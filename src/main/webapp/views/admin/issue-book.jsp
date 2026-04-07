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
    <title>Issue Book | LU Librisync</title>
    <link rel="stylesheet" href="<%= contextPath %>/assets/css/librisync.css">
</head>
<body>
    <div class="dashboard-shell">
        <aside class="sidebar">
            <h1>LU Librisync</h1>
            <p>Issue books to students with due date, QR, and tracking support.</p>
            <nav class="nav-list">
                <a href="<%= contextPath %>/admin/dashboard">Dashboard</a>
                <a href="<%= contextPath %>/views/admin/books.jsp">Books</a>
                <a href="<%= contextPath %>/views/admin/authors.jsp">Authors</a>
                <a href="<%= contextPath %>/views/admin/categories.jsp">Categories</a>
                <a class="active" href="<%= contextPath %>/views/admin/issue-book.jsp">Issue Book</a>
                <a href="<%= contextPath %>/views/admin/return-book.jsp">Return Book</a>
                <a href="<%= contextPath %>/views/admin/students.jsp">Students</a>
                <a href="<%= contextPath %>/views/admin/analytics.jsp">Analytics</a>
                <a href="<%= contextPath %>/logout" data-swal-confirm="true" data-swal-title="Log out?" data-swal-text="You will need to sign in again to continue using LU Librisync." data-swal-confirm-text="Yes, log out" data-swal-cancel-text="Stay here" data-swal-icon="?">Logout</a>
            </nav>
        </aside>
        <main class="content-area">
            <section class="page-grid" style="margin-bottom:18px;">
                <div class="content-card">
                    <div class="eyebrow">Issue Workflow</div>
                    <h2 class="section-title">Issue a book to a student.</h2>
                    <p class="section-copy">Use student ID, ISBN, due date, and optional QR issue reference to create a new loan.</p>
                    <form class="form-stack">
                        <div class="form-grid">
                            <div class="field-group">
                                <label>Student ID</label>
                                <input type="text" placeholder="Example: 241-0001">
                            </div>
                            <div class="field-group">
                                <label>Book ISBN</label>
                                <input type="text" placeholder="Enter ISBN">
                            </div>
                        </div>
                        <div class="form-grid">
                            <div class="field-group">
                                <label>Issue Date</label>
                                <input type="datetime-local">
                            </div>
                            <div class="field-group">
                                <label>Due Date</label>
                                <input type="datetime-local">
                            </div>
                        </div>
                        <div class="field-group">
                            <label>QR Issue Reference</label>
                            <input type="text" placeholder="Optional QR issue code">
                        </div>
                        <div class="field-group">
                            <label>Remarks</label>
                            <textarea placeholder="Optional notes"></textarea>
                        </div>
                        <button class="button" type="button">Confirm Issue</button>
                    </form>
                </div>
                <div class="content-card">
                    <h3 class="section-title">Circulation Checklist</h3>
                    <ul class="muted">
                        <li>Verify student ID and account status.</li>
                        <li>Confirm available quantity before issuing.</li>
                        <li>Use due date for reminders and fine automation.</li>
                        <li>Record QR or barcode values when available.</li>
                    </ul>
                </div>
            </section>

            <section class="table-card">
                <h3 class="section-title">Recent Issue Transactions</h3>
                <div class="table-wrap">
                    <table>
                        <thead>
                            <tr>
                                <th>Student ID</th>
                                <th>Book</th>
                                <th>Issue Date</th>
                                <th>Due Date</th>
                                <th>Status</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td>241-0001</td>
                                <td>Clean Code</td>
                                <td>2026-03-20 09:00</td>
                                <td>2026-04-03 09:00</td>
                                <td><span class="pill success">Issued</span></td>
                            </tr>
                            <tr>
                                <td>231-0002</td>
                                <td>Democracy and Education</td>
                                <td>2026-03-02 14:00</td>
                                <td>2026-03-16 14:00</td>
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
