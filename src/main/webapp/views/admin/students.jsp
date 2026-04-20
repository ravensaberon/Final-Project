<%@ page import="com.lulibrisync.model.Student,java.util.List,com.lulibrisync.utils.DashboardViewHelper" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    if (session.getAttribute("user") == null || !"ADMIN".equals(session.getAttribute("role"))) {
        response.sendRedirect(request.getContextPath() + "/views/auth/login.jsp");
        return;
    }

    String contextPath = request.getContextPath();
    List<Student> students = (List<Student>) request.getAttribute("students");
    Student editStudent = (Student) request.getAttribute("editStudent");
    String searchQuery = request.getAttribute("searchQuery") == null ? "" : String.valueOf(request.getAttribute("searchQuery"));
    int totalStudents = request.getAttribute("totalStudents") == null ? 0 : (Integer) request.getAttribute("totalStudents");
    int activeStudents = request.getAttribute("activeStudents") == null ? 0 : (Integer) request.getAttribute("activeStudents");
    int overdueStudents = request.getAttribute("overdueStudents") == null ? 0 : (Integer) request.getAttribute("overdueStudents");
    int totalReservations = request.getAttribute("totalReservations") == null ? 0 : (Integer) request.getAttribute("totalReservations");
    String feedbackType = request.getParameter("feedbackType");
    String feedbackMessage = request.getParameter("feedbackMessage");

    if (students == null) {
        students = java.util.Collections.emptyList();
    }

    int maxIssued = 1;
    for (Student student : students) {
        maxIssued = Math.max(maxIssued, student.getIssuedCount() + student.getOverdueCount());
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Student Management | LU Librisync</title>
    <link rel="stylesheet" href="<%= contextPath %>/assets/css/librisync.css">
</head>
<body>
    <div class="dashboard-shell">
        <aside class="sidebar">
            <h1>LU Librisync</h1>
            <p>Search, review, and update student records with better visibility into their library activity.</p>
            <nav class="nav-list">
                <a href="<%= contextPath %>/admin/dashboard">Dashboard</a>
                <a href="<%= contextPath %>/admin/books">Books</a>
                <a href="<%= contextPath %>/admin/authors">Authors</a>
                <a href="<%= contextPath %>/admin/categories">Categories</a>
                <a href="<%= contextPath %>/admin/issue">Issue Book</a>
                <a href="<%= contextPath %>/admin/return">Return Book</a>
                <a class="active" href="<%= contextPath %>/admin/students">Students</a>
                <a href="<%= contextPath %>/admin/analytics">Analytics</a>
                <a href="<%= contextPath %>/logout" data-swal-confirm="true" data-swal-title="Log out?" data-swal-text="You will need to sign in again to continue using LU Librisync." data-swal-confirm-text="Yes, log out" data-swal-cancel-text="Stay here" data-swal-icon="?">Logout</a>
            </nav>
        </aside>

        <main class="content-area">
            <section class="hero-card content-card" style="margin-bottom:18px;">
                <div class="eyebrow">Student Management</div>
                <h2 class="section-title">Search and maintain active student library records.</h2>
                <p class="section-copy">
                    Filter by student ID, name, or email, then update profile details and account status directly
                    from this admin workspace.
                </p>
                <form class="form-stack" action="<%= contextPath %>/admin/students" method="get" style="margin-top:18px;">
                    <div class="form-grid">
                        <div class="field-group">
                            <label for="q">Search Students</label>
                            <input id="q" name="q" type="text" value="<%= DashboardViewHelper.escapeHtml(searchQuery) %>"
                                   placeholder="Search by student ID, name, or email">
                        </div>
                        <div class="field-group" style="align-content:end;">
                            <div class="button-row">
                                <button class="button" type="submit">Search</button>
                                <a class="button-secondary" href="<%= contextPath %>/admin/students">Reset</a>
                            </div>
                        </div>
                    </div>
                </form>
            </section>

            <section class="metric-strip" style="margin-bottom:18px;">
                <article class="mini-stat">
                    <strong>Visible Students</strong>
                    <span class="metric"><%= totalStudents %></span>
                    <span>Total student records currently shown in the filtered directory.</span>
                </article>
                <article class="mini-stat">
                    <strong>Active Accounts</strong>
                    <span class="metric"><%= activeStudents %></span>
                    <span>Students whose library access is currently marked as active.</span>
                </article>
                <article class="mini-stat">
                    <strong>Overdue Cases</strong>
                    <span class="metric"><%= overdueStudents %></span>
                    <span>Students with at least one overdue book requiring attention.</span>
                </article>
                <article class="mini-stat">
                    <strong>Queued Reservations</strong>
                    <span class="metric"><%= totalReservations %></span>
                    <span>Total active reservation requests across visible student records.</span>
                </article>
            </section>

            <section class="chart-grid" style="margin-bottom:18px;">
                <article class="content-card">
                    <div class="table-toolbar">
                        <div>
                            <h3 class="section-title"><%= editStudent != null ? "Edit Student Record" : "Student Record Details" %></h3>
                            <p class="chart-caption">Choose a student from the table below to update profile and status data.</p>
                        </div>
                    </div>

                    <% if (feedbackMessage != null && !feedbackMessage.isBlank()) { %>
                        <div class="alert <%= "success".equals(feedbackType) ? "success" : "error" %>"><%= DashboardViewHelper.escapeHtml(feedbackMessage) %></div>
                    <% } %>

                    <% if (editStudent == null) { %>
                        <div class="empty-state">
                            <strong>Select a student to edit</strong>
                            <p>Use the directory table below and click <em>Edit</em> on any student to update their record here.</p>
                        </div>
                    <% } else { %>
                        <form class="form-stack" action="<%= contextPath %>/admin/students" method="post">
                            <input type="hidden" name="action" value="update">
                            <input type="hidden" name="id" value="<%= editStudent.getId() %>">
                            <input type="hidden" name="q" value="<%= DashboardViewHelper.escapeHtml(searchQuery) %>">
                            <div class="form-grid">
                                <div class="field-group">
                                    <label>Student ID</label>
                                    <input type="text" value="<%= DashboardViewHelper.escapeHtml(editStudent.getStudentId()) %>" readonly>
                                </div>
                                <div class="field-group">
                                    <label>Name</label>
                                    <input type="text" value="<%= DashboardViewHelper.escapeHtml(editStudent.getName()) %>" readonly>
                                </div>
                            </div>
                            <div class="form-grid">
                                <div class="field-group">
                                    <label for="course">Course</label>
                                    <input id="course" name="course" type="text" value="<%= DashboardViewHelper.escapeHtml(editStudent.getCourse()) %>" placeholder="Course">
                                </div>
                                <div class="field-group">
                                    <label for="yearLevel">Year Level</label>
                                    <input id="yearLevel" name="yearLevel" type="text" value="<%= DashboardViewHelper.escapeHtml(editStudent.getYearLevel()) %>" placeholder="Year level">
                                </div>
                            </div>
                            <div class="form-grid">
                                <div class="field-group">
                                    <label for="phone">Phone</label>
                                    <input id="phone" name="phone" type="text" value="<%= DashboardViewHelper.escapeHtml(editStudent.getPhone()) %>" placeholder="Phone number">
                                </div>
                                <div class="field-group">
                                    <label for="status">Status</label>
                                    <select id="status" name="status">
                                        <option value="ACTIVE" <%= "ACTIVE".equalsIgnoreCase(editStudent.getStatus()) ? "selected" : "" %>>ACTIVE</option>
                                        <option value="INACTIVE" <%= "INACTIVE".equalsIgnoreCase(editStudent.getStatus()) ? "selected" : "" %>>INACTIVE</option>
                                    </select>
                                </div>
                            </div>
                            <div class="field-group">
                                <label for="address">Address</label>
                                <textarea id="address" name="address" placeholder="Address"><%= DashboardViewHelper.escapeHtml(editStudent.getAddress()) %></textarea>
                            </div>
                            <div class="button-row">
                                <button class="button" type="submit">Save Student Record</button>
                                <a class="button-secondary" href="<%= contextPath %>/admin/students<%= searchQuery.isBlank() ? "" : "?q=" + java.net.URLEncoder.encode(searchQuery, java.nio.charset.StandardCharsets.UTF_8) %>">Cancel Edit</a>
                            </div>
                        </form>
                    <% } %>
                </article>

                <article class="chart-card">
                    <div class="chart-header">
                        <div>
                            <h3 class="section-title">Borrowing Load by Student</h3>
                            <p class="chart-caption">A quick visual of which students currently carry the highest active loan pressure.</p>
                        </div>
                    </div>

                    <% if (students.isEmpty()) { %>
                        <div class="empty-state">
                            <strong>No students to chart</strong>
                            <p>Student activity bars will appear here when the directory has records to display.</p>
                        </div>
                    <% } else { %>
                        <div class="bar-chart">
                            <% for (Student student : students) {
                                int load = student.getIssuedCount() + student.getOverdueCount();
                                int percent = load == 0 ? 6 : (int) Math.round((load * 100.0) / maxIssued);
                            %>
                                <div class="bar-row">
                                    <div class="bar-meta">
                                        <strong><%= DashboardViewHelper.escapeHtml(student.getName()) %></strong>
                                        <span><%= load %> active or overdue loans</span>
                                    </div>
                                    <div class="bar-track">
                                        <div class="bar-fill <%= student.getOverdueCount() > 0 ? "danger" : "success" %>" data-progress-width="<%= percent %>"></div>
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
                        <h3 class="section-title">Student Directory</h3>
                        <p class="chart-caption">Review student activity, jump into edits, or remove student accounts when necessary.</p>
                    </div>
                </div>

                <% if (students.isEmpty()) { %>
                    <div class="empty-state">
                        <strong>No students found</strong>
                        <p>Try a different search term or wait for new student registrations to appear.</p>
                    </div>
                <% } else { %>
                    <div class="table-wrap">
                        <table>
                            <thead>
                                <tr>
                                    <th>Student</th>
                                    <th>Course / Year</th>
                                    <th>Borrowing</th>
                                    <th>Reservations</th>
                                    <th>Status</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% for (Student student : students) { %>
                                    <tr>
                                        <td>
                                            <strong><%= DashboardViewHelper.escapeHtml(student.getName()) %></strong><br>
                                            <span class="muted"><%= DashboardViewHelper.escapeHtml(student.getStudentId()) %> • <%= DashboardViewHelper.escapeHtml(student.getEmail()) %></span>
                                        </td>
                                        <td><%= DashboardViewHelper.escapeHtml(student.getCourse()) %><br><span class="muted"><%= DashboardViewHelper.escapeHtml(student.getYearLevel()) %></span></td>
                                        <td>
                                            <span class="pill <%= student.getOverdueCount() > 0 ? "danger" : "success" %>">
                                                <%= student.getIssuedCount() %> issued / <%= student.getOverdueCount() %> overdue
                                            </span>
                                        </td>
                                        <td><span class="pill neutral"><%= student.getReservationCount() %> queued</span></td>
                                        <td><span class="pill <%= "ACTIVE".equalsIgnoreCase(student.getStatus()) ? "success" : "warning" %>"><%= DashboardViewHelper.escapeHtml(student.getStatus()) %></span></td>
                                        <td>
                                            <div class="table-actions">
                                                <a class="button-outline button-small" href="<%= contextPath %>/admin/students?edit=<%= student.getId() %><%= searchQuery.isBlank() ? "" : "&q=" + java.net.URLEncoder.encode(searchQuery, java.nio.charset.StandardCharsets.UTF_8) %>">Edit</a>
                                                <form action="<%= contextPath %>/admin/students" method="post">
                                                    <input type="hidden" name="action" value="delete">
                                                    <input type="hidden" name="userId" value="<%= student.getUserId() %>">
                                                    <input type="hidden" name="q" value="<%= DashboardViewHelper.escapeHtml(searchQuery) %>">
                                                    <button class="button-danger button-small" type="submit"
                                                            onclick="return confirm('Delete this student account? Their linked circulation history will also be removed.');">
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
