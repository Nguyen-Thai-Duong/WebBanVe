package controller.staff;

import DAO.TicketDAO;
import DAO.UserDAO;
import dto.TicketSummary;
import dto.TripOption;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import java.util.Objects;
import model.User;

/**
 * Staff console for handling ticket life-cycle operations (CRU, verify, create physical ticket).
 */
@WebServlet(name = "TicketManagementController", urlPatterns = {"/staff/tickets"})
public class TicketManagementController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final TicketDAO ticketDAO = new TicketDAO();
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session != null) {
            Object message = session.getAttribute("staffTicketMessage");
            Object type = session.getAttribute("staffTicketMessageType");
            if (message != null) {
                request.setAttribute("flashMessage", message);
                session.removeAttribute("staffTicketMessage");
            }
            if (type != null) {
                request.setAttribute("flashType", type);
                session.removeAttribute("staffTicketMessageType");
            }
        }

        String keyword = trim(request.getParameter("q"));
        String status = trim(request.getParameter("status"));
        List<TicketSummary> tickets = ticketDAO.findTickets(keyword, status);
        List<TripOption> tripOptions = ticketDAO.findUpcomingTrips(50);

        request.setAttribute("tickets", tickets);
        request.setAttribute("tripOptions", tripOptions);
        request.setAttribute("filterKeyword", keyword);
        request.setAttribute("filterStatus", status);
        request.setAttribute("activeMenu", "tickets");
        request.setAttribute("navbarSearchPlaceholder", "Tìm kiếm vé...");

        request.getRequestDispatcher("/WEB-INF/staff/ticket-management.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String action = trim(request.getParameter("action"));
        if (action == null) {
            response.sendRedirect(buildRedirectUrl(request));
            return;
        }

        switch (action) {
            case "create":
                handleCreateTicket(request, response);
                break;
            case "update":
                handleUpdateTicket(request, response);
                break;
            case "verify":
                handleVerifyTicket(request, response);
                break;
            default:
                setFlash(request, "warning", "Hành động không được hỗ trợ.");
                response.sendRedirect(buildRedirectUrl(request));
        }
    }

    private void handleCreateTicket(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Integer tripId = parseInteger(request.getParameter("tripId"));
        String seatNumber = normalizeSeat(request.getParameter("seatNumber"));
        String identifier = trim(request.getParameter("customerIdentifier"));
        String guestPhone = trim(request.getParameter("guestPhone"));
        String guestEmail = trim(request.getParameter("guestEmail"));

        if (tripId == null || seatNumber == null) {
            setFlash(request, "danger", "Vui lòng chọn chuyến đi và nhập số ghế.");
            response.sendRedirect(buildRedirectUrl(request));
            return;
        }

        Integer customerId = null;
        if (identifier != null) {
            User user = userDAO.findByIdentifier(identifier);
            if (user == null) {
                setFlash(request, "danger", "Không tìm thấy khách hàng tương ứng với thông tin cung cấp.");
                response.sendRedirect(buildRedirectUrl(request));
                return;
            }
            if (!Objects.equals(user.getRole(), "Customer")) {
                setFlash(request, "danger", "Chỉ có thể gán vé cho tài khoản khách hàng.");
                response.sendRedirect(buildRedirectUrl(request));
                return;
            }
            customerId = user.getUserId();
        }

        if (customerId == null && guestPhone == null) {
            setFlash(request, "danger", "Vui lòng nhập số điện thoại khách vãng lai nếu không chọn khách hàng.");
            response.sendRedirect(buildRedirectUrl(request));
            return;
        }

        Integer ticketId = ticketDAO.createPhysicalTicket(tripId, customerId, guestPhone, guestEmail, seatNumber);
        if (ticketId == null) {
            setFlash(request, "danger", "Không thể tạo vé mới. Vui lòng kiểm tra lại thông tin.");
        } else {
            setFlash(request, "success", "Đã tạo vé vật lý thành công với mã #" + ticketId + ".");
        }
        response.sendRedirect(buildRedirectUrl(request));
    }

    private void handleUpdateTicket(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Integer ticketId = parseInteger(request.getParameter("ticketId"));
        if (ticketId == null) {
            setFlash(request, "danger", "Thiếu mã vé cần cập nhật.");
            response.sendRedirect(buildRedirectUrl(request));
            return;
        }
        String seatNumber = normalizeSeat(request.getParameter("seatNumber"));
        String bookingStatus = trim(request.getParameter("bookingStatus"));
        String seatStatus = trim(request.getParameter("seatStatus"));
        String ticketStatus = trim(request.getParameter("ticketStatus"));

        if (seatNumber == null) {
            setFlash(request, "danger", "Số ghế không hợp lệ.");
            response.sendRedirect(buildRedirectUrl(request));
            return;
        }

        boolean updated = ticketDAO.updateTicketDetails(ticketId, seatNumber, bookingStatus, seatStatus, ticketStatus);
        if (updated) {
            setFlash(request, "success", "Đã cập nhật vé thành công.");
        } else {
            setFlash(request, "danger", "Không thể cập nhật vé. Vui lòng thử lại.");
        }
        response.sendRedirect(buildRedirectUrl(request));
    }

    private void handleVerifyTicket(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Integer ticketId = parseInteger(request.getParameter("ticketId"));
        if (ticketId == null) {
            setFlash(request, "danger", "Thiếu mã vé cần xác thực.");
            response.sendRedirect(buildRedirectUrl(request));
            return;
        }
        HttpSession session = request.getSession(false);
        User currentUser = session != null ? (User) session.getAttribute("currentUser") : null;
        if (currentUser == null) {
            setFlash(request, "danger", "Phiên làm việc đã hết hạn. Vui lòng đăng nhập lại.");
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        boolean verified = ticketDAO.verifyTicket(ticketId, currentUser.getUserId());
        if (verified) {
            setFlash(request, "success", "Đã xác thực vé thành công.");
        } else {
            setFlash(request, "danger", "Không thể xác thực vé. Vui lòng thử lại.");
        }
        response.sendRedirect(buildRedirectUrl(request));
    }

    private void setFlash(HttpServletRequest request, String type, String message) {
        HttpSession session = request.getSession(true);
        session.setAttribute("staffTicketMessage", message);
        session.setAttribute("staffTicketMessageType", type);
    }

    private Integer parseInteger(String value) {
        try {
            return value != null && !value.isBlank() ? Integer.valueOf(value) : null;
        } catch (NumberFormatException ex) {
            return null;
        }
    }

    private String normalizeSeat(String seat) {
        if (seat == null) {
            return null;
        }
        String trimmed = seat.trim();
        return trimmed.isEmpty() ? null : trimmed.toUpperCase();
    }

    private String trim(String value) {
        return value != null ? value.trim() : null;
    }

    private String buildRedirectUrl(HttpServletRequest request) {
        return request.getContextPath() + "/staff/tickets";
    }
}
