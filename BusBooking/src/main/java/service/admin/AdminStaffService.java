package service.admin;

import DAO.StaffDAO;
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
 * Service layer for staff management in admin module.
 */
public class AdminStaffService extends BaseAdminService {
    
    private static final Logger LOGGER = LoggerFactory.getLogger(AdminStaffService.class);
    private static final String DEFAULT_ROLE = "Staff";
    
    private final StaffDAO staffDAO;
    
    public AdminStaffService() {
        this.staffDAO = new StaffDAO();
    }
    
    /**
     * Get all staff members.
     */
    public List<User> getAllStaff() {
        List<User> staffMembers = staffDAO.findAll();
        return staffMembers != null ? staffMembers : Collections.emptyList();
    }
    
    /**
     * Get staff by ID.
     */
    public User getStaffById(Integer userId) {
        if (userId == null) {
            return null;
        }
        return staffDAO.findById(userId);
    }
    
    /**
     * Create a new staff member.
     */
    public boolean createStaff(User staff) {
        if (staff == null) {
            LOGGER.warn("Attempted to create null staff");
            return false;
        }
        return staffDAO.insert(staff);
    }
    
    /**
     * Update an existing staff member.
     */
    public boolean updateStaff(User staff) {
        if (staff == null || staff.getUserId() == null) {
            LOGGER.warn("Attempted to update invalid staff");
            return false;
        }
        return staffDAO.update(staff);
    }
    
    /**
     * Delete a staff member.
     */
    public boolean deleteStaff(Integer userId) {
        if (userId == null) {
            LOGGER.warn("Attempted to delete staff with null ID");
            return false;
        }
        return staffDAO.delete(userId);
    }
    
    /**
     * Build User (staff) from HTTP request parameters.
     */
    public User buildStaffFromRequest(HttpServletRequest request, String[] staffStatuses) {
        User staff = new User();
        staff.setFullName(trim(request.getParameter("fullName")));
        staff.setEmail(trim(request.getParameter("email")));
        staff.setPhoneNumber(trim(request.getParameter("phone")));
        staff.setAddress(trim(request.getParameter("address")));
        staff.setStatus(defaultIfBlank(request.getParameter("status"), staffStatuses[0]));
        staff.setRole(DEFAULT_ROLE);
        return staff;
    }
    
    /**
     * Validate and set password for new staff.
     */
    public boolean validatePassword(HttpSession session, HttpServletRequest request, User staff) {
        String password = trim(request.getParameter("password"));
        if (password == null || password.length() < 6) {
            setFlash(session, "staffMessage", "Mật khẩu phải có ít nhất 6 ký tự.", "danger");
            return false;
        }
        String hashed = PasswordUtils.hashPassword(password);
        if (hashed == null) {
            setFlash(session, "staffMessage", "Không thể tạo mật khẩu, vui lòng thử lại.", "danger");
            return false;
        }
        staff.setPasswordHash(hashed);
        return true;
    }
    
    /**
     * Apply password update if present in request (for edit operation).
     */
    public boolean applyPasswordUpdateIfPresent(HttpSession session, HttpServletRequest request, User staff) {
        String password = trim(request.getParameter("password"));
        if (password == null || password.isBlank()) {
            staff.setPasswordHash(null);
            return true;
        }
        if (password.length() < 6) {
            setFlash(session, "staffMessage", "Mật khẩu phải có ít nhất 6 ký tự.", "danger");
            return false;
        }
        String hashed = PasswordUtils.hashPassword(password);
        if (hashed == null) {
            setFlash(session, "staffMessage", "Không thể cập nhật mật khẩu, vui lòng thử lại.", "danger");
            return false;
        }
        staff.setPasswordHash(hashed);
        return true;
    }
    
    /**
     * Validate staff has required fields.
     */
    public boolean isValidStaff(User staff, boolean requirePassword) {
        boolean passwordReady = !requirePassword || (staff.getPasswordHash() != null && !staff.getPasswordHash().isBlank());
        return staff.getFullName() != null && !staff.getFullName().isBlank()
                && staff.getEmail() != null && !staff.getEmail().isBlank()
                && staff.getPhoneNumber() != null && !staff.getPhoneNumber().isBlank()
                && passwordReady;
    }
    
    /**
     * Validate staff field formats.
     */
    public boolean validateStaffFields(HttpSession session, User staff) {
        if (!InputValidator.isAlphabeticName(staff.getFullName())) {
            setFlash(session, "staffMessage", "Họ và tên chỉ được chứa chữ cái và khoảng trắng.", "danger");
            return false;
        }
        if (!InputValidator.isDigitsOnly(staff.getPhoneNumber())) {
            setFlash(session, "staffMessage", "Số điện thoại chỉ được chứa chữ số.", "danger");
            return false;
        }
        return true;
    }
}
