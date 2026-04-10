package com.lulibrisync.dao;

import com.lulibrisync.config.DBConnection;
import com.lulibrisync.model.Author;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class AuthorDAO {

    public List<Author> findAll() throws SQLException {
        String sql = "SELECT a.id, a.name, COALESCE(a.bio, '') AS bio, COUNT(b.id) AS book_count "
                + "FROM authors a "
                + "LEFT JOIN books b ON b.author_id = a.id "
                + "GROUP BY a.id, a.name, a.bio "
                + "ORDER BY a.name";

        try (Connection conn = requireConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            List<Author> authors = new ArrayList<>();
            while (rs.next()) {
                authors.add(mapRow(rs));
            }
            return authors;
        }
    }

    public Author findById(long id) throws SQLException {
        String sql = "SELECT a.id, a.name, COALESCE(a.bio, '') AS bio, COUNT(b.id) AS book_count "
                + "FROM authors a "
                + "LEFT JOIN books b ON b.author_id = a.id "
                + "WHERE a.id = ? "
                + "GROUP BY a.id, a.name, a.bio";

        try (Connection conn = requireConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapRow(rs) : null;
            }
        }
    }

    public void create(String name, String bio) throws SQLException {
        String sql = "INSERT INTO authors(name, bio) VALUES(?, ?)";
        try (Connection conn = requireConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, normalizeRequired(name));
            ps.setString(2, normalizeOptional(bio));
            ps.executeUpdate();
        }
    }

    public void update(long id, String name, String bio) throws SQLException {
        String sql = "UPDATE authors SET name = ?, bio = ? WHERE id = ?";
        try (Connection conn = requireConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, normalizeRequired(name));
            ps.setString(2, normalizeOptional(bio));
            ps.setLong(3, id);
            ps.executeUpdate();
        }
    }

    public void delete(long id) throws SQLException {
        String sql = "DELETE FROM authors WHERE id = ?";
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

    private Author mapRow(ResultSet rs) throws SQLException {
        return new Author(
                rs.getLong("id"),
                rs.getString("name"),
                rs.getString("bio"),
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
