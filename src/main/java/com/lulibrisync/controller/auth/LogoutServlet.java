package com.lulibrisync.controller.auth;

import com.lulibrisync.config.ActiveSessionManager;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/logout")
public class LogoutServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        HttpSession session = request.getSession(false);
        if (session != null) {
            ActiveSessionManager.releaseIfOwned(request.getServletContext(), session);
            session.invalidate();
        }

        response.sendRedirect(request.getContextPath() + "/index.jsp");
    }


}
