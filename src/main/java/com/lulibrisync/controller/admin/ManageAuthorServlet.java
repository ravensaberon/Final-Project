package com.lulibrisync.controller.admin;

import com.lulibrisync.dao.AuthorDAO;
import com.lulibrisync.model.Author;

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
import java.util.List;

@WebServlet("/admin/authors")
public class ManageAuthorServlet extends HttpServlet {

    private final AuthorDAO authorDAO = new AuthorDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!ensureAdmin(request, response)) {
            return;
        }

        try {
            List<Author> authors = authorDAO.findAll();
            Author editAuthor = null;
            long editId = parseLong(request.getParameter("edit"));
            if (editId > 0) {
                editAuthor = authorDAO.findById(editId);
            }

            int totalLinkedBooks = 0;
            int featuredAuthors = 0;
            for (Author author : authors) {
                totalLinkedBooks += author.getBookCount();
                if (author.getBookCount() > 0) {
                    featuredAuthors++;
                }
            }

            request.setAttribute("authors", authors);
            request.setAttribute("editAuthor", editAuthor);
            request.setAttribute("totalAuthors", authors.size());
            request.setAttribute("featuredAuthors", featuredAuthors);
            request.setAttribute("authorsWithoutTitles", Math.max(0, authors.size() - featuredAuthors));
            request.setAttribute("totalLinkedBooks", totalLinkedBooks);

            request.getRequestDispatcher("/views/admin/authors.jsp").forward(request, response);
        } catch (Exception e) {
            throw new ServletException("Unable to load authors.", e);
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
        String name = value(request.getParameter("name"));
        String bio = value(request.getParameter("bio"));

        try {
            if ("delete".equals(action)) {
                if (id <= 0) {
                    redirectWithMessage(response, request, "error", "Invalid author selected.", 0);
                    return;
                }
                authorDAO.delete(id);
                redirectWithMessage(response, request, "success", "Author deleted successfully.", 0);
                return;
            }

            if (name.isBlank()) {
                redirectWithMessage(response, request, "error", "Author name is required.",
                        "update".equals(action) ? id : 0);
                return;
            }

            if ("update".equals(action)) {
                authorDAO.update(id, name, bio);
                redirectWithMessage(response, request, "success", "Author updated successfully.", 0);
                return;
            }

            authorDAO.create(name, bio);
            redirectWithMessage(response, request, "success", "Author created successfully.", 0);
        } catch (SQLException e) {
            redirectWithMessage(response, request, "error", resolveSqlMessage(e), "update".equals(action) ? id : 0);
        }
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

    private String value(String input) {
        return input == null ? "" : input.trim();
    }

    private String resolveSqlMessage(SQLException exception) {
        String message = exception.getMessage();
        if (message != null && message.toLowerCase().contains("duplicate")) {
            return "That author already exists.";
        }
        return "Unable to save the author right now.";
    }

    private void redirectWithMessage(HttpServletResponse response, HttpServletRequest request,
                                     String type, String message, long editId) throws IOException {
        StringBuilder url = new StringBuilder(request.getContextPath())
                .append("/admin/authors?feedbackType=").append(encode(type))
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
