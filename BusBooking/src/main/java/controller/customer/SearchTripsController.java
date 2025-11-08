package controller.customer;

import DAO.TripDAO;
import DAO.BookingDAO;
import java.io.IOException;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Trip;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@WebServlet(name = "SearchTripsController", urlPatterns = { "/trips/search", "/trips/details/*" })
public class SearchTripsController extends HttpServlet {

    private static final Logger LOGGER = LoggerFactory.getLogger(SearchTripsController.class);
    private final TripDAO tripDAO = new TripDAO();
    private final BookingDAO bookingDAO = new BookingDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String pathInfo = request.getPathInfo();

        if (pathInfo != null && pathInfo.startsWith("/details/")) {
            // Handle trip details
            String tripIdStr = pathInfo.substring("/details/".length());
            try {
                int tripId = Integer.parseInt(tripIdStr);
                handleTripDetails(request, response, tripId);
            } catch (NumberFormatException e) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid trip ID");
            }
        } else {
            // Handle search
            handleSearch(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Handle search from form submission
        handleSearch(request, response);
    }

    private void handleSearch(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String departure = request.getParameter("departure");
        String destination = request.getParameter("destination");
        String dateStr = request.getParameter("departureDate");
        String passengers = request.getParameter("passengers");

        List<Trip> trips;
        if (departure != null || destination != null || dateStr != null) {
            LocalDateTime searchDate = null;
            if (dateStr != null && !dateStr.isEmpty()) {
                try {
                    searchDate = LocalDate.parse(dateStr).atStartOfDay();
                } catch (Exception e) {
                    LOGGER.warn("Invalid date format: {}", dateStr);
                }
            }

            trips = tripDAO.searchTrips(departure, destination, searchDate);
        } else {
            // No search criteria, show upcoming trips
            trips = tripDAO.findAll();
            LocalDateTime now = LocalDateTime.now();
            trips.removeIf(trip -> trip.getDepartureTime().isBefore(now));
        }

        request.setAttribute("trips", trips);
        request.setAttribute("departure", departure);
        request.setAttribute("destination", destination);
        request.setAttribute("departureDate", dateStr);
        request.setAttribute("passengers", passengers);

        request.getRequestDispatcher("/WEB-INF/customer/search-trips.jsp").forward(request, response);
    }

    private void handleTripDetails(HttpServletRequest request, HttpServletResponse response, int tripId)
            throws ServletException, IOException {
        Trip trip = tripDAO.findById(tripId);
        if (trip == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Trip not found");
            return;
        }

        // Get seat map information
        List<String> bookedSeats = bookingDAO.findBookedSeatsForTrip(tripId);

        request.setAttribute("trip", trip);
        request.setAttribute("bookedSeats", bookedSeats);
        request.getRequestDispatcher("/WEB-INF/customer/trip-details.jsp").forward(request, response);
    }
}