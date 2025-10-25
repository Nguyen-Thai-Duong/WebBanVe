package controller.staff;

import DAO.SupportTicketDAO;
import dto.SupportTicketView;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import model.User;

/**
 * Staff area controller for handling customer support ticket workflows.
 */
@WebServlet(name = "SupportTicketController", urlPatterns = {"/staff/support"})
public class SupportTicketController extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final String DEFAULT_STATUS = "InProgress";

    private final SupportTicketDAO supportTicketDAO = new SupportTicketDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session != null) {
            Object message = session.getAttribute("staffSupportMessage");
            Object type = session.getAttribute("staffSupportMessageType");
            if (message != null) {
                request.setAttribute("flashMessage", message);
                session.removeAttribute("staffSupportMessage");
            }
            if (type != null) {
                request.setAttribute("flashType", type);
                session.removeAttribute("staffSupportMessageType");
            }
        }

        String status = trim(request.getParameter("status"));
        String keyword = trim(request.getParameter("q"));
        List<SupportTicketView> tickets = supportTicketDAO.findTickets(status, keyword);

        request.setAttribute("tickets", tickets);
        request.setAttribute("filterStatus", status);
        request.setAttribute("filterKeyword", keyword);
        request.setAttribute("activeMenu", "support");
        request.setAttribute("navbarSearchPlaceholder", "Tìm kiếm yêu cầu hỗ trợ...");

        request.getRequestDispatcher("/WEB-INF/staff/support-ticket.jsp").forward(request, response);
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
            default:
                setFlash(request, "warning", "Hành động không được hỗ trợ.");
                response.sendRedirect(buildRedirectUrl(request));
        }
    }

    private void handleUpdate(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Integer supportId = parseInteger(request.getParameter("supportId"));
        if (supportId == null) {
            setFlash(request, "danger", "Thiếu mã ticket hỗ trợ cần cập nhật.");
            response.sendRedirect(buildRedirectUrl(request));
            return;
        }
        String status = trim(request.getParameter("status"));
        String resolution = trim(request.getParameter("resolution"));

        HttpSession session = request.getSession(false);
        User currentUser = session != null ? (User) session.getAttribute("currentUser") : null;
        if (currentUser == null) {
            setFlash(request, "danger", "Phiên làm việc đã hết hạn. Vui lòng đăng nhập lại.");
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        boolean updated = supportTicketDAO.updateTicket(supportId, status != null ? status : DEFAULT_STATUS, resolution, currentUser.getUserId());
        if (updated) {
            setFlash(request, "success", "Đã cập nhật yêu cầu hỗ trợ.");
        } else {
            setFlash(request, "danger", "Không thể cập nhật yêu cầu hỗ trợ. Vui lòng thử lại.");
        }
        response.sendRedirect(buildRedirectUrl(request));
    }

    private void setFlash(HttpServletRequest request, String type, String message) {
        HttpSession session = request.getSession(true);
        session.setAttribute("staffSupportMessage", message);
        session.setAttribute("staffSupportMessageType", type);
    }

    private Integer parseInteger(String value) {
        try {
            return value != null && !value.isBlank() ? Integer.valueOf(value) : null;
        } catch (NumberFormatException ex) {
            return null;
        }
    }

    private String trim(String value) {
        return value != null ? value.trim() : null;
    }

    private String buildRedirectUrl(HttpServletRequest request) {
        return request.getContextPath() + "/staff/support";
    }
}
