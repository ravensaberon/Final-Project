package com.lulibrisync.dao;

import com.lulibrisync.config.DBConnection;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.YearMonth;
import java.time.format.TextStyle;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

public class AnalyticsDAO {

    public Map<String, Object> loadOverview() throws SQLException {
        Map<String, Object> overview = new LinkedHashMap<>();
        overview.put("mostBorrowedTitle", loadMostBorrowedTitle());
        overview.put("reservationQueue", singleInt("SELECT COUNT(*) FROM reservations WHERE status IN ('PENDING', 'READY', 'CLAIMED')"));
        overview.put("pendingReminders", singleInt("SELECT COUNT(*) FROM email_notifications WHERE status = 'PENDING'"));
        overview.put("totalFineExposure", singleDouble("SELECT COALESCE(SUM(amount), 0) FROM fines WHERE status = 'UNPAID'"));

        int totalLoans = singleInt("SELECT COUNT(*) FROM issue_records");
        int overdueLoans = singleInt("SELECT COUNT(*) FROM issue_records WHERE status = 'OVERDUE'");
        int digitalTitles = singleInt("SELECT COUNT(*) FROM books WHERE is_digital = TRUE");
        int titles = singleInt("SELECT COUNT(*) FROM books");

        overview.put("totalLoans", totalLoans);
        overview.put("overdueLoans", overdueLoans);
        overview.put("overdueRate", totalLoans == 0 ? 0 : (int) Math.round((overdueLoans * 100.0) / totalLoans));
        overview.put("digitalCoverage", titles == 0 ? 0 : (int) Math.round((digitalTitles * 100.0) / titles));
        return overview;
    }

    public List<Map<String, Object>> loadMostBorrowedBooks(int limit) throws SQLException {
        String sql = "SELECT b.title AS label, COUNT(*) AS value "
                + "FROM issue_records i "
                + "JOIN books b ON b.id = i.book_id "
                + "GROUP BY i.book_id, b.title "
                + "ORDER BY value DESC, b.title ASC LIMIT ?";

        return queryChart(sql, limit, "success");
    }

    public List<Map<String, Object>> loadCategoryDemand(int limit) throws SQLException {
        String sql = "SELECT COALESCE(c.name, 'Uncategorized') AS label, COUNT(*) AS value "
                + "FROM issue_records i "
                + "JOIN books b ON b.id = i.book_id "
                + "LEFT JOIN categories c ON c.id = b.category_id "
                + "GROUP BY COALESCE(c.name, 'Uncategorized') "
                + "ORDER BY value DESC, label ASC LIMIT ?";

        return queryChart(sql, limit, "warning");
    }

