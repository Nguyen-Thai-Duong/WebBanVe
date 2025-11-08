package DAO;

import DBContext.DBContext;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.sql.Types;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import model.User;
import model.Vehicle;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Data access layer for vehicle management.
 */
public class VehicleDAO {

    private static final Logger LOGGER = LoggerFactory.getLogger(VehicleDAO.class);

    private static final String VEHICLE_SELECT = "SELECT v.VehicleID, v.EmployeeCode, v.LicensePlate, v.Model, v.Capacity, v.DateAdded, "
            + "v.MaintenanceIntervalDays, v.LastMaintenanceDate, v.LastRepairDate, v.Details, "
            + "v.VehicleStatus, v.CurrentCondition, "
            + "u.UserID, u.FullName, u.Email, u.PhoneNumber, u.Status AS OperatorStatus "
            + "FROM VEHICLE v LEFT JOIN [USER] u ON v.EmployeeCode = u.EmployeeCode";

    public List<Vehicle> findAll() {
        String sql = VEHICLE_SELECT + " ORDER BY v.DateAdded DESC";
        try (DBContext db = new DBContext()) {
            Connection conn = db.getConnection();
            if (conn == null) {
                LOGGER.error("Database connection is null while loading vehicles");
                return Collections.emptyList();
            }
            try (PreparedStatement ps = conn.prepareStatement(sql);
                    ResultSet rs = ps.executeQuery()) {
                List<Vehicle> vehicles = new ArrayList<>();
                while (rs.next()) {
                    vehicles.add(mapVehicle(rs));
                }
                return vehicles;
            }
        } catch (SQLException ex) {
            LOGGER.error("Failed to load vehicles", ex);
            return Collections.emptyList();
        }
    }

