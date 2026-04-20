package com.lulibrisync.controller.auth;

import com.lulibrisync.config.DBConnection;
import com.lulibrisync.service.EmailService;
import com.lulibrisync.utils.PasswordUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.Serializable;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.security.SecureRandom;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.LocalDateTime;

@WebServlet("/change-password")
public class ChangePasswordServlet extends HttpServlet {

    private static final String SESSION_PENDING_PASSWORD_CHANGE = "pendingPasswordChange";
    private static final String SESSION_PENDING_PASSWORD_MASKED_EMAIL = "pendingPasswordOtpMaskedEmail";

    private final EmailService emailService = new EmailService();
    private final SecureRandom secureRandom = new SecureRandom();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/views/auth/login.jsp");
            return;
        }

        String action = value(request.getParameter("action"));
        if ("verify-otp".equalsIgnoreCase(action)) {
            handleVerifyOtp(request, response, session);
            return;
        }

        handleRequestOtp(request, response, session);
    }

    private void handleRequestOtp(HttpServletRequest request, HttpServletResponse response, HttpSession session)
            throws IOException {

        long userId = parseLong(session.getAttribute("userId"));
        String currentPassword = value(request.getParameter("currentPassword"));
        String newPassword = value(request.getParameter("newPassword"));
        String confirmPassword = value(request.getParameter("confirmPassword"));

        if (currentPassword.isEmpty() || newPassword.isEmpty() || confirmPassword.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/views/auth/change-password.jsp?error=missing");
            return;
        }

        if (!newPassword.equals(confirmPassword)) {
            response.sendRedirect(request.getContextPath() + "/views/auth/change-password.jsp?error=mismatch");
            return;
        }

        if (newPassword.length() < 8 || !newPassword.matches("^(?=.*[A-Za-z])(?=.*\\d).{8,100}$")) {
            response.sendRedirect(request.getContextPath() + "/views/auth/change-password.jsp?error=format");
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            if (conn == null) {
                response.sendRedirect(request.getContextPath() + "/views/auth/change-password.jsp?error=server");
                return;
            }

            String selectSql = "SELECT name, email, password FROM users WHERE id = ?";
            try (PreparedStatement selectPs = conn.prepareStatement(selectSql)) {
                selectPs.setLong(1, userId);

                try (ResultSet rs = selectPs.executeQuery()) {
                    if (!rs.next()) {
                        response.sendRedirect(request.getContextPath() + "/views/auth/change-password.jsp?error=server");
                        return;
                    }

                    if (!PasswordUtil.verifyPassword(currentPassword, rs.getString("password"))) {
                        response.sendRedirect(request.getContextPath() + "/views/auth/change-password.jsp?error=current");
                        return;
                    }

                    String email = value(rs.getString("email")).toLowerCase();
                    String name = value(rs.getString("name"));
                    if (email.isEmpty()) {
                        response.sendRedirect(request.getContextPath() + "/views/auth/change-password.jsp?error=mail_not_configured");
                        return;
                    }

                    String otpCode = String.format("%06d", secureRandom.nextInt(1_000_000));
                    PendingPasswordChange pendingChange = new PendingPasswordChange(
                            userId,
                            PasswordUtil.hashPassword(newPassword),
                            otpCode,
                            LocalDateTime.now().plusMinutes(10)
                    );

                    emailService.sendPasswordChangeOtp(email, name, otpCode);
                    session.setAttribute(SESSION_PENDING_PASSWORD_CHANGE, pendingChange);
                    session.setAttribute(SESSION_PENDING_PASSWORD_MASKED_EMAIL, maskEmail(email));
                    response.sendRedirect(request.getContextPath() + "/views/auth/change-password.jsp?success=otp_sent");
                }
            }
        } catch (IllegalStateException e) {
            String error = "server";
            if ("mail_not_configured".equalsIgnoreCase(e.getMessage())) {
                error = "mail_not_configured";
            } else if ("mail_send_failed".equalsIgnoreCase(e.getMessage())) {
                error = "mail_send_failed";
            }
            response.sendRedirect(request.getContextPath() + "/views/auth/change-password.jsp?error=" + encode(error));
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/views/auth/change-password.jsp?error=server");
        }
    }

    private void handleVerifyOtp(HttpServletRequest request, HttpServletResponse response, HttpSession session)
            throws IOException {

        PendingPasswordChange pendingChange = (PendingPasswordChange) session.getAttribute(SESSION_PENDING_PASSWORD_CHANGE);
        if (pendingChange == null) {
            response.sendRedirect(request.getContextPath() + "/views/auth/change-password.jsp?error=otp_missing");
            return;
        }

        String otp = value(request.getParameter("otp"));
        if (otp.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/views/auth/change-password.jsp?error=otp_missing");
            return;
        }

        if (pendingChange.expiresAt.isBefore(LocalDateTime.now())) {
            clearPendingPasswordChange(session);
            response.sendRedirect(request.getContextPath() + "/views/auth/change-password.jsp?error=otp_expired");
            return;
        }

        if (!pendingChange.otpCode.equals(otp)) {
            response.sendRedirect(request.getContextPath() + "/views/auth/change-password.jsp?error=otp_invalid");
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            if (conn == null) {
                response.sendRedirect(request.getContextPath() + "/views/auth/change-password.jsp?error=server");
                return;
            }

            String updateSql = "UPDATE users SET password = ? WHERE id = ?";
            try (PreparedStatement updatePs = conn.prepareStatement(updateSql)) {
                updatePs.setString(1, pendingChange.passwordHash);
                updatePs.setLong(2, pendingChange.userId);
                updatePs.executeUpdate();
            }

            clearPendingPasswordChange(session);
            response.sendRedirect(request.getContextPath() + "/views/auth/change-password.jsp?success=updated");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/views/auth/change-password.jsp?error=server");
        }
    }

    private void clearPendingPasswordChange(HttpSession session) {
        session.removeAttribute(SESSION_PENDING_PASSWORD_CHANGE);
        session.removeAttribute(SESSION_PENDING_PASSWORD_MASKED_EMAIL);
    }

    private long parseLong(Object value) {
        try {
            return Long.parseLong(String.valueOf(value).trim());
        } catch (Exception e) {
            return 0L;
        }
    }

    private String value(String text) {
        return text == null ? "" : text.trim();
    }

    private String encode(String value) {
        return URLEncoder.encode(value == null ? "" : value, StandardCharsets.UTF_8);
    }

    private String maskEmail(String email) {
        if (email == null || email.isBlank() || !email.contains("@")) {
            return "your email";
        }
        String[] parts = email.split("@", 2);
        String local = parts[0];
        String domain = parts[1];
        if (local.length() <= 2) {
            return local.charAt(0) + "***@" + domain;
        }
        return local.substring(0, 2) + "***@" + domain;
    }

    private static final class PendingPasswordChange implements Serializable {
        private final long userId;
        private final String passwordHash;
        private final String otpCode;
        private final LocalDateTime expiresAt;

        private PendingPasswordChange(long userId, String passwordHash,
                                      String otpCode, LocalDateTime expiresAt) {
            this.userId = userId;
            this.passwordHash = passwordHash;
            this.otpCode = otpCode;
            this.expiresAt = expiresAt;
        }
    }
}
