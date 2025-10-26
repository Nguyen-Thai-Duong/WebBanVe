package DAO;

import DBContext.DBContext;
import dto.dashboard.MonthlyRevenue;
import dto.dashboard.PaymentMethodSummary;
import dto.dashboard.RouteSalesSummary;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Aggregation queries backing the admin dashboard and reporting pages.
 */
public class AdminDashboardDAO {

    private static final Logger LOGGER = Logger.getLogger(AdminDashboardDAO.class.getName());
    private static final DateTimeFormatter PERIOD_FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM");

    public BigDecimal calculateNetRevenue() {
        String sql = "SELECT COALESCE(SUM(CASE WHEN [Type] = 'Refund' THEN -Amount ELSE Amount END), 0) FROM PAYMENT";
        try (DBContext db = new DBContext()) {
            Connection conn = db.getConnection();
            if (conn == null) {
                LOGGER.severe("Database connection is null when calculating net revenue");
                return BigDecimal.ZERO;
            }
            try (PreparedStatement ps = conn.prepareStatement(sql);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    BigDecimal value = rs.getBigDecimal(1);
                    return value != null ? value : BigDecimal.ZERO;
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Failed to calculate net revenue", ex);
        }
        return BigDecimal.ZERO;
    }

    public BigDecimal calculateNetRevenueSince(LocalDateTime threshold) {
        if (threshold == null) {
            return calculateNetRevenue();
        }
        String sql = "SELECT COALESCE(SUM(CASE WHEN p.[Type] = 'Refund' THEN -p.Amount ELSE p.Amount END), 0) "
                + "FROM PAYMENT p INNER JOIN BOOKING b ON p.BookingID = b.BookingID WHERE b.BookingDate >= ?";
        try (DBContext db = new DBContext()) {
            Connection conn = db.getConnection();
            if (conn == null) {
                LOGGER.severe("Database connection is null when calculating period revenue");
                return BigDecimal.ZERO;
            }
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setTimestamp(1, Timestamp.valueOf(threshold));
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        BigDecimal value = rs.getBigDecimal(1);
                        return value != null ? value : BigDecimal.ZERO;
                    }
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Failed to calculate net revenue since " + threshold, ex);
        }
        return BigDecimal.ZERO;
    }

