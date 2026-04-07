package com.lulibrisync.filter;

import com.lulibrisync.config.ActiveSessionManager;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebFilter(urlPatterns = {"/admin/*", "/student/*", "/views/admin/*", "/views/student/*", "/views/auth/change-password.jsp"})
public class AuthFilter implements Filter {

    @Override
    public void doFilter(javax.servlet.ServletRequest request, javax.servlet.ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        HttpSession session = httpRequest.getSession(false);

        if (session == null || session.getAttribute("user") == null) {
            httpResponse.sendRedirect(httpRequest.getContextPath() + "/views/auth/login.jsp");
            return;
        }

        Object userAttr = session.getAttribute("user");
        Object roleAttr = session.getAttribute("role");

        if (!ActiveSessionManager.tryAcquire(
                httpRequest.getServletContext(),
                session,
                userAttr == null ? "" : String.valueOf(userAttr),
                roleAttr == null ? "" : String.valueOf(roleAttr))) {
            session.invalidate();
            httpResponse.sendRedirect(httpRequest.getContextPath() + "/views/auth/login.jsp?error=session_active");
            return;
        }

        chain.doFilter(request, response);
    }
}
