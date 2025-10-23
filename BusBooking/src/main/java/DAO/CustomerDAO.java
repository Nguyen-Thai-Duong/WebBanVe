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
import java.util.logging.Level;
import java.util.logging.Logger;
import model.User;

/**
 * Data access object for managing customer accounts (role = Customer).
 */
public class CustomerDAO {

    private static final Logger LOGGER = Logger.getLogger(CustomerDAO.class.getName());
    private static final String CUSTOMER_ROLE = "Customer";

    private static final String BASE_SELECT = "SELECT UserID, EmployeeCode, FullName, Email, PhoneNumber, Role, Status, Address, CreatedAt, UpdatedAt "
            + "FROM [USER] WHERE Role = ?";

    public List<User> findAll() {
        String sql = BASE_SELECT + " ORDER BY CreatedAt DESC";
        try (DBContext db = new DBContext()) {
            Connection conn = db.getConnection();
            if (conn == null) {
                LOGGER.log(Level.SEVERE, "Database connection is null when loading customers");
                return Collections.emptyList();
            }
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, CUSTOMER_ROLE);
                try (ResultSet rs = ps.executeQuery()) {
                    List<User> customers = new ArrayList<>();
                    while (rs.next()) {
                        customers.add(mapCustomer(rs));
                    }
                    return customers;
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Failed to load customers", ex);
            return Collections.emptyList();
        }
    }

    public User findById(int userId) {
        String sql = BASE_SELECT + " AND UserID = ?";
        try (DBContext db = new DBContext()) {
            Connection conn = db.getConnection();
            if (conn == null) {
                LOGGER.log(Level.SEVERE, "Database connection is null when loading customer id {0}", userId);
                return null;
            }
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, CUSTOMER_ROLE);
                ps.setInt(2, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        return mapCustomer(rs);
                    }
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Failed to find customer with id " + userId, ex);
        }
        return null;
    }

    public boolean insert(User customer) {
        String sql = "INSERT INTO [USER] (EmployeeCode, FullName, Email, PasswordHash, PhoneNumber, Role, Status, Address, CreatedAt, UpdatedAt) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        LocalDateTime now = LocalDateTime.now();
        try (DBContext db = new DBContext()) {
            Connection conn = db.getConnection();
            if (conn == null) {
                LOGGER.log(Level.SEVERE, "Database connection is null when inserting customer");
                return false;
            }
            try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
                ps.setNull(1, Types.NVARCHAR);
                ps.setString(2, customer.getFullName());
                ps.setString(3, customer.getEmail());
                ps.setString(4, customer.getPasswordHash());
                ps.setString(5, customer.getPhoneNumber());
                ps.setString(6, CUSTOMER_ROLE);
                ps.setString(7, customer.getStatus());
                if (customer.getAddress() != null && !customer.getAddress().isBlank()) {
                    ps.setString(8, customer.getAddress());
                } else {
                    ps.setNull(8, Types.NVARCHAR);
                }
                setTimestamp(ps, 9, now);
                setTimestamp(ps, 10, now);
                int affected = ps.executeUpdate();
                if (affected > 0) {
                    try (ResultSet keys = ps.getGeneratedKeys()) {
                        if (keys.next()) {
                            customer.setUserId(keys.getInt(1));
                        }
                    }
                }
                return affected > 0;
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Failed to insert customer", ex);
            return false;
        }
    }

    public boolean update(User customer) {
        if (customer.getUserId() == null) {
            throw new IllegalArgumentException("Customer ID is required for update");
        }
        boolean updatePassword = customer.getPasswordHash() != null && !customer.getPasswordHash().isBlank();
        StringBuilder sql = new StringBuilder("UPDATE [USER] SET FullName = ?, Email = ?, PhoneNumber = ?, Status = ?, Address = ?, UpdatedAt = ?");
        if (updatePassword) {
            sql.append(", PasswordHash = ?");
        }
        sql.append(" WHERE UserID = ? AND Role = ?");

        try (DBContext db = new DBContext()) {
            Connection conn = db.getConnection();
            if (conn == null) {
                LOGGER.log(Level.SEVERE, "Database connection is null when updating customer id {0}", customer.getUserId());
                return false;
            }
            try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
                int idx = 1;
                ps.setString(idx++, customer.getFullName());
                ps.setString(idx++, customer.getEmail());
                ps.setString(idx++, customer.getPhoneNumber());
                ps.setString(idx++, customer.getStatus());
                if (customer.getAddress() != null && !customer.getAddress().isBlank()) {
                    ps.setString(idx++, customer.getAddress());
                } else {
                    ps.setNull(idx++, Types.NVARCHAR);
                }
                setTimestamp(ps, idx++, LocalDateTime.now());
                if (updatePassword) {
                    ps.setString(idx++, customer.getPasswordHash());
                }
                ps.setInt(idx++, customer.getUserId());
                ps.setString(idx, CUSTOMER_ROLE);
                return ps.executeUpdate() > 0;
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Failed to update customer with id " + customer.getUserId(), ex);
            return false;
        }
    }

    public boolean delete(int userId) {
        String sql = "DELETE FROM [USER] WHERE UserID = ? AND Role = ?";
        try (DBContext db = new DBContext()) {
            Connection conn = db.getConnection();
            if (conn == null) {
                LOGGER.log(Level.SEVERE, "Database connection is null when deleting customer id {0}", userId);
                return false;
            }
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, userId);
                ps.setString(2, CUSTOMER_ROLE);
                return ps.executeUpdate() > 0;
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Failed to delete customer with id " + userId, ex);
            return false;
        }
    }

    private User mapCustomer(ResultSet rs) throws SQLException {
        User customer = new User();
        customer.setUserId(rs.getInt("UserID"));
        customer.setEmployeeCode(rs.getString("EmployeeCode"));
        customer.setFullName(rs.getString("FullName"));
        customer.setEmail(rs.getString("Email"));
        customer.setPhoneNumber(rs.getString("PhoneNumber"));
        customer.setRole(rs.getString("Role"));
        customer.setStatus(rs.getString("Status"));
        customer.setAddress(rs.getString("Address"));
        customer.setCreatedAt(toLocalDateTime(rs.getTimestamp("CreatedAt")));
        customer.setUpdatedAt(toLocalDateTime(rs.getTimestamp("UpdatedAt")));
        return customer;
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