    public long countTripsUpcoming(int daysAhead) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM TRIP WHERE DepartureTime >= GETDATE()");
        if (daysAhead > 0) {
            sql.append(" AND DepartureTime < DATEADD(day, ?, GETDATE())");
        }
        try (DBContext db = new DBContext()) {
            Connection conn = db.getConnection();
            if (conn == null) {
                LOGGER.severe("Database connection is null when counting upcoming trips");
                return 0L;
            }
            try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
                if (daysAhead > 0) {
                    ps.setInt(1, daysAhead);
                }
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        return rs.getLong(1);
                    }
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Failed to count upcoming trips", ex);
        }
        return 0L;
    }

    public long countTotalTrips() {
        String sql = "SELECT COUNT(*) FROM TRIP";
        try (DBContext db = new DBContext()) {
            Connection conn = db.getConnection();
            if (conn == null) {
                LOGGER.severe("Database connection is null when counting trips");
                return 0L;
            }
            try (PreparedStatement ps = conn.prepareStatement(sql);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getLong(1);
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Failed to count trips", ex);
        }
        return 0L;
    }

    public long countUsersByRole(String role) {
        String sql = "SELECT COUNT(*) FROM [USER] WHERE Role = ?";
        try (DBContext db = new DBContext()) {
            Connection conn = db.getConnection();
            if (conn == null) {
                LOGGER.log(Level.SEVERE, "Database connection is null when counting users for role {0}", role);
                return 0L;
            }
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, role);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        return rs.getLong(1);
                    }
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Failed to count users for role " + role, ex);
        }
        return 0L;
    }

    public List<MonthlyRevenue> fetchRevenueByMonth(int months) {
        int limit = months > 0 ? months : 6;
        String sql = "SELECT TOP " + limit + " YEAR(b.BookingDate) AS [Year], MONTH(b.BookingDate) AS [Month], "
                + "SUM(CASE WHEN p.[Type] = 'Refund' THEN -p.Amount ELSE p.Amount END) AS NetAmount "
                + "FROM PAYMENT p INNER JOIN BOOKING b ON p.BookingID = b.BookingID "
                + "WHERE b.BookingDate IS NOT NULL "
                + "GROUP BY YEAR(b.BookingDate), MONTH(b.BookingDate) "
                + "ORDER BY YEAR(b.BookingDate) DESC, MONTH(b.BookingDate) DESC";

        try (DBContext db = new DBContext()) {
            Connection conn = db.getConnection();
            if (conn == null) {
                LOGGER.severe("Database connection is null when loading monthly revenue");
                return Collections.emptyList();
            }
            try (PreparedStatement ps = conn.prepareStatement(sql);
                 ResultSet rs = ps.executeQuery()) {
                List<MonthlyRevenue> list = new ArrayList<>();
                while (rs.next()) {
                    int year = rs.getInt("Year");
                    int month = rs.getInt("Month");
                    BigDecimal amount = rs.getBigDecimal("NetAmount");
                    MonthlyRevenue entry = new MonthlyRevenue();
                    entry.setPeriod(LocalDate.of(year, month, 1).format(PERIOD_FORMATTER));
                    entry.setAmount(amount != null ? amount : BigDecimal.ZERO);
                    list.add(entry);
                }
                return list;
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Failed to load monthly revenue", ex);
            return Collections.emptyList();
        }
    }

    public List<PaymentMethodSummary> fetchRevenueByMethod(int daysBack) {
        StringBuilder sql = new StringBuilder()
                .append("SELECT [Method], SUM(CASE WHEN p.[Type] = 'Refund' THEN -p.Amount ELSE p.Amount END) AS NetAmount "
                        + "FROM PAYMENT p INNER JOIN BOOKING b ON p.BookingID = b.BookingID ");
        if (daysBack > 0) {
            sql.append("WHERE b.BookingDate >= DATEADD(day, ?, GETDATE()) ");
        }
        sql.append("GROUP BY [Method] ORDER BY NetAmount DESC");

        try (DBContext db = new DBContext()) {
            Connection conn = db.getConnection();
            if (conn == null) {
                LOGGER.severe("Database connection is null when loading payment summaries");
                return Collections.emptyList();
            }
            try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
                if (daysBack > 0) {
                    ps.setInt(1, -Math.abs(daysBack));
                }
                try (ResultSet rs = ps.executeQuery()) {
                    List<PaymentMethodSummary> list = new ArrayList<>();
                    while (rs.next()) {
                        PaymentMethodSummary summary = new PaymentMethodSummary();
                        summary.setMethod(rs.getString("Method"));
                        BigDecimal amount = rs.getBigDecimal("NetAmount");
                        summary.setNetAmount(amount != null ? amount : BigDecimal.ZERO);
                        list.add(summary);
                    }
                    return list;
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Failed to load revenue by payment method", ex);
            return Collections.emptyList();
        }
    }

    public List<RouteSalesSummary> fetchTopRouteSales(int limit, int daysBack) {
        int top = limit > 0 ? limit : 5;
        StringBuilder sql = new StringBuilder()
                .append("SELECT TOP ").append(top)
                .append(" route.Origin, route.Destination, COUNT(*) AS TicketCount "
                        + "FROM BOOKING b INNER JOIN TRIP trip ON b.TripID = trip.TripID "
                        + "INNER JOIN ROUTE route ON trip.RouteID = route.RouteID ");
        List<Object> params = new ArrayList<>();
        sql.append("WHERE b.SeatNumber IS NOT NULL AND (b.BookingStatus IS NULL OR b.BookingStatus <> 'Cancelled') ");
        if (daysBack > 0) {
            sql.append("AND b.BookingDate >= DATEADD(day, ?, GETDATE()) ");
            params.add(-Math.abs(daysBack));
        }
        sql.append("GROUP BY route.Origin, route.Destination ORDER BY TicketCount DESC, route.Origin ASC");

        try (DBContext db = new DBContext()) {
            Connection conn = db.getConnection();
            if (conn == null) {
                LOGGER.severe("Database connection is null when loading route sales");
                return Collections.emptyList();
            }
            try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
                for (int i = 0; i < params.size(); i++) {
                    ps.setObject(i + 1, params.get(i));
                }
                try (ResultSet rs = ps.executeQuery()) {
                    List<RouteSalesSummary> list = new ArrayList<>();
                    while (rs.next()) {
                        RouteSalesSummary summary = new RouteSalesSummary();
                        summary.setOrigin(rs.getString("Origin"));
                        summary.setDestination(rs.getString("Destination"));
                        summary.setTicketCount(rs.getLong("TicketCount"));
                        list.add(summary);
                    }
                    return list;
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Failed to load route sales summary", ex);
            return Collections.emptyList();
        }
    }
}
