<%@ page import="java.util.List,java.util.Map,java.util.Locale" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page session="true" %>
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
    Object currentUser = session.getAttribute("user");
    if (currentUser == null) {
        response.sendRedirect(request.getContextPath() + "/views/auth/login.jsp");
        return;
    }

    String studentName = String.valueOf(currentUser).trim();
    if (studentName.isEmpty()) {
        studentName = "Student";
    }

    String contextPath = request.getContextPath();
    String course = String.valueOf(request.getAttribute("studentCourse"));
    String yearLevel = String.valueOf(request.getAttribute("studentYearLevel"));
    String phone = String.valueOf(request.getAttribute("studentPhone"));
    String address = String.valueOf(request.getAttribute("studentAddress"));
    String studentId = String.valueOf(request.getAttribute("studentStudentId"));
    if ("null".equalsIgnoreCase(course)) course = "Not set";
    if ("null".equalsIgnoreCase(yearLevel)) yearLevel = "Not set";
    if ("null".equalsIgnoreCase(phone)) phone = "Not set";
    if ("null".equalsIgnoreCase(address)) address = "No address on file";
    if ("null".equalsIgnoreCase(studentId)) studentId = "-";

    int activeLoans = request.getAttribute("activeLoans") == null ? 0 : (Integer) request.getAttribute("activeLoans");
    int overdueLoans = request.getAttribute("overdueLoans") == null ? 0 : (Integer) request.getAttribute("overdueLoans");
    int reservationCount = request.getAttribute("reservationCount") == null ? 0 : (Integer) request.getAttribute("reservationCount");
    int completedLoans = request.getAttribute("completedLoans") == null ? 0 : (Integer) request.getAttribute("completedLoans");
    int outstandingFines = request.getAttribute("outstandingFines") == null ? 0 : (Integer) request.getAttribute("outstandingFines");
    int onTrackPercent = request.getAttribute("onTrackPercent") == null ? 100 : (Integer) request.getAttribute("onTrackPercent");

    List<Map<String, Object>> monthlyActivity = (List<Map<String, Object>>) request.getAttribute("monthlyActivity");
    List<Map<String, Object>> categoryInterest = (List<Map<String, Object>>) request.getAttribute("categoryInterest");
    List<Map<String, Object>> statusBreakdown = (List<Map<String, Object>>) request.getAttribute("statusBreakdown");
    List<Map<String, Object>> currentLoans = (List<Map<String, Object>>) request.getAttribute("currentLoans");
    List<Map<String, Object>> reservationQueue = (List<Map<String, Object>>) request.getAttribute("reservationQueue");

    if (monthlyActivity == null) monthlyActivity = java.util.Collections.emptyList();
    if (categoryInterest == null) categoryInterest = java.util.Collections.emptyList();
    if (statusBreakdown == null) statusBreakdown = java.util.Collections.emptyList();
    if (currentLoans == null) currentLoans = java.util.Collections.emptyList();
    if (reservationQueue == null) reservationQueue = java.util.Collections.emptyList();

    int metricScale = Math.max(
            1,
            Math.max(
                    Math.max(activeLoans, overdueLoans),
                    Math.max(Math.max(reservationCount, completedLoans), Math.max(outstandingFines, onTrackPercent))
            )
    );
    int activityScale = Math.max(1, maxValue(monthlyActivity));
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Student Dashboard | LU Librisync</title>
    <link rel="stylesheet" href="<%= contextPath %>/assets/css/librisync.css">
