package service.impl;

import DAO.TicketDAO;
import dto.customer.CustomerTicketOverview;
import dto.ticket.TicketSummary;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import service.CustomerTicketService;

public class CustomerTicketServiceImpl implements CustomerTicketService {

    private final TicketDAO ticketDAO = new TicketDAO();

    @Override
    public CustomerTicketOverview buildTicketOverview(int userId) {
        List<TicketSummary> allTickets = ticketDAO.findTicketsForCustomer(userId);
        List<TicketSummary> upcoming = new ArrayList<>();
        List<TicketSummary> past = new ArrayList<>();
        Map<String, Long> statusCounts = new LinkedHashMap<>();

        LocalDateTime now = LocalDateTime.now();
        for (TicketSummary ticket : allTickets) {
            String statusKey = normalizeStatus(ticket.getTicketStatus());
            statusCounts.merge(statusKey, 1L, Long::sum);

            LocalDateTime departure = ticket.getDepartureTime();
            if (departure != null && departure.isAfter(now)) {
                upcoming.add(ticket);
            } else {
                past.add(ticket);
            }
        }

        sortUpcoming(upcoming);
        sortPast(past);

        return new CustomerTicketOverview(allTickets, upcoming, past, statusCounts);
    }

    private String normalizeStatus(String status) {
        if (status == null || status.isBlank()) {
            return "Khác";
        }
        String normalized = status.trim().toLowerCase(Locale.ROOT);
        if ("issued".equals(normalized)) {
            return "Đã phát hành";
        }
        if ("used".equals(normalized) || "checkedin".equals(normalized) || "checked-in".equals(normalized)) {
            return "Đã sử dụng";
        }
        if ("cancelled".equals(normalized) || "canceled".equals(normalized)) {
            return "Đã hủy";
        }
        return status.trim();
    }

    private void sortUpcoming(List<TicketSummary> upcoming) {
        Comparator<TicketSummary> comparator = Comparator
                .comparing(TicketSummary::getDepartureTime, Comparator.nullsLast(Comparator.naturalOrder()))
                .thenComparing(TicketSummary::getIssuedDate, Comparator.nullsLast(Comparator.naturalOrder()))
                .thenComparing(TicketSummary::getTicketId, Comparator.nullsLast(Comparator.naturalOrder()));
        upcoming.sort(comparator);
    }

    private void sortPast(List<TicketSummary> past) {
        Comparator<TicketSummary> comparator = Comparator
                .comparing(TicketSummary::getDepartureTime, Comparator.nullsFirst(Comparator.reverseOrder()))
                .thenComparing(TicketSummary::getIssuedDate, Comparator.nullsFirst(Comparator.reverseOrder()))
                .thenComparing(TicketSummary::getTicketId, Comparator.nullsFirst(Comparator.reverseOrder()));
        past.sort(comparator);
    }
}
