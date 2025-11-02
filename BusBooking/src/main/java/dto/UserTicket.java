package dto;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

/**
 * Data Transfer Object (DTO) for displaying a user's purchased ticket information.
 * This class is not an entity, just a data carrier.
 */
public class UserTicket {
    private String ticketNumber;
    private String routeDetails; // e.g., "Hanoi -> Ho Chi Minh"
    private LocalDateTime departureTime;
    private LocalDateTime issuedDate;
    private String ticketStatus;
    private String seatNumber;

    private static final DateTimeFormatter DEPARTURE_FORMAT = DateTimeFormatter.ofPattern("HH:mm, dd/MM/yyyy");
    private static final DateTimeFormatter ISSUED_DATE_FORMAT = DateTimeFormatter.ofPattern("dd/MM/yyyy");

    // Constructor to map data from the DAO
    public UserTicket(String ticketNumber, String routeDetails, LocalDateTime departureTime, LocalDateTime issuedDate, String ticketStatus, String seatNumber) {
        this.ticketNumber = ticketNumber;
        this.routeDetails = routeDetails;
        this.departureTime = departureTime;
        this.issuedDate = issuedDate;
        this.ticketStatus = ticketStatus;
        this.seatNumber = seatNumber;
    }

    // Getters for JSP (used by Expression Language)
    public String getTicketNumber() { return ticketNumber; }
    public String getRouteDetails() { return routeDetails; }
    public LocalDateTime getDepartureTime() { return departureTime; }
    public LocalDateTime getIssuedDate() { return issuedDate; }
    public String getTicketStatus() { return ticketStatus; }
    public String getSeatNumber() { return seatNumber; }

    // 3. Add new methods to return pre-formatted strings
    public String getFormattedDepartureTime() {
        if (this.departureTime == null) {
            return "N/A";
        }
        return this.departureTime.format(DEPARTURE_FORMAT);
    }

    public String getFormattedIssuedDate() {
        if (this.issuedDate == null) {
            return "N/A";
        }
        return this.issuedDate.format(ISSUED_DATE_FORMAT);
    }
}