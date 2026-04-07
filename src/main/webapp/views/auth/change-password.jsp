<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    if (session.getAttribute("user") == null) {
        response.sendRedirect(request.getContextPath() + "/views/auth/login.jsp");
        return;
    }

    String error = request.getParameter("error");
    String success = request.getParameter("success");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Change Password | LU Librisync</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/librisync.css">
</head>
<body>
    <div class="page-shell hero-split">
        <section class="hero-panel">
            <div class="brand-pill">LU</div>
            <h1>Change your password.</h1>
            <p>Both administrators and students can update their own LU Librisync password from this secure page.</p>

            <ul>
                <li>Confirm your current password before making a change</li>
                <li>Use a stronger replacement password with letters and numbers</li>
                <li>Return to your dashboard after a successful update</li>
            </ul>
        </section>

        <section class="form-panel">
            <h2>Change Password</h2>
            <p class="subtitle">Signed in as <strong><%= session.getAttribute("user") %></strong>.</p>

            <% if ("updated".equals(success)) { %>
                <div class="alert success">Your password has been updated successfully.</div>
            <% } %>

            <% if ("missing".equals(error)) { %>
                <div class="alert error">Please complete all password fields.</div>
            <% } else if ("mismatch".equals(error)) { %>
                <div class="alert error">New password and confirm password do not match.</div>
            <% } else if ("format".equals(error)) { %>
                <div class="alert error">Your new password must be at least 8 characters and include at least one letter and one number.</div>
            <% } else if ("current".equals(error)) { %>
                <div class="alert error">Your current password is incorrect.</div>
            <% } else if ("server".equals(error)) { %>
                <div class="alert error">The system could not update your password right now.</div>
            <% } %>

            <form class="form-stack" action="<%= request.getContextPath() %>/change-password" method="post">
                <div class="field-group">
                    <label for="currentPassword">Current Password</label>
                    <input id="currentPassword" name="currentPassword" type="password" placeholder="Enter current password" required>
                </div>

                <div class="form-grid">
                    <div class="field-group">
                        <label for="newPassword">New Password</label>
                        <input id="newPassword" name="newPassword" type="password" placeholder="Enter new password" minlength="8" required>
                    </div>
                    <div class="field-group">
                        <label for="confirmPassword">Confirm New Password</label>
                        <input id="confirmPassword" name="confirmPassword" type="password" placeholder="Confirm new password" minlength="8" required>
                    </div>
                </div>

                <button class="button" type="submit">Update Password</button>
            </form>

            <p class="inline-link" style="margin-top:18px;">
                <% if ("ADMIN".equals(session.getAttribute("role"))) { %>
                    Return to <a href="<%= request.getContextPath() %>/admin/dashboard">admin dashboard</a>.
                <% } else { %>
                    Return to <a href="<%= request.getContextPath() %>/student/dashboard">student dashboard</a>.
                <% } %>
            </p>
        </section>
    </div>
</body>
</html>
