<%@ page import="com.lulibrisync.model.Author,com.lulibrisync.model.Book,com.lulibrisync.model.Category,java.util.List" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%!
    private String h(Object value) {
        String text = value == null ? "" : String.valueOf(value);
        return text.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }
%>
<%
    if (session.getAttribute("user") == null || !"ADMIN".equals(session.getAttribute("role"))) {
        response.sendRedirect(request.getContextPath() + "/views/auth/login.jsp");
        return;
    }

    String contextPath = request.getContextPath();
    List<Book> books = (List<Book>) request.getAttribute("books");
    List<Category> categories = (List<Category>) request.getAttribute("categories");
    List<Author> authors = (List<Author>) request.getAttribute("authors");
    Book editBook = (Book) request.getAttribute("editBook");

    int totalTitles = request.getAttribute("totalTitles") == null ? 0 : (Integer) request.getAttribute("totalTitles");
    int digitalTitles = request.getAttribute("digitalTitles") == null ? 0 : (Integer) request.getAttribute("digitalTitles");
    int lowStockCount = request.getAttribute("lowStockCount") == null ? 0 : (Integer) request.getAttribute("lowStockCount");
    int totalCopies = request.getAttribute("totalCopies") == null ? 0 : (Integer) request.getAttribute("totalCopies");
    int availableCopies = request.getAttribute("availableCopies") == null ? 0 : (Integer) request.getAttribute("availableCopies");

    String feedbackType = request.getParameter("feedbackType");
    String feedbackMessage = request.getParameter("feedbackMessage");

    if (books == null) books = java.util.Collections.emptyList();
    if (categories == null) categories = java.util.Collections.emptyList();
    if (authors == null) authors = java.util.Collections.emptyList();

    int maxCopies = 1;
    for (Book book : books) {
        maxCopies = Math.max(maxCopies, book.getQuantity());
    }

    boolean editing = editBook != null;
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
            <p>Manage catalog records, stock health, and the metadata students rely on when browsing the library.</p>
            <nav class="nav-list">
                <a href="<%= contextPath %>/admin/dashboard">Dashboard</a>
                <a class="active" href="<%= contextPath %>/admin/books">Books</a>
                <a href="<%= contextPath %>/admin/authors">Authors</a>
                <a href="<%= contextPath %>/admin/categories">Categories</a>
                <a href="<%= contextPath %>/admin/issue">Issue Book</a>
                <a href="<%= contextPath %>/admin/return">Return Book</a>
                <a href="<%= contextPath %>/admin/students">Students</a>
                <a href="<%= contextPath %>/admin/analytics">Analytics</a>
                <a href="<%= contextPath %>/logout" data-swal-confirm="true" data-swal-title="Log out?" data-swal-text="You will need to sign in again to continue using LU Librisync." data-swal-confirm-text="Yes, log out" data-swal-cancel-text="Stay here" data-swal-icon="?">Logout</a>
            </nav>
        </aside>

        <main class="content-area">
            <section class="hero-card content-card" style="margin-bottom:18px;">
                <div class="eyebrow">Book CRUD</div>
                <h2 class="section-title">Maintain the catalog with live stock and metadata control.</h2>
                <p class="section-copy">
                    Add new titles, update availability, manage category and author mapping, and remove stale records
                    from the catalog without leaving the admin workflow.
                </p>
                <div class="button-row">
                    <a class="button-secondary" href="<%= contextPath %>/admin/authors">Manage Authors</a>
                    <a class="button-ghost" href="<%= contextPath %>/admin/categories">Manage Categories</a>
                </div>
            </section>

            <section class="metric-strip" style="margin-bottom:18px;">
                <article class="mini-stat">
                    <strong>Total Titles</strong>
                    <span class="metric"><%= totalTitles %></span>
                    <span>Distinct catalog records currently managed in LU Librisync.</span>
                </article>
                <article class="mini-stat">
                    <strong>Total Copies</strong>
                    <span class="metric"><%= totalCopies %></span>
                    <span>Combined quantity across the physical and digital book inventory.</span>
                </article>
                <article class="mini-stat">
                    <strong>Available Copies</strong>
                    <span class="metric"><%= availableCopies %></span>
                    <span>Copies still ready for checkout or immediate student access.</span>
                </article>
                <article class="mini-stat">
                    <strong>Low Stock Titles</strong>
                    <span class="metric"><%= lowStockCount %></span>
                    <span>Titles with two or fewer available copies left in the system.</span>
                </article>
                <article class="mini-stat">
                    <strong>Digital Titles</strong>
                    <span class="metric"><%= digitalTitles %></span>
                    <span>Books already marked as accessible from the digital library flow.</span>
                </article>
            </section>

            <section class="chart-grid" style="margin-bottom:18px;">
                <article class="content-card">
                    <div class="table-toolbar">
                        <div>
                            <h3 class="section-title"><%= editing ? "Edit Book" : "Create Book" %></h3>
                            <p class="chart-caption">Capture the details students and staff need for borrowing, search, and stock tracking.</p>
                        </div>
                    </div>

                    <% if (feedbackMessage != null && !feedbackMessage.isBlank()) { %>
                        <div class="alert <%= "success".equals(feedbackType) ? "success" : "error" %>"><%= h(feedbackMessage) %></div>
                    <% } %>

                    <form class="form-stack" action="<%= contextPath %>/admin/books" method="post">
                        <input type="hidden" name="action" value="<%= editing ? "update" : "create" %>">
                        <% if (editing) { %>
                            <input type="hidden" name="id" value="<%= editBook.getId() %>">
                        <% } %>

                        <div class="form-grid">
                            <div class="field-group">
                                <label for="title">Book Title</label>
                                <input id="title" name="title" type="text" maxlength="180" required
                                       value="<%= editing ? h(editBook.getTitle()) : "" %>"
                                       placeholder="Enter title">
                            </div>
                            <div class="field-group">
                                <label for="isbn">ISBN</label>
                                <input id="isbn" name="isbn" type="text" maxlength="30" required
                                       value="<%= editing ? h(editBook.getIsbn()) : "" %>"
                                       placeholder="Enter ISBN">
                            </div>
                        </div>

                        <div class="form-grid">
                            <div class="field-group">
                                <label for="authorId">Author</label>
                                <select id="authorId" name="authorId">
                                    <option value="">Select author</option>
                                    <% for (Author author : authors) { %>
                                        <option value="<%= author.getId() %>"
                                            <%= editing && editBook.getAuthorId() != null && editBook.getAuthorId().longValue() == author.getId() ? "selected" : "" %>>
                                            <%= h(author.getName()) %>
                                        </option>
                                    <% } %>
                                </select>
                            </div>
                            <div class="field-group">
                                <label for="categoryId">Category</label>
                                <select id="categoryId" name="categoryId">
                                    <option value="">Select category</option>
                                    <% for (Category category : categories) { %>
                                        <option value="<%= category.getId() %>"
                                            <%= editing && editBook.getCategoryId() != null && editBook.getCategoryId().longValue() == category.getId() ? "selected" : "" %>>
                                            <%= h(category.getName()) %>
                                        </option>
                                    <% } %>
                                </select>
                            </div>
                        </div>

                        <div class="form-grid">
                            <div class="field-group">
                                <label for="barcode">Barcode</label>
                                <input id="barcode" name="barcode" type="text" maxlength="60"
                                       value="<%= editing ? h(editBook.getBarcode()) : "" %>"
                                       placeholder="Optional barcode">
                            </div>
                            <div class="field-group">
                                <label for="publicationYear">Publication Year</label>
                                <input id="publicationYear" name="publicationYear" type="number" min="1000" max="2100"
                                       value="<%= editing && editBook.getPublicationYear() != null ? editBook.getPublicationYear() : "" %>"
                                       placeholder="Optional year">
                            </div>
                        </div>

                        <div class="form-grid">
                            <div class="field-group">
                                <label for="quantity">Total Quantity</label>
                                <input id="quantity" name="quantity" type="number" min="0" required
                                       value="<%= editing ? editBook.getQuantity() : "" %>"
                                       placeholder="Total copies">
                            </div>
                            <div class="field-group">
                                <label for="availableQuantity">Available Quantity</label>
                                <input id="availableQuantity" name="availableQuantity" type="number" min="0" required
                                       value="<%= editing ? editBook.getAvailableQuantity() : "" %>"
                                       placeholder="Available copies">
                            </div>
                        </div>

                        <div class="form-grid">
                            <div class="field-group">
                                <label for="shelfLocation">Shelf Location</label>
                                <input id="shelfLocation" name="shelfLocation" type="text" maxlength="80"
                                       value="<%= editing ? h(editBook.getShelfLocation()) : "" %>"
                                       placeholder="Example: A1-04">
                            </div>
                            <div class="field-group">
                                <label for="isDigital">Digital Availability</label>
                                <div class="checkbox-row" style="min-height:50px;align-items:center;padding-top:8px;">
                                    <input id="isDigital" name="isDigital" type="checkbox" <%= editing && editBook.isDigital() ? "checked" : "" %>>
                                    <label for="isDigital">Available in the digital library</label>
                                </div>
                            </div>
                        </div>

                        <div class="field-group">
                            <label for="description">Description</label>
                            <textarea id="description" name="description" placeholder="Summary, notes, or catalog description."><%= editing ? h(editBook.getDescription()) : "" %></textarea>
                        </div>

                        <div class="button-row">
                            <button class="button" type="submit"><%= editing ? "Update Book" : "Save Book" %></button>
                            <% if (editing) { %>
                                <a class="button-secondary" href="<%= contextPath %>/admin/books">Cancel Edit</a>
                            <% } %>
                            <a class="button-ghost" href="<%= contextPath %>/views/ebook/upload.jsp">Upload E-Book</a>
                        </div>
                    </form>
                </article>

                <article class="chart-card">
                    <div class="chart-header">
                        <div>
                            <h3 class="section-title">Inventory Health</h3>
                            <p class="chart-caption">Quick view of how much stock each title still has available.</p>
                        </div>
                    </div>

                    <% if (books.isEmpty()) { %>
                        <div class="empty-state">
                            <strong>No books yet</strong>
                            <p>Add your first title to build the catalog and inventory health chart.</p>
                        </div>
                    <% } else { %>
                        <div class="bar-chart">
                            <% for (Book book : books) {
                                int percent = book.getQuantity() == 0 ? 6 : (int) Math.round((book.getAvailableQuantity() * 100.0) / Math.max(1, book.getQuantity()));
                                String tone = book.getAvailableQuantity() <= 1 ? "danger" : (book.getAvailableQuantity() <= 2 ? "warning" : "success");
                            %>
                                <div class="bar-row">
                                    <div class="bar-meta">
                                        <strong><%= h(book.getTitle()) %></strong>
                                        <span><%= book.getAvailableQuantity() %> / <%= book.getQuantity() %> available</span>
                                    </div>
                                    <div class="bar-track">
                                        <div class="bar-fill <%= tone %>" style="width:<%= percent %>%;"></div>
                                    </div>
                                </div>
                            <% } %>
                        </div>
                    <% } %>
                </article>
            </section>

            <section class="table-card">
                <div class="table-toolbar">
                    <div>
                        <h3 class="section-title">Catalog Directory</h3>
                        <p class="chart-caption">Edit or remove titles directly from the live catalog table.</p>
                    </div>
                </div>

                <% if (books.isEmpty()) { %>
                    <div class="empty-state">
                        <strong>No titles yet</strong>
                        <p>Your catalog is currently empty. Add a title using the form above to begin.</p>
                    </div>
                <% } else { %>
                    <div class="table-wrap">
                        <table>
                            <thead>
                                <tr>
                                    <th>Title</th>
                                    <th>Author</th>
                                    <th>Category</th>
                                    <th>ISBN / Barcode</th>
                                    <th>Availability</th>
                                    <th>Digital</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% for (Book book : books) {
                                    String tone = book.getAvailableQuantity() <= 1 ? "danger" : (book.getAvailableQuantity() <= 2 ? "warning" : "success");
                                %>
                                    <tr>
                                        <td>
                                            <strong><%= h(book.getTitle()) %></strong><br>
                                            <span class="muted">Shelf: <%= book.getShelfLocation().isBlank() ? "Not set" : h(book.getShelfLocation()) %></span>
                                        </td>
                                        <td><%= h(book.getAuthorName()) %></td>
                                        <td><%= h(book.getCategoryName()) %></td>
                                        <td>
                                            <span class="muted">ISBN:</span> <%= h(book.getIsbn()) %><br>
                                            <span class="muted">Barcode:</span> <%= book.getBarcode().isBlank() ? "Not set" : h(book.getBarcode()) %>
                                        </td>
                                        <td><span class="pill <%= tone %>"><%= book.getAvailableQuantity() %> / <%= book.getQuantity() %> available</span></td>
                                        <td><span class="pill <%= book.isDigital() ? "success" : "neutral" %>"><%= book.isDigital() ? "Digital" : "Print only" %></span></td>
                                        <td>
                                            <div class="table-actions">
                                                <a class="button-outline button-small" href="<%= contextPath %>/admin/books?edit=<%= book.getId() %>">Edit</a>
                                                <form action="<%= contextPath %>/admin/books" method="post">
                                                    <input type="hidden" name="action" value="delete">
                                                    <input type="hidden" name="id" value="<%= book.getId() %>">
                                                    <button class="button-danger button-small" type="submit"
                                                            onclick="return confirm('Delete this book? Related issue and reservation history may also be removed.');">
                                                        Delete
                                                    </button>
                                                </form>
                                            </div>
                                        </td>
                                    </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                <% } %>
            </section>
        </main>
    </div>
    <script src="<%= contextPath %>/assets/js/lu-swal.js"></script>
</body>
</html>
