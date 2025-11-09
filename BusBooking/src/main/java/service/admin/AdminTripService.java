package service.admin;

import DAO.TripDAO;
import DAO.RouteDAO;
import model.Trip;
import model.Route;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.Collections;
import java.util.List;

/**
 * Service layer for trip management in admin module.
 */
public class AdminTripService extends BaseAdminService {
    
    private static final Logger LOGGER = LoggerFactory.getLogger(AdminTripService.class);
    
    private final TripDAO tripDAO;
    private final RouteDAO routeDAO;
    
    public AdminTripService() {
        this.tripDAO = new TripDAO();
        this.routeDAO = new RouteDAO();
    }
    
    /**
     * Get all trips.
     */
    public List<Trip> getAllTrips() {
        List<Trip> trips = tripDAO.findAll();
        return trips != null ? trips : Collections.emptyList();
    }
    
    /**
     * Get trip by ID.
     */
    public Trip getTripById(Integer tripId) {
        if (tripId == null) {
            return null;
        }
        return tripDAO.findById(tripId);
    }
    
    /**
     * Get all active routes for selection.
     */
    public List<Route> getActiveRoutes() {
        List<Route> routes = routeDAO.findAll();
        return routes != null ? routes : Collections.emptyList();
    }
    
    /**
     * Create a new trip.
     */
    public boolean createTrip(Trip trip) {
        if (trip == null) {
            LOGGER.warn("Attempted to create null trip");
            return false;
        }
        return tripDAO.insert(trip);
    }
    
    /**
     * Update an existing trip.
     */
    public boolean updateTrip(Trip trip) {
        if (trip == null || trip.getTripId() == null) {
            LOGGER.warn("Attempted to update invalid trip");
            return false;
        }
        return tripDAO.update(trip);
    }
    
    /**
     * Delete a trip.
     */
    public boolean deleteTrip(Integer tripId) {
        if (tripId == null) {
            LOGGER.warn("Attempted to delete trip with null ID");
            return false;
        }
        return tripDAO.delete(tripId);
    }
}
