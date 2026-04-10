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
    <title>Return Book | LU Librisync</title>
    <link rel="stylesheet" href="<%= contextPath %>/assets/css/librisync.css">
</head>
<body>
    <div class="dashboard-shell">
        <aside class="sidebar">
            <h1>LU Librisync</h1>
            <p>Update returned books, loan status, and overdue fine details.</p>
            <nav class="nav-list">
                <a href="<%= contextPath %>/admin/dashboard">Dashboard</a>
                <a href="<%= contextPath %>/admin/books">Books</a>
                <a href="<%= contextPath %>/admin/authors">Authors</a>
                <a href="<%= contextPath %>/admin/categories">Categories</a>
                <a href="<%= contextPath %>/admin/issue">Issue Book</a>
                <a class="active" href="<%= contextPath %>/admin/return">Return Book</a>
                <a href="<%= contextPath %>/admin/students">Students</a>
                <a href="<%= contextPath %>/admin/analytics">Analytics</a>
                <a href="<%= contextPath %>/logout" data-swal-confirm="true" data-swal-title="Log out?" data-swal-text="You will need to sign in again to continue using LU Librisync." data-swal-confirm-text="Yes, log out" data-swal-cancel-text="Stay here" data-swal-icon="?">Logout</a>
            </nav>
        </aside>
        <main class="content-area">
            <section class="page-grid" style="margin-bottom:18px;">
                <div class="content-card">
                    <div class="eyebrow">Return Workflow</div>
                    <h2 class="section-title">Process returned books.</h2>
                    <p class="section-copy">Search by student ID or issue reference, then update return date, fine amount, and remarks.</p>
                    <form class="form-stack">
                        <div class="form-grid">
                            <div class="field-group">
                                <label>Student ID</label>
                                <input type="text" placeholder="Enter student ID">
                            </div>
                            <div class="field-group">
                                <label>Issue Reference</label>
                                <input type="text" placeholder="Example: QR-ISSUE-0002">
                            </div>
                        </div>
                        <div class="form-grid">
                            <div class="field-group">
                                <label>Return Date</label>
                                <input type="datetime-local">
                            </div>
                            <div class="field-group">
                                <label>Fine Amount</label>
                                <input type="number" step="0.01" placeholder="0.00">
                            </div>
                        </div>
                        <div class="field-group">
                            <label>Remarks</label>
                            <textarea placeholder="Condition notes or return remarks"></textarea>
                        </div>
                        <button class="button" type="button">Mark as Returned</button>
                    </form>
                </div>
                <div class="content-card">
                    <h3 class="section-title">Return Notes</h3>
                    <ul class="muted">
                        <li>Overdue records can trigger fine updates.</li>
                        <li>Returned books restore available quantity.</li>
                        <li>Reservation queues can be reviewed after successful return.</li>
                    </ul>
                </div>
            </section>

            <section class="table-card">
                <h3 class="section-title">Recent Return Records</h3>
                <div class="table-wrap">
                    <table>
                        <thead>
                            <tr>
                                <th>Student ID</th>
                                <th>Book</th>
                                <th>Due Date</th>
                                <th>Return Date</th>
                                <th>Fine</th>
                                <th>Status</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td>231-0002</td>
                                <td>Democracy and Education</td>
                                <td>2026-03-16 14:00</td>
                                <td>Pending</td>
                                <td>60.00</td>
                                <td><span class="pill danger">Overdue</span></td>
                            </tr>
                            <tr>
                                <td>241-0001</td>
                                <td>The Alchemist</td>
                                <td>2026-03-10 10:00</td>
                                <td>2026-03-09 15:30</td>
                                <td>0.00</td>
                                <td><span class="pill success">Returned</span></td>
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
