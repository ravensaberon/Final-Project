<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    String error = request.getParameter("error");
    String success = request.getParameter("success");
    String studentId = request.getParameter("studentId");
    String emailValue = request.getParameter("email");
    if (emailValue == null) {
        emailValue = "";
    }

    String safeEmailValue = emailValue
            .replace("&", "&amp;")
            .replace("<", "&lt;")
            .replace(">", "&gt;")
            .replace("\"", "&quot;")
            .replace("'", "&#39;");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login | LU Librisync</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/librisync.css">
    <style>
        :root {
            --bg: #eef6f0;
            --surface: rgba(255, 255, 255, 0.96);
            --surface-strong: #ffffff;
            --text: #1f2f24;
            --muted: #5f7667;
            --line: rgba(32, 112, 58, 0.16);
            --accent: #0f7f34;
            --accent-dark: #0a6428;
            --accent-soft: rgba(15, 127, 52, 0.12);
            --success: #2f6b43;
            --success-soft: #e2f1e7;
            --warning: #8d5c09;
            --warning-soft: #f8e7c5;
            --danger: #b6453d;
            --danger-soft: #f9e1dd;
            --shadow: 0 24px 48px rgba(18, 95, 44, 0.12);
        }

        body {
            background:
                radial-gradient(circle at top left, rgba(32, 182, 77, 0.18), transparent 30%),
                radial-gradient(circle at bottom right, rgba(11, 123, 47, 0.14), transparent 28%),
                linear-gradient(180deg, #f8fcf8 0%, #e8f2ea 100%);
        }

        .hero-panel {
            background:
                linear-gradient(180deg, rgba(11, 123, 47, 0.96), rgba(18, 145, 58, 0.92)),
                #0e7b32;
            color: #f4fff7;
        }

        .hero-panel .brand-pill {
            background: rgba(255, 255, 255, 0.16);
        }

        .hero-panel p,
        .hero-panel li {
            color: rgba(241, 255, 245, 0.88);
        }

        .info-card {
            background: rgba(255, 255, 255, 0.12);
            border-color: rgba(225, 255, 234, 0.26);
        }

        .form-panel {
            background: linear-gradient(180deg, rgba(255, 255, 255, 0.98), rgba(246, 253, 247, 0.95));
        }

        .password-field {
            position: relative;
        }

        .password-field input {
            padding-right: 56px;
        }

        .password-toggle {
            position: absolute;
            right: 12px;
            top: 50%;
            transform: translateY(-50%);
            width: 36px;
            height: 36px;
            border: 0;
            border-radius: 12px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            background: rgba(15, 127, 52, 0.1);
            color: var(--accent-dark);
            cursor: pointer;
            transition: background 0.2s ease, transform 0.2s ease;
        }

        .password-toggle:hover {
            background: rgba(15, 127, 52, 0.18);
            transform: translateY(-50%) scale(1.03);
        }

        .password-toggle:focus-visible {
            outline: 2px solid rgba(15, 127, 52, 0.28);
            outline-offset: 2px;
        }

        .password-toggle svg {
            width: 18px;
            height: 18px;
            stroke: currentColor;
            fill: none;
            stroke-width: 2;
            stroke-linecap: round;
            stroke-linejoin: round;
        }

        .sr-only {
            position: absolute;
            width: 1px;
            height: 1px;
            padding: 0;
            margin: -1px;
            overflow: hidden;
            clip: rect(0, 0, 0, 0);
            border: 0;
        }
    </style>
</head>
<body>
    <div class="page-shell hero-split">
        <section class="hero-panel">
            <div class="brand-pill">LU</div>
            <h1>Welcome to LU Librisync.</h1>
            <p>Sign in to continue to your library dashboard, book tracking, reservations, and digital resources.</p>

            <ul>
                <li>Browse and search books faster</li>
                <li>Manage borrowed books and reservations</li>
                <li>Use digital library tools anytime</li>
            </ul>

            <div class="info-card">
                <strong>System Name</strong>
                <p>LU Librisync is your smart campus library management platform for physical and digital collections.</p>
            </div>
        </section>

        <section class="form-panel">
            <h2>Sign In</h2>
            <p class="subtitle">Use your account to continue.</p>

            <% if ("registered".equals(success)) { %>
                <div class="alert success">
                    Registration successful.
                    <% if (studentId != null && !studentId.isBlank()) { %>
                        Your student ID is <strong><%= studentId %></strong>.
                    <% } %>
                    You can log in now.
                </div>
            <% } else if ("password_reset".equals(success)) { %>
                <div class="alert success">Your password has been reset successfully. Sign in with your new password.</div>
            <% } %>

            <% if ("invalid".equals(error)) { %>
                <div class="alert error">Invalid email or password. Please review your credentials and try again.</div>
            <% } else if ("session_active".equals(error)) { %>
                <div class="alert warning">Another account is currently logged in. Please log out the active account first.</div>
            <% } else if ("server".equals(error)) { %>
                <div class="alert error">The system could not complete your login request right now. Please try again.</div>
            <% } %>

            <form class="form-stack" action="<%= request.getContextPath() %>/login" method="post">
                <div class="field-group">
                    <label for="email">Email Address</label>
                    <input id="email" name="email" type="email" value="<%= safeEmailValue %>" placeholder="Enter your email" autocomplete="email" required>
                </div>

                <div class="field-group">
                    <label for="password">Password</label>
                    <div class="password-field">
                        <input id="password" name="password" type="password" placeholder="Enter your password" autocomplete="current-password" required>
                        <button class="password-toggle" id="passwordToggle" type="button" aria-label="Show password" aria-pressed="false">
                            <svg id="eyeOpenIcon" viewBox="0 0 24 24" aria-hidden="true">
                                <path d="M2 12s3.5-6 10-6 10 6 10 6-3.5 6-10 6-10-6-10-6z"></path>
                                <circle cx="12" cy="12" r="3"></circle>
                            </svg>
                            <svg id="eyeClosedIcon" viewBox="0 0 24 24" aria-hidden="true" style="display:none;">
                                <path d="M3 3l18 18"></path>
                                <path d="M10.6 10.7A3 3 0 0013.4 13.5"></path>
                                <path d="M9.9 5.1A10.8 10.8 0 0112 5c6.5 0 10 7 10 7a18.6 18.6 0 01-4 4.9"></path>
                                <path d="M6.6 6.7C4.2 8.3 2.8 10.7 2 12c0 0 3.5 7 10 7 1.8 0 3.3-.4 4.6-1"></path>
                            </svg>
                            <span class="sr-only">Toggle password visibility</span>
                        </button>
                    </div>
                </div>

                <button class="button" type="submit">Login</button>
            </form>

            <div class="button-row" style="margin-top:18px;">
                <a class="button-secondary" href="<%= request.getContextPath() %>/views/auth/register.jsp">Create Account</a>
                <a class="button-ghost" href="<%= request.getContextPath() %>/views/auth/forgot-password.jsp">Forgot Password</a>
            </div>

            <p class="inline-link" style="margin-top:18px;">Need to change your password after login? Use the <a href="<%= request.getContextPath() %>/views/auth/change-password.jsp">change password</a> page.</p>
        </section>
    </div>

    <script>
        (function () {
            var toggle = document.getElementById("passwordToggle");
            var password = document.getElementById("password");
            var eyeOpen = document.getElementById("eyeOpenIcon");
            var eyeClosed = document.getElementById("eyeClosedIcon");

            if (!toggle || !password || !eyeOpen || !eyeClosed) {
                return;
            }

            toggle.addEventListener("click", function () {
                var showPassword = password.type === "password";
                password.type = showPassword ? "text" : "password";
                toggle.setAttribute("aria-label", showPassword ? "Hide password" : "Show password");
                toggle.setAttribute("aria-pressed", showPassword ? "true" : "false");
                eyeOpen.style.display = showPassword ? "none" : "block";
                eyeClosed.style.display = showPassword ? "block" : "none";
            });
        })();
    </script>
</body>
</html>
