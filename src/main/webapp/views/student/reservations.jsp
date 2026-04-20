<%@ page import="com.lulibrisync.dao.UserDAO,com.lulibrisync.model.Book,com.lulibrisync.model.Reservation,com.lulibrisync.utils.DashboardViewHelper,java.time.format.DateTimeFormatter,java.util.List" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    if (session.getAttribute("user") == null) {
        response.sendRedirect(request.getContextPath() + "/views/auth/login.jsp");
        return;
    }

    String contextPath = request.getContextPath();
    UserDAO.StudentProfile profile = (UserDAO.StudentProfile) request.getAttribute("studentProfile");
    List<Reservation> reservations = (List<Reservation>) request.getAttribute("reservations");
    List<Book> reserveSuggestions = (List<Book>) request.getAttribute("reserveSuggestions");

    if (profile == null || reservations == null || reserveSuggestions == null) {
        response.sendRedirect(contextPath + "/student/reservations");
        return;
    }

    int pendingCount = request.getAttribute("pendingCount") == null ? 0 : ((Number) request.getAttribute("pendingCount")).intValue();
    int readyCount = request.getAttribute("readyCount") == null ? 0 : ((Number) request.getAttribute("readyCount")).intValue();
    int claimedCount = request.getAttribute("claimedCount") == null ? 0 : ((Number) request.getAttribute("claimedCount")).intValue();

    String success = request.getParameter("success");
    String error = request.getParameter("error");
    String reservedBook = request.getParameter("book");
    String queue = request.getParameter("queue");
    String statusLabel = request.getParameter("statusLabel");
    String expiresAtLabel = request.getParameter("expiresAt");

    DateTimeFormatter dateTimeFormat = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reservations | LU Librisync</title>
    <link rel="stylesheet" href="<%= contextPath %>/assets/css/librisync.css">
