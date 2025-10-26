package dto.ticket;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Locale;

/**
 * Lightweight projection for showing ticket information in staff consoles.
 */
public class TicketSummary {

    private static final DateTimeFormatter DEPARTURE_FORMATTER =
            DateTimeFormatter.ofPattern("HH:mm, dd/MM/yyyy").withLocale(new Locale("vi", "VN"));
    private static final String DEFAULT_SUPPORT_EMAIL = "support@futa.vn";

    private Integer ticketId;
    private Integer bookingId;
    private Integer tripId;
    private String ticketNumber;
    private String ticketStatus;
    private LocalDateTime issuedDate;
    private LocalDateTime checkedInAt;
    private String checkedInBy;
    private String seatNumber;
    private String seatStatus;
    private String bookingStatus;
    private String routeLabel;
    private LocalDateTime departureTime;
    private LocalDateTime arrivalTime;
    private String customerName;
    private String customerEmail;
    private String customerPhone;
    private String guestEmail;
    private String guestPhone;

    public Integer getTicketId() {
        return ticketId;
    }

    public void setTicketId(Integer ticketId) {
        this.ticketId = ticketId;
    }

    public Integer getBookingId() {
        return bookingId;
    }

    public void setBookingId(Integer bookingId) {
        this.bookingId = bookingId;
    }

    public Integer getTripId() {
        return tripId;
    }

    public void setTripId(Integer tripId) {
        this.tripId = tripId;
    }

    public String getTicketNumber() {
        return ticketNumber;
    }

    public void setTicketNumber(String ticketNumber) {
        this.ticketNumber = ticketNumber;
    }

    public String getTicketStatus() {
        return ticketStatus;
    }

    public void setTicketStatus(String ticketStatus) {
        this.ticketStatus = ticketStatus;
    }

    public LocalDateTime getIssuedDate() {
        return issuedDate;
    }

    public void setIssuedDate(LocalDateTime issuedDate) {
        this.issuedDate = issuedDate;
    }

    public LocalDateTime getCheckedInAt() {
        return checkedInAt;
    }

    public void setCheckedInAt(LocalDateTime checkedInAt) {
        this.checkedInAt = checkedInAt;
    }

    public String getCheckedInBy() {
        return checkedInBy;
    }

    public void setCheckedInBy(String checkedInBy) {
        this.checkedInBy = checkedInBy;
    }

    public String getSeatNumber() {
        return seatNumber;
    }

    public void setSeatNumber(String seatNumber) {
        this.seatNumber = seatNumber;
    }

    public String getSeatStatus() {
        return seatStatus;
    }

    public void setSeatStatus(String seatStatus) {
        this.seatStatus = seatStatus;
    }

    public String getBookingStatus() {
        return bookingStatus;
    }

    public void setBookingStatus(String bookingStatus) {
        this.bookingStatus = bookingStatus;
    }

    public String getRouteLabel() {
        return routeLabel;
    }

    public void setRouteLabel(String routeLabel) {
        this.routeLabel = routeLabel;
    }

    public LocalDateTime getDepartureTime() {
        return departureTime;
    }

    public void setDepartureTime(LocalDateTime departureTime) {
        this.departureTime = departureTime;
    }

    public LocalDateTime getArrivalTime() {
        return arrivalTime;
    }

    public void setArrivalTime(LocalDateTime arrivalTime) {
        this.arrivalTime = arrivalTime;
    }

    public String getCustomerName() {
        return customerName;
    }

    public void setCustomerName(String customerName) {
        this.customerName = customerName;
    }

    public String getCustomerEmail() {
        return customerEmail;
    }

    public void setCustomerEmail(String customerEmail) {
        this.customerEmail = customerEmail;
    }

    public String getCustomerPhone() {
        return customerPhone;
    }

    public void setCustomerPhone(String customerPhone) {
        this.customerPhone = customerPhone;
    }

    public String getGuestEmail() {
        return guestEmail;
    }

    public void setGuestEmail(String guestEmail) {
        this.guestEmail = guestEmail;
    }

    public String getGuestPhone() {
        return guestPhone;
    }

    public void setGuestPhone(String guestPhone) {
        this.guestPhone = guestPhone;
    }

    public String getDepartureDisplay() {
        LocalDateTime time = getDepartureTime();
        return time != null ? time.format(DEPARTURE_FORMATTER) : "Đang cập nhật";
    }

    public String getStatusLabel() {
        String normalized = normalizeStatus();
        switch (normalized) {
            case "issued":
                return "Đã phát hành";
            case "used":
            case "checkedin":
            case "checked-in":
                return "Đã sử dụng";
            case "cancelled":
            case "canceled":
                return "Đã hủy";
            case "reserved":
                return "Đã giữ chỗ";
            case "pending":
                return "Đang xử lý";
            default:
                return ticketStatus != null ? ticketStatus : "Không rõ";
        }
    }

    public String getStatusBadgeClass() {
        String normalized = normalizeStatus();
        switch (normalized) {
            case "issued":
                return "bg-label-info";
            case "used":
            case "checkedin":
            case "checked-in":
                return "bg-label-success";
            case "cancelled":
            case "canceled":
                return "bg-label-danger";
            case "pending":
            case "reserved":
                return "bg-label-warning";
            default:
                return "bg-label-secondary";
        }
    }

    public String getSeatDisplay() {
        return seatNumber != null && !seatNumber.isBlank() ? seatNumber : "Đang sắp xếp";
    }

    public String getHistoricalSeatDisplay() {
        return seatNumber != null && !seatNumber.isBlank() ? seatNumber : "N/A";
    }

    public String getPreferredContact() {
        if (guestPhone != null && !guestPhone.isBlank()) {
            return guestPhone;
        }
        if (customerPhone != null && !customerPhone.isBlank()) {
            return customerPhone;
        }
        if (customerEmail != null && !customerEmail.isBlank()) {
            return customerEmail;
        }
        if (guestEmail != null && !guestEmail.isBlank()) {
            return guestEmail;
        }
        return DEFAULT_SUPPORT_EMAIL;
    }

    private String normalizeStatus() {
        return ticketStatus != null ? ticketStatus.trim().toLowerCase(Locale.ROOT) : "";
    }
}
