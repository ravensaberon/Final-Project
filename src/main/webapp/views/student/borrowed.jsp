<%@ page import="com.lulibrisync.model.IssueRecord,com.lulibrisync.utils.DashboardViewHelper,java.time.format.DateTimeFormatter,java.util.List" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    if (session.getAttribute("user") == null) {
        response.sendRedirect(request.getContextPath() + "/views/auth/login.jsp");
        return;
    }

    String contextPath = request.getContextPath();
    List<IssueRecord> borrowedHistory = (List<IssueRecord>) request.getAttribute("borrowedHistory");
    if (borrowedHistory == null) {
        response.sendRedirect(contextPath + "/student/borrowed");
        return;
    }

    int activeCount = request.getAttribute("activeCount") == null ? 0 : ((Number) request.getAttribute("activeCount")).intValue();
    int returnedCount = request.getAttribute("returnedCount") == null ? 0 : ((Number) request.getAttribute("returnedCount")).intValue();
    int overdueCount = request.getAttribute("overdueCount") == null ? 0 : ((Number) request.getAttribute("overdueCount")).intValue();
    double unpaidFineTotal = request.getAttribute("unpaidFineTotal") == null ? 0.0d : ((Number) request.getAttribute("unpaidFineTotal")).doubleValue();
    DateTimeFormatter dateTimeFormat = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Borrowed Books | LU Librisync</title>
    <link rel="stylesheet" href="<%= contextPath %>/assets/css/librisync.css">
</head>
<body class="dashboard-reference">
    <div class="dashboard-shell">
        <aside class="sidebar">
            <div class="sidebar-brand">
                <div class="sidebar-brand-badge">LU</div>
                <div class="sidebar-brand-copy">
                    <strong>Student Portal</strong>
                    <span>Borrowed books</span>
                </div>
            </div>
            <p>Real issue history with due dates, return timestamps, and overdue fine visibility.</p>
            <div class="sidebar-section-label">Navigation</div>
            <nav class="nav-list">
                <a href="<%= contextPath %>/student/dashboard">Dashboard</a>
                <a href="<%= contextPath %>/student/books">Browse Books</a>
                <a class="active" href="<%= contextPath %>/student/borrowed">Borrowed Books</a>
                <a href="<%= contextPath %>/student/reservations">Reservations</a>
                <a href="<%= contextPath %>/student/profile">Profile</a>
                <a href="<%= contextPath %>/views/auth/change-password.jsp">Change Password</a>
                <a href="<%= contextPath %>/logout" data-swal-confirm="true" data-swal-title="Log out?" data-swal-text="You will need to sign in again to continue using LU Librisync." data-swal-confirm-text="Yes, log out" data-swal-cancel-text="Stay here" data-swal-icon="?">Logout</a>
            </nav>
        </aside>

        <main class="content-area">
            <section class="dashboard-topbar">
                <div>
                    <div class="eyebrow">Issued Books</div>
                    <h2 class="workspace-title">Your loan history and return schedule</h2>
                    <p class="workspace-copy">
                        This page now reads the actual circulation records so students can see issue time, due time,
                        return time, and auto-calculated overdue amounts from the same database the admin uses.
                    </p>
                </div>
            </section>

            <section class="overview-tile-grid">
                <article class="kpi-tile tile-sky">
                    <span class="tile-meta-label">Active Loans</span>
                    <strong class="tile-value"><%= activeCount %></strong>
                    <span class="tile-copy">Books still currently issued to your account.</span>
                    <div class="tile-track"><span data-progress-width="<%= borrowedHistory.isEmpty() ? 0 : DashboardViewHelper.percentOf(activeCount, borrowedHistory.size()) %>"></span></div>
                </article>
                <article class="kpi-tile tile-teal">
                    <span class="tile-meta-label">Returned Titles</span>
                    <strong class="tile-value"><%= returnedCount %></strong>
                    <span class="tile-copy">Books already completed and returned.</span>
                    <div class="tile-track"><span data-progress-width="<%= borrowedHistory.isEmpty() ? 0 : DashboardViewHelper.percentOf(returnedCount, borrowedHistory.size()) %>"></span></div>
                </article>
                <article class="kpi-tile tile-red">
                    <span class="tile-meta-label">Overdue Loans</span>
                    <strong class="tile-value"><%= overdueCount %></strong>
                    <span class="tile-copy">Records that need attention right away.</span>
                    <div class="tile-track"><span data-progress-width="<%= borrowedHistory.isEmpty() ? 0 : DashboardViewHelper.percentOf(overdueCount, borrowedHistory.size()) %>"></span></div>
                </article>
                <article class="kpi-tile tile-amber">
                    <span class="tile-meta-label">Outstanding Fines</span>
                    <strong class="tile-value"><%= String.format(java.util.Locale.US, "%.2f", unpaidFineTotal) %></strong>
                    <span class="tile-copy">Current overdue exposure from active late returns.</span>
                    <div class="tile-track"><span data-progress-width="<%= overdueCount > 0 ? 100 : 0 %>"></span></div>
                </article>
            </section>

            <section class="dashboard-panel">
                <div class="panel-head">
                    <div>
                        <h3>Borrowed Book History</h3>
                        <p>Every issue record tied to your student account.</p>
                    </div>
                    <span class="panel-badge"><%= borrowedHistory.size() %> records</span>
                </div>

                <% if (borrowedHistory.isEmpty()) { %>
                    <div class="empty-state">
                        <strong>No borrowing history yet</strong>
                        <p>Your future issue records will show up here together with due dates and return timestamps.</p>
                    </div>
                <% } else { %>
                    <div class="table-wrap">
                        <table class="dashboard-table">
                            <thead>
                                <tr>
                                    <th>Book</th>
                                    <th>Issue Reference</th>
                                    <th>Issue Date-Time</th>
                                    <th>Due Date-Time</th>
                                    <th>Return Date-Time</th>
                                    <th>Status</th>
                                    <th>Fine</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% for (IssueRecord record : borrowedHistory) {
                                       String status = record.getStatus();
                                       String tone = "ISSUED".equalsIgnoreCase(status)
                                               ? "success"
                                               : ("OVERDUE".equalsIgnoreCase(status) ? "danger" : "neutral");
                                %>
                                    <tr>
                                        <td>
                                            <strong><%= DashboardViewHelper.escapeHtml(record.getBookTitle()) %></strong><br>
                                            <span class="subtle-text"><%= DashboardViewHelper.escapeHtml(record.getRemarks()) %></span>
                                        </td>
                                        <td><%= DashboardViewHelper.escapeHtml(record.getIssueReference()) %></td>
                                        <td><%= record.getIssueDate() == null ? "-" : dateTimeFormat.format(record.getIssueDate()) %></td>
                                        <td><%= record.getDueDate() == null ? "-" : dateTimeFormat.format(record.getDueDate()) %></td>
                                        <td><%= record.getReturnDate() == null ? "Pending" : dateTimeFormat.format(record.getReturnDate()) %></td>
                                        <td><span class="pill <%= tone %>"><%= DashboardViewHelper.escapeHtml(status) %></span></td>
                                        <td><%= String.format(java.util.Locale.US, "%.2f", record.getFineAmount()) %></td>
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
