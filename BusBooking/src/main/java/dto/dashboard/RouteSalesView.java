package dto.dashboard;

/**
 * View model representing aggregated ticket sales per route.
 */
public class RouteSalesView {

    private final String routeLabel;
    private final String ticketCountLabel;

    public RouteSalesView(String routeLabel, String ticketCountLabel) {
        this.routeLabel = routeLabel;
        this.ticketCountLabel = ticketCountLabel;
    }

    public String getRouteLabel() {
        return routeLabel;
    }

    public String getTicketCountLabel() {
        return ticketCountLabel;
    }
}
