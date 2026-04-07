package com.lulibrisync.filter;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebFilter(urlPatterns = {"/admin/*", "/views/admin/*", "/views/ebook/upload.jsp"})
public class RoleFilter implements Filter {

    @Override
    public void doFilter(javax.servlet.ServletRequest request, javax.servlet.ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        HttpSession session = httpRequest.getSession(false);

        if (session == null || !"ADMIN".equals(session.getAttribute("role"))) {
            httpResponse.sendRedirect(httpRequest.getContextPath() + "/views/auth/login.jsp");
            return;
        }

        chain.doFilter(request, response);
    }
}
