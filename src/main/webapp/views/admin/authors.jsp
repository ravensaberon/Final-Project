<%@ page import="com.lulibrisync.model.Author,java.util.List" %>
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
    List<Author> authors = (List<Author>) request.getAttribute("authors");
    Author editAuthor = (Author) request.getAttribute("editAuthor");
    int totalAuthors = request.getAttribute("totalAuthors") == null ? 0 : (Integer) request.getAttribute("totalAuthors");
    int featuredAuthors = request.getAttribute("featuredAuthors") == null ? 0 : (Integer) request.getAttribute("featuredAuthors");
    int authorsWithoutTitles = request.getAttribute("authorsWithoutTitles") == null ? 0 : (Integer) request.getAttribute("authorsWithoutTitles");
    int totalLinkedBooks = request.getAttribute("totalLinkedBooks") == null ? 0 : (Integer) request.getAttribute("totalLinkedBooks");

    String feedbackType = request.getParameter("feedbackType");
    String feedbackMessage = request.getParameter("feedbackMessage");

    if (authors == null) {
        authors = java.util.Collections.emptyList();
    }

    int maxUsage = 1;
    for (Author author : authors) {
        maxUsage = Math.max(maxUsage, author.getBookCount());
    }

    boolean editing = editAuthor != null;
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
            <p>Manage author records so catalog entries stay searchable, readable, and consistent across titles.</p>
            <nav class="nav-list">
                <a href="<%= contextPath %>/admin/dashboard">Dashboard</a>
                <a href="<%= contextPath %>/admin/books">Books</a>
                <a class="active" href="<%= contextPath %>/admin/authors">Authors</a>
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
                <div class="eyebrow">Author CRUD</div>
                <h2 class="section-title">Maintain author profiles for cleaner catalog metadata.</h2>
                <p class="section-copy">
                    Create, edit, and remove author records while keeping track of which names are already linked
                    to books in the collection.
                </p>
                <div class="button-row">
                    <a class="button-secondary" href="<%= contextPath %>/admin/books">Open Books</a>
                    <a class="button-ghost" href="<%= contextPath %>/admin/dashboard">Back to Dashboard</a>
                </div>
            </section>

            <section class="metric-strip" style="margin-bottom:18px;">
                <article class="mini-stat">
                    <strong>Total Authors</strong>
                    <span class="metric"><%= totalAuthors %></span>
                    <span>Author records currently stored in the catalog administration panel.</span>
                </article>
                <article class="mini-stat">
                    <strong>Featured Authors</strong>
                    <span class="metric"><%= featuredAuthors %></span>
                    <span>Authors that already have at least one title in the collection.</span>
                </article>
                <article class="mini-stat">
                    <strong>Unlinked Authors</strong>
                    <span class="metric"><%= authorsWithoutTitles %></span>
                    <span>Records that can be reviewed or cleaned up if they remain unused.</span>
                </article>
                <article class="mini-stat">
                    <strong>Linked Titles</strong>
                    <span class="metric"><%= totalLinkedBooks %></span>
                    <span>Total books that are currently mapped to an author entry.</span>
                </article>
            </section>

            <section class="chart-grid" style="margin-bottom:18px;">
                <article class="content-card">
                    <div class="table-toolbar">
                        <div>
                            <h3 class="section-title"><%= editing ? "Edit Author" : "Create Author" %></h3>
                            <p class="chart-caption">Maintain author identities and optional background notes in one place.</p>
                        </div>
                    </div>

                    <% if (feedbackMessage != null && !feedbackMessage.isBlank()) { %>
                        <div class="alert <%= "success".equals(feedbackType) ? "success" : "error" %>"><%= h(feedbackMessage) %></div>
                    <% } %>

                    <form class="form-stack" action="<%= contextPath %>/admin/authors" method="post">
                        <input type="hidden" name="action" value="<%= editing ? "update" : "create" %>">
                        <% if (editing) { %>
                            <input type="hidden" name="id" value="<%= editAuthor.getId() %>">
                        <% } %>

                        <div class="field-group">
                            <label for="name">Author Name</label>
                            <input id="name" name="name" type="text" maxlength="120" required
                                   value="<%= editing ? h(editAuthor.getName()) : "" %>"
                                   placeholder="Example: Robert C. Martin">
                        </div>

                        <div class="field-group">
                            <label for="bio">Biography or Notes</label>
                            <textarea id="bio" name="bio" placeholder="Short author background, specialization, or metadata note."><%= editing ? h(editAuthor.getBio()) : "" %></textarea>
                        </div>

                        <div class="button-row">
                            <button class="button" type="submit"><%= editing ? "Update Author" : "Save Author" %></button>
                            <% if (editing) { %>
                                <a class="button-secondary" href="<%= contextPath %>/admin/authors">Cancel Edit</a>
                            <% } %>
                        </div>
                    </form>
                </article>

                <article class="chart-card">
                    <div class="chart-header">
                        <div>
                            <h3 class="section-title">Author Coverage</h3>
                            <p class="chart-caption">Quick visual of which author records are already tied to catalog titles.</p>
                        </div>
                    </div>

                    <% if (authors.isEmpty()) { %>
                        <div class="empty-state">
                            <strong>No authors yet</strong>
                            <p>Add author records here to improve book attribution and search quality.</p>
                        </div>
                    <% } else { %>
                        <div class="bar-chart">
                            <% for (Author author : authors) {
                                int percent = author.getBookCount() == 0 ? 6 : (int) Math.round((author.getBookCount() * 100.0) / maxUsage);
                            %>
                                <div class="bar-row">
                                    <div class="bar-meta">
                                        <strong><%= h(author.getName()) %></strong>
                                        <span><%= author.getBookCount() %> titles</span>
                                    </div>
                                    <div class="bar-track">
                                        <div class="bar-fill" style="width:<%= percent %>%;"></div>
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
                        <h3 class="section-title">Author Directory</h3>
                        <p class="chart-caption">Use edit and delete actions directly from the live author table.</p>
                    </div>
                </div>

                <% if (authors.isEmpty()) { %>
                    <div class="empty-state">
                        <strong>Nothing to manage yet</strong>
                        <p>The author directory is empty right now. Add one using the form above.</p>
                    </div>
                <% } else { %>
                    <div class="table-wrap">
                        <table>
                            <thead>
                                <tr>
                                    <th>Author</th>
                                    <th>Bio / Notes</th>
                                    <th>Titles</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% for (Author author : authors) { %>
                                    <tr>
                                        <td><strong><%= h(author.getName()) %></strong></td>
                                        <td><%= author.getBio().isBlank() ? "<span class=\"muted\">No notes yet.</span>" : h(author.getBio()) %></td>
                                        <td><span class="pill neutral"><%= author.getBookCount() %> titles</span></td>
                                        <td>
                                            <div class="table-actions">
                                                <a class="button-outline button-small" href="<%= contextPath %>/admin/authors?edit=<%= author.getId() %>">Edit</a>
                                                <form action="<%= contextPath %>/admin/authors" method="post">
                                                    <input type="hidden" name="action" value="delete">
                                                    <input type="hidden" name="id" value="<%= author.getId() %>">
                                                    <button class="button-danger button-small" type="submit"
                                                            onclick="return confirm('Delete this author? Books using it will become unassigned.');">
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
