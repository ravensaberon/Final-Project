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
    <title>Student Search | LU Librisync</title>
    <link rel="stylesheet" href="<%= contextPath %>/assets/css/librisync.css">
</head>
<body>
    <div class="dashboard-shell">
        <aside class="sidebar">
            <h1>LU Librisync</h1>
            <p>Search students by generated student ID and review their library details.</p>
            <nav class="nav-list">
                <a href="<%= contextPath %>/admin/dashboard">Dashboard</a>
                <a href="<%= contextPath %>/views/admin/books.jsp">Books</a>
                <a href="<%= contextPath %>/views/admin/authors.jsp">Authors</a>
                <a href="<%= contextPath %>/views/admin/categories.jsp">Categories</a>
                <a href="<%= contextPath %>/views/admin/issue-book.jsp">Issue Book</a>
                <a href="<%= contextPath %>/views/admin/return-book.jsp">Return Book</a>
                <a class="active" href="<%= contextPath %>/views/admin/students.jsp">Students</a>
                <a href="<%= contextPath %>/views/admin/analytics.jsp">Analytics</a>
                <a href="<%= contextPath %>/logout" data-swal-confirm="true" data-swal-title="Log out?" data-swal-text="You will need to sign in again to continue using LU Librisync." data-swal-confirm-text="Yes, log out" data-swal-cancel-text="Stay here" data-swal-icon="?">Logout</a>
            </nav>
        </aside>
        <main class="content-area">
            <section class="page-grid" style="margin-bottom:18px;">
                <div class="content-card">
                    <div class="eyebrow">Student Search</div>
                    <h2 class="section-title">Find a student using student ID.</h2>
                    <p class="section-copy">Support issue and return transactions, profile reviews, and reading history lookups.</p>
                    <form class="form-stack">
                        <div class="field-group">
                            <label>Student ID</label>
                            <input type="text" placeholder="Enter student ID">
                        </div>
                        <div class="button-row">
                            <button class="button" type="button">Search Student</button>
                            <button class="button-secondary" type="button">View Borrowing History</button>
                        </div>
                    </form>
                </div>

                <div class="content-card">
                    <h3 class="section-title">Student Profile Snapshot</h3>
                    <p class="muted"><strong>Name:</strong> Maria Santos</p>
                    <p class="muted"><strong>Student ID:</strong> 241-0001</p>
                    <p class="muted"><strong>Course:</strong> BS Information Technology</p>
                    <p class="muted"><strong>Year Level:</strong> 3rd Year</p>
                    <p class="muted"><strong>Status:</strong> Active member with issued and reserved titles.</p>
                </div>
            </section>

            <section class="table-card">
                <h3 class="section-title">Student Directory Snapshot</h3>
                <div class="table-wrap">
                    <table>
                        <thead>
                            <tr>
                                <th>Student ID</th>
                                <th>Name</th>
                                <th>Course</th>
                                <th>Issued Books</th>
                                <th>Reservations</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td>241-0001</td>
                                <td>Maria Santos</td>
                                <td>BS Information Technology</td>
                                <td>1</td>
                                <td>1</td>
                            </tr>
                            <tr>
                                <td>231-0002</td>
                                <td>John Cruz</td>
                                <td>BS Education</td>
                                <td>1</td>
                                <td>0</td>
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
