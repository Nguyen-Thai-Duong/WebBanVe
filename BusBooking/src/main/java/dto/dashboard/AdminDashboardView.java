package dto.dashboard;

import java.math.BigDecimal;
import java.text.DecimalFormat;
import java.text.DecimalFormatSymbols;
import java.text.NumberFormat;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Objects;

/**
 * Aggregated, formatted view model for the admin dashboard.
 */
public class AdminDashboardView {

    private final String totalRevenueLabel;
    private final String recentRevenueLabel;
    private final String upcomingTripsLabel;
    private final String totalTripsLabel;
    private final String activeSupportLabel;
    private final String staffCountLabel;
    private final String operatorCountLabel;
    private final String ticketsIssued30DaysLabel;
    private final String ticketsVerified30DaysLabel;
    private final String issuedCountLabel;
    private final String usedCountLabel;
    private final String cancelledCountLabel;
    private final long issuedCount;
    private final long usedCount;
    private final long cancelledCount;
    private final long totalTicketCount;
    private final String usedPercentStyle;
    private final String issuedPercentStyle;
    private final String cancelledPercentStyle;
    private final String usedPercentDisplay;
    private final String issuedPercentDisplay;
    private final String cancelledPercentDisplay;
    private final List<PaymentSummaryView> paymentSummaries;
    private final List<RouteSalesView> routeSummaries;
    private final String revenueChartLabelsJson;
    private final String revenueChartValuesJson;
    private final boolean hasRevenueData;

    private AdminDashboardView(String totalRevenueLabel,
            String recentRevenueLabel,
            String upcomingTripsLabel,
            String totalTripsLabel,
            String activeSupportLabel,
            String staffCountLabel,
            String operatorCountLabel,
            String ticketsIssued30DaysLabel,
            String ticketsVerified30DaysLabel,
            String issuedCountLabel,
            String usedCountLabel,
            String cancelledCountLabel,
            long issuedCount,
            long usedCount,
            long cancelledCount,
            long totalTicketCount,
            String usedPercentStyle,
            String issuedPercentStyle,
            String cancelledPercentStyle,
            String usedPercentDisplay,
            String issuedPercentDisplay,
            String cancelledPercentDisplay,
            List<PaymentSummaryView> paymentSummaries,
            List<RouteSalesView> routeSummaries,
            String revenueChartLabelsJson,
            String revenueChartValuesJson,
            boolean hasRevenueData) {
        this.totalRevenueLabel = totalRevenueLabel;
        this.recentRevenueLabel = recentRevenueLabel;
        this.upcomingTripsLabel = upcomingTripsLabel;
        this.totalTripsLabel = totalTripsLabel;
        this.activeSupportLabel = activeSupportLabel;
        this.staffCountLabel = staffCountLabel;
        this.operatorCountLabel = operatorCountLabel;
        this.ticketsIssued30DaysLabel = ticketsIssued30DaysLabel;
        this.ticketsVerified30DaysLabel = ticketsVerified30DaysLabel;
        this.issuedCountLabel = issuedCountLabel;
        this.usedCountLabel = usedCountLabel;
        this.cancelledCountLabel = cancelledCountLabel;
        this.issuedCount = issuedCount;
        this.usedCount = usedCount;
        this.cancelledCount = cancelledCount;
        this.totalTicketCount = totalTicketCount;
        this.usedPercentStyle = usedPercentStyle;
        this.issuedPercentStyle = issuedPercentStyle;
        this.cancelledPercentStyle = cancelledPercentStyle;
        this.usedPercentDisplay = usedPercentDisplay;
        this.issuedPercentDisplay = issuedPercentDisplay;
        this.cancelledPercentDisplay = cancelledPercentDisplay;
        this.paymentSummaries = paymentSummaries;
        this.routeSummaries = routeSummaries;
        this.revenueChartLabelsJson = revenueChartLabelsJson;
        this.revenueChartValuesJson = revenueChartValuesJson;
        this.hasRevenueData = hasRevenueData;
    }

