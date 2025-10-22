package controller.admin;

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
import java.util.List;
import model.Route;
import model.Trip;
import model.User;
import model.Vehicle;

/**
 * Servlet controller for Trip CRUD in the admin module.
 */
@WebServlet(name = "TripController", urlPatterns = {"/admin/trips"})
public class TripController extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final DateTimeFormatter FORM_INPUT_FORMAT = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm");

    private final TripDAO tripDAO = new TripDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
    loadReferenceData(request);
    List<Trip> trips = tripDAO.findAll();
    request.setAttribute("trips", trips);
    request.getRequestDispatcher("/WEB-INF/admin/trips-manager/trip-list.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        if (action == null) {
            response.sendRedirect(request.getContextPath() + "/admin/trips");
            return;
        }

        switch (action) {
            case "create":
                handleCreate(request, response);
                break;
            case "update":
                handleUpdate(request, response);
                break;
            case "delete":
                handleDelete(request, response);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/admin/trips");
        }
    }

    private void handleCreate(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Trip trip = buildTripFromRequest(request);
        if (!isValidTripData(trip)) {
            setFlash(request.getSession(), "danger", "Vui lòng nhập đầy đủ thông tin bắt buộc.");
            response.sendRedirect(request.getContextPath() + "/admin/trips");
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
        if (!isValidTripData(trip)) {
            setFlash(request.getSession(), "danger", "Vui lòng nhập đầy đủ thông tin bắt buộc.");
            response.sendRedirect(request.getContextPath() + "/admin/trips");
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
        trip.setArrivalTime(parseDateTime(request.getParameter("arrivalTime")));
        trip.setPrice(parseBigDecimal(request.getParameter("price")));
        trip.setTripStatus(defaultIfBlank(request.getParameter("tripStatus"), "Scheduled"));

        return trip;
    }

    private void loadReferenceData(HttpServletRequest request) {
        List<Route> routes = tripDAO.findRoutes();
        List<Vehicle> vehicles = tripDAO.findVehicles();
        List<User> operators = tripDAO.findOperators();
        request.setAttribute("routes", routes);
        request.setAttribute("vehicles", vehicles);
        request.setAttribute("operators", operators);
    }

    private void setFlash(HttpSession session, String type, String message) {
        session.setAttribute("tripMessage", message);
        session.setAttribute("tripMessageType", type);
    }

    private Integer parseInteger(String value) {
        try {
            return value != null && !value.isBlank() ? Integer.valueOf(value) : null;
        } catch (NumberFormatException ex) {
            return null;
        }
    }

    private BigDecimal parseBigDecimal(String value) {
        try {
            return value != null && !value.isBlank() ? new BigDecimal(value) : null;
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
                && trip.getPrice() != null;
    }

    private String defaultIfBlank(String value, String defaultValue) {
        return (value == null || value.isBlank()) ? defaultValue : value;
    }

    @Override
    public String getServletInfo() {
        return "Trip management controller";
    }
}
