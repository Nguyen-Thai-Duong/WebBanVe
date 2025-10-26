package dto.dashboard;

import java.math.BigDecimal;
import java.util.List;

public class AdminDashboardSnapshot {
    private BigDecimal totalRevenue;
    private BigDecimal recentRevenue;
    private long upcomingTrips;
    private long totalTrips;
    private long staffCount;
    private long operatorCount;
    private long activeSupportTickets;
    private List<MonthlyRevenue> monthlyRevenue;
    private List<PaymentMethodSummary> paymentSummaries;
    private List<RouteSalesSummary> topRoutes;

    public BigDecimal getTotalRevenue() {
        return totalRevenue;
    }

    public void setTotalRevenue(BigDecimal totalRevenue) {
        this.totalRevenue = totalRevenue;
    }

    public BigDecimal getRecentRevenue() {
        return recentRevenue;
    }

    public void setRecentRevenue(BigDecimal recentRevenue) {
        this.recentRevenue = recentRevenue;
    }

    public long getUpcomingTrips() {
        return upcomingTrips;
    }

    public void setUpcomingTrips(long upcomingTrips) {
        this.upcomingTrips = upcomingTrips;
    }

    public long getTotalTrips() {
        return totalTrips;
    }

    public void setTotalTrips(long totalTrips) {
        this.totalTrips = totalTrips;
    }

    public long getStaffCount() {
        return staffCount;
    }

    public void setStaffCount(long staffCount) {
        this.staffCount = staffCount;
    }

    public long getOperatorCount() {
        return operatorCount;
    }

    public void setOperatorCount(long operatorCount) {
        this.operatorCount = operatorCount;
    }

    public long getActiveSupportTickets() {
        return activeSupportTickets;
    }

    public void setActiveSupportTickets(long activeSupportTickets) {
        this.activeSupportTickets = activeSupportTickets;
    }

    public List<MonthlyRevenue> getMonthlyRevenue() {
        return monthlyRevenue;
    }

    public void setMonthlyRevenue(List<MonthlyRevenue> monthlyRevenue) {
        this.monthlyRevenue = monthlyRevenue;
    }

    public List<PaymentMethodSummary> getPaymentSummaries() {
        return paymentSummaries;
    }

    public void setPaymentSummaries(List<PaymentMethodSummary> paymentSummaries) {
        this.paymentSummaries = paymentSummaries;
    }

    public List<RouteSalesSummary> getTopRoutes() {
        return topRoutes;
    }

    public void setTopRoutes(List<RouteSalesSummary> topRoutes) {
        this.topRoutes = topRoutes;
    }
}
