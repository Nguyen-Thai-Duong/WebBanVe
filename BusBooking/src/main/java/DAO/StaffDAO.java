package DAO;

import DBContext.DBContext;
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
 * Data access object for managing staff accounts (role = Staff).
 */
public class StaffDAO {

    private static final Logger LOGGER = LoggerFactory.getLogger(StaffDAO.class);
    private static final String STAFF_ROLE = "Staff";

    private static final String BASE_SELECT = "SELECT UserID, EmployeeCode, FullName, Email, PhoneNumber, Role, Status, Address, CreatedAt, UpdatedAt "
            + "FROM [USER] WHERE Role = ?";

    public List<User> findAll() {
        String sql = BASE_SELECT + " ORDER BY CreatedAt DESC";
        try (DBContext db = new DBContext()) {
            Connection conn = db.getConnection();
            if (conn == null) {
                LOGGER.error("Database connection is null when loading staff members");
                return Collections.emptyList();
            }
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, STAFF_ROLE);
                try (ResultSet rs = ps.executeQuery()) {
                    List<User> staffMembers = new ArrayList<>();
                    while (rs.next()) {
                        staffMembers.add(mapStaff(rs));
                    }
                    return staffMembers;
                }
            }
        } catch (SQLException ex) {
            LOGGER.error("Failed to load staff members", ex);
            return Collections.emptyList();
        }
    }

    public User findById(int userId) {
        String sql = BASE_SELECT + " AND UserID = ?";
        try (DBContext db = new DBContext()) {
            Connection conn = db.getConnection();
            if (conn == null) {
                LOGGER.error("Database connection is null when finding staff member id {}", userId);
                return null;
            }
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, STAFF_ROLE);
                ps.setInt(2, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        return mapStaff(rs);
                    }
                }
            }
        } catch (SQLException ex) {
            LOGGER.error("Failed to find staff member with id {}", userId, ex);
        }
        return null;
    }

    public boolean insert(User staff) {
        String sql = "INSERT INTO [USER] (FullName, Email, PasswordHash, PhoneNumber, Role, Status, Address, CreatedAt, UpdatedAt) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        LocalDateTime now = LocalDateTime.now();
        try (DBContext db = new DBContext()) {
            Connection conn = db.getConnection();
            if (conn == null) {
                LOGGER.error("Database connection is null when inserting staff member");
                return false;
            }
            try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
                int idx = 1;
                ps.setString(idx++, staff.getFullName());
                ps.setString(idx++, staff.getEmail());
                ps.setString(idx++, staff.getPasswordHash());
                ps.setString(idx++, staff.getPhoneNumber());
                ps.setString(idx++, STAFF_ROLE);
                ps.setString(idx++, staff.getStatus());
                if (staff.getAddress() != null && !staff.getAddress().isBlank()) {
                    ps.setString(idx++, staff.getAddress());
                } else {
                    ps.setNull(idx++, Types.NVARCHAR);
                }
                setTimestamp(ps, idx++, now);
                setTimestamp(ps, idx++, now);
                int affected = ps.executeUpdate();
                if (affected > 0) {
                    try (ResultSet keys = ps.getGeneratedKeys()) {
                        if (keys.next()) {
                            staff.setUserId(keys.getInt(1));
                        }
                    }
                }
                return affected > 0;
            }
        } catch (SQLException ex) {
            LOGGER.error("Failed to insert staff member", ex);
            return false;
        }
    }

    public boolean update(User staff) {
        if (staff.getUserId() == null) {
            throw new IllegalArgumentException("Staff ID is required for update");
        }
        boolean updatePassword = staff.getPasswordHash() != null && !staff.getPasswordHash().isBlank();
        StringBuilder sql = new StringBuilder("UPDATE [USER] SET FullName = ?, Email = ?, PhoneNumber = ?, Status = ?, Address = ?, UpdatedAt = ?");
        if (updatePassword) {
            sql.append(", PasswordHash = ?");
        }
        sql.append(" WHERE UserID = ? AND Role = ?");

        try (DBContext db = new DBContext()) {
            Connection conn = db.getConnection();
            if (conn == null) {
                LOGGER.error("Database connection is null when updating staff member id {}", staff.getUserId());
                return false;
            }
            try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
                int idx = 1;
                ps.setString(idx++, staff.getFullName());
                ps.setString(idx++, staff.getEmail());
                ps.setString(idx++, staff.getPhoneNumber());
                ps.setString(idx++, staff.getStatus());
                if (staff.getAddress() != null && !staff.getAddress().isBlank()) {
                    ps.setString(idx++, staff.getAddress());
                } else {
                    ps.setNull(idx++, Types.NVARCHAR);
                }
                setTimestamp(ps, idx++, LocalDateTime.now());
                if (updatePassword) {
                    ps.setString(idx++, staff.getPasswordHash());
                }
                ps.setInt(idx++, staff.getUserId());
                ps.setString(idx, STAFF_ROLE);
                return ps.executeUpdate() > 0;
            }
        } catch (SQLException ex) {
            LOGGER.error("Failed to update staff member with id {}", staff.getUserId(), ex);
            return false;
        }
    }

    public boolean delete(int userId) {
        String sql = "DELETE FROM [USER] WHERE UserID = ? AND Role = ?";
        try (DBContext db = new DBContext()) {
            Connection conn = db.getConnection();
            if (conn == null) {
                LOGGER.error("Database connection is null when deleting staff member id {}", userId);
                return false;
            }
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, userId);
                ps.setString(2, STAFF_ROLE);
                return ps.executeUpdate() > 0;
            }
        } catch (SQLException ex) {
            LOGGER.error("Failed to delete staff member with id {}", userId, ex);
            return false;
        }
    }

    private User mapStaff(ResultSet rs) throws SQLException {
        User staff = new User();
        staff.setUserId(rs.getInt("UserID"));
        staff.setEmployeeCode(rs.getString("EmployeeCode"));
        staff.setFullName(rs.getString("FullName"));
        staff.setEmail(rs.getString("Email"));
        staff.setPhoneNumber(rs.getString("PhoneNumber"));
        staff.setRole(rs.getString("Role"));
        staff.setStatus(rs.getString("Status"));
        staff.setAddress(rs.getString("Address"));
        staff.setCreatedAt(toLocalDateTime(rs.getTimestamp("CreatedAt")));
        staff.setUpdatedAt(toLocalDateTime(rs.getTimestamp("UpdatedAt")));
        return staff;
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
}
