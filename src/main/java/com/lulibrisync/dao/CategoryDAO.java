package com.lulibrisync.dao;

import com.lulibrisync.config.DBConnection;
import com.lulibrisync.model.Category;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class CategoryDAO {

    public List<Category> findAll() throws SQLException {
        String sql = "SELECT c.id, c.name, COALESCE(c.description, '') AS description, COUNT(b.id) AS book_count "
                + "FROM categories c "
                + "LEFT JOIN books b ON b.category_id = c.id "
                + "GROUP BY c.id, c.name, c.description "
                + "ORDER BY c.name";

        try (Connection conn = requireConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            List<Category> categories = new ArrayList<>();
            while (rs.next()) {
                categories.add(mapRow(rs));
            }
            return categories;
        }
    }

    public Category findById(long id) throws SQLException {
        String sql = "SELECT c.id, c.name, COALESCE(c.description, '') AS description, COUNT(b.id) AS book_count "
                + "FROM categories c "
                + "LEFT JOIN books b ON b.category_id = c.id "
                + "WHERE c.id = ? "
                + "GROUP BY c.id, c.name, c.description";

        try (Connection conn = requireConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapRow(rs) : null;
            }
        }
    }

    public void create(String name, String description) throws SQLException {
        String sql = "INSERT INTO categories(name, description) VALUES(?, ?)";
        try (Connection conn = requireConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, normalizeRequired(name));
            ps.setString(2, normalizeOptional(description));
            ps.executeUpdate();
        }
    }

    public void update(long id, String name, String description) throws SQLException {
        String sql = "UPDATE categories SET name = ?, description = ? WHERE id = ?";
        try (Connection conn = requireConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, normalizeRequired(name));
            ps.setString(2, normalizeOptional(description));
            ps.setLong(3, id);
            ps.executeUpdate();
        }
    }

    public void delete(long id) throws SQLException {
        String sql = "DELETE FROM categories WHERE id = ?";
        try (Connection conn = requireConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, id);
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

    private Category mapRow(ResultSet rs) throws SQLException {
        return new Category(
                rs.getLong("id"),
                rs.getString("name"),
                rs.getString("description"),
                rs.getInt("book_count")
        );
    }

    private String normalizeRequired(String value) {
        return value == null ? "" : value.trim();
    }

    private String normalizeOptional(String value) {
        String normalized = value == null ? "" : value.trim();
        return normalized.isEmpty() ? null : normalized;
    }
}
