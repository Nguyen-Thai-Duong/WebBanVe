package controller.staff;

import DAO.SupportTicketDAO;
import DAO.TicketDAO;
import dto.SupportTicketView;
import dto.TicketSummary;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import model.User;

/**
 * Landing dashboard for staff workspace providing key operational metrics.
 */
@WebServlet(name = "StaffDashboardController", urlPatterns = {"/staff/dashboard"})
public class StaffDashboardController extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final int DEFAULT_LIST_LIMIT = 5;

    private final TicketDAO ticketDAO = new TicketDAO();
    private final SupportTicketDAO supportTicketDAO = new SupportTicketDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User currentUser = session != null ? (User) session.getAttribute("currentUser") : null;
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        LocalDateTime startOfDay = LocalDate.now().atStartOfDay();

        long ticketsIssuedToday = ticketDAO.countTicketsIssuedSince(startOfDay);
        long ticketsVerifiedToday = ticketDAO.countTicketsVerifiedSince(startOfDay);
        long ticketsAwaitingVerification = ticketDAO.countTicketsByStatus("Issued");
        long openSupportTickets = supportTicketDAO.countByStatuses(List.of("New", "InProgress"));

        List<TicketSummary> recentTickets = ticketDAO.findRecentTickets(DEFAULT_LIST_LIMIT);
        List<TicketSummary> pendingTickets = ticketDAO.findTicketsPendingVerification(DEFAULT_LIST_LIMIT);
        List<SupportTicketView> recentSupportTickets = supportTicketDAO.findRecentTickets(DEFAULT_LIST_LIMIT);

        request.setAttribute("metrics", Map.of(
                "ticketsIssuedToday", ticketsIssuedToday,
                "ticketsVerifiedToday", ticketsVerifiedToday,
                "ticketsAwaitingVerification", ticketsAwaitingVerification,
                "openSupportTickets", openSupportTickets
        ));
        request.setAttribute("recentTickets", recentTickets);
        request.setAttribute("pendingTickets", pendingTickets);
        request.setAttribute("recentSupportTickets", recentSupportTickets);
        request.setAttribute("activeMenu", "dashboard");
        request.setAttribute("navbarHideSearch", Boolean.TRUE);
        request.setAttribute("navbarSearchPlaceholder", "Tìm kiếm...");

        request.getRequestDispatcher("/WEB-INF/staff/dashboard.jsp").forward(request, response);
    }

    @Override
    public String getServletInfo() {
        return "Staff dashboard controller";
    }
}
