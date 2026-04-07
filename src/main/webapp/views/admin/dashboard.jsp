<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    if (session.getAttribute("user") == null || !"ADMIN".equals(session.getAttribute("role"))) {
        response.sendRedirect(request.getContextPath() + "/views/auth/login.jsp");
        return;
    }

    String contextPath = request.getContextPath();
    int totalBooks = request.getAttribute("totalBooks") == null ? 128 : (Integer) request.getAttribute("totalBooks");
    int totalStudents = request.getAttribute("totalStudents") == null ? 64 : (Integer) request.getAttribute("totalStudents");
    int issuedBooks = request.getAttribute("issuedBooks") == null ? 27 : (Integer) request.getAttribute("issuedBooks");
    int overdueBooks = request.getAttribute("overdueBooks") == null ? 6 : (Integer) request.getAttribute("overdueBooks");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard | LU Librisync</title>
    <link rel="stylesheet" href="<%= contextPath %>/assets/css/librisync.css">
</head>
<body>
    <div class="dashboard-shell">
        <aside class="sidebar">
            <h1>LU Librisync</h1>
            <p>Admin control center for catalog, circulation, student records, and analytics.</p>
            <nav class="nav-list">
                <a class="active" href="<%= contextPath %>/admin/dashboard">Dashboard</a>
                <a href="<%= contextPath %>/views/admin/books.jsp">Books</a>
                <a href="<%= contextPath %>/views/admin/authors.jsp">Authors</a>
                <a href="<%= contextPath %>/views/admin/categories.jsp">Categories</a>
                <a href="<%= contextPath %>/views/admin/issue-book.jsp">Issue Book</a>
                <a href="<%= contextPath %>/views/admin/return-book.jsp">Return Book</a>
                <a href="<%= contextPath %>/views/admin/students.jsp">Students</a>
                <a href="<%= contextPath %>/views/admin/analytics.jsp">Analytics</a>
                <a href="<%= contextPath %>/views/auth/change-password.jsp">Change Password</a>
                <a href="<%= contextPath %>/logout" data-swal-confirm="true" data-swal-title="Log out?" data-swal-text="You will need to sign in again to continue using LU Librisync." data-swal-confirm-text="Yes, log out" data-swal-cancel-text="Stay here" data-swal-icon="?">Logout</a>
            </nav>
        </aside>

        <main class="content-area">
            <section class="hero-card content-card" style="margin-bottom:18px;">
                <div class="eyebrow">Admin Dashboard</div>
                <h2 class="section-title">Welcome back, <%= session.getAttribute("user") %>.</h2>
                <p class="section-copy">This dashboard centralizes the LU Librisync workflow for books, issue and return, student tracking, analytics, fine readiness, and digital resources.</p>
                <div class="button-row">
                    <a class="button" href="<%= contextPath %>/views/admin/issue-book.jsp">Issue New Book</a>
                    <a class="button-secondary" href="<%= contextPath %>/views/admin/students.jsp">Search Student</a>
                    <a class="button-ghost" href="<%= contextPath %>/views/admin/analytics.jsp">Open Analytics</a>
                </div>
            </section>

            <section class="stats-grid" style="margin-bottom:18px;">
                <article class="stat-card">
                    <span class="stat-label">Total Books</span>
                    <span class="stat-value"><%= totalBooks %></span>
                    <span class="muted">Print and digital titles in the collection.</span>
                </article>
                <article class="stat-card">
                    <span class="stat-label">Total Students</span>
                    <span class="stat-value"><%= totalStudents %></span>
                    <span class="muted">Registered student members with generated IDs.</span>
                </article>
                <article class="stat-card">
                    <span class="stat-label">Issued Books</span>
                    <span class="stat-value"><%= issuedBooks %></span>
                    <span class="muted">Active loan transactions in circulation.</span>
                </article>
                <article class="stat-card">
                    <span class="stat-label">Overdue Books</span>
                    <span class="stat-value"><%= overdueBooks %></span>
                    <span class="muted">Loans requiring follow-up or fine updates.</span>
                </article>
            </section>

            <section class="page-grid" style="margin-bottom:18px;">
                <div class="content-card">
                    <h3 class="section-title">Admin Modules</h3>
                    <div class="card-grid">
                        <div class="content-card">
                            <h4>Catalog Management</h4>
                            <p class="muted">Manage books, categories, authors, ISBN, barcode, and digital availability.</p>
                        </div>
                        <div class="content-card">
                            <h4>Circulation</h4>
                            <p class="muted">Issue and return books, calculate fines, and update due schedules.</p>
                        </div>
                        <div class="content-card">
                            <h4>Student Search</h4>
                            <p class="muted">Locate students by student ID and review borrowing details.</p>
                        </div>
                        <div class="content-card">
                            <h4>Automation</h4>
                            <p class="muted">Support reservation queues, reminder visibility, and overdue tracking.</p>
                        </div>
                    </div>
                </div>

                <div class="content-card">
                    <h3 class="section-title">Today’s Priorities</h3>
                    <ul class="muted">
                        <li>Review overdue loans and pending fine follow-up.</li>
                        <li>Check student search and account activity.</li>
                        <li>Confirm high-demand reservations and available copies.</li>
                        <li>Monitor digital library uploads and access links.</li>
                    </ul>
                </div>
            </section>

            <section class="table-card">
                <h3 class="section-title">Recent Activity</h3>
                <div class="table-wrap">
                    <table>
                        <thead>
                            <tr>
                                <th>Student</th>
                                <th>Student ID</th>
                                <th>Book</th>
                                <th>Status</th>
                                <th>Date</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td>Maria Santos</td>
                                <td>241-0001</td>
                                <td>Clean Code</td>
                                <td><span class="pill success">Issued</span></td>
                                <td>2026-03-20</td>
                            </tr>
                            <tr>
                                <td>John Cruz</td>
                                <td>231-0002</td>
                                <td>Democracy and Education</td>
                                <td><span class="pill danger">Overdue</span></td>
                                <td>2026-03-15</td>
                            </tr>
                            <tr>
                                <td>Maria Santos</td>
                                <td>241-0001</td>
                                <td>The Alchemist</td>
                                <td><span class="pill warning">Reserved</span></td>
                                <td>2026-03-18</td>
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
