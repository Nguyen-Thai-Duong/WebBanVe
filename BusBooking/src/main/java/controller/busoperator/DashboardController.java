package controller.busoperator;

import DAO.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.User;
import java.io.IOException;
import java.time.LocalDateTime;
import java.util.Map;
import java.util.HashMap;

@WebServlet("/bus-operator/dashboard")
public class DashboardController extends HttpServlet {
    private final RouteDAO routeDAO = new RouteDAO();
    private final TripDAO tripDAO = new TripDAO();
    private final BookingDAO bookingDAO = new BookingDAO();
    private final VehicleDAO vehicleDAO = new VehicleDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User operator = (User) request.getSession().getAttribute("user");
        if (operator == null) {
            response.sendRedirect(request.getContextPath() + "/login-form.jsp");
            return;
        }

        int operatorId = operator.getUserId();

        // Get statistics
        Map<String, Object> stats = new HashMap<>();
        stats.put("totalRoutes", routeDAO.countRoutesByOperator(operatorId));
        stats.put("activeRoutes", routeDAO.countActiveRoutesByOperator(operatorId));
        stats.put("totalVehicles", vehicleDAO.countVehiclesByOperator(operatorId));
        stats.put("activeVehicles", vehicleDAO.countActiveVehiclesByOperator(operatorId));

        LocalDateTime now = LocalDateTime.now();
        stats.put("upcomingTrips", tripDAO.countUpcomingTripsByOperator(operatorId, now));
        stats.put("todayBookings", bookingDAO.countTodayBookingsByOperator(operatorId));
        stats.put("monthlyBookings", bookingDAO.countMonthlyBookingsByOperator(operatorId));
        stats.put("monthlyRevenue", bookingDAO.calculateMonthlyRevenueByOperator(operatorId));

        request.setAttribute("stats", stats);
        request.getRequestDispatcher("/WEB-INF/busOperator/dashboard.jsp").forward(request, response);
    }
}