</head>
<body class="dashboard-reference">
    <div class="dashboard-shell">
        <aside class="sidebar">
            <div class="sidebar-brand">
                <div class="sidebar-brand-badge">LU</div>
                <div class="sidebar-brand-copy">
                    <strong>Student Portal</strong>
                    <span>Reservations</span>
                </div>
            </div>
            <p>Queue unavailable books, monitor ready-to-claim slots, and cancel requests you no longer need.</p>
            <div class="sidebar-section-label">Navigation</div>
            <nav class="nav-list">
                <a href="<%= contextPath %>/student/dashboard">Dashboard</a>
                <a href="<%= contextPath %>/student/books">Browse Books</a>
                <a href="<%= contextPath %>/student/borrowed">Borrowed Books</a>
                <a class="active" href="<%= contextPath %>/student/reservations">Reservations</a>
                <a href="<%= contextPath %>/student/profile">Profile</a>
                <a href="<%= contextPath %>/logout" data-swal-confirm="true" data-swal-title="Log out?" data-swal-text="You will need to sign in again to continue using LU Librisync." data-swal-confirm-text="Yes, log out" data-swal-cancel-text="Stay here" data-swal-icon="?">Logout</a>
            </nav>
        </aside>

        <main class="content-area">
            <section class="dashboard-topbar">
                <div>
                    <div class="eyebrow">Reservation Queue</div>
                    <h2 class="workspace-title">Live reservation tracking for your account</h2>
                    <p class="workspace-copy">
                        The reservation queue now saves to the database, auto-promotes ready items when copies become
                        available, and records reminder notifications for claimable books.
                    </p>
                </div>
            </section>

            <% if ("reserved".equalsIgnoreCase(success)) { %>
                <div class="alert success" style="margin-bottom:18px;">
                    Reservation created for <strong><%= DashboardViewHelper.escapeHtml(reservedBook) %></strong>.
                    Queue position: <strong><%= DashboardViewHelper.escapeHtml(queue) %></strong>.
                    Status: <strong><%= DashboardViewHelper.escapeHtml(statusLabel) %></strong>.
                    Availability note: <strong><%= DashboardViewHelper.escapeHtml(expiresAtLabel) %></strong>.
                </div>
            <% } else if ("cancelled".equalsIgnoreCase(success)) { %>
                <div class="alert success" style="margin-bottom:18px;">Your reservation was cancelled and the queue was rebalanced.</div>
            <% } else if ("reservation_exists".equalsIgnoreCase(error)) { %>
                <div class="alert warning" style="margin-bottom:18px;">You already have an active reservation for that title.</div>
            <% } else if ("already_issued".equalsIgnoreCase(error)) { %>
                <div class="alert warning" style="margin-bottom:18px;">That book is already issued to your account, so it cannot be reserved again.</div>
            <% } else if ("book".equalsIgnoreCase(error)) { %>
                <div class="alert warning" style="margin-bottom:18px;">Choose a valid book before creating a reservation.</div>
            <% } else if ("missing".equalsIgnoreCase(error)) { %>
                <div class="alert warning" style="margin-bottom:18px;">That reservation is no longer active.</div>
            <% } else if ("server".equalsIgnoreCase(error)) { %>
                <div class="alert error" style="margin-bottom:18px;">The system could not update your reservation right now. Please try again.</div>
            <% } %>

            <section class="overview-tile-grid">
                <article class="kpi-tile tile-amber">
                    <span class="tile-meta-label">Pending Queue</span>
                    <strong class="tile-value"><%= pendingCount %></strong>
                    <span class="tile-copy">Reservations still waiting for a copy to free up.</span>
                    <div class="tile-track"><span data-progress-width="<%= reservations.isEmpty() ? 0 : DashboardViewHelper.percentOf(pendingCount, reservations.size()) %>"></span></div>
                </article>
                <article class="kpi-tile tile-sky">
                    <span class="tile-meta-label">Ready To Claim</span>
                    <strong class="tile-value"><%= readyCount %></strong>
                    <span class="tile-copy">Reservations already promoted by the automation flow.</span>
                    <div class="tile-track"><span data-progress-width="<%= reservations.isEmpty() ? 0 : DashboardViewHelper.percentOf(readyCount, reservations.size()) %>"></span></div>
                </article>
                <article class="kpi-tile tile-violet">
                    <span class="tile-meta-label">Claimed Queue</span>
                    <strong class="tile-value"><%= claimedCount %></strong>
                    <span class="tile-copy">Reservations already acknowledged and awaiting admin issue.</span>
                    <div class="tile-track"><span data-progress-width="<%= reservations.isEmpty() ? 0 : DashboardViewHelper.percentOf(claimedCount, reservations.size()) %>"></span></div>
                </article>
                <article class="kpi-tile tile-teal">
                    <span class="tile-meta-label">Student ID</span>
                    <strong class="tile-value"><%= DashboardViewHelper.escapeHtml(profile.getUser().getStudentId()) %></strong>
                    <span class="tile-copy">Your reservation activity is tied to this student record.</span>
                    <div class="tile-track"><span data-progress-width="100"></span></div>
                </article>
            </section>

            <section class="panel-grid">
                <article class="dashboard-panel">
                    <div class="panel-head">
                        <div>
                            <h3>Quick Reserve</h3>
                            <p>Choose a title below to send it into the queue immediately.</p>
                        </div>
                    </div>

                    <div class="summary-list">
                        <%
                            int suggestionCount = 0;
                            for (Book book : reserveSuggestions) {
                                if (suggestionCount >= 6) {
                                    break;
                                }
                                suggestionCount++;
                        %>
                            <div class="summary-item">
                                <div>
                                    <strong><%= DashboardViewHelper.escapeHtml(book.getTitle()) %></strong>
                                    <span><%= DashboardViewHelper.escapeHtml(book.getAuthorName()) %> | <%= DashboardViewHelper.escapeHtml(book.getCategoryName()) %></span>
                                </div>
                                <form action="<%= contextPath %>/student/reservations" method="post">
                                    <input type="hidden" name="bookId" value="<%= book.getId() %>">
                                    <button class="button-soft button-small" type="submit">Reserve</button>
                                </form>
                            </div>
                        <% } %>
                    </div>
                </article>

                <div class="stack-grid">
                    <article class="dashboard-panel">
                        <div class="panel-head">
                            <div>
                                <h3>Queue Notes</h3>
                                <p>How the reservation system now behaves.</p>
                            </div>
                        </div>
                        <div class="summary-list">
                            <div class="summary-item">
                                <strong>Auto-ready promotion</strong>
                                <span>When a copy becomes available, the earliest pending reservation is promoted to ready status.</span>
                            </div>
                            <div class="summary-item">
                                <strong>Email queue logging</strong>
                                <span>Ready items create a notification entry in the automation queue for follow-up.</span>
                            </div>
                            <div class="summary-item">
                                <strong>Queue cleanup</strong>
                                <span>Cancelled or expired reservations are removed from the active queue order.</span>
                            </div>
                        </div>
                    </article>
                </div>
            </section>

            <section class="dashboard-panel">
                <div class="panel-head">
                    <div>
                        <h3>Reservation History</h3>
                        <p>Live reservation rows from the database.</p>
                    </div>
                    <span class="panel-badge"><%= reservations.size() %> records</span>
                </div>

                <% if (reservations.isEmpty()) { %>
                    <div class="empty-state">
                        <strong>No reservations yet</strong>
                        <p>Create one from the catalog or from the quick reserve panel above to start using the queue system.</p>
                    </div>
                <% } else { %>
                    <div class="table-wrap">
                        <table class="dashboard-table">
                            <thead>
                                <tr>
                                    <th>Book</th>
                                    <th>ISBN</th>
                                    <th>Queue Position</th>
                                    <th>Status</th>
                                    <th>Reserved At</th>
                                    <th>Expires At</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% for (Reservation reservation : reservations) {
                                       String tone = "READY".equalsIgnoreCase(reservation.getStatus())
                                               ? "success"
                                               : ("CANCELLED".equalsIgnoreCase(reservation.getStatus()) ? "neutral" : "warning");
                                %>
                                    <tr>
                                        <td>
                                            <strong><%= DashboardViewHelper.escapeHtml(reservation.getTitle()) %></strong><br>
                                            <span class="subtle-text"><%= reservation.isDigital() ? "Digital access ready" : "Physical catalog item" %></span>
                                        </td>
                                        <td><%= DashboardViewHelper.escapeHtml(reservation.getIsbn()) %></td>
                                        <td><%= reservation.getQueuePosition() %></td>
                                        <td><span class="pill <%= tone %>"><%= DashboardViewHelper.escapeHtml(reservation.getStatus()) %></span></td>
                                        <td><%= reservation.getReservedAt() == null ? "-" : dateTimeFormat.format(reservation.getReservedAt()) %></td>
                                        <td><%= reservation.getExpiresAt() == null ? "Queue pending" : dateTimeFormat.format(reservation.getExpiresAt()) %></td>
                                        <td>
                                            <% if ("PENDING".equalsIgnoreCase(reservation.getStatus()) || "READY".equalsIgnoreCase(reservation.getStatus()) || "CLAIMED".equalsIgnoreCase(reservation.getStatus())) { %>
                                                <form action="<%= contextPath %>/student/reservations" method="post">
                                                    <input type="hidden" name="action" value="cancel">
                                                    <input type="hidden" name="reservationId" value="<%= reservation.getId() %>">
                                                    <button class="button-danger button-small" type="submit">Cancel</button>
                                                </form>
                                            <% } else { %>
                                                <span class="subtle-text">No action</span>
                                            <% } %>
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
