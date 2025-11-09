package controller.admin;

import dto.BookingAdminView;
import dto.TripOption;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;
import service.admin.AdminBookingService;

import java.io.IOException;
import java.time.format.DateTimeFormatter;
import java.util.List;

/**
 * Controller responsible for booking administration CRUD flows.
 */
@WebServlet(name = "BookingController", urlPatterns = {"/admin/bookings", "/admin/bookings/new", "/admin/bookings/edit"})
public class BookingController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private static final String[] BOOKING_STATUSES = {"Pending", "Confirmed", "Cancelled", "Void"};
    private static final String[] SEAT_STATUSES = {"Booked", "Reserved", "Cancelled"};
    private static final DateTimeFormatter DISPLAY_FORMATTER = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");

    private final AdminBookingService bookingService = new AdminBookingService();

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
        List<BookingAdminView> bookings = bookingService.getAllBookings();
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
        Integer bookingId = bookingService.parseInteger(request.getParameter("bookingId"));
        if (bookingId == null) {
            bookingService.setFlash(request.getSession(), "bookingMessage", "Không tìm thấy đơn đặt chỗ.", "danger");
            response.sendRedirect(request.getContextPath() + "/admin/bookings");
            return;
        }
        BookingAdminView booking = bookingService.getBookingById(bookingId);
        if (booking == null) {
            bookingService.setFlash(request.getSession(), "bookingMessage", "Không tìm thấy đơn đặt chỗ.", "danger");
            response.sendRedirect(request.getContextPath() + "/admin/bookings");
            return;
        }
        prepareBookingForm(request, booking);
        forward(request, response, "/WEB-INF/admin/bookings/booking-edit.jsp");
    }

    private void handleCreate(HttpServletRequest request, HttpServletResponse response) throws IOException {
        BookingAdminView booking = bookingService.buildBookingFromRequest(request, BOOKING_STATUSES, SEAT_STATUSES);
        if (!bookingService.validateBooking(request.getSession(), booking)) {
            response.sendRedirect(request.getContextPath() + "/admin/bookings/new");
            return;
        }
        boolean created = bookingService.createBooking(booking);
        bookingService.setFlash(request.getSession(), "bookingMessage", 
                created ? "Tạo đơn đặt chỗ thành công." : "Không thể tạo đơn đặt chỗ.", 
                created ? "success" : "danger");
        response.sendRedirect(request.getContextPath() + "/admin/bookings");
    }

    private void handleUpdate(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Integer bookingId = bookingService.parseInteger(request.getParameter("bookingId"));
        if (bookingId == null) {
            bookingService.setFlash(request.getSession(), "bookingMessage", "Không tìm thấy đơn đặt chỗ cần cập nhật.", "danger");
            response.sendRedirect(request.getContextPath() + "/admin/bookings");
            return;
        }
        BookingAdminView booking = bookingService.buildBookingFromRequest(request, BOOKING_STATUSES, SEAT_STATUSES);
        booking.setBookingId(bookingId);
        if (!bookingService.validateBooking(request.getSession(), booking)) {
            response.sendRedirect(request.getContextPath() + "/admin/bookings/edit?bookingId=" + bookingId);
            return;
        }
        boolean updated = bookingService.updateBooking(booking);
        bookingService.setFlash(request.getSession(), "bookingMessage", 
                updated ? "Cập nhật đơn đặt chỗ thành công." : "Không thể cập nhật đơn đặt chỗ.", 
                updated ? "success" : "danger");
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
        Integer bookingId = bookingService.parseInteger(request.getParameter("bookingId"));
        if (bookingId == null) {
            bookingService.setFlash(request.getSession(), "bookingMessage", "Không tìm thấy đơn đặt chỗ cần xóa.", "danger");
        } else {
            boolean deleted = bookingService.deleteBooking(bookingId);
            bookingService.setFlash(request.getSession(), "bookingMessage", 
                    deleted ? "Đã xóa đơn đặt chỗ." : "Không thể xóa đơn đặt chỗ.", 
                    deleted ? "success" : "danger");
        }
        response.sendRedirect(request.getContextPath() + "/admin/bookings");
    }

    private void prepareBookingForm(HttpServletRequest request, BookingAdminView booking) {
        List<TripOption> trips = bookingService.getTripOptions();
        List<User> customers = bookingService.getCustomersForSelection();
        request.setAttribute("booking", booking);
        request.setAttribute("tripOptions", trips);
        request.setAttribute("customers", customers);
        request.setAttribute("bookingStatuses", BOOKING_STATUSES);
        request.setAttribute("seatStatuses", SEAT_STATUSES);
        request.setAttribute("dateFormatter", DISPLAY_FORMATTER);
        request.setAttribute("ttlValue", bookingService.formatForInput(booking != null ? booking.getTtlExpiry() : null));
        request.setAttribute("activeMenu", "bookings");
    }

    private void forward(HttpServletRequest request, HttpServletResponse response, String path) throws ServletException, IOException {
        request.getRequestDispatcher(path).forward(request, response);
    }

    @Override
    public String getServletInfo() {
        return "Booking management controller";
    }
}
