package controller.admin;

import DAO.BookingDAO;
import dto.BookingAdminView;
import dto.TripOption;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.Collections;
import java.util.List;
import model.User;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import util.InputValidator;

/**
 * Controller responsible for booking administration CRUD flows.
 */
@WebServlet(name = "BookingController", urlPatterns = {"/admin/bookings", "/admin/bookings/new", "/admin/bookings/edit"})
public class BookingController extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = LoggerFactory.getLogger(BookingController.class);

    private static final String[] BOOKING_STATUSES = {"Pending", "Confirmed", "Cancelled", "Void"};
    private static final String[] SEAT_STATUSES = {"Booked", "Reserved", "Cancelled"};
    private static final DateTimeFormatter DISPLAY_FORMATTER = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
    private static final DateTimeFormatter INPUT_FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm");

    private final BookingDAO bookingDAO = new BookingDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String path = request.getServletPath();
        if ("/admin/bookings/new".equals(path)) {
            showCreateForm(request, response);
        } else if ("/admin/bookings/edit".equals(path)) {
            showEditForm(request, response);
        } else {
            showBookingList(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String path = request.getServletPath();
        if ("/admin/bookings".equals(path)) {
            handleActionPost(request, response);
        } else if ("/admin/bookings/new".equals(path)) {
            handleCreate(request, response);
        } else if ("/admin/bookings/edit".equals(path)) {
            handleUpdate(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/bookings");
        }
    }

    private void showBookingList(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        List<BookingAdminView> bookings = bookingDAO.findAll();
        if (bookings == null) {
            bookings = Collections.emptyList();
        }
        request.setAttribute("bookings", bookings);
        request.setAttribute("bookingStatuses", BOOKING_STATUSES);
        request.setAttribute("seatStatuses", SEAT_STATUSES);
        request.setAttribute("dateFormatter", DISPLAY_FORMATTER);
        request.setAttribute("activeMenu", "bookings");
        forward(request, response, "/WEB-INF/admin/bookings/booking-list.jsp");
    }

    private void showCreateForm(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        prepareBookingForm(request, null);
        forward(request, response, "/WEB-INF/admin/bookings/booking-create.jsp");
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Integer bookingId = parseInteger(request.getParameter("bookingId"));
        if (bookingId == null) {
            setFlash(request.getSession(), "bookingMessage", "Không tìm thấy đơn đặt chỗ.", "danger");
            response.sendRedirect(request.getContextPath() + "/admin/bookings");
            return;
        }
        BookingAdminView booking = bookingDAO.findById(bookingId);
        if (booking == null) {
            setFlash(request.getSession(), "bookingMessage", "Không tìm thấy đơn đặt chỗ.", "danger");
            response.sendRedirect(request.getContextPath() + "/admin/bookings");
            return;
        }
        prepareBookingForm(request, booking);
        forward(request, response, "/WEB-INF/admin/bookings/booking-edit.jsp");
    }

    private void handleCreate(HttpServletRequest request, HttpServletResponse response) throws IOException {
        BookingAdminView booking = buildBookingFromRequest(request);
        if (!validateBooking(request, booking)) {
            response.sendRedirect(request.getContextPath() + "/admin/bookings/new");
            return;
        }
        boolean created = bookingDAO.insert(booking);
        setFlash(request.getSession(), "bookingMessage", created ? "Tạo đơn đặt chỗ thành công." : "Không thể tạo đơn đặt chỗ.", created ? "success" : "danger");
        response.sendRedirect(request.getContextPath() + "/admin/bookings");
    }

    private void handleUpdate(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Integer bookingId = parseInteger(request.getParameter("bookingId"));
        if (bookingId == null) {
            setFlash(request.getSession(), "bookingMessage", "Không tìm thấy đơn đặt chỗ cần cập nhật.", "danger");
            response.sendRedirect(request.getContextPath() + "/admin/bookings");
            return;
        }
        BookingAdminView booking = buildBookingFromRequest(request);
        booking.setBookingId(bookingId);
        if (!validateBooking(request, booking)) {
            response.sendRedirect(request.getContextPath() + "/admin/bookings/edit?bookingId=" + bookingId);
            return;
        }
        boolean updated = bookingDAO.update(booking);
        setFlash(request.getSession(), "bookingMessage", updated ? "Cập nhật đơn đặt chỗ thành công." : "Không thể cập nhật đơn đặt chỗ.", updated ? "success" : "danger");
        response.sendRedirect(request.getContextPath() + "/admin/bookings");
    }

    private void handleActionPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String action = request.getParameter("action");
        if ("delete".equals(action)) {
            handleDelete(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/bookings");
        }
    }

    private void handleDelete(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Integer bookingId = parseInteger(request.getParameter("bookingId"));
        if (bookingId == null) {
            setFlash(request.getSession(), "bookingMessage", "Không tìm thấy đơn đặt chỗ cần xóa.", "danger");
        } else {
            boolean deleted = bookingDAO.delete(bookingId);
            setFlash(request.getSession(), "bookingMessage", deleted ? "Đã xóa đơn đặt chỗ." : "Không thể xóa đơn đặt chỗ.", deleted ? "success" : "danger");
        }
        response.sendRedirect(request.getContextPath() + "/admin/bookings");
    }

    private BookingAdminView buildBookingFromRequest(HttpServletRequest request) {
        BookingAdminView booking = new BookingAdminView();
        booking.setTripId(parseInteger(request.getParameter("tripId")));
        booking.setCustomerId(parseInteger(request.getParameter("customerId")));
        booking.setGuestPhoneNumber(trim(request.getParameter("guestPhone")));
        booking.setGuestEmail(trim(request.getParameter("guestEmail")));
        booking.setSeatNumber(trim(request.getParameter("seatNumber")));
        booking.setBookingStatus(defaultIfBlank(request.getParameter("bookingStatus"), BOOKING_STATUSES[0]));
        booking.setSeatStatus(defaultIfBlank(request.getParameter("seatStatus"), SEAT_STATUSES[0]));
        booking.setTtlExpiry(parseDateTime(request.getParameter("ttlExpiry")));
        return booking;
    }

    private boolean validateBooking(HttpServletRequest request, BookingAdminView booking) {
        if (booking.getTripId() == null) {
            setFlash(request.getSession(), "bookingMessage", "Vui lòng chọn chuyến đi.", "danger");
            return false;
        }
        if (booking.getSeatNumber() == null || booking.getSeatNumber().isBlank()) {
            setFlash(request.getSession(), "bookingMessage", "Vui lòng nhập số ghế.", "danger");
            return false;
        }
        if (booking.getCustomerId() == null && (booking.getGuestPhoneNumber() == null || booking.getGuestPhoneNumber().isBlank())) {
            setFlash(request.getSession(), "bookingMessage", "Cần chọn khách hàng hoặc cung cấp số điện thoại khách lẻ.", "danger");
            return false;
        }
        if (booking.getGuestPhoneNumber() != null && !booking.getGuestPhoneNumber().isBlank()
                && !InputValidator.isDigitsOnly(booking.getGuestPhoneNumber())) {
            setFlash(request.getSession(), "bookingMessage", "Số điện thoại khách lẻ chỉ được chứa chữ số.", "danger");
            return false;
        }
        return true;
    }

    private void prepareBookingForm(HttpServletRequest request, BookingAdminView booking) {
        List<TripOption> trips = bookingDAO.findTripOptions();
        List<User> customers = bookingDAO.findCustomersForSelection();
        request.setAttribute("booking", booking);
        request.setAttribute("tripOptions", trips != null ? trips : Collections.emptyList());
        request.setAttribute("customers", customers != null ? customers : Collections.emptyList());
        request.setAttribute("bookingStatuses", BOOKING_STATUSES);
        request.setAttribute("seatStatuses", SEAT_STATUSES);
        request.setAttribute("dateFormatter", DISPLAY_FORMATTER);
        request.setAttribute("ttlValue", formatForInput(booking != null ? booking.getTtlExpiry() : null));
        request.setAttribute("activeMenu", "bookings");
    }

    private void setFlash(HttpSession session, String key, String message, String type) {
        session.setAttribute(key, message);
        session.setAttribute(key + "Type", type);
    }

    private void forward(HttpServletRequest request, HttpServletResponse response, String path) throws ServletException, IOException {
        request.getRequestDispatcher(path).forward(request, response);
    }

    private Integer parseInteger(String value) {
        try {
            return value != null && !value.isBlank() ? Integer.valueOf(value) : null;
        } catch (NumberFormatException ex) {
            LOGGER.warn("Failed to parse integer value: {}", value);
            return null;
        }
    }

    private String trim(String value) {
        if (value == null) {
            return null;
        }
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }

    private String defaultIfBlank(String value, String fallback) {
        if (value == null) {
            return fallback;
        }
        String trimmed = value.trim();
        return trimmed.isEmpty() ? fallback : trimmed;
    }

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

    private String formatForInput(LocalDateTime value) {
        if (value == null) {
            return null;
        }
        return INPUT_FORMATTER.format(value);
    }

    @Override
    public String getServletInfo() {
        return "Booking management controller";
    }
}
