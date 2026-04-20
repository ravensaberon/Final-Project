<%@ page import="com.lulibrisync.model.Book,com.lulibrisync.model.Student,java.util.List,java.util.Map,com.lulibrisync.utils.DashboardViewHelper" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    if (session.getAttribute("user") == null || !"ADMIN".equals(session.getAttribute("role"))) {
        response.sendRedirect(request.getContextPath() + "/views/auth/login.jsp");
        return;
    }

    String contextPath = request.getContextPath();
    List<Student> issueStudents = (List<Student>) request.getAttribute("issueStudents");
    List<Book> availableBooks = (List<Book>) request.getAttribute("availableBooks");
    List<Map<String, Object>> recentIssues = (List<Map<String, Object>>) request.getAttribute("recentIssues");

    if (issueStudents == null || availableBooks == null || recentIssues == null) {
        response.sendRedirect(contextPath + "/admin/issue");
        return;
    }

    String issueDatePreview = String.valueOf(request.getAttribute("issueDatePreview"));
    String dueDatePreview = String.valueOf(request.getAttribute("dueDatePreview"));
    String loanWindowDays = String.valueOf(request.getAttribute("loanWindowDays"));
    if ("null".equalsIgnoreCase(issueDatePreview)) issueDatePreview = "";
    if ("null".equalsIgnoreCase(dueDatePreview)) dueDatePreview = "";
    if ("null".equalsIgnoreCase(loanWindowDays)) loanWindowDays = "14";

    String success = request.getParameter("success");
    String error = request.getParameter("error");
    String issuedReference = request.getParameter("reference");
    String issuedStudentId = request.getParameter("studentId");
    String issuedBook = request.getParameter("book");
    String issuedDue = request.getParameter("due");
    String issueQrPreview = String.valueOf(request.getAttribute("issueQrPreview"));
    if ("null".equalsIgnoreCase(issueQrPreview)) issueQrPreview = "";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Issue Book | LU Librisync</title>
    <link rel="stylesheet" href="<%= contextPath %>/assets/css/librisync.css">
