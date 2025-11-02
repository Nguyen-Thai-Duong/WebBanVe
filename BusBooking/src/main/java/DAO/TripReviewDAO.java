package DAO;

import DBContext.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.sql.Types;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Data access object for managing trip reviews.
 */
public class TripReviewDAO {

    private static final Logger LOGGER = Logger.getLogger(TripReviewDAO.class.getName());

    // Query để kiểm tra xem đánh giá đã tồn tại chưa
    private static final String CHECK_EXISTING_REVIEW =
            "SELECT COUNT(ReviewID) FROM TRIP_REVIEW WHERE TripID = ? AND CustomerID = ?";

    // Query để chèn đánh giá mới
    private static final String INSERT_REVIEW =
            "INSERT INTO TRIP_REVIEW (TripID, CustomerID, Rating, Comment, ReviewDate) VALUES (?, ?, ?, ?, GETDATE())";

    // Query để lấy chi tiết chuyến đi cần thiết cho form đánh giá
    private static final String GET_TRIP_DETAILS =
            "SELECT R.Origin, R.Destination, T.DepartureTime " +
                    "FROM TRIP T JOIN ROUTE R ON T.RouteID = R.RouteID " +
                    "WHERE T.TripID = ?";

    /**
     * DTO đơn giản để mang chi tiết chuyến đi đến Controller/JSP.
     */
    // BẮT ĐẦU FIX: Thay đổi khai báo trường thành private và thêm Getters
    public static class TripReviewDetails {
        private String routeDetails;
        private String departureTime;

        // Thêm Constructor mặc định (nếu cần)
        public TripReviewDetails() {}

        // Thêm các Setter (nếu cần thiết, trong trường hợp này là cần để gán giá trị từ DAO)
        public void setRouteDetails(String routeDetails) {
            this.routeDetails = routeDetails;
        }

        public void setDepartureTime(String departureTime) {
            this.departureTime = departureTime;
        }

        // FIX LỖI: Thêm Public Getter cho 'routeDetails'
        public String getRouteDetails() {
            return routeDetails;
        }

        // FIX LỖI: Thêm Public Getter cho 'departureTime'
        public String getDepartureTime() {
            return departureTime;
        }
    }
    // KẾT THÚC FIX

    /**
     * Kiểm tra xem khách hàng đã gửi đánh giá cho chuyến đi này chưa.
     * @param tripId ID chuyến đi.
     * @param customerId ID người dùng (Customer).
     * @return true nếu đã có, false nếu chưa.
     */
    public boolean isReviewSubmitted(int tripId, int customerId) {
        // ... (Không thay đổi)
        try (DBContext db = new DBContext()) {
            Connection conn = db.getConnection();
            if (conn == null) return false;

            try (PreparedStatement ps = conn.prepareStatement(CHECK_EXISTING_REVIEW)) {
                ps.setInt(1, tripId);
                ps.setInt(2, customerId);
                try (ResultSet rs = ps.executeQuery()) {
                    return rs.next() && rs.getInt(1) > 0;
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Failed to check existing review for TripID: " + tripId, ex);
            return false;
        }
    }

    /**
     * Lưu đánh giá mới vào cơ sở dữ liệu.
     * @param tripId ID chuyến đi.
     * @param customerId ID người dùng (Customer).
     * @param rating Điểm đánh giá (1-5).
     * @param comment Nhận xét (tối đa 256 ký tự).
     * @return true nếu lưu thành công.
     */
    public boolean saveReview(int tripId, int customerId, int rating, String comment) {
        // ... (Không thay đổi)
        try (DBContext db = new DBContext()) {
            Connection conn = db.getConnection();
            if (conn == null) return false;

            try (PreparedStatement ps = conn.prepareStatement(INSERT_REVIEW)) {
                ps.setInt(1, tripId);
                ps.setInt(2, customerId);
                ps.setInt(3, rating);

                // Truncate comment to prevent DB error (assuming NVARCHAR(256))
                String finalComment = (comment != null) ? comment.trim() : null;
                if (finalComment != null && finalComment.length() > 256) {
                    finalComment = finalComment.substring(0, 256);
                }

                if (finalComment != null && !finalComment.isEmpty()) {
                    ps.setString(4, finalComment);
                } else {
                    ps.setNull(4, Types.NVARCHAR);
                }

                return ps.executeUpdate() > 0;
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Failed to save review for TripID: " + tripId, ex);
            return false;
        }
    }

    /**
     * Lấy thông tin cơ bản về chuyến đi để hiển thị trên form.
     */
    public TripReviewDetails getTripDetailsForReview(int tripId) {
        try (DBContext db = new DBContext()) {
            Connection conn = db.getConnection();
            if (conn == null) return null;

            try (PreparedStatement ps = conn.prepareStatement(GET_TRIP_DETAILS)) {
                ps.setInt(1, tripId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        TripReviewDetails details = new TripReviewDetails();
                        // Sử dụng Setter nếu có, hoặc truy cập trực tiếp nếu trường là public (nhưng nên dùng setter/getter)
                        details.setRouteDetails(rs.getString("Origin") + " -> " + rs.getString("Destination"));

                        Timestamp departureTs = rs.getTimestamp("DepartureTime");
                        if (departureTs != null) {
                            details.setDepartureTime(departureTs.toLocalDateTime()
                                    .format(java.time.format.DateTimeFormatter.ofPattern("HH:mm, dd/MM/yyyy")));
                        } else {
                            details.setDepartureTime("N/A");
                        }
                        return details;
                    }
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Failed to fetch trip details for TripID: " + tripId, ex);
        }
        return null;
    }
}