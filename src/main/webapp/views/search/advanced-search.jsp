<%@ page import="com.lulibrisync.model.Author,com.lulibrisync.model.Book,com.lulibrisync.model.Category,com.lulibrisync.utils.DashboardViewHelper,java.net.URLEncoder,java.nio.charset.StandardCharsets,java.util.List" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    String contextPath = request.getContextPath();
    List<Book> searchResults = (List<Book>) request.getAttribute("searchResults");
    List<Category> searchCategories = (List<Category>) request.getAttribute("searchCategories");
    List<Author> searchAuthors = (List<Author>) request.getAttribute("searchAuthors");

    if (searchResults == null || searchCategories == null || searchAuthors == null) {
        response.sendRedirect(contextPath + "/search/advanced");
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

    boolean studentLoggedIn = "STUDENT".equals(String.valueOf(session.getAttribute("role")));
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Advanced Search | LU Librisync</title>
    <link rel="stylesheet" href="<%= contextPath %>/assets/css/librisync.css">
</head>
<body>
    <div class="page-shell">
        <section class="form-panel">
            <div class="eyebrow">Advanced Search</div>
            <h2>Search the LU Librisync collection.</h2>
            <p class="subtitle">Filter by category, author, availability, ISBN, and barcode. Barcode scanning now fills the search box when your browser supports the camera scanner API.</p>

            <form class="form-stack" action="<%= contextPath %>/search/advanced" method="get">
                <div class="form-grid">
                    <div class="field-group">
                        <label for="keyword">Keyword</label>
                        <input id="keyword" name="keyword" type="text" value="<%= DashboardViewHelper.escapeHtml(keyword) %>" placeholder="Enter title, author, category, or summary">
                    </div>
                    <div class="field-group">
                        <label for="authorId">Author</label>
                        <select id="authorId" name="authorId">
                            <option value="">All authors</option>
                            <% for (Author author : searchAuthors) { %>
                                <option value="<%= author.getId() %>" <%= selectedAuthorId != null && selectedAuthorId == author.getId() ? "selected" : "" %>>
                                    <%= DashboardViewHelper.escapeHtml(author.getName()) %>
                                </option>
                            <% } %>
                        </select>
                    </div>
                </div>
                <div class="form-grid">
                    <div class="field-group">
                        <label for="categoryId">Category</label>
                        <select id="categoryId" name="categoryId">
                            <option value="">All categories</option>
                            <% for (Category category : searchCategories) { %>
                                <option value="<%= category.getId() %>" <%= selectedCategoryId != null && selectedCategoryId == category.getId() ? "selected" : "" %>>
                                    <%= DashboardViewHelper.escapeHtml(category.getName()) %>
                                </option>
                            <% } %>
                        </select>
                    </div>
                    <div class="field-group">
                        <label for="availability">Availability</label>
                        <select id="availability" name="availability">
                            <option value="ALL" <%= "ALL".equalsIgnoreCase(availability) ? "selected" : "" %>>All statuses</option>
                            <option value="AVAILABLE" <%= "AVAILABLE".equalsIgnoreCase(availability) ? "selected" : "" %>>Available now</option>
                            <option value="UNAVAILABLE" <%= "UNAVAILABLE".equalsIgnoreCase(availability) ? "selected" : "" %>>Reserve only</option>
                            <option value="DIGITAL" <%= "DIGITAL".equalsIgnoreCase(availability) ? "selected" : "" %>>Digital only</option>
                        </select>
                    </div>
                </div>
                <div class="form-grid">
                    <div class="field-group">
                        <label for="isbn">ISBN Search</label>
                        <input id="isbn" name="isbn" type="text" value="<%= DashboardViewHelper.escapeHtml(isbn) %>" placeholder="Search by ISBN">
                    </div>
                    <div class="field-group">
                        <label for="barcode">Barcode Search</label>
                        <input id="barcode" name="barcode" type="text" value="<%= DashboardViewHelper.escapeHtml(barcode) %>" placeholder="Type or scan barcode">
                        <p class="field-help" id="barcodeHelp">You can paste a barcode, use a hardware scanner, or try camera scan below.</p>
                    </div>
                </div>
                <div class="button-row">
                    <button class="button" type="submit">Run Search</button>
                    <button class="button-secondary" id="scanBarcodeButton" type="button">Scan Barcode</button>
                    <a class="button-ghost" href="<%= contextPath %>/search/advanced">Reset</a>
                    <a class="button-secondary" href="<%= studentLoggedIn ? contextPath + "/student/books" : contextPath + "/" %>">Back</a>
                </div>
            </form>
        </section>

        <section class="table-card" style="margin:24px;">
            <div class="panel-head">
                <div>
                    <h3 class="section-title">Search Results</h3>
                    <p class="section-copy">Results are now pulled directly from the books table with your selected filters.</p>
                </div>
                <span class="panel-badge"><%= searchResults.size() %> matches</span>
            </div>

            <% if (searchResults.isEmpty()) { %>
                <div class="empty-state">
                    <strong>No results matched that search</strong>
                    <p>Try clearing one filter at a time or switching to a broader keyword.</p>
                </div>
            <% } else { %>
                <div class="table-wrap">
                    <table class="dashboard-table">
                        <thead>
                            <tr>
                                <th>Title</th>
                                <th>Category</th>
                                <th>Author</th>
                                <th>ISBN</th>
                                <th>Barcode</th>
                                <th>Status</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (Book book : searchResults) {
                                   String tone = book.getAvailableQuantity() > 0 ? "success" : "warning";
                                   String readerUrl = contextPath + "/ebook/read?bookId=" + book.getId()
                                           + "&title=" + URLEncoder.encode(book.getTitle(), StandardCharsets.UTF_8)
                                           + "&author=" + URLEncoder.encode(book.getAuthorName(), StandardCharsets.UTF_8)
                                           + "&isbn=" + URLEncoder.encode(book.getIsbn(), StandardCharsets.UTF_8)
                                           + "&chapter=" + URLEncoder.encode("Advanced search result", StandardCharsets.UTF_8)
                                           + "&cover=" + URLEncoder.encode(book.isDigital() ? "emerald" : "teal", StandardCharsets.UTF_8)
                                           + "&progress=8";
                            %>
                                <tr>
                                    <td><%= DashboardViewHelper.escapeHtml(book.getTitle()) %></td>
                                    <td><%= DashboardViewHelper.escapeHtml(book.getCategoryName()) %></td>
                                    <td><%= DashboardViewHelper.escapeHtml(book.getAuthorName()) %></td>
                                    <td><%= DashboardViewHelper.escapeHtml(book.getIsbn()) %></td>
                                    <td><%= DashboardViewHelper.escapeHtml(book.getBarcode()) %></td>
                                    <td><span class="pill <%= tone %>"><%= book.getAvailableQuantity() > 0 ? "Available" : "Reserve" %></span></td>
                                    <td>
                                        <div class="table-actions">
                                            <% if (studentLoggedIn) { %>
                                                <form action="<%= contextPath %>/student/reservations" method="post">
                                                    <input type="hidden" name="bookId" value="<%= book.getId() %>">
                                                    <button class="button-soft button-small" type="submit">Reserve</button>
                                                </form>
                                            <% } %>
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
    </div>

    <script>
        (function () {
            var scanButton = document.getElementById("scanBarcodeButton");
            var barcodeInput = document.getElementById("barcode");
            var barcodeHelp = document.getElementById("barcodeHelp");

            if (!scanButton || !barcodeInput) {
                return;
            }

            scanButton.addEventListener("click", async function () {
                if (!("BarcodeDetector" in window) || !navigator.mediaDevices || !navigator.mediaDevices.getUserMedia) {
                    barcodeHelp.textContent = "Camera barcode scanning is not supported in this browser yet. You can still paste the barcode value manually.";
                    return;
                }

                try {
                    var supportedFormats = await window.BarcodeDetector.getSupportedFormats();
                    var preferredFormat = supportedFormats.indexOf("code_128") >= 0 ? ["code_128"] : supportedFormats;
                    if (!preferredFormat.length) {
                        barcodeHelp.textContent = "This browser did not report any supported barcode formats.";
                        return;
                    }

                    var stream = await navigator.mediaDevices.getUserMedia({ video: { facingMode: "environment" } });
                    var video = document.createElement("video");
                    video.setAttribute("playsinline", "true");
                    video.srcObject = stream;
                    await video.play();

                    barcodeHelp.textContent = "Scanning through the rear camera. Hold the barcode steady for a moment.";
                    var detector = new window.BarcodeDetector({ formats: preferredFormat });
                    var found = false;
                    var startedAt = Date.now();

                    while (!found && Date.now() - startedAt < 10000) {
                        var codes = await detector.detect(video);
                        if (codes && codes.length) {
                            barcodeInput.value = codes[0].rawValue || "";
                            barcodeHelp.textContent = "Barcode scanned successfully. Run search to filter the catalog.";
                            found = true;
                        }
                        await new Promise(function (resolve) { window.setTimeout(resolve, 180); });
                    }

                    stream.getTracks().forEach(function (track) { track.stop(); });
                    if (!found) {
                        barcodeHelp.textContent = "No barcode detected in 10 seconds. Try again or paste the value manually.";
                    }
                } catch (error) {
                    barcodeHelp.textContent = "Camera access failed. Please allow the camera or enter the barcode manually.";
                }
            });
        })();
    </script>
</body>
</html>
