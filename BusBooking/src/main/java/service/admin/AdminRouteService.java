package service.admin;

import DAO.RouteDAO;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import model.Route;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import util.InputValidator;

import java.math.BigDecimal;
import java.util.Collections;
import java.util.List;
import java.util.Set;

/**
 * Service layer for route management in admin module.
 */
public class AdminRouteService extends BaseAdminService {
    
    private static final Logger LOGGER = LoggerFactory.getLogger(AdminRouteService.class);
    private static final String DEFAULT_ROUTE_STATUS = "Active";
    
    private final RouteDAO routeDAO;
    
    public AdminRouteService() {
        this.routeDAO = new RouteDAO();
    }
    
    /**
     * Get all routes.
     */
    public List<Route> getAllRoutes() {
        List<Route> routes = routeDAO.findAll();
        return routes != null ? routes : Collections.emptyList();
    }
    
    /**
     * Get route by ID.
     */
    public Route getRouteById(Integer routeId) {
        if (routeId == null) {
            return null;
        }
        return routeDAO.findById(routeId);
    }
    
    /**
     * Create a new route.
     */
    public boolean createRoute(Route route) {
        if (route == null) {
            LOGGER.warn("Attempted to create null route");
            return false;
        }
        return routeDAO.insert(route);
    }
    
    /**
     * Update an existing route.
     */
    public boolean updateRoute(Route route) {
        if (route == null || route.getRouteId() == null) {
            LOGGER.warn("Attempted to update invalid route");
            return false;
        }
        return routeDAO.update(route);
    }
    
    /**
     * Delete a route.
     */
    public boolean deleteRoute(Integer routeId) {
        if (routeId == null) {
            LOGGER.warn("Attempted to delete route with null ID");
            return false;
        }
        return routeDAO.delete(routeId);
    }
    
    /**
     * Build Route from HTTP request parameters.
     */
    public Route buildRouteFromRequest(HttpServletRequest request, Set<String> routeStatusSet) {
        Route route = new Route();
        route.setOrigin(trim(request.getParameter("origin")));
        route.setDestination(trim(request.getParameter("destination")));
        route.setDistance(parseDecimal(request.getParameter("distance")));
        route.setDurationMinutes(parseDurationMinutes(request.getParameter("durationMinutes")));
        route.setRouteStatus(normalizeRouteStatus(request.getParameter("routeStatus"), routeStatusSet));
        return route;
    }
    
    /**
     * Validate route data.
     */
    public boolean validateRoute(HttpSession session, HttpServletRequest request, Route route, Set<String> routeStatusSet) {
        if (route.getOrigin() == null || route.getOrigin().isBlank()) {
            setFlash(session, "routeMessage", "Vui lòng nhập điểm đi.", "danger");
            return false;
        }
        if (route.getDestination() == null || route.getDestination().isBlank()) {
            setFlash(session, "routeMessage", "Vui lòng nhập điểm đến.", "danger");
            return false;
        }
        if (route.getOrigin() != null && route.getDestination() != null
                && route.getOrigin().equalsIgnoreCase(route.getDestination())) {
            setFlash(session, "routeMessage", "Điểm đi và điểm đến phải khác nhau.", "danger");
            return false;
        }
        String distanceRaw = trim(request.getParameter("distance"));
        if (distanceRaw != null && route.getDistance() == null) {
            setFlash(session, "routeMessage", "Khoảng cách phải là số nguyên không âm.", "danger");
            return false;
        }
        String durationRaw = trim(request.getParameter("durationMinutes"));
        if (durationRaw != null && route.getDurationMinutes() == null) {
            setFlash(session, "routeMessage", "Thời gian tuyến đường phải là số phút hợp lệ.", "danger");
            return false;
        }
        if (route.getDurationMinutes() != null && route.getDurationMinutes() < 0) {
            setFlash(session, "routeMessage", "Thời gian tuyến đường không được nhỏ hơn 0.", "danger");
            return false;
        }
        String statusRaw = trim(request.getParameter("routeStatus"));
        if (statusRaw != null && !routeStatusSet.contains(statusRaw)) {
            setFlash(session, "routeMessage", "Trạng thái tuyến đường không hợp lệ.", "danger");
            return false;
        }
        return true;
    }
    
    /**
     * Parse decimal value from string.
     */
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
    
    /**
     * Parse duration minutes from string.
     */
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
    
    /**
     * Normalize route status to valid value.
     */
    private String normalizeRouteStatus(String status, Set<String> routeStatusSet) {
        String trimmed = trim(status);
        if (trimmed == null) {
            return DEFAULT_ROUTE_STATUS;
        }
        return routeStatusSet.contains(trimmed) ? trimmed : DEFAULT_ROUTE_STATUS;
    }
}
