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
    <title>Reservations | LU Librisync</title>
    <link rel="stylesheet" href="<%= contextPath %>/assets/css/librisync.css">
</head>
<body>
    <div class="dashboard-shell">
        <aside class="sidebar">
            <h1>LU Librisync</h1>
            <p>Track your reservation queue and pending book requests.</p>
            <nav class="nav-list">
                <a href="<%= contextPath %>/views/student/dashboard.jsp">Dashboard</a>
                <a href="<%= contextPath %>/views/student/books.jsp">Browse Books</a>
                <a href="<%= contextPath %>/views/student/borrowed.jsp">Borrowed Books</a>
                <a class="active" href="<%= contextPath %>/views/student/reservations.jsp">Reservations</a>
                <a href="<%= contextPath %>/views/student/profile.jsp">Profile</a>
                <a href="<%= contextPath %>/logout" data-swal-confirm="true" data-swal-title="Log out?" data-swal-text="You will need to sign in again to continue using LU Librisync." data-swal-confirm-text="Yes, log out" data-swal-cancel-text="Stay here" data-swal-icon="?">Logout</a>
            </nav>
        </aside>
        <main class="content-area">
            <section class="content-card" style="margin-bottom:18px;">
                <div class="eyebrow">Reservation Queue</div>
                <h2 class="section-title">Your reservation status.</h2>
                <p class="section-copy">Monitor queue position, readiness, and reservation expiry for high-demand books.</p>
            </section>

            <section class="table-card">
                <h3 class="section-title">Reservation History</h3>
                <div class="table-wrap">
                    <table>
                        <thead>
                            <tr>
                                <th>Book</th>
                                <th>Queue Position</th>
                                <th>Status</th>
                                <th>Reserved At</th>
                                <th>Expires At</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td>The Alchemist</td>
                                <td>1</td>
                                <td><span class="pill warning">Pending</span></td>
                                <td>2026-03-21 11:20</td>
                                <td>2026-03-24 11:20</td>
                            </tr>
                            <tr>
                                <td>Clean Code</td>
                                <td>Ready</td>
                                <td><span class="pill success">Ready to Claim</span></td>
                                <td>2026-03-16 09:10</td>
                                <td>2026-03-23 09:10</td>
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
