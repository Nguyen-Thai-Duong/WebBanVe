/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller.customer; // Hoặc package của bạn

import DAO.BookingDAO; // bookingDAO của bạn
import dto.BookingAdminView; // DTO bạn dùng trong BookingDAO
import java.io.IOException;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "CheckoutController", urlPatterns = {"/payment"})
public class CheckoutController extends HttpServlet {

    private final BookingDAO bookingDAO = new BookingDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        String rawBookingIds = request.getParameter("bookingIds"); // Ví dụ: "123,124"

        if (rawBookingIds == null || rawBookingIds.isEmpty()) {
            // Không có ID nào được gửi, quay lại trang chủ hoặc trang tìm kiếm
            response.sendRedirect(request.getContextPath() + "/homepage.jsp");
            return;
        }

        List<BookingAdminView> pendingBookings = new ArrayList<>();
        List<Integer> bookingIdList = new ArrayList<>();
        int tripId = -1; // Để lưu TripID, dùng cho việc quay lại

        try {
            // --- Bước 1: Lấy và Parse các Booking ID ---
            String[] ids = rawBookingIds.split(",");
            for (String idStr : ids) {
                bookingIdList.add(Integer.parseInt(idStr.trim()));
            }

            // --- Bước 2: Lấy thông tin các Booking 'Pending' từ DB ---
            for (int id : bookingIdList) {
                // Bạn cần một hàm mới trong BookingDAO để lấy booking 'Pending'
                // Tạm thời, ta dùng hàm findById() của bạn
                BookingAdminView booking = bookingDAO.findById(id);

                if (booking == null) {
                    throw new Exception("Lượt giữ ghế (ID: " + id + ") không tồn tại.");
                }

                // Lưu lại TripID để nếu lỗi còn biết đường quay lại
                if (tripId == -1) {
                    tripId = booking.getTripId();
                }

                // --- Bước 3: KIỂM TRA THỜI GIAN HẾT HẠN (RẤT QUAN TRỌNG) ---
                if (!"Pending".equals(booking.getBookingStatus())) {
                    throw new Exception("Ghế " + booking.getSeatNumber() + " đã được đặt hoặc đã bị hủy.");
                }
                
                if (booking.getTtlExpiry() == null || booking.getTtlExpiry().isBefore(LocalDateTime.now())) {
                    // ĐÃ HẾT HẠN!
                    // (Bạn nên có 1 hàm xóa các booking hết hạn này đi)
                    bookingDAO.delete(id); // Tạm thời xóa luôn
                    throw new Exception("Đã hết thời gian giữ ghế (" + booking.getSeatNumber() + "). Vui lòng chọn lại.");
                }

                // Nếu mọi thứ OK, thêm vào danh sách
                pendingBookings.add(booking);
            }

            // --- Bước 4: Chuyển tiếp đến trang điền thông tin ---
            // Nếu qua được hết vòng lặp => Tất cả ghế đều hợp lệ
            session.setAttribute("checkoutBookings", pendingBookings); // Gửi danh sách ghế
            session.setAttribute("checkoutBookingIds", rawBookingIds); // Gửi lại chuỗi ID
            
            // Chuyển hướng đến trang JSP để điền thông tin
            response.sendRedirect(request.getContextPath() + "/checkout.jsp");

        } catch (Exception e) {
            // --- Xử lý LỖI: Hết hạn hoặc Lỗi dữ liệu ---
            session.setAttribute("seatSelectionError", e.getMessage());
            
            // Trả người dùng về trang chọn ghế của chuyến đi đó
            // Bạn cần đảm bảo đường dẫn /select-seat có thể nhận TripID
            if (tripId != -1) {
                response.sendRedirect(request.getContextPath() + "/select-seat?tripId=" + tripId);
            } else {
                // Nếu không biết tripId, trả về trang chủ
                response.sendRedirect(request.getContextPath() + "/homepage.jsp");
            }
        }
    }
}