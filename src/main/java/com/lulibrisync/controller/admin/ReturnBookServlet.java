package com.lulibrisync.controller.admin;

import com.lulibrisync.dao.IssueRecordDAO;
import com.lulibrisync.model.IssueRecord;
import com.lulibrisync.service.LibraryAutomationService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.time.format.DateTimeFormatter;
import java.util.List;

@WebServlet("/admin/return")
public class ReturnBookServlet extends HttpServlet {

    private static final DateTimeFormatter DATE_TIME_FORMAT = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");

    private final IssueRecordDAO issueRecordDAO = new IssueRecordDAO();
    private final LibraryAutomationService automationService = new LibraryAutomationService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!isAdmin(request.getSession(false))) {
            response.sendRedirect(request.getContextPath() + "/views/auth/login.jsp");
            return;
        }

        String studentIdQuery = value(request.getParameter("studentId"));
        String referenceQuery = value(request.getParameter("reference"));

        try {
            automationService.runMaintenance();

            List<IssueRecord> returnCandidates = issueRecordDAO.findReturnCandidates(studentIdQuery, referenceQuery);
            List<IssueRecord> recentReturns = issueRecordDAO.findRecentReturns(8);

            request.setAttribute("returnCandidates", returnCandidates);
            request.setAttribute("recentReturns", recentReturns);
            request.setAttribute("studentIdQuery", studentIdQuery);
            request.setAttribute("referenceQuery", referenceQuery);

            request.getRequestDispatcher("/views/admin/return-book.jsp").forward(request, response);
        } catch (Exception e) {
            throw new ServletException("Unable to load return workflow.", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!isAdmin(request.getSession(false))) {
            response.sendRedirect(request.getContextPath() + "/views/auth/login.jsp");
            return;
        }

        long issueRecordId = parseLong(request.getParameter("issueRecordId"));
        String remarks = value(request.getParameter("remarks"));

        if (issueRecordId <= 0) {
            response.sendRedirect(request.getContextPath() + "/admin/return?error=selection");
            return;
        }

        try {
            IssueRecordDAO.ReturnResult result = issueRecordDAO.processReturn(issueRecordId, remarks);
            automationService.runMaintenance();

            response.sendRedirect(request.getContextPath()
                    + "/admin/return?success=returned"
                    + "&studentIdValue=" + encode(result.getRecord().getStudentId())
                    + "&book=" + encode(result.getRecord().getBookTitle())
                    + "&returnedAt=" + encode(DATE_TIME_FORMAT.format(result.getReturnDate())));
        } catch (IllegalStateException e) {
            String error = "server";
            if ("record_missing".equalsIgnoreCase(e.getMessage())) {
                error = "missing";
            } else if ("already_returned".equalsIgnoreCase(e.getMessage())) {
                error = "already_returned";
            }
            response.sendRedirect(request.getContextPath() + "/admin/return?error=" + encode(error));
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/return?error=server");
        }
    }

    private boolean isAdmin(HttpSession session) {
        return session != null
                && session.getAttribute("user") != null
                && "ADMIN".equals(String.valueOf(session.getAttribute("role")));
    }

    private long parseLong(String value) {
        try {
            return Long.parseLong(value == null ? "" : value.trim());
        } catch (Exception e) {
            return 0L;
        }
    }

    private String value(String input) {
        return input == null ? "" : input.trim();
    }

    private String encode(String value) {
        return URLEncoder.encode(value == null ? "" : value, StandardCharsets.UTF_8);
    }
}
