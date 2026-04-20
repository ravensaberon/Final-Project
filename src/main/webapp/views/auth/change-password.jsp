<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    if (session.getAttribute("user") == null) {
        response.sendRedirect(request.getContextPath() + "/views/auth/login.jsp");
        return;
    }

    String error = request.getParameter("error");
    String success = request.getParameter("success");
    boolean otpPending = session.getAttribute("pendingPasswordChange") != null;
    String maskedOtpEmail = String.valueOf(session.getAttribute("pendingPasswordOtpMaskedEmail"));
    if ("null".equalsIgnoreCase(maskedOtpEmail)) {
        maskedOtpEmail = "";
    }
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
            <p>Your password update is now protected with email OTP verification before the new password is actually saved.</p>

            <ul>
                <li>Confirm your current password before requesting a password change OTP</li>
                <li>Use a stronger replacement password with letters and numbers</li>
                <li>Enter the OTP sent to your current account email before the change is applied</li>
            </ul>

            <div class="info-card">
                <strong>Signed in as</strong>
                <p style="margin:8px 0 0;"><%= session.getAttribute("user") %></p>
                <p style="margin:10px 0 0;">OTP destination: <strong><%= session.getAttribute("userEmail") %></strong></p>
            </div>
        </section>

        <section class="form-panel">
            <h2>Change Password</h2>
            <p class="subtitle">We will ask for confirmation first, then send an OTP to your account email before the password update is finalized.</p>

            <% if ("updated".equals(success)) { %>
                <div class="alert success">Your password has been updated successfully after OTP verification.</div>
            <% } else if ("otp_sent".equals(success)) { %>
                <div class="alert success">An OTP has been sent to <strong><%= maskedOtpEmail %></strong>. Enter it below to complete the password change.</div>
            <% } %>

            <% if ("missing".equals(error)) { %>
                <div class="alert error">Please complete all password fields.</div>
            <% } else if ("mismatch".equals(error)) { %>
                <div class="alert error">New password and confirm password do not match.</div>
            <% } else if ("format".equals(error)) { %>
                <div class="alert error">Your new password must be at least 8 characters and include at least one letter and one number.</div>
            <% } else if ("current".equals(error)) { %>
                <div class="alert error">Your current password is incorrect.</div>
            <% } else if ("otp_missing".equals(error)) { %>
                <div class="alert warning">Enter the OTP from your email first before we change your password.</div>
            <% } else if ("otp_invalid".equals(error)) { %>
                <div class="alert error">The OTP you entered is incorrect. Please try again.</div>
            <% } else if ("otp_expired".equals(error)) { %>
                <div class="alert warning">That OTP has expired. Request a new one from the password change form.</div>
            <% } else if ("mail_not_configured".equals(error)) { %>
                <div class="alert error">OTP email sending is not configured yet. Add your Gmail/SMTP settings first, then try again.</div>
            <% } else if ("mail_send_failed".equals(error)) { %>
                <div class="alert error">We tried to send the OTP but the email delivery failed. Double-check the Gmail/SMTP settings.</div>
            <% } else if ("server".equals(error)) { %>
                <div class="alert error">The system could not update your password right now.</div>
            <% } %>

            <% if (otpPending) { %>
                <div class="info-card" style="margin-bottom:18px;">
                    <h3 style="margin:0 0 8px;">Verify OTP Before Updating</h3>
                    <p style="margin:0 0 16px; color:var(--muted); line-height:1.6;">We already sent a one-time password to <strong><%= maskedOtpEmail %></strong>. Enter it below to confirm the change password request.</p>
                    <form class="form-stack" action="<%= request.getContextPath() %>/change-password" method="post">
                        <input type="hidden" name="action" value="verify-otp">
                        <div class="form-grid">
                            <div class="field-group">
                                <label for="otp">OTP Code</label>
                                <input id="otp" name="otp" type="text" inputmode="numeric" maxlength="6" placeholder="Enter 6-digit OTP" required>
                            </div>
                            <div class="field-group">
                                <label for="otpEmail">Sent To</label>
                                <input id="otpEmail" type="text" value="<%= maskedOtpEmail %>" readonly>
                            </div>
                        </div>
                        <button class="button" type="submit">Verify OTP And Update Password</button>
                    </form>
                </div>
            <% } %>

            <form class="form-stack" action="<%= request.getContextPath() %>/change-password" method="post">
                <input type="hidden" name="action" value="request-otp">
                <div class="field-group">
                    <label for="currentPassword">Current Password</label>
                    <input id="currentPassword" name="currentPassword" type="password" placeholder="Enter current password" autocomplete="current-password" required>
                </div>

                <div class="form-grid">
                    <div class="field-group">
                        <label for="newPassword">New Password</label>
                        <input id="newPassword" name="newPassword" type="password" placeholder="Enter new password" minlength="8" autocomplete="new-password" required>
                    </div>
                    <div class="field-group">
                        <label for="confirmPassword">Confirm New Password</label>
                        <input id="confirmPassword" name="confirmPassword" type="password" placeholder="Confirm new password" minlength="8" autocomplete="new-password" required>
                    </div>
                </div>

                <div class="button-row">
                    <button
                        class="button"
                        type="button"
                        data-swal-confirm="true"
                        data-swal-title="Update password?"
                        data-swal-text="Are you sure you want to change your password? We will send an OTP to your current account email before saving the new password."
                        data-swal-confirm-text="Yes, send OTP"
                        data-swal-cancel-text="Cancel"
                        data-swal-icon="!">
                        Update Password
                    </button>
                </div>
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
    <script src="<%= request.getContextPath() %>/assets/js/lu-swal.js"></script>
</body>
</html>