    public List<Map<String, Object>> loadOverdueTrend(int months) throws SQLException {
        String sql = "SELECT DATE_FORMAT(due_date, '%Y-%m') AS month_key, COUNT(*) AS value "
                + "FROM issue_records "
                + "WHERE status = 'OVERDUE' AND due_date >= ? "
                + "GROUP BY DATE_FORMAT(due_date, '%Y-%m')";

        Map<String, Integer> values = new LinkedHashMap<>();
        YearMonth current = YearMonth.now();
        YearMonth start = current.minusMonths(Math.max(0, months - 1L));

        try (Connection conn = requireConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setDate(1, Date.valueOf(start.atDay(1)));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    values.put(rs.getString("month_key"), rs.getInt("value"));
                }
            }
        }

        List<Map<String, Object>> rows = new ArrayList<>();
        for (int i = 0; i < months; i++) {
            YearMonth month = start.plusMonths(i);
            Map<String, Object> row = new LinkedHashMap<>();
            row.put("label", month.getMonth().getDisplayName(TextStyle.SHORT, Locale.ENGLISH));
            row.put("value", values.getOrDefault(month.toString(), 0));
            row.put("tone", "danger");
            rows.add(row);
        }
        return rows;
    }

    public List<Map<String, Object>> loadReadingHistory(int limit) throws SQLException {
        String sql = "SELECT student_name, student_id, book_title, issue_date, due_date, return_date, status, fine_amount "
                + "FROM vw_student_reading_history "
                + "ORDER BY COALESCE(return_date, due_date, issue_date) DESC LIMIT ?";

        try (Connection conn = requireConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                List<Map<String, Object>> rows = new ArrayList<>();
                while (rs.next()) {
                    Map<String, Object> row = new LinkedHashMap<>();
                    row.put("studentName", rs.getString("student_name"));
                    row.put("studentId", rs.getString("student_id"));
                    row.put("bookTitle", rs.getString("book_title"));
                    row.put("issueDate", String.valueOf(rs.getTimestamp("issue_date")));
                    row.put("dueDate", String.valueOf(rs.getTimestamp("due_date")));
                    row.put("returnDate", rs.getTimestamp("return_date") == null
                            ? "Pending"
                            : String.valueOf(rs.getTimestamp("return_date")));
                    row.put("status", rs.getString("status"));
                    row.put("fineAmount", rs.getDouble("fine_amount"));
                    rows.add(row);
                }
                return rows;
            }
        }
    }

    public List<Map<String, Object>> loadTopReaders(int limit) throws SQLException {
        String sql = "SELECT u.name AS label, COUNT(*) AS value "
                + "FROM issue_records i "
                + "JOIN students s ON s.id = i.student_id "
                + "JOIN users u ON u.id = s.user_id "
                + "GROUP BY s.id, u.name "
                + "ORDER BY value DESC, u.name ASC LIMIT ?";

        return queryChart(sql, limit, "success");
    }

    public List<Map<String, Object>> loadAutomationQueue(int limit) throws SQLException {
        String sql = "SELECT notification_type, subject, status, scheduled_at "
                + "FROM email_notifications "
                + "ORDER BY CASE status WHEN 'PENDING' THEN 0 WHEN 'FAILED' THEN 1 ELSE 2 END, scheduled_at ASC "
                + "LIMIT ?";

        try (Connection conn = requireConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                List<Map<String, Object>> rows = new ArrayList<>();
                while (rs.next()) {
                    Map<String, Object> row = new LinkedHashMap<>();
                    String type = rs.getString("notification_type");
                    row.put("type", humanizeType(type));
                    row.put("subject", rs.getString("subject"));
                    row.put("status", humanizeType(rs.getString("status")));
                    row.put("scheduledAt", rs.getTimestamp("scheduled_at") == null
                            ? "Queue now"
                            : String.valueOf(rs.getTimestamp("scheduled_at")));
                    row.put("tone", "FAILED".equalsIgnoreCase(rs.getString("status"))
                            ? "danger"
                            : ("SENT".equalsIgnoreCase(rs.getString("status")) ? "success" : "warning"));
                    rows.add(row);
                }
                return rows;
            }
        }
    }

    private List<Map<String, Object>> queryChart(String sql, int limit, String tone) throws SQLException {
        try (Connection conn = requireConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                List<Map<String, Object>> rows = new ArrayList<>();
                while (rs.next()) {
                    Map<String, Object> row = new LinkedHashMap<>();
                    row.put("label", rs.getString("label"));
                    row.put("value", rs.getInt("value"));
                    row.put("tone", tone);
                    rows.add(row);
                }
                return rows;
            }
        }
    }

    private int singleInt(String sql) throws SQLException {
        try (Connection conn = requireConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        }
    }

    private double singleDouble(String sql) throws SQLException {
        try (Connection conn = requireConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getDouble(1) : 0.0d;
        }
    }

    private String loadMostBorrowedTitle() throws SQLException {
        String sql = "SELECT b.title FROM issue_records i "
                + "JOIN books b ON b.id = i.book_id "
                + "GROUP BY i.book_id, b.title "
                + "ORDER BY COUNT(*) DESC, b.title ASC LIMIT 1";

        try (Connection conn = requireConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getString(1) : "No data yet";
        }
    }

    private Connection requireConnection() throws SQLException {
        Connection conn = DBConnection.getConnection();
        if (conn == null) {
            throw new SQLException("Database connection is unavailable.");
        }
        return conn;
    }

    private String humanizeType(String value) {
        if (value == null || value.isBlank()) {
            return "Unknown";
        }
        String normalized = value.toLowerCase(Locale.ENGLISH).replace('_', ' ');
        return Character.toUpperCase(normalized.charAt(0)) + normalized.substring(1);
    }
}
