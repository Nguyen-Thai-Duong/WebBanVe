package controller.admin;

import DAO.SupportTicketDAO;
import dto.dashboard.AdminDashboardSnapshot;
import dto.dashboard.MonthlyRevenue;
import dto.dashboard.PaymentMethodSummary;
import dto.dashboard.RouteSalesSummary;
import dto.ticket.TicketSummary;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;
import java.util.Map;
import service.AdminReportingService;

/**
 * Provides aggregated operational reports for administrators.
 */
@WebServlet(name = "ReportsController", urlPatterns = {"/admin/reports"})
public class ReportsController extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final int DEFAULT_RANGE_DAYS = 90;
    private static final int DEFAULT_MONTHS = 12;

    private final AdminReportingService reportingService = new AdminReportingService();
    private final SupportTicketDAO supportTicketDAO = new SupportTicketDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setAttribute("activeMenu", "reports");
        request.setAttribute("navbarSearchPlaceholder", "Lọc báo cáo...");

        int rangeDays = parsePositiveInt(request.getParameter("range"), DEFAULT_RANGE_DAYS);
        int months = parsePositiveInt(request.getParameter("months"), DEFAULT_MONTHS);

        AdminDashboardSnapshot snapshot = reportingService.buildDashboardSnapshot(rangeDays);
        Map<String, Long> ticketStatusCounts = reportingService.loadTicketStatusCounts();
        List<MonthlyRevenue> monthlyRevenue = reportingService.loadMonthlyRevenue(months);
        List<PaymentMethodSummary> paymentSummaries = reportingService.loadPaymentSummaries(rangeDays);
        List<RouteSalesSummary> topRoutes = reportingService.loadTopRoutes(10, rangeDays);
        List<TicketSummary> recentTickets = reportingService.loadRecentTickets(15);

        request.setAttribute("reportRangeDays", rangeDays);
        request.setAttribute("revenueMonths", months);
        request.setAttribute("dashboardSnapshot", snapshot);
        request.setAttribute("ticketStatusCounts", ticketStatusCounts);
        request.setAttribute("monthlyRevenue", monthlyRevenue);
        request.setAttribute("paymentSummaries", paymentSummaries);
        request.setAttribute("topRoutes", topRoutes);
        request.setAttribute("recentTickets", recentTickets);
        request.setAttribute("supportOpenCount", supportTicketDAO.countByStatus("Open"));
        request.setAttribute("supportInProgressCount", supportTicketDAO.countByStatus("InProgress"));
        request.setAttribute("supportClosedCount", supportTicketDAO.countByStatus("Closed"));

        request.getRequestDispatcher("/WEB-INF/admin/reports.jsp").forward(request, response);
    }

    @Override
    public String getServletInfo() {
        return "Admin reports controller";
    }

    private int parsePositiveInt(String raw, int fallback) {
        if (raw == null || raw.isBlank()) {
            return fallback;
        }
        try {
            int value = Integer.parseInt(raw);
            return value > 0 ? value : fallback;
        } catch (NumberFormatException ex) {
            return fallback;
        }
    }
}
