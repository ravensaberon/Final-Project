<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    if (session.getAttribute("user") == null || !"ADMIN".equals(session.getAttribute("role"))) {
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
    <title>Analytics Dashboard | LU Librisync</title>
    <link rel="stylesheet" href="<%= contextPath %>/assets/css/librisync.css">
</head>
<body>
    <div class="dashboard-shell">
        <aside class="sidebar">
            <h1>LU Librisync</h1>
            <p>Overdue analytics, reading history, usage trends, and automation visibility.</p>
            <nav class="nav-list">
                <a href="<%= contextPath %>/admin/dashboard">Dashboard</a>
                <a href="<%= contextPath %>/admin/books">Books</a>
                <a href="<%= contextPath %>/admin/authors">Authors</a>
                <a href="<%= contextPath %>/admin/categories">Categories</a>
                <a href="<%= contextPath %>/admin/issue">Issue Book</a>
                <a href="<%= contextPath %>/admin/return">Return Book</a>
                <a href="<%= contextPath %>/admin/students">Students</a>
                <a class="active" href="<%= contextPath %>/admin/analytics">Analytics</a>
                <a href="<%= contextPath %>/logout" data-swal-confirm="true" data-swal-title="Log out?" data-swal-text="You will need to sign in again to continue using LU Librisync." data-swal-confirm-text="Yes, log out" data-swal-cancel-text="Stay here" data-swal-icon="?">Logout</a>
            </nav>
        </aside>
        <main class="content-area">
            <section class="hero-card content-card" style="margin-bottom:18px;">
                <div class="eyebrow">Analytics Dashboard</div>
                <h2 class="section-title">Measure the library’s performance.</h2>
                <p class="section-copy">Track most borrowed books, overdue rates, reservation demand, student reading history, and digital usage patterns inside LU Librisync.</p>
            </section>

            <section class="stats-grid" style="margin-bottom:18px;">
                <article class="stat-card">
                    <span class="stat-label">Most Borrowed Title</span>
                    <span class="stat-value">Clean Code</span>
                    <span class="muted">Top title in recent borrowing activity.</span>
                </article>
                <article class="stat-card">
                    <span class="stat-label">Overdue Rate</span>
                    <span class="stat-value">9%</span>
                    <span class="muted">Current portion of loans marked overdue.</span>
                </article>
                <article class="stat-card">
                    <span class="stat-label">Reservation Queue</span>
                    <span class="stat-value">12</span>
                    <span class="muted">Students waiting for high-demand books.</span>
                </article>
                <article class="stat-card">
                    <span class="stat-label">E-Book Sessions</span>
                    <span class="stat-value">38</span>
                    <span class="muted">Digital library access sessions this week.</span>
                </article>
            </section>

            <section class="table-card">
                <h3 class="section-title">Student Reading History Snapshot</h3>
                <div class="table-wrap">
                    <table>
                        <thead>
                            <tr>
                                <th>Student</th>
                                <th>Student ID</th>
                                <th>Book</th>
                                <th>Issue Date</th>
                                <th>Due Date</th>
                                <th>Status</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td>Maria Santos</td>
                                <td>241-0001</td>
                                <td>Clean Code</td>
                                <td>2026-03-20</td>
                                <td>2026-04-03</td>
                                <td><span class="pill success">Issued</span></td>
                            </tr>
                            <tr>
                                <td>John Cruz</td>
                                <td>231-0002</td>
                                <td>Democracy and Education</td>
                                <td>2026-03-02</td>
                                <td>2026-03-16</td>
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
