/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller.staff;


import DAO.BookingDAO; // DAO của bạn
import dto.BookingAdminView; // DTO của bạn
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.time.format.DateTimeFormatter;
import org.json.JSONObject; // Thư viện org.json

@WebServlet(name = "CheckInController", urlPatterns = {"/api/check-in"})
public class CheckInController extends HttpServlet {

    private final BookingDAO bookingDAO = new BookingDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        JSONObject jsonResponse = new JSONObject();

        try {
            int bookingId = Integer.parseInt(request.getParameter("bookingId"));
            BookingAdminView booking = bookingDAO.findById(bookingId);

            // Logic kiểm tra vé
            if (booking == null) {
                // Lỗi 1: Không tìm thấy vé
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                jsonResponse.put("message", "Không tìm thấy vé với mã: " + bookingId);
            } else if ("Cancelled".equals(booking.getBookingStatus())) {
                // Lỗi 2: Vé đã bị hủy
                response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                jsonResponse.put("message", "Vé này đã bị hủy (Trạng thái: " + booking.getBookingStatus() + ")");
            } else if ("Used".equals(booking.getSeatStatus())) {
                // Lỗi 3: Vé đã check-in
                response.setStatus(HttpServletResponse.SC_CONFLICT); // 409 Conflict
                jsonResponse.put("message", "Vé này đã được check-in (sử dụng) trước đó.");
            } else if ("Confirmed".equals(booking.getBookingStatus())) {
                // THÀNH CÔNG: Vé hợp lệ
                jsonResponse.put("status", "success");
                jsonResponse.put("bookingId", booking.getBookingId());
                jsonResponse.put("customerName", booking.getCustomerName() != null ? booking.getCustomerName() : booking.getGuestEmail());
                jsonResponse.put("customerPhone", booking.getCustomerPhone() != null ? booking.getCustomerPhone() : "N/A");
                jsonResponse.put("route", booking.getRouteOrigin() + " -> " + booking.getRouteDestination());
                jsonResponse.put("departureTime", booking.getDepartureTime().format(DateTimeFormatter.ofPattern("HH:mm 'ngày' dd/MM/yyyy")));
                jsonResponse.put("seatNumber", booking.getSeatNumber());
            } else {
                // Lỗi 4: Vé chưa thanh toán (Pending)
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                jsonResponse.put("message", "Vé này chưa được thanh toán (Trạng thái: " + booking.getBookingStatus() + ")");
            }

        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            jsonResponse.put("message", "Mã vé không hợp lệ. Phải là một con số.");
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            jsonResponse.put("message", "Lỗi máy chủ: " + e.getMessage());
        }

        out.print(jsonResponse.toString());
        out.flush();
    }
}