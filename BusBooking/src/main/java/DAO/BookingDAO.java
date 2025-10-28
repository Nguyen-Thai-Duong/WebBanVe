package DAO;

import DBContext.DBContext;
import dto.BookingAdminView;
import dto.TripOption;
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
import model.User;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Data access object dedicated to booking administration flows.
 */
public class BookingDAO {

    private static final Logger LOGGER = LoggerFactory.getLogger(BookingDAO.class);

    private static final String BASE_SELECT =
        "SELECT b.BookingID, b.TripID, b.UserID, b.GuestPhoneNumber, b.GuestEmail, "
            + "b.BookingDate, b.BookingStatus, b.SeatNumber, b.SeatStatus, b.TTL_Expiry, "
            + "trip.DepartureTime, trip.ArrivalTime, route.Origin, route.Destination, route.DurationMinutes, route.RouteStatus, veh.LicensePlate, "
            + "cust.FullName AS CustomerName, cust.Email AS CustomerEmail, cust.PhoneNumber AS CustomerPhone "
            + "FROM BOOKING b "
            + "JOIN TRIP trip ON b.TripID = trip.TripID "
            + "JOIN ROUTE route ON trip.RouteID = route.RouteID "
            + "LEFT JOIN VEHICLE veh ON trip.VehicleID = veh.VehicleID "
            + "LEFT JOIN [USER] cust ON b.UserID = cust.UserID";

    public List<BookingAdminView> findAll() {
        String sql = BASE_SELECT + " ORDER BY b.BookingDate DESC, b.BookingID DESC";
        try (DBContext db = new DBContext()) {
            Connection conn = db.getConnection();
            if (conn == null) {
                LOGGER.error("Database connection is null when loading bookings");
                return Collections.emptyList();
            }
            try (PreparedStatement ps = conn.prepareStatement(sql);
                    ResultSet rs = ps.executeQuery()) {
                List<BookingAdminView> bookings = new ArrayList<>();
                while (rs.next()) {
                    bookings.add(mapBooking(rs));
                }
                return bookings;
            }
        } catch (SQLException ex) {
            LOGGER.error("Failed to load bookings", ex);
            return Collections.emptyList();
        }
    }

