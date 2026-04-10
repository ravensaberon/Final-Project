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
    <title>Upload E-Book | LU Librisync</title>
    <link rel="stylesheet" href="<%= contextPath %>/assets/css/librisync.css">
</head>
<body>
    <div class="page-shell">
        <section class="form-panel">
            <div class="eyebrow">Digital Library</div>
            <h2>Upload an e-book to LU Librisync.</h2>
            <p class="subtitle">Support digital library access and PDF reader integration for students.</p>

            <form class="form-stack" enctype="multipart/form-data">
                <div class="form-grid">
                    <div class="field-group">
                        <label>Book Title</label>
                        <input type="text" placeholder="Enter linked book title">
                    </div>
                    <div class="field-group">
                        <label>ISBN</label>
                        <input type="text" placeholder="Enter ISBN">
                    </div>
                </div>
                <div class="field-group">
                    <label>PDF File</label>
                    <input type="file">
                </div>
                <div class="field-group">
                    <label>Access Notes</label>
                    <textarea placeholder="Any internal digital access notes"></textarea>
                </div>
                <div class="button-row">
                    <button class="button" type="button">Upload E-Book</button>
                    <a class="button-secondary" href="<%= contextPath %>/admin/books">Back to Books</a>
                </div>
            </form>
        </section>
    </div>
</body>
</html>
