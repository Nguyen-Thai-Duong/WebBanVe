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
            + "r.Origin, r.Destination, r.Distance, "
            + "v.LicensePlate, v.Model, v.Capacity, "
            + "u.FullName AS OperatorName, u.Email AS OperatorEmail, u.EmployeeCode "
            + "FROM TRIP t "
            + "INNER JOIN ROUTE r ON t.RouteID = r.RouteID "
            + "INNER JOIN VEHICLE v ON t.VehicleID = v.VehicleID "
            + "INNER JOIN [USER] u ON t.OperatorID = u.UserID";

    public List<Trip> findAll() {
        String sql = BASE_SELECT + " ORDER BY t.DepartureTime DESC";
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
        String sql = "SELECT RouteID, Origin, Destination, Distance FROM ROUTE ORDER BY Origin, Destination";
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
                routes.add(route);
            }
            return routes;
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Failed to load routes", ex);
            return Collections.emptyList();
        }
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
        trip.setDepartureTime(toLocalDateTime(rs.getTimestamp("DepartureTime")));
        trip.setArrivalTime(toLocalDateTime(rs.getTimestamp("ArrivalTime")));
        trip.setPrice(rs.getBigDecimal("Price"));
        trip.setTripStatus(rs.getString("TripStatus"));

        Route route = new Route();
        route.setRouteId(rs.getInt("RouteID"));
        route.setOrigin(rs.getString("Origin"));
        route.setDestination(rs.getString("Destination"));
        route.setDistance(rs.getBigDecimal("Distance"));
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

        return trip;
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