    public BookingAdminView findById(int bookingId) {
        String sql = BASE_SELECT + " WHERE b.BookingID = ?";
        try (DBContext db = new DBContext()) {
            Connection conn = db.getConnection();
            if (conn == null) {
                LOGGER.error("Database connection is null when loading booking id {}", bookingId);
                return null;
            }
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, bookingId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        return mapBooking(rs);
                    }
                }
            }
        } catch (SQLException ex) {
            LOGGER.error("Failed to find booking with id {}", bookingId, ex);
        }
        return null;
    }

    public boolean insert(BookingAdminView booking) {
        String sql = "INSERT INTO BOOKING (TripID, UserID, GuestPhoneNumber, GuestEmail, BookingDate, BookingStatus, "
                + "SeatNumber, SeatStatus, TTL_Expiry) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        LocalDateTime bookingDate = booking.getBookingDate() != null ? booking.getBookingDate() : LocalDateTime.now();
        try (DBContext db = new DBContext()) {
            Connection conn = db.getConnection();
            if (conn == null) {
                LOGGER.error("Database connection is null when inserting booking");
                return false;
            }
            try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
                int idx = 1;
                ps.setInt(idx++, booking.getTripId());
                if (booking.getCustomerId() != null) {
                    ps.setInt(idx++, booking.getCustomerId());
                } else {
                    ps.setNull(idx++, Types.INTEGER);
                }
                setNullableString(ps, idx++, booking.getGuestPhoneNumber(), Types.VARCHAR);
                setNullableString(ps, idx++, booking.getGuestEmail(), Types.NVARCHAR);
                setTimestamp(ps, idx++, bookingDate);
                ps.setString(idx++, resolveBookingStatus(booking.getBookingStatus()));
                ps.setString(idx++, booking.getSeatNumber());
                ps.setString(idx++, resolveSeatStatus(booking.getSeatStatus()));
                setTimestamp(ps, idx, booking.getTtlExpiry());

                int affected = ps.executeUpdate();
                if (affected > 0) {
                    try (ResultSet keys = ps.getGeneratedKeys()) {
                        if (keys.next()) {
                            booking.setBookingId(keys.getInt(1));
                        }
                    }
                }
                return affected > 0;
            }
        } catch (SQLException ex) {
            LOGGER.error("Failed to insert booking", ex);
            return false;
        }
    }

    public boolean update(BookingAdminView booking) {
        if (booking.getBookingId() == null) {
            throw new IllegalArgumentException("Booking ID is required for update");
        }
        String sql = "UPDATE BOOKING SET TripID = ?, UserID = ?, GuestPhoneNumber = ?, GuestEmail = ?, "
                + "BookingStatus = ?, SeatNumber = ?, SeatStatus = ?, TTL_Expiry = ? WHERE BookingID = ?";
        try (DBContext db = new DBContext()) {
            Connection conn = db.getConnection();
            if (conn == null) {
                LOGGER.error("Database connection is null when updating booking id {}", booking.getBookingId());
                return false;
            }
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                int idx = 1;
                ps.setInt(idx++, booking.getTripId());
                if (booking.getCustomerId() != null) {
                    ps.setInt(idx++, booking.getCustomerId());
                } else {
                    ps.setNull(idx++, Types.INTEGER);
                }
                setNullableString(ps, idx++, booking.getGuestPhoneNumber(), Types.VARCHAR);
                setNullableString(ps, idx++, booking.getGuestEmail(), Types.NVARCHAR);
                ps.setString(idx++, resolveBookingStatus(booking.getBookingStatus()));
                ps.setString(idx++, booking.getSeatNumber());
                ps.setString(idx++, resolveSeatStatus(booking.getSeatStatus()));
                setTimestamp(ps, idx++, booking.getTtlExpiry());
                ps.setInt(idx, booking.getBookingId());
                return ps.executeUpdate() > 0;
            }
        } catch (SQLException ex) {
            LOGGER.error("Failed to update booking with id {}", booking.getBookingId(), ex);
            return false;
        }
    }

    public boolean delete(int bookingId) {
        String sql = "DELETE FROM BOOKING WHERE BookingID = ?";
        try (DBContext db = new DBContext()) {
            Connection conn = db.getConnection();
            if (conn == null) {
                LOGGER.error("Database connection is null when deleting booking id {}", bookingId);
                return false;
            }
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, bookingId);
                return ps.executeUpdate() > 0;
            }
        } catch (SQLException ex) {
            LOGGER.error("Failed to delete booking with id {}", bookingId, ex);
            return false;
        }
    }

    public List<TripOption> findTripOptions() {
    String sql = "SELECT trip.TripID, trip.DepartureTime, trip.ArrivalTime, route.Origin, route.Destination, route.DurationMinutes, veh.LicensePlate "
                + "FROM TRIP trip "
                + "JOIN ROUTE route ON trip.RouteID = route.RouteID "
                + "JOIN VEHICLE veh ON trip.VehicleID = veh.VehicleID "
                + "ORDER BY trip.DepartureTime DESC";
        try (DBContext db = new DBContext()) {
            Connection conn = db.getConnection();
            if (conn == null) {
                LOGGER.error("Database connection is null when loading trip options for bookings");
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
                    option.setRouteLabel(buildRouteLabel(origin, destination));
                    LocalDateTime departure = toLocalDateTime(rs.getTimestamp("DepartureTime"));
                    LocalDateTime arrival = toLocalDateTime(rs.getTimestamp("ArrivalTime"));
                    int duration = rs.getInt("DurationMinutes");
                    boolean durationIsNull = rs.wasNull();
                    if (arrival == null && !durationIsNull && departure != null) {
                        arrival = departure.plusMinutes(duration);
                    }
                    option.setDepartureTime(departure);
                    option.setArrivalTime(arrival);
                    option.setVehicleLabel(rs.getString("LicensePlate"));
                    options.add(option);
                }
                return options;
            }
        } catch (SQLException ex) {
            LOGGER.error("Failed to load trip options for bookings", ex);
            return Collections.emptyList();
        }
    }

    public List<User> findCustomersForSelection() {
        String sql = "SELECT UserID, FullName, Email, PhoneNumber FROM [USER] WHERE Role = 'Customer' ORDER BY FullName";
        try (DBContext db = new DBContext()) {
            Connection conn = db.getConnection();
            if (conn == null) {
                LOGGER.error("Database connection is null when loading customer options for bookings");
                return Collections.emptyList();
            }
            try (PreparedStatement ps = conn.prepareStatement(sql);
                    ResultSet rs = ps.executeQuery()) {
                List<User> customers = new ArrayList<>();
                while (rs.next()) {
                    User user = new User();
                    user.setUserId(rs.getInt("UserID"));
                    user.setFullName(rs.getString("FullName"));
                    user.setEmail(rs.getString("Email"));
                    user.setPhoneNumber(rs.getString("PhoneNumber"));
                    customers.add(user);
                }
                return customers;
            }
        } catch (SQLException ex) {
            LOGGER.error("Failed to load customers for bookings", ex);
            return Collections.emptyList();
        }
    }

    private BookingAdminView mapBooking(ResultSet rs) throws SQLException {
        BookingAdminView view = new BookingAdminView();
        view.setBookingId(rs.getInt("BookingID"));
        view.setTripId(rs.getInt("TripID"));
        int customerId = rs.getInt("UserID");
        if (!rs.wasNull()) {
            view.setCustomerId(customerId);
        }
        view.setGuestPhoneNumber(rs.getString("GuestPhoneNumber"));
        view.setGuestEmail(rs.getString("GuestEmail"));
        view.setBookingDate(toLocalDateTime(rs.getTimestamp("BookingDate")));
        view.setBookingStatus(rs.getString("BookingStatus"));
        view.setSeatNumber(rs.getString("SeatNumber"));
        view.setSeatStatus(rs.getString("SeatStatus"));
        view.setTtlExpiry(toLocalDateTime(rs.getTimestamp("TTL_Expiry")));
        LocalDateTime departure = toLocalDateTime(rs.getTimestamp("DepartureTime"));
        LocalDateTime arrival = toLocalDateTime(rs.getTimestamp("ArrivalTime"));
        int duration = rs.getInt("DurationMinutes");
        boolean durationIsNull = rs.wasNull();
        if (arrival == null && !durationIsNull && departure != null) {
            arrival = departure.plusMinutes(duration);
        }
        view.setDepartureTime(departure);
        view.setArrivalTime(arrival);
        view.setRouteOrigin(rs.getString("Origin"));
        view.setRouteDestination(rs.getString("Destination"));
        view.setRouteDurationMinutes(durationIsNull ? null : duration);
        String routeStatus = rs.getString("RouteStatus");
        view.setRouteStatus(routeStatus != null && !routeStatus.isBlank() ? routeStatus : "Active");
        view.setVehiclePlate(rs.getString("LicensePlate"));
        view.setCustomerName(rs.getString("CustomerName"));
        view.setCustomerEmail(rs.getString("CustomerEmail"));
        view.setCustomerPhone(rs.getString("CustomerPhone"));
        return view;
    }

    private void setTimestamp(PreparedStatement ps, int index, LocalDateTime value) throws SQLException {
        if (value != null) {
            ps.setTimestamp(index, Timestamp.valueOf(value));
        } else {
            ps.setNull(index, Types.TIMESTAMP);
        }
    }

    private void setNullableString(PreparedStatement ps, int index, String value, int sqlType) throws SQLException {
        if (value != null && !value.isBlank()) {
            ps.setString(index, value);
        } else {
            ps.setNull(index, sqlType);
        }
    }

    private LocalDateTime toLocalDateTime(Timestamp timestamp) {
        return timestamp != null ? timestamp.toLocalDateTime() : null;
    }

    private String buildRouteLabel(String origin, String destination) {
        String safeOrigin = origin != null ? origin : "?";
        String safeDestination = destination != null ? destination : "?";
        return safeOrigin + " -> " + safeDestination;
    }

    private String resolveBookingStatus(String status) {
        if (status == null || status.isBlank()) {
            return "Pending";
        }
        return status;
    }

    private String resolveSeatStatus(String status) {
        if (status == null || status.isBlank()) {
            return "Booked";
        }
        return status;
    }
}
