package com.lulibrisync.controller.ebook;

import com.lulibrisync.dao.BookDAO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/ebook/read")
public class ReadEbookServlet extends HttpServlet {

    private final BookDAO bookDAO = new BookDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        long bookId = parseLong(request.getParameter("bookId"));
        if (bookId > 0) {
            try {
                BookDAO.EbookMetadata metadata = bookDAO.findEbookMetadata(bookId);
                if (metadata != null) {
                    request.setAttribute("ebookBookId", metadata.getId());
                    request.setAttribute("ebookTitle", metadata.getTitle());
                    request.setAttribute("ebookAuthor", metadata.getAuthorName());
                    request.setAttribute("ebookIsbn", metadata.getIsbn());
                    request.setAttribute("ebookDescription", metadata.getDescription());
                    request.setAttribute("embeddedPdfUrl",
                            request.getContextPath() + "/ebook/file?bookId=" + metadata.getId());
                }
            } catch (Exception e) {
                throw new ServletException("Unable to open digital reader.", e);
            }
        }
        request.getRequestDispatcher("/views/ebook/reader.jsp").forward(request, response);
    }

    private long parseLong(String value) {
        try {
            return Long.parseLong(value == null ? "" : value.trim());
        } catch (Exception e) {
            return 0L;
        }
    }
}
