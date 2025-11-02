package dto;

import java.math.BigDecimal;
import java.text.NumberFormat;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Locale;

/**
 * Data Transfer Object (DTO) for displaying a user's purchased ticket information.
 */
public class UserTicket {
    private String ticketNumber;
    private String routeDetails; // e.g., "Hanoi -> Ho Chi Minh"
    private LocalDateTime departureTime;
    private LocalDateTime issuedDate;
    private String ticketStatus;
    private String seatNumber;

    // --- NEW FIELDS FOR DETAIL VIEW ---
    private BigDecimal price;
    private String origin;
    private String destination;
    private String vehicleOperatorEmployeeCode;

    private static final DateTimeFormatter DEPARTURE_FORMAT = DateTimeFormatter.ofPattern("HH:mm, dd/MM/yyyy");
    private static final DateTimeFormatter ISSUED_DATE_FORMAT = DateTimeFormatter.ofPattern("dd/MM/yyyy");

    // Constructor to map data from the DAO (UPDATED)
    public UserTicket(String ticketNumber, String routeDetails, LocalDateTime departureTime, LocalDateTime issuedDate,
                      String ticketStatus, String seatNumber, BigDecimal price, String origin,
                      String destination, String vehicleOperatorEmployeeCode) {
        this.ticketNumber = ticketNumber;
        this.routeDetails = routeDetails;
        this.departureTime = departureTime;
        this.issuedDate = issuedDate;
        this.ticketStatus = ticketStatus;
        this.seatNumber = seatNumber;
        this.price = price;
        this.origin = origin;
        this.destination = destination;
        this.vehicleOperatorEmployeeCode = vehicleOperatorEmployeeCode;
    }

    // Existing Getters
    public String getTicketNumber() { return ticketNumber; }
    public String getRouteDetails() { return routeDetails; }
    public LocalDateTime getDepartureTime() { return departureTime; }
    public LocalDateTime getIssuedDate() { return issuedDate; }
    public String getTicketStatus() { return ticketStatus; }
    public String getSeatNumber() { return seatNumber; }

    // New Detail Getters
    public BigDecimal getPrice() { return price; }
    public String getOrigin() { return origin; }
    public String getDestination() { return destination; }
    public String getVehicleOperatorEmployeeCode() { return vehicleOperatorEmployeeCode; }

    // Existing Date/Time formatting methods
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

    // --- NEW FORMATTING METHOD for Price ---
    public String getFormattedPrice() {
        if (this.price == null) {
            return "0 VND";
        }
        // Format to Vietnamese Dong (VND)
        NumberFormat nf = NumberFormat.getCurrencyInstance(new Locale("vi", "VN"));
        // Use a common symbol or explicit text (e.g., VND)
        return nf.format(this.price).replace("₫", "VND");
    }
}