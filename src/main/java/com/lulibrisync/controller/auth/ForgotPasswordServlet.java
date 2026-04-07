package com.lulibrisync.controller.auth;

import com.lulibrisync.config.AppConfig;
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
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.UUID;

@WebServlet("/forgot-password")
public class ForgotPasswordServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String action = value(request.getParameter("action"));
        if ("reset".equals(action)) {
            handleReset(request, response);
            return;
        }

        handleRequestToken(request, response);
    }

    private void handleRequestToken(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String email = value(request.getParameter("email")).toLowerCase();

        if (email.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/views/auth/forgot-password.jsp?error=missing_email");
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            if (conn == null) {
                response.sendRedirect(request.getContextPath() + "/views/auth/forgot-password.jsp?error=server");
                return;
            }

            String lookupSql = "SELECT id FROM users WHERE email = ?";
            try (PreparedStatement lookupPs = conn.prepareStatement(lookupSql)) {
                lookupPs.setString(1, email);

                try (ResultSet rs = lookupPs.executeQuery()) {
                    if (!rs.next()) {
                        response.sendRedirect(request.getContextPath() + "/views/auth/forgot-password.jsp?error=email_not_found");
                        return;
                    }

                    long userId = rs.getLong("id");
                    String token = UUID.randomUUID().toString().replace("-", "").toUpperCase();
                    LocalDateTime expiry = LocalDateTime.now().plusMinutes(AppConfig.RESET_TOKEN_EXPIRY_MINUTES);

                    String insertSql = "INSERT INTO password_reset_tokens(user_id, token, expires_at, used) VALUES(?,?,?,?)";
                    try (PreparedStatement insertPs = conn.prepareStatement(insertSql)) {
                        insertPs.setLong(1, userId);
                        insertPs.setString(2, token);
                        insertPs.setTimestamp(3, Timestamp.valueOf(expiry));
                        insertPs.setBoolean(4, false);
                        insertPs.executeUpdate();
                    }

                    String redirect = request.getContextPath()
                            + "/views/auth/forgot-password.jsp?success=token_created&email=" + encode(email)
                            + "&token=" + encode(token);
                    response.sendRedirect(redirect);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/views/auth/forgot-password.jsp?error=server");
        }
    }

    private void handleReset(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String token = value(request.getParameter("token"));
        String password = value(request.getParameter("password"));
        String confirmPassword = value(request.getParameter("confirmPassword"));

        if (token.isEmpty() || password.isEmpty() || confirmPassword.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/views/auth/forgot-password.jsp?error=missing_reset_fields&token=" + encode(token));
            return;
        }

        if (!password.equals(confirmPassword)) {
            response.sendRedirect(request.getContextPath() + "/views/auth/forgot-password.jsp?error=password_mismatch&token=" + encode(token));
            return;
        }

        if (password.length() < 8 || !password.matches("^(?=.*[A-Za-z])(?=.*\\d).{8,100}$")) {
            response.sendRedirect(request.getContextPath() + "/views/auth/forgot-password.jsp?error=password_format&token=" + encode(token));
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            if (conn == null) {
                response.sendRedirect(request.getContextPath() + "/views/auth/forgot-password.jsp?error=server");
                return;
            }

            conn.setAutoCommit(false);

            try {
                String lookupSql = "SELECT user_id, expires_at, used FROM password_reset_tokens WHERE token = ?";
                long userId;
                Timestamp expiresAt;
                boolean used;

                try (PreparedStatement lookupPs = conn.prepareStatement(lookupSql)) {
                    lookupPs.setString(1, token);

                    try (ResultSet rs = lookupPs.executeQuery()) {
                        if (!rs.next()) {
                            conn.rollback();
                            response.sendRedirect(request.getContextPath() + "/views/auth/forgot-password.jsp?error=invalid_token");
                            return;
                        }

                        userId = rs.getLong("user_id");
                        expiresAt = rs.getTimestamp("expires_at");
                        used = rs.getBoolean("used");
                    }
                }

                if (used || expiresAt == null || expiresAt.toLocalDateTime().isBefore(LocalDateTime.now())) {
                    conn.rollback();
                    response.sendRedirect(request.getContextPath() + "/views/auth/forgot-password.jsp?error=expired_token");
                    return;
                }

                try (PreparedStatement updateUser = conn.prepareStatement("UPDATE users SET password = ? WHERE id = ?")) {
                    updateUser.setString(1, PasswordUtil.hashPassword(password));
                    updateUser.setLong(2, userId);
                    updateUser.executeUpdate();
                }

                try (PreparedStatement updateToken = conn.prepareStatement("UPDATE password_reset_tokens SET used = ? WHERE token = ?")) {
                    updateToken.setBoolean(1, true);
                    updateToken.setString(2, token);
                    updateToken.executeUpdate();
                }

                conn.commit();
                response.sendRedirect(request.getContextPath() + "/views/auth/login.jsp?success=password_reset");
            } catch (Exception e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/views/auth/forgot-password.jsp?error=server");
        }
    }

    private String value(String text) {
        return text == null ? "" : text.trim();
    }

    private String encode(String value) {
        return URLEncoder.encode(value, StandardCharsets.UTF_8);
    }
}
