package com.lulibrisync.controller.search;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

@WebServlet("/search/isbn")
public class ISBNLookupServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String isbn = request.getParameter("isbn");
        response.sendRedirect(request.getContextPath()
                + "/search/advanced?isbn="
                + URLEncoder.encode(isbn == null ? "" : isbn, StandardCharsets.UTF_8));
    }
}