    public static AdminDashboardView from(AdminDashboardSnapshot snapshot,
            Map<String, Long> ticketStatusCounts,
            long ticketsIssued30Days,
            long ticketsVerified30Days,
            Locale locale) {
        Objects.requireNonNull(locale, "locale must not be null");

        NumberFormat currencyFormat = NumberFormat.getCurrencyInstance(locale);
        NumberFormat numberFormat = NumberFormat.getIntegerInstance(locale);
        DecimalFormat percentDisplayFormat = new DecimalFormat("0.0", DecimalFormatSymbols.getInstance(locale));
        DecimalFormat percentStyleFormat = new DecimalFormat("0.0", DecimalFormatSymbols.getInstance(Locale.US));

        BigDecimal totalRevenue = snapshot != null && snapshot.getTotalRevenue() != null
                ? snapshot.getTotalRevenue() : BigDecimal.ZERO;
        BigDecimal recentRevenue = snapshot != null && snapshot.getRecentRevenue() != null
                ? snapshot.getRecentRevenue() : BigDecimal.ZERO;
        long upcomingTrips = snapshot != null ? snapshot.getUpcomingTrips() : 0L;
        long totalTrips = snapshot != null ? snapshot.getTotalTrips() : 0L;
        long activeSupport = snapshot != null ? snapshot.getActiveSupportTickets() : 0L;
        long staffCount = snapshot != null ? snapshot.getStaffCount() : 0L;
        long operatorCount = snapshot != null ? snapshot.getOperatorCount() : 0L;

        long issuedCount = findCountIgnoreCase(ticketStatusCounts, "Issued");
        long usedCount = findCountIgnoreCase(ticketStatusCounts, "Used");
        long cancelledCount = findCountIgnoreCase(ticketStatusCounts, "Cancelled");
        long totalTicketCount = issuedCount + usedCount + cancelledCount;

        double usedPercent = totalTicketCount > 0 ? usedCount * 100.0 / totalTicketCount : 0.0;
        double issuedPercent = totalTicketCount > 0 ? issuedCount * 100.0 / totalTicketCount : 0.0;
        double cancelledPercent = totalTicketCount > 0 ? cancelledCount * 100.0 / totalTicketCount : 0.0;

        String usedPercentStyle = percentStyleFormat.format(usedPercent);
        String issuedPercentStyle = percentStyleFormat.format(issuedPercent);
        String cancelledPercentStyle = percentStyleFormat.format(cancelledPercent);

        String usedPercentDisplay = percentDisplayFormat.format(usedPercent);
        String issuedPercentDisplay = percentDisplayFormat.format(issuedPercent);
        String cancelledPercentDisplay = percentDisplayFormat.format(cancelledPercent);

        List<PaymentSummaryView> paymentViews = buildPaymentViews(snapshot, currencyFormat);
        List<RouteSalesView> routeViews = buildRouteViews(snapshot, numberFormat);

        ChartData chartData = buildChartData(snapshot);

        return new AdminDashboardView(
                currencyFormat.format(totalRevenue),
                currencyFormat.format(recentRevenue),
                numberFormat.format(upcomingTrips),
                numberFormat.format(totalTrips),
                numberFormat.format(activeSupport),
                numberFormat.format(staffCount),
                numberFormat.format(operatorCount),
                numberFormat.format(ticketsIssued30Days),
                numberFormat.format(ticketsVerified30Days),
                numberFormat.format(issuedCount),
                numberFormat.format(usedCount),
                numberFormat.format(cancelledCount),
                issuedCount,
                usedCount,
                cancelledCount,
                totalTicketCount,
                usedPercentStyle,
                issuedPercentStyle,
                cancelledPercentStyle,
                usedPercentDisplay,
                issuedPercentDisplay,
                cancelledPercentDisplay,
                paymentViews,
                routeViews,
                chartData.labelsJson,
                chartData.valuesJson,
                chartData.hasData);
    }

    private static long findCountIgnoreCase(Map<String, Long> counts, String key) {
        if (counts == null || counts.isEmpty() || key == null) {
            return 0L;
        }
        for (Map.Entry<String, Long> entry : counts.entrySet()) {
            if (entry.getKey() != null && entry.getKey().equalsIgnoreCase(key)) {
                return entry.getValue() != null ? entry.getValue() : 0L;
            }
        }
        return 0L;
    }

    private static List<PaymentSummaryView> buildPaymentViews(AdminDashboardSnapshot snapshot, NumberFormat currencyFormat) {
        if (snapshot == null || snapshot.getPaymentSummaries() == null) {
            return Collections.emptyList();
        }
        List<PaymentSummaryView> views = new ArrayList<>();
        snapshot.getPaymentSummaries().forEach(summary -> {
            String method = summary.getMethod() != null ? summary.getMethod() : "Khác";
            BigDecimal amount = summary.getNetAmount() != null ? summary.getNetAmount() : BigDecimal.ZERO;
            views.add(new PaymentSummaryView(method, currencyFormat.format(amount)));
        });
        return Collections.unmodifiableList(views);
    }

    private static List<RouteSalesView> buildRouteViews(AdminDashboardSnapshot snapshot, NumberFormat numberFormat) {
        if (snapshot == null || snapshot.getTopRoutes() == null) {
            return Collections.emptyList();
        }
        List<RouteSalesView> views = new ArrayList<>();
        snapshot.getTopRoutes().forEach(route -> {
            String origin = route.getOrigin() != null ? route.getOrigin() : "?";
            String destination = route.getDestination() != null ? route.getDestination() : "?";
            String label = origin + " → " + destination;
            views.add(new RouteSalesView(label, numberFormat.format(route.getTicketCount())));
        });
        return Collections.unmodifiableList(views);
    }

