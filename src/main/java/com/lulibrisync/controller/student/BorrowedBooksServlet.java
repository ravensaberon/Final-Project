package com.lulibrisync.controller.student;

import com.lulibrisync.dao.IssueRecordDAO;
import com.lulibrisync.dao.UserDAO;
import com.lulibrisync.model.IssueRecord;
import com.lulibrisync.service.LibraryAutomationService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet("/student/borrowed")
public class BorrowedBooksServlet extends HttpServlet {

    private final IssueRecordDAO issueRecordDAO = new IssueRecordDAO();
    private final UserDAO userDAO = new UserDAO();
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

            long userId = Long.parseLong(String.valueOf(session.getAttribute("userId")));
            UserDAO.StudentProfile profile = userDAO.findStudentProfileByUserId(userId);
            if (profile == null) {
                response.sendRedirect(request.getContextPath() + "/views/auth/login.jsp");
                return;
            }

            long studentDbId = profile.getStudentDbId();
            List<IssueRecord> borrowedHistory = issueRecordDAO.findBorrowedHistory(studentDbId);

            int activeCount = 0;
            int returnedCount = 0;
            int overdueCount = 0;
            double unpaidFineTotal = 0;
            for (IssueRecord record : borrowedHistory) {
                if ("ISSUED".equalsIgnoreCase(record.getStatus())) {
                    activeCount++;
                } else if ("RETURNED".equalsIgnoreCase(record.getStatus())) {
                    returnedCount++;
                } else if ("OVERDUE".equalsIgnoreCase(record.getStatus())) {
                    overdueCount++;
                    unpaidFineTotal += record.getFineAmount();
                }
            }

            request.setAttribute("borrowedHistory", borrowedHistory);
            request.setAttribute("activeCount", activeCount);
            request.setAttribute("returnedCount", returnedCount);
            request.setAttribute("overdueCount", overdueCount);
            request.setAttribute("unpaidFineTotal", unpaidFineTotal);

            request.getRequestDispatcher("/views/student/borrowed.jsp").forward(request, response);
        } catch (Exception e) {
            throw new ServletException("Unable to load borrowed books.", e);
        }
    }

}
