package com.lulibrisync.controller.student;

import com.lulibrisync.dao.UserDAO;
import com.lulibrisync.service.EmailService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.Serializable;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.security.SecureRandom;
import java.time.LocalDateTime;

@WebServlet("/student/profile")
public class ProfileServlet extends HttpServlet {

    private static final String SESSION_PENDING_PROFILE_UPDATE = "pendingProfileUpdate";

    private final UserDAO userDAO = new UserDAO();
    private final EmailService emailService = new EmailService();
    private final SecureRandom secureRandom = new SecureRandom();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/views/auth/login.jsp");
            return;
        }

        try {
            long userId = parseLong(session.getAttribute("userId"));
            UserDAO.StudentProfile profile = userDAO.findStudentProfileByUserId(userId);
            if (profile == null) {
                response.sendRedirect(request.getContextPath() + "/views/auth/login.jsp");
                return;
            }

            request.setAttribute("studentProfile", profile);
            PendingProfileUpdate pendingUpdate = (PendingProfileUpdate) session.getAttribute(SESSION_PENDING_PROFILE_UPDATE);
            request.setAttribute("otpPending", pendingUpdate != null);
            request.setAttribute("maskedOtpEmail", pendingUpdate == null ? "" : maskEmail(pendingUpdate.otpRecipientEmail));
            request.setAttribute("profileDraftName", pendingUpdate == null ? profile.getUser().getName() : pendingUpdate.name);
            request.setAttribute("profileDraftEmail", pendingUpdate == null ? profile.getUser().getEmail() : pendingUpdate.email);
            request.setAttribute("profileDraftCourse", pendingUpdate == null ? profile.getCourse() : pendingUpdate.course);
            request.setAttribute("profileDraftYearLevel", pendingUpdate == null ? profile.getYearLevel() : pendingUpdate.yearLevel);
            request.setAttribute("profileDraftPhone", pendingUpdate == null ? profile.getPhone() : pendingUpdate.phone);
            request.setAttribute("profileDraftAddress", pendingUpdate == null ? profile.getAddress() : pendingUpdate.address);
            request.getRequestDispatcher("/views/student/profile.jsp").forward(request, response);
        } catch (Exception e) {
            throw new ServletException("Unable to load student profile.", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/views/auth/login.jsp");
            return;
        }

        String action = value(request.getParameter("action"));
        if ("verify-otp".equalsIgnoreCase(action)) {
            handleVerifyOtp(request, response, session);
            return;
        }

        handleRequestOtp(request, response, session);
    }

    private void handleRequestOtp(HttpServletRequest request, HttpServletResponse response, HttpSession session)
            throws IOException {

        long userId = parseLong(session.getAttribute("userId"));
        String name = value(request.getParameter("name"));
        String email = value(request.getParameter("email")).toLowerCase();
        String course = value(request.getParameter("course"));
        String yearLevel = value(request.getParameter("yearLevel"));
        String phone = value(request.getParameter("phone"));
        String address = value(request.getParameter("address"));

        if (name.isEmpty() || email.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/student/profile?error=missing");
            return;
        }

        try {
            UserDAO.StudentProfile currentProfile = userDAO.findStudentProfileByUserId(userId);
            if (currentProfile == null) {
                response.sendRedirect(request.getContextPath() + "/student/profile?error=server");
                return;
            }

            String otpRecipientEmail = value(currentProfile.getUser().getEmail()).toLowerCase();
            String otpRecipientName = value(currentProfile.getUser().getName());
            if (otpRecipientEmail.isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/student/profile?error=mail_not_configured");
                return;
            }

            String otpCode = String.format("%06d", secureRandom.nextInt(1_000_000));
            PendingProfileUpdate pendingUpdate = new PendingProfileUpdate(
                    userId,
                    name,
                    email,
                    course,
                    yearLevel,
                    phone,
                    address,
                    otpRecipientEmail,
                    otpCode,
                    LocalDateTime.now().plusMinutes(10)
            );

            emailService.sendProfileOtp(otpRecipientEmail, otpRecipientName.isEmpty() ? name : otpRecipientName, otpCode);
            session.setAttribute(SESSION_PENDING_PROFILE_UPDATE, pendingUpdate);
            response.sendRedirect(request.getContextPath() + "/student/profile?success=otp_sent");
        } catch (IllegalStateException e) {
            String error = "server";
            if ("mail_not_configured".equalsIgnoreCase(e.getMessage())) {
                error = "mail_not_configured";
            } else if ("mail_send_failed".equalsIgnoreCase(e.getMessage())) {
                error = "mail_send_failed";
            }
            response.sendRedirect(request.getContextPath() + "/student/profile?error=" + encode(error));
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/student/profile?error=server");
        }
    }

    private void handleVerifyOtp(HttpServletRequest request, HttpServletResponse response, HttpSession session)
            throws IOException {

        PendingProfileUpdate pendingUpdate = (PendingProfileUpdate) session.getAttribute(SESSION_PENDING_PROFILE_UPDATE);
        if (pendingUpdate == null) {
            response.sendRedirect(request.getContextPath() + "/student/profile?error=otp_missing");
            return;
        }

        String otp = value(request.getParameter("otp"));
        if (otp.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/student/profile?error=otp_missing");
            return;
        }

        if (pendingUpdate.expiresAt.isBefore(LocalDateTime.now())) {
            session.removeAttribute(SESSION_PENDING_PROFILE_UPDATE);
            response.sendRedirect(request.getContextPath() + "/student/profile?error=otp_expired");
            return;
        }

        if (!pendingUpdate.otpCode.equals(otp)) {
            response.sendRedirect(request.getContextPath() + "/student/profile?error=otp_invalid");
            return;
        }

        try {
            userDAO.updateStudentProfile(
                    pendingUpdate.userId,
                    pendingUpdate.name,
                    pendingUpdate.email,
                    pendingUpdate.course,
                    pendingUpdate.yearLevel,
                    pendingUpdate.phone,
                    pendingUpdate.address
            );
            session.setAttribute("user", pendingUpdate.name);
            session.setAttribute("userEmail", pendingUpdate.email.toLowerCase());
            session.removeAttribute(SESSION_PENDING_PROFILE_UPDATE);
            response.sendRedirect(request.getContextPath() + "/student/profile?success=updated");
        } catch (IllegalStateException e) {
            String error = "server";
            if ("email_exists".equalsIgnoreCase(e.getMessage())) {
                error = "email_exists";
            }
            response.sendRedirect(request.getContextPath() + "/student/profile?error=" + encode(error));
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/student/profile?error=server");
        }
    }

    private long parseLong(Object value) {
        try {
            return Long.parseLong(String.valueOf(value).trim());
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

    private String maskEmail(String email) {
        if (email == null || email.isBlank() || !email.contains("@")) {
            return "your email";
        }
        String[] parts = email.split("@", 2);
        String local = parts[0];
        String domain = parts[1];
        if (local.length() <= 2) {
            return local.charAt(0) + "***@" + domain;
        }
        return local.substring(0, 2) + "***@" + domain;
    }

    private static final class PendingProfileUpdate implements Serializable {
        private final long userId;
        private final String name;
        private final String email;
        private final String course;
        private final String yearLevel;
        private final String phone;
        private final String address;
        private final String otpRecipientEmail;
        private final String otpCode;
        private final LocalDateTime expiresAt;

        private PendingProfileUpdate(long userId, String name, String email, String course, String yearLevel,
                                     String phone, String address, String otpRecipientEmail,
                                     String otpCode, LocalDateTime expiresAt) {
            this.userId = userId;
            this.name = name;
            this.email = email;
            this.course = course;
            this.yearLevel = yearLevel;
            this.phone = phone;
            this.address = address;
            this.otpRecipientEmail = otpRecipientEmail;
            this.otpCode = otpCode;
            this.expiresAt = expiresAt;
        }
    }
}
