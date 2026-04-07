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
    <title>Book Management | LU Librisync</title>
    <link rel="stylesheet" href="<%= contextPath %>/assets/css/librisync.css">
</head>
<body>
    <div class="dashboard-shell">
        <aside class="sidebar">
            <h1>LU Librisync</h1>
            <p>Manage print and digital catalog records in one workspace.</p>
            <nav class="nav-list">
                <a href="<%= contextPath %>/admin/dashboard">Dashboard</a>
                <a class="active" href="<%= contextPath %>/views/admin/books.jsp">Books</a>
                <a href="<%= contextPath %>/views/admin/authors.jsp">Authors</a>
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
                    <div class="eyebrow">Book Management</div>
                    <h2 class="section-title">Add and organize library books.</h2>
                    <p class="section-copy">Capture title, ISBN, barcode, quantity, category, author, and digital library status.</p>
                    <form class="form-stack">
                        <div class="form-grid">
                            <div class="field-group">
                                <label>Book Title</label>
                                <input type="text" placeholder="Enter title">
                            </div>
                            <div class="field-group">
                                <label>ISBN</label>
                                <input type="text" placeholder="Enter ISBN">
                            </div>
                        </div>
                        <div class="form-grid">
                            <div class="field-group">
                                <label>Author</label>
                                <input type="text" placeholder="Select or add author">
                            </div>
                            <div class="field-group">
                                <label>Category</label>
                                <input type="text" placeholder="Select category">
                            </div>
                        </div>
                        <div class="form-grid">
                            <div class="field-group">
                                <label>Barcode</label>
                                <input type="text" placeholder="Enter barcode">
                            </div>
                            <div class="field-group">
                                <label>Shelf Location</label>
                                <input type="text" placeholder="Example: A1-04">
                            </div>
                        </div>
                        <div class="form-grid">
                            <div class="field-group">
                                <label>Quantity</label>
                                <input type="number" placeholder="Total quantity">
                            </div>
                            <div class="field-group">
                                <label>Available Quantity</label>
                                <input type="number" placeholder="Available copies">
                            </div>
                        </div>
                        <div class="field-group">
                            <label>Description</label>
                            <textarea placeholder="Book description or notes"></textarea>
                        </div>
                        <div class="checkbox-row">
                            <input id="isDigital" type="checkbox">
                            <label for="isDigital">This title is available in the digital library.</label>
                        </div>
                        <div class="button-row">
                            <button class="button" type="button">Save Book</button>
                            <a class="button-secondary" href="<%= contextPath %>/views/ebook/upload.jsp">Upload E-Book</a>
                        </div>
                    </form>
                </div>

                <div class="content-card">
                    <h3 class="section-title">Catalog Features</h3>
                    <ul class="muted">
                        <li>Advanced search filters by category, author, availability, ISBN, and barcode.</li>
                        <li>Digital library readiness for e-book upload and access.</li>
                        <li>Reservation queue support when available quantity reaches zero.</li>
                        <li>QR-ready issue reference support for faster circulation.</li>
                    </ul>
                </div>
            </section>

            <section class="table-card">
                <h3 class="section-title">Catalog Snapshot</h3>
                <div class="table-wrap">
                    <table>
                        <thead>
                            <tr>
                                <th>Title</th>
                                <th>ISBN</th>
                                <th>Author</th>
                                <th>Category</th>
                                <th>Availability</th>
                                <th>Digital</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td>Clean Code</td>
                                <td>9780132350884</td>
                                <td>Robert C. Martin</td>
                                <td>Computer Science</td>
                                <td><span class="pill success">3 Available</span></td>
                                <td>Yes</td>
                            </tr>
                            <tr>
                                <td>The Alchemist</td>
                                <td>9780062315007</td>
                                <td>Paulo Coelho</td>
                                <td>Literature</td>
                                <td><span class="pill warning">2 Available</span></td>
                                <td>Yes</td>
                            </tr>
                            <tr>
                                <td>Democracy and Education</td>
                                <td>9780684836317</td>
                                <td>John Dewey</td>
                                <td>Education</td>
                                <td><span class="pill danger">Low Stock</span></td>
                                <td>No</td>
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
