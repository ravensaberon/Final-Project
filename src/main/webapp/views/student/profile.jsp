<%@ page import="com.lulibrisync.dao.UserDAO,com.lulibrisync.utils.DashboardViewHelper,java.time.LocalDate,java.time.format.DateTimeFormatter,java.util.Locale" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    if (session.getAttribute("user") == null) {
        response.sendRedirect(request.getContextPath() + "/views/auth/login.jsp");
        return;
    }

    String contextPath = request.getContextPath();
    UserDAO.StudentProfile profile = (UserDAO.StudentProfile) request.getAttribute("studentProfile");
    if (profile == null) {
        response.sendRedirect(contextPath + "/student/profile");
        return;
    }

    String success = request.getParameter("success");
    String error = request.getParameter("error");
    boolean otpPending = Boolean.TRUE.equals(request.getAttribute("otpPending"));
    String maskedOtpEmail = String.valueOf(request.getAttribute("maskedOtpEmail"));
    String draftName = String.valueOf(request.getAttribute("profileDraftName"));
    String draftEmail = String.valueOf(request.getAttribute("profileDraftEmail"));
    String draftCourse = String.valueOf(request.getAttribute("profileDraftCourse"));
    String draftYearLevel = String.valueOf(request.getAttribute("profileDraftYearLevel"));
    String draftPhone = String.valueOf(request.getAttribute("profileDraftPhone"));
    String draftAddress = String.valueOf(request.getAttribute("profileDraftAddress"));

    if ("null".equalsIgnoreCase(maskedOtpEmail)) maskedOtpEmail = "";
    if ("null".equalsIgnoreCase(draftName)) draftName = "";
    if ("null".equalsIgnoreCase(draftEmail)) draftEmail = "";
    if ("null".equalsIgnoreCase(draftCourse)) draftCourse = "";
    if ("null".equalsIgnoreCase(draftYearLevel)) draftYearLevel = "";
    if ("null".equalsIgnoreCase(draftPhone)) draftPhone = "";
    if ("null".equalsIgnoreCase(draftAddress)) draftAddress = "";

    String initials = profile.getUser().getName();
    if (initials == null || initials.isBlank()) {
        initials = "LU";
    } else {
        String[] parts = initials.trim().split("\\s+");
        StringBuilder builder = new StringBuilder();
        for (int i = 0; i < parts.length && i < 2; i++) {
            builder.append(Character.toUpperCase(parts[i].charAt(0)));
        }
        initials = builder.toString();
    }

    String courseDisplay = profile.getCourse() == null || profile.getCourse().isBlank() ? "Not set" : profile.getCourse();
    String yearLevelDisplay = profile.getYearLevel() == null || profile.getYearLevel().isBlank() ? "Not set" : profile.getYearLevel();
    String phoneDisplay = profile.getPhone() == null || profile.getPhone().isBlank() ? "Not set" : profile.getPhone();
    String addressDisplay = profile.getAddress() == null || profile.getAddress().isBlank() ? "Not set" : profile.getAddress();
    String emailDisplay = profile.getUser().getEmail() == null || profile.getUser().getEmail().isBlank() ? "Not set" : profile.getUser().getEmail();
    String statusDisplay = profile.getUser().getStatus() == null || profile.getUser().getStatus().isBlank() ? "ACTIVE" : profile.getUser().getStatus();

    LocalDate today = LocalDate.now();
    DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("d 'of' MMMM yyyy", Locale.ENGLISH);
    DateTimeFormatter dayFormatter = DateTimeFormatter.ofPattern("EEEE", Locale.ENGLISH);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Profile | LU Librisync</title>
    <link rel="stylesheet" href="<%= contextPath %>/assets/css/librisync.css">