    public Vehicle findById(int vehicleId) {
        String sql = VEHICLE_SELECT + " WHERE v.VehicleID = ?";
        try (DBContext db = new DBContext()) {
            Connection conn = db.getConnection();
            if (conn == null) {
                LOGGER.error("Database connection is null while finding vehicle id {}", vehicleId);
                return null;
            }
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, vehicleId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        return mapVehicle(rs);
                    }
                }
            }
        } catch (SQLException ex) {
            LOGGER.error("Failed to find vehicle id {}", vehicleId, ex);
        }
        return null;
    }

    public boolean insert(Vehicle vehicle) {
        String sql = "INSERT INTO VEHICLE (EmployeeCode, LicensePlate, Model, Capacity, DateAdded, "
                + "MaintenanceIntervalDays, LastMaintenanceDate, LastRepairDate, Details, VehicleStatus, CurrentCondition) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        LocalDateTime dateAdded = vehicle.getDateAdded() != null ? vehicle.getDateAdded() : LocalDateTime.now();
        try (DBContext db = new DBContext()) {
            Connection conn = db.getConnection();
            if (conn == null) {
                LOGGER.error("Database connection is null while inserting vehicle");
                return false;
            }
            try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
                int idx = 1;
                setNullableString(ps, idx++, getEmployeeCode(vehicle));
                ps.setString(idx++, vehicle.getLicensePlate());
                setNullableString(ps, idx++, vehicle.getModel());
                setNullableInteger(ps, idx++, vehicle.getCapacity());
                setTimestamp(ps, idx++, dateAdded);
                setNullableInteger(ps, idx++, vehicle.getMaintenanceIntervalDays());
                setDate(ps, idx++, vehicle.getLastMaintenanceDate());
                setDate(ps, idx++, vehicle.getLastRepairDate());
                setNullableString(ps, idx++, vehicle.getDetails());
                ps.setString(idx++, vehicle.getVehicleStatus());
                setNullableString(ps, idx++, vehicle.getCurrentCondition());
                int affected = ps.executeUpdate();
                if (affected > 0) {
                    try (ResultSet keys = ps.getGeneratedKeys()) {
                        if (keys.next()) {
                            vehicle.setVehicleId(keys.getInt(1));
                        }
                    }
                }
                return affected > 0;
            }
        } catch (SQLException ex) {
            LOGGER.error("Failed to insert vehicle with plate {}", vehicle.getLicensePlate(), ex);
            return false;
        }
    }

    public boolean update(Vehicle vehicle) {
        if (vehicle.getVehicleId() == null) {
            throw new IllegalArgumentException("Vehicle ID is required for update");
        }
        String sql = "UPDATE VEHICLE SET EmployeeCode = ?, LicensePlate = ?, Model = ?, Capacity = ?, "
                + "MaintenanceIntervalDays = ?, LastMaintenanceDate = ?, LastRepairDate = ?, Details = ?, "
                + "VehicleStatus = ?, CurrentCondition = ? WHERE VehicleID = ?";
        try (DBContext db = new DBContext()) {
            Connection conn = db.getConnection();
            if (conn == null) {
                LOGGER.error("Database connection is null while updating vehicle id {}", vehicle.getVehicleId());
                return false;
            }
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                int idx = 1;
                setNullableString(ps, idx++, getEmployeeCode(vehicle));
                ps.setString(idx++, vehicle.getLicensePlate());
                setNullableString(ps, idx++, vehicle.getModel());
                setNullableInteger(ps, idx++, vehicle.getCapacity());
                setNullableInteger(ps, idx++, vehicle.getMaintenanceIntervalDays());
                setDate(ps, idx++, vehicle.getLastMaintenanceDate());
                setDate(ps, idx++, vehicle.getLastRepairDate());
                setNullableString(ps, idx++, vehicle.getDetails());
                ps.setString(idx++, vehicle.getVehicleStatus());
                setNullableString(ps, idx++, vehicle.getCurrentCondition());
                ps.setInt(idx, vehicle.getVehicleId());
                return ps.executeUpdate() > 0;
            }
        } catch (SQLException ex) {
            LOGGER.error("Failed to update vehicle id {}", vehicle.getVehicleId(), ex);
            return false;
        }
    }

    public boolean delete(int vehicleId) {
        String sql = "DELETE FROM VEHICLE WHERE VehicleID = ?";
        try (DBContext db = new DBContext()) {
            Connection conn = db.getConnection();
            if (conn == null) {
                LOGGER.error("Database connection is null while deleting vehicle id {}", vehicleId);
                return false;
            }
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, vehicleId);
                return ps.executeUpdate() > 0;
            }
        } catch (SQLException ex) {
            LOGGER.error("Failed to delete vehicle id {}", vehicleId, ex);
            return false;
        }
    }

    private Vehicle mapVehicle(ResultSet rs) throws SQLException {
        Vehicle vehicle = new Vehicle();
        vehicle.setVehicleId(rs.getInt("VehicleID"));
        vehicle.setLicensePlate(rs.getString("LicensePlate"));
        vehicle.setModel(rs.getString("Model"));
        vehicle.setCapacity(getInteger(rs, "Capacity"));
        vehicle.setDateAdded(getLocalDateTime(rs.getTimestamp("DateAdded")));
        vehicle.setMaintenanceIntervalDays(getInteger(rs, "MaintenanceIntervalDays"));
        vehicle.setLastMaintenanceDate(getLocalDate(rs.getDate("LastMaintenanceDate")));
        vehicle.setLastRepairDate(getLocalDate(rs.getDate("LastRepairDate")));
        vehicle.setDetails(rs.getString("Details"));
        vehicle.setVehicleStatus(rs.getString("VehicleStatus"));
        vehicle.setCurrentCondition(rs.getString("CurrentCondition"));

        String employeeCode = rs.getString("EmployeeCode");
        if (employeeCode != null) {
            User operator = new User();
            operator.setEmployeeCode(employeeCode);
            operator.setUserId(getInteger(rs, "UserID"));
            operator.setFullName(rs.getString("FullName"));
            operator.setEmail(rs.getString("Email"));
            operator.setPhoneNumber(rs.getString("PhoneNumber"));
            operator.setStatus(rs.getString("OperatorStatus"));
            vehicle.setOperator(operator);
        }
        return vehicle;
    }

    private void setNullableString(PreparedStatement ps, int index, String value) throws SQLException {
        if (value != null && !value.isBlank()) {
            ps.setString(index, value);
        } else {
            ps.setNull(index, Types.NVARCHAR);
        }
    }

    private void setNullableInteger(PreparedStatement ps, int index, Integer value) throws SQLException {
        if (value != null) {
            ps.setInt(index, value);
        } else {
            ps.setNull(index, Types.INTEGER);
        }
    }

    private void setTimestamp(PreparedStatement ps, int index, LocalDateTime value) throws SQLException {
        if (value != null) {
            ps.setTimestamp(index, Timestamp.valueOf(value));
        } else {
            ps.setNull(index, Types.TIMESTAMP);
        }
    }

    private void setDate(PreparedStatement ps, int index, LocalDate value) throws SQLException {
        if (value != null) {
            ps.setDate(index, Date.valueOf(value));
        } else {
            ps.setNull(index, Types.DATE);
        }
    }

    public int countVehiclesByOperator(int operatorId) {
        String sql = "SELECT COUNT(*) FROM VEHICLE v JOIN [USER] u ON v.EmployeeCode = u.EmployeeCode WHERE u.UserID = ?";
        try (DBContext db = new DBContext()) {
            Connection conn = db.getConnection();
            if (conn == null) {
                LOGGER.error("Database connection is null when counting vehicles for operator {}", operatorId);
                return 0;
            }
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, operatorId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        return rs.getInt(1);
                    }
                }
            }
        } catch (SQLException ex) {
            LOGGER.error("Failed to count vehicles for operator {}", operatorId, ex);
        }
        return 0;
    }

    public int countActiveVehiclesByOperator(int operatorId) {
        String sql = "SELECT COUNT(*) FROM VEHICLE v JOIN [USER] u ON v.EmployeeCode = u.EmployeeCode " +
                "WHERE u.UserID = ? AND v.VehicleStatus = 'Available'";
        try (DBContext db = new DBContext()) {
            Connection conn = db.getConnection();
            if (conn == null) {
                LOGGER.error("Database connection is null when counting active vehicles for operator {}", operatorId);
                return 0;
            }
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, operatorId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        return rs.getInt(1);
                    }
                }
            }
        } catch (SQLException ex) {
            LOGGER.error("Failed to count active vehicles for operator {}", operatorId, ex);
        }
        return 0;
    }

    private LocalDateTime getLocalDateTime(Timestamp timestamp) {
        return timestamp != null ? timestamp.toLocalDateTime() : null;
    }

    private LocalDate getLocalDate(Date date) {
        return date != null ? date.toLocalDate() : null;
    }

    private Integer getInteger(ResultSet rs, String columnLabel) throws SQLException {
        int value = rs.getInt(columnLabel);
        return rs.wasNull() ? null : value;
    }

    private String getEmployeeCode(Vehicle vehicle) {
        return vehicle.getOperator() != null ? vehicle.getOperator().getEmployeeCode() : null;
    }
}
