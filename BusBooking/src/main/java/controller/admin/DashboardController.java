package controller.admin;

import dto.dashboard.AdminDashboardSnapshot;
import dto.dashboard.AdminDashboardView;
import dto.ticket.TicketSummary;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.time.LocalDateTime;
import java.util.Locale;
import java.util.List;
import java.util.Map;
import service.AdminReportingService;

/**
 * Displays the admin dashboard landing page.
 */
@WebServlet(name = "DashboardController", urlPatterns = {"/admin/dashboard"})
public class DashboardController extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private final AdminReportingService reportingService = new AdminReportingService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setAttribute("activeMenu", "dashboard");
        request.setAttribute("navbarSearchPlaceholder", "Tìm kiếm báo cáo...");

    AdminDashboardSnapshot snapshot = reportingService.buildDashboardSnapshot();
    Map<String, Long> ticketStatusCounts = reportingService.loadTicketStatusCounts();
    List<TicketSummary> recentTickets = reportingService.loadRecentTickets(6);
    LocalDateTime threshold = LocalDateTime.now().minusDays(30);
    long ticketsIssued30d = reportingService.countTicketsIssuedSince(threshold);
    long ticketsVerified30d = reportingService.countTicketsVerifiedSince(threshold);

    Locale locale = new Locale("vi", "VN");
    AdminDashboardView dashboardView = AdminDashboardView.from(
        snapshot,
        ticketStatusCounts,
        ticketsIssued30d,
        ticketsVerified30d,
        locale);

    request.setAttribute("adminView", dashboardView);
    request.setAttribute("recentTickets", recentTickets);

        request.getRequestDispatcher("/WEB-INF/admin/dashboard.jsp").forward(request, response);
    }

    @Override
    public String getServletInfo() {
        return "Admin dashboard controller";
    }
}
