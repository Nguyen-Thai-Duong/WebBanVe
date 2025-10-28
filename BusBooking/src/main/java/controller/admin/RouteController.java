package controller.admin;

import DAO.RouteDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import model.Route;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import util.InputValidator;

/**
 * Controller responsible for route management flows.
 */
@WebServlet(name = "RouteController", urlPatterns = {"/admin/routes", "/admin/routes/new", "/admin/routes/edit"})
public class RouteController extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = LoggerFactory.getLogger(RouteController.class);
    private static final int MAX_TRIPS_PER_ROUTE = 5;
    private static final String DEFAULT_ROUTE_STATUS = "Active";
    private static final List<String> ROUTE_STATUS_OPTIONS = Collections.unmodifiableList(Arrays.asList("Active", "Inactive"));
    private static final Set<String> ROUTE_STATUS_SET = Collections.unmodifiableSet(new HashSet<>(ROUTE_STATUS_OPTIONS));

    private final RouteDAO routeDAO = new RouteDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String path = request.getServletPath();
        if ("/admin/routes/new".equals(path)) {
            showCreateForm(request, response);
        } else if ("/admin/routes/edit".equals(path)) {
            showEditForm(request, response);
        } else {
            showRouteList(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String path = request.getServletPath();
        if ("/admin/routes".equals(path)) {
            handleActionPost(request, response);
        } else if ("/admin/routes/new".equals(path)) {
            handleCreate(request, response);
        } else if ("/admin/routes/edit".equals(path)) {
            handleUpdate(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/routes");
        }
    }

    private void showRouteList(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        List<Route> routes = routeDAO.findAll();
        if (routes == null) {
            routes = Collections.emptyList();
        }
        request.setAttribute("routes", routes);
        request.setAttribute("maxTripsPerRoute", MAX_TRIPS_PER_ROUTE);
        request.setAttribute("activeMenu", "routes");
        forward(request, response, "/WEB-INF/admin/routes/route-list.jsp");
    }

    private void showCreateForm(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        prepareRouteForm(request, null);
        forward(request, response, "/WEB-INF/admin/routes/route-create.jsp");
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Integer routeId = parseInteger(request.getParameter("routeId"));
        if (routeId == null) {
            setFlash(request.getSession(), "routeMessage", "Không tìm thấy tuyến đường.", "danger");
            response.sendRedirect(request.getContextPath() + "/admin/routes");
            return;
        }
        Route route = routeDAO.findById(routeId);
        if (route == null) {
            setFlash(request.getSession(), "routeMessage", "Không tìm thấy tuyến đường.", "danger");
            response.sendRedirect(request.getContextPath() + "/admin/routes");
            return;
        }
        prepareRouteForm(request, route);
        forward(request, response, "/WEB-INF/admin/routes/route-edit.jsp");
    }

    private void handleCreate(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Route route = buildRouteFromRequest(request);
        if (!validateRoute(request, route)) {
            response.sendRedirect(request.getContextPath() + "/admin/routes/new");
            return;
        }
        boolean created = routeDAO.insert(route);
        setFlash(request.getSession(), "routeMessage", created ? "Tạo tuyến đường thành công." : "Không thể tạo tuyến đường.", created ? "success" : "danger");
        response.sendRedirect(request.getContextPath() + "/admin/routes");
    }

    private void handleUpdate(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Integer routeId = parseInteger(request.getParameter("routeId"));
        if (routeId == null) {
            setFlash(request.getSession(), "routeMessage", "Không tìm thấy tuyến đường cần cập nhật.", "danger");
            response.sendRedirect(request.getContextPath() + "/admin/routes");
            return;
        }
        Route route = buildRouteFromRequest(request);
        route.setRouteId(routeId);
        if (!validateRoute(request, route)) {
            response.sendRedirect(request.getContextPath() + "/admin/routes/edit?routeId=" + routeId);
            return;
        }
        boolean updated = routeDAO.update(route);
        setFlash(request.getSession(), "routeMessage", updated ? "Cập nhật tuyến đường thành công." : "Không thể cập nhật tuyến đường.", updated ? "success" : "danger");
        response.sendRedirect(request.getContextPath() + "/admin/routes");
    }

    private void handleActionPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String action = request.getParameter("action");
        if ("delete".equals(action)) {
            handleDelete(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/routes");
        }
    }

    private void handleDelete(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Integer routeId = parseInteger(request.getParameter("routeId"));
        if (routeId == null) {
            setFlash(request.getSession(), "routeMessage", "Không tìm thấy tuyến đường cần xóa.", "danger");
        } else {
            boolean deleted = routeDAO.delete(routeId);
            setFlash(request.getSession(), "routeMessage", deleted ? "Đã xóa tuyến đường." : "Không thể xóa tuyến đường.", deleted ? "success" : "danger");
        }
        response.sendRedirect(request.getContextPath() + "/admin/routes");
    }

    private Route buildRouteFromRequest(HttpServletRequest request) {
        Route route = new Route();
        route.setOrigin(trim(request.getParameter("origin")));
        route.setDestination(trim(request.getParameter("destination")));
        route.setDistance(parseDecimal(request.getParameter("distance")));
        route.setDurationMinutes(parseDurationMinutes(request.getParameter("durationMinutes")));
        route.setRouteStatus(normalizeRouteStatus(request.getParameter("routeStatus")));
        return route;
    }

    private boolean validateRoute(HttpServletRequest request, Route route) {
        if (route.getOrigin() == null || route.getOrigin().isBlank()) {
            setFlash(request.getSession(), "routeMessage", "Vui lòng nhập điểm đi.", "danger");
            return false;
        }
        if (route.getDestination() == null || route.getDestination().isBlank()) {
            setFlash(request.getSession(), "routeMessage", "Vui lòng nhập điểm đến.", "danger");
            return false;
        }
        if (route.getOrigin() != null && route.getDestination() != null
                && route.getOrigin().equalsIgnoreCase(route.getDestination())) {
            setFlash(request.getSession(), "routeMessage", "Điểm đi và điểm đến phải khác nhau.", "danger");
            return false;
        }
        String distanceRaw = trim(request.getParameter("distance"));
        if (distanceRaw != null && route.getDistance() == null) {
            setFlash(request.getSession(), "routeMessage", "Khoảng cách phải là số nguyên không âm.", "danger");
            return false;
        }
        String durationRaw = trim(request.getParameter("durationMinutes"));
        if (durationRaw != null && route.getDurationMinutes() == null) {
            setFlash(request.getSession(), "routeMessage", "Thời gian tuyến đường phải là số phút hợp lệ.", "danger");
            return false;
        }
        if (route.getDurationMinutes() != null && route.getDurationMinutes() < 0) {
            setFlash(request.getSession(), "routeMessage", "Thời gian tuyến đường không được nhỏ hơn 0.", "danger");
            return false;
        }
        String statusRaw = trim(request.getParameter("routeStatus"));
        if (statusRaw != null && !ROUTE_STATUS_SET.contains(statusRaw)) {
            setFlash(request.getSession(), "routeMessage", "Trạng thái tuyến đường không hợp lệ.", "danger");
            return false;
        }
        return true;
    }

    private void prepareRouteForm(HttpServletRequest request, Route route) {
        Route resolvedRoute = route != null ? route : new Route();
        if (resolvedRoute.getRouteStatus() == null || resolvedRoute.getRouteStatus().isBlank()) {
            resolvedRoute.setRouteStatus(DEFAULT_ROUTE_STATUS);
        }
        request.setAttribute("route", resolvedRoute);
        request.setAttribute("activeMenu", "routes");
        request.setAttribute("formAction", resolvedRoute.getRouteId() != null
                ? request.getContextPath() + "/admin/routes/edit"
                : request.getContextPath() + "/admin/routes/new");
        request.setAttribute("submitLabel", resolvedRoute.getRouteId() != null ? "Cập nhật" : "Tạo tuyến");
        request.setAttribute("cancelHref", request.getContextPath() + "/admin/routes");
        request.setAttribute("routeStatuses", ROUTE_STATUS_OPTIONS);
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

    private BigDecimal parseDecimal(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        String trimmed = value.trim();
        if (!InputValidator.isDigitsOnly(trimmed)) {
            LOGGER.warn("Invalid distance value (non integer digits): {}", value);
            return null;
        }
        try {
            return new BigDecimal(trimmed);
        } catch (NumberFormatException ex) {
            LOGGER.warn("Failed to parse decimal value: {}", value);
            return null;
        }
    }

    private Integer parseDurationMinutes(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        try {
            int minutes = Integer.parseInt(value.trim());
            return minutes >= 0 ? minutes : null;
        } catch (NumberFormatException ex) {
            LOGGER.warn("Failed to parse route duration value: {}", value);
            return null;
        }
    }

    private String normalizeRouteStatus(String status) {
        String trimmed = trim(status);
        if (trimmed == null) {
            return DEFAULT_ROUTE_STATUS;
        }
        return ROUTE_STATUS_SET.contains(trimmed) ? trimmed : DEFAULT_ROUTE_STATUS;
    }

    @Override
    public String getServletInfo() {
        return "Route management controller";
    }
}
