package com.lulibrisync.api.repository;

import com.lulibrisync.api.model.ApiUser;
import com.lulibrisync.api.model.ApiUserSummary;
import org.springframework.dao.DataAccessException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.simple.SimpleJdbcInsert;
import org.springframework.stereotype.Repository;

import javax.sql.DataSource;
import java.sql.Date;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Repository
public class ApiUserRepository {

    private static final RowMapper<ApiUser> API_USER_ROW_MAPPER = (rs, rowNum) -> new ApiUser(
            rs.getLong("id"),
            rs.getString("name"),
            rs.getString("email"),
            rs.getString("password"),
            rs.getString("role"),
            rs.getString("student_id"),
            rs.getString("status")
    );

    private final JdbcTemplate jdbcTemplate;
    private final SimpleJdbcInsert userInsert;
    private final SimpleJdbcInsert studentInsert;

    public ApiUserRepository(JdbcTemplate jdbcTemplate, DataSource dataSource) {
        this.jdbcTemplate = jdbcTemplate;
        this.userInsert = new SimpleJdbcInsert(dataSource)
                .withTableName("users")
                .usingGeneratedKeyColumns("id");
        this.studentInsert = new SimpleJdbcInsert(dataSource)
                .withTableName("students")
                .usingGeneratedKeyColumns("id");
    }

    public Optional<ApiUser> findByEmail(String email) {
        String sql = "SELECT id, name, email, password, role, student_id, status FROM users WHERE email = ?";
        List<ApiUser> users = jdbcTemplate.query(sql, API_USER_ROW_MAPPER, email);
        return users.stream().findFirst();
    }

    public Optional<ApiUser> findById(long userId) {
        String sql = "SELECT id, name, email, password, role, student_id, status FROM users WHERE id = ?";
        List<ApiUser> users = jdbcTemplate.query(sql, API_USER_ROW_MAPPER, userId);
        return users.stream().findFirst();
    }

    public boolean existsByEmail(String email) {
        Integer count = jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM users WHERE email = ?",
                Integer.class,
                email
        );
        return count != null && count > 0;
    }

    public long insertUser(String name, String email, String passwordHash, String role, String studentId) {
        Number generatedId = userInsert.executeAndReturnKey(new MapSqlParameterSource()
                .addValue("name", name)
                .addValue("email", email)
                .addValue("password", passwordHash)
                .addValue("role", role)
                .addValue("student_id", studentId)
                .addValue("status", "ACTIVE")
        );
        return generatedId.longValue();
    }

    public void insertStudent(long userId, String studentId, String contactNumber, LocalDate birthDate) {
        studentInsert.execute(new MapSqlParameterSource()
                .addValue("user_id", userId)
                .addValue("student_id", studentId)
                .addValue("course", "Not set")
                .addValue("year_level", "Not set")
                .addValue("phone", contactNumber)
                .addValue("address", "")
                .addValue("date_of_birth", Date.valueOf(birthDate))
        );
    }

    public int nextStudentSequence(int year) {
        String prefix = year + "-";
        Integer currentMax = jdbcTemplate.queryForObject(
                "SELECT MAX(CAST(SUBSTRING_INDEX(student_id, '-', -1) AS UNSIGNED)) FROM users WHERE student_id LIKE ?",
                Integer.class,
                prefix + "%"
        );
        return (currentMax == null ? 0 : currentMax) + 1;
    }

    public void updatePassword(long userId, String passwordHash) {
        jdbcTemplate.update("UPDATE users SET password = ? WHERE id = ?", passwordHash, userId);
    }

    public List<ApiUserSummary> findAllUsers() {
        return jdbcTemplate.query(
                "SELECT id, name, email, role, status, student_id FROM users ORDER BY id DESC",
                (rs, rowNum) -> new ApiUserSummary(
                        rs.getLong("id"),
                        rs.getString("name"),
                        rs.getString("email"),
                        rs.getString("role"),
                        rs.getString("status"),
                        rs.getString("student_id")
                )
        );
    }

    public ApiUserSummary findUserSummaryByEmail(String email) {
        try {
            return jdbcTemplate.queryForObject(
                    "SELECT id, name, email, role, status, student_id FROM users WHERE email = ?",
                    (rs, rowNum) -> new ApiUserSummary(
                            rs.getLong("id"),
                            rs.getString("name"),
                            rs.getString("email"),
                            rs.getString("role"),
                            rs.getString("status"),
                            rs.getString("student_id")
                    ),
                    email
            );
        } catch (DataAccessException e) {
            return null;
        }
    }
}
