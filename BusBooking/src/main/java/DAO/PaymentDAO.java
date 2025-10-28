package DAO;

import DBContext.DBContext;
import dto.PaymentAdminView;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Data access object for payment administration tasks.
 */
public class PaymentDAO {

    private static final Logger LOGGER = LoggerFactory.getLogger(PaymentDAO.class);

    private static final String BASE_SELECT =
            "SELECT p.PaymentID, p.BookingID, p.Amount, p.TransactionDate, p.Method, p.Type, p.TransactionRef, "
                    + "b.SeatNumber, b.BookingStatus, trip.DepartureTime, route.Origin, route.Destination, "
                    + "cust.FullName AS CustomerName "
                    + "FROM PAYMENT p "
                    + "JOIN BOOKING b ON p.BookingID = b.BookingID "
                    + "JOIN TRIP trip ON b.TripID = trip.TripID "
                    + "JOIN ROUTE route ON trip.RouteID = route.RouteID "
                    + "LEFT JOIN [USER] cust ON b.UserID = cust.UserID";

    public List<PaymentAdminView> findAll() {
        String sql = BASE_SELECT
                + " ORDER BY CASE WHEN LOWER(b.BookingStatus) = 'pending' THEN 0 ELSE 1 END, "
                + "p.TransactionDate DESC, p.PaymentID DESC";
        try (DBContext db = new DBContext()) {
            Connection conn = db.getConnection();
            if (conn == null) {
                LOGGER.error("Database connection is null when loading payments");
                return Collections.emptyList();
            }
            try (PreparedStatement ps = conn.prepareStatement(sql);
                    ResultSet rs = ps.executeQuery()) {
                List<PaymentAdminView> payments = new ArrayList<>();
                while (rs.next()) {
                    payments.add(mapPayment(rs));
                }
                return payments;
            }
        } catch (SQLException ex) {
            LOGGER.error("Failed to load payments", ex);
            return Collections.emptyList();
        }
    }

    public PaymentAdminView findById(int paymentId) {
        String sql = BASE_SELECT + " WHERE p.PaymentID = ?";
        try (DBContext db = new DBContext()) {
            Connection conn = db.getConnection();
            if (conn == null) {
                LOGGER.error("Database connection is null when loading payment id {}", paymentId);
                return null;
            }
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, paymentId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        return mapPayment(rs);
                    }
                }
            }
        } catch (SQLException ex) {
            LOGGER.error("Failed to find payment with id {}", paymentId, ex);
        }
        return null;
    }

    private PaymentAdminView mapPayment(ResultSet rs) throws SQLException {
        PaymentAdminView view = new PaymentAdminView();
        view.setPaymentId(rs.getInt("PaymentID"));
        view.setBookingId(rs.getInt("BookingID"));
        view.setAmount(rs.getBigDecimal("Amount"));
        view.setTransactionDate(toLocalDateTime(rs.getTimestamp("TransactionDate")));
        view.setMethod(rs.getString("Method"));
        view.setType(rs.getString("Type"));
        view.setTransactionRef(rs.getString("TransactionRef"));
        view.setSeatNumber(rs.getString("SeatNumber"));
        view.setBookingStatus(rs.getString("BookingStatus"));
        view.setDepartureTime(toLocalDateTime(rs.getTimestamp("DepartureTime")));
        view.setRouteOrigin(rs.getString("Origin"));
        view.setRouteDestination(rs.getString("Destination"));
        view.setCustomerName(rs.getString("CustomerName"));
        return view;
    }

    private LocalDateTime toLocalDateTime(java.sql.Timestamp timestamp) {
        return timestamp != null ? timestamp.toLocalDateTime() : null;
    }
}
