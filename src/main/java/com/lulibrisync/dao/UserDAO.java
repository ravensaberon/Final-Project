package com.lulibrisync.dao;

import com.lulibrisync.config.DBConnection;
import com.lulibrisync.model.User;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class UserDAO {

    public StudentProfile findStudentProfileByUserId(long userId) throws SQLException {
        String sql = "SELECT u.id, u.name, u.email, u.role, COALESCE(u.student_id, '') AS student_id, u.status, "
                + "s.id AS student_db_id, COALESCE(s.course, 'Not set') AS course, "
                + "COALESCE(s.year_level, 'Not set') AS year_level, COALESCE(s.phone, '') AS phone, "
                + "COALESCE(s.address, '') AS address, "
                + "COALESCE(issue_summary.active_count, 0) AS active_count, "
                + "COALESCE(issue_summary.returned_count, 0) AS returned_count, "
                + "COALESCE(issue_summary.overdue_count, 0) AS overdue_count, "
                + "COALESCE(reservation_summary.pending_count, 0) AS pending_count "
                + "FROM users u "
                + "JOIN students s ON s.user_id = u.id "
                + "LEFT JOIN ("
                + "    SELECT student_id, "
                + "           SUM(CASE WHEN status = 'ISSUED' THEN 1 ELSE 0 END) AS active_count, "
                + "           SUM(CASE WHEN status = 'RETURNED' THEN 1 ELSE 0 END) AS returned_count, "
                + "           SUM(CASE WHEN status = 'OVERDUE' THEN 1 ELSE 0 END) AS overdue_count "
                + "    FROM issue_records GROUP BY student_id"
                + ") issue_summary ON issue_summary.student_id = s.id "
                + "LEFT JOIN ("
                + "    SELECT student_id, COUNT(*) AS pending_count "
                + "    FROM reservations WHERE status IN ('PENDING', 'READY', 'CLAIMED') GROUP BY student_id"
                + ") reservation_summary ON reservation_summary.student_id = s.id "
                + "WHERE u.id = ? AND u.role = 'STUDENT'";

        try (Connection conn = requireConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    return null;
                }

                User user = new User(
                        rs.getLong("id"),
                        rs.getString("name"),
                        rs.getString("email"),
                        rs.getString("role"),
                        rs.getString("student_id"),
                        rs.getString("status")
                );

                return new StudentProfile(
                        user,
                        rs.getLong("student_db_id"),
                        rs.getString("course"),
                        rs.getString("year_level"),
                        rs.getString("phone"),
                        rs.getString("address"),
                        rs.getInt("active_count"),
                        rs.getInt("returned_count"),
                        rs.getInt("overdue_count"),
                        rs.getInt("pending_count")
                );
            }
        }
    }

    public void updateStudentProfile(long userId, String name, String email, String course,
                                     String yearLevel, String phone, String address) throws SQLException {
        String duplicateSql = "SELECT COUNT(*) FROM users WHERE email = ? AND id <> ?";
        String updateUserSql = "UPDATE users SET name = ?, email = ? WHERE id = ? AND role = 'STUDENT'";
        String updateStudentSql = "UPDATE students SET course = ?, year_level = ?, phone = ?, address = ? WHERE user_id = ?";

        try (Connection conn = requireConnection()) {
            conn.setAutoCommit(false);
            try (PreparedStatement duplicatePs = conn.prepareStatement(duplicateSql);
                 PreparedStatement userPs = conn.prepareStatement(updateUserSql);
                 PreparedStatement studentPs = conn.prepareStatement(updateStudentSql)) {

                String normalizedName = normalizeRequired(name);
                String normalizedEmail = normalizeRequired(email).toLowerCase();

                duplicatePs.setString(1, normalizedEmail);
                duplicatePs.setLong(2, userId);
                try (ResultSet rs = duplicatePs.executeQuery()) {
                    if (rs.next() && rs.getInt(1) > 0) {
                        throw new IllegalStateException("email_exists");
                    }
                }

                userPs.setString(1, normalizedName);
                userPs.setString(2, normalizedEmail);
                userPs.setLong(3, userId);
                userPs.executeUpdate();

                studentPs.setString(1, normalizeOptional(course, "Not set"));
                studentPs.setString(2, normalizeOptional(yearLevel, "Not set"));
                studentPs.setString(3, normalizeOptional(phone, ""));
                studentPs.setString(4, normalizeOptional(address, ""));
                studentPs.setLong(5, userId);
                studentPs.executeUpdate();

                conn.commit();
            } catch (Exception e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
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

    private String normalizeRequired(String value) {
        return value == null ? "" : value.trim();
    }

    private String normalizeOptional(String value, String fallback) {
        String normalized = value == null ? "" : value.trim();
        return normalized.isEmpty() ? fallback : normalized;
    }

    public static final class StudentProfile {
        private final User user;
        private final long studentDbId;
        private final String course;
        private final String yearLevel;
        private final String phone;
        private final String address;
        private final int activeLoans;
        private final int returnedLoans;
        private final int overdueLoans;
        private final int reservationCount;

        public StudentProfile(User user, long studentDbId, String course, String yearLevel, String phone,
                              String address, int activeLoans, int returnedLoans, int overdueLoans,
                              int reservationCount) {
            this.user = user;
            this.studentDbId = studentDbId;
            this.course = course;
            this.yearLevel = yearLevel;
            this.phone = phone;
            this.address = address;
            this.activeLoans = activeLoans;
            this.returnedLoans = returnedLoans;
            this.overdueLoans = overdueLoans;
            this.reservationCount = reservationCount;
        }

        public User getUser() {
            return user;
        }

        public long getStudentDbId() {
            return studentDbId;
        }

        public String getCourse() {
            return course;
        }

        public String getYearLevel() {
            return yearLevel;
        }

        public String getPhone() {
            return phone;
        }

        public String getAddress() {
            return address;
        }

        public int getActiveLoans() {
            return activeLoans;
        }

        public int getReturnedLoans() {
            return returnedLoans;
        }

        public int getOverdueLoans() {
            return overdueLoans;
        }

        public int getReservationCount() {
            return reservationCount;
        }
    }
}
