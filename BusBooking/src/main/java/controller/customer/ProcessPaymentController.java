package controller.customer;

import DAO.BookingDAO;
import dto.BookingAdminView; // Import DTO của bạn
import model.User;
import service.EmailService; // <-- Import EmailService của bạn

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.util.logging.Level; // <-- Dùng logger của Java
import java.util.logging.Logger; // <-- Dùng logger của Java

@WebServlet(name = "ProcessPaymentController", urlPatterns = {"/process-payment"})
public class ProcessPaymentController extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(ProcessPaymentController.class.getName()); // <-- Logger mới
    private final BookingDAO bookingDAO = new BookingDAO();
    private EmailService emailService; // <-- Dịch vụ email của bạn

    @Override
    public void init() throws ServletException {
        // Khởi tạo EmailService khi servlet khởi động
        // Lấy config từ web.xml
        String smtpUser = getServletContext().getInitParameter("SMTP_USER");
        String smtpPass = getServletContext().getInitParameter("SMTP_PASS");

        if (smtpUser == null || smtpUser.isEmpty() || smtpPass == null || smtpPass.isEmpty()) {
            LOGGER.log(Level.SEVERE, "SMTP_USER hoặc SMTP_PASS chưa được cấu hình trong web.xml");
        } else {
            this.emailService = new EmailService(smtpUser, smtpPass);
            LOGGER.info("EmailService đã được khởi tạo thành công.");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();

        String rawBookingIds = request.getParameter("bookingIds");
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        User loggedInUser = (User) session.getAttribute("USER");

        List<Integer> successIds = new ArrayList<>();
        List<BookingAdminView> confirmedBookings = new ArrayList<>();
        boolean allSuccess = true;

        try {
            String[] ids = rawBookingIds.split(",");
            for (String idStr : ids) {
                int bookingId = Integer.parseInt(idStr.trim());
                
                boolean success = bookingDAO.confirmBooking(bookingId, fullName, email, phone, loggedInUser);
                
                if (success) {
                    successIds.add(bookingId);
                    BookingAdminView confirmed = bookingDAO.findById(bookingId);
                    if (confirmed != null) {
                        confirmedBookings.add(confirmed);
                    }
                } else {
                    allSuccess = false;
                    throw new Exception("Lỗi khi xác nhận vé (ID: " + bookingId + ").");
                }
            }
            
            // --- THAY ĐỔI CHỖ NÀY ---
            // Gọi EmailService của bạn
            if (allSuccess && !confirmedBookings.isEmpty()) {
                if (this.emailService != null) { // Kiểm tra xem email service đã được init chưa
                    try {
                        String subject = "Xác nhận đặt vé thành công - Mã: " + successIds.get(0);
                        String htmlBody = createTicketEmailHtml(confirmedBookings, fullName, email, phone);
                        
                        // Gọi hàm GỬI HTML MỚI
                        emailService.sendHtmlMail(email, subject, htmlBody);
                        
                    } catch (Exception e) {
                        LOGGER.log(Level.WARNING, "Đặt vé thành công nhưng gửi email thất bại: ", e);
                    }
                } else {
                    LOGGER.log(Level.SEVERE, "EmailService chưa được khởi tạo. Không thể gửi email.");
                }
            }
            // --- KẾT THÚC THAY ĐỔI ---

            session.setAttribute("confirmedBookingIds", successIds);
            response.sendRedirect(request.getContextPath() + "/booking-success.jsp");

        } catch (Exception e) {
            session.setAttribute("checkoutError", e.getMessage());
            response.sendRedirect(request.getContextPath() + "/checkout.jsp");
        }
    }

    /**
     * Hàm này tạo nội dung HTML cho email vé xe.
     * (Giữ nguyên như cũ)
     */
    private String createTicketEmailHtml(List<BookingAdminView> bookings, String fullName, String email, String phone) {
        if (bookings == null || bookings.isEmpty()) {
            return "<p>Lỗi: Không có thông tin vé.</p>";
        }
        
        // Lấy thông tin chung từ vé đầu tiên
        BookingAdminView firstTicket = bookings.get(0);
        String origin = firstTicket.getRouteOrigin();
        String destination = firstTicket.getRouteDestination();
        String departureTime = firstTicket.getDepartureTime().toString(); // Cần format
        String vehiclePlate = firstTicket.getVehiclePlate();

        StringBuilder sb = new StringBuilder();
        sb.append("<div style='font-family: Arial, sans-serif; max-width: 600px; margin: auto; border: 1px solid #ddd; padding: 20px;'>");
        sb.append("<h1 style='color: #0d6efd;'>Cảm ơn bạn đã đặt vé!</h1>");
        // ... (phần còn lại của HTML y hệt như tin nhắn trước) ...
        sb.append("</div>");

        return sb.toString();
    }
}