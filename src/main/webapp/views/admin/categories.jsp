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
    <title>Category Management | LU Librisync</title>
    <link rel="stylesheet" href="<%= contextPath %>/assets/css/librisync.css">
</head>
<body>
    <div class="dashboard-shell">
        <aside class="sidebar">
            <h1>LU Librisync</h1>
            <p>Manage category structure for smarter catalog organization and search.</p>
            <nav class="nav-list">
                <a href="<%= contextPath %>/admin/dashboard">Dashboard</a>
                <a href="<%= contextPath %>/views/admin/books.jsp">Books</a>
                <a href="<%= contextPath %>/views/admin/authors.jsp">Authors</a>
                <a class="active" href="<%= contextPath %>/views/admin/categories.jsp">Categories</a>
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
                    <div class="eyebrow">Category Management</div>
                    <h2 class="section-title">Organize books by category.</h2>
                    <p class="section-copy">Keep print and digital library materials easy to browse, filter, and analyze.</p>
                    <form class="form-stack">
                        <div class="field-group">
                            <label>Category Name</label>
                            <input type="text" placeholder="Enter category name">
                        </div>
                        <div class="field-group">
                            <label>Description</label>
                            <textarea placeholder="Describe the category"></textarea>
                        </div>
                        <button class="button" type="button">Save Category</button>
                    </form>
                </div>
                <div class="content-card">
                    <h3 class="section-title">Category Use Cases</h3>
                    <ul class="muted">
                        <li>Advanced search by academic or genre grouping.</li>
                        <li>Better borrowing analytics by discipline.</li>
                        <li>Stronger catalog navigation for students and admins.</li>
                    </ul>
                </div>
            </section>

            <section class="table-card">
                <h3 class="section-title">Category Directory</h3>
                <div class="table-wrap">
                    <table>
                        <thead>
                            <tr>
                                <th>Category</th>
                                <th>Description</th>
                                <th>Typical Use</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td>Computer Science</td>
                                <td>Programming, systems, and software engineering</td>
                                <td>Technical and development books</td>
                            </tr>
                            <tr>
                                <td>Education</td>
                                <td>Teaching and pedagogy resources</td>
                                <td>Teacher education and training materials</td>
                            </tr>
                            <tr>
                                <td>Literature</td>
                                <td>Fiction, poetry, and literary studies</td>
                                <td>Reading enrichment and language learning</td>
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
