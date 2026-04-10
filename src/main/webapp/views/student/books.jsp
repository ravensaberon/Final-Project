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
    <title>Browse Books | LU Librisync</title>
    <link rel="stylesheet" href="<%= contextPath %>/assets/css/librisync.css">
</head>
<body>
    <div class="dashboard-shell">
        <aside class="sidebar">
            <h1>LU Librisync</h1>
            <p>Student book browsing with advanced search, filters, and digital access.</p>
            <nav class="nav-list">
                <a href="<%= contextPath %>/student/dashboard">Dashboard</a>
                <a class="active" href="<%= contextPath %>/student/books">Browse Books</a>
                <a href="<%= contextPath %>/student/borrowed">Borrowed Books</a>
                <a href="<%= contextPath %>/student/reservations">Reservations</a>
                <a href="<%= contextPath %>/student/profile">Profile</a>
                <a href="<%= contextPath %>/views/search/advanced-search.jsp">Advanced Search</a>
                <a href="<%= contextPath %>/logout" data-swal-confirm="true" data-swal-title="Log out?" data-swal-text="You will need to sign in again to continue using LU Librisync." data-swal-confirm-text="Yes, log out" data-swal-cancel-text="Stay here" data-swal-icon="?">Logout</a>
            </nav>
        </aside>
        <main class="content-area">
            <section class="page-grid" style="margin-bottom:18px;">
                <div class="content-card">
                    <div class="eyebrow">Book Discovery</div>
                    <h2 class="section-title">Browse the library collection.</h2>
                    <p class="section-copy">Search by title, author, ISBN, barcode, category, and availability.</p>
                    <form class="form-stack">
                        <div class="form-grid">
                            <div class="field-group">
                                <label>Keyword</label>
                                <input type="text" placeholder="Search title, author, or keyword">
                            </div>
                            <div class="field-group">
                                <label>Availability</label>
                                <select>
                                    <option>All</option>
                                    <option>Available</option>
                                    <option>Reserved</option>
                                    <option>Digital Only</option>
                                </select>
                            </div>
                        </div>
                        <div class="form-grid">
                            <div class="field-group">
                                <label>Category</label>
                                <input type="text" placeholder="Example: Computer Science">
                            </div>
                            <div class="field-group">
                                <label>Author</label>
                                <input type="text" placeholder="Enter author">
                            </div>
                        </div>
                        <div class="button-row">
                            <button class="button" type="button">Search</button>
                            <a class="button-secondary" href="<%= contextPath %>/views/search/advanced-search.jsp">Open Advanced Search</a>
                        </div>
                    </form>
                </div>
                <div class="content-card">
                    <h3 class="section-title">Student Features</h3>
                    <ul class="muted">
                        <li>Reserve unavailable books and monitor queue status.</li>
                        <li>Open digital titles in the e-book reader.</li>
                        <li>Search using ISBN or barcode information.</li>
                    </ul>
                    <p class="section-copy" style="margin-top: 14px;">Digital books you open here will appear in your dashboard's Continue Reading row.</p>
                </div>
            </section>

            <section class="table-card">
                <h3 class="section-title">Available Books</h3>
                <div class="table-wrap">
                    <table>
                        <thead>
                            <tr>
                                <th>Title</th>
                                <th>Author</th>
                                <th>ISBN</th>
                                <th>Availability</th>
                                <th>Digital</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td>Clean Code</td>
                                <td>Robert C. Martin</td>
                                <td>9780132350884</td>
                                <td><span class="pill success">Available</span></td>
                                <td><a href="<%= contextPath %>/ebook/read?bookId=clean-code&amp;title=Clean%20Code&amp;author=Robert%20C.%20Martin&amp;isbn=9780132350884&amp;chapter=Chapter%203%20-%20Meaningful%20Names&amp;cover=emerald&amp;progress=42">Read Online</a></td>
                            </tr>
                            <tr>
                                <td>The Alchemist</td>
                                <td>Paulo Coelho</td>
                                <td>9780062315007</td>
                                <td><span class="pill warning">Reserve</span></td>
                                <td><a href="<%= contextPath %>/ebook/read?bookId=the-alchemist&amp;title=The%20Alchemist&amp;author=Paulo%20Coelho&amp;isbn=9780062315007&amp;chapter=Part%202%20-%20The%20Crystal%20Merchant&amp;cover=olive&amp;progress=18">Read Online</a></td>
                            </tr>
                            <tr>
                                <td>Democracy and Education</td>
                                <td>John Dewey</td>
                                <td>9780684836317</td>
                                <td><span class="pill danger">Limited</span></td>
                                <td><a href="<%= contextPath %>/ebook/read?bookId=democracy-education&amp;title=Democracy%20and%20Education&amp;author=John%20Dewey&amp;isbn=9780684836317&amp;chapter=Section%201%20-%20Education%20as%20Growth&amp;cover=teal&amp;progress=7">Read Online</a></td>
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
