<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    if (session.getAttribute("user") == null) {
        response.sendRedirect(request.getContextPath() + "/views/auth/login.jsp");
        return;
    }
    String contextPath = request.getContextPath();
    String studentId = String.valueOf(session.getAttribute("studentId"));
    if ("null".equals(studentId)) {
        studentId = "Not assigned";
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Profile | LU Librisync</title>
    <link rel="stylesheet" href="<%= contextPath %>/assets/css/librisync.css">
</head>
<body>
    <div class="dashboard-shell">
        <aside class="sidebar">
            <h1>LU Librisync</h1>
            <p>Update your personal profile and student library information.</p>
            <nav class="nav-list">
                <a href="<%= contextPath %>/student/dashboard">Dashboard</a>
                <a href="<%= contextPath %>/student/books">Browse Books</a>
                <a href="<%= contextPath %>/student/borrowed">Borrowed Books</a>
                <a href="<%= contextPath %>/student/reservations">Reservations</a>
                <a class="active" href="<%= contextPath %>/student/profile">Profile</a>
                <a href="<%= contextPath %>/views/auth/change-password.jsp">Change Password</a>
                <a href="<%= contextPath %>/logout" data-swal-confirm="true" data-swal-title="Log out?" data-swal-text="You will need to sign in again to continue using LU Librisync." data-swal-confirm-text="Yes, log out" data-swal-cancel-text="Stay here" data-swal-icon="?">Logout</a>
            </nav>
        </aside>
        <main class="content-area">
            <section class="page-grid" style="margin-bottom:18px;">
                <div class="content-card">
                    <div class="eyebrow">Student Profile</div>
                    <h2 class="section-title">Update your personal information.</h2>
                    <p class="section-copy">Keep your account accurate for issue, return, reminders, and library communication.</p>
                    <form class="form-stack">
                        <div class="form-grid">
                            <div class="field-group">
                                <label>Full Name</label>
                                <input type="text" value="<%= session.getAttribute("user") %>">
                            </div>
                            <div class="field-group">
                                <label>Email</label>
                                <input type="email" value="<%= session.getAttribute("userEmail") == null ? "" : session.getAttribute("userEmail") %>">
                            </div>
                        </div>
                        <div class="form-grid">
                            <div class="field-group">
                                <label>Course</label>
                                <input type="text" placeholder="Enter course">
                            </div>
                            <div class="field-group">
                                <label>Year Level</label>
                                <input type="text" placeholder="Enter year level">
                            </div>
                        </div>
                        <div class="form-grid">
                            <div class="field-group">
                                <label>Phone</label>
                                <input type="text" placeholder="Enter contact number">
                            </div>
                            <div class="field-group">
                                <label>Address</label>
                                <input type="text" placeholder="Enter address">
                            </div>
                        </div>
                        <button class="button" type="button">Save Profile</button>
                    </form>
                </div>
                <div class="content-card">
                    <h3 class="section-title">Account Snapshot</h3>
                    <p class="muted"><strong>Student ID:</strong> <%= studentId %></p>
                    <p class="muted"><strong>Role:</strong> Student</p>
                    <p class="muted"><strong>Password:</strong> You can change it from the change password page.</p>
                </div>
            </section>
        </main>
    </div>
    <script src="<%= contextPath %>/assets/js/lu-swal.js"></script>
</body>
</html>
