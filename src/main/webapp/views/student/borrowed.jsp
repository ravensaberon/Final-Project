<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    if (session.getAttribute("user") == null) {
        response.sendRedirect(request.getContextPath() + "/views/auth/login.jsp");
        return;
    }
    String contextPath = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Borrowed Books | LU Librisync</title>
    <link rel="stylesheet" href="<%= contextPath %>/assets/css/librisync.css">
</head>
<body>
    <div class="dashboard-shell">
        <aside class="sidebar">
            <h1>LU Librisync</h1>
            <p>Track your issued books, due dates, and return schedule.</p>
            <nav class="nav-list">
                <a href="<%= contextPath %>/student/dashboard">Dashboard</a>
                <a href="<%= contextPath %>/student/books">Browse Books</a>
                <a class="active" href="<%= contextPath %>/student/borrowed">Borrowed Books</a>
                <a href="<%= contextPath %>/student/reservations">Reservations</a>
                <a href="<%= contextPath %>/student/profile">Profile</a>
                <a href="<%= contextPath %>/views/auth/change-password.jsp">Change Password</a>
                <a href="<%= contextPath %>/logout" data-swal-confirm="true" data-swal-title="Log out?" data-swal-text="You will need to sign in again to continue using LU Librisync." data-swal-confirm-text="Yes, log out" data-swal-cancel-text="Stay here" data-swal-icon="?">Logout</a>
            </nav>
        </aside>
        <main class="content-area">
            <section class="content-card" style="margin-bottom:18px;">
                <div class="eyebrow">Issued Books</div>
                <h2 class="section-title">Your active loans and return timelines.</h2>
                <p class="section-copy">Monitor due date-time, return status, and fines from your student account.</p>
            </section>

            <section class="table-card">
                <h3 class="section-title">Borrowed Book History</h3>
                <div class="table-wrap">
                    <table>
                        <thead>
                            <tr>
                                <th>Book</th>
                                <th>Issue Date</th>
                                <th>Due Date-Time</th>
                                <th>Return Date-Time</th>
                                <th>Status</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td>Clean Code</td>
                                <td>2026-03-20 09:00</td>
                                <td>2026-04-03 09:00</td>
                                <td>Pending</td>
                                <td><span class="pill success">Issued</span></td>
                            </tr>
                            <tr>
                                <td>The Alchemist</td>
                                <td>2026-02-22 10:00</td>
                                <td>2026-03-08 10:00</td>
                                <td>2026-03-07 16:15</td>
                                <td><span class="pill success">Returned</span></td>
                            </tr>
                            <tr>
                                <td>Democracy and Education</td>
                                <td>2026-03-02 14:00</td>
                                <td>2026-03-16 14:00</td>
                                <td>Pending</td>
                                <td><span class="pill danger">Overdue</span></td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </section>
        </main>
    </div>
    <script src="<%= contextPath %>/assets/js/lu-swal.js"></script>
</body>
</html>
