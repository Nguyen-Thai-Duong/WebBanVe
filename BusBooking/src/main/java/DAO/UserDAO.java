package DAO;

import DBContext.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.logging.Level;
import java.util.logging.Logger;
import model.User;

/**
 * Data access helper for user authentication and lookups.
 */
public class UserDAO {

    private static final Logger LOGGER = Logger.getLogger(UserDAO.class.getName());
    private static final String BASE_SELECT = "SELECT UserID, EmployeeCode, FullName, Email, PasswordHash, PhoneNumber, Role, Status, Address, CreatedAt, UpdatedAt FROM [USER]";

    public User findByIdentifier(String identifier) {
        if (identifier == null || identifier.isBlank()) {
            return null;
        }
        String sql = BASE_SELECT + " WHERE Email = ? OR PhoneNumber = ?";
        try (DBContext db = new DBContext()) {
            Connection conn = db.getConnection();
            if (conn == null) {
                LOGGER.log(Level.SEVERE, "Database connection is null when finding user by identifier {0}", identifier);
                return null;
            }
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, identifier);
                ps.setString(2, identifier);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        return mapUser(rs);
                    }
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Failed to find user by identifier " + identifier, ex);
        }
        return null;
    }

    public boolean emailExists(String email) {
        if (email == null || email.isBlank()) {
            return false;
        }
        String sql = "SELECT 1 FROM [USER] WHERE Email = ?";
        try (DBContext db = new DBContext()) {
            Connection conn = db.getConnection();
            if (conn == null) {
                LOGGER.log(Level.SEVERE, "Database connection is null when checking email existence {0}", email);
                return false;
            }
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, email);
                try (ResultSet rs = ps.executeQuery()) {
                    return rs.next();
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Failed to check email existence " + email, ex);
            return false;
        }
    }

    public boolean phoneExists(String phone) {
        if (phone == null || phone.isBlank()) {
            return false;
        }
        String sql = "SELECT 1 FROM [USER] WHERE PhoneNumber = ?";
        try (DBContext db = new DBContext()) {
            Connection conn = db.getConnection();
            if (conn == null) {
                LOGGER.log(Level.SEVERE, "Database connection is null when checking phone existence {0}", phone);
                return false;
            }
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, phone);
                try (ResultSet rs = ps.executeQuery()) {
                    return rs.next();
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Failed to check phone existence " + phone, ex);
            return false;
        }
    }

    public boolean phoneExistsForOtherUser(String phone, int excludeUserId) {
        if (phone == null || phone.isBlank()) {
            return false;
        }
        String sql = "SELECT 1 FROM [USER] WHERE PhoneNumber = ? AND UserID <> ?";
        try (DBContext db = new DBContext()) {
            Connection conn = db.getConnection();
            if (conn == null) {
                LOGGER.log(Level.SEVERE, "Database connection is null when checking phone existence for {0}", phone);
                return false;
            }
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, phone);
                ps.setInt(2, excludeUserId);
                try (ResultSet rs = ps.executeQuery()) {
                    return rs.next();
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Failed to check phone existence for " + phone, ex);
            return false;
        }
    }

    public Integer createCustomer(String fullName, String email, String phoneNumber, String passwordHash) {
    String sql = "INSERT INTO [USER] (FullName, Email, PasswordHash, PhoneNumber, Role, Status, CreatedAt, UpdatedAt) "
        + "VALUES (?, ?, ?, ?, ?, ?, GETDATE(), GETDATE())";
        try (DBContext db = new DBContext()) {
            Connection conn = db.getConnection();
            if (conn == null) {
                LOGGER.log(Level.SEVERE, "Database connection is null when creating customer account for {0}", email);
                return null;
            }
            boolean previousAutoCommit = conn.getAutoCommit();
            conn.setAutoCommit(false);
            try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
                ps.setString(1, fullName);
                ps.setString(2, email);
                ps.setString(3, passwordHash);
                ps.setString(4, phoneNumber);
                ps.setString(5, "Customer");
                ps.setString(6, "Active");
                int affected = ps.executeUpdate();
                if (affected == 0) {
                    conn.rollback();
                    conn.setAutoCommit(previousAutoCommit);
                    return null;
                }

                Integer generatedId = null;
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        generatedId = rs.getInt(1);
                    }
                }
                if (generatedId == null || generatedId == 0) {
                    try (PreparedStatement keyStmt = conn.prepareStatement("SELECT CAST(SCOPE_IDENTITY() AS INT) AS NewId")) {
                        try (ResultSet keyRs = keyStmt.executeQuery()) {
                            if (keyRs.next()) {
                                generatedId = keyRs.getInt("NewId");
                            }
                        }
                    }
                }

                if (generatedId == null || generatedId == 0) {
                    LOGGER.log(Level.WARNING, "Customer account created but failed to retrieve generated ID for email {0}", email);
                    generatedId = -1;
                }

                conn.commit();
                conn.setAutoCommit(previousAutoCommit);
                return generatedId;
            } catch (SQLException ex) {
                conn.rollback();
                throw ex;
            } finally {
                conn.setAutoCommit(previousAutoCommit);
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Failed to create customer account for " + email, ex);
            throw new RuntimeException("REGISTRATION_DATABASE_ERROR", ex);
        }
    }

    public boolean updateCustomerProfile(int userId, String fullName, String phoneNumber, String address) {
        String sql = "UPDATE [USER] SET FullName = ?, PhoneNumber = ?, Address = ?, UpdatedAt = GETDATE() WHERE UserID = ?";
        try (DBContext db = new DBContext()) {
            Connection conn = db.getConnection();
            if (conn == null) {
                LOGGER.log(Level.SEVERE, "Database connection is null when updating profile for user {0}", userId);
                return false;
            }
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, fullName);
                ps.setString(2, phoneNumber);
                ps.setString(3, address);
                ps.setInt(4, userId);
                return ps.executeUpdate() > 0;
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Failed to update profile for user " + userId, ex);
            return false;
        }
    }

    public User findById(int userId) {
        String sql = BASE_SELECT + " WHERE UserID = ?";
        try (DBContext db = new DBContext()) {
            Connection conn = db.getConnection();
            if (conn == null) {
                LOGGER.log(Level.SEVERE, "Database connection is null when finding user by id {0}", userId);
                return null;
            }
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        return mapUser(rs);
                    }
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Failed to find user by id " + userId, ex);
        }
        return null;
    }

    private User mapUser(ResultSet rs) throws SQLException {
        User user = new User();
        user.setUserId(rs.getInt("UserID"));
        user.setEmployeeCode(rs.getString("EmployeeCode"));
        user.setFullName(rs.getString("FullName"));
        user.setEmail(rs.getString("Email"));
        user.setPasswordHash(rs.getString("PasswordHash"));
        user.setPhoneNumber(rs.getString("PhoneNumber"));
        String role = rs.getString("Role");
        user.setRole(role);
        user.setStatus(rs.getString("Status"));
        user.setAddress(rs.getString("Address"));
        java.sql.Timestamp created = rs.getTimestamp("CreatedAt");
        if (created != null) {
            user.setCreatedAt(created.toLocalDateTime());
        }
        java.sql.Timestamp updated = rs.getTimestamp("UpdatedAt");
        if (updated != null) {
            user.setUpdatedAt(updated.toLocalDateTime());
        }
        return user;
    }


    public boolean updatePassword(int userId, String passwordHash) {
        String sql = "UPDATE [USER] SET PasswordHash = ?, UpdatedAt = GETDATE() WHERE UserID = ?";
        try (DBContext db = new DBContext()) {
            Connection conn = db.getConnection();
            if (conn == null) {
                LOGGER.log(Level.SEVERE, "Database connection is null when updating password for user {0}", userId);
                return false;
            }
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, passwordHash);
                ps.setInt(2, userId);
                return ps.executeUpdate() > 0;
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Failed to update password for user " + userId, ex);
            return false;
        }
    }
}
