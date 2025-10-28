package controller.admin;

import DAO.RouteDAO;
import DAO.TripDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.Collections;
import java.util.List;
import model.Route;
import model.Trip;
import model.User;
import model.Vehicle;
import util.InputValidator;

/**
 * Servlet controller for Trip CRUD in the admin module.
 */
@WebServlet(name = "TripController", urlPatterns = {"/admin/trips", "/admin/trips/new", "/admin/trips/edit"})
public class TripController extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final DateTimeFormatter FORM_INPUT_FORMAT = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm");
    private static final DateTimeFormatter TABLE_FORMATTER = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
    private static final String[] TRIP_STATUSES = {"Scheduled", "Departed", "Arrived", "Delayed", "Cancelled"};
    private static final String ACTIVE_ROUTE_STATUS = "Active";
    private static final int MAX_TRIPS_PER_ROUTE = 5;

    private final TripDAO tripDAO = new TripDAO();
    private final RouteDAO routeDAO = new RouteDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();
        switch (path) {
            case "/admin/trips":
                List<Trip> trips = tripDAO.findAll();
                if (trips == null) {
                    trips = Collections.emptyList();
                }
                request.setAttribute("trips", trips);
                request.setAttribute("tableFormatter", TABLE_FORMATTER);
                request.setAttribute("activeMenu", "trips");
                request.getRequestDispatcher("/WEB-INF/admin/trips/trip-list.jsp").forward(request, response);
                break;
            case "/admin/trips/new":
                prepareTripForm(request, null);
                request.getRequestDispatcher("/WEB-INF/admin/trips/trip-create.jsp").forward(request, response);
                break;
            case "/admin/trips/edit":
                handleEditForm(request, response);
                break;
            default:
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String path = request.getServletPath();
        switch (path) {
            case "/admin/trips":
                handleActionPost(request, response);
                break;
            case "/admin/trips/new":
                handleCreate(request, response);
                break;
            case "/admin/trips/edit":
                handleUpdate(request, response);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/admin/trips");
        }
    }

    private void handleCreate(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Trip trip = buildTripFromRequest(request);
        if (trip.getPrice() == null) {
            setFlash(request.getSession(), "danger", "Giá vé phải là số hợp lệ.");
            response.sendRedirect(request.getContextPath() + "/admin/trips/new");
            return;
        }
        if (!isValidTripData(trip)) {
            setFlash(request.getSession(), "danger", "Vui lòng nhập đầy đủ thông tin bắt buộc.");
            response.sendRedirect(request.getContextPath() + "/admin/trips/new");
            return;
        }
        if (!enrichTripWithRoute(request, trip)) {
            response.sendRedirect(request.getContextPath() + "/admin/trips/new");
            return;
        }
        boolean created = tripDAO.insert(trip);
        if (created) {
            setFlash(request.getSession(), "success", "Tạo chuyến đi thành công.");
        } else {
            setFlash(request.getSession(), "danger", "Không thể tạo chuyến đi. Vui lòng thử lại.");
        }
        response.sendRedirect(request.getContextPath() + "/admin/trips");
    }

    private void handleUpdate(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Trip trip = buildTripFromRequest(request);
        trip.setTripId(parseInteger(request.getParameter("tripId")));
        if (trip.getTripId() == null) {
            setFlash(request.getSession(), "danger", "Thiếu mã chuyến đi cần cập nhật.");
            response.sendRedirect(request.getContextPath() + "/admin/trips");
            return;
        }
        if (trip.getPrice() == null) {
            setFlash(request.getSession(), "danger", "Giá vé phải là số hợp lệ.");
            response.sendRedirect(request.getContextPath() + "/admin/trips/edit?tripId=" + trip.getTripId());
            return;
        }
        if (!isValidTripData(trip)) {
            setFlash(request.getSession(), "danger", "Vui lòng nhập đầy đủ thông tin bắt buộc.");
            response.sendRedirect(request.getContextPath() + "/admin/trips/edit?tripId=" + trip.getTripId());
            return;
        }
        if (!enrichTripWithRoute(request, trip)) {
            response.sendRedirect(request.getContextPath() + "/admin/trips/edit?tripId=" + trip.getTripId());
            return;
        }
        boolean updated = tripDAO.update(trip);
        if (updated) {
            setFlash(request.getSession(), "success", "Cập nhật chuyến đi thành công.");
        } else {
            setFlash(request.getSession(), "danger", "Không thể cập nhật chuyến đi. Vui lòng thử lại.");
        }
        response.sendRedirect(request.getContextPath() + "/admin/trips");
    }

    private void handleDelete(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Integer tripId = parseInteger(request.getParameter("tripId"));
        if (tripId == null) {
            setFlash(request.getSession(), "danger", "Thiếu mã chuyến đi cần xóa.");
            response.sendRedirect(request.getContextPath() + "/admin/trips");
            return;
        }
        boolean deleted = tripDAO.delete(tripId);
        if (deleted) {
            setFlash(request.getSession(), "success", "Đã xóa chuyến đi.");
        } else {
            setFlash(request.getSession(), "danger", "Không thể xóa chuyến đi. Vui lòng thử lại.");
        }
        response.sendRedirect(request.getContextPath() + "/admin/trips");
    }

    private Trip buildTripFromRequest(HttpServletRequest request) {
        Trip trip = new Trip();

        Route route = new Route();
        route.setRouteId(parseInteger(request.getParameter("routeId")));
        trip.setRoute(route);

        Vehicle vehicle = new Vehicle();
        vehicle.setVehicleId(parseInteger(request.getParameter("vehicleId")));
        trip.setVehicle(vehicle);

        User operator = new User();
        operator.setUserId(parseInteger(request.getParameter("operatorId")));
        trip.setOperator(operator);

        trip.setDepartureTime(parseDateTime(request.getParameter("departureTime")));
        trip.setPrice(parseBigDecimal(request.getParameter("price")));
        trip.setTripStatus(defaultIfBlank(request.getParameter("tripStatus"), "Scheduled"));

        return trip;
    }

    private void prepareTripForm(HttpServletRequest request, Trip trip) {
        List<Route> routes = tripDAO.findRoutes();
        List<Vehicle> vehicles = tripDAO.findVehicles();
        List<User> operators = tripDAO.findOperators();
        request.setAttribute("trip", trip);
        request.setAttribute("routes", routes);
        request.setAttribute("vehicles", vehicles);
        request.setAttribute("operators", operators);
        request.setAttribute("tripStatuses", TRIP_STATUSES);
        request.setAttribute("activeMenu", "trips");
        request.setAttribute("maxTripsPerRoute", MAX_TRIPS_PER_ROUTE);
    }

    private void setFlash(HttpSession session, String type, String message) {
        session.setAttribute("tripMessage", message);
        session.setAttribute("tripMessageType", type);
    }

    private void handleEditForm(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        Integer tripId = parseInteger(request.getParameter("tripId"));
        if (tripId == null) {
            setFlash(request.getSession(), "danger", "Thiếu mã chuyến đi cần chỉnh sửa.");
            response.sendRedirect(request.getContextPath() + "/admin/trips");
            return;
        }
        Trip trip = tripDAO.findById(tripId);
        if (trip == null) {
            setFlash(request.getSession(), "danger", "Không tìm thấy chuyến đi.");
            response.sendRedirect(request.getContextPath() + "/admin/trips");
            return;
        }
        prepareTripForm(request, trip);
    request.getRequestDispatcher("/WEB-INF/admin/trips/trip-edit.jsp").forward(request, response);
    }

    private void handleActionPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String action = request.getParameter("action");
        if ("delete".equals(action)) {
            handleDelete(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/trips");
        }
    }

    private Integer parseInteger(String value) {
        try {
            return value != null && !value.isBlank() ? Integer.valueOf(value) : null;
        } catch (NumberFormatException ex) {
            return null;
        }
    }

    private BigDecimal parseBigDecimal(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        String trimmed = value.trim();
        if (!InputValidator.isValidMonetaryAmount(trimmed)) {
            return null;
        }
        try {
            BigDecimal amount = new BigDecimal(trimmed);
            return amount.signum() >= 0 ? amount : null;
        } catch (NumberFormatException ex) {
            return null;
        }
    }

    private LocalDateTime parseDateTime(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        try {
            return LocalDateTime.parse(value, FORM_INPUT_FORMAT);
        } catch (DateTimeParseException ex) {
            return null;
        }
    }

    private boolean isValidTripData(Trip trip) {
        return trip.getRoute() != null && trip.getRoute().getRouteId() != null
                && trip.getVehicle() != null && trip.getVehicle().getVehicleId() != null
                && trip.getOperator() != null && trip.getOperator().getUserId() != null
                && trip.getDepartureTime() != null
        && trip.getPrice() != null && trip.getPrice().signum() >= 0;
    }

    private boolean enrichTripWithRoute(HttpServletRequest request, Trip trip) {
        Integer routeId = trip.getRoute() != null ? trip.getRoute().getRouteId() : null;
        if (routeId == null) {
            setFlash(request.getSession(), "danger", "Vui lòng chọn tuyến đường hợp lệ.");
            return false;
        }
        Route selectedRoute = routeDAO.findById(routeId);
        if (selectedRoute == null) {
            setFlash(request.getSession(), "danger", "Không tìm thấy tuyến đường đã chọn.");
            return false;
        }
        int scheduledTrips = tripDAO.countTripsByRoute(routeId, trip.getTripId());
        if (scheduledTrips >= MAX_TRIPS_PER_ROUTE) {
            setFlash(request.getSession(), "danger", "Tuyến đường đã có đủ " + MAX_TRIPS_PER_ROUTE + " chuyến.");
            return false;
        }
        if (selectedRoute.getRouteStatus() != null && !ACTIVE_ROUTE_STATUS.equalsIgnoreCase(selectedRoute.getRouteStatus())) {
            setFlash(request.getSession(), "danger", "Tuyến đường đang tạm ngưng. Vui lòng chọn tuyến khác.");
            return false;
        }
        Integer durationMinutes = selectedRoute.getDurationMinutes();
        if (durationMinutes == null) {
            setFlash(request.getSession(), "danger", "Tuyến đường chưa có thời gian di chuyển. Vui lòng cập nhật trước khi lập chuyến.");
            return false;
        }
        if (durationMinutes <= 0) {
            setFlash(request.getSession(), "danger", "Thời gian di chuyển của tuyến phải lớn hơn 0 phút.");
            return false;
        }
        if (trip.getDepartureTime() == null) {
            setFlash(request.getSession(), "danger", "Vui lòng nhập giờ khởi hành hợp lệ.");
            return false;
        }
        trip.setRoute(selectedRoute);
        selectedRoute.setTripCount(scheduledTrips);
        trip.setArrivalTime(trip.getDepartureTime().plusMinutes(durationMinutes));
        return true;
    }

    private String defaultIfBlank(String value, String defaultValue) {
        return (value == null || value.isBlank()) ? defaultValue : value;
    }

    @Override
    public String getServletInfo() {
        return "Trip management controller";
    }
}
