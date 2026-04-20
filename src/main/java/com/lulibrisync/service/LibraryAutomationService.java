package com.lulibrisync.service;

import com.lulibrisync.config.DBConnection;
import com.lulibrisync.dao.ReservationDAO;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.List;

public class LibraryAutomationService {

    private static final double DAILY_FINE = 10.0d;
    private final ReservationDAO reservationDAO = new ReservationDAO();

    public void runMaintenance() throws SQLException {
        try (Connection conn = requireConnection()) {
            conn.setAutoCommit(false);
            try {
                expireReadyReservations(conn);
                syncOverduesAndFines(conn);
                queueDueReminders(conn);
                promoteReservationQueue(conn);
                conn.commit();
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        }
    }

    private void expireReadyReservations(Connection conn) throws SQLException {
        String selectSql = "SELECT id, book_id FROM reservations "
                + "WHERE status = 'READY' AND expires_at IS NOT NULL AND expires_at < ?";
        String updateSql = "UPDATE reservations SET status = 'CANCELLED', expires_at = NULL WHERE id = ?";

        List<Long> affectedBooks = new ArrayList<>();
        try (PreparedStatement selectPs = conn.prepareStatement(selectSql);
             PreparedStatement updatePs = conn.prepareStatement(updateSql)) {
            selectPs.setTimestamp(1, Timestamp.valueOf(LocalDateTime.now()));
            try (ResultSet rs = selectPs.executeQuery()) {
                while (rs.next()) {
                    affectedBooks.add(rs.getLong("book_id"));
                    updatePs.setLong(1, rs.getLong("id"));
                    updatePs.addBatch();
                }
            }
            updatePs.executeBatch();
        }

        for (Long bookId : affectedBooks) {
            reservationDAO.resequenceQueue(conn, bookId);
        }
    }

    private void syncOverduesAndFines(Connection conn) throws SQLException {
        String selectSql = "SELECT id, student_id, due_date FROM issue_records "
                + "WHERE status IN ('ISSUED', 'OVERDUE') AND return_date IS NULL AND due_date < ?";
        String updateIssueSql = "UPDATE issue_records SET status = 'OVERDUE', fine_amount = ? WHERE id = ?";
        String selectFineSql = "SELECT id, status FROM fines WHERE issue_record_id = ?";
        String insertFineSql = "INSERT INTO fines(issue_record_id, student_id, amount, status, calculated_at) "
                + "VALUES(?, ?, ?, 'UNPAID', ?)";
        String updateFineSql = "UPDATE fines SET amount = ?, calculated_at = ? WHERE id = ? AND status = 'UNPAID'";

        try (PreparedStatement selectPs = conn.prepareStatement(selectSql);
             PreparedStatement updateIssuePs = conn.prepareStatement(updateIssueSql);
             PreparedStatement selectFinePs = conn.prepareStatement(selectFineSql);
             PreparedStatement insertFinePs = conn.prepareStatement(insertFineSql);
             PreparedStatement updateFinePs = conn.prepareStatement(updateFineSql)) {

            selectPs.setTimestamp(1, Timestamp.valueOf(LocalDateTime.now()));
            try (ResultSet rs = selectPs.executeQuery()) {
                while (rs.next()) {
                    long issueId = rs.getLong("id");
                    long studentId = rs.getLong("student_id");
                    LocalDateTime dueDate = rs.getTimestamp("due_date").toLocalDateTime();
                    long daysOverdue = Math.max(1L, ChronoUnit.DAYS.between(dueDate.toLocalDate(), LocalDateTime.now().toLocalDate()));
                    double fineAmount = daysOverdue * DAILY_FINE;
                    Timestamp now = Timestamp.valueOf(LocalDateTime.now());

                    updateIssuePs.setDouble(1, fineAmount);
                    updateIssuePs.setLong(2, issueId);
                    updateIssuePs.addBatch();

                    selectFinePs.setLong(1, issueId);
                    try (ResultSet fineRs = selectFinePs.executeQuery()) {
                        if (fineRs.next()) {
                            updateFinePs.setDouble(1, fineAmount);
                            updateFinePs.setTimestamp(2, now);
                            updateFinePs.setLong(3, fineRs.getLong("id"));
                            updateFinePs.addBatch();
                        } else {
                            insertFinePs.setLong(1, issueId);
                            insertFinePs.setLong(2, studentId);
                            insertFinePs.setDouble(3, fineAmount);
                            insertFinePs.setTimestamp(4, now);
                            insertFinePs.addBatch();
                        }
                    }
                }
            }

            updateIssuePs.executeBatch();
            updateFinePs.executeBatch();
            insertFinePs.executeBatch();
        }
    }

    private void queueDueReminders(Connection conn) throws SQLException {
        String sql = "SELECT i.id, u.id AS user_id, u.name, b.title, i.due_date "
                + "FROM issue_records i "
                + "JOIN students s ON s.id = i.student_id "
                + "JOIN users u ON u.id = s.user_id "
                + "JOIN books b ON b.id = i.book_id "
                + "WHERE i.status = 'ISSUED' AND i.return_date IS NULL "
                + "AND i.due_date BETWEEN ? AND ?";
        String existsSql = "SELECT COUNT(*) FROM email_notifications "
                + "WHERE user_id = ? AND notification_type = 'DUE_REMINDER' AND subject = ? AND status IN ('PENDING', 'SENT')";
        String insertSql = "INSERT INTO email_notifications(user_id, notification_type, subject, body, scheduled_at, status) "
                + "VALUES(?, 'DUE_REMINDER', ?, ?, ?, 'PENDING')";

        try (PreparedStatement ps = conn.prepareStatement(sql);
             PreparedStatement existsPs = conn.prepareStatement(existsSql);
             PreparedStatement insertPs = conn.prepareStatement(insertSql)) {

            LocalDateTime now = LocalDateTime.now();
            ps.setTimestamp(1, Timestamp.valueOf(now));
            ps.setTimestamp(2, Timestamp.valueOf(now.plusDays(2)));

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    long userId = rs.getLong("user_id");
                    String title = rs.getString("title");
                    LocalDateTime dueDate = rs.getTimestamp("due_date").toLocalDateTime();
                    String subject = "Reminder: " + title + " is due soon";
                    String body = "Hello " + rs.getString("name") + ", your borrowed book \"" + title
                            + "\" is due on " + dueDate.toLocalDate() + ".";

                    existsPs.setLong(1, userId);
                    existsPs.setString(2, subject);
                    try (ResultSet existsRs = existsPs.executeQuery()) {
                        if (existsRs.next() && existsRs.getInt(1) > 0) {
                            continue;
                        }
                    }

                    insertPs.setLong(1, userId);
                    insertPs.setString(2, subject);
                    insertPs.setString(3, body);
                    insertPs.setTimestamp(4, Timestamp.valueOf(now));
                    insertPs.addBatch();
                }
            }

            insertPs.executeBatch();
        }
    }

    private void promoteReservationQueue(Connection conn) throws SQLException {
        String booksSql = "SELECT b.id, b.title, b.available_quantity, ready_summary.ready_count "
                + "FROM books b "
                + "JOIN (SELECT DISTINCT book_id FROM reservations WHERE status = 'PENDING') pending ON pending.book_id = b.id "
                + "LEFT JOIN ("
                + "    SELECT book_id, COUNT(*) AS ready_count FROM reservations WHERE status = 'READY' GROUP BY book_id"
                + ") ready_summary ON ready_summary.book_id = b.id";
        String nextPendingSql = "SELECT r.id, r.student_id, u.id AS user_id, u.name "
                + "FROM reservations r "
                + "JOIN students s ON s.id = r.student_id "
                + "JOIN users u ON u.id = s.user_id "
                + "WHERE r.book_id = ? AND r.status = 'PENDING' "
                + "ORDER BY r.reserved_at ASC LIMIT 1";
        String promoteSql = "UPDATE reservations SET status = 'READY', expires_at = ? WHERE id = ?";

        try (PreparedStatement booksPs = conn.prepareStatement(booksSql);
             PreparedStatement nextPendingPs = conn.prepareStatement(nextPendingSql);
             PreparedStatement promotePs = conn.prepareStatement(promoteSql)) {

            try (ResultSet rs = booksPs.executeQuery()) {
                while (rs.next()) {
                    long bookId = rs.getLong("id");
                    String title = rs.getString("title");
                    int availableQuantity = rs.getInt("available_quantity");
                    int readyCount = rs.getObject("ready_count") == null ? 0 : rs.getInt("ready_count");

                    if (availableQuantity <= 0 || readyCount > 0) {
                        continue;
                    }

                    nextPendingPs.setLong(1, bookId);
                    try (ResultSet pendingRs = nextPendingPs.executeQuery()) {
                        if (!pendingRs.next()) {
                            continue;
                        }

                        long reservationId = pendingRs.getLong("id");
                        long userId = pendingRs.getLong("user_id");
                        String userName = pendingRs.getString("name");
                        LocalDateTime expiresAt = LocalDateTime.now().plusDays(2);

                        promotePs.setTimestamp(1, Timestamp.valueOf(expiresAt));
                        promotePs.setLong(2, reservationId);
                        promotePs.executeUpdate();
                        reservationDAO.resequenceQueue(conn, bookId);
                        reservationDAO.createReadyNotification(
                                conn,
                                userId,
                                "Reservation ready: " + title,
                                "Hello " + userName + ", your reservation for \"" + title
                                        + "\" is now ready to claim until " + expiresAt.toLocalDate() + ".",
                                LocalDateTime.now()
                        );
                    }
                }
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
}