    private static ChartData buildChartData(AdminDashboardSnapshot snapshot) {
        if (snapshot == null || snapshot.getMonthlyRevenue() == null || snapshot.getMonthlyRevenue().isEmpty()) {
            return new ChartData("[]", "[]", false);
        }
        List<String> labels = new ArrayList<>();
        List<String> values = new ArrayList<>();
        for (int i = snapshot.getMonthlyRevenue().size() - 1; i >= 0; i--) {
            MonthlyRevenue revenue = snapshot.getMonthlyRevenue().get(i);
            String label = revenue.getPeriod() != null ? revenue.getPeriod() : "N/A";
            BigDecimal amount = revenue.getAmount() != null ? revenue.getAmount() : BigDecimal.ZERO;
            labels.add(label);
            values.add(amount.toPlainString());
        }
        return new ChartData(toJsonStringArray(labels), toJsonNumberArray(values), !labels.isEmpty());
    }

    private static String toJsonStringArray(List<String> items) {
        if (items.isEmpty()) {
            return "[]";
        }
        StringBuilder builder = new StringBuilder("[");
        for (int i = 0; i < items.size(); i++) {
            String value = items.get(i) != null ? items.get(i) : "";
            builder.append('"').append(value.replace("\\", "\\\\").replace("\"", "\\\"")).append('"');
            if (i < items.size() - 1) {
                builder.append(',');
            }
        }
        builder.append(']');
        return builder.toString();
    }

    private static String toJsonNumberArray(List<String> items) {
        if (items.isEmpty()) {
            return "[]";
        }
        StringBuilder builder = new StringBuilder("[");
        for (int i = 0; i < items.size(); i++) {
            builder.append(items.get(i));
            if (i < items.size() - 1) {
                builder.append(',');
            }
        }
        builder.append(']');
        return builder.toString();
    }

    public String getTotalRevenueLabel() {
        return totalRevenueLabel;
    }

    public String getRecentRevenueLabel() {
        return recentRevenueLabel;
    }

    public String getUpcomingTripsLabel() {
        return upcomingTripsLabel;
    }

    public String getTotalTripsLabel() {
        return totalTripsLabel;
    }

    public String getActiveSupportLabel() {
        return activeSupportLabel;
    }

    public String getStaffCountLabel() {
        return staffCountLabel;
    }

    public String getOperatorCountLabel() {
        return operatorCountLabel;
    }

    public String getTicketsIssued30DaysLabel() {
        return ticketsIssued30DaysLabel;
    }

    public String getTicketsVerified30DaysLabel() {
        return ticketsVerified30DaysLabel;
    }

    public String getIssuedCountLabel() {
        return issuedCountLabel;
    }

    public String getUsedCountLabel() {
        return usedCountLabel;
    }

    public String getCancelledCountLabel() {
        return cancelledCountLabel;
    }

    public long getIssuedCount() {
        return issuedCount;
    }

    public long getUsedCount() {
        return usedCount;
    }

    public long getCancelledCount() {
        return cancelledCount;
    }

    public long getTotalTicketCount() {
        return totalTicketCount;
    }

    public String getUsedPercentStyle() {
        return usedPercentStyle;
    }

    public String getIssuedPercentStyle() {
        return issuedPercentStyle;
    }

    public String getCancelledPercentStyle() {
        return cancelledPercentStyle;
    }

    public String getUsedPercentDisplay() {
        return usedPercentDisplay;
    }

    public String getIssuedPercentDisplay() {
        return issuedPercentDisplay;
    }

    public String getCancelledPercentDisplay() {
        return cancelledPercentDisplay;
    }

    public List<PaymentSummaryView> getPaymentSummaries() {
        return paymentSummaries;
    }

    public List<RouteSalesView> getRouteSummaries() {
        return routeSummaries;
    }

    public String getRevenueChartLabelsJson() {
        return revenueChartLabelsJson;
    }

    public String getRevenueChartValuesJson() {
        return revenueChartValuesJson;
    }

    public boolean isHasRevenueData() {
        return hasRevenueData;
    }

    private static final class ChartData {
        private final String labelsJson;
        private final String valuesJson;
        private final boolean hasData;

        private ChartData(String labelsJson, String valuesJson, boolean hasData) {
            this.labelsJson = labelsJson;
            this.valuesJson = valuesJson;
            this.hasData = hasData;
        }
    }
}
