package com.lulibrisync.controller.auth;

import com.lulibrisync.config.DBConnection;
import com.lulibrisync.utils.PasswordUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.time.LocalDate;
import java.time.Period;
import java.time.Year;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Locale;
import java.util.Set;
import java.util.regex.Pattern;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {

    private static final Pattern NAME_PART_PATTERN = Pattern.compile("^[A-Za-z](?:[A-Za-z .'-]{0,48}[A-Za-z])?$");
    private static final Pattern NAME_REPEAT_PATTERN = Pattern.compile("([A-Za-z])\\1{2,}", Pattern.CASE_INSENSITIVE);
    private static final int MIN_NAME_LETTERS = 2;
    private static final int MAX_NAME_TOKEN_LENGTH = 12;
    private static final Pattern CONTACT_PATTERN = Pattern.compile("^\\+?\\d{10,15}$");
    private static final Set<String> ALLOWED_EMAIL_DOMAINS = new HashSet<>(Arrays.asList(
            "gmail.com", "yahoo.com", "yahoo.com.ph", "outlook.com",
            "hotmail.com", "live.com", "icloud.com", "proton.me",
            "protonmail.com", "aol.com", "gmx.com", "mail.com"
    ));
    private static final Pattern PASSWORD_PATTERN = Pattern.compile(
            "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[^A-Za-z\\d\\s]).{12,100}$"
    );
    private static final Set<String> COMMON_WEAK_PASSWORDS = new HashSet<>(Arrays.asList(
            "password", "password123", "12345678", "123456789", "qwerty123",
            "admin123", "welcome123", "letmein123", "iloveyou", "abc12345",
            "passw0rd", "student123", "adminadmin", "11111111", "12341234"
    ));

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String firstName = normalizeName(request.getParameter("firstName"));
        String middleName = normalizeName(request.getParameter("middleName"));
        String lastName = normalizeName(request.getParameter("lastName"));
        String contactNumber = normalizeContactNumber(sanitize(request.getParameter("contactNumber")));
        String birthDateText = sanitize(request.getParameter("birthDate"));
        String email = sanitize(request.getParameter("email"));
        String password = sanitize(request.getParameter("password"));
        String confirmPassword = sanitize(request.getParameter("confirmPassword"));
        String agree = request.getParameter("agree");

        if (firstName.isEmpty() || lastName.isEmpty()
                || contactNumber.isEmpty() || birthDateText.isEmpty()
                || email.isEmpty() || password.isEmpty() || confirmPassword.isEmpty()) {
            redirectWithState(response, request, "missing", firstName, middleName, lastName, contactNumber, birthDateText, email);
            return;
        }

        if (!isValidNamePart(firstName) || !isValidNamePart(lastName)) {
            redirectWithState(response, request, "name", firstName, middleName, lastName, contactNumber, birthDateText, email);
            return;
        }

        if (!middleName.isEmpty() && !isValidNamePart(middleName)) {
            redirectWithState(response, request, "name", firstName, middleName, lastName, contactNumber, birthDateText, email);
            return;
        }

        if (!CONTACT_PATTERN.matcher(contactNumber).matches()) {
            redirectWithState(response, request, "contact", firstName, middleName, lastName, contactNumber, birthDateText, email);
            return;
        }

        LocalDate birthDate = parseBirthDate(birthDateText);
        if (birthDate == null) {
            redirectWithState(response, request, "birth_date", firstName, middleName, lastName, contactNumber, birthDateText, email);
            return;
        }

        LocalDate today = LocalDate.now();
        if (birthDate.isAfter(today)) {
            redirectWithState(response, request, "birth_date_future", firstName, middleName, lastName, contactNumber, birthDateText, email);
            return;
        }

        int age = Period.between(birthDate, today).getYears();
        if (age < 5 || age > 120) {
            redirectWithState(response, request, "birth_date_age", firstName, middleName, lastName, contactNumber, birthDateText, email);
            return;
        }

        if (!isLowercaseEmail(email)) {
            redirectWithState(response, request, "email", firstName, middleName, lastName, contactNumber, birthDateText, email);
            return;
        }

        String normalizedEmail = email.toLowerCase(Locale.ROOT);
        if (!isValidEmail(normalizedEmail) || hasInvalidEmailDots(normalizedEmail) || !isAllowedEmailProvider(normalizedEmail)) {
            redirectWithState(response, request, "email", firstName, middleName, lastName, contactNumber, birthDateText, email);
            return;
        }
        email = normalizedEmail;

        if (password.length() < 12) {
            redirectWithState(response, request, "password_length", firstName, middleName, lastName, contactNumber, birthDateText, email);
            return;
        }

        if (!PASSWORD_PATTERN.matcher(password).matches()) {
            redirectWithState(response, request, "password_format", firstName, middleName, lastName, contactNumber, birthDateText, email);
            return;
        }

        if (isCommonWeakPassword(password)) {
            redirectWithState(response, request, "password_common", firstName, middleName, lastName, contactNumber, birthDateText, email);
            return;
        }

        if (hasRepeatedCharacterSequence(password, 4)) {
            redirectWithState(response, request, "password_repeated", firstName, middleName, lastName, contactNumber, birthDateText, email);
            return;
        }

        if (containsPersonalInfo(password, firstName, middleName, lastName, email, contactNumber, birthDateText)) {
            redirectWithState(response, request, "password_personal", firstName, middleName, lastName, contactNumber, birthDateText, email);
            return;
        }

        if (!password.equals(confirmPassword)) {
            redirectWithState(response, request, "password_mismatch", firstName, middleName, lastName, contactNumber, birthDateText, email);
            return;
        }

        if (!"yes".equals(agree)) {
            redirectWithState(response, request, "terms", firstName, middleName, lastName, contactNumber, birthDateText, email);
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            if (conn == null) {
                redirectWithState(response, request, "server", firstName, middleName, lastName, contactNumber, birthDateText, email);
                return;
            }

            conn.setAutoCommit(false);

            try {
                if (emailExists(conn, email)) {
                    conn.rollback();
                    redirectWithState(response, request, "email_exists", firstName, middleName, lastName, contactNumber, birthDateText, email);
                    return;
                }

                String studentId = generateStudentId(conn);
                String hashedPassword = PasswordUtil.hashPassword(password);
                String fullName = buildFullName(firstName, middleName, lastName);
                if (fullName.length() > 100) {
                    redirectWithState(response, request, "name_length", firstName, middleName, lastName, contactNumber, birthDateText, email);
                    return;
                }

                String insertUserSql = "INSERT INTO users(name,email,password,role,student_id) VALUES(?,?,?, 'STUDENT', ?)";
                long userId;

                try (PreparedStatement ps = conn.prepareStatement(insertUserSql, Statement.RETURN_GENERATED_KEYS)) {
                    ps.setString(1, fullName);
                    ps.setString(2, email);
                    ps.setString(3, hashedPassword);
                    ps.setString(4, studentId);
                    ps.executeUpdate();

                    try (ResultSet keys = ps.getGeneratedKeys()) {
                        if (!keys.next()) {
                            throw new SQLException("Unable to create user account.");
                        }
                        userId = keys.getLong(1);
                    }
                }

                String insertStudentSql = "INSERT INTO students(user_id, student_id, course, year_level, phone, address, date_of_birth) "
                        + "VALUES(?,?,?,?,?,?,?)";
                try (PreparedStatement ps = conn.prepareStatement(insertStudentSql)) {
                    ps.setLong(1, userId);
                    ps.setString(2, studentId);
                    ps.setString(3, "Not set");
                    ps.setString(4, "Not set");
                    ps.setString(5, contactNumber);
                    ps.setString(6, "");
                    ps.setDate(7, Date.valueOf(birthDate));
                    ps.executeUpdate();
                }

                conn.commit();
                response.sendRedirect(request.getContextPath() + "/views/auth/login.jsp?success=registered&studentId=" + encode(studentId));
            } catch (Exception e) {
                conn.rollback();
                e.printStackTrace();
                redirectWithState(response, request, "server", firstName, middleName, lastName, contactNumber, birthDateText, email);
            } finally {
                conn.setAutoCommit(true);
            }

        } catch (Exception e) {
            e.printStackTrace();
            redirectWithState(response, request, "server", firstName, middleName, lastName, contactNumber, birthDateText, email);
        }
    }

    private boolean isValidNamePart(String value) {
        if (!NAME_PART_PATTERN.matcher(value).matches()) {
            return false;
        }

        if (countLetters(value) < MIN_NAME_LETTERS) {
            return false;
        }

        if (NAME_REPEAT_PATTERN.matcher(value).find()) {
            return false;
        }

        return !hasTooLongNameToken(value);
    }

    private int countLetters(String value) {
        int count = 0;
        for (int i = 0; i < value.length(); i++) {
            if (Character.isLetter(value.charAt(i))) {
                count++;
            }
        }
        return count;
    }

    private boolean hasTooLongNameToken(String value) {
        String[] tokens = value.split("[ .'-]+");
        for (String token : tokens) {
            if (!token.isEmpty() && token.length() > MAX_NAME_TOKEN_LENGTH) {
                return true;
            }
        }
        return false;
    }

    private String normalizeContactNumber(String value) {
        return value
                .replace(" ", "")
                .replace("-", "")
                .replace(".", "")
                .replace("(", "")
                .replace(")", "");
    }

    private LocalDate parseBirthDate(String value) {
        try {
            return LocalDate.parse(value);
        } catch (Exception e) {
            return null;
        }
    }

    private String buildFullName(String firstName, String middleName, String lastName) {
        return (firstName + " " + middleName + " " + lastName).replaceAll("\\s+", " ").trim();
    }

    private boolean emailExists(Connection conn, String email) throws SQLException {
        String checkSql = "SELECT 1 FROM users WHERE email = ?";
        try (PreparedStatement ps = conn.prepareStatement(checkSql)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    private String generateStudentId(Connection conn) throws SQLException {
        String prefix = Year.now().getValue() + "-";
        String sql = "SELECT MAX(CAST(SUBSTRING_INDEX(student_id, '-', -1) AS UNSIGNED)) "
                + "FROM users WHERE student_id LIKE ?";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, prefix + "%");
            try (ResultSet rs = ps.executeQuery()) {
                int nextNumber = 1;
                if (rs.next()) {
                    int currentMax = rs.getInt(1);
                    if (!rs.wasNull()) {
                        nextNumber = currentMax + 1;
                    }
                }
                return prefix + String.format("%04d", nextNumber);
            }
        }
    }

    private boolean isValidEmail(String email) {
        return email.matches("^[a-z0-9+_.-]+@[a-z0-9.-]+\\.[a-z]{2,}$");
    }

    private boolean isLowercaseEmail(String email) {
        return email.equals(email.toLowerCase(Locale.ROOT));
    }

    private boolean isAllowedEmailProvider(String email) {
        int atIndex = email.indexOf('@');
        if (atIndex <= 0 || atIndex >= email.length() - 1) {
            return false;
        }

        String domain = email.substring(atIndex + 1);
        return ALLOWED_EMAIL_DOMAINS.contains(domain)
                || domain.endsWith(".edu")
                || domain.endsWith(".edu.ph");
    }

    private boolean hasInvalidEmailDots(String email) {
        int atIndex = email.indexOf('@');
        if (atIndex <= 0 || atIndex >= email.length() - 1) {
            return true;
        }

        String localPart = email.substring(0, atIndex);
        String domainPart = email.substring(atIndex + 1);

        return localPart.startsWith(".")
                || localPart.endsWith(".")
                || localPart.contains("..")
                || domainPart.startsWith(".")
                || domainPart.endsWith(".")
                || domainPart.contains("..");
    }

    private boolean isCommonWeakPassword(String password) {
        return COMMON_WEAK_PASSWORDS.contains(password.toLowerCase(Locale.ROOT));
    }

    private boolean hasRepeatedCharacterSequence(String password, int minSequenceLength) {
        int repeatCount = 1;
        for (int i = 1; i < password.length(); i++) {
            if (password.charAt(i) == password.charAt(i - 1)) {
                repeatCount++;
                if (repeatCount >= minSequenceLength) {
                    return true;
                }
            } else {
                repeatCount = 1;
            }
        }
        return false;
    }

    private boolean containsPersonalInfo(String password, String firstName, String middleName, String lastName,
                                         String email, String contactNumber, String birthDateText) {
        String lowerPassword = password.toLowerCase(Locale.ROOT);

        String emailLocalPart = email;
        int atIndex = email.indexOf('@');
        if (atIndex > 0) {
            emailLocalPart = email.substring(0, atIndex);
        }

        String[] tokens = {
                normalizeToken(firstName),
                normalizeToken(middleName),
                normalizeToken(lastName),
                normalizeToken(emailLocalPart),
                normalizeToken(contactNumber),
                normalizeToken(birthDateText)
        };

        for (String token : tokens) {
            if (token.length() >= 3 && lowerPassword.contains(token)) {
                return true;
            }
        }

        return false;
    }

    private String normalizeToken(String value) {
        return value == null ? "" : value.toLowerCase(Locale.ROOT).replaceAll("[^a-z0-9]", "");
    }

    private String sanitize(String value) {
        return value == null ? "" : value.trim();
    }

    private String normalizeName(String value) {
        return sanitize(value).replaceAll("\\s+", " ");
    }

    private void redirectWithState(HttpServletResponse response, HttpServletRequest request, String error,
                                   String firstName, String middleName, String lastName,
                                   String contactNumber, String birthDate, String email) throws IOException {
        String redirectUrl = request.getContextPath()
                + "/views/auth/register.jsp?error=" + encode(error)
                + "&firstName=" + encode(firstName)
                + "&middleName=" + encode(middleName)
                + "&lastName=" + encode(lastName)
                + "&contactNumber=" + encode(contactNumber)
                + "&birthDate=" + encode(birthDate)
                + "&email=" + encode(email);
        response.sendRedirect(redirectUrl);
    }

    private String encode(String value) {
        return URLEncoder.encode(value, StandardCharsets.UTF_8);
    }
}
