package com.lulibrisync.controller.student;

import com.lulibrisync.dao.BookDAO;
import com.lulibrisync.dao.ReservationDAO;
import com.lulibrisync.dao.UserDAO;
import com.lulibrisync.model.Book;
import com.lulibrisync.model.Reservation;
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

@WebServlet("/student/reservations")
public class ReservationServlet extends HttpServlet {

    private static final DateTimeFormatter DATE_TIME_FORMAT = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");

    private final UserDAO userDAO = new UserDAO();
    private final ReservationDAO reservationDAO = new ReservationDAO();
    private final BookDAO bookDAO = new BookDAO();
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

            List<Reservation> reservations = reservationDAO.findByStudent(profile.getStudentDbId());
            List<Book> reserveSuggestions = bookDAO.findAll();

            int pendingCount = 0;
            int readyCount = 0;
            int claimedCount = 0;
            for (Reservation reservation : reservations) {
                if ("PENDING".equalsIgnoreCase(reservation.getStatus())) {
                    pendingCount++;
                } else if ("READY".equalsIgnoreCase(reservation.getStatus())) {
                    readyCount++;
                } else if ("CLAIMED".equalsIgnoreCase(reservation.getStatus())) {
                    claimedCount++;
                }
            }

            request.setAttribute("studentProfile", profile);
            request.setAttribute("reservations", reservations);
            request.setAttribute("reserveSuggestions", reserveSuggestions);
            request.setAttribute("pendingCount", pendingCount);
            request.setAttribute("readyCount", readyCount);
            request.setAttribute("claimedCount", claimedCount);

            request.getRequestDispatcher("/views/student/reservations.jsp").forward(request, response);
        } catch (Exception e) {
            throw new ServletException("Unable to load reservations.", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/views/auth/login.jsp");
            return;
        }

        String action = value(request.getParameter("action"));

        try {
            long userId = Long.parseLong(String.valueOf(session.getAttribute("userId")));
            UserDAO.StudentProfile profile = userDAO.findStudentProfileByUserId(userId);
            if (profile == null) {
                response.sendRedirect(request.getContextPath() + "/views/auth/login.jsp");
                return;
            }

            if ("cancel".equalsIgnoreCase(action)) {
                long reservationId = parseLong(request.getParameter("reservationId"));
                if (!reservationDAO.cancelReservation(reservationId, profile.getStudentDbId())) {
                    response.sendRedirect(request.getContextPath() + "/student/reservations?error=missing");
                    return;
                }
                automationService.runMaintenance();
                response.sendRedirect(request.getContextPath() + "/student/reservations?success=cancelled");
                return;
            }

            long bookId = parseLong(request.getParameter("bookId"));
            if (bookId <= 0) {
                response.sendRedirect(request.getContextPath() + "/student/reservations?error=book");
                return;
            }

            ReservationDAO.ReservationResult result = reservationDAO.createReservation(profile.getStudentDbId(), bookId);
            automationService.runMaintenance();

            response.sendRedirect(request.getContextPath()
                    + "/student/reservations?success=reserved"
                    + "&book=" + encode(result.getTitle())
                    + "&queue=" + result.getQueuePosition()
                    + "&statusLabel=" + encode(result.getStatus())
                    + "&expiresAt=" + encode(result.getExpiresAt() == null
                    ? "Pending queue"
                    : DATE_TIME_FORMAT.format(result.getExpiresAt())));
        } catch (IllegalStateException e) {
            String error = "server";
            if ("reservation_exists".equalsIgnoreCase(e.getMessage())) {
                error = "reservation_exists";
            } else if ("already_issued".equalsIgnoreCase(e.getMessage())) {
                error = "already_issued";
            }
            response.sendRedirect(request.getContextPath() + "/student/reservations?error=" + encode(error));
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/student/reservations?error=server");
        }
    }

    private long parseLong(String value) {
        try {
            return Long.parseLong(value == null ? "" : value.trim());
        } catch (Exception e) {
            return 0L;
        }
    }

    private String value(String text) {
        return text == null ? "" : text.trim();
    }

    private String encode(String value) {
        return URLEncoder.encode(value == null ? "" : value, StandardCharsets.UTF_8);
    }
}
