package controller.busoperator;

import DAO.TripDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Objects;
import model.Trip;
import model.User;

/**
 * Displays the dashboard landing page for bus operators.
 */
@WebServlet(name = "OperatorDashboardController", urlPatterns = {"/bus-operator/dashboard"})
public class OperatorDashboardController extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private final TripDAO tripDAO = new TripDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User currentUser = session != null ? (User) session.getAttribute("currentUser") : null;
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        List<Trip> upcomingTrips = tripDAO.findUpcomingTripsForOperator(currentUser.getUserId(), 20);
        long totalUpcomingTrips = upcomingTrips.size();
        long todayTripCount = upcomingTrips.stream()
                .map(Trip::getDepartureTime)
                .filter(Objects::nonNull)
                .filter(time -> time.toLocalDate().isEqual(LocalDate.now()))
                .count();
        int totalSeatCapacity = upcomingTrips.stream()
                .map(Trip::getVehicle)
                .filter(Objects::nonNull)
                .mapToInt(vehicle -> vehicle.getCapacity() != null ? vehicle.getCapacity() : 0)
                .sum();
        LocalDateTime nextDeparture = upcomingTrips.stream()
                .map(Trip::getDepartureTime)
                .filter(Objects::nonNull)
                .min(LocalDateTime::compareTo)
                .orElse(null);

        request.setAttribute("upcomingTrips", upcomingTrips);
        request.setAttribute("totalUpcomingTrips", totalUpcomingTrips);
        request.setAttribute("todayTripCount", todayTripCount);
        request.setAttribute("totalSeatCapacity", totalSeatCapacity);
        request.setAttribute("nextDeparture", nextDeparture);
        request.setAttribute("activeMenu", "dashboard");
        request.setAttribute("navbarHideSearch", Boolean.TRUE);
        request.setAttribute("navbarSearchPlaceholder", "Tìm chuyến đi...");

        request.getRequestDispatcher("/WEB-INF/busOperator/dashboard.jsp").forward(request, response);
    }

    @Override
    public String getServletInfo() {
        return "Bus operator dashboard controller";
    }
}
