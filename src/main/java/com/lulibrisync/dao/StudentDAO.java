package com.lulibrisync.dao;

import com.lulibrisync.config.DBConnection;
import com.lulibrisync.model.Student;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class StudentDAO {

    public List<Student> findAll(String search) throws SQLException {
        String sql = "SELECT s.id, s.user_id, s.student_id, u.name, u.email, "
                + "COALESCE(s.course, 'Not set') AS course, COALESCE(s.year_level, 'Not set') AS year_level, "
                + "COALESCE(s.phone, '') AS phone, COALESCE(s.address, '') AS address, u.status, "
                + "COALESCE(issue_summary.issued_count, 0) AS issued_count, "
                + "COALESCE(reservation_summary.reservation_count, 0) AS reservation_count, "
                + "COALESCE(issue_summary.overdue_count, 0) AS overdue_count "
                + "FROM students s "
                + "JOIN users u ON u.id = s.user_id "
                + "LEFT JOIN ("
                + "    SELECT student_id, "
                + "           SUM(CASE WHEN status = 'ISSUED' THEN 1 ELSE 0 END) AS issued_count, "
                + "           SUM(CASE WHEN status = 'OVERDUE' THEN 1 ELSE 0 END) AS overdue_count "
                + "    FROM issue_records GROUP BY student_id"
                + ") issue_summary ON issue_summary.student_id = s.id "
                + "LEFT JOIN ("
                + "    SELECT student_id, COUNT(*) AS reservation_count "
                + "    FROM reservations WHERE status IN ('PENDING', 'READY', 'CLAIMED') GROUP BY student_id"
                + ") reservation_summary ON reservation_summary.student_id = s.id "
                + "WHERE (? = '' OR s.student_id LIKE ? OR u.name LIKE ? OR u.email LIKE ?) "
                + "ORDER BY u.name";

        String normalizedSearch = normalizeSearch(search);
        String wildcardSearch = "%" + normalizedSearch + "%";

        try (Connection conn = requireConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, normalizedSearch);
            ps.setString(2, wildcardSearch);
            ps.setString(3, wildcardSearch);
            ps.setString(4, wildcardSearch);

            try (ResultSet rs = ps.executeQuery()) {
                List<Student> students = new ArrayList<>();
                while (rs.next()) {
                    students.add(mapRow(rs));
                }
                return students;
            }
        }
    }

    public Student findById(long id) throws SQLException {
        String sql = "SELECT s.id, s.user_id, s.student_id, u.name, u.email, "
                + "COALESCE(s.course, 'Not set') AS course, COALESCE(s.year_level, 'Not set') AS year_level, "
                + "COALESCE(s.phone, '') AS phone, COALESCE(s.address, '') AS address, u.status, "
                + "COALESCE(issue_summary.issued_count, 0) AS issued_count, "
                + "COALESCE(reservation_summary.reservation_count, 0) AS reservation_count, "
                + "COALESCE(issue_summary.overdue_count, 0) AS overdue_count "
                + "FROM students s "
                + "JOIN users u ON u.id = s.user_id "
                + "LEFT JOIN ("
                + "    SELECT student_id, "
                + "           SUM(CASE WHEN status = 'ISSUED' THEN 1 ELSE 0 END) AS issued_count, "
                + "           SUM(CASE WHEN status = 'OVERDUE' THEN 1 ELSE 0 END) AS overdue_count "
                + "    FROM issue_records GROUP BY student_id"
                + ") issue_summary ON issue_summary.student_id = s.id "
                + "LEFT JOIN ("
                + "    SELECT student_id, COUNT(*) AS reservation_count "
                + "    FROM reservations WHERE status IN ('PENDING', 'READY', 'CLAIMED') GROUP BY student_id"
                + ") reservation_summary ON reservation_summary.student_id = s.id "
                + "WHERE s.id = ?";

        try (Connection conn = requireConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapRow(rs) : null;
            }
        }
    }

    public List<Student> findActiveForIssue() throws SQLException {
        String sql = "SELECT s.id, s.user_id, s.student_id, u.name, u.email, "
                + "COALESCE(s.course, 'Not set') AS course, COALESCE(s.year_level, 'Not set') AS year_level, "
                + "COALESCE(s.phone, '') AS phone, COALESCE(s.address, '') AS address, u.status, "
                + "COALESCE(issue_summary.issued_count, 0) AS issued_count, "
                + "COALESCE(reservation_summary.reservation_count, 0) AS reservation_count, "
                + "COALESCE(issue_summary.overdue_count, 0) AS overdue_count "
                + "FROM students s "
                + "JOIN users u ON u.id = s.user_id "
                + "LEFT JOIN ("
                + "    SELECT student_id, "
                + "           SUM(CASE WHEN status = 'ISSUED' THEN 1 ELSE 0 END) AS issued_count, "
                + "           SUM(CASE WHEN status = 'OVERDUE' THEN 1 ELSE 0 END) AS overdue_count "
                + "    FROM issue_records GROUP BY student_id"
                + ") issue_summary ON issue_summary.student_id = s.id "
                + "LEFT JOIN ("
                + "    SELECT student_id, COUNT(*) AS reservation_count "
                + "    FROM reservations WHERE status IN ('PENDING', 'READY', 'CLAIMED') GROUP BY student_id"
                + ") reservation_summary ON reservation_summary.student_id = s.id "
                + "WHERE u.status = 'ACTIVE' "
                + "ORDER BY u.name";

        try (Connection conn = requireConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            List<Student> students = new ArrayList<>();
            while (rs.next()) {
                students.add(mapRow(rs));
            }
            return students;
        }
    }

    public void update(long id, String course, String yearLevel, String phone, String address, String status)
            throws SQLException {

        String updateStudentSql = "UPDATE students SET course = ?, year_level = ?, phone = ?, address = ? WHERE id = ?";
        String updateUserSql = "UPDATE users SET status = ? WHERE id = (SELECT user_id FROM students WHERE id = ?)";

        try (Connection conn = requireConnection()) {
            conn.setAutoCommit(false);
            try (PreparedStatement studentPs = conn.prepareStatement(updateStudentSql);
                 PreparedStatement userPs = conn.prepareStatement(updateUserSql)) {

                studentPs.setString(1, normalizeOptional(course, "Not set"));
                studentPs.setString(2, normalizeOptional(yearLevel, "Not set"));
                studentPs.setString(3, normalizeOptional(phone, ""));
                studentPs.setString(4, normalizeOptional(address, ""));
                studentPs.setLong(5, id);
                studentPs.executeUpdate();

                userPs.setString(1, normalizeStatus(status));
                userPs.setLong(2, id);
                userPs.executeUpdate();

                conn.commit();
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        }
    }

    public void deleteByUserId(long userId) throws SQLException {
        String sql = "DELETE FROM users WHERE id = ? AND role = 'STUDENT'";
        try (Connection conn = requireConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, userId);
            ps.executeUpdate();
        }
    }

    private Connection requireConnection() throws SQLException {
        Connection conn = DBConnection.getConnection();
        if (conn == null) {
            throw new SQLException("Database connection is unavailable.");
        }
        return conn;
    }

    private Student mapRow(ResultSet rs) throws SQLException {
        return new Student(
                rs.getLong("id"),
                rs.getLong("user_id"),
                rs.getString("student_id"),
                rs.getString("name"),
                rs.getString("email"),
                rs.getString("course"),
                rs.getString("year_level"),
                rs.getString("phone"),
                rs.getString("address"),
                rs.getString("status"),
                rs.getInt("issued_count"),
                rs.getInt("reservation_count"),
                rs.getInt("overdue_count")
        );
    }

    private String normalizeSearch(String value) {
        return value == null ? "" : value.trim();
    }

    private String normalizeOptional(String value, String fallback) {
        String normalized = value == null ? "" : value.trim();
        return normalized.isEmpty() ? fallback : normalized;
    }

    private String normalizeStatus(String value) {
        String normalized = value == null ? "" : value.trim().toUpperCase();
        return "INACTIVE".equals(normalized) ? "INACTIVE" : "ACTIVE";
    }
}
