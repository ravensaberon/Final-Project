package com.lulibrisync.api.service;

import com.lulibrisync.api.dto.AuthLoginRequest;
import com.lulibrisync.api.dto.AuthRegisterRequest;
import com.lulibrisync.api.dto.AuthResponse;
import com.lulibrisync.api.dto.RegisterResponse;
import com.lulibrisync.api.model.ApiUser;
import com.lulibrisync.api.model.ApiUserSummary;
import com.lulibrisync.api.repository.ApiUserRepository;
import com.lulibrisync.api.security.JwtTokenService;
import com.lulibrisync.utils.PasswordUtil;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.time.LocalDate;
import java.time.Period;
import java.time.Year;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Locale;
import java.util.Set;
import java.util.regex.Pattern;

@Service
public class AuthApiService {

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

    private final ApiUserRepository apiUserRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenService jwtTokenService;

    public AuthApiService(ApiUserRepository apiUserRepository, PasswordEncoder passwordEncoder, JwtTokenService jwtTokenService) {
        this.apiUserRepository = apiUserRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtTokenService = jwtTokenService;
    }

    @Transactional
    public RegisterResponse register(AuthRegisterRequest request) {
        String firstName = normalizeName(request.getFirstName());
        String middleName = normalizeName(request.getMiddleName());
        String lastName = normalizeName(request.getLastName());
        String emailInput = sanitize(request.getEmail());
        String password = sanitize(request.getPassword());
        String confirmPassword = sanitize(request.getConfirmPassword());
        String contactNumber = normalizeContactNumber(sanitize(request.getContactNumber()));
        String birthDateText = sanitize(request.getBirthDate());

        if (!isLowercaseEmail(emailInput)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Email must be lowercase.");
        }

        String email = emailInput.toLowerCase(Locale.ROOT);

        if (!isValidNamePart(firstName) || !isValidNamePart(lastName)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                    "First and last name must be at least 2 letters, no symbols/digits, and no triple repeated letters.");
        }
        if (!middleName.isEmpty() && !isValidNamePart(middleName)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                    "Middle name must be at least 2 letters if provided, with no symbols/digits or triple repeated letters.");
        }
        if (!isValidEmail(email) || hasInvalidEmailDots(email)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Invalid email format.");
        }
        if (!isAllowedEmailProvider(email)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                    "Unsupported email provider. Use gmail, outlook, yahoo, or school .edu/.edu.ph.");
        }
        if (apiUserRepository.existsByEmail(email)) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Email is already registered.");
        }
        if (!CONTACT_PATTERN.matcher(contactNumber).matches()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Contact number must be 10 to 15 digits.");
        }

        LocalDate birthDate = parseBirthDate(birthDateText);
        if (birthDate == null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Birth date is invalid.");
        }
        if (birthDate.isAfter(LocalDate.now())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Birth date cannot be in the future.");
        }
        int age = Period.between(birthDate, LocalDate.now()).getYears();
        if (age < 5 || age > 120) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Age must be between 5 and 120.");
        }

        if (!password.equals(confirmPassword)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Password and confirm password do not match.");
        }
        validateStrongPassword(password, firstName, middleName, lastName, email, contactNumber, birthDateText);

        String fullName = buildFullName(firstName, middleName, lastName);
        if (fullName.length() > 100) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Combined full name is too long.");
        }

        String studentId = generateStudentId();
        String passwordHash = passwordEncoder.encode(password); // BCrypt

        long userId = apiUserRepository.insertUser(fullName, email, passwordHash, "STUDENT", studentId);
        apiUserRepository.insertStudent(userId, studentId, contactNumber, birthDate);

        return new RegisterResponse("Registration successful.", studentId);
    }

    @Transactional
    public AuthResponse login(AuthLoginRequest request) {
        String email = sanitize(request.getEmail()).toLowerCase(Locale.ROOT);
        String password = sanitize(request.getPassword());

        ApiUser user = apiUserRepository.findByEmail(email)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid email or password."));

        if (!"ACTIVE".equalsIgnoreCase(user.getStatus())) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Account is inactive.");
        }

        boolean isBcryptHash = isBcryptHash(user.getPassword());
        boolean passwordMatches = isBcryptHash
                ? passwordEncoder.matches(password, user.getPassword())
                : PasswordUtil.verifyPassword(password, user.getPassword());

        if (!passwordMatches) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid email or password.");
        }

        // Automatic migration for legacy hashed/plain passwords into BCrypt.
        if (!isBcryptHash) {
            apiUserRepository.updatePassword(user.getId(), passwordEncoder.encode(password));
        }

        String token = jwtTokenService.generateToken(user);
        ApiUserSummary summary = new ApiUserSummary(
                user.getId(),
                user.getName(),
                user.getEmail(),
                user.getRole(),
                user.getStatus(),
                user.getStudentId()
        );

        return new AuthResponse(token, "Bearer", jwtTokenService.getJwtExpirationMs(), summary);
    }

    private String generateStudentId() {
        int year = Year.now().getValue();
        int nextSequence = apiUserRepository.nextStudentSequence(year);
        return year + "-" + String.format("%04d", nextSequence);
    }

    private void validateStrongPassword(String password, String firstName, String middleName, String lastName,
                                        String email, String contactNumber, String birthDateText) {
        if (password.length() < 12) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Password must be at least 12 characters long.");
        }
        if (!PASSWORD_PATTERN.matcher(password).matches()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                    "Password must include uppercase, lowercase, number, and special character.");
        }
        if (COMMON_WEAK_PASSWORDS.contains(password.toLowerCase(Locale.ROOT))) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Password is too common.");
        }
        if (hasRepeatedCharacterSequence(password, 4)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Password cannot contain repeated characters.");
        }
        if (containsPersonalInfo(password, firstName, middleName, lastName, email, contactNumber, birthDateText)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Password cannot contain personal information.");
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

    private LocalDate parseBirthDate(String value) {
        try {
            return LocalDate.parse(value);
        } catch (Exception e) {
            return null;
        }
    }

    private String normalizeContactNumber(String value) {
        return value
                .replace(" ", "")
                .replace("-", "")
                .replace(".", "")
                .replace("(", "")
                .replace(")", "");
    }

    private String buildFullName(String firstName, String middleName, String lastName) {
        return (firstName + " " + middleName + " " + lastName).replaceAll("\\s+", " ").trim();
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

    private boolean isBcryptHash(String hash) {
        if (hash == null) {
            return false;
        }
        return hash.startsWith("$2a$") || hash.startsWith("$2b$") || hash.startsWith("$2y$");
    }

    private String sanitize(String value) {
        return value == null ? "" : value.trim();
    }

    private String normalizeName(String value) {
        return sanitize(value).replaceAll("\\s+", " ");
    }
}
