package com.lulibrisync.controller.admin;

import com.lulibrisync.dao.StudentDAO;
import com.lulibrisync.model.Student;

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

@WebServlet("/admin/students")
public class StudentSearchServlet extends HttpServlet {

    private final StudentDAO studentDAO = new StudentDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!ensureAdmin(request, response)) {
            return;
        }

        String search = value(request.getParameter("q"));

        try {
            List<Student> students = studentDAO.findAll(search);
            Student editStudent = null;
            long editId = parseLong(request.getParameter("edit"));
            if (editId > 0) {
                editStudent = studentDAO.findById(editId);
            }

            int activeStudents = 0;
            int overdueStudents = 0;
            int totalReservations = 0;
            for (Student student : students) {
                if ("ACTIVE".equalsIgnoreCase(student.getStatus())) {
                    activeStudents++;
                }
                if (student.getOverdueCount() > 0) {
                    overdueStudents++;
                }
                totalReservations += student.getReservationCount();
            }

            request.setAttribute("students", students);
            request.setAttribute("editStudent", editStudent);
            request.setAttribute("searchQuery", search);
            request.setAttribute("totalStudents", students.size());
            request.setAttribute("activeStudents", activeStudents);
            request.setAttribute("overdueStudents", overdueStudents);
            request.setAttribute("totalReservations", totalReservations);

            request.getRequestDispatcher("/views/admin/students.jsp").forward(request, response);
        } catch (Exception e) {
            throw new ServletException("Unable to load student management data.", e);
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
        long userId = parseLong(request.getParameter("userId"));
        String query = value(request.getParameter("q"));

        try {
            if ("delete".equals(action)) {
                if (userId <= 0) {
                    redirectWithMessage(response, request, "error", "Invalid student selected.", query, 0);
                    return;
                }
                studentDAO.deleteByUserId(userId);
                redirectWithMessage(response, request, "success", "Student account deleted successfully.", query, 0);
                return;
            }

            if (id <= 0) {
                redirectWithMessage(response, request, "error", "Invalid student selected.", query, 0);
                return;
            }

            studentDAO.update(
                    id,
                    value(request.getParameter("course")),
                    value(request.getParameter("yearLevel")),
                    value(request.getParameter("phone")),
                    value(request.getParameter("address")),
                    value(request.getParameter("status"))
            );
            redirectWithMessage(response, request, "success", "Student profile updated successfully.", query, 0);
        } catch (SQLException e) {
            redirectWithMessage(response, request, "error", "Unable to update the student right now.", query, id);
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

    private String value(String input) {
        return input == null ? "" : input.trim();
    }

    private long parseLong(String value) {
        try {
            return Long.parseLong(value == null ? "" : value.trim());
        } catch (Exception e) {
            return 0;
        }
    }

    private void redirectWithMessage(HttpServletResponse response, HttpServletRequest request,
                                     String type, String message, String query, long editId) throws IOException {
        StringBuilder url = new StringBuilder(request.getContextPath())
                .append("/admin/students?feedbackType=").append(encode(type))
                .append("&feedbackMessage=").append(encode(message));

        if (!query.isBlank()) {
            url.append("&q=").append(encode(query));
        }
        if (editId > 0) {
            url.append("&edit=").append(editId);
        }

        response.sendRedirect(url.toString());
    }

    private String encode(String value) {
        return URLEncoder.encode(value == null ? "" : value, StandardCharsets.UTF_8);
    }
}
