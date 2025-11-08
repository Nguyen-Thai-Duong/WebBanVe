package DAO;

import DBContext.DBContext;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.sql.Types;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import model.Route;
import model.Trip;
import model.User;
import model.Vehicle;

/**
 * Data access layer for Trip management using plain JDBC.
 */
public class TripDAO {

    private static final Logger LOGGER = Logger.getLogger(TripDAO.class.getName());

    private static final String BASE_SELECT = "SELECT "
            + "t.TripID, t.RouteID, t.DepartureTime, t.ArrivalTime, t.Price, t.VehicleID, t.OperatorID, t.TripStatus, "
            + "r.Origin, r.Destination, r.Distance, r.DurationMinutes, r.RouteStatus, "
            + "v.LicensePlate, v.Model, v.Capacity, "
            + "u.FullName AS OperatorName, u.Email AS OperatorEmail, u.EmployeeCode "
            + "FROM TRIP t "
            + "INNER JOIN ROUTE r ON t.RouteID = r.RouteID "
            + "INNER JOIN VEHICLE v ON t.VehicleID = v.VehicleID "
            + "INNER JOIN [USER] u ON t.OperatorID = u.UserID";

    public List<Trip> searchTrips(String origin, String destination, LocalDateTime searchDate) {
        List<String> conditions = new ArrayList<>();
        List<Object> parameters = new ArrayList<>();

        if (origin != null && !origin.isEmpty()) {
            conditions.add("r.Origin LIKE ?");
            parameters.add("%" + origin + "%");
        }

        if (destination != null && !destination.isEmpty()) {
            conditions.add("r.Destination LIKE ?");
            parameters.add("%" + destination + "%");
        }

        if (searchDate != null) {
            conditions.add("CONVERT(date, t.DepartureTime) = CONVERT(date, ?)");
            parameters.add(Timestamp.valueOf(searchDate));
        }

        // Only show upcoming trips
        conditions.add("t.DepartureTime >= ?");
        parameters.add(Timestamp.valueOf(LocalDateTime.now()));

        // Only show active trips and routes
        conditions.add("t.TripStatus = 'Available'");
        conditions.add("r.RouteStatus = 'Active'");

        String sql = BASE_SELECT;
        if (!conditions.isEmpty()) {
            sql += " WHERE " + String.join(" AND ", conditions);
        }
        sql += " ORDER BY t.DepartureTime ASC";

        try (DBContext db = new DBContext()) {
            Connection conn = db.getConnection();
            if (conn == null) {
                LOGGER.log(Level.SEVERE, "Database connection is null when searching trips");
                return Collections.emptyList();
            }
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                for (int i = 0; i < parameters.size(); i++) {
                    if (parameters.get(i) instanceof String) {
                        ps.setString(i + 1, (String) parameters.get(i));
                    } else if (parameters.get(i) instanceof Timestamp) {
                        ps.setTimestamp(i + 1, (Timestamp) parameters.get(i));
                    }
                }
                try (ResultSet rs = ps.executeQuery()) {
                    List<Trip> trips = new ArrayList<>();
                    while (rs.next()) {
                        trips.add(mapTrip(rs));
                    }
                    return trips;
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Failed to search trips", ex);
            return Collections.emptyList();
        }
    }

    public List<Trip> findAll() {
        String sql = BASE_SELECT + " ORDER BY t.DepartureTime ASC";
        try (DBContext db = new DBContext()) {
            Connection conn = db.getConnection();
            if (conn == null) {
                LOGGER.log(Level.SEVERE, "Database connection is null when loading trips");
                return Collections.emptyList();
            }
            try (PreparedStatement ps = conn.prepareStatement(sql);
                    ResultSet rs = ps.executeQuery()) {
                List<Trip> trips = new ArrayList<>();
                while (rs.next()) {
                    trips.add(mapTrip(rs));
                }
                return trips;
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Failed to load trips", ex);
            return Collections.emptyList();
        }
    }

    public Trip findById(int tripId) {
        String sql = BASE_SELECT + " WHERE t.TripID = ?";
        try (DBContext db = new DBContext()) {
            Connection conn = db.getConnection();
            if (conn == null) {
                LOGGER.log(Level.SEVERE, "Database connection is null when loading trip id {0}", tripId);
                return null;
            }
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, tripId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        return mapTrip(rs);
                    }
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Failed to find trip with id " + tripId, ex);
        }
        return null;
    }

    public boolean insert(Trip trip) {
        String sql = "INSERT INTO TRIP (RouteID, DepartureTime, ArrivalTime, Price, VehicleID, OperatorID, TripStatus) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (DBContext db = new DBContext()) {
            Connection conn = db.getConnection();
            if (conn == null) {
                LOGGER.log(Level.SEVERE, "Database connection is null when inserting trip");
                return false;
            }
            try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
                mapStatement(ps, trip);
                int affected = ps.executeUpdate();
                if (affected > 0) {
                    try (ResultSet keys = ps.getGeneratedKeys()) {
                        if (keys.next()) {
                            trip.setTripId(keys.getInt(1));
                        }
                    }
                }
                return affected > 0;
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Failed to insert trip", ex);
            return false;
        }
    }

