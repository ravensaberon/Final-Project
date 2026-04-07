package com.lulibrisync.controller.auth;

import com.lulibrisync.config.DBConnection;
import com.lulibrisync.utils.PasswordUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

@WebServlet("/change-password")
public class ChangePasswordServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/views/auth/login.jsp");
            return;
        }

        long userId = ((Number) session.getAttribute("userId")).longValue();
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

            String selectSql = "SELECT password FROM users WHERE id = ?";
            try (PreparedStatement selectPs = conn.prepareStatement(selectSql)) {
                selectPs.setLong(1, userId);

                try (ResultSet rs = selectPs.executeQuery()) {
                    if (!rs.next() || !PasswordUtil.verifyPassword(currentPassword, rs.getString("password"))) {
                        response.sendRedirect(request.getContextPath() + "/views/auth/change-password.jsp?error=current");
                        return;
                    }
                }
            }

            String updateSql = "UPDATE users SET password = ? WHERE id = ?";
            try (PreparedStatement updatePs = conn.prepareStatement(updateSql)) {
                updatePs.setString(1, PasswordUtil.hashPassword(newPassword));
                updatePs.setLong(2, userId);
                updatePs.executeUpdate();
            }

            response.sendRedirect(request.getContextPath() + "/views/auth/change-password.jsp?success=updated");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/views/auth/change-password.jsp?error=server");
        }
    }

    private String value(String text) {
        return text == null ? "" : text.trim();
    }
}
