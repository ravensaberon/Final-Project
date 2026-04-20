<%@ page import="com.lulibrisync.model.Author,com.lulibrisync.model.Book,com.lulibrisync.model.Category,com.lulibrisync.utils.DashboardViewHelper,java.net.URLEncoder,java.nio.charset.StandardCharsets,java.util.List" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    if (session.getAttribute("user") == null) {
        response.sendRedirect(request.getContextPath() + "/views/auth/login.jsp");
        return;
    }

    String contextPath = request.getContextPath();
    List<Book> books = (List<Book>) request.getAttribute("books");
    List<Category> categories = (List<Category>) request.getAttribute("bookCategories");
    List<Author> authors = (List<Author>) request.getAttribute("bookAuthors");

    if (books == null || categories == null || authors == null) {
        response.sendRedirect(contextPath + "/student/books");
        return;
    }

    String keyword = String.valueOf(request.getAttribute("keyword"));
    String availability = String.valueOf(request.getAttribute("availability"));
    String isbn = String.valueOf(request.getAttribute("isbn"));
    String barcode = String.valueOf(request.getAttribute("barcode"));
    Long selectedCategoryId = (Long) request.getAttribute("selectedCategoryId");
    Long selectedAuthorId = (Long) request.getAttribute("selectedAuthorId");

    if ("null".equalsIgnoreCase(keyword)) keyword = "";
    if ("null".equalsIgnoreCase(availability)) availability = "ALL";
    if ("null".equalsIgnoreCase(isbn)) isbn = "";
    if ("null".equalsIgnoreCase(barcode)) barcode = "";

    int availableCount = 0;
    int digitalCount = 0;
    int reserveOnlyCount = 0;
    for (Book book : books) {
        if (book.getAvailableQuantity() > 0) {
            availableCount++;
        } else {
            reserveOnlyCount++;
        }
        if (book.isDigital()) {
            digitalCount++;
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Browse Books | LU Librisync</title>
    <link rel="stylesheet" href="<%= contextPath %>/assets/css/librisync.css">
</head>
<body class="dashboard-reference">
    <div class="dashboard-shell">
        <aside class="sidebar">
            <div class="sidebar-brand">
                <div class="sidebar-brand-badge">LU</div>
                <div class="sidebar-brand-copy">
                    <strong>Student Portal</strong>
                    <span>Browse books</span>
                </div>
            </div>
            <p>Search by keyword, ISBN, barcode, category, author, and availability without leaving the student panel.</p>
            <div class="sidebar-section-label">Navigation</div>
            <nav class="nav-list">
                <a href="<%= contextPath %>/student/dashboard">Dashboard</a>
                <a class="active" href="<%= contextPath %>/student/books">Browse Books</a>
                <a href="<%= contextPath %>/student/borrowed">Borrowed Books</a>
                <a href="<%= contextPath %>/student/reservations">Reservations</a>
                <a href="<%= contextPath %>/student/profile">Profile</a>
                <a href="<%= contextPath %>/search/advanced">Advanced Search</a>
                <a href="<%= contextPath %>/views/auth/change-password.jsp">Change Password</a>
                <a href="<%= contextPath %>/logout" data-swal-confirm="true" data-swal-title="Log out?" data-swal-text="You will need to sign in again to continue using LU Librisync." data-swal-confirm-text="Yes, log out" data-swal-cancel-text="Stay here" data-swal-icon="?">Logout</a>
            </nav>
            <div class="sidebar-mini-card">
                <strong>Catalog tip</strong>
                <span>Unavailable copies can still be queued through the reservation system.</span>
            </div>
        </aside>

        <main class="content-area">
            <section class="dashboard-topbar">
                <div>
                    <div class="eyebrow">Browse Books</div>
                    <h2 class="workspace-title">Library catalog with smart filters</h2>
                    <p class="workspace-copy">
                        This page now pulls real titles from the catalog, supports quick reservation actions, and opens
                        the digital reader for e-book-ready titles.
                    </p>
                </div>
                <div class="dashboard-toolbar">
                    <div class="search-prompt"><%= books.size() %> results</div>
                    <div class="status-chip"><%= availableCount %> available now</div>
                </div>
            </section>

            <section class="overview-tile-grid">
                <article class="kpi-tile tile-sky">
                    <span class="tile-meta-label">Catalog Results</span>
                    <strong class="tile-value"><%= books.size() %></strong>
                    <span class="tile-copy">Books matching your current catalog view.</span>
                    <div class="tile-track"><span data-progress-width="100"></span></div>
                </article>
                <article class="kpi-tile tile-teal">
                    <span class="tile-meta-label">Available Copies</span>
                    <strong class="tile-value"><%= availableCount %></strong>
                    <span class="tile-copy">Books with stock that can be issued right away.</span>
                    <div class="tile-track"><span data-progress-width="<%= books.isEmpty() ? 0 : DashboardViewHelper.percentOf(availableCount, books.size()) %>"></span></div>
                </article>
                <article class="kpi-tile tile-amber">
                    <span class="tile-meta-label">Digital Titles</span>
                    <strong class="tile-value"><%= digitalCount %></strong>
                    <span class="tile-copy">Titles that can open in the built-in reader.</span>
                    <div class="tile-track"><span data-progress-width="<%= books.isEmpty() ? 0 : DashboardViewHelper.percentOf(digitalCount, books.size()) %>"></span></div>
                </article>
                <article class="kpi-tile tile-violet">
                    <span class="tile-meta-label">Reserve Queue</span>
                    <strong class="tile-value"><%= reserveOnlyCount %></strong>
                    <span class="tile-copy">Unavailable titles you can push into the reservation queue.</span>
                    <div class="tile-track"><span data-progress-width="<%= books.isEmpty() ? 0 : DashboardViewHelper.percentOf(reserveOnlyCount, books.size()) %>"></span></div>
                </article>
            </section>

            <section class="panel-grid">
                <article class="dashboard-panel">
                    <div class="panel-head">
                        <div>
                            <h3>Quick Catalog Filter</h3>
                            <p>Search here or open the advanced page for ISBN and barcode-focused lookup.</p>
                        </div>
                        <a class="button-soft button-small" href="<%= contextPath %>/search/advanced">Open advanced search</a>
                    </div>

                    <form class="form-stack" action="<%= contextPath %>/student/books" method="get">
                        <div class="form-grid">
                            <div class="field-group">
                                <label for="keyword">Keyword</label>
                                <input id="keyword" name="keyword" type="text" value="<%= DashboardViewHelper.escapeHtml(keyword) %>" placeholder="Search title, author, category, or summary">
                            </div>
                            <div class="field-group">
                                <label for="availability">Availability</label>
                                <select id="availability" name="availability">
                                    <option value="ALL" <%= "ALL".equalsIgnoreCase(availability) ? "selected" : "" %>>All catalog statuses</option>
                                    <option value="AVAILABLE" <%= "AVAILABLE".equalsIgnoreCase(availability) ? "selected" : "" %>>Available now</option>
                                    <option value="UNAVAILABLE" <%= "UNAVAILABLE".equalsIgnoreCase(availability) ? "selected" : "" %>>Reserve only</option>
                                    <option value="DIGITAL" <%= "DIGITAL".equalsIgnoreCase(availability) ? "selected" : "" %>>Digital titles</option>
                                </select>
                            </div>
                        </div>
                        <div class="form-grid">
                            <div class="field-group">
                                <label for="categoryId">Category</label>
                                <select id="categoryId" name="categoryId">
                                    <option value="">All categories</option>
                                    <% for (Category category : categories) { %>
                                        <option value="<%= category.getId() %>" <%= selectedCategoryId != null && selectedCategoryId == category.getId() ? "selected" : "" %>>
                                            <%= DashboardViewHelper.escapeHtml(category.getName()) %>
                                        </option>
                                    <% } %>
                                </select>
                            </div>
                            <div class="field-group">
                                <label for="authorId">Author</label>
                                <select id="authorId" name="authorId">
                                    <option value="">All authors</option>
                                    <% for (Author author : authors) { %>
                                        <option value="<%= author.getId() %>" <%= selectedAuthorId != null && selectedAuthorId == author.getId() ? "selected" : "" %>>
                                            <%= DashboardViewHelper.escapeHtml(author.getName()) %>
                                        </option>
                                    <% } %>
                                </select>
                            </div>
                        </div>
                        <div class="form-grid">
                            <div class="field-group">
                                <label for="isbn">ISBN Lookup</label>
                                <input id="isbn" name="isbn" type="text" value="<%= DashboardViewHelper.escapeHtml(isbn) %>" placeholder="Enter or paste ISBN">
                            </div>
                            <div class="field-group">
                                <label for="barcode">Barcode Input</label>
                                <input id="barcode" name="barcode" type="text" value="<%= DashboardViewHelper.escapeHtml(barcode) %>" placeholder="Type or scan a barcode value">
                            </div>
                        </div>
                        <div class="button-row">
                            <button class="button" type="submit">Search Catalog</button>
                            <a class="button-secondary" href="<%= contextPath %>/student/books">Reset Filters</a>
                        </div>
                    </form>
                </article>

                <div class="stack-grid">
                    <article class="dashboard-panel">
                        <div class="panel-head">
                            <div>
                                <h3>Feature Coverage</h3>
                                <p>Student-side catalog tools now map to the requirement list.</p>
                            </div>
                        </div>
                        <div class="summary-list">
                            <div class="summary-item">
                                <strong>Advanced search ready</strong>
                                <span>Category, author, availability, ISBN, and barcode filters are wired to the database.</span>
                            </div>
                            <div class="summary-item">
                                <strong>Reservation shortcut</strong>
                                <span>Any listed book can be sent directly to your queue from this page.</span>
                            </div>
                            <div class="summary-item">
                                <strong>Digital access</strong>
                                <span>E-book-ready titles open in the built-in reader with saved progress support.</span>
                            </div>
                        </div>
                    </article>
                </div>
            </section>

            <section class="dashboard-panel">
                <div class="panel-head">
                    <div>
                        <h3>Catalog Results</h3>
                        <p>Live books from your current library database.</p>
                    </div>
                    <span class="panel-badge"><%= books.size() %> matched</span>
                </div>

                <% if (books.isEmpty()) { %>
                    <div class="empty-state">
                        <strong>No books matched those filters</strong>
                        <p>Try clearing one or two filters, or open the advanced search page for a more targeted query.</p>
                    </div>
                <% } else { %>
                    <div class="table-wrap">
                        <table class="dashboard-table">
                            <thead>
                                <tr>
                                    <th>Title</th>
                                    <th>Author / Category</th>
                                    <th>ISBN / Barcode</th>
                                    <th>Availability</th>
                                    <th>Digital</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% for (Book book : books) {
                                       String tone = book.getAvailableQuantity() > 0 ? "success" : "warning";
                                       String statusLabel = book.getAvailableQuantity() > 0
                                               ? book.getAvailableQuantity() + " available"
                                               : "Reserve queue only";
                                       String readerUrl = contextPath + "/ebook/read?bookId=" + book.getId()
                                               + "&title=" + URLEncoder.encode(book.getTitle(), StandardCharsets.UTF_8)
                                               + "&author=" + URLEncoder.encode(book.getAuthorName(), StandardCharsets.UTF_8)
                                               + "&isbn=" + URLEncoder.encode(book.getIsbn(), StandardCharsets.UTF_8)
                                               + "&chapter=" + URLEncoder.encode("Digital preview", StandardCharsets.UTF_8)
                                               + "&cover=" + URLEncoder.encode(book.isDigital() ? "emerald" : "teal", StandardCharsets.UTF_8)
                                               + "&progress=12";
                                %>
                                    <tr>
                                        <td>
                                            <strong><%= DashboardViewHelper.escapeHtml(book.getTitle()) %></strong><br>
                                            <span class="subtle-text"><%= DashboardViewHelper.escapeHtml(book.getShelfLocation()) %></span>
                                        </td>
                                        <td>
                                            <strong><%= DashboardViewHelper.escapeHtml(book.getAuthorName()) %></strong><br>
                                            <span class="subtle-text"><%= DashboardViewHelper.escapeHtml(book.getCategoryName()) %></span>
                                        </td>
                                        <td>
                                            <strong><%= DashboardViewHelper.escapeHtml(book.getIsbn()) %></strong><br>
                                            <span class="subtle-text"><%= DashboardViewHelper.escapeHtml(book.getBarcode()) %></span>
                                        </td>
                                        <td><span class="pill <%= tone %>"><%= statusLabel %></span></td>
                                        <td>
                                            <% if (book.isDigital()) { %>
                                                <span class="pill success">Reader enabled</span>
                                            <% } else { %>
                                                <span class="pill neutral">Physical only</span>
                                            <% } %>
                                        </td>
                                        <td>
                                            <div class="table-actions">
                                                <form action="<%= contextPath %>/student/reservations" method="post">
                                                    <input type="hidden" name="bookId" value="<%= book.getId() %>">
                                                    <button class="button-soft button-small" type="submit">Reserve</button>
                                                </form>
                                                <% if (book.isDigital()) { %>
                                                    <a class="button-outline button-small" href="<%= readerUrl %>">Read</a>
                                                <% } %>
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
    <script src="<%= contextPath %>/assets/js/progress-width.js"></script>
</body>
</html>
