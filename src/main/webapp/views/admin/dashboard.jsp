<%@ page import="java.util.List,java.util.Map,java.util.Locale" %>
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

    private String dash(int percent) {
        double circumference = 452.39d;
        double dash = Math.max(0d, Math.min(100d, percent)) * circumference / 100d;
        return String.format(Locale.US, "%.2f 999", dash);
    }

    private int n(Object value) {
        if (value == null) {
            return 0;
        }
        if (value instanceof Number) {
            return ((Number) value).intValue();
        }
        try {
            return Integer.parseInt(String.valueOf(value));
        } catch (NumberFormatException ex) {
            return 0;
        }
    }

    private int maxValue(List<Map<String, Object>> rows) {
        int max = 0;
        if (rows == null) {
            return max;
        }
        for (Map<String, Object> row : rows) {
            max = Math.max(max, n(row.get("value")));
        }
        return max;
    }

    private int percentOf(int value, int total) {
        if (total <= 0) {
            return 0;
        }
        return (int) Math.round((value * 100.0d) / total);
    }

    private double chartX(int index, int count, int width, int padX) {
        if (count <= 1) {
            return width / 2.0d;
        }
        double usableWidth = width - (padX * 2.0d);
        return padX + ((usableWidth * index) / (count - 1.0d));
    }

    private double chartY(int value, int max, int height, int padTop, int padBottom) {
        double usableHeight = height - padTop - padBottom;
        if (max <= 0) {
            return height - padBottom;
        }
        return padTop + usableHeight - ((value * usableHeight) / max);
    }

    private String fmt(double value) {
        return String.format(Locale.US, "%.2f", value);
    }

    private String linePoints(List<Map<String, Object>> rows, int width, int height, int padX, int padTop, int padBottom) {
        if (rows == null || rows.isEmpty()) {
            return "";
        }

        int max = Math.max(1, maxValue(rows));
        StringBuilder builder = new StringBuilder();
        for (int i = 0; i < rows.size(); i++) {
            if (i > 0) {
                builder.append(' ');
            }
            int value = n(rows.get(i).get("value"));
            builder.append(fmt(chartX(i, rows.size(), width, padX)))
                    .append(',')
                    .append(fmt(chartY(value, max, height, padTop, padBottom)));
        }
        return builder.toString();
    }

    private String areaPoints(List<Map<String, Object>> rows, int width, int height, int padX, int padTop, int padBottom) {
        if (rows == null || rows.isEmpty()) {
            return "";
        }

        double baseline = height - padBottom;
        StringBuilder builder = new StringBuilder();
        builder.append(fmt(chartX(0, rows.size(), width, padX)))
                .append(',')
                .append(fmt(baseline))
                .append(' ')
                .append(linePoints(rows, width, height, padX, padTop, padBottom))
                .append(' ')
                .append(fmt(chartX(rows.size() - 1, rows.size(), width, padX)))
                .append(',')
                .append(fmt(baseline));
        return builder.toString();
    }
%>
<%
    if (session.getAttribute("user") == null || !"ADMIN".equals(session.getAttribute("role"))) {
        response.sendRedirect(request.getContextPath() + "/views/auth/login.jsp");
        return;
    }

    String contextPath = request.getContextPath();
    int totalBooks = request.getAttribute("totalBooks") == null ? 0 : (Integer) request.getAttribute("totalBooks");
    int totalStudents = request.getAttribute("totalStudents") == null ? 0 : (Integer) request.getAttribute("totalStudents");
    int issuedBooks = request.getAttribute("issuedBooks") == null ? 0 : (Integer) request.getAttribute("issuedBooks");
    int overdueBooks = request.getAttribute("overdueBooks") == null ? 0 : (Integer) request.getAttribute("overdueBooks");
    int reservationCount = request.getAttribute("reservationCount") == null ? 0 : (Integer) request.getAttribute("reservationCount");
    int digitalTitles = request.getAttribute("digitalTitles") == null ? 0 : (Integer) request.getAttribute("digitalTitles");
    int totalCopies = request.getAttribute("totalCopies") == null ? 0 : (Integer) request.getAttribute("totalCopies");
    int onTrackPercent = request.getAttribute("onTrackPercent") == null ? 100 : (Integer) request.getAttribute("onTrackPercent");
    int digitalCoverage = request.getAttribute("digitalCoverage") == null ? 0 : (Integer) request.getAttribute("digitalCoverage");

    List<Map<String, Object>> categoryMix = (List<Map<String, Object>>) request.getAttribute("categoryMix");
    List<Map<String, Object>> circulationTrend = (List<Map<String, Object>>) request.getAttribute("circulationTrend");
    List<Map<String, Object>> statusBreakdown = (List<Map<String, Object>>) request.getAttribute("statusBreakdown");
    List<Map<String, Object>> recentActivity = (List<Map<String, Object>>) request.getAttribute("recentActivity");
    List<Map<String, Object>> lowStockBooks = (List<Map<String, Object>>) request.getAttribute("lowStockBooks");
    List<Map<String, Object>> reservationPressure = (List<Map<String, Object>>) request.getAttribute("reservationPressure");

    if (categoryMix == null) categoryMix = java.util.Collections.emptyList();
    if (circulationTrend == null) circulationTrend = java.util.Collections.emptyList();
    if (statusBreakdown == null) statusBreakdown = java.util.Collections.emptyList();
    if (recentActivity == null) recentActivity = java.util.Collections.emptyList();
    if (lowStockBooks == null) lowStockBooks = java.util.Collections.emptyList();
    if (reservationPressure == null) reservationPressure = java.util.Collections.emptyList();

    int metricScale = Math.max(
            1,
            Math.max(
                    Math.max(totalBooks, totalStudents),
                    Math.max(Math.max(issuedBooks, overdueBooks), Math.max(reservationCount, digitalTitles))
            )
    );
    int circulationScale = Math.max(1, maxValue(circulationTrend));
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard | LU Librisync</title>
    <link rel="stylesheet" href="<%= contextPath %>/assets/css/librisync.css">