</head>
<body class="dashboard-reference">
    <div class="dashboard-shell">
        <aside class="sidebar">
            <div class="sidebar-brand">
                <div class="sidebar-brand-badge"><%= h(studentName.substring(0, 1).toUpperCase()) %></div>
                <div class="sidebar-brand-copy">
                    <strong><%= h(studentName) %></strong>
                    <span>Student workspace</span>
                </div>
            </div>
            <p>Your personal library board for borrowing activity, reservations, and reading momentum.</p>
            <div class="sidebar-section-label">Navigation</div>
            <nav class="nav-list">
                <a class="active" href="<%= contextPath %>/student/dashboard">Dashboard</a>
                <a href="<%= contextPath %>/student/books">Browse Books</a>
                <a href="<%= contextPath %>/student/borrowed">Borrowed Books</a>
                <a href="<%= contextPath %>/student/reservations">Reservations</a>
                <a href="<%= contextPath %>/student/profile">My Profile</a>
                <a href="<%= contextPath %>/logout" data-swal-confirm="true" data-swal-title="Log out?" data-swal-text="You will need to sign in again to continue using LU Librisync." data-swal-confirm-text="Yes, log out" data-swal-cancel-text="Stay here" data-swal-icon="?">Logout</a>
            </nav>
            <div class="sidebar-mini-card">
                <strong>Reading health</strong>
                <span><%= onTrackPercent %>% of your current loans are still on track.</span>
                <span><%= reservationCount %> reservations are visible in your queue.</span>
            </div>
        </aside>

        <main class="content-area">
            <section class="dashboard-topbar">
                <div>
                    <div class="eyebrow">Student Dashboard</div>
                    <h2 class="workspace-title">Reading Activity Dashboard</h2>
                    <p class="workspace-copy">
                        A more visual home base for tracking due dates, reservation flow, borrowing rhythm, and the
                        categories you read the most.
                    </p>
                </div>
                <div class="dashboard-toolbar">
                    <div class="search-prompt">Student ID: <%= h(studentId) %></div>
                    <div class="status-chip"><%= onTrackPercent %>% On-Time Rate</div>
                </div>
            </section>

            <section class="dashboard-banner">
                <article class="banner-primary">
                    <div class="banner-head">
                        <div>
                            <h3 class="section-title">Profile Snapshot</h3>
                            <p>Quick view of your academic profile and current library standing.</p>
                        </div>
                        <span class="panel-badge"><%= h(course) %></span>
                    </div>
                    <div class="banner-stats">
                        <div class="banner-stat">
                            <strong><%= h(yearLevel) %></strong>
                            <span>Current year level</span>
                        </div>
                        <div class="banner-stat">
                            <strong><%= reservationCount %></strong>
                            <span>Reservations in queue</span>
                        </div>
                        <div class="banner-stat">
                            <strong><%= activeLoans %></strong>
                            <span>Active borrowed titles</span>
                        </div>
                    </div>
                </article>
                <article class="banner-secondary">
                    <span class="tile-meta-label">Student Reminder</span>
                    <h3 style="margin:14px 0 8px;font-size:1.35rem;">Stay ahead of due dates</h3>
                    <p>Use the dashboard below to spot overdue risk and manage reservations before they become urgent.</p>
                    <ul>
                        <li><%= overdueLoans %> overdue items currently need attention.</li>
                        <li><%= outstandingFines %> total unpaid fine balance is on record.</li>
                        <li><%= completedLoans %> loans have already been completed successfully.</li>
                    </ul>
                </article>
            </section>

            <section class="overview-tile-grid">
                <article class="kpi-tile tile-sky">
                    <span class="tile-meta-label">Active Loans</span>
                    <strong class="tile-value"><%= activeLoans %></strong>
                    <span class="tile-copy">Books currently borrowed and still in your account.</span>
                    <div class="tile-track"><span style="width:<%= percentOf(activeLoans, metricScale) %>%;"></span></div>
                </article>
                <article class="kpi-tile tile-teal">
                    <span class="tile-meta-label">Reservations</span>
                    <strong class="tile-value"><%= reservationCount %></strong>
                    <span class="tile-copy">Books waiting in your queue or ready to claim.</span>
                    <div class="tile-track"><span style="width:<%= percentOf(reservationCount, metricScale) %>%;"></span></div>
                </article>
                <article class="kpi-tile tile-amber">
                    <span class="tile-meta-label">Completed</span>
                    <strong class="tile-value"><%= completedLoans %></strong>
                    <span class="tile-copy">Borrowed titles already returned successfully.</span>
                    <div class="tile-track"><span style="width:<%= percentOf(completedLoans, metricScale) %>%;"></span></div>
                </article>
                <article class="kpi-tile tile-violet">
                    <span class="tile-meta-label">On-Time Rate</span>
                    <strong class="tile-value"><%= onTrackPercent %>%</strong>
                    <span class="tile-copy">Share of your active loans still inside the safe return window.</span>
                    <div class="tile-track"><span style="width:<%= onTrackPercent %>%;"></span></div>
                </article>
                <article class="kpi-tile tile-cyan">
                    <span class="tile-meta-label">Fine Balance</span>
                    <strong class="tile-value"><%= outstandingFines %></strong>
                    <span class="tile-copy">Current unpaid fine amount tied to your issue records.</span>
                    <div class="tile-track"><span style="width:<%= percentOf(outstandingFines, metricScale) %>%;"></span></div>
                </article>
                <article class="kpi-tile tile-red">
                    <span class="tile-meta-label">Overdue</span>
                    <strong class="tile-value"><%= overdueLoans %></strong>
                    <span class="tile-copy">Loans already past due and needing quick follow-up.</span>
                    <div class="tile-track"><span style="width:<%= percentOf(overdueLoans, metricScale) %>%;"></span></div>
                </article>
            </section>

            <section class="panel-grid">
                <article class="dashboard-panel">
                    <div class="panel-head">
                        <div>
                            <h3>Monthly Borrowing Trend</h3>
                            <p>Visual look at your checkouts over the last six months.</p>
                        </div>
                        <span class="panel-badge">6 months</span>
                    </div>
                    <% if (monthlyActivity.isEmpty()) { %>
                        <div class="empty-state">
                            <strong>No borrowing trend yet</strong>
                            <p>Your monthly borrowing chart will appear once you start checking out books.</p>
                        </div>
                    <% } else { %>
                        <div class="trend-chart">
                            <svg viewBox="0 0 520 220" role="img" aria-label="Six month borrowing trend graph">
                                <defs>
                                    <linearGradient id="studentTrendFill" x1="0%" y1="0%" x2="0%" y2="100%">
                                        <stop offset="0%" stop-color="#4b7bec" stop-opacity="0.34"></stop>
                                        <stop offset="100%" stop-color="#4b7bec" stop-opacity="0.04"></stop>
                                    </linearGradient>
                                </defs>
                                <% for (int step = 0; step < 4; step++) {
                                       int guideValue = (int) Math.round((activityScale * step) / 3.0d);
                                       double guideY = chartY(guideValue, activityScale, 220, 24, 34);
                                %>
                                    <line class="chart-grid-line" x1="34" y1="<%= fmt(guideY) %>" x2="486" y2="<%= fmt(guideY) %>"></line>
                                    <text class="chart-axis-label" x="10" y="<%= fmt(guideY + 4) %>"><%= guideValue %></text>
                                <% } %>
                                <polygon class="trend-area" fill="url(#studentTrendFill)" points="<%= areaPoints(monthlyActivity, 520, 220, 34, 24, 34) %>"></polygon>
                                <polyline class="trend-line" points="<%= linePoints(monthlyActivity, 520, 220, 34, 24, 34) %>"></polyline>
                                <% for (int i = 0; i < monthlyActivity.size(); i++) {
                                       Map<String, Object> row = monthlyActivity.get(i);
                                       int value = n(row.get("value"));
                                       double pointX = chartX(i, monthlyActivity.size(), 520, 34);
                                       double pointY = chartY(value, activityScale, 220, 24, 34);
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
                            <h3>Reading Balance</h3>
                            <p>Quick health check of your current borrowing status.</p>
                        </div>
                        <span class="panel-badge"><%= onTrackPercent %>% healthy</span>
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
                </article>
            </section>

            <section class="panel-grid">
                <article class="dashboard-panel">
                    <div class="panel-head">
                        <div>
                            <h3>Category Interest</h3>
                            <p>Subjects and genres that show up most in your borrowing history.</p>
                        </div>
                        <span class="panel-badge">Reading profile</span>
                    </div>
                    <% if (categoryInterest.isEmpty()) { %>
                        <div class="empty-state">
                            <strong>No category profile yet</strong>
                            <p>Borrow a few books and your category interest panel will start filling up.</p>
                        </div>
                    <% } else { %>
                        <div class="progress-list">
                            <% for (int i = 0; i < categoryInterest.size(); i++) {
                                   Map<String, Object> row = categoryInterest.get(i);
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
                            <h3>Current Due Dates</h3>
                            <p>Books you should prioritize before they become overdue.</p>
                        </div>
                        <span class="panel-badge">Current loans</span>
                    </div>
                    <% if (currentLoans.isEmpty()) { %>
                        <div class="empty-state">
                            <strong>No current loans</strong>
                            <p>You are clear right now. Browse the collection when you are ready for your next checkout.</p>
                        </div>
                    <% } else { %>
                        <div class="activity-stack">
                            <% for (Map<String, Object> row : currentLoans) { %>
                                <div class="activity-item">
                                    <strong><%= h(row.get("title")) %></strong>
                                    <span class="pill <%= h(row.get("tone")) %>"><%= h(row.get("status")) %></span>
                                    <span class="meta">Due: <%= h(row.get("dueDate")) %> | Fine: <%= h(row.get("fineAmount")) %></span>
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
                            <h3>Reservation Pipeline</h3>
                            <p>Books you are waiting on or preparing to claim.</p>
                        </div>
                    </div>
                    <% if (reservationQueue.isEmpty()) { %>
                        <div class="empty-state">
                            <strong>No reservations in line</strong>
                            <p>Reserved books will appear here once you join the queue for in-demand titles.</p>
                        </div>
                    <% } else { %>
                        <div class="activity-stack">
                            <% for (Map<String, Object> row : reservationQueue) { %>
                                <div class="activity-item">
                                    <strong><%= h(row.get("title")) %></strong>
                                    <span class="pill <%= h(row.get("tone")) %>"><%= h(row.get("status")) %></span>
                                    <span class="meta"><%= h(row.get("queue")) %> | <%= h(row.get("reservedAt")) %></span>
                                </div>
                            <% } %>
                        </div>
                    <% } %>
                </article>

                <article class="dashboard-panel">
                    <div class="panel-head">
                        <div>
                            <h3>Profile Snapshot</h3>
                            <p>Contact and academic details used by the library.</p>
                        </div>
                    </div>
                    <div class="profile-summary-grid">
                        <div class="profile-summary-card">
                            <strong>Course</strong>
                            <span><%= h(course) %></span>
                        </div>
                        <div class="profile-summary-card">
                            <strong>Year Level</strong>
                            <span><%= h(yearLevel) %></span>
                        </div>
                        <div class="profile-summary-card">
                            <strong>Phone</strong>
                            <span><%= h(phone) %></span>
                        </div>
                        <div class="profile-summary-card">
                            <strong>Address</strong>
                            <span><%= h(address) %></span>
                        </div>
                    </div>
                </article>

                <article class="dashboard-panel">
                    <div class="panel-head">
                        <div>
                            <h3>Action Guide</h3>
                            <p>Quick reminders to keep your account healthy.</p>
                        </div>
                    </div>
                    <div class="mini-metric-grid">
                        <div class="summary-item">
                            <strong>Watch due dates</strong>
                            <span>Review the due-date panel regularly to avoid overdue records.</span>
                        </div>
                        <div class="summary-item">
                            <strong>Reserve early</strong>
                            <span>Popular titles can build queues quickly, so reserve them early.</span>
                        </div>
                        <div class="summary-item">
                            <strong>Keep profile updated</strong>
                            <span>Updated contact details help the library reach you faster.</span>
                        </div>
                    </div>
                </article>
            </section>
        </main>
    </div>
    <script src="<%= contextPath %>/assets/js/lu-swal.js"></script>
</body>
</html>
