package service.admin;

import DAO.VehicleDAO;
import DAO.OperatorDAO;
import model.Vehicle;
import model.User;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.Collections;
import java.util.List;

/**
 * Service layer for vehicle management in admin module.
 */
public class AdminVehicleService extends BaseAdminService {
    
    private static final Logger LOGGER = LoggerFactory.getLogger(AdminVehicleService.class);
    
    private final VehicleDAO vehicleDAO;
    private final OperatorDAO operatorDAO;
    
    public AdminVehicleService() {
        this.vehicleDAO = new VehicleDAO();
        this.operatorDAO = new OperatorDAO();
    }
    
    /**
     * Get all vehicles.
     */
    public List<Vehicle> getAllVehicles() {
        List<Vehicle> vehicles = vehicleDAO.findAll();
        return vehicles != null ? vehicles : Collections.emptyList();
    }
    
    /**
     * Get vehicle by ID.
     */
    public Vehicle getVehicleById(Integer vehicleId) {
        if (vehicleId == null) {
            return null;
        }
        return vehicleDAO.findById(vehicleId);
    }
    
    /**
     * Get all operators for selection.
     */
    public List<User> getAllOperators() {
        List<User> operators = operatorDAO.findAll();
        return operators != null ? operators : Collections.emptyList();
    }
    
    /**
     * Create a new vehicle.
     */
    public boolean createVehicle(Vehicle vehicle) {
        if (vehicle == null) {
            LOGGER.warn("Attempted to create null vehicle");
            return false;
        }
        return vehicleDAO.insert(vehicle);
    }
    
    /**
     * Update an existing vehicle.
     */
    public boolean updateVehicle(Vehicle vehicle) {
        if (vehicle == null || vehicle.getVehicleId() == null) {
            LOGGER.warn("Attempted to update invalid vehicle");
            return false;
        }
        return vehicleDAO.update(vehicle);
    }
    
    /**
     * Delete a vehicle.
     */
    public boolean deleteVehicle(Integer vehicleId) {
        if (vehicleId == null) {
            LOGGER.warn("Attempted to delete vehicle with null ID");
            return false;
        }
        return vehicleDAO.delete(vehicleId);
    }
}
