<%@ page import="com.lulibrisync.utils.DashboardViewHelper,java.util.List,java.util.Map" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    if (session.getAttribute("user") == null || !"ADMIN".equals(session.getAttribute("role"))) {
        response.sendRedirect(request.getContextPath() + "/views/auth/login.jsp");
        return;
    }

    String contextPath = request.getContextPath();
    Map<String, Object> overview = (Map<String, Object>) request.getAttribute("analyticsOverview");
    List<Map<String, Object>> mostBorrowedBooks = (List<Map<String, Object>>) request.getAttribute("mostBorrowedBooks");
    List<Map<String, Object>> categoryDemand = (List<Map<String, Object>>) request.getAttribute("categoryDemand");
    List<Map<String, Object>> overdueTrend = (List<Map<String, Object>>) request.getAttribute("overdueTrend");
    List<Map<String, Object>> readingHistory = (List<Map<String, Object>>) request.getAttribute("readingHistory");
    List<Map<String, Object>> topReaders = (List<Map<String, Object>>) request.getAttribute("topReaders");
    List<Map<String, Object>> automationQueue = (List<Map<String, Object>>) request.getAttribute("automationQueue");

    if (overview == null || mostBorrowedBooks == null || categoryDemand == null || overdueTrend == null
            || readingHistory == null || topReaders == null || automationQueue == null) {
        response.sendRedirect(contextPath + "/admin/analytics");
        return;
    }

    int overdueRate = DashboardViewHelper.toInt(overview.get("overdueRate"));
    int reservationQueue = DashboardViewHelper.toInt(overview.get("reservationQueue"));
    int pendingReminders = DashboardViewHelper.toInt(overview.get("pendingReminders"));
    int digitalCoverage = DashboardViewHelper.toInt(overview.get("digitalCoverage"));
    int trendWidth = 560;
    int trendHeight = 250;
    int padX = 40;
    int padTop = 28;
    int padBottom = 34;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Analytics Dashboard | LU Librisync</title>
    <link rel="stylesheet" href="<%= contextPath %>/assets/css/librisync.css">
