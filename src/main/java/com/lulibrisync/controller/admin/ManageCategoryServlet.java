package com.lulibrisync.controller.admin;

import com.lulibrisync.dao.CategoryDAO;
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
import java.util.List;

@WebServlet("/admin/categories")
public class ManageCategoryServlet extends HttpServlet {

    private final CategoryDAO categoryDAO = new CategoryDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!ensureAdmin(request, response)) {
            return;
        }

        try {
            List<Category> categories = categoryDAO.findAll();
            Category editCategory = null;
            long editId = parseLong(request.getParameter("edit"));
            if (editId > 0) {
                editCategory = categoryDAO.findById(editId);
            }

            int totalAssignedBooks = 0;
            int activeCategories = 0;
            for (Category category : categories) {
                totalAssignedBooks += category.getBookCount();
                if (category.getBookCount() > 0) {
                    activeCategories++;
                }
            }

            request.setAttribute("categories", categories);
            request.setAttribute("editCategory", editCategory);
            request.setAttribute("totalCategories", categories.size());
            request.setAttribute("activeCategories", activeCategories);
            request.setAttribute("idleCategories", Math.max(0, categories.size() - activeCategories));
            request.setAttribute("totalAssignedBooks", totalAssignedBooks);

            request.getRequestDispatcher("/views/admin/categories.jsp").forward(request, response);
        } catch (Exception e) {
            throw new ServletException("Unable to load categories.", e);
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
        String description = value(request.getParameter("description"));

        try {
            if ("delete".equals(action)) {
                if (id <= 0) {
                    redirectWithMessage(response, request, "error", "Invalid category selected.", 0);
                    return;
                }
                categoryDAO.delete(id);
                redirectWithMessage(response, request, "success", "Category deleted successfully.", 0);
                return;
            }

            if (name.isBlank()) {
                redirectWithMessage(response, request, "error", "Category name is required.",
                        "update".equals(action) ? id : 0);
                return;
            }

            if ("update".equals(action)) {
                categoryDAO.update(id, name, description);
                redirectWithMessage(response, request, "success", "Category updated successfully.", 0);
                return;
            }

            categoryDAO.create(name, description);
            redirectWithMessage(response, request, "success", "Category created successfully.", 0);
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
            return "That category name already exists.";
        }
        return "Unable to save the category right now.";
    }

    private void redirectWithMessage(HttpServletResponse response, HttpServletRequest request,
                                     String type, String message, long editId) throws IOException {
        StringBuilder url = new StringBuilder(request.getContextPath())
                .append("/admin/categories?feedbackType=").append(encode(type))
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
