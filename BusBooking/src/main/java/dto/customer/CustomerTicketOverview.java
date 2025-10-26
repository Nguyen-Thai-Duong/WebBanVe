package dto.customer;

import dto.ticket.TicketSummary;
import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class CustomerTicketOverview {

    private final List<TicketSummary> allTickets;
    private final List<TicketSummary> upcomingTickets;
    private final List<TicketSummary> pastTickets;
    private final Map<String, Long> statusCounts;

    public CustomerTicketOverview(List<TicketSummary> allTickets,
            List<TicketSummary> upcomingTickets,
            List<TicketSummary> pastTickets,
            Map<String, Long> statusCounts) {
        this.allTickets = allTickets != null ? List.copyOf(allTickets) : List.of();
        this.upcomingTickets = upcomingTickets != null ? List.copyOf(upcomingTickets) : List.of();
        this.pastTickets = pastTickets != null ? List.copyOf(pastTickets) : List.of();
        this.statusCounts = statusCounts != null ? new LinkedHashMap<>(statusCounts) : new LinkedHashMap<>();
    }

    public List<TicketSummary> getAllTickets() {
        return Collections.unmodifiableList(allTickets);
    }

    public List<TicketSummary> getUpcomingTickets() {
        return Collections.unmodifiableList(upcomingTickets);
    }

    public List<TicketSummary> getPastTickets() {
        return Collections.unmodifiableList(pastTickets);
    }

    public Map<String, Long> getStatusCounts() {
        return Collections.unmodifiableMap(statusCounts);
    }

    public int getTotalTickets() {
        return allTickets.size();
    }

    public int getUpcomingCount() {
        return upcomingTickets.size();
    }

    public int getPastCount() {
        return pastTickets.size();
    }

    public boolean hasTickets() {
        return !allTickets.isEmpty();
    }
}
