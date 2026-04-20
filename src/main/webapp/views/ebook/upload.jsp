<%@ page import="com.lulibrisync.model.Book,com.lulibrisync.utils.DashboardViewHelper,java.util.List" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    if (session.getAttribute("user") == null || !"ADMIN".equals(session.getAttribute("role"))) {
        response.sendRedirect(request.getContextPath() + "/views/auth/login.jsp");
        return;
    }

    String contextPath = request.getContextPath();
    List<Book> ebookBooks = (List<Book>) request.getAttribute("ebookBooks");
    if (ebookBooks == null) {
        response.sendRedirect(contextPath + "/ebook/upload");
        return;
    }

    String success = request.getParameter("success");
    String error = request.getParameter("error");
    long selectedBookId = 0L;
    try {
        selectedBookId = Long.parseLong(request.getParameter("book"));
    } catch (Exception ignored) {
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Upload E-Book | LU Librisync</title>
    <link rel="stylesheet" href="<%= contextPath %>/assets/css/librisync.css">
</head>
<body>
    <div class="page-shell">
        <section class="form-panel">
            <div class="eyebrow">Digital Library</div>
            <h2>Upload an e-book to LU Librisync.</h2>
            <p class="subtitle">Attach a PDF to a catalog book so students can open it in the built-in digital reader.</p>

            <% if ("uploaded".equalsIgnoreCase(success)) { %>
                <div class="alert success">
                    PDF uploaded successfully. The selected title is now marked for digital access in the catalog.
                </div>
            <% } else if ("missing".equalsIgnoreCase(error)) { %>
                <div class="alert warning">Choose a book and PDF file before uploading.</div>
            <% } else if ("book".equalsIgnoreCase(error)) { %>
                <div class="alert warning">That book could not be found anymore. Refresh the page and try again.</div>
            <% } else if ("server".equalsIgnoreCase(error)) { %>
                <div class="alert error">The system could not upload the PDF right now. Please try again.</div>
            <% } %>

            <form class="form-stack" action="<%= contextPath %>/ebook/upload" method="post" enctype="multipart/form-data">
                <div class="field-group">
                    <label for="bookId">Linked Book Title</label>
                    <select id="bookId" name="bookId" required>
                        <option value="">Select a catalog title</option>
                        <% for (Book book : ebookBooks) { %>
                            <option value="<%= book.getId() %>" <%= selectedBookId == book.getId() ? "selected" : "" %>>
                                <%= DashboardViewHelper.escapeHtml(book.getTitle()) %> - <%= DashboardViewHelper.escapeHtml(book.getIsbn()) %>
                            </option>
                        <% } %>
                    </select>
                </div>
                <div class="form-grid">
                    <div class="field-group">
                        <label for="pdfFile">PDF File</label>
                        <input id="pdfFile" name="pdfFile" type="file" accept="application/pdf" required>
                        <p class="field-help">Only PDF files are supported in the current digital reader flow.</p>
                    </div>
                    <div class="field-group">
                        <label>Reader Availability</label>
                        <input type="text" value="After upload, the title becomes available in /ebook/read and the student catalog." readonly>
                    </div>
                </div>
                <div class="button-row">
                    <button class="button" type="submit">Upload E-Book</button>
                    <a class="button-secondary" href="<%= contextPath %>/admin/books">Back to Books</a>
                    <a class="button-ghost" href="<%= contextPath %>/admin/analytics">View Analytics</a>
                </div>
            </form>
        </section>
    </div>
</body>
</html>
