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
    <title>Author Management | LU Librisync</title>
    <link rel="stylesheet" href="<%= contextPath %>/assets/css/librisync.css">
</head>
<body>
    <div class="dashboard-shell">
        <aside class="sidebar">
            <h1>LU Librisync</h1>
            <p>Maintain author records for cleaner catalog metadata and search.</p>
            <nav class="nav-list">
                <a href="<%= contextPath %>/admin/dashboard">Dashboard</a>
                <a href="<%= contextPath %>/views/admin/books.jsp">Books</a>
                <a class="active" href="<%= contextPath %>/views/admin/authors.jsp">Authors</a>
                <a href="<%= contextPath %>/views/admin/categories.jsp">Categories</a>
                <a href="<%= contextPath %>/views/admin/issue-book.jsp">Issue Book</a>
                <a href="<%= contextPath %>/views/admin/return-book.jsp">Return Book</a>
                <a href="<%= contextPath %>/views/admin/students.jsp">Students</a>
                <a href="<%= contextPath %>/views/admin/analytics.jsp">Analytics</a>
                <a href="<%= contextPath %>/logout" data-swal-confirm="true" data-swal-title="Log out?" data-swal-text="You will need to sign in again to continue using LU Librisync." data-swal-confirm-text="Yes, log out" data-swal-cancel-text="Stay here" data-swal-icon="?">Logout</a>
            </nav>
        </aside>
        <main class="content-area">
            <section class="page-grid" style="margin-bottom:18px;">
                <div class="content-card">
                    <div class="eyebrow">Author Management</div>
                    <h2 class="section-title">Create and update author records.</h2>
                    <p class="section-copy">Improve catalog consistency and advanced search relevance by managing author information centrally.</p>
                    <form class="form-stack">
                        <div class="field-group">
                            <label>Author Name</label>
                            <input type="text" placeholder="Enter author name">
                        </div>
                        <div class="field-group">
                            <label>Biography</label>
                            <textarea placeholder="Short biography or notes"></textarea>
                        </div>
                        <button class="button" type="button">Save Author</button>
                    </form>
                </div>
                <div class="content-card">
                    <h3 class="section-title">Author Data Benefits</h3>
                    <ul class="muted">
                        <li>Supports author-based catalog browsing.</li>
                        <li>Improves advanced search filters and result quality.</li>
                        <li>Keeps book attribution consistent across print and digital titles.</li>
                    </ul>
                </div>
            </section>

            <section class="table-card">
                <h3 class="section-title">Author Directory</h3>
                <div class="table-wrap">
                    <table>
                        <thead>
                            <tr>
                                <th>Author</th>
                                <th>Specialization</th>
                                <th>Catalog Note</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td>Robert C. Martin</td>
                                <td>Software Engineering</td>
                                <td>Popular in computing and programming titles</td>
                            </tr>
                            <tr>
                                <td>Paulo Coelho</td>
                                <td>Literature</td>
                                <td>Frequently read fiction title author</td>
                            </tr>
                            <tr>
                                <td>John Dewey</td>
                                <td>Education</td>
                                <td>Key reference author for pedagogy collections</td>
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
