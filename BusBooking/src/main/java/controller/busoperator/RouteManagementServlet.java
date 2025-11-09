package controller.busoperator;

import DAO.RouteDAOImpl;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Route;
import model.User;
import util.InputValidator;

import java.io.IOException;
import java.util.List;
import java.math.BigDecimal;

@WebServlet("/bus-operator/routes/*")
public class RouteManagementServlet extends HttpServlet {
    private final RouteDAOImpl routeDAO;

    public RouteManagementServlet() {
        this.routeDAO = new RouteDAOImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String pathInfo = request.getPathInfo();

        if (pathInfo == null || pathInfo.equals("/")) {
            listRoutes(request, response);
        } else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String pathInfo = request.getPathInfo();

        if ("/add".equals(pathInfo)) {
            addRoute(request, response);
        } else if ("/edit".equals(pathInfo)) {
            editRoute(request, response);
        } else if ("/delete".equals(pathInfo)) {
            deleteRoute(request, response);
        } else if ("/toggle-status".equals(pathInfo)) {
            toggleRouteStatus(request, response);
        } else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    private void listRoutes(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User operator = (User) request.getSession().getAttribute("user");
        List<Route> routes = routeDAO.getRoutesByOperatorId(operator.getUserId());
        request.setAttribute("routes", routes);
        request.getRequestDispatcher("/WEB-INF/busOperator/routes.jsp").forward(request, response);
    }

    private void addRoute(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            User operator = (User) request.getSession().getAttribute("user");
            if (operator == null) {
                response.sendError(HttpServletResponse.SC_UNAUTHORIZED);
                return;
            }

            String origin = request.getParameter("origin");
            String destination = request.getParameter("destination");
            String distance = request.getParameter("distance");
            String duration = request.getParameter("durationMinutes");

            // Validate inputs
            if (!InputValidator.isValidCity(origin) || !InputValidator.isValidCity(destination)) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("Invalid city name format");
                return;
            }

            if (!InputValidator.isValidDistance(distance)) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("Invalid distance format");
                return;
            }

            if (!InputValidator.isDigitsOnly(duration)) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("Invalid duration format");
                return;
            }

            Route route = new Route();
            route.setOrigin(origin);
            route.setDestination(destination);
            route.setDistance(new BigDecimal(distance));
            route.setDurationMinutes(Integer.parseInt(duration));
            route.setRouteStatus("Active");
            route.setOperatorId(operator.getUserId());

            if (routeDAO.addRoute(route)) {
                response.sendRedirect(request.getContextPath() + "/bus-operator/routes");
            } else {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                response.getWriter().write("Failed to add route");
            }
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("Error adding route: " + e.getMessage());
        }
    }

    private void editRoute(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String routeId = request.getParameter("routeId");
            String origin = request.getParameter("origin");
            String destination = request.getParameter("destination");
            String distance = request.getParameter("distance");
            String duration = request.getParameter("durationMinutes");

            if (!InputValidator.isDigitsOnly(routeId)) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("Invalid route ID");
                return;
            }

            // Validate inputs
            if (!InputValidator.isValidCity(origin) || !InputValidator.isValidCity(destination)) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("Invalid city name format");
                return;
            }

            if (!InputValidator.isValidDistance(distance)) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("Invalid distance format");
                return;
            }

            if (!InputValidator.isDigitsOnly(duration)) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("Invalid duration format");
                return;
            }

            User operator = (User) request.getSession().getAttribute("user");
            Route route = new Route();
            route.setRouteId(Integer.parseInt(routeId));
            route.setOrigin(origin);
            route.setDestination(destination);
            route.setDistance(new BigDecimal(distance));
            route.setDurationMinutes(Integer.parseInt(duration));
            // Needed by RouteDAOImpl.updateRoute (has OperatorID condition)
            if (operator != null) {
                route.setOperatorId(operator.getUserId());
            }

            if (routeDAO.updateRoute(route)) {
                response.sendRedirect(request.getContextPath() + "/bus-operator/routes");
            } else {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                response.getWriter().write("Failed to update route");
            }
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("Error updating route: " + e.getMessage());
        }
    }

    private void deleteRoute(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String routeId = request.getParameter("routeId");
            if (!InputValidator.isDigitsOnly(routeId)) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("Invalid route ID");
                return;
            }

            Route route = routeDAO.getRouteById(Integer.parseInt(routeId));
            if (route == null) {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                response.getWriter().write("Route not found");
                return;
            }

            // Check if route has any trips
            if (route.getTripCount() > 0) {
                response.setStatus(HttpServletResponse.SC_CONFLICT);
                response.getWriter().write("Cannot delete route with existing trips");
                return;
            }

            if (routeDAO.deleteRoute(Integer.parseInt(routeId))) {
                response.setStatus(HttpServletResponse.SC_OK);
            } else {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                response.getWriter().write("Failed to delete route");
            }
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("Error deleting route: " + e.getMessage());
        }
    }

    private void toggleRouteStatus(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String routeId = request.getParameter("routeId");
            if (!InputValidator.isDigitsOnly(routeId)) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("Invalid route ID");
                return;
            }

            Route route = routeDAO.getRouteById(Integer.parseInt(routeId));
            if (route == null) {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                response.getWriter().write("Route not found");
                return;
            }

            String newStatus = "Active".equals(route.getRouteStatus()) ? "Inactive" : "Active";
            if (routeDAO.updateRouteStatus(route.getRouteId(), newStatus)) {
                response.setStatus(HttpServletResponse.SC_OK);
            } else {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                response.getWriter().write("Failed to update route status");
            }
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("Error toggling route status: " + e.getMessage());
        }
    }
}