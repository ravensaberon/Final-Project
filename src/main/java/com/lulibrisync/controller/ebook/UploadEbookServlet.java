package com.lulibrisync.controller.ebook;

import com.lulibrisync.dao.BookDAO;
import com.lulibrisync.model.Book;
import com.lulibrisync.utils.FileUploadUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;
import java.io.IOException;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;

@WebServlet("/ebook/upload")
@MultipartConfig(maxFileSize = 25 * 1024 * 1024L, maxRequestSize = 30 * 1024 * 1024L)
public class UploadEbookServlet extends HttpServlet {

    private final BookDAO bookDAO = new BookDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || !"ADMIN".equals(String.valueOf(session.getAttribute("role")))) {
            response.sendRedirect(request.getContextPath() + "/views/auth/login.jsp");
            return;
        }

        try {
            List<Book> books = bookDAO.findAll();
            request.setAttribute("ebookBooks", books);
            request.getRequestDispatcher("/views/ebook/upload.jsp").forward(request, response);
        } catch (Exception e) {
            throw new ServletException("Unable to load e-book upload page.", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || !"ADMIN".equals(String.valueOf(session.getAttribute("role")))) {
            response.sendRedirect(request.getContextPath() + "/views/auth/login.jsp");
            return;
        }

        long bookId = parseLong(request.getParameter("bookId"));
        Part pdfPart = request.getPart("pdfFile");
        if (bookId <= 0 || pdfPart == null || pdfPart.getSize() <= 0) {
            response.sendRedirect(request.getContextPath() + "/ebook/upload?error=missing");
            return;
        }

        try {
            Book book = bookDAO.findById(bookId);
            if (book == null) {
                response.sendRedirect(request.getContextPath() + "/ebook/upload?error=book");
                return;
            }

            Path uploadDirectory = Paths.get(System.getProperty("user.home"), "LU_Librisync", "uploads", "ebooks");
            String savedPath = FileUploadUtil.savePdf(pdfPart, uploadDirectory, book.getTitle());
            bookDAO.attachEbook(bookId, savedPath);

            response.sendRedirect(request.getContextPath() + "/ebook/upload?success=uploaded&book=" + bookId);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/ebook/upload?error=server");
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
