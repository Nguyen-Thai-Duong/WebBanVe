package service.admin;

import DAO.CustomerDAO;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import model.User;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import util.InputValidator;
import util.PasswordUtils;

import java.util.Collections;
import java.util.List;

/**
 * Service layer for customer management in admin module.
 */
public class AdminCustomerService extends BaseAdminService {
    
    private static final Logger LOGGER = LoggerFactory.getLogger(AdminCustomerService.class);
    private static final String DEFAULT_ROLE = "Customer";
    
    private final CustomerDAO customerDAO;
    
    public AdminCustomerService() {
        this.customerDAO = new CustomerDAO();
    }
    
    /**
     * Get all customers.
     */
    public List<User> getAllCustomers() {
        List<User> customers = customerDAO.findAll();
        return customers != null ? customers : Collections.emptyList();
    }
    
    /**
     * Get customer by ID.
     */
    public User getCustomerById(Integer userId) {
        if (userId == null) {
            return null;
        }
        return customerDAO.findById(userId);
    }
    
    /**
     * Create a new customer.
     */
    public boolean createCustomer(User customer) {
        if (customer == null) {
            LOGGER.warn("Attempted to create null customer");
            return false;
        }
        return customerDAO.insert(customer);
    }
    
    /**
     * Update an existing customer.
     */
    public boolean updateCustomer(User customer) {
        if (customer == null || customer.getUserId() == null) {
            LOGGER.warn("Attempted to update invalid customer");
            return false;
        }
        return customerDAO.update(customer);
    }
    
    /**
     * Delete a customer.
     */
    public boolean deleteCustomer(Integer userId) {
        if (userId == null) {
            LOGGER.warn("Attempted to delete customer with null ID");
            return false;
        }
        return customerDAO.delete(userId);
    }
    
    /**
     * Build User (customer) from HTTP request parameters.
     */
    public User buildCustomerFromRequest(HttpServletRequest request, boolean requirePassword) {
        User customer = new User();
        customer.setFullName(defaultIfBlank(request.getParameter("fullName"), null));
        customer.setEmail(defaultIfBlank(request.getParameter("email"), null));
        customer.setPhoneNumber(defaultIfBlank(request.getParameter("phoneNumber"), null));
        customer.setAddress(defaultIfBlank(request.getParameter("address"), null));
        customer.setStatus(defaultIfBlank(request.getParameter("status"), "Active"));
        customer.setRole(DEFAULT_ROLE);

        String password = request.getParameter("password");
        if (password != null && !password.isBlank()) {
            try {
                customer.setPasswordHash(PasswordUtils.hashPassword(password));
            } catch (RuntimeException ex) {
                LOGGER.error("Không thể mã hóa mật khẩu", ex);
                customer.setPasswordHash(null);
            }
        } else if (requirePassword) {
            customer.setPasswordHash(null);
        }
        return customer;
    }
    
    /**
     * Validate customer has required fields.
     */
    public boolean isValidCustomer(User customer, boolean requirePassword) {
        return customer.getFullName() != null && !customer.getFullName().isBlank()
                && customer.getEmail() != null && !customer.getEmail().isBlank()
                && customer.getPhoneNumber() != null && !customer.getPhoneNumber().isBlank()
                && (!requirePassword || (customer.getPasswordHash() != null && !customer.getPasswordHash().isBlank()));
    }
    
    /**
     * Validate customer field formats.
     */
    public boolean validateCustomerFields(HttpSession session, User customer) {
        if (!InputValidator.isAlphabeticName(customer.getFullName())) {
            setFlash(session, "customerMessage", "Họ và tên chỉ được chứa chữ cái và khoảng trắng.", "danger");
            return false;
        }
        if (!InputValidator.isDigitsOnly(customer.getPhoneNumber())) {
            setFlash(session, "customerMessage", "Số điện thoại chỉ được chứa chữ số.", "danger");
            return false;
        }
        return true;
    }
}
