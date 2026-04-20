<%@ page import="com.lulibrisync.model.IssueRecord,com.lulibrisync.utils.DashboardViewHelper,java.time.format.DateTimeFormatter,java.util.List" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    if (session.getAttribute("user") == null || !"ADMIN".equals(session.getAttribute("role"))) {
        response.sendRedirect(request.getContextPath() + "/views/auth/login.jsp");
        return;
    }

    String contextPath = request.getContextPath();
    List<IssueRecord> returnCandidates = (List<IssueRecord>) request.getAttribute("returnCandidates");
    List<IssueRecord> recentReturns = (List<IssueRecord>) request.getAttribute("recentReturns");
    if (returnCandidates == null || recentReturns == null) {
        response.sendRedirect(contextPath + "/admin/return");
        return;
    }

    String studentIdQuery = String.valueOf(request.getAttribute("studentIdQuery"));
    String referenceQuery = String.valueOf(request.getAttribute("referenceQuery"));
    if ("null".equalsIgnoreCase(studentIdQuery)) studentIdQuery = "";
    if ("null".equalsIgnoreCase(referenceQuery)) referenceQuery = "";

    String success = request.getParameter("success");
    String error = request.getParameter("error");
    String studentIdValue = request.getParameter("studentIdValue");
    String book = request.getParameter("book");
    String returnedAt = request.getParameter("returnedAt");

    DateTimeFormatter dateTimeFormat = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");

    int overdueCount = 0;
    for (IssueRecord record : returnCandidates) {
        if ("OVERDUE".equalsIgnoreCase(record.getStatus())) {
            overdueCount++;
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Return Book | LU Librisync</title>
    <link rel="stylesheet" href="<%= contextPath %>/assets/css/librisync.css">
</head>
<body class="dashboard-reference">
    <div class="dashboard-shell">
        <aside class="sidebar">
            <div class="sidebar-brand">
                <div class="sidebar-brand-badge">LU</div>
                <div class="sidebar-brand-copy">
                    <strong>Library MS</strong>
                    <span>Return workflow</span>
                </div>
            </div>
            <p>Search active loans by student ID or QR issue reference, then return them with automatic stock updates.</p>
            <div class="sidebar-section-label">Management</div>
            <nav class="nav-list">
                <a href="<%= contextPath %>/admin/dashboard">Dashboard</a>
                <a href="<%= contextPath %>/admin/books">Books</a>
                <a href="<%= contextPath %>/admin/authors">Authors</a>
                <a href="<%= contextPath %>/admin/categories">Categories</a>
                <a href="<%= contextPath %>/admin/issue">Issue Book</a>
                <a class="active" href="<%= contextPath %>/admin/return">Return Book</a>
                <a href="<%= contextPath %>/admin/students">Students</a>
                <a href="<%= contextPath %>/admin/analytics">Analytics</a>
                <a href="<%= contextPath %>/logout" data-swal-confirm="true" data-swal-title="Log out?" data-swal-text="You will need to sign in again to continue using LU Librisync." data-swal-confirm-text="Yes, log out" data-swal-cancel-text="Stay here" data-swal-icon="?">Logout</a>
            </nav>
        </aside>

        <main class="content-area">
            <section class="dashboard-topbar">
                <div>
                    <div class="eyebrow">Return Workflow</div>
                    <h2 class="workspace-title">Process live return records</h2>
                    <p class="workspace-copy">
                        Returning a book now updates the issue record, restores catalog stock, and triggers the
                        reservation automation to prepare the next waiting student when a copy becomes available.
                    </p>
                </div>
            </section>

            <% if ("returned".equalsIgnoreCase(success)) { %>
                <div class="alert success" style="margin-bottom:18px;">
                    Return processed for <strong><%= DashboardViewHelper.escapeHtml(studentIdValue) %></strong>.
                    Book: <strong><%= DashboardViewHelper.escapeHtml(book) %></strong>.
                    Return time: <strong><%= DashboardViewHelper.escapeHtml(returnedAt) %></strong>.
                </div>
            <% } else if ("selection".equalsIgnoreCase(error)) { %>
                <div class="alert warning" style="margin-bottom:18px;">Choose a valid issue record before marking a return.</div>
            <% } else if ("missing".equalsIgnoreCase(error)) { %>
                <div class="alert warning" style="margin-bottom:18px;">That issue record no longer exists.</div>
            <% } else if ("already_returned".equalsIgnoreCase(error)) { %>
                <div class="alert warning" style="margin-bottom:18px;">That loan has already been returned.</div>
            <% } else if ("server".equalsIgnoreCase(error)) { %>
                <div class="alert error" style="margin-bottom:18px;">The system could not process the return right now. Please try again.</div>
            <% } %>

            <section class="overview-tile-grid">
                <article class="kpi-tile tile-sky">
                    <span class="tile-meta-label">Open Returns</span>
                    <strong class="tile-value"><%= returnCandidates.size() %></strong>
                    <span class="tile-copy">Issue records still waiting for completion.</span>
                    <div class="tile-track"><span data-progress-width="100"></span></div>
                </article>
                <article class="kpi-tile tile-red">
                    <span class="tile-meta-label">Overdue Records</span>
                    <strong class="tile-value"><%= overdueCount %></strong>
                    <span class="tile-copy">Returns that already carry automated overdue fines.</span>
                    <div class="tile-track"><span data-progress-width="<%= returnCandidates.isEmpty() ? 0 : DashboardViewHelper.percentOf(overdueCount, returnCandidates.size()) %>"></span></div>
                </article>
                <article class="kpi-tile tile-teal">
                    <span class="tile-meta-label">Recent Returns</span>
                    <strong class="tile-value"><%= recentReturns.size() %></strong>
                    <span class="tile-copy">Latest circulation records for quick review.</span>
                    <div class="tile-track"><span data-progress-width="100"></span></div>
                </article>
            </section>

            <section class="panel-grid">
                <article class="dashboard-panel">
                    <div class="panel-head">
                        <div>
                            <h3>Search Active Loans</h3>
                            <p>Filter by student ID or QR issue reference.</p>
                        </div>
                    </div>

                    <form class="form-stack" action="<%= contextPath %>/admin/return" method="get">
                        <div class="form-grid">
                            <div class="field-group">
                                <label for="studentId">Student ID</label>
                                <input id="studentId" name="studentId" type="text" value="<%= DashboardViewHelper.escapeHtml(studentIdQuery) %>" placeholder="Example: 241-0001">
                            </div>
                            <div class="field-group">
                                <label for="reference">Issue Reference</label>
                                <input id="reference" name="reference" type="text" value="<%= DashboardViewHelper.escapeHtml(referenceQuery) %>" placeholder="Example: QR-ISSUE-20260401...">
                            </div>
                        </div>
                        <div class="button-row">
                            <button class="button" type="submit">Search Return Records</button>
                            <a class="button-secondary" href="<%= contextPath %>/admin/return">Reset</a>
                        </div>
                    </form>
                </article>

                <div class="stack-grid">
                    <article class="dashboard-panel">
                        <div class="panel-head">
                            <div>
                                <h3>Workflow Notes</h3>
                                <p>What happens during a return now.</p>
                            </div>
                        </div>
                        <div class="summary-list">
                            <div class="summary-item">
                                <strong>Stock recovery</strong>
                                <span>The book's available quantity is incremented automatically after a successful return.</span>
                            </div>
                            <div class="summary-item">
                                <strong>Fine preservation</strong>
                                <span>Any overdue fine already computed stays visible for reporting and collection.</span>
                            </div>
                            <div class="summary-item">
                                <strong>Queue promotion</strong>
                                <span>The reservation automation can now prepare the next waiting student after stock opens up.</span>
                            </div>
                        </div>
                    </article>
                </div>
            </section>

            <section class="dashboard-panel" style="margin-bottom:18px;">
                <div class="panel-head">
                    <div>
                        <h3>Active Return Candidates</h3>
                        <p>Select an active record and complete the return inline.</p>
                    </div>
                    <span class="panel-badge"><%= returnCandidates.size() %> open</span>
                </div>

                <% if (returnCandidates.isEmpty()) { %>
                    <div class="empty-state">
                        <strong>No active return records matched</strong>
                        <p>Try another student ID or issue reference, or wait for new issue records to be created.</p>
                    </div>
                <% } else { %>
                    <div class="table-wrap">
                        <table class="dashboard-table">
                            <thead>
                                <tr>
                                    <th>Student</th>
                                    <th>Book</th>
                                    <th>Issue Reference</th>
                                    <th>Due Date</th>
                                    <th>Status</th>
                                    <th>Fine</th>
                                    <th>Return Action</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% for (IssueRecord record : returnCandidates) {
                                       String tone = "OVERDUE".equalsIgnoreCase(record.getStatus()) ? "danger" : "success";
                                %>
                                    <tr>
                                        <td>
                                            <strong><%= DashboardViewHelper.escapeHtml(record.getStudentId()) %></strong><br>
                                            <span class="subtle-text"><%= DashboardViewHelper.escapeHtml(record.getStudentName()) %></span>
                                        </td>
                                        <td><%= DashboardViewHelper.escapeHtml(record.getBookTitle()) %></td>
                                        <td><%= DashboardViewHelper.escapeHtml(record.getIssueReference()) %></td>
                                        <td><%= record.getDueDate() == null ? "-" : dateTimeFormat.format(record.getDueDate()) %></td>
                                        <td><span class="pill <%= tone %>"><%= DashboardViewHelper.escapeHtml(record.getStatus()) %></span></td>
                                        <td><%= String.format(java.util.Locale.US, "%.2f", record.getFineAmount()) %></td>
                                        <td>
                                            <form class="form-stack" action="<%= contextPath %>/admin/return" method="post">
                                                <input type="hidden" name="issueRecordId" value="<%= record.getId() %>">
                                                <textarea name="remarks" placeholder="Optional condition or return note"></textarea>
                                                <button class="button-soft button-small" type="submit">Mark Returned</button>
                                            </form>
                                        </td>
                                    </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                <% } %>
            </section>

            <section class="dashboard-panel">
                <div class="panel-head">
                    <div>
                        <h3>Recent Circulation Records</h3>
                        <p>Latest returned and active records for audit visibility.</p>
                    </div>
                    <span class="panel-badge"><%= recentReturns.size() %> latest</span>
                </div>

                <% if (recentReturns.isEmpty()) { %>
                    <div class="empty-state">
                        <strong>No recent records</strong>
                        <p>Circulation entries will appear here after the first issue and return transactions.</p>
                    </div>
                <% } else { %>
                    <div class="table-wrap">
                        <table class="dashboard-table">
                            <thead>
                                <tr>
                                    <th>Student</th>
                                    <th>Book</th>
                                    <th>Issue Date</th>
                                    <th>Return Date</th>
                                    <th>Status</th>
                                    <th>Fine</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% for (IssueRecord record : recentReturns) {
                                       String tone = "OVERDUE".equalsIgnoreCase(record.getStatus())
                                               ? "danger"
                                               : ("RETURNED".equalsIgnoreCase(record.getStatus()) ? "neutral" : "success");
                                %>
                                    <tr>
                                        <td>
                                            <strong><%= DashboardViewHelper.escapeHtml(record.getStudentId()) %></strong><br>
                                            <span class="subtle-text"><%= DashboardViewHelper.escapeHtml(record.getStudentName()) %></span>
                                        </td>
                                        <td><%= DashboardViewHelper.escapeHtml(record.getBookTitle()) %></td>
                                        <td><%= record.getIssueDate() == null ? "-" : dateTimeFormat.format(record.getIssueDate()) %></td>
                                        <td><%= record.getReturnDate() == null ? "Pending" : dateTimeFormat.format(record.getReturnDate()) %></td>
                                        <td><span class="pill <%= tone %>"><%= DashboardViewHelper.escapeHtml(record.getStatus()) %></span></td>
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
