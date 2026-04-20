package com.lulibrisync.controller.admin;

import com.lulibrisync.config.DBConnection;
import com.lulibrisync.service.LibraryAutomationService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
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

@WebServlet("/admin/dashboard")
public class AdminDashboardServlet extends HttpServlet {

    private static final DecimalFormat WHOLE_PERCENT = new DecimalFormat("0");
    private final LibraryAutomationService automationService = new LibraryAutomationService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try (Connection conn = requireConnection()) {
            automationService.runMaintenance();
            Map<String, Integer> overview = loadOverview(conn);
            List<Map<String, Object>> categoryMix = withBarPercent(loadCategoryMix(conn));
            List<Map<String, Object>> circulationTrend = withBarPercent(loadMonthlyCirculation(conn));
            List<Map<String, Object>> statusBreakdown = loadStatusBreakdown(conn);
            List<Map<String, Object>> recentActivity = loadRecentActivity(conn);
            List<Map<String, Object>> lowStockBooks = loadLowStockBooks(conn);
            List<Map<String, Object>> reservationPressure = withBarPercent(loadReservationPressure(conn));

            int issuedBooks = overview.get("issuedBooks");
            int overdueBooks = overview.get("overdueBooks");
            int activeLoanBase = issuedBooks + overdueBooks;
            int onTrackPercent = activeLoanBase == 0 ? 100 : percent(issuedBooks, activeLoanBase);
            int digitalCoverage = overview.get("totalBooks") == 0
                    ? 0
                    : percent(overview.get("digitalTitles"), overview.get("totalBooks"));

            request.setAttribute("totalBooks", overview.get("totalBooks"));
            request.setAttribute("totalStudents", overview.get("totalStudents"));
            request.setAttribute("issuedBooks", issuedBooks);
            request.setAttribute("overdueBooks", overdueBooks);
            request.setAttribute("reservationCount", overview.get("reservationCount"));
            request.setAttribute("digitalTitles", overview.get("digitalTitles"));
            request.setAttribute("totalCopies", overview.get("totalCopies"));
            request.setAttribute("onTrackPercent", onTrackPercent);
            request.setAttribute("digitalCoverage", digitalCoverage);
            request.setAttribute("categoryMix", categoryMix);
            request.setAttribute("circulationTrend", circulationTrend);
            request.setAttribute("statusBreakdown", statusBreakdown);
            request.setAttribute("recentActivity", recentActivity);
            request.setAttribute("lowStockBooks", lowStockBooks);
            request.setAttribute("reservationPressure", reservationPressure);

            request.getRequestDispatcher("/views/admin/dashboard.jsp").forward(request, response);
        } catch (Exception e) {
            throw new ServletException("Unable to load admin dashboard.", e);
        }
    }

    private Connection requireConnection() throws SQLException {
        Connection conn = DBConnection.getConnection();
        if (conn == null) {
            throw new SQLException("Database connection is unavailable.");
        }
        return conn;
    }

    private Map<String, Integer> loadOverview(Connection conn) throws SQLException {
        Map<String, Integer> overview = new LinkedHashMap<>();

        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT COUNT(*) AS total_books, COALESCE(SUM(quantity), 0) AS total_copies, "
                        + "COALESCE(SUM(CASE WHEN is_digital THEN 1 ELSE 0 END), 0) AS digital_titles "
                        + "FROM books");
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                overview.put("totalBooks", rs.getInt("total_books"));
                overview.put("totalCopies", rs.getInt("total_copies"));
                overview.put("digitalTitles", rs.getInt("digital_titles"));
            }
        }

        overview.put("totalStudents", singleCount(conn, "SELECT COUNT(*) FROM students"));
        overview.put("issuedBooks", singleCount(conn, "SELECT COUNT(*) FROM issue_records WHERE status = 'ISSUED'"));
        overview.put("overdueBooks", singleCount(conn, "SELECT COUNT(*) FROM issue_records WHERE status = 'OVERDUE'"));
        overview.put("reservationCount",
                singleCount(conn, "SELECT COUNT(*) FROM reservations WHERE status IN ('PENDING', 'READY')"));

        return overview;
    }

    private int singleCount(Connection conn, String sql) throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        }
    }

    private List<Map<String, Object>> loadCategoryMix(Connection conn) throws SQLException {
        String sql = "SELECT COALESCE(c.name, 'Uncategorized') AS label, COUNT(b.id) AS value "
                + "FROM books b "
                + "LEFT JOIN categories c ON c.id = b.category_id "
                + "GROUP BY COALESCE(c.name, 'Uncategorized') "
                + "ORDER BY value DESC, label ASC LIMIT 6";

        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            List<Map<String, Object>> rows = new ArrayList<>();
            while (rs.next()) {
                rows.add(chartPoint(rs.getString("label"), rs.getInt("value"), "success"));
            }
            return rows;
        }
    }

    private List<Map<String, Object>> loadMonthlyCirculation(Connection conn) throws SQLException {
        String sql = "SELECT DATE_FORMAT(issue_date, '%Y-%m') AS month_key, COUNT(*) AS value "
                + "FROM issue_records "
                + "WHERE issue_date >= ? "
                + "GROUP BY DATE_FORMAT(issue_date, '%Y-%m')";

        Map<String, Integer> valuesByMonth = new LinkedHashMap<>();
        YearMonth current = YearMonth.now();
        YearMonth startMonth = current.minusMonths(5);

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setDate(1, Date.valueOf(startMonth.atDay(1)));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    valuesByMonth.put(rs.getString("month_key"), rs.getInt("value"));
                }
            }
        }

        List<Map<String, Object>> rows = new ArrayList<>();
        for (int i = 0; i < 6; i++) {
            YearMonth month = startMonth.plusMonths(i);
            String key = month.toString();
            String label = month.getMonth().getDisplayName(TextStyle.SHORT, Locale.ENGLISH);
            rows.add(chartPoint(label, valuesByMonth.getOrDefault(key, 0), "success"));
        }
        return rows;
    }

    private List<Map<String, Object>> loadStatusBreakdown(Connection conn) throws SQLException {
        String sql = "SELECT status, COUNT(*) AS value FROM issue_records GROUP BY status";
        Map<String, Integer> counts = new LinkedHashMap<>();
        counts.put("ISSUED", 0);
        counts.put("RETURNED", 0);
        counts.put("OVERDUE", 0);

        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                counts.put(rs.getString("status"), rs.getInt("value"));
            }
        }

        int total = 0;
        for (int value : counts.values()) {
            total += value;
        }

        List<Map<String, Object>> rows = new ArrayList<>();
        rows.add(statusPoint("Issued", counts.get("ISSUED"), total, "success"));
        rows.add(statusPoint("Returned", counts.get("RETURNED"), total, "warning"));
        rows.add(statusPoint("Overdue", counts.get("OVERDUE"), total, "danger"));
        return rows;
    }

    private List<Map<String, Object>> loadRecentActivity(Connection conn) throws SQLException {
        String sql = "SELECT u.name AS student_name, s.student_id, b.title, i.status, i.issue_date, i.return_date "
                + "FROM issue_records i "
                + "JOIN students s ON s.id = i.student_id "
                + "JOIN users u ON u.id = s.user_id "
                + "JOIN books b ON b.id = i.book_id "
                + "ORDER BY COALESCE(i.return_date, i.issue_date) DESC LIMIT 6";

        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            List<Map<String, Object>> rows = new ArrayList<>();
            while (rs.next()) {
                Timestamp activityTime = rs.getTimestamp("return_date");
                if (activityTime == null) {
                    activityTime = rs.getTimestamp("issue_date");
                }

                Map<String, Object> row = new LinkedHashMap<>();
                row.put("student", rs.getString("student_name"));
                row.put("studentId", rs.getString("student_id"));
                row.put("book", rs.getString("title"));
                row.put("status", humanizeStatus(rs.getString("status")));
                row.put("tone", toneForStatus(rs.getString("status")));
                row.put("dateLabel", formatTimestamp(activityTime));
                rows.add(row);
            }
            return rows;
        }
    }

    private List<Map<String, Object>> loadLowStockBooks(Connection conn) throws SQLException {
        String sql = "SELECT title, available_quantity, quantity "
                + "FROM books "
                + "ORDER BY available_quantity ASC, title ASC LIMIT 5";

        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            List<Map<String, Object>> rows = new ArrayList<>();
            while (rs.next()) {
                int available = rs.getInt("available_quantity");
                int quantity = rs.getInt("quantity");
                Map<String, Object> row = new LinkedHashMap<>();
                row.put("title", rs.getString("title"));
                row.put("availability", available + " of " + quantity + " copies available");
                row.put("tone", available <= 1 ? "danger" : (available <= 2 ? "warning" : "neutral"));
                rows.add(row);
            }
            return rows;
        }
    }

    private List<Map<String, Object>> loadReservationPressure(Connection conn) throws SQLException {
        String sql = "SELECT b.title AS label, COUNT(r.id) AS value "
                + "FROM reservations r "
                + "JOIN books b ON b.id = r.book_id "
                + "WHERE r.status IN ('PENDING', 'READY') "
                + "GROUP BY b.id, b.title "
                + "ORDER BY value DESC, b.title ASC LIMIT 5";

        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            List<Map<String, Object>> rows = new ArrayList<>();
            while (rs.next()) {
                rows.add(chartPoint(rs.getString("label"), rs.getInt("value"), "warning"));
            }
            return rows;
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

    private String humanizeStatus(String status) {
        if (status == null || status.isBlank()) {
            return "Unknown";
        }
        String lower = status.toLowerCase(Locale.ENGLISH);
        return Character.toUpperCase(lower.charAt(0)) + lower.substring(1);
    }

    private String toneForStatus(String status) {
        if ("OVERDUE".equalsIgnoreCase(status)) {
            return "danger";
        }
        if ("RETURNED".equalsIgnoreCase(status)) {
            return "warning";
        }
        return "success";
    }

    private String formatTimestamp(Timestamp timestamp) {
        if (timestamp == null) {
            return "No activity yet";
        }
        LocalDate date = timestamp.toLocalDateTime().toLocalDate();
        return date.getMonth().getDisplayName(TextStyle.SHORT, Locale.ENGLISH) + " " + date.getDayOfMonth()
                + ", " + date.getYear();
    }
}
