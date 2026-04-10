package com.lulibrisync.controller.admin;

import com.lulibrisync.dao.AuthorDAO;
import com.lulibrisync.dao.BookDAO;
import com.lulibrisync.dao.CategoryDAO;
import com.lulibrisync.model.Author;
import com.lulibrisync.model.Book;
import com.lulibrisync.model.Category;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.SQLException;
import java.time.Year;
import java.util.List;

@WebServlet("/admin/books")
public class ManageBookServlet extends HttpServlet {

    private final BookDAO bookDAO = new BookDAO();
    private final CategoryDAO categoryDAO = new CategoryDAO();
    private final AuthorDAO authorDAO = new AuthorDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!ensureAdmin(request, response)) {
            return;
        }

        try {
            List<Book> books = bookDAO.findAll();
            List<Category> categories = categoryDAO.findAll();
            List<Author> authors = authorDAO.findAll();

            Book editBook = null;
            long editId = parseLong(request.getParameter("edit"));
            if (editId > 0) {
                editBook = bookDAO.findById(editId);
            }

            int totalCopies = 0;
            int availableCopies = 0;
            int lowStockCount = 0;
            int digitalTitles = 0;
            for (Book book : books) {
                totalCopies += book.getQuantity();
                availableCopies += book.getAvailableQuantity();
                if (book.getAvailableQuantity() <= 2) {
                    lowStockCount++;
                }
                if (book.isDigital()) {
                    digitalTitles++;
                }
            }

            request.setAttribute("books", books);
            request.setAttribute("categories", categories);
            request.setAttribute("authors", authors);
            request.setAttribute("editBook", editBook);
            request.setAttribute("totalTitles", books.size());
            request.setAttribute("digitalTitles", digitalTitles);
            request.setAttribute("lowStockCount", lowStockCount);
            request.setAttribute("totalCopies", totalCopies);
            request.setAttribute("availableCopies", availableCopies);

            request.getRequestDispatcher("/views/admin/books.jsp").forward(request, response);
        } catch (Exception e) {
            throw new ServletException("Unable to load books.", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!ensureAdmin(request, response)) {
            return;
        }

        request.setCharacterEncoding("UTF-8");

        String action = value(request.getParameter("action"));
        long id = parseLong(request.getParameter("id"));

        try {
            if ("delete".equals(action)) {
                if (id <= 0) {
                    redirectWithMessage(response, request, "error", "Invalid book selected.", 0);
                    return;
                }
                bookDAO.delete(id);
                redirectWithMessage(response, request, "success", "Book deleted successfully.", 0);
                return;
            }

            Book book = buildBookFromRequest(request, id);
            String validationMessage = validateBook(book);
            if (validationMessage != null) {
                redirectWithMessage(response, request, "error", validationMessage,
                        "update".equals(action) ? id : 0);
                return;
            }

            if ("update".equals(action)) {
                bookDAO.update(book);
                redirectWithMessage(response, request, "success", "Book updated successfully.", 0);
                return;
            }

            bookDAO.create(book);
            redirectWithMessage(response, request, "success", "Book created successfully.", 0);
        } catch (SQLException e) {
            redirectWithMessage(response, request, "error", resolveSqlMessage(e), "update".equals(action) ? id : 0);
        }
    }

    private Book buildBookFromRequest(HttpServletRequest request, long id) {
        String title = value(request.getParameter("title"));
        String isbn = value(request.getParameter("isbn"));
        String barcode = value(request.getParameter("barcode"));
        Long categoryId = parseOptionalLong(request.getParameter("categoryId"));
        Long authorId = parseOptionalLong(request.getParameter("authorId"));
        Integer publicationYear = parseOptionalInt(request.getParameter("publicationYear"));
        int quantity = parseInt(request.getParameter("quantity"));
        int availableQuantity = parseInt(request.getParameter("availableQuantity"));
        String shelfLocation = value(request.getParameter("shelfLocation"));
        String description = value(request.getParameter("description"));
        boolean isDigital = request.getParameter("isDigital") != null;

        return new Book(
                id,
                title,
                isbn,
                barcode,
                categoryId,
                null,
                authorId,
                null,
                publicationYear,
                quantity,
                availableQuantity,
                shelfLocation,
                description,
                isDigital
        );
    }

    private String validateBook(Book book) {
        if (book.getTitle().isBlank()) {
            return "Book title is required.";
        }
        if (book.getIsbn().isBlank()) {
            return "ISBN is required.";
        }
        if (book.getQuantity() < 0) {
            return "Quantity cannot be negative.";
        }
        if (book.getAvailableQuantity() < 0) {
            return "Available quantity cannot be negative.";
        }
        if (book.getAvailableQuantity() > book.getQuantity()) {
            return "Available quantity cannot be greater than total quantity.";
        }
        if (book.getPublicationYear() != null) {
            int currentYear = Year.now().getValue() + 1;
            if (book.getPublicationYear() < 1000 || book.getPublicationYear() > currentYear) {
                return "Publication year is outside the accepted range.";
            }
        }
        return null;
    }

    private boolean ensureAdmin(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        if (session == null || !"ADMIN".equals(session.getAttribute("role"))) {
            response.sendRedirect(request.getContextPath() + "/views/auth/login.jsp");
            return false;
        }
        return true;
    }

    private long parseLong(String value) {
        try {
            return Long.parseLong(value == null ? "" : value.trim());
        } catch (Exception e) {
            return 0;
        }
    }

    private Long parseOptionalLong(String value) {
        long parsed = parseLong(value);
        return parsed > 0 ? parsed : null;
    }

    private Integer parseOptionalInt(String value) {
        try {
            String trimmed = value(value);
            return trimmed.isEmpty() ? null : Integer.parseInt(trimmed);
        } catch (Exception e) {
            return null;
        }
    }

    private int parseInt(String value) {
        try {
            return Integer.parseInt(value == null ? "" : value.trim());
        } catch (Exception e) {
            return -1;
        }
    }

    private String value(String input) {
        return input == null ? "" : input.trim();
    }

    private String resolveSqlMessage(SQLException exception) {
        String message = exception.getMessage();
        if (message == null) {
            return "Unable to save the book right now.";
        }

        String lower = message.toLowerCase();
        if (lower.contains("isbn")) {
            return "That ISBN already exists in the catalog.";
        }
        if (lower.contains("barcode")) {
            return "That barcode already exists in the catalog.";
        }
        return "Unable to save the book right now.";
    }

    private void redirectWithMessage(HttpServletResponse response, HttpServletRequest request,
                                     String type, String message, long editId) throws IOException {
        StringBuilder url = new StringBuilder(request.getContextPath())
                .append("/admin/books?feedbackType=").append(encode(type))
                .append("&feedbackMessage=").append(encode(message));

        if (editId > 0) {
            url.append("&edit=").append(editId);
        }

        response.sendRedirect(url.toString());
    }

    private String encode(String value) {
        return URLEncoder.encode(value == null ? "" : value, StandardCharsets.UTF_8);
    }
}
