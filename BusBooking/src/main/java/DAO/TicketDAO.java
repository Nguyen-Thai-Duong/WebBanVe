package DAO;

import DBContext.DBContext;
import dto.ticket.TicketSummary;
import dto.ticket.TripOption;
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
import java.util.UUID;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Data access helper dedicated to ticket lifecycle operations for staff flows.
 */
public class TicketDAO {

    private static final Logger LOGGER = Logger.getLogger(TicketDAO.class.getName());
    private static final String DEFAULT_TICKET_STATUS = "Issued";
    private static final String DEFAULT_BOOKING_STATUS = "Confirmed";
    private static final String DEFAULT_SEAT_STATUS = "Booked";

    public List<TicketSummary> findTickets(String keyword, String status) {
        StringBuilder sql = new StringBuilder()
                .append("SELECT TOP 200 ")
                .append("t.TicketID, t.TicketNumber, t.TicketStatus, t.IssuedDate, t.CheckedInAt, ")
                .append("staff.FullName AS CheckedInByName, ")
                .append("b.BookingID, b.SeatNumber, b.SeatStatus, b.BookingStatus, b.TripID, ")
                .append("trip.DepartureTime, trip.ArrivalTime, route.Origin, route.Destination, ")
                .append("cust.FullName AS CustomerName, cust.Email AS CustomerEmail, cust.PhoneNumber AS CustomerPhone, ")
                .append("b.GuestEmail, b.GuestPhoneNumber ")
                .append("FROM TICKET t ")
                .append("JOIN BOOKING b ON t.BookingID = b.BookingID ")
                .append("JOIN TRIP trip ON b.TripID = trip.TripID ")
                .append("JOIN ROUTE route ON trip.RouteID = route.RouteID ")
                .append("LEFT JOIN [USER] cust ON b.UserID = cust.UserID ")
                .append("LEFT JOIN [USER] staff ON t.CheckedInBy = staff.UserID ");

        List<Object> params = new ArrayList<>();
        boolean hasWhere = false;
        if (status != null && !status.isBlank()) {
            sql.append("WHERE t.TicketStatus = ? ");
            params.add(status);
            hasWhere = true;
        }
        if (keyword != null && !keyword.isBlank()) {
            sql.append(hasWhere ? "AND " : "WHERE ")
                    .append("(t.TicketNumber LIKE ? OR b.SeatNumber LIKE ? OR cust.FullName LIKE ? OR cust.PhoneNumber LIKE ? OR b.GuestPhoneNumber LIKE ?) ");
            String pattern = "%" + keyword.trim() + "%";
            params.add(pattern);
            params.add(pattern);
            params.add(pattern);
            params.add(pattern);
            params.add(pattern);
        }
        sql.append("ORDER BY t.IssuedDate DESC, t.TicketID DESC");

        try (DBContext db = new DBContext()) {
            Connection conn = db.getConnection();
            if (conn == null) {
                LOGGER.log(Level.SEVERE, "Database connection is null when loading tickets");
                return Collections.emptyList();
            }
            try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
                for (int i = 0; i < params.size(); i++) {
                    ps.setObject(i + 1, params.get(i));
                }
                try (ResultSet rs = ps.executeQuery()) {
                    List<TicketSummary> results = new ArrayList<>();
                    while (rs.next()) {
                        results.add(mapTicket(rs));
                    }
                    return results;
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Failed to load tickets", ex);
            return Collections.emptyList();
        }
    }

    public TicketSummary findById(int ticketId) {
        String sql = "SELECT t.TicketID, t.TicketNumber, t.TicketStatus, t.IssuedDate, t.CheckedInAt, "
                + "staff.FullName AS CheckedInByName, b.BookingID, b.SeatNumber, b.SeatStatus, b.BookingStatus, b.TripID, "
                + "trip.DepartureTime, trip.ArrivalTime, route.Origin, route.Destination, "
                + "cust.FullName AS CustomerName, cust.Email AS CustomerEmail, cust.PhoneNumber AS CustomerPhone, "
                + "b.GuestEmail, b.GuestPhoneNumber "
                + "FROM TICKET t "
                + "JOIN BOOKING b ON t.BookingID = b.BookingID "
                + "JOIN TRIP trip ON b.TripID = trip.TripID "
                + "JOIN ROUTE route ON trip.RouteID = route.RouteID "
                + "LEFT JOIN [USER] cust ON b.UserID = cust.UserID "
                + "LEFT JOIN [USER] staff ON t.CheckedInBy = staff.UserID "
                + "WHERE t.TicketID = ?";
        try (DBContext db = new DBContext()) {
            Connection conn = db.getConnection();
            if (conn == null) {
                LOGGER.log(Level.SEVERE, "Database connection is null when loading ticket {0}", ticketId);
                return null;
            }
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, ticketId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        return mapTicket(rs);
                    }
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Failed to find ticket " + ticketId, ex);
        }
        return null;
    }

