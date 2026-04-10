<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Advanced Search | LU Librisync</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/librisync.css">
</head>
<body>
    <div class="page-shell">
        <section class="form-panel">
            <div class="eyebrow">Advanced Search</div>
            <h2>Search the LU Librisync collection.</h2>
            <p class="subtitle">Filter by category, author, availability, ISBN, and barcode.</p>

            <form class="form-stack">
                <div class="form-grid">
                    <div class="field-group">
                        <label>Keyword</label>
                        <input type="text" placeholder="Enter title or keyword">
                    </div>
                    <div class="field-group">
                        <label>Author</label>
                        <input type="text" placeholder="Enter author">
                    </div>
                </div>
                <div class="form-grid">
                    <div class="field-group">
                        <label>Category</label>
                        <input type="text" placeholder="Enter category">
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
                        <label>ISBN Search</label>
                        <input type="text" placeholder="Search by ISBN">
                    </div>
                    <div class="field-group">
                        <label>Barcode Scanning Input</label>
                        <input type="text" placeholder="Paste or scan barcode">
                    </div>
                </div>
                <div class="button-row">
                    <button class="button" type="button">Run Search</button>
                    <a class="button-secondary" href="<%= request.getContextPath() %>/student/books">Back to Books</a>
                </div>
            </form>
        </section>

        <section class="table-card" style="margin:24px;">
            <h3 class="section-title">Search Results Snapshot</h3>
            <div class="table-wrap">
                <table>
                    <thead>
                        <tr>
                            <th>Title</th>
                            <th>Category</th>
                            <th>Author</th>
                            <th>ISBN</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td>Clean Code</td>
                            <td>Computer Science</td>
                            <td>Robert C. Martin</td>
                            <td>9780132350884</td>
                            <td><span class="pill success">Available</span></td>
                        </tr>
                        <tr>
                            <td>The Alchemist</td>
                            <td>Literature</td>
                            <td>Paulo Coelho</td>
                            <td>9780062315007</td>
                            <td><span class="pill warning">Reserved</span></td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </section>
    </div>
</body>
</html>
