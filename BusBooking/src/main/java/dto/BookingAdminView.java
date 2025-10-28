package dto;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

/**
 * Projection used by the admin booking management screens.
 */
public class BookingAdminView {

    private Integer bookingId;
    private Integer tripId;
    private Integer customerId;
    private String customerName;
    private String customerEmail;
    private String customerPhone;
    private String guestPhoneNumber;
    private String guestEmail;
    private LocalDateTime bookingDate;
    private String bookingStatus;
    private String seatNumber;
    private String seatStatus;
    private LocalDateTime ttlExpiry;
    private LocalDateTime departureTime;
    private LocalDateTime arrivalTime;
    private String routeOrigin;
    private String routeDestination;
    private String vehiclePlate;
    private Integer routeDurationMinutes;
    private String routeStatus;

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

    public Integer getCustomerId() {
        return customerId;
    }

    public void setCustomerId(Integer customerId) {
        this.customerId = customerId;
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

    public String getGuestPhoneNumber() {
        return guestPhoneNumber;
    }

    public void setGuestPhoneNumber(String guestPhoneNumber) {
        this.guestPhoneNumber = guestPhoneNumber;
    }

    public String getGuestEmail() {
        return guestEmail;
    }

    public void setGuestEmail(String guestEmail) {
        this.guestEmail = guestEmail;
    }

    public LocalDateTime getBookingDate() {
        return bookingDate;
    }

    public void setBookingDate(LocalDateTime bookingDate) {
        this.bookingDate = bookingDate;
    }

    public String getBookingStatus() {
        return bookingStatus;
    }

    public void setBookingStatus(String bookingStatus) {
        this.bookingStatus = bookingStatus;
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

    public LocalDateTime getTtlExpiry() {
        return ttlExpiry;
    }

    public void setTtlExpiry(LocalDateTime ttlExpiry) {
        this.ttlExpiry = ttlExpiry;
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

    public String getRouteOrigin() {
        return routeOrigin;
    }

    public void setRouteOrigin(String routeOrigin) {
        this.routeOrigin = routeOrigin;
    }

    public String getRouteDestination() {
        return routeDestination;
    }

    public void setRouteDestination(String routeDestination) {
        this.routeDestination = routeDestination;
    }

    public String getVehiclePlate() {
        return vehiclePlate;
    }

    public void setVehiclePlate(String vehiclePlate) {
        this.vehiclePlate = vehiclePlate;
    }

    public Integer getRouteDurationMinutes() {
        return routeDurationMinutes;
    }

    public void setRouteDurationMinutes(Integer routeDurationMinutes) {
        this.routeDurationMinutes = routeDurationMinutes;
    }

    public String getRouteStatus() {
        return routeStatus;
    }

    public void setRouteStatus(String routeStatus) {
        this.routeStatus = routeStatus;
    }

    public String formatBookingDate(DateTimeFormatter formatter) {
        return formatDate(bookingDate, formatter);
    }

    public String formatDepartureTime(DateTimeFormatter formatter) {
        return formatDate(departureTime, formatter);
    }

    public String formatArrivalTime(DateTimeFormatter formatter) {
        return formatDate(arrivalTime, formatter);
    }

    public String formatTtlExpiry(DateTimeFormatter formatter) {
        return formatDate(ttlExpiry, formatter);
    }

    public String getFormattedCode() {
        if (bookingId == null) {
            return null;
        }
        return String.format("BK-%05d", bookingId);
    }

    public String getRouteDurationLabel() {
        if (routeDurationMinutes == null) {
            return null;
        }
        int hours = routeDurationMinutes / 60;
        int minutes = routeDurationMinutes % 60;
        if (hours > 0) {
            return String.format("%d giờ %d phút", hours, minutes);
        }
        return String.format("%d phút", minutes);
    }

    private String formatDate(LocalDateTime dateTime, DateTimeFormatter formatter) {
        if (dateTime == null || formatter == null) {
            return null;
        }
        return formatter.format(dateTime);
    }
}
