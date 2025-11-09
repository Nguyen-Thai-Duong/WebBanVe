package service.admin;

import DAO.BookingDAO;
import dto.TripOption;
import dto.BookingAdminView;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import model.User;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import util.InputValidator;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.Collections;
import java.util.List;

/**
 * Service layer for booking management in admin module.
 * Handles business logic, validation, and DTO mapping.
 */
public class AdminBookingService extends BaseAdminService {
    
    private static final Logger LOGGER = LoggerFactory.getLogger(AdminBookingService.class);
    private static final DateTimeFormatter INPUT_FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm");
    
    private final BookingDAO bookingDAO;
    
    public AdminBookingService() {
        this.bookingDAO = new BookingDAO();
    }
    
    /**
     * Get all bookings.
     */
    public List<BookingAdminView> getAllBookings() {
        List<BookingAdminView> bookings = bookingDAO.findAll();
        return bookings != null ? bookings : Collections.emptyList();
    }
    
    /**
     * Get booking by ID.
     */
    public BookingAdminView getBookingById(Integer bookingId) {
        if (bookingId == null) {
            return null;
        }
        return bookingDAO.findById(bookingId);
    }
    
    /**
     * Create a new booking.
     */
    public boolean createBooking(BookingAdminView booking) {
        if (booking == null) {
            LOGGER.warn("Attempted to create null booking");
            return false;
        }
        return bookingDAO.insert(booking);
    }
    
    /**
     * Update an existing booking.
     */
    public boolean updateBooking(BookingAdminView booking) {
        if (booking == null || booking.getBookingId() == null) {
            LOGGER.warn("Attempted to update invalid booking");
            return false;
        }
        return bookingDAO.update(booking);
    }
    
    /**
     * Delete a booking.
     */
    public boolean deleteBooking(Integer bookingId) {
        if (bookingId == null) {
            LOGGER.warn("Attempted to delete booking with null ID");
            return false;
        }
        return bookingDAO.delete(bookingId);
    }
    
    /**
     * Get trip options for selection.
     */
    public List<TripOption> getTripOptions() {
        List<TripOption> trips = bookingDAO.findTripOptions();
        return trips != null ? trips : Collections.emptyList();
    }
    
    /**
     * Get customers for selection.
     */
    public List<User> getCustomersForSelection() {
        List<User> customers = bookingDAO.findCustomersForSelection();
        return customers != null ? customers : Collections.emptyList();
    }
    
    /**
     * Build BookingAdminView from HTTP request parameters.
     */
    public BookingAdminView buildBookingFromRequest(HttpServletRequest request, String[] bookingStatuses, String[] seatStatuses) {
        BookingAdminView booking = new BookingAdminView();
        booking.setTripId(parseInteger(request.getParameter("tripId")));
        booking.setCustomerId(parseInteger(request.getParameter("customerId")));
        booking.setGuestPhoneNumber(trim(request.getParameter("guestPhone")));
        booking.setGuestEmail(trim(request.getParameter("guestEmail")));
        booking.setSeatNumber(trim(request.getParameter("seatNumber")));
        booking.setBookingStatus(defaultIfBlank(request.getParameter("bookingStatus"), bookingStatuses[0]));
        booking.setSeatStatus(defaultIfBlank(request.getParameter("seatStatus"), seatStatuses[0]));
        booking.setTtlExpiry(parseDateTime(request.getParameter("ttlExpiry")));
        return booking;
    }
    
    /**
     * Validate booking data.
     */
    public boolean validateBooking(HttpSession session, BookingAdminView booking) {
        if (booking.getTripId() == null) {
            setFlash(session, "bookingMessage", "Vui lòng chọn chuyến đi.", "danger");
            return false;
        }
        if (booking.getSeatNumber() == null || booking.getSeatNumber().isBlank()) {
            setFlash(session, "bookingMessage", "Vui lòng nhập số ghế.", "danger");
            return false;
        }
        if (booking.getCustomerId() == null && (booking.getGuestPhoneNumber() == null || booking.getGuestPhoneNumber().isBlank())) {
            setFlash(session, "bookingMessage", "Cần chọn khách hàng hoặc cung cấp số điện thoại khách lẻ.", "danger");
            return false;
        }
        if (booking.getGuestPhoneNumber() != null && !booking.getGuestPhoneNumber().isBlank()
                && !InputValidator.isDigitsOnly(booking.getGuestPhoneNumber())) {
            setFlash(session, "bookingMessage", "Số điện thoại khách lẻ chỉ được chứa chữ số.", "danger");
            return false;
        }
        return true;
    }
    
    /**
     * Format LocalDateTime for HTML input field.
     */
    public String formatForInput(LocalDateTime value) {
        if (value == null) {
            return null;
        }
        return INPUT_FORMATTER.format(value);
    }
    
    /**
     * Parse datetime from string.
     */
    private LocalDateTime parseDateTime(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        try {
            return LocalDateTime.parse(value.trim(), INPUT_FORMATTER);
        } catch (DateTimeParseException ex) {
            LOGGER.warn("Failed to parse datetime value: {}", value);
            return null;
        }
    }
}
