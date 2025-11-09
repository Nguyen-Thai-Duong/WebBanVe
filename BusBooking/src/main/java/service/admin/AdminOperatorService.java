package service.admin;

import DAO.OperatorDAO;
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
 * Service layer for bus operator management in admin module.
 */
public class AdminOperatorService extends BaseAdminService {
    
    private static final Logger LOGGER = LoggerFactory.getLogger(AdminOperatorService.class);
    private static final String DEFAULT_ROLE = "BusOperator";
    
    private final OperatorDAO operatorDAO;
    
    public AdminOperatorService() {
        this.operatorDAO = new OperatorDAO();
    }
    
    /**
     * Get all operators.
     */
    public List<User> getAllOperators() {
        List<User> operators = operatorDAO.findAll();
        return operators != null ? operators : Collections.emptyList();
    }
    
    /**
     * Get operator by ID.
     */
    public User getOperatorById(Integer userId) {
        if (userId == null) {
            return null;
        }
        return operatorDAO.findById(userId);
    }
    
    /**
     * Create a new operator.
     */
    public boolean createOperator(User operator) {
        if (operator == null) {
            LOGGER.warn("Attempted to create null operator");
            return false;
        }
        return operatorDAO.insert(operator);
    }
    
    /**
     * Update an existing operator.
     */
    public boolean updateOperator(User operator) {
        if (operator == null || operator.getUserId() == null) {
            LOGGER.warn("Attempted to update invalid operator");
            return false;
        }
        return operatorDAO.update(operator);
    }
    
    /**
     * Delete an operator.
     */
    public boolean deleteOperator(Integer userId) {
        if (userId == null) {
            LOGGER.warn("Attempted to delete operator with null ID");
            return false;
        }
        return operatorDAO.delete(userId);
    }
    
    /**
     * Build User (operator) from HTTP request parameters.
     */
    public User buildOperatorFromRequest(HttpServletRequest request, String[] operatorStatuses) {
        User operator = new User();
        operator.setFullName(trim(request.getParameter("fullName")));
        operator.setEmail(trim(request.getParameter("email")));
        operator.setPhoneNumber(trim(request.getParameter("phone")));
        operator.setAddress(trim(request.getParameter("address")));
        operator.setStatus(defaultIfBlank(request.getParameter("status"), operatorStatuses[0]));
        operator.setRole(DEFAULT_ROLE);
        return operator;
    }
    
    /**
     * Validate and set password for new operator.
     */
    public boolean validatePassword(HttpSession session, HttpServletRequest request, User operator) {
        String password = trim(request.getParameter("password"));
        if (password == null || password.length() < 6) {
            setFlash(session, "operatorMessage", "Mật khẩu phải có ít nhất 6 ký tự.", "danger");
            return false;
        }
        String hashed = PasswordUtils.hashPassword(password);
        operator.setPasswordHash(hashed);
        return true;
    }
    
    /**
     * Apply password update if present in request (for edit operation).
     */
    public boolean applyPasswordUpdateIfPresent(HttpSession session, HttpServletRequest request, User operator) {
        String password = trim(request.getParameter("password"));
        if (password == null || password.isBlank()) {
            operator.setPasswordHash(null);
            return true;
        }
        if (password.length() < 6) {
            setFlash(session, "operatorMessage", "Mật khẩu phải có ít nhất 6 ký tự.", "danger");
            return false;
        }
        operator.setPasswordHash(PasswordUtils.hashPassword(password));
        return true;
    }
    
    /**
     * Validate operator has required fields.
     */
    public boolean isValidOperator(User operator, boolean requirePassword) {
        boolean passwordReady = !requirePassword || (operator.getPasswordHash() != null && !operator.getPasswordHash().isBlank());
        return operator.getFullName() != null && !operator.getFullName().isBlank()
                && operator.getEmail() != null && !operator.getEmail().isBlank()
                && operator.getPhoneNumber() != null && !operator.getPhoneNumber().isBlank()
                && passwordReady;
    }
    
    /**
     * Validate operator field formats.
     */
    public boolean validateOperatorFields(HttpSession session, User operator) {
        if (!InputValidator.isAlphabeticName(operator.getFullName())) {
            setFlash(session, "operatorMessage", "Họ và tên chỉ được chứa chữ cái và khoảng trắng.", "danger");
            return false;
        }
        if (!InputValidator.isDigitsOnly(operator.getPhoneNumber())) {
            setFlash(session, "operatorMessage", "Số điện thoại chỉ được chứa chữ số.", "danger");
            return false;
        }
        return true;
    }
}