    public List<TicketSummary> findTicketsForCustomer(int customerId) {
        String sql = "SELECT t.TicketID, t.TicketNumber, t.TicketStatus, t.IssuedDate, t.CheckedInAt, "
                + "staff.FullName AS CheckedInByName, b.BookingID, b.SeatNumber, b.SeatStatus, b.BookingStatus, b.TripID, "
                + "trip.DepartureTime, trip.ArrivalTime, route.Origin, route.Destination, "
                + "cust.FullName AS CustomerName, cust.Email AS CustomerEmail, cust.PhoneNumber AS CustomerPhone, "
                + "b.GuestEmail, b.GuestPhoneNumber "
                + "FROM TICKET t "
                + "JOIN BOOKING b ON t.BookingID = b.BookingID "
                + "JOIN TRIP trip ON b.TripID = trip.TripID "
                + "JOIN ROUTE route ON trip.RouteID = route.RouteID "
                + "LEFT JOIN [USER] cust ON b.UserID = cust.UserID "
                + "LEFT JOIN [USER] staff ON t.CheckedInBy = staff.UserID "
                + "WHERE b.UserID = ? "
                + "ORDER BY trip.DepartureTime DESC, t.IssuedDate DESC";

        try (DBContext db = new DBContext()) {
            Connection conn = db.getConnection();
            if (conn == null) {
                LOGGER.log(Level.SEVERE, "Database connection is null when loading tickets for customer {0}", customerId);
                return Collections.emptyList();
            }
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, customerId);
                try (ResultSet rs = ps.executeQuery()) {
                    List<TicketSummary> results = new ArrayList<>();
                    while (rs.next()) {
                        results.add(mapTicket(rs));
                    }
                    return results;
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Failed to load tickets for customer " + customerId, ex);
            return Collections.emptyList();
        }
    }

