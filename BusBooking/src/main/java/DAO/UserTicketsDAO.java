package DAO;

import DBContext.DBContext;
import dto.UserTicket;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class UserTicketsDAO {

    private static final Logger LOGGER = Logger.getLogger(TicketDAO.class.getName());

    // This is the correct, verified SQL query.
    // It joins BOOKING, TICKET, TRIP, and ROUTE to get all required details.
    private static final String FIND_TICKETS_BY_USER_ID =
            "SELECT " +
                    "    T.TicketNumber, " +
                    "    T.TicketStatus, " +
                    "    T.IssuedDate, " +
                    "    B.SeatNumber, " +
                    "    R.Origin + ' -> ' + R.Destination AS RouteDetails, " +
                    "    TR.DepartureTime, " +
                    "    TR.Price, " + // NEW
                    "    R.Origin, " + // NEW
                    "    R.Destination, " + // NEW
                    "    V.EmployeeCode AS OperatorCode " + // NEW: Assuming Vehicle table has EmployeeCode
                    "FROM " +
                    "    BOOKING B " +
                    "JOIN " +
                    "    TICKET T ON B.BookingID = T.BookingID " +
                    "JOIN " +
                    "    TRIP TR ON B.TripID = TR.TripID " +
                    "JOIN " +
                    "    ROUTE R ON TR.RouteID = R.RouteID " +
                    "JOIN " +
                    "    VEHICLE V ON TR.VehicleID = V.VehicleID " +
                    "WHERE " +
                    "    B.UserID = ?";
    /**
     * Retrieves all purchased tickets for a specific user ID.
     * @param userId The ID of the user.
     * @return A list of UserTicketDTO objects.
     */
    public List<UserTicket> findTicketsByUserId(int userId) {
        List<UserTicket> tickets = new ArrayList<>();

        try (DBContext db = new DBContext()) {
            Connection conn = db.getConnection();
            if (conn == null) {
                LOGGER.log(Level.SEVERE, "Database connection is null when loading tickets for user {0}", userId);
                return Collections.emptyList();
            }
            try (PreparedStatement ps = conn.prepareStatement(FIND_TICKETS_BY_USER_ID)) {
                ps.setInt(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        tickets.add(mapTicketDTO(rs));
                    }
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Failed to fetch tickets for user id " + userId, ex);
            return Collections.emptyList();
        }
        return tickets;
    }

    private UserTicket mapTicketDTO(ResultSet rs) throws SQLException {
        String ticketNumber = rs.getString("TicketNumber");
        String ticketStatus = rs.getString("TicketStatus");
        String routeDetails = rs.getString("RouteDetails");
        String seatNumber = rs.getString("SeatNumber");

        // Fetch new detail fields
        BigDecimal price = rs.getBigDecimal("Price");
        String origin = rs.getString("Origin");
        String destination = rs.getString("Destination");
        String operatorCode = rs.getString("OperatorCode");

        LocalDateTime issuedDate = toLocalDateTime(rs.getTimestamp("IssuedDate"));
        LocalDateTime departureTime = toLocalDateTime(rs.getTimestamp("DepartureTime"));

        // UPDATED DTO INSTANTIATION
        return new UserTicket(ticketNumber, routeDetails, departureTime, issuedDate,
                ticketStatus, seatNumber, price, origin, destination, operatorCode);
    }

    // Utility method to convert SQL Timestamp to LocalDateTime
    private LocalDateTime toLocalDateTime(Timestamp timestamp) {
        return timestamp != null ? timestamp.toLocalDateTime() : null;
    }
}