</head>
<body class="dashboard-reference">
    <div class="dashboard-shell">
        <aside class="sidebar">
            <div class="sidebar-brand">
                <div class="sidebar-brand-badge">LU</div>
                <div class="sidebar-brand-copy">
                    <strong>Library MS</strong>
                    <span>Analytics</span>
                </div>
            </div>
            <p>Most borrowed books, overdue rate, reading history, and automation workload from live data.</p>
            <div class="sidebar-section-label">Management</div>
            <nav class="nav-list">
                <a href="<%= contextPath %>/admin/dashboard">Dashboard</a>
                <a href="<%= contextPath %>/admin/books">Books</a>
                <a href="<%= contextPath %>/admin/authors">Authors</a>
                <a href="<%= contextPath %>/admin/categories">Categories</a>
                <a href="<%= contextPath %>/admin/issue">Issue Book</a>
                <a href="<%= contextPath %>/admin/return">Return Book</a>
                <a href="<%= contextPath %>/admin/students">Students</a>
                <a class="active" href="<%= contextPath %>/admin/analytics">Analytics</a>
                <a href="<%= contextPath %>/logout" data-swal-confirm="true" data-swal-title="Log out?" data-swal-text="You will need to sign in again to continue using LU Librisync." data-swal-confirm-text="Yes, log out" data-swal-cancel-text="Stay here" data-swal-icon="?">Logout</a>
            </nav>
            <div class="sidebar-mini-card">
                <strong>Automation visibility</strong>
                <span>Due reminders and reservation-ready notifications are now reflected in the analytics queue.</span>
            </div>
        </aside>

        <main class="content-area">
            <section class="dashboard-topbar">
                <div>
                    <div class="eyebrow">Analytics Dashboard</div>
                    <h2 class="workspace-title">Performance and circulation intelligence</h2>
                    <p class="workspace-copy">
                        This dashboard is now backed by the real library database, so your charts and tables update from
                        actual issue history, overdue records, reservation demand, and queued notifications.
                    </p>
                </div>
            </section>

            <section class="overview-tile-grid">
                <article class="kpi-tile tile-sky">
                    <span class="tile-meta-label">Most Borrowed</span>
                    <strong class="tile-value"><%= DashboardViewHelper.escapeHtml(overview.get("mostBorrowedTitle")) %></strong>
                    <span class="tile-copy">Top-performing book across the recorded issue history.</span>
                    <div class="tile-track"><span data-progress-width="100"></span></div>
                </article>
                <article class="kpi-tile tile-red">
                    <span class="tile-meta-label">Overdue Rate</span>
                    <strong class="tile-value"><%= overdueRate %>%</strong>
                    <span class="tile-copy">Share of all circulation records currently marked overdue.</span>
                    <div class="tile-track"><span data-progress-width="<%= overdueRate %>"></span></div>
                </article>
                <article class="kpi-tile tile-amber">
                    <span class="tile-meta-label">Reservation Queue</span>
                    <strong class="tile-value"><%= reservationQueue %></strong>
                    <span class="tile-copy">Pending and ready reservations waiting for action.</span>
                    <div class="tile-track"><span data-progress-width="<%= Math.min(100, reservationQueue * 10) %>"></span></div>
                </article>
                <article class="kpi-tile tile-teal">
                    <span class="tile-meta-label">Pending Reminders</span>
                    <strong class="tile-value"><%= pendingReminders %></strong>
                    <span class="tile-copy">Queued due reminders and reservation-ready notifications.</span>
                    <div class="tile-track"><span data-progress-width="<%= Math.min(100, pendingReminders * 12) %>"></span></div>
                </article>
                <article class="kpi-tile tile-violet">
                    <span class="tile-meta-label">Digital Coverage</span>
                    <strong class="tile-value"><%= digitalCoverage %>%</strong>
                    <span class="tile-copy">Share of catalog titles already marked for digital access.</span>
                    <div class="tile-track"><span data-progress-width="<%= digitalCoverage %>"></span></div>
                </article>
                <article class="kpi-tile tile-cyan">
                    <span class="tile-meta-label">Unpaid Fine Exposure</span>
                    <strong class="tile-value"><%= String.format(java.util.Locale.US, "%.2f", ((Number) overview.get("totalFineExposure")).doubleValue()) %></strong>
                    <span class="tile-copy">Open fine balance created by automated overdue calculations.</span>
                    <div class="tile-track"><span data-progress-width="<%= ((Number) overview.get("totalFineExposure")).doubleValue() > 0 ? 100 : 0 %>"></span></div>
                </article>
            </section>

            <section class="panel-grid">
                <article class="dashboard-panel">
                    <div class="panel-head">
                        <div>
                            <h3>Overdue Trend</h3>
                            <p>Monthly overdue volume from the last six months.</p>
                        </div>
                        <span class="panel-badge">Trend view</span>
                    </div>

                    <div class="trend-chart">
                        <svg viewBox="0 0 <%= trendWidth %> <%= trendHeight %>" aria-label="Overdue trend chart">
                            <line class="chart-grid-line" x1="<%= padX %>" y1="<%= trendHeight - padBottom %>" x2="<%= trendWidth - padX %>" y2="<%= trendHeight - padBottom %>"></line>
                            <polyline class="trend-area" fill="rgba(182, 69, 61, 0.18)" points="<%= DashboardViewHelper.areaPoints(overdueTrend, trendWidth, trendHeight, padX, padTop, padBottom) %>"></polyline>
                            <polyline class="trend-line" stroke="#b6453d" points="<%= DashboardViewHelper.linePoints(overdueTrend, trendWidth, trendHeight, padX, padTop, padBottom) %>"></polyline>
                            <% for (int i = 0; i < overdueTrend.size(); i++) {
                                   Map<String, Object> point = overdueTrend.get(i);
                                   int value = DashboardViewHelper.toInt(point.get("value"));
                                   double x = DashboardViewHelper.chartX(i, overdueTrend.size(), trendWidth, padX);
                                   double y = DashboardViewHelper.chartY(value, Math.max(1, DashboardViewHelper.maxValue(overdueTrend)), trendHeight, padTop, padBottom);
                            %>
                                <circle class="trend-point" cx="<%= DashboardViewHelper.fmt(x) %>" cy="<%= DashboardViewHelper.fmt(y) %>" r="6" style="stroke:#b6453d"></circle>
                                <text class="chart-value-label" x="<%= DashboardViewHelper.fmt(x) %>" y="<%= DashboardViewHelper.fmt(y - 12) %>" text-anchor="middle"><%= value %></text>
                                <text class="chart-axis-label" x="<%= DashboardViewHelper.fmt(x) %>" y="<%= trendHeight - 10 %>" text-anchor="middle"><%= DashboardViewHelper.escapeHtml(point.get("label")) %></text>
                            <% } %>
                        </svg>
                    </div>
                </article>

                <div class="stack-grid">
                    <article class="dashboard-panel">
                        <div class="panel-head">
                            <div>
                                <h3>Most Borrowed Books</h3>
                                <p>Titles with the strongest circulation demand.</p>
                            </div>
                        </div>
                        <div class="progress-list">
                            <% int mostBorrowedMax = Math.max(1, DashboardViewHelper.maxValue(mostBorrowedBooks));
                               for (Map<String, Object> row : mostBorrowedBooks) {
                                   int value = DashboardViewHelper.toInt(row.get("value"));
                            %>
                                <div class="progress-item">
                                    <div class="progress-meta">
                                        <strong><%= DashboardViewHelper.escapeHtml(row.get("label")) %></strong>
                                        <span><%= value %> issues</span>
                                    </div>
                                    <div class="progress-track">
                                        <span class="palette-0" data-progress-width="<%= DashboardViewHelper.percentOf(value, mostBorrowedMax) %>"></span>
                                    </div>
                                </div>
                            <% } %>
                        </div>
                    </article>

                    <article class="dashboard-panel">
                        <div class="panel-head">
                            <div>
                                <h3>Top Student Readers</h3>
                                <p>Students with the most recorded borrowing activity.</p>
                            </div>
                        </div>
                        <div class="progress-list">
                            <% int topReaderMax = Math.max(1, DashboardViewHelper.maxValue(topReaders));
                               for (Map<String, Object> row : topReaders) {
                                   int value = DashboardViewHelper.toInt(row.get("value"));
                            %>
                                <div class="progress-item">
                                    <div class="progress-meta">
                                        <strong><%= DashboardViewHelper.escapeHtml(row.get("label")) %></strong>
                                        <span><%= value %> borrowed</span>
                                    </div>
                                    <div class="progress-track">
                                        <span class="palette-1" data-progress-width="<%= DashboardViewHelper.percentOf(value, topReaderMax) %>"></span>
                                    </div>
                                </div>
                            <% } %>
                        </div>
                    </article>
                </div>
            </section>

            <section class="panel-grid">
                <article class="dashboard-panel">
                    <div class="panel-head">
                        <div>
                            <h3>Category Demand</h3>
                            <p>Borrowing interest grouped by catalog category.</p>
                        </div>
                    </div>
                    <div class="bar-chart">
                        <% int categoryMax = Math.max(1, DashboardViewHelper.maxValue(categoryDemand));
                           int paletteIndex = 0;
                           for (Map<String, Object> row : categoryDemand) {
                               int value = DashboardViewHelper.toInt(row.get("value"));
                        %>
                            <div class="bar-row">
                                <div class="bar-meta">
                                    <strong><%= DashboardViewHelper.escapeHtml(row.get("label")) %></strong>
                                    <span><%= value %> loans</span>
                                </div>
                                <div class="bar-track">
                                    <div class="bar-fill palette-<%= paletteIndex % 6 %>" data-progress-width="<%= DashboardViewHelper.percentOf(value, categoryMax) %>"></div>
                                </div>
                            </div>
                        <% paletteIndex++; } %>
                    </div>
                </article>

                <article class="dashboard-panel">
                    <div class="panel-head">
                        <div>
                            <h3>Automation Queue</h3>
                            <p>Reminder and reservation notifications waiting in the system.</p>
                        </div>
                    </div>
                    <% if (automationQueue.isEmpty()) { %>
                        <div class="empty-state">
                            <strong>No queued automations</strong>
                            <p>Due reminders and reservation-ready notifications will appear here once they are generated.</p>
                        </div>
                    <% } else { %>
                        <div class="activity-stack">
                            <% for (Map<String, Object> row : automationQueue) { %>
                                <div class="activity-item">
                                    <div class="status-inline <%= DashboardViewHelper.escapeHtml(row.get("tone")) %>">
                                        <strong><%= DashboardViewHelper.escapeHtml(row.get("type")) %></strong>
                                    </div>
                                    <p><%= DashboardViewHelper.escapeHtml(row.get("subject")) %></p>
                                    <span class="meta"><%= DashboardViewHelper.escapeHtml(row.get("status")) %> | <%= DashboardViewHelper.escapeHtml(row.get("scheduledAt")) %></span>
                                </div>
                            <% } %>
                        </div>
                    <% } %>
                </article>
            </section>

            <section class="dashboard-panel">
                <div class="panel-head">
                    <div>
                        <h3>Student Reading History</h3>
                        <p>Recent circulation history sourced from the reporting view.</p>
                    </div>
                    <span class="panel-badge"><%= readingHistory.size() %> rows</span>
                </div>

                <% if (readingHistory.isEmpty()) { %>
                    <div class="empty-state">
                        <strong>No reading history yet</strong>
                        <p>The reporting table will fill in automatically as students borrow and return books.</p>
                    </div>
                <% } else { %>
                    <div class="table-wrap">
                        <table class="dashboard-table">
                            <thead>
                                <tr>
                                    <th>Student</th>
                                    <th>Book</th>
                                    <th>Issue Date</th>
                                    <th>Due Date</th>
                                    <th>Return Date</th>
                                    <th>Status</th>
                                    <th>Fine</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% for (Map<String, Object> row : readingHistory) {
                                       String status = String.valueOf(row.get("status"));
                                       String tone = "OVERDUE".equalsIgnoreCase(status)
                                               ? "danger"
                                               : ("RETURNED".equalsIgnoreCase(status) ? "neutral" : "success");
                                %>
                                    <tr>
                                        <td>
                                            <strong><%= DashboardViewHelper.escapeHtml(row.get("studentName")) %></strong><br>
                                            <span class="subtle-text"><%= DashboardViewHelper.escapeHtml(row.get("studentId")) %></span>
                                        </td>
                                        <td><%= DashboardViewHelper.escapeHtml(row.get("bookTitle")) %></td>
                                        <td><%= DashboardViewHelper.escapeHtml(row.get("issueDate")) %></td>
                                        <td><%= DashboardViewHelper.escapeHtml(row.get("dueDate")) %></td>
                                        <td><%= DashboardViewHelper.escapeHtml(row.get("returnDate")) %></td>
                                        <td><span class="pill <%= tone %>"><%= DashboardViewHelper.escapeHtml(status) %></span></td>
                                        <td><%= String.format(java.util.Locale.US, "%.2f", ((Number) row.get("fineAmount")).doubleValue()) %></td>
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
