package com.lulibrisync.controller.admin;

import com.lulibrisync.dao.AnalyticsDAO;
import com.lulibrisync.service.LibraryAutomationService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import java.util.Map;

@WebServlet("/admin/analytics")
public class AnalyticsServlet extends HttpServlet {

    private final AnalyticsDAO analyticsDAO = new AnalyticsDAO();
    private final LibraryAutomationService automationService = new LibraryAutomationService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || !"ADMIN".equals(String.valueOf(session.getAttribute("role")))) {
            response.sendRedirect(request.getContextPath() + "/views/auth/login.jsp");
            return;
        }

        try {
            automationService.runMaintenance();

            Map<String, Object> overview = analyticsDAO.loadOverview();
            List<Map<String, Object>> mostBorrowed = analyticsDAO.loadMostBorrowedBooks(6);
            List<Map<String, Object>> categoryDemand = analyticsDAO.loadCategoryDemand(6);
            List<Map<String, Object>> overdueTrend = analyticsDAO.loadOverdueTrend(6);
            List<Map<String, Object>> readingHistory = analyticsDAO.loadReadingHistory(8);
            List<Map<String, Object>> topReaders = analyticsDAO.loadTopReaders(5);
            List<Map<String, Object>> automationQueue = analyticsDAO.loadAutomationQueue(6);

            request.setAttribute("analyticsOverview", overview);
            request.setAttribute("mostBorrowedBooks", mostBorrowed);
            request.setAttribute("categoryDemand", categoryDemand);
            request.setAttribute("overdueTrend", overdueTrend);
            request.setAttribute("readingHistory", readingHistory);
            request.setAttribute("topReaders", topReaders);
            request.setAttribute("automationQueue", automationQueue);

            request.getRequestDispatcher("/views/admin/analytics.jsp").forward(request, response);
        } catch (Exception e) {
            throw new ServletException("Unable to load analytics dashboard.", e);
        }
    }
}
