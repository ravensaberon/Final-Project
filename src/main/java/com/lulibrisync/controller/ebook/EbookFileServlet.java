package com.lulibrisync.controller.ebook;

import com.lulibrisync.dao.BookDAO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.OutputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

@WebServlet("/ebook/file")
public class EbookFileServlet extends HttpServlet {

    private final BookDAO bookDAO = new BookDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        long bookId = parseLong(request.getParameter("bookId"));
        if (bookId <= 0) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        try {
            BookDAO.EbookMetadata metadata = bookDAO.findEbookMetadata(bookId);
            if (metadata == null || metadata.getEbookPath() == null || metadata.getEbookPath().isBlank()) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }

            Path filePath = Paths.get(metadata.getEbookPath());
            if (!Files.exists(filePath)) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }

            response.setContentType("application/pdf");
            response.setHeader("Content-Disposition", "inline; filename=\"" + filePath.getFileName() + "\"");
            response.setContentLengthLong(Files.size(filePath));

            try (OutputStream outputStream = response.getOutputStream()) {
                Files.copy(filePath, outputStream);
            }
        } catch (Exception e) {
            throw new ServletException("Unable to stream PDF file.", e);
        }
    }

    private long parseLong(String value) {
        try {
            return Long.parseLong(value == null ? "" : value.trim());
        } catch (Exception e) {
            return 0L;
        }
    }
}
