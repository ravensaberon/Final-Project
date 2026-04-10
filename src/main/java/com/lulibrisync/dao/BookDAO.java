package com.lulibrisync.dao;

import com.lulibrisync.config.DBConnection;
import com.lulibrisync.model.Book;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

public class BookDAO {

    public List<Book> findAll() throws SQLException {
        String sql = "SELECT b.id, b.title, b.isbn, COALESCE(b.barcode, '') AS barcode, "
                + "b.category_id, COALESCE(c.name, 'Uncategorized') AS category_name, "
                + "b.author_id, COALESCE(a.name, 'Unknown author') AS author_name, "
                + "b.publication_year, b.quantity, b.available_quantity, "
                + "COALESCE(b.shelf_location, '') AS shelf_location, "
                + "COALESCE(b.description, '') AS description, b.is_digital "
                + "FROM books b "
                + "LEFT JOIN categories c ON c.id = b.category_id "
                + "LEFT JOIN authors a ON a.id = b.author_id "
                + "ORDER BY b.title";

        try (Connection conn = requireConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            List<Book> books = new ArrayList<>();
            while (rs.next()) {
                books.add(mapRow(rs));
            }
            return books;
        }
    }

    public Book findById(long id) throws SQLException {
        String sql = "SELECT b.id, b.title, b.isbn, COALESCE(b.barcode, '') AS barcode, "
                + "b.category_id, COALESCE(c.name, 'Uncategorized') AS category_name, "
                + "b.author_id, COALESCE(a.name, 'Unknown author') AS author_name, "
                + "b.publication_year, b.quantity, b.available_quantity, "
                + "COALESCE(b.shelf_location, '') AS shelf_location, "
                + "COALESCE(b.description, '') AS description, b.is_digital "
                + "FROM books b "
                + "LEFT JOIN categories c ON c.id = b.category_id "
                + "LEFT JOIN authors a ON a.id = b.author_id "
                + "WHERE b.id = ?";

        try (Connection conn = requireConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapRow(rs) : null;
            }
        }
    }

    public List<Book> findAvailableForIssue() throws SQLException {
        String sql = "SELECT b.id, b.title, b.isbn, COALESCE(b.barcode, '') AS barcode, "
                + "b.category_id, COALESCE(c.name, 'Uncategorized') AS category_name, "
                + "b.author_id, COALESCE(a.name, 'Unknown author') AS author_name, "
                + "b.publication_year, b.quantity, b.available_quantity, "
                + "COALESCE(b.shelf_location, '') AS shelf_location, "
                + "COALESCE(b.description, '') AS description, b.is_digital "
                + "FROM books b "
                + "LEFT JOIN categories c ON c.id = b.category_id "
                + "LEFT JOIN authors a ON a.id = b.author_id "
                + "WHERE b.available_quantity > 0 "
                + "ORDER BY b.title";

        try (Connection conn = requireConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            List<Book> books = new ArrayList<>();
            while (rs.next()) {
                books.add(mapRow(rs));
            }
            return books;
        }
    }

    public void create(Book book) throws SQLException {
        String sql = "INSERT INTO books(title, isbn, barcode, category_id, author_id, publication_year, quantity, "
                + "available_quantity, shelf_location, description, is_digital) "
                + "VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = requireConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            bindBook(ps, book, false);
            ps.executeUpdate();
        }
    }

    public void update(Book book) throws SQLException {
        String sql = "UPDATE books SET title = ?, isbn = ?, barcode = ?, category_id = ?, author_id = ?, "
                + "publication_year = ?, quantity = ?, available_quantity = ?, shelf_location = ?, "
                + "description = ?, is_digital = ? WHERE id = ?";

        try (Connection conn = requireConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            bindBook(ps, book, true);
            ps.executeUpdate();
        }
    }

    public void delete(long id) throws SQLException {
        String sql = "DELETE FROM books WHERE id = ?";
        try (Connection conn = requireConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, id);
            ps.executeUpdate();
        }
    }

    private void bindBook(PreparedStatement ps, Book book, boolean includeId) throws SQLException {
        ps.setString(1, normalizeRequired(book.getTitle()));
        ps.setString(2, normalizeRequired(book.getIsbn()));
        ps.setString(3, normalizeOptional(book.getBarcode()));
        setNullableLong(ps, 4, book.getCategoryId());
        setNullableLong(ps, 5, book.getAuthorId());
        setNullableInteger(ps, 6, book.getPublicationYear());
        ps.setInt(7, book.getQuantity());
        ps.setInt(8, book.getAvailableQuantity());
        ps.setString(9, normalizeOptional(book.getShelfLocation()));
        ps.setString(10, normalizeOptional(book.getDescription()));
        ps.setBoolean(11, book.isDigital());
        if (includeId) {
            ps.setLong(12, book.getId());
        }
    }

    private void setNullableLong(PreparedStatement ps, int index, Long value) throws SQLException {
        if (value == null) {
            ps.setNull(index, Types.BIGINT);
        } else {
            ps.setLong(index, value);
        }
    }

    private void setNullableInteger(PreparedStatement ps, int index, Integer value) throws SQLException {
        if (value == null) {
            ps.setNull(index, Types.INTEGER);
        } else {
            ps.setInt(index, value);
        }
    }

    private Connection requireConnection() throws SQLException {
        Connection conn = DBConnection.getConnection();
        if (conn == null) {
            throw new SQLException("Database connection is unavailable.");
        }
        return conn;
    }

    private Book mapRow(ResultSet rs) throws SQLException {
        Long categoryId = rs.getObject("category_id") == null ? null : rs.getLong("category_id");
        Long authorId = rs.getObject("author_id") == null ? null : rs.getLong("author_id");
        Integer publicationYear = rs.getObject("publication_year") == null ? null : rs.getInt("publication_year");

        return new Book(
                rs.getLong("id"),
                rs.getString("title"),
                rs.getString("isbn"),
                rs.getString("barcode"),
                categoryId,
                rs.getString("category_name"),
                authorId,
                rs.getString("author_name"),
                publicationYear,
                rs.getInt("quantity"),
                rs.getInt("available_quantity"),
                rs.getString("shelf_location"),
                rs.getString("description"),
                rs.getBoolean("is_digital")
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
