package com.lulibrisync.controller.search;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

@WebServlet("/search/barcode")
public class BarcodeSearchServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String barcode = request.getParameter("barcode");
        response.sendRedirect(request.getContextPath()
                + "/search/advanced?barcode="
                + URLEncoder.encode(barcode == null ? "" : barcode, StandardCharsets.UTF_8));
    }
}
