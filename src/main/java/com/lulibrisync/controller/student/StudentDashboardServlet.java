package com.lulibrisync.controller.student;

import com.lulibrisync.config.DBConnection;
import com.lulibrisync.service.LibraryAutomationService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.text.DecimalFormat;
import java.time.LocalDate;
import java.time.YearMonth;
import java.time.format.TextStyle;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

@WebServlet("/student/dashboard")
public class StudentDashboardServlet extends HttpServlet {

    private static final DecimalFormat WHOLE_PERCENT = new DecimalFormat("0");
    private final LibraryAutomationService automationService = new LibraryAutomationService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/views/auth/login.jsp");
            return;
        }

        long userId = toLong(session.getAttribute("userId"));

        try (Connection conn = requireConnection()) {
            automationService.runMaintenance();
            StudentContext context = loadStudentContext(conn, userId);
            if (context == null) {
                response.sendRedirect(request.getContextPath() + "/views/auth/login.jsp");
                return;
            }

            Map<String, Integer> overview = loadOverview(conn, context.studentDbId);
            List<Map<String, Object>> monthlyActivity = withBarPercent(loadMonthlyActivity(conn, context.studentDbId));
            List<Map<String, Object>> categoryInterest = withBarPercent(loadCategoryInterest(conn, context.studentDbId));
            List<Map<String, Object>> statusBreakdown = loadStatusBreakdown(conn, context.studentDbId);
            List<Map<String, Object>> currentLoans = loadCurrentLoans(conn, context.studentDbId);
            List<Map<String, Object>> reservationQueue = loadReservationQueue(conn, context.studentDbId);

            int activeLoans = overview.get("activeLoans");
            int overdueLoans = overview.get("overdueLoans");
            int activeBase = activeLoans + overdueLoans;
            int onTrackPercent = activeBase == 0 ? 100 : percent(activeLoans, activeBase);

            request.setAttribute("studentCourse", context.course);
            request.setAttribute("studentYearLevel", context.yearLevel);
            request.setAttribute("studentPhone", context.phone);
            request.setAttribute("studentAddress", context.address);
            request.setAttribute("studentStudentId", context.studentId);
            request.setAttribute("activeLoans", activeLoans);
            request.setAttribute("overdueLoans", overdueLoans);
            request.setAttribute("reservationCount", overview.get("reservationCount"));
            request.setAttribute("completedLoans", overview.get("completedLoans"));
            request.setAttribute("outstandingFines", overview.get("outstandingFines"));
            request.setAttribute("onTrackPercent", onTrackPercent);
            request.setAttribute("monthlyActivity", monthlyActivity);
            request.setAttribute("categoryInterest", categoryInterest);
            request.setAttribute("statusBreakdown", statusBreakdown);
            request.setAttribute("currentLoans", currentLoans);
            request.setAttribute("reservationQueue", reservationQueue);

            request.getRequestDispatcher("/views/student/dashboard.jsp").forward(request, response);
        } catch (Exception e) {
            throw new ServletException("Unable to load student dashboard.", e);
        }
    }

    private Connection requireConnection() throws SQLException {
        Connection conn = DBConnection.getConnection();
        if (conn == null) {
            throw new SQLException("Database connection is unavailable.");
        }
        return conn;
    }

    private StudentContext loadStudentContext(Connection conn, long userId) throws SQLException {
        String sql = "SELECT s.id, s.student_id, COALESCE(s.course, 'Not set') AS course, "
                + "COALESCE(s.year_level, 'Not set') AS year_level, COALESCE(s.phone, 'Not set') AS phone, "
                + "COALESCE(s.address, 'No address on file') AS address "
                + "FROM students s WHERE s.user_id = ?";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    return null;
                }
                return new StudentContext(
                        rs.getLong("id"),
                        rs.getString("student_id"),
                        rs.getString("course"),
                        rs.getString("year_level"),
                        rs.getString("phone"),
                        rs.getString("address")
                );
            }
        }
    }

    private Map<String, Integer> loadOverview(Connection conn, long studentDbId) throws SQLException {
        Map<String, Integer> overview = new LinkedHashMap<>();

        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT "
                        + "COALESCE(SUM(CASE WHEN status = 'ISSUED' THEN 1 ELSE 0 END), 0) AS active_loans, "
                        + "COALESCE(SUM(CASE WHEN status = 'OVERDUE' THEN 1 ELSE 0 END), 0) AS overdue_loans, "
                        + "COALESCE(SUM(CASE WHEN status = 'RETURNED' THEN 1 ELSE 0 END), 0) AS completed_loans "
                        + "FROM issue_records WHERE student_id = ?")) {

            ps.setLong(1, studentDbId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    overview.put("activeLoans", rs.getInt("active_loans"));
                    overview.put("overdueLoans", rs.getInt("overdue_loans"));
                    overview.put("completedLoans", rs.getInt("completed_loans"));
                }
            }
        }

        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT COUNT(*) FROM reservations WHERE student_id = ? AND status IN ('PENDING', 'READY')")) {
            ps.setLong(1, studentDbId);
            try (ResultSet rs = ps.executeQuery()) {
                overview.put("reservationCount", rs.next() ? rs.getInt(1) : 0);
            }
        }

        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT COALESCE(SUM(amount), 0) FROM fines WHERE student_id = ? AND status = 'UNPAID'")) {
            ps.setLong(1, studentDbId);
            try (ResultSet rs = ps.executeQuery()) {
                overview.put("outstandingFines", rs.next() ? rs.getInt(1) : 0);
            }
        }

        return overview;
    }

    private List<Map<String, Object>> loadMonthlyActivity(Connection conn, long studentDbId) throws SQLException {
        String sql = "SELECT DATE_FORMAT(issue_date, '%Y-%m') AS month_key, COUNT(*) AS value "
                + "FROM issue_records WHERE student_id = ? AND issue_date >= ? "
                + "GROUP BY DATE_FORMAT(issue_date, '%Y-%m')";

        Map<String, Integer> valuesByMonth = new LinkedHashMap<>();
        YearMonth current = YearMonth.now();
        YearMonth startMonth = current.minusMonths(5);

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, studentDbId);
            ps.setDate(2, Date.valueOf(startMonth.atDay(1)));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    valuesByMonth.put(rs.getString("month_key"), rs.getInt("value"));
                }
            }
        }

        List<Map<String, Object>> rows = new ArrayList<>();
        for (int i = 0; i < 6; i++) {
            YearMonth month = startMonth.plusMonths(i);
            String label = month.getMonth().getDisplayName(TextStyle.SHORT, Locale.ENGLISH);
            rows.add(chartPoint(label, valuesByMonth.getOrDefault(month.toString(), 0), "success"));
        }
        return rows;
    }

    private List<Map<String, Object>> loadCategoryInterest(Connection conn, long studentDbId) throws SQLException {
        String sql = "SELECT COALESCE(c.name, 'Uncategorized') AS label, COUNT(i.id) AS value "
                + "FROM issue_records i "
                + "JOIN books b ON b.id = i.book_id "
                + "LEFT JOIN categories c ON c.id = b.category_id "
                + "WHERE i.student_id = ? "
                + "GROUP BY COALESCE(c.name, 'Uncategorized') "
                + "ORDER BY value DESC, label ASC LIMIT 5";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, studentDbId);
            try (ResultSet rs = ps.executeQuery()) {
                List<Map<String, Object>> rows = new ArrayList<>();
                while (rs.next()) {
                    rows.add(chartPoint(rs.getString("label"), rs.getInt("value"), "success"));
                }
                return rows;
            }
        }
    }

    private List<Map<String, Object>> loadStatusBreakdown(Connection conn, long studentDbId) throws SQLException {
        String sql = "SELECT status, COUNT(*) AS value FROM issue_records WHERE student_id = ? GROUP BY status";
        Map<String, Integer> counts = new LinkedHashMap<>();
        counts.put("ISSUED", 0);
        counts.put("RETURNED", 0);
        counts.put("OVERDUE", 0);

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, studentDbId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    counts.put(rs.getString("status"), rs.getInt("value"));
                }
            }
        }

        int total = 0;
        for (int value : counts.values()) {
            total += value;
        }

        List<Map<String, Object>> rows = new ArrayList<>();
        rows.add(statusPoint("Active", counts.get("ISSUED"), total, "success"));
        rows.add(statusPoint("Returned", counts.get("RETURNED"), total, "warning"));
        rows.add(statusPoint("Overdue", counts.get("OVERDUE"), total, "danger"));
        return rows;
    }

    private List<Map<String, Object>> loadCurrentLoans(Connection conn, long studentDbId) throws SQLException {
        String sql = "SELECT b.title, i.due_date, i.status, COALESCE(i.fine_amount, 0) AS fine_amount "
                + "FROM issue_records i "
                + "JOIN books b ON b.id = i.book_id "
                + "WHERE i.student_id = ? AND i.status IN ('ISSUED', 'OVERDUE') "
                + "ORDER BY i.due_date ASC LIMIT 5";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, studentDbId);
            try (ResultSet rs = ps.executeQuery()) {
                List<Map<String, Object>> rows = new ArrayList<>();
                while (rs.next()) {
                    String status = rs.getString("status");
                    Map<String, Object> row = new LinkedHashMap<>();
                    row.put("title", rs.getString("title"));
                    row.put("dueDate", formatTimestamp(rs.getTimestamp("due_date")));
                    row.put("status", "OVERDUE".equalsIgnoreCase(status) ? "Overdue" : "Due soon");
                    row.put("tone", "OVERDUE".equalsIgnoreCase(status) ? "danger" : "warning");
                    row.put("fineAmount", rs.getInt("fine_amount"));
                    rows.add(row);
                }
                return rows;
            }
        }
    }

    private List<Map<String, Object>> loadReservationQueue(Connection conn, long studentDbId) throws SQLException {
        String sql = "SELECT b.title, r.status, r.queue_position, r.reserved_at "
                + "FROM reservations r "
                + "JOIN books b ON b.id = r.book_id "
                + "WHERE r.student_id = ? AND r.status IN ('PENDING', 'READY', 'CLAIMED') "
                + "ORDER BY r.reserved_at DESC LIMIT 5";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, studentDbId);
            try (ResultSet rs = ps.executeQuery()) {
                List<Map<String, Object>> rows = new ArrayList<>();
                while (rs.next()) {
                    String status = rs.getString("status");
                    Map<String, Object> row = new LinkedHashMap<>();
                    row.put("title", rs.getString("title"));
                    row.put("status", humanizeStatus(status));
                    row.put("tone", "READY".equalsIgnoreCase(status)
                            ? "success"
                            : ("CLAIMED".equalsIgnoreCase(status) ? "neutral" : "warning"));
                    row.put("queue", "Queue #" + rs.getInt("queue_position"));
                    row.put("reservedAt", formatTimestamp(rs.getTimestamp("reserved_at")));
                    rows.add(row);
                }
                return rows;
            }
        }
    }

    private List<Map<String, Object>> withBarPercent(List<Map<String, Object>> rows) {
        int max = 1;
        for (Map<String, Object> row : rows) {
            max = Math.max(max, ((Number) row.get("value")).intValue());
        }
        for (Map<String, Object> row : rows) {
            int value = ((Number) row.get("value")).intValue();
            row.put("percent", value == 0 ? 6 : percent(value, max));
        }
        return rows;
    }

    private Map<String, Object> chartPoint(String label, int value, String tone) {
        Map<String, Object> row = new LinkedHashMap<>();
        row.put("label", label);
        row.put("value", value);
        row.put("tone", tone);
        row.put("percent", 0);
        return row;
    }

    private Map<String, Object> statusPoint(String label, int value, int total, String tone) {
        Map<String, Object> row = new LinkedHashMap<>();
        row.put("label", label);
        row.put("value", value);
        row.put("tone", tone);
        row.put("share", total == 0 ? "0%" : WHOLE_PERCENT.format((value * 100.0) / total) + "%");
        return row;
    }

    private int percent(int value, int total) {
        if (total <= 0) {
            return 0;
        }
        return (int) Math.round((value * 100.0) / total);
    }

    private long toLong(Object value) {
        if (value instanceof Number) {
            return ((Number) value).longValue();
        }
        return Long.parseLong(String.valueOf(value));
    }

    private String humanizeStatus(String status) {
        if (status == null || status.isBlank()) {
            return "Unknown";
        }
        String lower = status.toLowerCase(Locale.ENGLISH);
        return Character.toUpperCase(lower.charAt(0)) + lower.substring(1);
    }

    private String formatTimestamp(Timestamp timestamp) {
        if (timestamp == null) {
            return "No date available";
        }
        LocalDate date = timestamp.toLocalDateTime().toLocalDate();
        return date.getMonth().getDisplayName(TextStyle.SHORT, Locale.ENGLISH) + " " + date.getDayOfMonth()
                + ", " + date.getYear();
    }

    private static final class StudentContext {
        private final long studentDbId;
        private final String studentId;
        private final String course;
        private final String yearLevel;
        private final String phone;
        private final String address;

        private StudentContext(long studentDbId, String studentId, String course, String yearLevel,
                               String phone, String address) {
            this.studentDbId = studentDbId;
            this.studentId = studentId;
            this.course = course;
            this.yearLevel = yearLevel;
            this.phone = phone;
            this.address = address;
        }
    }
}
