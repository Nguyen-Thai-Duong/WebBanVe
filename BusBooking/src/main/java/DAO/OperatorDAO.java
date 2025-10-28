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
 * Data access object for managing bus operator accounts (role = BusOperator).
 */
public class OperatorDAO {

    private static final Logger LOGGER = LoggerFactory.getLogger(OperatorDAO.class);
    private static final String OPERATOR_ROLE = "BusOperator";
    private static final String BASE_SELECT = "SELECT UserID, EmployeeCode, FullName, Email, PhoneNumber, Role, Status, Address, CreatedAt, UpdatedAt "
            + "FROM [USER] WHERE Role = ?";

    public List<User> findAll() {
        String sql = BASE_SELECT + " ORDER BY CreatedAt DESC";
        try (DBContext db = new DBContext()) {
            Connection conn = db.getConnection();
            if (conn == null) {
                LOGGER.error("Database connection is null when loading operators");
                return Collections.emptyList();
            }
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, OPERATOR_ROLE);
                try (ResultSet rs = ps.executeQuery()) {
                    List<User> operators = new ArrayList<>();
                    while (rs.next()) {
                        operators.add(mapUser(rs));
                    }
                    return operators;
                }
            }
        } catch (SQLException ex) {
            LOGGER.error("Failed to load operators", ex);
            return Collections.emptyList();
        }
    }

    public User findById(int userId) {
        String sql = BASE_SELECT + " AND UserID = ?";
        try (DBContext db = new DBContext()) {
            Connection conn = db.getConnection();
            if (conn == null) {
                LOGGER.error("Database connection is null when finding operator id {}", userId);
                return null;
            }
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, OPERATOR_ROLE);
                ps.setInt(2, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        return mapUser(rs);
                    }
                }
            }
        } catch (SQLException ex) {
            LOGGER.error("Failed to find operator id {}", userId, ex);
        }
        return null;
    }

    public boolean insert(User operator) {
        String sql = "INSERT INTO [USER] (FullName, Email, PasswordHash, PhoneNumber, Role, Status, Address, CreatedAt, UpdatedAt) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        LocalDateTime now = LocalDateTime.now();
        try (DBContext db = new DBContext()) {
            Connection conn = db.getConnection();
            if (conn == null) {
                LOGGER.error("Database connection is null when inserting operator");
                return false;
            }
            try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
                int idx = 1;
                ps.setString(idx++, operator.getFullName());
                ps.setString(idx++, operator.getEmail());
                ps.setString(idx++, operator.getPasswordHash());
                ps.setString(idx++, operator.getPhoneNumber());
                ps.setString(idx++, OPERATOR_ROLE);
                ps.setString(idx++, operator.getStatus());
                if (operator.getAddress() != null && !operator.getAddress().isBlank()) {
                    ps.setString(idx++, operator.getAddress());
                } else {
                    ps.setNull(idx++, Types.NVARCHAR);
                }
                ps.setTimestamp(idx++, Timestamp.valueOf(now));
                ps.setTimestamp(idx, Timestamp.valueOf(now));
                int affected = ps.executeUpdate();
                if (affected > 0) {
                    try (ResultSet keys = ps.getGeneratedKeys()) {
                        if (keys.next()) {
                            operator.setUserId(keys.getInt(1));
                        }
                    }
                }
                return affected > 0;
            }
        } catch (SQLException ex) {
            LOGGER.error("Failed to insert operator {}", operator.getEmail(), ex);
            return false;
        }
    }

    public boolean update(User operator) {
        if (operator.getUserId() == null) {
            throw new IllegalArgumentException("Operator ID is required for update");
        }
        boolean updatePassword = operator.getPasswordHash() != null && !operator.getPasswordHash().isBlank();
        StringBuilder sql = new StringBuilder("UPDATE [USER] SET FullName = ?, Email = ?, PhoneNumber = ?, Status = ?, Address = ?, UpdatedAt = ?");
        if (updatePassword) {
            sql.append(", PasswordHash = ?");
        }
        sql.append(" WHERE UserID = ? AND Role = ?");

        try (DBContext db = new DBContext()) {
            Connection conn = db.getConnection();
            if (conn == null) {
                LOGGER.error("Database connection is null when updating operator id {}", operator.getUserId());
                return false;
            }
            try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
                int idx = 1;
                ps.setString(idx++, operator.getFullName());
                ps.setString(idx++, operator.getEmail());
                ps.setString(idx++, operator.getPhoneNumber());
                ps.setString(idx++, operator.getStatus());
                if (operator.getAddress() != null && !operator.getAddress().isBlank()) {
                    ps.setString(idx++, operator.getAddress());
                } else {
                    ps.setNull(idx++, Types.NVARCHAR);
                }
                ps.setTimestamp(idx++, Timestamp.valueOf(LocalDateTime.now()));
                if (updatePassword) {
                    ps.setString(idx++, operator.getPasswordHash());
                }
                ps.setInt(idx++, operator.getUserId());
                ps.setString(idx, OPERATOR_ROLE);
                return ps.executeUpdate() > 0;
            }
        } catch (SQLException ex) {
            LOGGER.error("Failed to update operator id {}", operator.getUserId(), ex);
            return false;
        }
    }

    public boolean delete(int userId) {
        String sql = "DELETE FROM [USER] WHERE UserID = ? AND Role = ?";
        try (DBContext db = new DBContext()) {
            Connection conn = db.getConnection();
            if (conn == null) {
                LOGGER.error("Database connection is null when deleting operator id {}", userId);
                return false;
            }
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, userId);
                ps.setString(2, OPERATOR_ROLE);
                return ps.executeUpdate() > 0;
            }
        } catch (SQLException ex) {
            LOGGER.error("Failed to delete operator id {}", userId, ex);
            return false;
        }
    }

    private User mapUser(ResultSet rs) throws SQLException {
        User operator = new User();
        operator.setUserId(rs.getInt("UserID"));
        operator.setEmployeeCode(rs.getString("EmployeeCode"));
        operator.setFullName(rs.getString("FullName"));
        operator.setEmail(rs.getString("Email"));
        operator.setPhoneNumber(rs.getString("PhoneNumber"));
        operator.setRole(rs.getString("Role"));
        operator.setStatus(rs.getString("Status"));
        operator.setAddress(rs.getString("Address"));
        operator.setCreatedAt(toLocalDateTime(rs.getTimestamp("CreatedAt")));
        operator.setUpdatedAt(toLocalDateTime(rs.getTimestamp("UpdatedAt")));
        return operator;
    }

    private LocalDateTime toLocalDateTime(Timestamp timestamp) {
        return timestamp != null ? timestamp.toLocalDateTime() : null;
    }
}
