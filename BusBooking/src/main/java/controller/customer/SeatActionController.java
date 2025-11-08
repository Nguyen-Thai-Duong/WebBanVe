/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller.customer;


import DAO.BookingDAO;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.json.JSONObject; // Cần thư viện org.json

/**
 * Servlet này hoạt động như một API để xử lý các hành động
 * chọn (hold) và hủy chọn (release) ghế từ phía client.
 */
@WebServlet(name = "SeatActionController", urlPatterns = {"/api/seat-action"})
public class SeatActionController extends HttpServlet {

    private final BookingDAO bookingDAO = new BookingDAO();
    private static final int HOLD_DURATION_MINUTES = 10; // Giữ ghế trong 10 phút

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        PrintWriter out = response.getWriter();
        JSONObject jsonResponse = new JSONObject();
        
        try {
            String action = request.getParameter("action");
            HttpSession session = request.getSession();
            String sessionId = session.getId();

            if (action == null) {
                throw new Exception("Hành động (action) không được cung cấp.");
            }

            switch (action) {
                case "hold":
                    handleHoldSeat(request, response, sessionId, jsonResponse);
                    break;
                case "release":
                    handleReleaseSeat(request, response, sessionId, jsonResponse);
                    break;
                default:
                    throw new Exception("Hành động không hợp lệ: " + action);
            }

        } catch (Exception e) {
            // Xử lý lỗi chung
            jsonResponse.put("status", "error");
            jsonResponse.put("message", "Đã có lỗi xảy ra: " + e.getMessage());
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
        
        out.print(jsonResponse.toString());
        out.flush();
    }

    /**
     * Xử lý yêu cầu giữ ghế
     */
    private void handleHoldSeat(HttpServletRequest request, HttpServletResponse response, String sessionId, JSONObject jsonResponse) {
        try {
            int tripId = Integer.parseInt(request.getParameter("tripId"));
            String seatName = request.getParameter("seatName");

            if (seatName == null || seatName.isEmpty()) {
                 throw new Exception("Tên ghế (seatName) không hợp lệ.");
            }

            // Gọi hàm DAO để giữ ghế
            Integer newBookingId = bookingDAO.holdSeat(tripId, seatName, sessionId, HOLD_DURATION_MINUTES);

            if (newBookingId != null) {
                // Giữ ghế THÀNH CÔNG
                jsonResponse.put("status", "success");
                jsonResponse.put("action", "held");
                jsonResponse.put("bookingId", newBookingId); // Rất quan trọng
                jsonResponse.put("seatName", seatName);
            } else {
                // Giữ ghế THẤT BẠI (ghế đã bị lấy)
                jsonResponse.put("status", "error");
                jsonResponse.put("message", "Ghế này vừa bị người khác chọn mất rồi!");
                response.setStatus(HttpServletResponse.SC_CONFLICT); // 409 Conflict
            }
            
        } catch (NumberFormatException e) {
            jsonResponse.put("status", "error");
            jsonResponse.put("message", "TripID không hợp lệ.");
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
        } catch (Exception e) {
            jsonResponse.put("status", "error");
            jsonResponse.put("message", "Lỗi khi giữ ghế: " + e.getMessage());
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    /**
     * Xử lý yêu cầu hủy giữ ghế
     */
    private void handleReleaseSeat(HttpServletRequest request, HttpServletResponse response, String sessionId, JSONObject jsonResponse) {
        try {
            int bookingId = Integer.parseInt(request.getParameter("bookingId"));
            String seatName = request.getParameter("seatName");

            // Gọi hàm DAO để hủy giữ ghế
            boolean success = bookingDAO.releaseHeldSeat(bookingId, sessionId);

            if (success) {
                // Hủy THÀNH CÔNG
                jsonResponse.put("status", "success");
                jsonResponse.put("action", "released");
                jsonResponse.put("seatName", seatName);
            } else {
                // Hủy THẤT BẠI (có thể do sai bookingId hoặc sai session)
                jsonResponse.put("status", "error");
                jsonResponse.put("message", "Không thể hủy giữ ghế này.");
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            }
        } catch (NumberFormatException e) {
            jsonResponse.put("status", "error");
            jsonResponse.put("message", "BookingID không hợp lệ.");
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
        } catch (Exception e) {
            jsonResponse.put("status", "error");
            jsonResponse.put("message", "Lỗi khi hủy giữ ghế: " + e.getMessage());
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }
}