package com.lulibrisync.controller.auth;

import com.lulibrisync.config.ActiveSessionManager;
import com.lulibrisync.config.DBConnection;
import com.lulibrisync.utils.PasswordUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String email = value(request.getParameter("email")).toLowerCase();
        String password = value(request.getParameter("password"));

        if (email.isEmpty() || password.isEmpty()) {
            redirectWithEmail(response, request, "invalid", email);
            return;
        }

        HttpSession existingSession = request.getSession(false);
        if (existingSession != null && existingSession.getAttribute("user") != null) {
            redirectWithEmail(response, request, "session_active", email);
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            if (conn == null) {
                redirectWithEmail(response, request, "server", email);
                return;
            }

            String sql = "SELECT id, name, email, password, role, student_id FROM users WHERE email = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, email);

                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        redirectWithEmail(response, request, "invalid", email);
                        return;
                    }

                    String storedPassword = rs.getString("password");
                    if (!PasswordUtil.verifyPassword(password, storedPassword)) {
                        redirectWithEmail(response, request, "invalid", email);
                        return;
                    }

                    if (!PasswordUtil.isBcryptHash(storedPassword)) {
                        String upgradeSql = "UPDATE users SET password = ? WHERE id = ?";
                        try (PreparedStatement upgradePs = conn.prepareStatement(upgradeSql)) {
                            upgradePs.setString(1, PasswordUtil.hashPassword(password));
                            upgradePs.setLong(2, rs.getLong("id"));
                            upgradePs.executeUpdate();
                        }
                    }

                    HttpSession session = request.getSession(true);
                    String role = rs.getString("role");

                    if (!ActiveSessionManager.tryAcquire(
                            request.getServletContext(),
                            session,
                            rs.getString("name"),
                            role)) {
                        session.invalidate();
                        redirectWithEmail(response, request, "session_active", email);
                        return;
                    }

                    session.setAttribute("userId", rs.getLong("id"));
                    session.setAttribute("user", rs.getString("name"));
                    session.setAttribute("userEmail", rs.getString("email"));
                    session.setAttribute("studentId", rs.getString("student_id"));
                    session.setAttribute("role", role);

                    if ("ADMIN".equalsIgnoreCase(role)) {
                        response.sendRedirect(request.getContextPath() + "/admin/dashboard");
                    } else {
                        response.sendRedirect(request.getContextPath() + "/student/dashboard");
                    }
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
            redirectWithEmail(response, request, "server", email);
        }
    }

    private String value(String text) {
        return text == null ? "" : text.trim();
    }

    private void redirectWithEmail(HttpServletResponse response, HttpServletRequest request, String error, String email)
            throws IOException {
        response.sendRedirect(request.getContextPath()
                + "/views/auth/login.jsp?error=" + encode(error)
                + "&email=" + encode(email));
    }

    private String encode(String value) {
        return URLEncoder.encode(value == null ? "" : value, StandardCharsets.UTF_8);
    }
}
