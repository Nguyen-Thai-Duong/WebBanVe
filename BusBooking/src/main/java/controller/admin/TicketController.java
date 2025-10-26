package controller.admin;

import DAO.TicketDAO;
import dto.ticket.TicketSummary;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

/**
 * Admin ticket controller used for auditing, editing, and deleting ticket records.
 */
@WebServlet(name = "AdminTicketController", urlPatterns = {"/admin/tickets"})
public class TicketController extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final String FLASH_KEY = "adminTicketMessage";
    private static final String FLASH_TYPE_KEY = "adminTicketMessageType";

    private final TicketDAO ticketDAO = new TicketDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        loadFlash(request);
        String keyword = trim(request.getParameter("q"));
        String status = trim(request.getParameter("status"));
        List<TicketSummary> tickets = ticketDAO.findTickets(keyword, status);

        request.setAttribute("tickets", tickets);
        request.setAttribute("filterKeyword", keyword);
        request.setAttribute("filterStatus", status);
        request.setAttribute("activeMenu", "tickets");
        request.setAttribute("navbarSearchPlaceholder", "Tìm kiếm vé...");
        request.getRequestDispatcher("/WEB-INF/admin/ticket-management.jsp").forward(request, response);
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
            case "update":
                handleUpdate(request, response);
                break;
            case "delete":
                handleDelete(request, response);
                break;
            default:
                setFlash(request, "warning", "Hành động không được hỗ trợ.");
                response.sendRedirect(buildRedirectUrl(request));
        }
    }

    private void handleUpdate(HttpServletRequest request, HttpServletResponse response) throws IOException {
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
        setFlash(request, updated ? "success" : "danger",
                updated ? "Đã cập nhật vé." : "Không thể cập nhật vé. Vui lòng thử lại.");
        response.sendRedirect(buildRedirectUrl(request));
    }

    private void handleDelete(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Integer ticketId = parseInteger(request.getParameter("ticketId"));
        if (ticketId == null) {
            setFlash(request, "danger", "Thiếu mã vé cần xóa.");
            response.sendRedirect(buildRedirectUrl(request));
            return;
        }
        boolean deleted = ticketDAO.deleteTicket(ticketId);
        setFlash(request, deleted ? "success" : "danger",
                deleted ? "Đã xóa vé và booking liên quan." : "Không thể xóa vé. Vui lòng kiểm tra lại.");
        response.sendRedirect(buildRedirectUrl(request));
    }

    private void loadFlash(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) {
            return;
        }
        Object message = session.getAttribute(FLASH_KEY);
        Object type = session.getAttribute(FLASH_TYPE_KEY);
        if (message != null) {
            request.setAttribute("flashMessage", message);
            session.removeAttribute(FLASH_KEY);
        }
        if (type != null) {
            request.setAttribute("flashType", type);
            session.removeAttribute(FLASH_TYPE_KEY);
        }
    }

    private void setFlash(HttpServletRequest request, String type, String message) {
        HttpSession session = request.getSession(true);
        session.setAttribute(FLASH_KEY, message);
        session.setAttribute(FLASH_TYPE_KEY, type);
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
        return request.getContextPath() + "/admin/tickets";
    }
}
