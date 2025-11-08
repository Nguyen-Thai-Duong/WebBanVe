package DAO;

import DBContext.DBContext;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Set;
import model.Route;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class RouteDAOImpl {
    private static final Logger LOGGER = LoggerFactory.getLogger(RouteDAOImpl.class);
    private static final Set<String> ALLOWED_STATUSES = Set.of("Active", "Inactive");

    public List<Route> getRoutesByOperatorId(Integer operatorId) {
        if (operatorId == null) {
            return Collections.emptyList();
        }

        final String sql = "SELECT r.RouteID, r.Origin, r.Destination, r.Distance, "
                + "r.DurationMinutes, r.RouteStatus, r.OperatorID, COALESCE(tc.TotalTrips, 0) AS TripCount "
                + "FROM ROUTE r LEFT JOIN (SELECT RouteID, COUNT(*) AS TotalTrips FROM TRIP GROUP BY RouteID) tc "
                + "ON r.RouteID = tc.RouteID "
                + "WHERE r.OperatorID = ? ORDER BY r.Origin, r.Destination";

        List<Route> routes = new ArrayList<>();

        try (DBContext db = new DBContext()) {
            Connection conn = db.getConnection();
            if (conn == null) {
                LOGGER.error("Database connection is null when loading routes for operator {}", operatorId);
                return Collections.emptyList();
            }

            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, operatorId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Route route = mapRoute(rs);
                        routes.add(route);
                    }
                }
            }
        } catch (SQLException ex) {
            LOGGER.error("Failed to load routes for operator {}", operatorId, ex);
            return Collections.emptyList();
        }

        return routes;
    }

    public Route getRouteById(int routeId) {
        final String sql = "SELECT r.RouteID, r.Origin, r.Destination, r.Distance, "
                + "r.DurationMinutes, r.RouteStatus, r.OperatorID, COALESCE(tc.TotalTrips, 0) AS TripCount "
                + "FROM ROUTE r LEFT JOIN (SELECT RouteID, COUNT(*) AS TotalTrips FROM TRIP GROUP BY RouteID) tc "
                + "ON r.RouteID = tc.RouteID WHERE r.RouteID = ?";

        try (DBContext db = new DBContext()) {
            Connection conn = db.getConnection();
            if (conn == null) {
                LOGGER.error("Database connection is null when fetching route {}", routeId);
                return null;
            }

            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, routeId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        return mapRoute(rs);
                    }
                }
            }
        } catch (SQLException ex) {
            LOGGER.error("Failed to fetch route {}", routeId, ex);
        }

        return null;
    }

    public boolean addRoute(Route route) {
        if (route == null || route.getOperatorId() == null) {
            return false;
        }

        final String sql = "INSERT INTO ROUTE (Origin, Destination, Distance, DurationMinutes, RouteStatus, OperatorID) "
                + "VALUES (?, ?, ?, ?, ?, ?)";

        try (DBContext db = new DBContext()) {
            Connection conn = db.getConnection();
            if (conn == null) {
                LOGGER.error("Database connection is null when adding route");
                return false;
            }

            try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
                ps.setString(1, route.getOrigin());
                ps.setString(2, route.getDestination());
                ps.setBigDecimal(3, route.getDistance());
                ps.setInt(4, route.getDurationMinutes());
                ps.setString(5, route.getRouteStatus() != null ? route.getRouteStatus() : "Active");
                ps.setInt(6, route.getOperatorId());

                int affected = ps.executeUpdate();
                if (affected > 0) {
                    try (ResultSet rs = ps.getGeneratedKeys()) {
                        if (rs.next()) {
                            route.setRouteId(rs.getInt(1));
                        }
                    }
                    return true;
                }
            }
        } catch (SQLException ex) {
            LOGGER.error("Failed to add route", ex);
        }

        return false;
    }

    public boolean updateRoute(Route route) {
        if (route == null || route.getRouteId() == null || route.getOperatorId() == null) {
            return false;
        }

        final String sql = "UPDATE ROUTE SET Origin = ?, Destination = ?, Distance = ?, DurationMinutes = ? "
                + "WHERE RouteID = ? AND OperatorID = ?";

        try (DBContext db = new DBContext()) {
            Connection conn = db.getConnection();
            if (conn == null) {
                LOGGER.error("Database connection is null when updating route {}", route.getRouteId());
                return false;
            }

            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, route.getOrigin());
                ps.setString(2, route.getDestination());
                ps.setBigDecimal(3, route.getDistance());
                ps.setInt(4, route.getDurationMinutes());
                ps.setInt(5, route.getRouteId());
                ps.setInt(6, route.getOperatorId());

                return ps.executeUpdate() > 0;
            }
        } catch (SQLException ex) {
            LOGGER.error("Failed to update route {}", route.getRouteId(), ex);
        }

        return false;
    }

    public boolean updateRouteStatus(int routeId, String status) {
        if (!ALLOWED_STATUSES.contains(status)) {
            LOGGER.error("Invalid route status: {}", status);
            return false;
        }

        final String sql = "UPDATE ROUTE SET RouteStatus = ? WHERE RouteID = ?";

        try (DBContext db = new DBContext()) {
            Connection conn = db.getConnection();
            if (conn == null) {
                LOGGER.error("Database connection is null when updating route {} status", routeId);
                return false;
            }

            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, status);
                ps.setInt(2, routeId);
                return ps.executeUpdate() > 0;
            }
        } catch (SQLException ex) {
            LOGGER.error("Failed to update route {} status", routeId, ex);
        }

        return false;
    }

    public boolean deleteRoute(int routeId) {
        final String sql = "DELETE FROM ROUTE WHERE RouteID = ? "
                + "AND NOT EXISTS (SELECT 1 FROM TRIP WHERE RouteID = ?)";

        try (DBContext db = new DBContext()) {
            Connection conn = db.getConnection();
            if (conn == null) {
                LOGGER.error("Database connection is null when deleting route {}", routeId);
                return false;
            }

            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, routeId);
                ps.setInt(2, routeId);
                return ps.executeUpdate() > 0;
            }
        } catch (SQLException ex) {
            LOGGER.error("Failed to delete route {}", routeId, ex);
        }

        return false;
    }

    private Route mapRoute(ResultSet rs) throws SQLException {
        Route route = new Route();
        route.setRouteId(rs.getInt("RouteID"));
        route.setOrigin(rs.getString("Origin"));
        route.setDestination(rs.getString("Destination"));
        route.setDistance(rs.getBigDecimal("Distance"));
        route.setDurationMinutes(rs.getInt("DurationMinutes"));
        route.setRouteStatus(rs.getString("RouteStatus"));
        route.setOperatorId(rs.getInt("OperatorID"));
        route.setTripCount(rs.getInt("TripCount"));
        return route;
    }
}