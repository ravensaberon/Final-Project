package com.lulibrisync.dao;

import com.lulibrisync.config.DBConnection;
import com.lulibrisync.model.Reservation;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

public class ReservationDAO {

    public List<Reservation> findByStudent(long studentDbId) throws SQLException {
        String sql = "SELECT r.id, r.book_id, r.student_id, b.title, b.isbn, b.is_digital, r.queue_position, "
                + "r.status, r.reserved_at, r.expires_at "
                + "FROM reservations r "
                + "JOIN books b ON b.id = r.book_id "
                + "WHERE r.student_id = ? "
                + "ORDER BY r.reserved_at DESC";

        try (Connection conn = requireConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, studentDbId);
            try (ResultSet rs = ps.executeQuery()) {
                List<Reservation> rows = new ArrayList<>();
                while (rs.next()) {
                    rows.add(mapReservation(rs));
                }
                return rows;
            }
        }
    }

    public List<Map<String, Object>> findQueueSnapshot(int limit) throws SQLException {
        String sql = "SELECT b.title, COUNT(*) AS queued_count, "
                + "SUM(CASE WHEN r.status = 'READY' THEN 1 ELSE 0 END) AS ready_count "
                + "FROM reservations r "
                + "JOIN books b ON b.id = r.book_id "
                + "WHERE r.status IN ('PENDING', 'READY', 'CLAIMED') "
                + "GROUP BY r.book_id, b.title "
                + "ORDER BY queued_count DESC, b.title ASC LIMIT ?";

        try (Connection conn = requireConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                List<Map<String, Object>> rows = new ArrayList<>();
                while (rs.next()) {
                    Map<String, Object> row = new LinkedHashMap<>();
                    row.put("title", rs.getString("title"));
                    row.put("queuedCount", rs.getInt("queued_count"));
                    row.put("readyCount", rs.getInt("ready_count"));
                    rows.add(row);
                }
                return rows;
            }
        }
    }

    public ReservationResult createReservation(long studentDbId, long bookId) throws SQLException {
        String activeReservationSql = "SELECT COUNT(*) FROM reservations "
                + "WHERE student_id = ? AND book_id = ? AND status IN ('PENDING', 'READY', 'CLAIMED')";
        String activeIssueSql = "SELECT COUNT(*) FROM issue_records "
                + "WHERE student_id = ? AND book_id = ? AND status IN ('ISSUED', 'OVERDUE')";
        String bookSql = "SELECT id, title, isbn, available_quantity FROM books WHERE id = ?";
        String queueSql = "SELECT COALESCE(MAX(queue_position), 0) FROM reservations "
                + "WHERE book_id = ? AND status IN ('PENDING', 'READY', 'CLAIMED')";
        String readySql = "SELECT COUNT(*) FROM reservations WHERE book_id = ? AND status = 'READY'";
        String insertSql = "INSERT INTO reservations(book_id, student_id, queue_position, status, reserved_at, expires_at) "
                + "VALUES(?, ?, ?, ?, ?, ?)";

        try (Connection conn = requireConnection()) {
            conn.setAutoCommit(false);
            try (PreparedStatement activeReservationPs = conn.prepareStatement(activeReservationSql);
                 PreparedStatement activeIssuePs = conn.prepareStatement(activeIssueSql);
                 PreparedStatement bookPs = conn.prepareStatement(bookSql);
                 PreparedStatement queuePs = conn.prepareStatement(queueSql);
                 PreparedStatement readyPs = conn.prepareStatement(readySql);
                 PreparedStatement insertPs = conn.prepareStatement(insertSql)) {

                activeReservationPs.setLong(1, studentDbId);
                activeReservationPs.setLong(2, bookId);
                try (ResultSet rs = activeReservationPs.executeQuery()) {
                    if (rs.next() && rs.getInt(1) > 0) {
                        throw new IllegalStateException("reservation_exists");
                    }
                }

                activeIssuePs.setLong(1, studentDbId);
                activeIssuePs.setLong(2, bookId);
                try (ResultSet rs = activeIssuePs.executeQuery()) {
                    if (rs.next() && rs.getInt(1) > 0) {
                        throw new IllegalStateException("already_issued");
                    }
                }

                String title = "";
                String isbn = "";
                int availableQuantity = 0;
                bookPs.setLong(1, bookId);
                try (ResultSet rs = bookPs.executeQuery()) {
                    if (!rs.next()) {
                        throw new SQLException("Book record could not be found.");
                    }
                    title = rs.getString("title");
                    isbn = rs.getString("isbn");
                    availableQuantity = rs.getInt("available_quantity");
                }

                int queuePosition = 1;
                queuePs.setLong(1, bookId);
                try (ResultSet rs = queuePs.executeQuery()) {
                    if (rs.next()) {
                        queuePosition = rs.getInt(1) + 1;
                    }
                }

                int readyCount = 0;
                readyPs.setLong(1, bookId);
                try (ResultSet rs = readyPs.executeQuery()) {
                    if (rs.next()) {
                        readyCount = rs.getInt(1);
                    }
                }

                LocalDateTime now = LocalDateTime.now();
                boolean readyNow = availableQuantity > 0 && readyCount == 0 && queuePosition == 1;
                String status = readyNow ? "READY" : "PENDING";
                LocalDateTime expiresAt = readyNow ? now.plusDays(2) : null;

                insertPs.setLong(1, bookId);
                insertPs.setLong(2, studentDbId);
                insertPs.setInt(3, queuePosition);
                insertPs.setString(4, status);
                insertPs.setTimestamp(5, Timestamp.valueOf(now));
                if (expiresAt == null) {
                    insertPs.setTimestamp(6, null);
                } else {
                    insertPs.setTimestamp(6, Timestamp.valueOf(expiresAt));
                }
                insertPs.executeUpdate();

                conn.commit();
                return new ReservationResult(title, isbn, queuePosition, status, expiresAt);
            } catch (Exception e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        }
    }

    public boolean cancelReservation(long reservationId, long studentDbId) throws SQLException {
        String lookupSql = "SELECT book_id FROM reservations "
                + "WHERE id = ? AND student_id = ? AND status IN ('PENDING', 'READY', 'CLAIMED')";
        String cancelSql = "UPDATE reservations SET status = 'CANCELLED', expires_at = NULL WHERE id = ?";

        try (Connection conn = requireConnection()) {
            conn.setAutoCommit(false);
            try (PreparedStatement lookupPs = conn.prepareStatement(lookupSql);
                 PreparedStatement cancelPs = conn.prepareStatement(cancelSql)) {

                lookupPs.setLong(1, reservationId);
                lookupPs.setLong(2, studentDbId);

                long bookId = 0L;
                try (ResultSet rs = lookupPs.executeQuery()) {
                    if (!rs.next()) {
                        conn.rollback();
                        return false;
                    }
                    bookId = rs.getLong("book_id");
                }

                cancelPs.setLong(1, reservationId);
                cancelPs.executeUpdate();
                resequenceQueue(conn, bookId);
                conn.commit();
                return true;
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        }
    }

    public void resequenceQueue(Connection conn, long bookId) throws SQLException {
        String sql = "SELECT id FROM reservations "
                + "WHERE book_id = ? AND status IN ('PENDING', 'READY', 'CLAIMED') "
                + "ORDER BY CASE status WHEN 'READY' THEN 0 WHEN 'CLAIMED' THEN 1 ELSE 2 END, reserved_at ASC";
        String updateSql = "UPDATE reservations SET queue_position = ? WHERE id = ?";

        try (PreparedStatement selectPs = conn.prepareStatement(sql);
             PreparedStatement updatePs = conn.prepareStatement(updateSql)) {
            selectPs.setLong(1, bookId);
            try (ResultSet rs = selectPs.executeQuery()) {
                int position = 1;
                while (rs.next()) {
                    updatePs.setInt(1, position++);
                    updatePs.setLong(2, rs.getLong("id"));
                    updatePs.addBatch();
                }
            }
            updatePs.executeBatch();
        }
    }

    public void createReadyNotification(Connection conn, long userId, String subject, String body,
                                        LocalDateTime scheduledAt) throws SQLException {
        String existsSql = "SELECT COUNT(*) FROM email_notifications "
                + "WHERE user_id = ? AND notification_type = 'RESERVATION_READY' AND subject = ? AND status IN ('PENDING', 'SENT')";
        String insertSql = "INSERT INTO email_notifications(user_id, notification_type, subject, body, scheduled_at, status) "
                + "VALUES(?, 'RESERVATION_READY', ?, ?, ?, 'PENDING')";

        try (PreparedStatement existsPs = conn.prepareStatement(existsSql)) {
            existsPs.setLong(1, userId);
            existsPs.setString(2, subject);
            try (ResultSet rs = existsPs.executeQuery()) {
                if (rs.next() && rs.getInt(1) > 0) {
                    return;
                }
            }
        }

        try (PreparedStatement insertPs = conn.prepareStatement(insertSql)) {
            insertPs.setLong(1, userId);
            insertPs.setString(2, subject);
            insertPs.setString(3, body);
            insertPs.setTimestamp(4, Timestamp.valueOf(scheduledAt));
            insertPs.executeUpdate();
        }
    }

    private Connection requireConnection() throws SQLException {
        Connection conn = DBConnection.getConnection();
        if (conn == null) {
            throw new SQLException("Database connection is unavailable.");
        }
        return conn;
    }

    private Reservation mapReservation(ResultSet rs) throws SQLException {
        Timestamp expiresAt = rs.getTimestamp("expires_at");
        return new Reservation(
                rs.getLong("id"),
                rs.getLong("book_id"),
                rs.getLong("student_id"),
                rs.getString("title"),
                rs.getString("isbn"),
                rs.getInt("queue_position"),
                rs.getString("status"),
                rs.getTimestamp("reserved_at").toLocalDateTime(),
                expiresAt == null ? null : expiresAt.toLocalDateTime(),
                rs.getBoolean("is_digital")
        );
    }

    public static String humanizeStatus(String status) {
        if (status == null || status.isBlank()) {
            return "Unknown";
        }
        String normalized = status.toLowerCase(Locale.ENGLISH);
        return Character.toUpperCase(normalized.charAt(0)) + normalized.substring(1);
    }

    public static final class ReservationResult {
        private final String title;
        private final String isbn;
        private final int queuePosition;
        private final String status;
        private final LocalDateTime expiresAt;

        public ReservationResult(String title, String isbn, int queuePosition, String status, LocalDateTime expiresAt) {
            this.title = title;
            this.isbn = isbn;
            this.queuePosition = queuePosition;
            this.status = status;
            this.expiresAt = expiresAt;
        }

        public String getTitle() {
            return title;
        }

        public String getIsbn() {
            return isbn;
        }

        public int getQueuePosition() {
            return queuePosition;
        }

        public String getStatus() {
            return status;
        }

        public LocalDateTime getExpiresAt() {
            return expiresAt;
        }
    }
}
