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
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

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
        long editId = parseLong(request.getParameter("edit"));

        try {
            loadStudentPage(request, response, search, editId, null, null, null);
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
                    redirectWithStatus(response, request, "delete_error", query, 0);
                    return;
                }
                studentDAO.deleteByUserId(userId);
                redirectWithStatus(response, request, "deleted", query, 0);
                return;
            }

            if (id <= 0) {
                redirectWithStatus(response, request, "update_error", query, 0);
                return;
            }

            Student existingStudent = studentDAO.findById(id);
            if (existingStudent == null) {
                redirectWithStatus(response, request, "update_error", query, 0);
                return;
            }

            String course = value(request.getParameter("course"));
            String yearLevel = value(request.getParameter("yearLevel"));
            String phone = value(request.getParameter("phone"));
            String address = value(request.getParameter("address"));
            String status = value(request.getParameter("status"));

            Map<String, String> validationErrors = validateStudentForm(course, yearLevel, phone, address, status);
            if (!validationErrors.isEmpty()) {
                Student draftStudent = buildDraftStudent(existingStudent, course, yearLevel, phone, address, status);
                loadStudentPage(
                        request,
                        response,
                        query,
                        id,
                        draftStudent,
                        validationErrors,
                        "Please correct the highlighted fields."
                );
                return;
            }

            studentDAO.update(
                    id,
                    course,
                    yearLevel,
                    phone,
                    address,
                    status
            );
            redirectWithStatus(response, request, "updated", query, id);
        } catch (SQLException e) {
            try {
                Student existingStudent = id > 0 ? studentDAO.findById(id) : null;
                Student draftStudent = existingStudent == null
                        ? null
                        : buildDraftStudent(
                                existingStudent,
                                value(request.getParameter("course")),
                                value(request.getParameter("yearLevel")),
                                value(request.getParameter("phone")),
                                value(request.getParameter("address")),
                                value(request.getParameter("status"))
                        );

                loadStudentPage(
                        request,
                        response,
                        query,
                        id,
                        draftStudent,
                        null,
                        "Unable to update the student right now."
                );
            } catch (SQLException nested) {
                throw new ServletException("Unable to update the student right now.", nested);
            }
        }
    }

    private void loadStudentPage(HttpServletRequest request, HttpServletResponse response,
                                 String search, long editId, Student editStudentOverride,
                                 Map<String, String> validationErrors, String formError)
            throws ServletException, IOException, SQLException {

        List<Student> students = studentDAO.findAll(search);
        Student editStudent = editStudentOverride;
        if (editStudent == null && editId > 0) {
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
        request.setAttribute("validationErrors", validationErrors);
        request.setAttribute("formError", formError);

        request.getRequestDispatcher("/views/admin/students.jsp").forward(request, response);
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

    private void redirectWithStatus(HttpServletResponse response, HttpServletRequest request,
                                    String status, String query, long editId) throws IOException {
        StringBuilder url = new StringBuilder(request.getContextPath())
                .append("/admin/students?success=").append(encode(status));

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

    private Map<String, String> validateStudentForm(String course, String yearLevel, String phone,
                                                    String address, String status) {
        Map<String, String> errors = new LinkedHashMap<>();

        if (course.length() > 100) {
            errors.put("course", "Course must be 100 characters or fewer.");
        }
        if (yearLevel.length() > 40) {
            errors.put("yearLevel", "Year level must be 40 characters or fewer.");
        }
        if (!phone.isBlank() && !phone.matches("^[+0-9()\\-\\s]{7,20}$")) {
            errors.put("phone", "Phone must be 7 to 20 characters and use digits or + - ( ).");
        }
        if (address.length() > 255) {
            errors.put("address", "Address must be 255 characters or fewer.");
        }
        if (!status.isBlank()
                && !"ACTIVE".equalsIgnoreCase(status)
                && !"INACTIVE".equalsIgnoreCase(status)) {
            errors.put("status", "Choose a valid status.");
        }

        return errors;
    }

    private Student buildDraftStudent(Student existingStudent, String course, String yearLevel,
                                      String phone, String address, String status) {
        return new Student(
                existingStudent.getId(),
                existingStudent.getUserId(),
                existingStudent.getStudentId(),
                existingStudent.getName(),
                existingStudent.getEmail(),
                course,
                yearLevel,
                phone,
                address,
                status.isBlank() ? existingStudent.getStatus() : status.toUpperCase(),
                existingStudent.getIssuedCount(),
                existingStudent.getReservationCount(),
                existingStudent.getOverdueCount()
        );
    }
}