    public Integer createPhysicalTicket(int tripId, Integer customerId, String guestPhone, String guestEmail, String seatNumber) {
        String insertBooking = "INSERT INTO BOOKING (TripID, UserID, GuestPhoneNumber, GuestEmail, BookingDate, BookingStatus, SeatNumber, SeatStatus) "
                + "VALUES (?, ?, ?, ?, GETDATE(), ?, ?, ?)";
        String insertTicket = "INSERT INTO TICKET (BookingID, TicketNumber, TicketStatus, IssuedDate) VALUES (?, ?, ?, GETDATE())";

        try (DBContext db = new DBContext()) {
            Connection conn = db.getConnection();
            if (conn == null) {
                LOGGER.log(Level.SEVERE, "Database connection is null when creating physical ticket");
                return null;
            }
            boolean previousAutoCommit = conn.getAutoCommit();
            conn.setAutoCommit(false);
            try (PreparedStatement bookingStmt = conn.prepareStatement(insertBooking, Statement.RETURN_GENERATED_KEYS)) {
                bookingStmt.setInt(1, tripId);
                if (customerId != null) {
                    bookingStmt.setInt(2, customerId);
                } else {
                    bookingStmt.setNull(2, Types.INTEGER);
                }
                if (guestPhone != null && !guestPhone.isBlank()) {
                    bookingStmt.setString(3, guestPhone);
                } else {
                    bookingStmt.setNull(3, Types.VARCHAR);
                }
                if (guestEmail != null && !guestEmail.isBlank()) {
                    bookingStmt.setString(4, guestEmail);
                } else {
                    bookingStmt.setNull(4, Types.NVARCHAR);
                }
                bookingStmt.setString(5, DEFAULT_BOOKING_STATUS);
                bookingStmt.setString(6, seatNumber);
                bookingStmt.setString(7, DEFAULT_SEAT_STATUS);

                int affected = bookingStmt.executeUpdate();
                if (affected == 0) {
                    conn.rollback();
                    return null;
                }
                Integer bookingId = null;
                try (ResultSet keys = bookingStmt.getGeneratedKeys()) {
                    if (keys.next()) {
                        bookingId = keys.getInt(1);
                    }
                }
                if (bookingId == null) {
                    conn.rollback();
                    return null;
                }

                try (PreparedStatement ticketStmt = conn.prepareStatement(insertTicket, Statement.RETURN_GENERATED_KEYS)) {
                    ticketStmt.setInt(1, bookingId);
                    ticketStmt.setString(2, generateTicketNumber(tripId));
                    ticketStmt.setString(3, DEFAULT_TICKET_STATUS);
                    if (ticketStmt.executeUpdate() == 0) {
                        conn.rollback();
                        return null;
                    }
                    Integer ticketId = null;
                    try (ResultSet keys = ticketStmt.getGeneratedKeys()) {
                        if (keys.next()) {
                            ticketId = keys.getInt(1);
                        }
                    }
                    conn.commit();
                    conn.setAutoCommit(previousAutoCommit);
                    return ticketId;
                }
            } catch (SQLException ex) {
                conn.rollback();
                LOGGER.log(Level.SEVERE, "Failed to create physical ticket", ex);
            } finally {
                conn.setAutoCommit(previousAutoCommit);
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Unexpected error when creating physical ticket", ex);
        }
        return null;
    }

    public boolean updateTicketDetails(int ticketId, String seatNumber, String bookingStatus, String seatStatus, String ticketStatus) {
        String updateBooking = "UPDATE BOOKING SET SeatNumber = ?, SeatStatus = ?, BookingStatus = ? WHERE BookingID = (SELECT BookingID FROM TICKET WHERE TicketID = ?)";
        String updateTicket = "UPDATE TICKET SET TicketStatus = ?, CheckedInBy = CASE WHEN ? = 'Used' THEN CheckedInBy ELSE NULL END, CheckedInAt = CASE WHEN ? = 'Used' THEN CheckedInAt ELSE NULL END WHERE TicketID = ?";

        try (DBContext db = new DBContext()) {
            Connection conn = db.getConnection();
            if (conn == null) {
                LOGGER.log(Level.SEVERE, "Database connection is null when updating ticket {0}", ticketId);
                return false;
            }
            boolean previousAutoCommit = conn.getAutoCommit();
            conn.setAutoCommit(false);
            try (PreparedStatement bookingStmt = conn.prepareStatement(updateBooking);
                 PreparedStatement ticketStmt = conn.prepareStatement(updateTicket)) {
                bookingStmt.setString(1, seatNumber);
                bookingStmt.setString(2, seatStatus != null && !seatStatus.isBlank() ? seatStatus : DEFAULT_SEAT_STATUS);
                bookingStmt.setString(3, bookingStatus != null && !bookingStatus.isBlank() ? bookingStatus : DEFAULT_BOOKING_STATUS);
                bookingStmt.setInt(4, ticketId);
                if (bookingStmt.executeUpdate() == 0) {
                    conn.rollback();
                    return false;
                }

                String resolvedStatus = ticketStatus != null && !ticketStatus.isBlank() ? ticketStatus : DEFAULT_TICKET_STATUS;
                ticketStmt.setString(1, resolvedStatus);
                ticketStmt.setString(2, resolvedStatus);
                ticketStmt.setString(3, resolvedStatus);
                ticketStmt.setInt(4, ticketId);
                if (ticketStmt.executeUpdate() == 0) {
                    conn.rollback();
                    return false;
                }
                conn.commit();
                conn.setAutoCommit(previousAutoCommit);
                return true;
            } catch (SQLException ex) {
                conn.rollback();
                LOGGER.log(Level.SEVERE, "Failed to update ticket details", ex);
            } finally {
                conn.setAutoCommit(previousAutoCommit);
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Unexpected error when updating ticket details", ex);
        }
        return false;
    }

    public boolean verifyTicket(int ticketId, int staffId) {
        String updateTicket = "UPDATE TICKET SET TicketStatus = 'Used', CheckedInBy = ?, CheckedInAt = GETDATE() WHERE TicketID = ?";
        String updateBooking = "UPDATE BOOKING SET BookingStatus = ?, SeatStatus = ? WHERE BookingID = (SELECT BookingID FROM TICKET WHERE TicketID = ?)";

        try (DBContext db = new DBContext()) {
            Connection conn = db.getConnection();
            if (conn == null) {
                LOGGER.log(Level.SEVERE, "Database connection is null when verifying ticket {0}", ticketId);
                return false;
            }
            boolean previousAutoCommit = conn.getAutoCommit();
            conn.setAutoCommit(false);
            try (PreparedStatement ticketStmt = conn.prepareStatement(updateTicket);
                 PreparedStatement bookingStmt = conn.prepareStatement(updateBooking)) {
                ticketStmt.setInt(1, staffId);
                ticketStmt.setInt(2, ticketId);
                if (ticketStmt.executeUpdate() == 0) {
                    conn.rollback();
                    return false;
                }

                bookingStmt.setString(1, DEFAULT_BOOKING_STATUS);
                bookingStmt.setString(2, DEFAULT_SEAT_STATUS);
                bookingStmt.setInt(3, ticketId);
                if (bookingStmt.executeUpdate() == 0) {
                    conn.rollback();
                    return false;
                }
                conn.commit();
                conn.setAutoCommit(previousAutoCommit);
                return true;
            } catch (SQLException ex) {
                conn.rollback();
                LOGGER.log(Level.SEVERE, "Failed to verify ticket", ex);
            } finally {
                conn.setAutoCommit(previousAutoCommit);
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Unexpected error when verifying ticket", ex);
        }
        return false;
    }

    /**
     * Deletes a ticket and associated booking/payments so admins can void incorrect records.
     */
    public boolean deleteTicket(int ticketId) {
        String selectBooking = "SELECT BookingID FROM TICKET WHERE TicketID = ?";
        String deletePayments = "DELETE FROM PAYMENT WHERE BookingID = ?";
        String deleteSupport = "DELETE FROM SUPPORT_TICKET WHERE BookingID = ?";
        String deleteTicket = "DELETE FROM TICKET WHERE TicketID = ?";
        String deleteBooking = "DELETE FROM BOOKING WHERE BookingID = ?";

        try (DBContext db = new DBContext()) {
            Connection conn = db.getConnection();
            if (conn == null) {
                LOGGER.log(Level.SEVERE, "Database connection is null when deleting ticket {0}", ticketId);
                return false;
            }
            boolean previousAutoCommit = conn.getAutoCommit();
            conn.setAutoCommit(false);
            Integer bookingId = null;
            try (PreparedStatement ps = conn.prepareStatement(selectBooking)) {
                ps.setInt(1, ticketId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        bookingId = rs.getInt("BookingID");
                        if (rs.wasNull()) {
                            bookingId = null;
                        }
                    }
                }
            }
            if (bookingId == null) {
                conn.setAutoCommit(previousAutoCommit);
                return false;
            }

            try (PreparedStatement paymentStmt = conn.prepareStatement(deletePayments);
                 PreparedStatement supportStmt = conn.prepareStatement(deleteSupport);
                 PreparedStatement ticketStmt = conn.prepareStatement(deleteTicket);
                 PreparedStatement bookingStmt = conn.prepareStatement(deleteBooking)) {

                paymentStmt.setInt(1, bookingId);
                paymentStmt.executeUpdate();

                supportStmt.setInt(1, bookingId);
                supportStmt.executeUpdate();

                ticketStmt.setInt(1, ticketId);
                if (ticketStmt.executeUpdate() == 0) {
                    conn.rollback();
                    conn.setAutoCommit(previousAutoCommit);
                    return false;
                }

                bookingStmt.setInt(1, bookingId);
                bookingStmt.executeUpdate();

                conn.commit();
                conn.setAutoCommit(previousAutoCommit);
                return true;
            } catch (SQLException ex) {
                conn.rollback();
                throw ex;
            } finally {
                conn.setAutoCommit(previousAutoCommit);
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Failed to delete ticket " + ticketId, ex);
            return false;
        }
    }

    public List<TripOption> findUpcomingTrips(int limit) {
        String sql = "SELECT TOP " + (limit > 0 ? limit : 50) + " trip.TripID, trip.DepartureTime, trip.ArrivalTime, route.Origin, route.Destination, veh.LicensePlate "
                + "FROM TRIP trip "
                + "JOIN ROUTE route ON trip.RouteID = route.RouteID "
                + "JOIN VEHICLE veh ON trip.VehicleID = veh.VehicleID "
                + "WHERE trip.DepartureTime >= DATEADD(day, -1, GETDATE()) "
                + "ORDER BY trip.DepartureTime ASC";
        try (DBContext db = new DBContext()) {
            Connection conn = db.getConnection();
            if (conn == null) {
                LOGGER.log(Level.SEVERE, "Database connection is null when loading trip options");
                return Collections.emptyList();
            }
            try (PreparedStatement ps = conn.prepareStatement(sql);
                 ResultSet rs = ps.executeQuery()) {
                List<TripOption> options = new ArrayList<>();
                while (rs.next()) {
                    TripOption option = new TripOption();
                    option.setTripId(rs.getInt("TripID"));
                    String origin = rs.getString("Origin");
                    String destination = rs.getString("Destination");
                    option.setRouteLabel((origin != null ? origin : "?") + " - " + (destination != null ? destination : "?"));
                    option.setDepartureTime(toLocalDateTime(rs.getTimestamp("DepartureTime")));
                    option.setArrivalTime(toLocalDateTime(rs.getTimestamp("ArrivalTime")));
                    option.setVehicleLabel(rs.getString("LicensePlate"));
                    options.add(option);
                }
                return options;
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Failed to load trip options", ex);
            return Collections.emptyList();
        }
    }

    public long countTicketsByStatus(String status) {
        if (status == null || status.isBlank()) {
            return 0L;
        }
        String sql = "SELECT COUNT(*) FROM TICKET WHERE TicketStatus = ?";
        try (DBContext db = new DBContext()) {
            Connection conn = db.getConnection();
            if (conn == null) {
                LOGGER.log(Level.SEVERE, "Database connection is null when counting tickets by status {0}", status);
                return 0L;
            }
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, status);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        return rs.getLong(1);
                    }
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Failed to count tickets by status " + status, ex);
        }
        return 0L;
    }

    public long countTicketsIssuedSince(LocalDateTime threshold) {
        if (threshold == null) {
            return 0L;
        }
        String sql = "SELECT COUNT(*) FROM TICKET WHERE IssuedDate >= ?";
        try (DBContext db = new DBContext()) {
            Connection conn = db.getConnection();
            if (conn == null) {
                LOGGER.log(Level.SEVERE, "Database connection is null when counting tickets issued since {0}", threshold);
                return 0L;
            }
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setTimestamp(1, Timestamp.valueOf(threshold));
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        return rs.getLong(1);
                    }
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Failed to count tickets issued since " + threshold, ex);
        }
        return 0L;
    }

    public long countTicketsVerifiedSince(LocalDateTime threshold) {
        if (threshold == null) {
            return 0L;
        }
        String sql = "SELECT COUNT(*) FROM TICKET WHERE CheckedInAt >= ?";
        try (DBContext db = new DBContext()) {
            Connection conn = db.getConnection();
            if (conn == null) {
                LOGGER.log(Level.SEVERE, "Database connection is null when counting tickets verified since {0}", threshold);
                return 0L;
            }
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setTimestamp(1, Timestamp.valueOf(threshold));
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        return rs.getLong(1);
                    }
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Failed to count tickets verified since " + threshold, ex);
        }
        return 0L;
    }