    public boolean update(Trip trip) {
        if (trip.getTripId() == null) {
            throw new IllegalArgumentException("Trip ID is required for update");
        }
        String sql = "UPDATE TRIP SET RouteID = ?, DepartureTime = ?, ArrivalTime = ?, Price = ?, "
                + "VehicleID = ?, OperatorID = ?, TripStatus = ? WHERE TripID = ?";
        try (DBContext db = new DBContext()) {
            Connection conn = db.getConnection();
            if (conn == null) {
                LOGGER.log(Level.SEVERE, "Database connection is null when updating trip id {0}", trip.getTripId());
                return false;
            }
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                mapStatement(ps, trip);
                ps.setInt(8, trip.getTripId());
                return ps.executeUpdate() > 0;
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Failed to update trip with id " + trip.getTripId(), ex);
            return false;
        }
    }

    public boolean delete(int tripId) {
        String sql = "DELETE FROM TRIP WHERE TripID = ?";
        try (DBContext db = new DBContext()) {
            Connection conn = db.getConnection();
            if (conn == null) {
                LOGGER.log(Level.SEVERE, "Database connection is null when deleting trip id {0}", tripId);
                return false;
            }
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, tripId);
                return ps.executeUpdate() > 0;
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Failed to delete trip with id " + tripId, ex);
            return false;
        }
    }

    public List<Route> findRoutes() {
        String sql = "SELECT r.RouteID, r.Origin, r.Destination, r.Distance, r.DurationMinutes, r.RouteStatus, "
                + "COALESCE(tc.TotalTrips, 0) AS TripCount FROM ROUTE r "
                + "LEFT JOIN (SELECT RouteID, COUNT(*) AS TotalTrips FROM TRIP GROUP BY RouteID) tc "
                + "ON r.RouteID = tc.RouteID ORDER BY r.Origin, r.Destination";
        try (DBContext db = new DBContext()) {
            Connection conn = db.getConnection();
            if (conn == null) {
                LOGGER.log(Level.SEVERE, "Database connection is null when loading routes");
                return Collections.emptyList();
            }
            try (PreparedStatement ps = conn.prepareStatement(sql);
                    ResultSet rs = ps.executeQuery()) {
                List<Route> routes = new ArrayList<>();
                while (rs.next()) {
                    Route route = new Route();
                    route.setRouteId(rs.getInt("RouteID"));
                    route.setOrigin(rs.getString("Origin"));
                    route.setDestination(rs.getString("Destination"));
                    route.setDistance(rs.getBigDecimal("Distance"));
                    int duration = rs.getInt("DurationMinutes");
                    boolean durationIsNull = rs.wasNull();
                    route.setDurationMinutes(durationIsNull ? null : duration);
                    route.setRouteStatus(rs.getString("RouteStatus"));
                    route.setTripCount(rs.getInt("TripCount"));
                    routes.add(route);
                }
                return routes;
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Failed to load routes", ex);
            return Collections.emptyList();
        }
    }

    public int countTripsByRoute(int routeId, Integer excludeTripId) {
        String sql = "SELECT COUNT(*) FROM TRIP WHERE RouteID = ?" + (excludeTripId != null ? " AND TripID <> ?" : "");
        try (DBContext db = new DBContext()) {
            Connection conn = db.getConnection();
            if (conn == null) {
                LOGGER.log(Level.SEVERE, "Database connection is null when counting trips for route {0}", routeId);
                return 0;
            }
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, routeId);
                if (excludeTripId != null) {
                    ps.setInt(2, excludeTripId);
                }
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        return rs.getInt(1);
                    }
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Failed to count trips for route " + routeId, ex);
        }
        return 0;
    }

    public List<Vehicle> findVehicles() {
        String sql = "SELECT VehicleID, LicensePlate, Model, Capacity FROM VEHICLE ORDER BY LicensePlate";
        try (DBContext db = new DBContext()) {
            Connection conn = db.getConnection();
            if (conn == null) {
                LOGGER.log(Level.SEVERE, "Database connection is null when loading vehicles");
                return Collections.emptyList();
            }
            try (PreparedStatement ps = conn.prepareStatement(sql);
                    ResultSet rs = ps.executeQuery()) {
                List<Vehicle> vehicles = new ArrayList<>();
                while (rs.next()) {
                    Vehicle vehicle = new Vehicle();
                    vehicle.setVehicleId(rs.getInt("VehicleID"));
                    vehicle.setLicensePlate(rs.getString("LicensePlate"));
                    vehicle.setModel(rs.getString("Model"));
                    vehicle.setCapacity(rs.getInt("Capacity"));
                    vehicles.add(vehicle);
                }
                return vehicles;
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Failed to load vehicles", ex);
            return Collections.emptyList();
        }
    }

    public List<User> findOperators() {
        String sql = "SELECT UserID, EmployeeCode, FullName, Email FROM [USER] "
                + "WHERE Role = 'BusOperator' ORDER BY FullName";
        try (DBContext db = new DBContext()) {
            Connection conn = db.getConnection();
            if (conn == null) {
                LOGGER.log(Level.SEVERE, "Database connection is null when loading operators");
                return Collections.emptyList();
            }
            try (PreparedStatement ps = conn.prepareStatement(sql);
                    ResultSet rs = ps.executeQuery()) {
                List<User> operators = new ArrayList<>();
                while (rs.next()) {
                    User user = new User();
                    user.setUserId(rs.getInt("UserID"));
                    user.setEmployeeCode(rs.getString("EmployeeCode"));
                    user.setFullName(rs.getString("FullName"));
                    user.setEmail(rs.getString("Email"));
                    operators.add(user);
                }
                return operators;
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Failed to load bus operators", ex);
            return Collections.emptyList();
        }
    }

    private void mapStatement(PreparedStatement ps, Trip trip) throws SQLException {
        ps.setInt(1, trip.getRoute().getRouteId());
        setTimestamp(ps, 2, trip.getDepartureTime());
        setTimestamp(ps, 3, trip.getArrivalTime());
        ps.setBigDecimal(4, safePrice(trip.getPrice()));
        ps.setInt(5, trip.getVehicle().getVehicleId());
        ps.setInt(6, trip.getOperator().getUserId());
        ps.setString(7, trip.getTripStatus());
    }

    private Trip mapTrip(ResultSet rs) throws SQLException {
        Trip trip = new Trip();
        trip.setTripId(rs.getInt("TripID"));
        LocalDateTime departure = toLocalDateTime(rs.getTimestamp("DepartureTime"));
        LocalDateTime arrival = toLocalDateTime(rs.getTimestamp("ArrivalTime"));
        trip.setDepartureTime(departure);
        trip.setArrivalTime(arrival);
        trip.setPrice(rs.getBigDecimal("Price"));
        trip.setTripStatus(rs.getString("TripStatus"));

        Route route = new Route();
        route.setRouteId(rs.getInt("RouteID"));
        route.setOrigin(rs.getString("Origin"));
        route.setDestination(rs.getString("Destination"));
        route.setDistance(rs.getBigDecimal("Distance"));
        int duration = rs.getInt("DurationMinutes");
        boolean durationIsNull = rs.wasNull();
        route.setDurationMinutes(durationIsNull ? null : duration);
        String routeStatus = rs.getString("RouteStatus");
        route.setRouteStatus(routeStatus != null && !routeStatus.isBlank() ? routeStatus : "Active");
        trip.setRoute(route);

        Vehicle vehicle = new Vehicle();
        vehicle.setVehicleId(rs.getInt("VehicleID"));
        vehicle.setLicensePlate(rs.getString("LicensePlate"));
        vehicle.setModel(rs.getString("Model"));
        vehicle.setCapacity(rs.getInt("Capacity"));
        trip.setVehicle(vehicle);

        User operator = new User();
        operator.setUserId(rs.getInt("OperatorID"));
        operator.setFullName(rs.getString("OperatorName"));
        operator.setEmail(rs.getString("OperatorEmail"));
        operator.setEmployeeCode(rs.getString("EmployeeCode"));
        trip.setOperator(operator);

        if (trip.getArrivalTime() == null && route.getDurationMinutes() != null && departure != null) {
            trip.setArrivalTime(departure.plusMinutes(route.getDurationMinutes()));
        }

        return trip;
    }

    /**
     * Loads upcoming trips assigned to a specific operator, ordered by departure
     * time.
     * Only trips with departure time after the provided threshold (default now - 1
     * day) are returned.
     *
     * @param operatorId the operator (user) identifier
     * @param maxResults maximum number of trips to return, pass a value <= 0 for no
     *                   limit
     * @return list of upcoming trips for the operator
     */
    public List<Trip> findUpcomingTripsForOperator(int operatorId, int maxResults) {
        LocalDateTime threshold = LocalDateTime.now().minusDays(1);
        String sql = BASE_SELECT
                + " WHERE t.OperatorID = ? AND t.DepartureTime >= ?"
                + " ORDER BY t.DepartureTime ASC";

        try (DBContext db = new DBContext()) {
            Connection conn = db.getConnection();
            if (conn == null) {
                LOGGER.log(Level.SEVERE, "Database connection is null when loading trips for operator {0}", operatorId);
                return Collections.emptyList();
            }
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, operatorId);
                ps.setTimestamp(2, Timestamp.valueOf(threshold));
                try (ResultSet rs = ps.executeQuery()) {
                    List<Trip> trips = new ArrayList<>();
                    while (rs.next()) {
                        trips.add(mapTrip(rs));
                        if (maxResults > 0 && trips.size() >= maxResults) {
                            break;
                        }
                    }
                    return trips;
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Failed to load upcoming trips for operator " + operatorId, ex);
            return Collections.emptyList();
        }
    }

    public int countUpcomingTripsByOperator(int operatorId, LocalDateTime from) {
        String sql = "SELECT COUNT(*) FROM TRIP WHERE OperatorID = ? AND DepartureTime >= ?";
        try (DBContext db = new DBContext()) {
            Connection conn = db.getConnection();
            if (conn == null) {
                LOGGER.log(Level.SEVERE, "Database connection is null when counting upcoming trips for operator {0}",
                        operatorId);
                return 0;
            }
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, operatorId);
                ps.setTimestamp(2, Timestamp.valueOf(from));
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        return rs.getInt(1);
                    }
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Failed to count upcoming trips for operator " + operatorId, ex);
        }
        return 0;
    }

    private void setTimestamp(PreparedStatement ps, int index, LocalDateTime value) throws SQLException {
        if (value != null) {
            ps.setTimestamp(index, Timestamp.valueOf(value));
        } else {
            ps.setNull(index, Types.TIMESTAMP);
        }
    }

    private LocalDateTime toLocalDateTime(Timestamp timestamp) {
        return timestamp != null ? timestamp.toLocalDateTime() : null;
    }

    private BigDecimal safePrice(BigDecimal price) {
        return price != null ? price : BigDecimal.ZERO;
    }
}