</head>
<body class="dashboard-reference">
    <div class="dashboard-shell">
        <aside class="sidebar">
            <div class="sidebar-brand">
                <div class="sidebar-brand-badge">LU</div>
                <div class="sidebar-brand-copy">
                    <strong>Library MS</strong>
                    <span>Admin workspace</span>
                </div>
            </div>
            <p>Reference-inspired control panel for circulation, stock health, and student demand.</p>
            <div class="sidebar-section-label">Management</div>
            <nav class="nav-list">
                <a class="active" href="<%= contextPath %>/admin/dashboard">Dashboard</a>
                <a href="<%= contextPath %>/admin/books">Books</a>
                <a href="<%= contextPath %>/admin/authors">Authors</a>
                <a href="<%= contextPath %>/admin/categories">Categories</a>
                <a href="<%= contextPath %>/admin/issue">Issue Book</a>
                <a href="<%= contextPath %>/admin/return">Return Book</a>
                <a href="<%= contextPath %>/admin/students">Students</a>
                <a href="<%= contextPath %>/admin/analytics">Analytics</a>
                <a href="<%= contextPath %>/views/auth/change-password.jsp">Change Password</a>
                <a href="<%= contextPath %>/logout" data-swal-confirm="true" data-swal-title="Log out?" data-swal-text="You will need to sign in again to continue using LU Librisync." data-swal-confirm-text="Yes, log out" data-swal-cancel-text="Stay here" data-swal-icon="?">Logout</a>
            </nav>
            <div class="sidebar-mini-card">
                <strong>Service health</strong>
                <span><%= onTrackPercent %>% of active loans are still on time.</span>
                <span><%= reservationCount %> reservation requests need queue visibility.</span>
            </div>
        </aside>

        <main class="content-area">
            <section class="dashboard-topbar">
                <div>
                    <div class="eyebrow">Library Dashboard</div>
                    <h2 class="workspace-title">Library Management Dashboard</h2>
                    <p class="workspace-copy">
                        A more visual operations board for monitoring catalog scale, recent circulation, category demand,
                        and alert-heavy areas without relying on long text blocks.
                    </p>
                </div>
                <div class="dashboard-toolbar">
                    <div class="search-prompt">Search books, members, or activity panels</div>
                    <div class="status-chip">Live Library Data</div>
                </div>
            </section>

            <section class="dashboard-banner">
                <article class="banner-primary">
                    <div class="banner-head">
                        <div>
                            <h3 class="section-title">Operations Snapshot</h3>
                            <p>Use this zone to scan collection volume, student coverage, and digital readiness at a glance.</p>
                        </div>
                        <span class="panel-badge"><%= totalCopies %> tracked copies</span>
                    </div>
                    <div class="banner-stats">
                        <div class="banner-stat">
                            <strong><%= totalBooks %></strong>
                            <span>Total catalog titles</span>
                        </div>
                        <div class="banner-stat">
                            <strong><%= totalStudents %></strong>
                            <span>Active student accounts</span>
                        </div>
                        <div class="banner-stat">
                            <strong><%= digitalCoverage %>%</strong>
                            <span>Digital shelf coverage</span>
                        </div>
                    </div>
                </article>
                <article class="banner-secondary">
                    <span class="tile-meta-label">Today's Focus</span>
                    <h3 style="margin:14px 0 8px;font-size:1.35rem;">Action priorities</h3>
                    <p>These are the pressure points that need the fastest admin attention today.</p>
                    <ul>
                        <li><%= overdueBooks %> overdue records currently need follow-up.</li>
                        <li><%= reservationCount %> reservations are building up in the queue.</li>
                        <li><%= digitalTitles %> titles are already ready for digital access.</li>
                    </ul>
                </article>
            </section>

            <section class="overview-tile-grid">
                <article class="kpi-tile tile-sky">
                    <span class="tile-meta-label">Catalog</span>
                    <strong class="tile-value"><%= totalBooks %></strong>
                    <span class="tile-copy">Total titles indexed in the library collection.</span>
                    <div class="tile-track"><span style="width:<%= percentOf(totalBooks, metricScale) %>%;"></span></div>
                </article>
                <article class="kpi-tile tile-teal">
                    <span class="tile-meta-label">Students</span>
                    <strong class="tile-value"><%= totalStudents %></strong>
                    <span class="tile-copy">Registered student members in the system.</span>
                    <div class="tile-track"><span style="width:<%= percentOf(totalStudents, metricScale) %>%;"></span></div>
                </article>
                <article class="kpi-tile tile-amber">
                    <span class="tile-meta-label">Issued</span>
                    <strong class="tile-value"><%= issuedBooks %></strong>
                    <span class="tile-copy">Books currently moving through active circulation.</span>
                    <div class="tile-track"><span style="width:<%= percentOf(issuedBooks, metricScale) %>%;"></span></div>
                </article>
                <article class="kpi-tile tile-violet">
                    <span class="tile-meta-label">Reservations</span>
                    <strong class="tile-value"><%= reservationCount %></strong>
                    <span class="tile-copy">Students waiting on books already in demand.</span>
                    <div class="tile-track"><span style="width:<%= percentOf(reservationCount, metricScale) %>%;"></span></div>
                </article>
                <article class="kpi-tile tile-cyan">
                    <span class="tile-meta-label">Digital Shelf</span>
                    <strong class="tile-value"><%= digitalTitles %></strong>
                    <span class="tile-copy">Titles available for digital reading flow.</span>
                    <div class="tile-track"><span style="width:<%= percentOf(digitalTitles, metricScale) %>%;"></span></div>
                </article>
                <article class="kpi-tile tile-red">
                    <span class="tile-meta-label">Overdue</span>
                    <strong class="tile-value"><%= overdueBooks %></strong>
                    <span class="tile-copy">Loans beyond due date and needing direct intervention.</span>
                    <div class="tile-track"><span style="width:<%= percentOf(overdueBooks, metricScale) %>%;"></span></div>
                </article>
            </section>

            <section class="panel-grid">
                <article class="dashboard-panel">
                    <div class="panel-head">
                        <div>
                            <h3>Recent Transactions</h3>
                            <p>Latest borrowing movement across the system.</p>
                        </div>
                        <span class="panel-badge">Latest 6</span>
                    </div>
                    <% if (recentActivity.isEmpty()) { %>
                        <div class="empty-state">
                            <strong>No recent activity</strong>
                            <p>Issue and return transactions will appear here once circulation starts moving.</p>
                        </div>
                    <% } else { %>
                        <div class="table-wrap">
                            <table class="dashboard-table">
                                <thead>
                                    <tr>
                                        <th>Student</th>
                                        <th>ID</th>
                                        <th>Book</th>
                                        <th>Status</th>
                                        <th>Date</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% for (Map<String, Object> row : recentActivity) { %>
                                        <tr>
                                            <td><%= h(row.get("student")) %></td>
                                            <td><%= h(row.get("studentId")) %></td>
                                            <td><%= h(row.get("book")) %></td>
                                            <td><span class="pill <%= h(row.get("tone")) %>"><%= h(row.get("status")) %></span></td>
                                            <td><%= h(row.get("dateLabel")) %></td>
                                        </tr>
                                    <% } %>
                                </tbody>
                            </table>
                        </div>
                    <% } %>
                </article>

                <div class="stack-grid">
                    <article class="dashboard-panel">
                        <div class="panel-head">
                            <div>
                                <h3>Book Categories</h3>
                                <p>Visual distribution of titles by catalog category.</p>
                            </div>
                            <span class="panel-badge">Top 6</span>
                        </div>
                        <% if (categoryMix.isEmpty()) { %>
                            <div class="empty-state">
                                <strong>No category data yet</strong>
                                <p>Add categories and books to start seeing the category mix here.</p>
                            </div>
                        <% } else { %>
                            <div class="progress-list">
                                <% for (int i = 0; i < categoryMix.size(); i++) {
                                       Map<String, Object> row = categoryMix.get(i);
                                %>
                                    <div class="progress-item">
                                        <div class="progress-meta">
                                            <strong><%= h(row.get("label")) %></strong>
                                            <span><%= row.get("value") %> titles</span>
                                        </div>
                                        <div class="progress-track">
                                            <span class="palette-<%= i % 6 %>" style="width:<%= row.get("percent") %>%;"></span>
                                        </div>
                                    </div>
                                <% } %>
                            </div>
                        <% } %>
                    </article>

                    <article class="dashboard-panel">
                        <div class="panel-head">
                            <div>
                                <h3>Circulation Health</h3>
                                <p>How many active loans remain healthy versus late.</p>
                            </div>
                            <span class="panel-badge"><%= onTrackPercent %>% on track</span>
                        </div>
                        <div class="donut-layout">
                            <div class="donut-ring">
                                <svg viewBox="0 0 180 180" aria-hidden="true">
                                    <circle class="donut-track" cx="90" cy="90" r="72"></circle>
                                    <circle class="donut-value" cx="90" cy="90" r="72" stroke-dasharray="<%= dash(onTrackPercent) %>"></circle>
                                </svg>
                                <div class="donut-center">
                                    <div>
                                        <strong><%= onTrackPercent %>%</strong>
                                        <span>On-time loans</span>
                                    </div>
                                </div>
                            </div>
                            <ul class="chart-legend">
                                <% for (Map<String, Object> row : statusBreakdown) { %>
                                    <li>
                                        <div class="legend-key">
                                            <span class="legend-swatch <%= h(row.get("tone")) %>"></span>
                                            <strong><%= h(row.get("label")) %></strong>
                                        </div>
                                        <span><%= row.get("value") %> records, <%= h(row.get("share")) %></span>
                                    </li>
                                <% } %>
                            </ul>
                        </div>
                        <div class="summary-list">
                            <div class="summary-item">
                                <strong>Digital readiness</strong>
                                <span><%= digitalCoverage %>% of titles are digital-ready.</span>
                            </div>
                            <div class="summary-item">
                                <strong>Queue size</strong>
                                <span><%= reservationCount %> reservations are active right now.</span>
                            </div>
                        </div>
                    </article>
                </div>
            </section>

            <section class="panel-grid">
                <article class="dashboard-panel">
                    <div class="panel-head">
                        <div>
                            <h3>Monthly Circulation Trend</h3>
                            <p>Visual issue trend for the last six months.</p>
                        </div>
                        <span class="panel-badge">6 months</span>
                    </div>
                    <% if (circulationTrend.isEmpty()) { %>
                        <div class="empty-state">
                            <strong>No circulation history yet</strong>
                            <p>Issue transactions will appear here as soon as circulation data builds up.</p>
                        </div>
                    <% } else { %>
                        <div class="trend-chart">
                            <svg viewBox="0 0 520 220" role="img" aria-label="Six month circulation trend graph">
                                <defs>
                                    <linearGradient id="adminTrendFill" x1="0%" y1="0%" x2="0%" y2="100%">
                                        <stop offset="0%" stop-color="#4b7bec" stop-opacity="0.34"></stop>
                                        <stop offset="100%" stop-color="#4b7bec" stop-opacity="0.04"></stop>
                                    </linearGradient>
                                </defs>
                                <% for (int step = 0; step < 4; step++) {
                                       int guideValue = (int) Math.round((circulationScale * step) / 3.0d);
                                       double guideY = chartY(guideValue, circulationScale, 220, 24, 34);
                                %>
                                    <line class="chart-grid-line" x1="34" y1="<%= fmt(guideY) %>" x2="486" y2="<%= fmt(guideY) %>"></line>
                                    <text class="chart-axis-label" x="10" y="<%= fmt(guideY + 4) %>"><%= guideValue %></text>
                                <% } %>
                                <polygon class="trend-area" fill="url(#adminTrendFill)" points="<%= areaPoints(circulationTrend, 520, 220, 34, 24, 34) %>"></polygon>
                                <polyline class="trend-line" points="<%= linePoints(circulationTrend, 520, 220, 34, 24, 34) %>"></polyline>
                                <% for (int i = 0; i < circulationTrend.size(); i++) {
                                       Map<String, Object> row = circulationTrend.get(i);
                                       int value = n(row.get("value"));
                                       double pointX = chartX(i, circulationTrend.size(), 520, 34);
                                       double pointY = chartY(value, circulationScale, 220, 24, 34);
                                %>
                                    <circle class="trend-point" cx="<%= fmt(pointX) %>" cy="<%= fmt(pointY) %>" r="4.5"></circle>
                                    <text class="chart-axis-label" x="<%= fmt(pointX) %>" y="208" text-anchor="middle"><%= h(row.get("label")) %></text>
                                    <% if (value > 0) { %>
                                        <text class="chart-value-label" x="<%= fmt(pointX) %>" y="<%= fmt(Math.max(18, pointY - 12)) %>" text-anchor="middle"><%= value %></text>
                                    <% } %>
                                <% } %>
                            </svg>
                        </div>
                    <% } %>
                </article>

                <article class="dashboard-panel">
                    <div class="panel-head">
                        <div>
                            <h3>Reservation Pressure</h3>
                            <p>The titles with the strongest queue pressure.</p>
                        </div>
                        <span class="panel-badge">Demand view</span>
                    </div>
                    <% if (reservationPressure.isEmpty()) { %>
                        <div class="empty-state">
                            <strong>No reservation pressure right now</strong>
                            <p>When students start queuing for books, this demand panel will fill up.</p>
                        </div>
                    <% } else { %>
                        <div class="progress-list">
                            <% for (int i = 0; i < reservationPressure.size(); i++) {
                                   Map<String, Object> row = reservationPressure.get(i);
                            %>
                                <div class="progress-item">
                                    <div class="progress-meta">
                                        <strong><%= h(row.get("label")) %></strong>
                                        <span><%= row.get("value") %> requests</span>
                                    </div>
                                    <div class="progress-track">
                                        <span class="palette-<%= (i + 2) % 6 %>" style="width:<%= row.get("percent") %>%;"></span>
                                    </div>
                                </div>
                            <% } %>
                        </div>
                    <% } %>
                </article>
            </section>

            <section class="mini-panel-grid">
                <article class="dashboard-panel">
                    <div class="panel-head">
                        <div>
                            <h3>Low Stock Watchlist</h3>
                            <p>Books that may need replenishment or follow-up.</p>
                        </div>
                    </div>
                    <% if (lowStockBooks.isEmpty()) { %>
                        <div class="empty-state">
                            <strong>No low-stock titles yet</strong>
                            <p>Low-availability titles will be highlighted here once the catalog grows.</p>
                        </div>
                    <% } else { %>
                        <div class="activity-stack">
                            <% for (Map<String, Object> row : lowStockBooks) { %>
                                <div class="activity-item">
                                    <strong><%= h(row.get("title")) %></strong>
                                    <span class="pill <%= h(row.get("tone")) %>"><%= h(row.get("availability")) %></span>
                                </div>
                            <% } %>
                        </div>
                    <% } %>
                </article>

                <article class="dashboard-panel">
                    <div class="panel-head">
                        <div>
                            <h3>Alerts & Notifications</h3>
                            <p>Operational reminders based on current system values.</p>
                        </div>
                    </div>
                    <div class="mini-metric-grid">
                        <div class="summary-item">
                            <strong>Overdue priority</strong>
                            <span><%= overdueBooks %> records need staff follow-up.</span>
                        </div>
                        <div class="summary-item">
                            <strong>Reservation queue</strong>
                            <span><%= reservationCount %> active requests are waiting.</span>
                        </div>
                        <div class="summary-item">
                            <strong>Digital coverage</strong>
                            <span><%= digitalCoverage %>% of titles can be served digitally.</span>
                        </div>
                    </div>
                </article>

                <article class="dashboard-panel">
                    <div class="panel-head">
                        <div>
                            <h3>Quick Actions</h3>
                            <p>Direct links to the most-used admin tasks.</p>
                        </div>
                    </div>
                    <div class="button-row">
                        <a class="button-small button-outline" href="<%= contextPath %>/admin/books">Open Books</a>
                        <a class="button-small button-outline" href="<%= contextPath %>/admin/categories">Manage Categories</a>
                        <a class="button-small button-outline" href="<%= contextPath %>/admin/students">View Students</a>
                        <a class="button-small button-soft" href="<%= contextPath %>/admin/analytics">Full Analytics</a>
                    </div>
                </article>
            </section>
        </main>
    </div>
    <script src="<%= contextPath %>/assets/js/lu-swal.js"></script>
</body>
</html>
