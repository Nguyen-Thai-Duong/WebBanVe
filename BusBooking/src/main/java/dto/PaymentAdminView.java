package dto;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

/**
 * Projection model for payment administration screens.
 */
public class PaymentAdminView {

    private Integer paymentId;
    private Integer bookingId;
    private BigDecimal amount;
    private LocalDateTime transactionDate;
    private String method;
    private String type;
    private String transactionRef;

    private String routeOrigin;
    private String routeDestination;
    private String seatNumber;
    private String bookingStatus;
    private String customerName;
    private LocalDateTime departureTime;

    public Integer getPaymentId() {
        return paymentId;
    }

    public void setPaymentId(Integer paymentId) {
        this.paymentId = paymentId;
    }

    public Integer getBookingId() {
        return bookingId;
    }

    public void setBookingId(Integer bookingId) {
        this.bookingId = bookingId;
    }

    public BigDecimal getAmount() {
        return amount;
    }

    public void setAmount(BigDecimal amount) {
        this.amount = amount;
    }

    public LocalDateTime getTransactionDate() {
        return transactionDate;
    }

    public void setTransactionDate(LocalDateTime transactionDate) {
        this.transactionDate = transactionDate;
    }

    public String getMethod() {
        return method;
    }

    public void setMethod(String method) {
        this.method = method;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getTransactionRef() {
        return transactionRef;
    }

    public void setTransactionRef(String transactionRef) {
        this.transactionRef = transactionRef;
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

    public String getSeatNumber() {
        return seatNumber;
    }

    public void setSeatNumber(String seatNumber) {
        this.seatNumber = seatNumber;
    }

    public String getBookingStatus() {
        return bookingStatus;
    }

    public void setBookingStatus(String bookingStatus) {
        this.bookingStatus = bookingStatus;
    }

    public boolean isPending() {
        return bookingStatus != null && "pending".equalsIgnoreCase(bookingStatus);
    }

    public String getCustomerName() {
        return customerName;
    }

    public void setCustomerName(String customerName) {
        this.customerName = customerName;
    }

    public LocalDateTime getDepartureTime() {
        return departureTime;
    }

    public void setDepartureTime(LocalDateTime departureTime) {
        this.departureTime = departureTime;
    }

    public String formatTransactionDate(DateTimeFormatter formatter) {
        return formatDate(transactionDate, formatter);
    }

    public String formatDepartureTime(DateTimeFormatter formatter) {
        return formatDate(departureTime, formatter);
    }

    public String buildRouteLabel() {
        String origin = routeOrigin != null ? routeOrigin : "?";
        String destination = routeDestination != null ? routeDestination : "?";
        return origin + " -> " + destination;
    }

    private String formatDate(LocalDateTime dateTime, DateTimeFormatter formatter) {
        if (dateTime == null || formatter == null) {
            return null;
        }
        return formatter.format(dateTime);
    }
}
