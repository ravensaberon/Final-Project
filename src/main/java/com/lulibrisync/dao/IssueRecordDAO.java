package com.lulibrisync.dao;

import com.lulibrisync.config.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

public class IssueRecordDAO {

    private static final int DEFAULT_LOAN_DAYS = 14;
    private static final DateTimeFormatter REFERENCE_FORMAT =
            DateTimeFormatter.ofPattern("yyyyMMddHHmmss", Locale.ENGLISH);

    public IssueResult issueBook(long studentDbId, long bookId, long adminUserId, String remarks) throws SQLException {
        String studentSql = "SELECT s.id, s.student_id, u.name, u.status "
                + "FROM students s "
                + "JOIN users u ON u.id = s.user_id "
                + "WHERE s.id = ?";
        String bookSql = "SELECT id, title, isbn, available_quantity FROM books WHERE id = ? FOR UPDATE";
        String insertSql = "INSERT INTO issue_records(book_id, student_id, issued_by, qr_issue_code, issue_date, due_date, status, fine_amount, remarks) "
                + "VALUES(?, ?, ?, ?, ?, ?, 'ISSUED', 0.00, ?)";
        String updateBookSql = "UPDATE books SET available_quantity = available_quantity - 1 WHERE id = ? AND available_quantity > 0";

        try (Connection conn = requireConnection()) {
            conn.setAutoCommit(false);
            try {
                StudentIssueContext student = loadStudentContext(conn, studentSql, studentDbId);
                if (student == null) {
                    throw new SQLException("Student record could not be found.");
                }
                if (!"ACTIVE".equalsIgnoreCase(student.status)) {
                    throw new IllegalStateException("student_inactive");
                }

                BookIssueContext book = loadBookContext(conn, bookSql, bookId);
                if (book == null) {
                    throw new SQLException("Book record could not be found.");
                }
                if (book.availableQuantity <= 0) {
                    throw new IllegalStateException("book_unavailable");
                }

                LocalDateTime issueDate = LocalDateTime.now();
                LocalDateTime dueDate = issueDate.plusDays(DEFAULT_LOAN_DAYS);
                String reference = generateReference(issueDate, studentDbId, bookId);

                try (PreparedStatement insertPs = conn.prepareStatement(insertSql)) {
                    insertPs.setLong(1, book.id);
                    insertPs.setLong(2, student.id);
                    insertPs.setLong(3, adminUserId);
                    insertPs.setString(4, reference);
                    insertPs.setTimestamp(5, Timestamp.valueOf(issueDate));
                    insertPs.setTimestamp(6, Timestamp.valueOf(dueDate));
                    insertPs.setString(7, normalizeOptional(remarks));
                    insertPs.executeUpdate();
                }

                try (PreparedStatement updatePs = conn.prepareStatement(updateBookSql)) {
                    updatePs.setLong(1, book.id);
                    int updatedRows = updatePs.executeUpdate();
                    if (updatedRows == 0) {
                        throw new IllegalStateException("book_unavailable");
                    }
                }

                conn.commit();
                return new IssueResult(reference, book.title, student.studentId, dueDate);
            } catch (Exception e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        }
    }

    public List<Map<String, Object>> findRecentIssues(int limit) throws SQLException {
        String sql = "SELECT s.student_id, u.name AS student_name, b.title AS book_title, "
                + "DATE_FORMAT(i.issue_date, '%Y-%m-%d %H:%i') AS issue_label, "
                + "DATE_FORMAT(i.due_date, '%Y-%m-%d %H:%i') AS due_label, "
                + "i.status, COALESCE(i.qr_issue_code, '') AS issue_reference "
                + "FROM issue_records i "
                + "JOIN students s ON s.id = i.student_id "
                + "JOIN users u ON u.id = s.user_id "
                + "JOIN books b ON b.id = i.book_id "
                + "ORDER BY i.issue_date DESC "
                + "LIMIT ?";

        try (Connection conn = requireConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                List<Map<String, Object>> rows = new ArrayList<>();
                while (rs.next()) {
                    Map<String, Object> row = new LinkedHashMap<>();
                    row.put("studentId", rs.getString("student_id"));
                    row.put("studentName", rs.getString("student_name"));
                    row.put("bookTitle", rs.getString("book_title"));
                    row.put("issueDate", rs.getString("issue_label"));
                    row.put("dueDate", rs.getString("due_label"));
                    row.put("status", humanizeStatus(rs.getString("status")));
                    row.put("tone", toneForStatus(rs.getString("status")));
                    row.put("reference", rs.getString("issue_reference"));
                    rows.add(row);
                }
                return rows;
            }
        }
    }

    private StudentIssueContext loadStudentContext(Connection conn, String sql, long studentDbId) throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, studentDbId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    return null;
                }
                return new StudentIssueContext(
                        rs.getLong("id"),
                        rs.getString("student_id"),
                        rs.getString("name"),
                        rs.getString("status")
                );
            }
        }
    }

    private BookIssueContext loadBookContext(Connection conn, String sql, long bookId) throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, bookId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    return null;
                }
                return new BookIssueContext(
                        rs.getLong("id"),
                        rs.getString("title"),
                        rs.getString("isbn"),
                        rs.getInt("available_quantity")
                );
            }
        }
    }

    private Connection requireConnection() throws SQLException {
        Connection conn = DBConnection.getConnection();
        if (conn == null) {
            throw new SQLException("Database connection is unavailable.");
        }
        return conn;
    }

    private String generateReference(LocalDateTime issueDate, long studentDbId, long bookId) {
        return "QR-ISSUE-" + issueDate.format(REFERENCE_FORMAT) + "-S" + studentDbId + "-B" + bookId;
    }

    private String normalizeOptional(String value) {
        String normalized = value == null ? "" : value.trim();
        return normalized.isEmpty() ? null : normalized;
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
            return "neutral";
        }
        return "success";
    }

    public int getDefaultLoanDays() {
        return DEFAULT_LOAN_DAYS;
    }

    public static final class IssueResult {
        private final String reference;
        private final String bookTitle;
        private final String studentId;
        private final LocalDateTime dueDate;

        public IssueResult(String reference, String bookTitle, String studentId, LocalDateTime dueDate) {
            this.reference = reference;
            this.bookTitle = bookTitle;
            this.studentId = studentId;
            this.dueDate = dueDate;
        }

        public String getReference() {
            return reference;
        }

        public String getBookTitle() {
            return bookTitle;
        }

        public String getStudentId() {
            return studentId;
        }

        public LocalDateTime getDueDate() {
            return dueDate;
        }
    }

    private static final class StudentIssueContext {
        private final long id;
        private final String studentId;
        private final String name;
        private final String status;

        private StudentIssueContext(long id, String studentId, String name, String status) {
            this.id = id;
            this.studentId = studentId;
            this.name = name;
            this.status = status;
        }
    }

    private static final class BookIssueContext {
        private final long id;
        private final String title;
        private final String isbn;
        private final int availableQuantity;

        private BookIssueContext(long id, String title, String isbn, int availableQuantity) {
            this.id = id;
            this.title = title;
            this.isbn = isbn;
            this.availableQuantity = availableQuantity;
        }
    }
}
