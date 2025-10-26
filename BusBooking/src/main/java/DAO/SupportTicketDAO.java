package DAO;

import DBContext.DBContext;
import dto.support.SupportTicketView;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.sql.Types;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.stream.Collectors;

/**
 * Persistence helper for customer support tickets handled by staff.
 */
public class SupportTicketDAO {

    private static final Logger LOGGER = Logger.getLogger(SupportTicketDAO.class.getName());

    public List<SupportTicketView> findTickets(String status, String keyword) {
        StringBuilder sql = new StringBuilder()
                .append("SELECT TOP 200 ")
                .append("st.SupportID, st.Category, st.IssueDescription, st.ResolutionDetails, st.Status, st.OpenedDate, st.ClosedDate, ")
                .append("st.BookingID, b.SeatNumber, b.TripID, ")
                .append("trip.DepartureTime, route.Origin, route.Destination, ")
                .append("cust.FullName AS CustomerName, cust.Email AS CustomerEmail, cust.PhoneNumber AS CustomerPhone, ")
                .append("staff.FullName AS StaffAssignedName ")
                .append("FROM SUPPORT_TICKET st ")
                .append("LEFT JOIN BOOKING b ON st.BookingID = b.BookingID ")
                .append("LEFT JOIN TRIP trip ON b.TripID = trip.TripID ")
                .append("LEFT JOIN ROUTE route ON trip.RouteID = route.RouteID ")
                .append("LEFT JOIN [USER] cust ON st.CustomerID = cust.UserID ")
                .append("LEFT JOIN [USER] staff ON st.StaffAssigned = staff.UserID ");

        List<Object> params = new ArrayList<>();
        boolean hasWhere = false;
        if (status != null && !status.isBlank()) {
            sql.append("WHERE st.Status = ? ");
            params.add(status);
            hasWhere = true;
        }
        if (keyword != null && !keyword.isBlank()) {
            sql.append(hasWhere ? "AND " : "WHERE ")
                    .append("(st.IssueDescription LIKE ? OR st.Category LIKE ? OR cust.FullName LIKE ? OR cust.Email LIKE ? OR cust.PhoneNumber LIKE ?) ");
            String pattern = "%" + keyword.trim() + "%";
            params.add(pattern);
            params.add(pattern);
            params.add(pattern);
            params.add(pattern);
            params.add(pattern);
        }
        sql.append("ORDER BY st.OpenedDate DESC, st.SupportID DESC");

        try (DBContext db = new DBContext()) {
            Connection conn = db.getConnection();
            if (conn == null) {
                LOGGER.log(Level.SEVERE, "Database connection is null when loading support tickets");
                return Collections.emptyList();
            }
            try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
                for (int i = 0; i < params.size(); i++) {
                    ps.setObject(i + 1, params.get(i));
                }
                try (ResultSet rs = ps.executeQuery()) {
                    List<SupportTicketView> list = new ArrayList<>();
                    while (rs.next()) {
                        list.add(mapTicket(rs));
                    }
                    return list;
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Failed to load support tickets", ex);
            return Collections.emptyList();
        }
    }

    public long countByStatus(String status) {
        if (status == null || status.isBlank()) {
            return 0L;
        }
        String sql = "SELECT COUNT(*) FROM SUPPORT_TICKET WHERE Status = ?";
        try (DBContext db = new DBContext()) {
            Connection conn = db.getConnection();
            if (conn == null) {
                LOGGER.log(Level.SEVERE, "Database connection is null when counting support tickets by status {0}", status);
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
            LOGGER.log(Level.SEVERE, "Failed to count support tickets by status " + status, ex);
        }
        return 0L;
    }

    public long countByStatuses(List<String> statuses) {
        if (statuses == null || statuses.isEmpty()) {
            return 0L;
        }
        String placeholders = statuses.stream().map(s -> "?").collect(Collectors.joining(", "));
        String sql = "SELECT COUNT(*) FROM SUPPORT_TICKET WHERE Status IN (" + placeholders + ")";
        try (DBContext db = new DBContext()) {
            Connection conn = db.getConnection();
            if (conn == null) {
                LOGGER.log(Level.SEVERE, "Database connection is null when counting support tickets by multiple statuses");
                return 0L;
            }
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                for (int i = 0; i < statuses.size(); i++) {
                    ps.setString(i + 1, statuses.get(i));
                }
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        return rs.getLong(1);
                    }
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Failed to count support tickets by statuses", ex);
        }
        return 0L;
    }

    public List<SupportTicketView> findRecentTickets(int limit) {
        int effectiveLimit = limit > 0 ? limit : 10;
        String sql = "SELECT TOP " + effectiveLimit + " "
                + "st.SupportID, st.Category, st.IssueDescription, st.ResolutionDetails, st.Status, st.OpenedDate, st.ClosedDate, "
                + "st.BookingID, b.SeatNumber, b.TripID, "
                + "trip.DepartureTime, route.Origin, route.Destination, "
                + "cust.FullName AS CustomerName, cust.Email AS CustomerEmail, cust.PhoneNumber AS CustomerPhone, "
                + "staff.FullName AS StaffAssignedName "
                + "FROM SUPPORT_TICKET st "
                + "LEFT JOIN BOOKING b ON st.BookingID = b.BookingID "
                + "LEFT JOIN TRIP trip ON b.TripID = trip.TripID "
                + "LEFT JOIN ROUTE route ON trip.RouteID = route.RouteID "
                + "LEFT JOIN [USER] cust ON st.CustomerID = cust.UserID "
                + "LEFT JOIN [USER] staff ON st.StaffAssigned = staff.UserID "
                + "ORDER BY st.OpenedDate DESC, st.SupportID DESC";

        try (DBContext db = new DBContext()) {
            Connection conn = db.getConnection();
            if (conn == null) {
                LOGGER.log(Level.SEVERE, "Database connection is null when loading recent support tickets");
                return Collections.emptyList();
            }
            try (PreparedStatement ps = conn.prepareStatement(sql);
                    ResultSet rs = ps.executeQuery()) {
                List<SupportTicketView> list = new ArrayList<>();
                while (rs.next()) {
                    list.add(mapTicket(rs));
                }
                return list;
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Failed to load recent support tickets", ex);
            return Collections.emptyList();
        }
    }

    public boolean updateTicket(int supportId, String status, String resolutionDetails, Integer staffId) {
        String sql = "UPDATE SUPPORT_TICKET SET Status = ?, ResolutionDetails = ?, StaffAssigned = ?, ClosedDate = CASE WHEN ? = 'Closed' THEN GETDATE() ELSE NULL END WHERE SupportID = ?";
        try (DBContext db = new DBContext()) {
            Connection conn = db.getConnection();
            if (conn == null) {
                LOGGER.log(Level.SEVERE, "Database connection is null when updating support ticket {0}", supportId);
                return false;
            }
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, status != null && !status.isBlank() ? status : "InProgress");
                if (resolutionDetails != null && !resolutionDetails.isBlank()) {
                    ps.setString(2, resolutionDetails.trim());
                } else {
                    ps.setNull(2, Types.NVARCHAR);
                }
                if (staffId != null) {
                    ps.setInt(3, staffId);
                } else {
                    ps.setNull(3, Types.INTEGER);
                }
                String statusValue = status != null && !status.isBlank() ? status : "InProgress";
                ps.setString(4, statusValue);
                ps.setInt(5, supportId);
                return ps.executeUpdate() > 0;
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Failed to update support ticket", ex);
            return false;
        }
    }

    private SupportTicketView mapTicket(ResultSet rs) throws SQLException {
        SupportTicketView view = new SupportTicketView();
        view.setSupportId(rs.getInt("SupportID"));
        view.setCategory(rs.getString("Category"));
        view.setIssueDescription(rs.getString("IssueDescription"));
        view.setResolutionDetails(rs.getString("ResolutionDetails"));
        view.setStatus(rs.getString("Status"));
        view.setOpenedDate(toLocalDateTime(rs.getTimestamp("OpenedDate")));
        view.setClosedDate(toLocalDateTime(rs.getTimestamp("ClosedDate")));
        int bookingId = rs.getInt("BookingID");
        view.setBookingId(rs.wasNull() ? null : bookingId);
        view.setSeatNumber(rs.getString("SeatNumber"));
        int tripId = rs.getInt("TripID");
        view.setTripId(rs.wasNull() ? null : tripId);
        String origin = rs.getString("Origin");
        String destination = rs.getString("Destination");
        view.setRouteLabel((origin != null ? origin : "?") + " - " + (destination != null ? destination : "?"));
        view.setDepartureTime(toLocalDateTime(rs.getTimestamp("DepartureTime")));
        view.setCustomerName(rs.getString("CustomerName"));
        view.setCustomerEmail(rs.getString("CustomerEmail"));
        view.setCustomerPhone(rs.getString("CustomerPhone"));
        view.setStaffAssignedName(rs.getString("StaffAssignedName"));
        return view;
    }

    private LocalDateTime toLocalDateTime(Timestamp timestamp) {
        return timestamp != null ? timestamp.toLocalDateTime() : null;
    }
}