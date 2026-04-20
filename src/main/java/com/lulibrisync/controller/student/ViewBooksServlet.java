package com.lulibrisync.controller.student;

import com.lulibrisync.dao.AuthorDAO;
import com.lulibrisync.dao.BookDAO;
import com.lulibrisync.dao.CategoryDAO;
import com.lulibrisync.model.Author;
import com.lulibrisync.model.Book;
import com.lulibrisync.model.Category;
import com.lulibrisync.service.LibraryAutomationService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet("/student/books")
public class ViewBooksServlet extends HttpServlet {

    private final BookDAO bookDAO = new BookDAO();
    private final CategoryDAO categoryDAO = new CategoryDAO();
    private final AuthorDAO authorDAO = new AuthorDAO();
    private final LibraryAutomationService automationService = new LibraryAutomationService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/views/auth/login.jsp");
            return;
        }

        try {
            automationService.runMaintenance();

            String keyword = value(request.getParameter("keyword"));
            Long categoryId = parseOptionalLong(request.getParameter("categoryId"));
            Long authorId = parseOptionalLong(request.getParameter("authorId"));
            String availability = value(request.getParameter("availability"));
            String isbn = value(request.getParameter("isbn"));
            String barcode = value(request.getParameter("barcode"));

            List<Book> books = bookDAO.search(keyword, categoryId, authorId, availability, isbn, barcode);
            List<Category> categories = categoryDAO.findAll();
            List<Author> authors = authorDAO.findAll();

            request.setAttribute("books", books);
            request.setAttribute("bookCategories", categories);
            request.setAttribute("bookAuthors", authors);
            request.setAttribute("keyword", keyword);
            request.setAttribute("selectedCategoryId", categoryId);
            request.setAttribute("selectedAuthorId", authorId);
            request.setAttribute("availability", availability.isEmpty() ? "ALL" : availability.toUpperCase());
            request.setAttribute("isbn", isbn);
            request.setAttribute("barcode", barcode);

            request.getRequestDispatcher("/views/student/books.jsp").forward(request, response);
        } catch (Exception e) {
            throw new ServletException("Unable to load student book catalog.", e);
        }
    }

    private String value(String text) {
        return text == null ? "" : text.trim();
    }

    private Long parseOptionalLong(String value) {
        try {
            String normalized = value(value);
            return normalized.isEmpty() ? null : Long.parseLong(normalized);
        } catch (Exception e) {
            return null;
        }
    }
}