</head>
<body class="dashboard-reference">
    <div class="dashboard-shell">
        <aside class="sidebar">
            <div class="sidebar-brand">
                <div class="sidebar-brand-badge">LU</div>
                <div class="sidebar-brand-copy">
                    <strong>Library MS</strong>
                    <span>Issue workflow</span>
                </div>
            </div>
            <p>Automatic loan issuance with live student and catalog selection.</p>
            <div class="sidebar-section-label">Management</div>
            <nav class="nav-list">
                <a href="<%= contextPath %>/admin/dashboard">Dashboard</a>
                <a href="<%= contextPath %>/admin/books">Books</a>
                <a href="<%= contextPath %>/admin/authors">Authors</a>
                <a href="<%= contextPath %>/admin/categories">Categories</a>
                <a class="active" href="<%= contextPath %>/admin/issue">Issue Book</a>
                <a href="<%= contextPath %>/admin/return">Return Book</a>
                <a href="<%= contextPath %>/admin/students">Students</a>
                <a href="<%= contextPath %>/admin/analytics">Analytics</a>
                <a href="<%= contextPath %>/logout" data-swal-confirm="true" data-swal-title="Log out?" data-swal-text="You will need to sign in again to continue using LU Librisync." data-swal-confirm-text="Yes, log out" data-swal-cancel-text="Stay here" data-swal-icon="?">Logout</a>
            </nav>
            <div class="sidebar-mini-card">
                <strong>Automatic issue mode</strong>
                <span>Pick the student and available book only.</span>
                <span>Issue date, due date, and QR reference are generated automatically.</span>
            </div>
        </aside>

        <main class="content-area">
            <section class="dashboard-topbar">
                <div>
                    <div class="eyebrow">Issue Book</div>
                    <h2 class="workspace-title">Automatic Issue Workflow</h2>
                    <p class="workspace-copy">
                        Your professor is right: admins should not have to type student IDs, ISBNs, dates, and references
                        one by one. This flow now uses live pickers and automatic loan details.
                    </p>
                </div>
                <div class="dashboard-toolbar">
                    <div class="search-prompt"><%= issueStudents.size() %> active students</div>
                    <div class="status-chip"><%= availableBooks.size() %> available books</div>
                </div>
            </section>

            <% if ("issued".equals(success)) { %>
                <div class="alert success" style="margin-bottom:18px;">
                    Book issued successfully for <strong><%= DashboardViewHelper.escapeHtml(issuedStudentId) %></strong>.
                    Reference: <strong><%= DashboardViewHelper.escapeHtml(issuedReference) %></strong>.
                    Book: <strong><%= DashboardViewHelper.escapeHtml(issuedBook) %></strong>.
                    Due date: <strong><%= DashboardViewHelper.escapeHtml(issuedDue) %></strong>.
                </div>
            <% } else if ("selection".equals(error)) { %>
                <div class="alert warning" style="margin-bottom:18px;">Choose both a student and an available book before confirming the issue.</div>
            <% } else if ("student_inactive".equals(error)) { %>
                <div class="alert warning" style="margin-bottom:18px;">The selected student is inactive and cannot receive a new issue record.</div>
            <% } else if ("book_unavailable".equals(error)) { %>
                <div class="alert error" style="margin-bottom:18px;">That book is no longer available for issue. Choose another title or refresh the page.</div>
            <% } else if ("server".equals(error)) { %>
                <div class="alert error" style="margin-bottom:18px;">The system could not complete the issue request right now. Please try again.</div>
            <% } %>

            <section class="panel-grid">
                <article class="dashboard-panel">
                    <div class="panel-head">
                        <div>
                            <h3>Issue Setup</h3>
                            <p>Select from live records instead of typing IDs and ISBNs manually.</p>
                        </div>
                        <span class="panel-badge">Auto issue</span>
                    </div>

                    <form class="form-stack" action="<%= contextPath %>/admin/issue" method="post" id="issueForm">
                        <div class="form-grid">
                            <div class="field-group">
                                <label for="studentDbId">Student</label>
                                <select id="studentDbId" name="studentDbId" required>
                                    <option value="">Select an active student</option>
                                    <% for (Student student : issueStudents) { %>
                                        <option
                                                value="<%= student.getId() %>"
                                                data-student-id="<%= DashboardViewHelper.escapeHtml(student.getStudentId()) %>"
                                                data-name="<%= DashboardViewHelper.escapeHtml(student.getName()) %>"
                                                data-course="<%= DashboardViewHelper.escapeHtml(student.getCourse()) %>"
                                                data-email="<%= DashboardViewHelper.escapeHtml(student.getEmail()) %>"
                                                data-issued="<%= student.getIssuedCount() %>"
                                                data-reservations="<%= student.getReservationCount() %>"
                                                data-overdue="<%= student.getOverdueCount() %>">
                                            <%= DashboardViewHelper.escapeHtml(student.getStudentId()) %> - <%= DashboardViewHelper.escapeHtml(student.getName()) %>
                                        </option>
                                    <% } %>
                                </select>
                            </div>
                            <div class="field-group">
                                <label for="bookId">Available Book</label>
                                <select id="bookId" name="bookId" required>
                                    <option value="">Select a book with stock</option>
                                    <% for (Book book : availableBooks) { %>
                                        <option
                                                value="<%= book.getId() %>"
                                                data-title="<%= DashboardViewHelper.escapeHtml(book.getTitle()) %>"
                                                data-isbn="<%= DashboardViewHelper.escapeHtml(book.getIsbn()) %>"
                                                data-author="<%= DashboardViewHelper.escapeHtml(book.getAuthorName()) %>"
                                                data-category="<%= DashboardViewHelper.escapeHtml(book.getCategoryName()) %>"
                                                data-shelf="<%= DashboardViewHelper.escapeHtml(book.getShelfLocation()) %>"
                                                data-available="<%= book.getAvailableQuantity() %>"
                                                data-digital="<%= book.isDigital() ? "Digital access ready" : "Physical shelf only" %>">
                                            <%= DashboardViewHelper.escapeHtml(book.getTitle()) %> - <%= DashboardViewHelper.escapeHtml(book.getIsbn()) %> (<%= book.getAvailableQuantity() %> left)
                                        </option>
                                    <% } %>
                                </select>
                            </div>
                        </div>

                        <div class="form-grid">
                            <div class="field-group">
                                <label>Issue Date</label>
                                <input type="text" value="<%= DashboardViewHelper.escapeHtml(issueDatePreview) %>" readonly>
                                <p class="field-help">Generated automatically the moment you confirm the issue.</p>
                            </div>
                            <div class="field-group">
                                <label>Due Date</label>
                                <input type="text" value="<%= DashboardViewHelper.escapeHtml(dueDatePreview) %>" readonly>
                                <p class="field-help">Default circulation window: <%= DashboardViewHelper.escapeHtml(loanWindowDays) %> days.</p>
                            </div>
                        </div>

                        <div class="field-group">
                            <label>QR Issue Reference</label>
                            <input type="text" value="Generated automatically after confirmation" readonly>
                            <p class="field-help">No need to type or invent a reference manually.</p>
                        </div>

                        <div class="field-group">
                            <label for="remarks">Remarks</label>
                            <textarea id="remarks" name="remarks" placeholder="Optional notes for the issue transaction"></textarea>
                        </div>

                        <div class="button-row">
                            <button class="button" type="submit">Confirm Issue Automatically</button>
                            <a class="button-secondary" href="<%= contextPath %>/admin/books">View Catalog</a>
                        </div>
                    </form>
                </article>

                <div class="stack-grid">
                    <article class="dashboard-panel">
                        <div class="panel-head">
                            <div>
                                <h3>Selected Student</h3>
                                <p>Quick context before you issue the loan.</p>
                            </div>
                        </div>
                        <div class="profile-summary-grid">
                            <div class="profile-summary-card">
                                <strong>Name</strong>
                                <span id="studentPreviewName">Choose a student</span>
                            </div>
                            <div class="profile-summary-card">
                                <strong>Student ID</strong>
                                <span id="studentPreviewId">-</span>
                            </div>
                            <div class="profile-summary-card">
                                <strong>Course</strong>
                                <span id="studentPreviewCourse">-</span>
                            </div>
                            <div class="profile-summary-card">
                                <strong>Email</strong>
                                <span id="studentPreviewEmail">-</span>
                            </div>
                            <div class="profile-summary-card">
                                <strong>Active Loans</strong>
                                <span id="studentPreviewIssued">0</span>
                            </div>
                            <div class="profile-summary-card">
                                <strong>Reservations</strong>
                                <span id="studentPreviewReservations">0</span>
                            </div>
                        </div>
                    </article>

                    <article class="dashboard-panel">
                        <div class="panel-head">
                            <div>
                                <h3>Selected Book</h3>
                                <p>Availability and catalog details update automatically.</p>
                            </div>
                        </div>
                        <div class="profile-summary-grid">
                            <div class="profile-summary-card">
                                <strong>Title</strong>
                                <span id="bookPreviewTitle">Choose a book</span>
                            </div>
                            <div class="profile-summary-card">
                                <strong>ISBN</strong>
                                <span id="bookPreviewIsbn">-</span>
                            </div>
                            <div class="profile-summary-card">
                                <strong>Author</strong>
                                <span id="bookPreviewAuthor">-</span>
                            </div>
                            <div class="profile-summary-card">
                                <strong>Category</strong>
                                <span id="bookPreviewCategory">-</span>
                            </div>
                            <div class="profile-summary-card">
                                <strong>Shelf</strong>
                                <span id="bookPreviewShelf">-</span>
                            </div>
                            <div class="profile-summary-card">
                                <strong>Stock</strong>
                                <span id="bookPreviewAvailable">0 available</span>
                            </div>
                        </div>
                        <div class="summary-list">
                            <div class="summary-item">
                                <strong>Access mode</strong>
                                <span id="bookPreviewMode">-</span>
                            </div>
                        </div>
                    </article>

                    <article class="dashboard-panel">
                        <div class="panel-head">
                            <div>
                                <h3>Why this is automatic now</h3>
                                <p>The admin only selects, reviews, and confirms.</p>
                            </div>
                        </div>
                        <div class="mini-metric-grid">
                            <div class="summary-item">
                                <strong>No manual ID typing</strong>
                                <span>Students are selected from active records already in the database.</span>
                            </div>
                            <div class="summary-item">
                                <strong>No manual ISBN entry</strong>
                                <span>Books are selected from titles that still have available stock.</span>
                            </div>
                            <div class="summary-item">
                                <strong>No manual date/reference entry</strong>
                                <span>Issue date, due date, and QR issue reference are generated by the system.</span>
                            </div>
                        </div>
                    </article>

                    <% if ("issued".equals(success) && issueQrPreview != null && !issueQrPreview.trim().isEmpty()) { %>
                        <article class="dashboard-panel">
                            <div class="panel-head">
                                <div>
                                    <h3>QR Issue Code</h3>
                                    <p>Scannable QR generated from the saved issue reference.</p>
                                </div>
                            </div>
                            <div class="summary-list">
                                <div class="summary-item" style="justify-content:center;">
                                    <img src="<%= issueQrPreview %>" alt="QR code for <%= DashboardViewHelper.escapeHtml(issuedReference) %>" style="width:220px;height:220px;border-radius:18px;background:#fff;padding:12px;">
                                </div>
                                <div class="summary-item">
                                    <strong>Reference</strong>
                                    <span><%= DashboardViewHelper.escapeHtml(issuedReference) %></span>
                                </div>
                            </div>
                        </article>
                    <% } %>
                </div>
            </section>

            <section class="dashboard-panel">
                <div class="panel-head">
                    <div>
                        <h3>Recent Issue Transactions</h3>
                        <p>Live issue records from the circulation database.</p>
                    </div>
                    <span class="panel-badge">Latest <%= recentIssues.size() %></span>
                </div>

                <% if (recentIssues.isEmpty()) { %>
                    <div class="empty-state">
                        <strong>No issue transactions yet</strong>
                        <p>The latest circulation records will appear here once books are issued through the system.</p>
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
                                    <th>Reference</th>
                                    <th>Status</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% for (Map<String, Object> row : recentIssues) { %>
                                    <tr>
                                        <td>
                                            <strong><%= DashboardViewHelper.escapeHtml(row.get("studentId")) %></strong><br>
                                            <span class="subtle-text"><%= DashboardViewHelper.escapeHtml(row.get("studentName")) %></span>
                                        </td>
                                        <td><%= DashboardViewHelper.escapeHtml(row.get("bookTitle")) %></td>
                                        <td><%= DashboardViewHelper.escapeHtml(row.get("issueDate")) %></td>
                                        <td><%= DashboardViewHelper.escapeHtml(row.get("dueDate")) %></td>
                                        <td><%= DashboardViewHelper.escapeHtml(row.get("reference")) %></td>
                                        <td><span class="pill <%= DashboardViewHelper.escapeHtml(row.get("tone")) %>"><%= DashboardViewHelper.escapeHtml(row.get("status")) %></span></td>
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
    <script>
        (function () {
            var studentSelect = document.getElementById("studentDbId");
            var bookSelect = document.getElementById("bookId");
            var form = document.getElementById("issueForm");

            function applyStudentPreview() {
                var option = studentSelect.options[studentSelect.selectedIndex];
                var hasValue = option && option.value;
                document.getElementById("studentPreviewName").textContent = hasValue ? option.getAttribute("data-name") : "Choose a student";
                document.getElementById("studentPreviewId").textContent = hasValue ? option.getAttribute("data-student-id") : "-";
                document.getElementById("studentPreviewCourse").textContent = hasValue ? option.getAttribute("data-course") : "-";
                document.getElementById("studentPreviewEmail").textContent = hasValue ? option.getAttribute("data-email") : "-";
                document.getElementById("studentPreviewIssued").textContent = hasValue ? option.getAttribute("data-issued") : "0";
                document.getElementById("studentPreviewReservations").textContent = hasValue ? option.getAttribute("data-reservations") : "0";
            }

            function applyBookPreview() {
                var option = bookSelect.options[bookSelect.selectedIndex];
                var hasValue = option && option.value;
                document.getElementById("bookPreviewTitle").textContent = hasValue ? option.getAttribute("data-title") : "Choose a book";
                document.getElementById("bookPreviewIsbn").textContent = hasValue ? option.getAttribute("data-isbn") : "-";
                document.getElementById("bookPreviewAuthor").textContent = hasValue ? option.getAttribute("data-author") : "-";
                document.getElementById("bookPreviewCategory").textContent = hasValue ? option.getAttribute("data-category") : "-";
                document.getElementById("bookPreviewShelf").textContent = hasValue ? option.getAttribute("data-shelf") : "-";
                document.getElementById("bookPreviewAvailable").textContent = hasValue ? option.getAttribute("data-available") + " available" : "0 available";
                document.getElementById("bookPreviewMode").textContent = hasValue ? option.getAttribute("data-digital") : "-";
            }

            studentSelect.addEventListener("change", applyStudentPreview);
            bookSelect.addEventListener("change", applyBookPreview);
            applyStudentPreview();
            applyBookPreview();

            form.addEventListener("submit", function () {
                var submitButton = form.querySelector("button[type='submit']");
                if (submitButton) {
                    submitButton.disabled = true;
                    submitButton.textContent = "Issuing Book...";
                }
            });
        })();
    </script>
</body>
</html>
