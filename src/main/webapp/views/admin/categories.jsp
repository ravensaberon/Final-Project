<%@ page import="com.lulibrisync.model.Category,java.util.List,java.util.Locale,com.lulibrisync.utils.DashboardViewHelper" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    if (session.getAttribute("user") == null || !"ADMIN".equals(session.getAttribute("role"))) {
        response.sendRedirect(request.getContextPath() + "/views/auth/login.jsp");
        return;
    }

    String contextPath = request.getContextPath();
    List<Category> categories = (List<Category>) request.getAttribute("categories");
    Category editCategory = (Category) request.getAttribute("editCategory");
    int totalCategories = request.getAttribute("totalCategories") == null ? 0 : (Integer) request.getAttribute("totalCategories");
    int activeCategories = request.getAttribute("activeCategories") == null ? 0 : (Integer) request.getAttribute("activeCategories");
    int idleCategories = request.getAttribute("idleCategories") == null ? 0 : (Integer) request.getAttribute("idleCategories");
    int totalAssignedBooks = request.getAttribute("totalAssignedBooks") == null ? 0 : (Integer) request.getAttribute("totalAssignedBooks");

    String feedbackType = request.getParameter("feedbackType");
    String feedbackMessage = request.getParameter("feedbackMessage");

    if (categories == null) {
        categories = java.util.Collections.emptyList();
    }

    int maxUsage = 1;
    for (Category category : categories) {
        maxUsage = Math.max(maxUsage, category.getBookCount());
    }

    boolean editing = editCategory != null;
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
            <p>Shape the catalog with better category structure, cleaner search filters, and smarter reporting.</p>
            <nav class="nav-list">
                <a href="<%= contextPath %>/admin/dashboard">Dashboard</a>
                <a href="<%= contextPath %>/admin/books">Books</a>
                <a href="<%= contextPath %>/admin/authors">Authors</a>
                <a class="active" href="<%= contextPath %>/admin/categories">Categories</a>
                <a href="<%= contextPath %>/admin/issue">Issue Book</a>
                <a href="<%= contextPath %>/admin/return">Return Book</a>
                <a href="<%= contextPath %>/admin/students">Students</a>
                <a href="<%= contextPath %>/admin/analytics">Analytics</a>
                <a href="<%= contextPath %>/logout" data-swal-confirm="true" data-swal-title="Log out?" data-swal-text="You will need to sign in again to continue using LU Librisync." data-swal-confirm-text="Yes, log out" data-swal-cancel-text="Stay here" data-swal-icon="?">Logout</a>
            </nav>
        </aside>

        <main class="content-area">
            <section class="hero-card content-card" style="margin-bottom:18px;">
                <div class="eyebrow">Category CRUD</div>
                <h2 class="section-title">Manage catalog categories with live usage visibility.</h2>
                <p class="section-copy">
                    Create new categories, edit descriptions, and remove unused entries while keeping an eye on
                    how much of the collection is mapped to each category.
                </p>
                <div class="button-row">
                    <a class="button-secondary" href="<%= contextPath %>/admin/books">Open Books</a>
                    <a class="button-ghost" href="<%= contextPath %>/admin/dashboard">Back to Dashboard</a>
                </div>
            </section>

            <section class="metric-strip" style="margin-bottom:18px;">
                <article class="mini-stat">
                    <strong>Total Categories</strong>
                    <span class="metric"><%= totalCategories %></span>
                    <span>All catalog labels currently available to the admin team.</span>
                </article>
                <article class="mini-stat">
                    <strong>Active Categories</strong>
                    <span class="metric"><%= activeCategories %></span>
                    <span>Categories that already have at least one book assigned.</span>
                </article>
                <article class="mini-stat">
                    <strong>Idle Categories</strong>
                    <span class="metric"><%= idleCategories %></span>
                    <span>Useful for cleanup if a label is no longer needed.</span>
                </article>
                <article class="mini-stat">
                    <strong>Mapped Titles</strong>
                    <span class="metric"><%= totalAssignedBooks %></span>
                    <span>Total books currently attached to category records.</span>
                </article>
            </section>

            <section class="chart-grid" style="margin-bottom:18px;">
                <article class="content-card">
                    <div class="table-toolbar">
                        <div>
                            <h3 class="section-title"><%= editing ? "Edit Category" : "Create Category" %></h3>
                            <p class="chart-caption">Use this form to keep your category list clean and consistent.</p>
                        </div>
                    </div>

                    <% if (feedbackMessage != null && !feedbackMessage.isBlank()) { %>
                        <div class="alert <%= "success".equals(feedbackType) ? "success" : "error" %>"><%= DashboardViewHelper.escapeHtml(feedbackMessage) %></div>
                    <% } %>

                    <form class="form-stack" action="<%= contextPath %>/admin/categories" method="post">
                        <input type="hidden" name="action" value="<%= editing ? "update" : "create" %>">
                        <% if (editing) { %>
                            <input type="hidden" name="id" value="<%= editCategory.getId() %>">
                        <% } %>

                        <div class="field-group">
                            <label for="name">Category Name</label>
                            <input id="name" name="name" type="text" maxlength="120" required
                                   value="<%= editing ? DashboardViewHelper.escapeHtml(editCategory.getName()) : "" %>"
                                   placeholder="Example: Computer Science">
                        </div>

                        <div class="field-group">
                            <label for="description">Description</label>
                            <textarea id="description" name="description" placeholder="Explain what kind of titles belong here."><%= editing ? DashboardViewHelper.escapeHtml(editCategory.getDescription()) : "" %></textarea>
                        </div>

                        <div class="button-row">
                            <button class="button" type="submit"><%= editing ? "Update Category" : "Save Category" %></button>
                            <% if (editing) { %>
                                <a class="button-secondary" href="<%= contextPath %>/admin/categories">Cancel Edit</a>
                            <% } %>
                        </div>
                    </form>
                </article>

                <article class="chart-card">
                    <div class="chart-header">
                        <div>
                            <h3 class="section-title">Category Usage Snapshot</h3>
                            <p class="chart-caption">The busiest categories based on currently assigned titles.</p>
                        </div>
                    </div>

                    <% if (categories.isEmpty()) { %>
                        <div class="empty-state">
                            <strong>No categories yet</strong>
                            <p>Create your first category to start organizing the library collection.</p>
                        </div>
                    <% } else { %>
                        <div class="bar-chart">
                            <% for (Category category : categories) {
                                int percent = category.getBookCount() == 0 ? 6 : (int) Math.round((category.getBookCount() * 100.0) / maxUsage);
                            %>
                                <div class="bar-row">
                                    <div class="bar-meta">
                                        <strong><%= DashboardViewHelper.escapeHtml(category.getName()) %></strong>
                                        <span><%= category.getBookCount() %> titles</span>
                                    </div>
                                    <div class="bar-track">
                                        <div class="bar-fill" data-progress-width="<%= percent %>"></div>
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
                        <h3 class="section-title">Category Directory</h3>
                        <p class="chart-caption">Edit or remove categories directly from the catalog directory.</p>
                    </div>
                </div>

                <% if (categories.isEmpty()) { %>
                    <div class="empty-state">
                        <strong>Nothing to manage yet</strong>
                        <p>Your category directory is still empty. Add one using the form above.</p>
                    </div>
                <% } else { %>
                    <div class="table-wrap">
                        <table>
                            <thead>
                                <tr>
                                    <th>Category</th>
                                    <th>Description</th>
                                    <th>Titles</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% for (Category category : categories) { %>
                                    <tr>
                                        <td><strong><%= DashboardViewHelper.escapeHtml(category.getName()) %></strong></td>
                                        <td><%= category.getDescription().isBlank() ? "<span class=\"muted\">No description yet.</span>" : DashboardViewHelper.escapeHtml(category.getDescription()) %></td>
                                        <td><span class="pill neutral"><%= category.getBookCount() %> titles</span></td>
                                        <td>
                                            <div class="table-actions">
                                                <a class="button-outline button-small" href="<%= contextPath %>/admin/categories?edit=<%= category.getId() %>">Edit</a>
                                                <form action="<%= contextPath %>/admin/categories" method="post">
                                                    <input type="hidden" name="action" value="delete">
                                                    <input type="hidden" name="id" value="<%= category.getId() %>">
                                                    <button class="button-danger button-small" type="submit"
                                                            onclick="return confirm('Delete this category? Books using it will become uncategorized.');">
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
    <script src="<%= contextPath %>/assets/js/progress-width.js"></script>
</body>
</html>
