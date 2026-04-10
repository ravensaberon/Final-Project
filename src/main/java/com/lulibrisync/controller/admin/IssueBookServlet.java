package com.lulibrisync.controller.admin;

import com.lulibrisync.dao.BookDAO;
import com.lulibrisync.dao.IssueRecordDAO;
import com.lulibrisync.dao.StudentDAO;
import com.lulibrisync.model.Book;
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
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Map;

@WebServlet("/admin/issue")
public class IssueBookServlet extends HttpServlet {

    private static final DateTimeFormatter PREVIEW_FORMAT =
            DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");

    private final StudentDAO studentDAO = new StudentDAO();
    private final BookDAO bookDAO = new BookDAO();
    private final IssueRecordDAO issueRecordDAO = new IssueRecordDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!isAdmin(request.getSession(false))) {
            response.sendRedirect(request.getContextPath() + "/views/auth/login.jsp");
            return;
        }

        try {
            LocalDateTime issueDate = LocalDateTime.now();
            LocalDateTime dueDate = issueDate.plusDays(issueRecordDAO.getDefaultLoanDays());
            List<Student> students = studentDAO.findActiveForIssue();
            List<Book> books = bookDAO.findAvailableForIssue();
            List<Map<String, Object>> recentIssues = issueRecordDAO.findRecentIssues(8);

            request.setAttribute("issueStudents", students);
            request.setAttribute("availableBooks", books);
            request.setAttribute("recentIssues", recentIssues);
            request.setAttribute("issueDatePreview", PREVIEW_FORMAT.format(issueDate));
            request.setAttribute("dueDatePreview", PREVIEW_FORMAT.format(dueDate));
            request.setAttribute("loanWindowDays", issueRecordDAO.getDefaultLoanDays());

            request.getRequestDispatcher("/views/admin/issue-book.jsp").forward(request, response);
        } catch (Exception e) {
            throw new ServletException("Unable to load issue workflow.", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (!isAdmin(session)) {
            response.sendRedirect(request.getContextPath() + "/views/auth/login.jsp");
            return;
        }

        long studentDbId = parseLong(request.getParameter("studentDbId"));
        long bookId = parseLong(request.getParameter("bookId"));
        long adminUserId = parseLong(session.getAttribute("userId"));
        String remarks = request.getParameter("remarks");

        if (studentDbId <= 0 || bookId <= 0 || adminUserId <= 0) {
            response.sendRedirect(request.getContextPath() + "/admin/issue?error=selection");
            return;
        }

        try {
            IssueRecordDAO.IssueResult result = issueRecordDAO.issueBook(studentDbId, bookId, adminUserId, remarks);
            response.sendRedirect(request.getContextPath()
                    + "/admin/issue?success=issued"
                    + "&reference=" + encode(result.getReference())
                    + "&studentId=" + encode(result.getStudentId())
                    + "&book=" + encode(result.getBookTitle())
                    + "&due=" + encode(PREVIEW_FORMAT.format(result.getDueDate())));
        } catch (IllegalStateException e) {
            String error = "server";
            if ("student_inactive".equalsIgnoreCase(e.getMessage())) {
                error = "student_inactive";
            } else if ("book_unavailable".equalsIgnoreCase(e.getMessage())) {
                error = "book_unavailable";
            }
            response.sendRedirect(request.getContextPath() + "/admin/issue?error=" + encode(error));
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/issue?error=server");
        }
    }

    private boolean isAdmin(HttpSession session) {
        return session != null
                && session.getAttribute("user") != null
                && "ADMIN".equals(String.valueOf(session.getAttribute("role")));
    }

    private long parseLong(Object value) {
        if (value == null) {
            return 0L;
        }
        try {
            return Long.parseLong(String.valueOf(value).trim());
        } catch (NumberFormatException ex) {
            return 0L;
        }
    }

    private String encode(String value) {
        return URLEncoder.encode(value == null ? "" : value, StandardCharsets.UTF_8);
    }
}