</head>
<body class="dashboard-reference">
    <div class="dashboard-shell">
        <aside class="sidebar">
            <div class="sidebar-brand">
                <div class="sidebar-brand-badge">LU</div>
                <div class="sidebar-brand-copy">
                    <strong>Student Portal</strong>
                    <span>My profile</span>
                </div>
            </div>
            <p>View your details in one place, then update them securely with an email OTP sent to your current student account.</p>
            <div class="sidebar-section-label">Navigation</div>
            <nav class="nav-list">
                <a href="<%= contextPath %>/student/dashboard">Dashboard</a>
                <a href="<%= contextPath %>/student/books">Browse Books</a>
                <a href="<%= contextPath %>/student/borrowed">Borrowed Books</a>
                <a href="<%= contextPath %>/student/reservations">Reservations</a>
                <a class="active" href="<%= contextPath %>/student/profile">Profile</a>
                <a href="<%= contextPath %>/views/auth/change-password.jsp">Change Password</a>
                <a href="<%= contextPath %>/logout" data-swal-confirm="true" data-swal-title="Log out?" data-swal-text="You will need to sign in again to continue using LU Librisync." data-swal-confirm-text="Yes, log out" data-swal-cancel-text="Stay here" data-swal-icon="!">Logout</a>
            </nav>

            <div class="sidebar-mini-card">
                <strong>Profile security</strong>
                <span>Every profile change now asks for confirmation first, then sends an OTP to your account email before saving.</span>
            </div>
        </aside>

        <main class="content-area">
            <section class="dashboard-topbar">
                <div>
                    <h1 class="workspace-title">My Profile</h1>
                    <p class="workspace-copy">Student information, contact details, and library activity in a cleaner reference-style layout with OTP-protected profile updates.</p>
                </div>
                <div class="dashboard-toolbar">
                    <span class="status-chip">OTP Protected</span>
                    <span class="search-prompt">Account email: <%= DashboardViewHelper.escapeHtml(emailDisplay) %></span>
                </div>
            </section>

            <% if ("updated".equalsIgnoreCase(success)) { %>
                <div class="alert success">Your profile has been updated successfully after OTP verification.</div>
            <% } else if ("otp_sent".equalsIgnoreCase(success)) { %>
                <div class="alert success">An OTP has been sent to <strong><%= DashboardViewHelper.escapeHtml(maskedOtpEmail) %></strong>. Enter it below to finish updating your profile.</div>
            <% } else if ("missing".equalsIgnoreCase(error)) { %>
                <div class="alert warning">Name and email are required before we can send the OTP.</div>
            <% } else if ("email_exists".equalsIgnoreCase(error)) { %>
                <div class="alert error">That email is already being used by another account.</div>
            <% } else if ("otp_missing".equalsIgnoreCase(error)) { %>
                <div class="alert warning">Enter the OTP from your email first before we save the profile changes.</div>
            <% } else if ("otp_invalid".equalsIgnoreCase(error)) { %>
                <div class="alert error">The OTP you entered is incorrect. Please try again.</div>
            <% } else if ("otp_expired".equalsIgnoreCase(error)) { %>
                <div class="alert warning">That OTP has expired. Request a new one from the update form.</div>
            <% } else if ("mail_not_configured".equalsIgnoreCase(error)) { %>
                <div class="alert error">OTP email sending is not configured yet. Add your Gmail/SMTP credentials first, then try again.</div>
            <% } else if ("mail_send_failed".equalsIgnoreCase(error)) { %>
                <div class="alert error">We tried to send the OTP to your account email, but the email delivery failed. Double-check the Gmail/SMTP settings.</div>
            <% } else if ("server".equalsIgnoreCase(error)) { %>
                <div class="alert error">The system could not process your profile request right now. Please try again.</div>
            <% } %>

            <section class="student-profile-layout">
                <div class="student-profile-main">
                    <section class="profile-reference-card profile-reference-hero">
                        <div class="profile-reference-banner">
                            <div class="profile-reference-badge">ID</div>
                            <div>
                                <h2>My Profile</h2>
                                <p>Student information</p>
                            </div>
                        </div>

                        <div class="profile-reference-shell">
                            <div class="profile-reference-summary">
                                <div class="profile-reference-avatar"><%= DashboardViewHelper.escapeHtml(initials) %></div>
                                <strong><%= DashboardViewHelper.escapeHtml(profile.getUser().getName()) %></strong>
                                <span><%= DashboardViewHelper.escapeHtml(profile.getUser().getStudentId()) %></span>
                                <p><%= DashboardViewHelper.escapeHtml(courseDisplay) %> • <%= DashboardViewHelper.escapeHtml(yearLevelDisplay) %></p>
                            </div>

                            <div class="profile-reference-sections">
                                <section class="profile-reference-section">
                                    <div class="profile-section-title">
                                        <span class="profile-section-icon">P</span>
                                        <h3>Personal Details</h3>
                                    </div>
                                    <div class="profile-reference-detail-grid">
                                        <span>Name</span>
                                        <strong><%= DashboardViewHelper.escapeHtml(profile.getUser().getName()) %></strong>
                                        <span>Student ID</span>
                                        <strong><%= DashboardViewHelper.escapeHtml(profile.getUser().getStudentId()) %></strong>
                                        <span>Role</span>
                                        <strong><%= DashboardViewHelper.escapeHtml(profile.getUser().getRole()) %></strong>
                                        <span>Status</span>
                                        <strong><%= DashboardViewHelper.escapeHtml(statusDisplay) %></strong>
                                    </div>
                                </section>

                                <section class="profile-reference-section">
                                    <div class="profile-section-title">
                                        <span class="profile-section-icon">C</span>
                                        <h3>Contact Details</h3>
                                    </div>
                                    <div class="profile-reference-detail-grid">
                                        <span>Email Address</span>
                                        <strong><%= DashboardViewHelper.escapeHtml(emailDisplay) %></strong>
                                        <span>Contact Number</span>
                                        <strong><%= DashboardViewHelper.escapeHtml(phoneDisplay) %></strong>
                                        <span>Address</span>
                                        <strong><%= DashboardViewHelper.escapeHtml(addressDisplay) %></strong>
                                        <span>OTP Destination</span>
                                        <strong><%= DashboardViewHelper.escapeHtml(emailDisplay) %></strong>
                                    </div>
                                </section>

                                <section class="profile-reference-section">
                                    <div class="profile-section-title">
                                        <span class="profile-section-icon">E</span>
                                        <h3>Education</h3>
                                    </div>
                                    <div class="profile-reference-detail-grid">
                                        <span>Course</span>
                                        <strong><%= DashboardViewHelper.escapeHtml(courseDisplay) %></strong>
                                        <span>Year / Block</span>
                                        <strong><%= DashboardViewHelper.escapeHtml(yearLevelDisplay) %></strong>
                                        <span>Student Record ID</span>
                                        <strong><%= profile.getStudentDbId() %></strong>
                                        <span>Profile Update Mode</span>
                                        <strong>Email OTP Verification</strong>
                                    </div>
                                </section>

                                <section class="profile-reference-section">
                                    <div class="profile-section-title">
                                        <span class="profile-section-icon">L</span>
                                        <h3>Library Snapshot</h3>
                                    </div>
                                    <div class="profile-reference-detail-grid">
                                        <span>Active Loans</span>
                                        <strong><%= profile.getActiveLoans() %></strong>
                                        <span>Returned Books</span>
                                        <strong><%= profile.getReturnedLoans() %></strong>
                                        <span>Reservations</span>
                                        <strong><%= profile.getReservationCount() %></strong>
                                        <span>Overdue Items</span>
                                        <strong><%= profile.getOverdueLoans() %></strong>
                                    </div>
                                </section>
                            </div>
                        </div>
                    </section>

                    <% if (otpPending) { %>
                        <section class="profile-reference-card profile-otp-card">
                            <div class="panel-head">
                                <div>
                                    <h3>Verify OTP Before Saving</h3>
                                    <p>We already sent a one-time password to <strong><%= DashboardViewHelper.escapeHtml(maskedOtpEmail) %></strong>. Enter it below to confirm the profile update.</p>
                                </div>
                                <span class="panel-badge">Pending verification</span>
                            </div>
                            <form class="form-stack" action="<%= contextPath %>/student/profile" method="post">
                                <input type="hidden" name="action" value="verify-otp">
                                <div class="form-grid">
                                    <div class="field-group">
                                        <label for="otp">OTP Code</label>
                                        <input id="otp" name="otp" type="text" inputmode="numeric" maxlength="6" placeholder="Enter 6-digit OTP" required>
                                    </div>
                                    <div class="field-group">
                                        <label for="otpEmail">Sent To</label>
                                        <input id="otpEmail" type="text" value="<%= DashboardViewHelper.escapeHtml(maskedOtpEmail) %>" readonly>
                                    </div>
                                </div>
                                <div class="button-row">
                                    <button class="button" type="submit">Verify OTP And Save</button>
                                </div>
                            </form>
                        </section>
                    <% } %>

                    <section class="profile-reference-card profile-editor-card">
                        <div class="panel-head">
                            <div>
                                <h3>Update Profile</h3>
                                <p>Clicking the button below will first ask for confirmation, then send an OTP to your current account Gmail/email before any profile change is saved.</p>
                            </div>
                            <span class="panel-badge">Secure update flow</span>
                        </div>

                        <form class="form-stack" action="<%= contextPath %>/student/profile" method="post" id="profileUpdateForm">
                            <input type="hidden" name="action" value="request-otp">
                            <div class="form-grid">
                                <div class="field-group">
                                    <label for="name">Full Name</label>
                                    <input id="name" name="name" type="text" value="<%= DashboardViewHelper.escapeHtml(draftName) %>" required>
                                </div>
                                <div class="field-group">
                                    <label for="email">Email</label>
                                    <input id="email" name="email" type="email" value="<%= DashboardViewHelper.escapeHtml(draftEmail) %>" required>
                                    <p class="field-help">OTP will be sent to the current account email on file before this new email value is saved.</p>
                                </div>
                            </div>
                            <div class="form-grid">
                                <div class="field-group">
                                    <label for="course">Course</label>
                                    <input id="course" name="course" type="text" value="<%= DashboardViewHelper.escapeHtml(draftCourse) %>">
                                </div>
                                <div class="field-group">
                                    <label for="yearLevel">Year Level / Block</label>
                                    <input id="yearLevel" name="yearLevel" type="text" value="<%= DashboardViewHelper.escapeHtml(draftYearLevel) %>">
                                </div>
                            </div>
                            <div class="form-grid">
                                <div class="field-group">
                                    <label for="phone">Contact Number</label>
                                    <input id="phone" name="phone" type="text" value="<%= DashboardViewHelper.escapeHtml(draftPhone) %>">
                                </div>
                                <div class="field-group">
                                    <label for="address">Address</label>
                                    <textarea id="address" name="address"><%= DashboardViewHelper.escapeHtml(draftAddress) %></textarea>
                                </div>
                            </div>
                            <div class="button-row">
                                <button
                                    class="button"
                                    type="button"
                                    data-swal-confirm="true"
                                    data-swal-title="Update profile?"
                                    data-swal-text="Are you sure you want to update your profile? We will send an OTP to your current account email before saving the changes."
                                    data-swal-confirm-text="Yes, send OTP"
                                    data-swal-cancel-text="Cancel"
                                    data-swal-icon="!">
                                    Update Profile
                                </button>
                                <a class="button-secondary" href="<%= contextPath %>/views/auth/change-password.jsp">Change Password</a>
                            </div>
                        </form>
                    </section>
                </div>

                <aside class="student-profile-rail">
                    <section class="profile-side-card profile-date-card">
                        <span class="profile-side-label"><%= today.format(dateFormatter) %></span>
                        <strong><%= today.format(dayFormatter) %></strong>
                        <p>Your profile updates are verified through your email before they are applied.</p>
                    </section>

                    <section class="profile-side-card">
                        <div class="profile-side-head">
                            <h3>Security Check</h3>
                            <span class="mini-chip"><%= otpPending ? "OTP pending" : "Ready" %></span>
                        </div>
                        <div class="profile-side-stack">
                            <div class="profile-side-item">
                                <span>Current account email</span>
                                <strong><%= DashboardViewHelper.escapeHtml(emailDisplay) %></strong>
                            </div>
                            <div class="profile-side-item">
                                <span>OTP destination</span>
                                <strong><%= DashboardViewHelper.escapeHtml(otpPending ? maskedOtpEmail : emailDisplay) %></strong>
                            </div>
                            <div class="profile-side-item">
                                <span>Before saving updates</span>
                                <strong>Confirmation + OTP required</strong>
                            </div>
                        </div>
                    </section>

                    <section class="profile-side-card">
                        <div class="profile-side-head">
                            <h3>Library Quick Stats</h3>
                            <span class="mini-chip">Live</span>
                        </div>
                        <div class="profile-rail-metrics">
                            <div class="profile-rail-metric">
                                <span>Active Loans</span>
                                <strong><%= profile.getActiveLoans() %></strong>
                            </div>
                            <div class="profile-rail-metric">
                                <span>Reservations</span>
                                <strong><%= profile.getReservationCount() %></strong>
                            </div>
                            <div class="profile-rail-metric">
                                <span>Returned Books</span>
                                <strong><%= profile.getReturnedLoans() %></strong>
                            </div>
                            <div class="profile-rail-metric danger">
                                <span>Overdue</span>
                                <strong><%= profile.getOverdueLoans() %></strong>
                            </div>
                        </div>
                    </section>
                </aside>
            </section>
        </main>
    </div>
    <script src="<%= contextPath %>/assets/js/lu-swal.js"></script>
</body>
</html>
