package DAO;

import DBContext.DBContext;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Types;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import model.Route;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Data access object dedicated to route management.
 */
public class RouteDAO {

    private static final Logger LOGGER = LoggerFactory.getLogger(RouteDAO.class);

    private static final String BASE_SELECT = "SELECT RouteID, Origin, Destination, Distance FROM ROUTE";

    public List<Route> findAll() {
        String sql = BASE_SELECT + " ORDER BY Origin, Destination";
        try (DBContext db = new DBContext()) {
            Connection conn = db.getConnection();
            if (conn == null) {
                LOGGER.error("Database connection is null when loading routes");
                return Collections.emptyList();
            }
            try (PreparedStatement ps = conn.prepareStatement(sql);
                    ResultSet rs = ps.executeQuery()) {
                List<Route> routes = new ArrayList<>();
                while (rs.next()) {
                    routes.add(mapRoute(rs));
                }
                return routes;
            }
        } catch (SQLException ex) {
            LOGGER.error("Failed to load routes", ex);
            return Collections.emptyList();
        }
    }

    public Route findById(int routeId) {
        String sql = BASE_SELECT + " WHERE RouteID = ?";
        try (DBContext db = new DBContext()) {
            Connection conn = db.getConnection();
            if (conn == null) {
                LOGGER.error("Database connection is null when finding route id {}", routeId);
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
            LOGGER.error("Failed to find route with id {}", routeId, ex);
        }
        return null;
    }

    public boolean insert(Route route) {
        String sql = "INSERT INTO ROUTE (Origin, Destination, Distance) VALUES (?, ?, ?)";
        try (DBContext db = new DBContext()) {
            Connection conn = db.getConnection();
            if (conn == null) {
                LOGGER.error("Database connection is null when inserting route");
                return false;
            }
            try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
                int idx = 1;
                ps.setString(idx++, route.getOrigin());
                ps.setString(idx++, route.getDestination());
                setNullableDecimal(ps, idx, route.getDistance());
                int affected = ps.executeUpdate();
                if (affected > 0) {
                    try (ResultSet keys = ps.getGeneratedKeys()) {
                        if (keys.next()) {
                            route.setRouteId(keys.getInt(1));
                        }
                    }
                }
                return affected > 0;
            }
        } catch (SQLException ex) {
            LOGGER.error("Failed to insert route", ex);
            return false;
        }
    }

    public boolean update(Route route) {
        if (route.getRouteId() == null) {
            throw new IllegalArgumentException("Route ID is required for update");
        }
        String sql = "UPDATE ROUTE SET Origin = ?, Destination = ?, Distance = ? WHERE RouteID = ?";
        try (DBContext db = new DBContext()) {
            Connection conn = db.getConnection();
            if (conn == null) {
                LOGGER.error("Database connection is null when updating route id {}", route.getRouteId());
                return false;
            }
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                int idx = 1;
                ps.setString(idx++, route.getOrigin());
                ps.setString(idx++, route.getDestination());
                setNullableDecimal(ps, idx++, route.getDistance());
                ps.setInt(idx, route.getRouteId());
                return ps.executeUpdate() > 0;
            }
        } catch (SQLException ex) {
            LOGGER.error("Failed to update route with id {}", route.getRouteId(), ex);
            return false;
        }
    }

    public boolean delete(int routeId) {
        String sql = "DELETE FROM ROUTE WHERE RouteID = ?";
        try (DBContext db = new DBContext()) {
            Connection conn = db.getConnection();
            if (conn == null) {
                LOGGER.error("Database connection is null when deleting route id {}", routeId);
                return false;
            }
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, routeId);
                return ps.executeUpdate() > 0;
            }
        } catch (SQLException ex) {
            LOGGER.error("Failed to delete route with id {}", routeId, ex);
            return false;
        }
    }

    private Route mapRoute(ResultSet rs) throws SQLException {
        Route route = new Route();
        route.setRouteId(rs.getInt("RouteID"));
        route.setOrigin(rs.getString("Origin"));
        route.setDestination(rs.getString("Destination"));
        route.setDistance(rs.getBigDecimal("Distance"));
        return route;
    }

    private void setNullableDecimal(PreparedStatement ps, int index, BigDecimal value) throws SQLException {
        if (value != null) {
            ps.setBigDecimal(index, value);
        } else {
            ps.setNull(index, Types.DECIMAL);
        }
    }
}
