<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    String error = request.getParameter("error");
    String success = request.getParameter("success");
    String token = request.getParameter("token");
    String email = request.getParameter("email");

    if (token == null) {
        token = "";
    }
    if (email == null) {
        email = "";
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Recover Password | LU Librisync</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/librisync.css">
</head>
<body>
    <div class="page-shell hero-split">
        <section class="hero-panel">
            <div class="brand-pill">LU</div>
            <h1>Recover your password.</h1>
            <p>LU Librisync includes a password recovery flow for students and administrators. Request a reset token, then set a new password securely.</p>

            <ul>
                <li>Request a password reset token using your registered email</li>
                <li>Reset your password with a fresh credential that includes letters and numbers</li>
                <li>Continue back to login after the update is complete</li>
            </ul>

            <div class="info-card">
                <strong>Demo-friendly reset flow</strong>
                <p>If email delivery is not configured yet, the generated reset token is shown on this page so you can still continue the full recovery process during development.</p>
            </div>
        </section>

        <section class="form-panel">
            <h2>Password Recovery</h2>
            <p class="subtitle">Request a reset token or use an existing token to set a new password.</p>

            <% if ("token_created".equals(success)) { %>
                <div class="alert success">
                    Reset token created successfully for <strong><%= email %></strong>.
                    Use this development token to continue: <strong><%= token %></strong>
                </div>
            <% } %>

            <% if ("missing_email".equals(error)) { %>
                <div class="alert error">Enter your registered email address to request a reset token.</div>
            <% } else if ("email_not_found".equals(error)) { %>
                <div class="alert error">No LU Librisync account was found for that email address.</div>
            <% } else if ("missing_reset_fields".equals(error)) { %>
                <div class="alert error">Complete the token and password fields to reset your password.</div>
            <% } else if ("password_mismatch".equals(error)) { %>
                <div class="alert error">New password and confirm password do not match.</div>
            <% } else if ("password_format".equals(error)) { %>
                <div class="alert error">Your new password must be at least 8 characters and include at least one letter and one number.</div>
            <% } else if ("invalid_token".equals(error)) { %>
                <div class="alert error">That reset token is not valid.</div>
            <% } else if ("expired_token".equals(error)) { %>
                <div class="alert error">That reset token has expired or has already been used.</div>
            <% } else if ("server".equals(error)) { %>
                <div class="alert error">The system could not finish the recovery request right now. Please try again.</div>
            <% } %>

            <div class="content-card" style="margin-bottom:18px;">
                <h3 class="section-title">1. Request Reset Token</h3>
                <p class="section-copy">Enter your email to generate a password reset token.</p>

                <form class="form-stack" action="<%= request.getContextPath() %>/forgot-password" method="post">
                    <input type="hidden" name="action" value="request">
                    <div class="field-group">
                        <label for="requestEmail">Registered Email</label>
                        <input id="requestEmail" name="email" type="email" placeholder="Enter your email" required>
                    </div>
                    <button class="button" type="submit">Generate Reset Token</button>
                </form>
            </div>

            <div class="content-card">
                <h3 class="section-title">2. Set New Password</h3>
                <p class="section-copy">Use the reset token to create a new password for your account.</p>

                <form class="form-stack" action="<%= request.getContextPath() %>/forgot-password" method="post">
                    <input type="hidden" name="action" value="reset">

                    <div class="field-group">
                        <label for="token">Reset Token</label>
                        <input id="token" name="token" type="text" value="<%= token %>" placeholder="Enter reset token" required>
                    </div>

                    <div class="form-grid">
                        <div class="field-group">
                            <label for="password">New Password</label>
                            <input id="password" name="password" type="password" placeholder="Create new password" minlength="8" required>
                        </div>
                        <div class="field-group">
                            <label for="confirmPassword">Confirm Password</label>
                            <input id="confirmPassword" name="confirmPassword" type="password" placeholder="Re-enter new password" minlength="8" required>
                        </div>
                    </div>

                    <button class="button" type="submit">Reset Password</button>
                </form>
            </div>

            <p class="inline-link" style="margin-top:18px;">Back to <a href="<%= request.getContextPath() %>/views/auth/login.jsp">login</a>.</p>
        </section>
    </div>
</body>
</html>