    public List<TicketSummary> findRecentTickets(int limit) {
        int effectiveLimit = limit > 0 ? limit : 10;
        String sql = "SELECT TOP " + effectiveLimit + " "
                + "t.TicketID, t.TicketNumber, t.TicketStatus, t.IssuedDate, t.CheckedInAt, "
                + "staff.FullName AS CheckedInByName, "
                + "b.BookingID, b.SeatNumber, b.SeatStatus, b.BookingStatus, b.TripID, "
                + "trip.DepartureTime, trip.ArrivalTime, route.Origin, route.Destination, "
                + "cust.FullName AS CustomerName, cust.Email AS CustomerEmail, cust.PhoneNumber AS CustomerPhone, "
                + "b.GuestEmail, b.GuestPhoneNumber "
                + "FROM TICKET t "
                + "JOIN BOOKING b ON t.BookingID = b.BookingID "
                + "JOIN TRIP trip ON b.TripID = trip.TripID "
                + "JOIN ROUTE route ON trip.RouteID = route.RouteID "
                + "LEFT JOIN [USER] cust ON b.UserID = cust.UserID "
                + "LEFT JOIN [USER] staff ON t.CheckedInBy = staff.UserID "
                + "ORDER BY t.IssuedDate DESC, t.TicketID DESC";

        try (DBContext db = new DBContext()) {
            Connection conn = db.getConnection();
            if (conn == null) {
                LOGGER.log(Level.SEVERE, "Database connection is null when loading recent tickets");
                return Collections.emptyList();
            }
            try (PreparedStatement ps = conn.prepareStatement(sql);
                    ResultSet rs = ps.executeQuery()) {
                List<TicketSummary> results = new ArrayList<>();
                while (rs.next()) {
                    results.add(mapTicket(rs));
                }
                return results;
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Failed to load recent tickets", ex);
            return Collections.emptyList();
        }
    }

    public List<TicketSummary> findTicketsPendingVerification(int limit) {
        int effectiveLimit = limit > 0 ? limit : 10;
        String sql = "SELECT TOP " + effectiveLimit + " "
                + "t.TicketID, t.TicketNumber, t.TicketStatus, t.IssuedDate, t.CheckedInAt, "
                + "staff.FullName AS CheckedInByName, "
                + "b.BookingID, b.SeatNumber, b.SeatStatus, b.BookingStatus, b.TripID, "
                + "trip.DepartureTime, trip.ArrivalTime, route.Origin, route.Destination, "
                + "cust.FullName AS CustomerName, cust.Email AS CustomerEmail, cust.PhoneNumber AS CustomerPhone, "
                + "b.GuestEmail, b.GuestPhoneNumber "
                + "FROM TICKET t "
                + "JOIN BOOKING b ON t.BookingID = b.BookingID "
                + "JOIN TRIP trip ON b.TripID = trip.TripID "
                + "JOIN ROUTE route ON trip.RouteID = route.RouteID "
                + "LEFT JOIN [USER] cust ON b.UserID = cust.UserID "
                + "LEFT JOIN [USER] staff ON t.CheckedInBy = staff.UserID "
                + "WHERE t.TicketStatus = ? AND trip.DepartureTime >= DATEADD(day, -1, GETDATE()) "
                + "ORDER BY trip.DepartureTime ASC, t.IssuedDate ASC";

        try (DBContext db = new DBContext()) {
            Connection conn = db.getConnection();
            if (conn == null) {
                LOGGER.log(Level.SEVERE, "Database connection is null when loading tickets pending verification");
                return Collections.emptyList();
            }
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, DEFAULT_TICKET_STATUS);
                try (ResultSet rs = ps.executeQuery()) {
                    List<TicketSummary> results = new ArrayList<>();
                    while (rs.next()) {
                        results.add(mapTicket(rs));
                    }
                    return results;
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Failed to load tickets pending verification", ex);
            return Collections.emptyList();
        }
    }

    private TicketSummary mapTicket(ResultSet rs) throws SQLException {
        TicketSummary summary = new TicketSummary();
        summary.setTicketId(rs.getInt("TicketID"));
        summary.setBookingId(rs.getInt("BookingID"));
        summary.setTripId(rs.getInt("TripID"));
        summary.setTicketNumber(rs.getString("TicketNumber"));
        summary.setTicketStatus(rs.getString("TicketStatus"));
        summary.setIssuedDate(toLocalDateTime(rs.getTimestamp("IssuedDate")));
        summary.setCheckedInAt(toLocalDateTime(rs.getTimestamp("CheckedInAt")));
        summary.setCheckedInBy(rs.getString("CheckedInByName"));
        summary.setSeatNumber(rs.getString("SeatNumber"));
        summary.setSeatStatus(rs.getString("SeatStatus"));
        summary.setBookingStatus(rs.getString("BookingStatus"));
        String origin = rs.getString("Origin");
        String destination = rs.getString("Destination");
    summary.setRouteLabel(composeRouteLabel(origin, destination));
        summary.setDepartureTime(toLocalDateTime(rs.getTimestamp("DepartureTime")));
        summary.setArrivalTime(toLocalDateTime(rs.getTimestamp("ArrivalTime")));
        summary.setCustomerName(rs.getString("CustomerName"));
        summary.setCustomerEmail(rs.getString("CustomerEmail"));
        summary.setCustomerPhone(rs.getString("CustomerPhone"));
        summary.setGuestEmail(rs.getString("GuestEmail"));
        summary.setGuestPhone(rs.getString("GuestPhoneNumber"));
        return summary;
    }

    private LocalDateTime toLocalDateTime(Timestamp timestamp) {
        return timestamp != null ? timestamp.toLocalDateTime() : null;
    }

    private String composeRouteLabel(String origin, String destination) {
        String safeOrigin = origin != null && !origin.isBlank() ? origin : "?";
        String safeDestination = destination != null && !destination.isBlank() ? destination : "?";
        return safeOrigin + " → " + safeDestination;
    }

    private String generateTicketNumber(int tripId) {
        return "T" + tripId + "-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
    }
}
