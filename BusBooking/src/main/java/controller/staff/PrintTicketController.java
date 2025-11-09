/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller.staff;

import DAO.BookingDAO;
import dto.BookingAdminView;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "PrintTicketController", urlPatterns = {"/print-ticket"})
public class PrintTicketController extends HttpServlet {
    
    private final BookingDAO bookingDAO = new BookingDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int bookingId = Integer.parseInt(request.getParameter("id"));
            BookingAdminView booking = bookingDAO.findById(bookingId);
            
            // (Bạn nên thêm một hàm trong DAO để cập nhật 
            // SeatStatus = 'Used' hoặc TicketStatus = 'Printed' ở đây)
            // bookingDAO.updateSeatStatus(bookingId, "Used");

            request.setAttribute("ticket", booking);
            request.getRequestDispatcher("/WEB-INF/jsp/print-ticket.jsp").forward(request, response);
            
        } catch (Exception e) {
            response.getWriter().println("Lỗi khi tải dữ liệu in: " + e.getMessage());
        }
    }
}