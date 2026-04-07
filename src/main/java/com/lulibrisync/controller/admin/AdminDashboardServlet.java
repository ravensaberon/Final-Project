package com.lulibrisync.controller.admin;

import com.lulibrisync.config.DBConnection;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.sql.*;

@WebServlet("/admin/dashboard")
public class AdminDashboardServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response) {

        try (Connection conn = DBConnection.getConnection()) {

            Statement st = conn.createStatement();

            ResultSet rs1 = st.executeQuery("SELECT COUNT(*) FROM books");
            rs1.next();
            request.setAttribute("totalBooks", rs1.getInt(1));

            ResultSet rs2 = st.executeQuery("SELECT COUNT(*) FROM students");
            rs2.next();
            request.setAttribute("totalStudents", rs2.getInt(1));

            ResultSet rs3 = st.executeQuery("SELECT COUNT(*) FROM issue_records WHERE status='ISSUED'");
            rs3.next();
            request.setAttribute("issuedBooks", rs3.getInt(1));

            ResultSet rs4 = st.executeQuery("SELECT COUNT(*) FROM issue_records WHERE status='OVERDUE'");
            rs4.next();
            request.setAttribute("overdueBooks", rs4.getInt(1));

            request.getRequestDispatcher("/views/admin/dashboard.jsp")
                    .forward(request, response);

        } catch (Exception e) {
            System.out.println("Error: " + e.getMessage());
        }
    }
}