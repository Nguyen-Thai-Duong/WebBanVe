package service;

import DAO.AdminDashboardDAO;
import DAO.SupportTicketDAO;
import DAO.TicketDAO;
import dto.dashboard.AdminDashboardSnapshot;
import dto.dashboard.MonthlyRevenue;
import dto.dashboard.PaymentMethodSummary;
import dto.dashboard.RouteSalesSummary;
import dto.ticket.TicketSummary;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Supplies aggregated metrics and datasets for the admin dashboard and reports.
 */
public class AdminReportingService {

    private static final int DEFAULT_RECENT_DAYS = 30;
    private static final List<String> ACTIVE_SUPPORT_STATUSES = Arrays.asList("Open", "InProgress");

    private final AdminDashboardDAO dashboardDAO = new AdminDashboardDAO();
    private final SupportTicketDAO supportTicketDAO = new SupportTicketDAO();
    private final TicketDAO ticketDAO = new TicketDAO();

    public AdminDashboardSnapshot buildDashboardSnapshot() {
        return buildDashboardSnapshot(DEFAULT_RECENT_DAYS);
    }

    public AdminDashboardSnapshot buildDashboardSnapshot(int recentDays) {
        int effectiveRecentDays = recentDays > 0 ? recentDays : DEFAULT_RECENT_DAYS;
        AdminDashboardSnapshot snapshot = new AdminDashboardSnapshot();
        snapshot.setTotalRevenue(safeValue(dashboardDAO.calculateNetRevenue()));
        snapshot.setRecentRevenue(safeValue(dashboardDAO.calculateNetRevenueSince(LocalDateTime.now().minusDays(effectiveRecentDays))));
        snapshot.setUpcomingTrips(dashboardDAO.countTripsUpcoming(effectiveRecentDays));
        snapshot.setTotalTrips(dashboardDAO.countTotalTrips());
        snapshot.setStaffCount(dashboardDAO.countUsersByRole("Staff"));
        snapshot.setOperatorCount(dashboardDAO.countUsersByRole("BusOperator"));
        snapshot.setActiveSupportTickets(supportTicketDAO.countByStatuses(ACTIVE_SUPPORT_STATUSES));
        snapshot.setMonthlyRevenue(dashboardDAO.fetchRevenueByMonth(6));
        snapshot.setPaymentSummaries(dashboardDAO.fetchRevenueByMethod(effectiveRecentDays));
        snapshot.setTopRoutes(dashboardDAO.fetchTopRouteSales(5, effectiveRecentDays));
        return snapshot;
    }

    public Map<String, Long> loadTicketStatusCounts() {
        Map<String, Long> counts = new HashMap<>();
        counts.put("Issued", ticketDAO.countTicketsByStatus("Issued"));
        counts.put("Used", ticketDAO.countTicketsByStatus("Used"));
        counts.put("Cancelled", ticketDAO.countTicketsByStatus("Cancelled"));
        return counts;
    }

    public List<MonthlyRevenue> loadMonthlyRevenue(int months) {
        return dashboardDAO.fetchRevenueByMonth(months);
    }

    public List<PaymentMethodSummary> loadPaymentSummaries(int daysBack) {
        return dashboardDAO.fetchRevenueByMethod(daysBack);
    }

    public List<RouteSalesSummary> loadTopRoutes(int limit, int daysBack) {
        return dashboardDAO.fetchTopRouteSales(limit, daysBack);
    }

    public long countTicketsIssuedSince(LocalDateTime threshold) {
        return threshold != null ? ticketDAO.countTicketsIssuedSince(threshold) : 0L;
    }

    public long countTicketsVerifiedSince(LocalDateTime threshold) {
        return threshold != null ? ticketDAO.countTicketsVerifiedSince(threshold) : 0L;
    }

    public List<TicketSummary> loadRecentTickets(int limit) {
        return limit > 0 ? ticketDAO.findRecentTickets(limit) : Collections.emptyList();
    }

    private BigDecimal safeValue(BigDecimal value) {
        return value != null ? value : BigDecimal.ZERO;
    }
}
