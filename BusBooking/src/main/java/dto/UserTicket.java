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
    private String routeDetails;
    private LocalDateTime departureTime;
    private LocalDateTime issuedDate;
    private String ticketStatus;
    private String seatNumber;

    // --- View ticket detail ---
    private BigDecimal price;
    private String origin;
    private String destination;
    private String vehicleOperatorEmployeeCode;

    private Integer tripId;

    private static final DateTimeFormatter DEPARTURE_FORMAT = DateTimeFormatter.ofPattern("HH:mm, dd/MM/yyyy");
    private static final DateTimeFormatter ISSUED_DATE_FORMAT = DateTimeFormatter.ofPattern("dd/MM/yyyy");


    public UserTicket(String ticketNumber, String routeDetails, LocalDateTime departureTime, LocalDateTime issuedDate,
                      String ticketStatus, String seatNumber, BigDecimal price, String origin,
                      String destination, String vehicleOperatorEmployeeCode, Integer tripId) {
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
        this.tripId = tripId;
    }


    public String getTicketNumber() { return ticketNumber; }
    public String getRouteDetails() { return routeDetails; }
    public LocalDateTime getDepartureTime() { return departureTime; }
    public LocalDateTime getIssuedDate() { return issuedDate; }
    public String getTicketStatus() { return ticketStatus; }
    public String getSeatNumber() { return seatNumber; }


    public BigDecimal getPrice() { return price; }
    public String getOrigin() { return origin; }
    public String getDestination() { return destination; }
    public String getVehicleOperatorEmployeeCode() { return vehicleOperatorEmployeeCode; }

    public Integer getTripId() { return tripId; }


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


    public String getFormattedPrice() {
        if (this.price == null) {
            return "0 VND";
        }

        NumberFormat nf = NumberFormat.getCurrencyInstance(new Locale("vi", "VN"));

        return nf.format(this.price).replace("₫", "VND");
    }
}