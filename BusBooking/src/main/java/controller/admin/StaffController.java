package controller.admin;

import DAO.StaffDAO;
import util.PasswordUtils;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.time.format.DateTimeFormatter;
import java.util.Collections;
import java.util.List;
import model.User;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import util.InputValidator;

@WebServlet(name = "StaffController", urlPatterns = {"/admin/staff", "/admin/staff/new", "/admin/staff/edit"})
public class StaffController extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = LoggerFactory.getLogger(StaffController.class);
    private static final String DEFAULT_ROLE = "Staff";
    private static final String[] STAFF_STATUSES = {"Active", "Inactive", "Suspended", "Locked"};
    private static final DateTimeFormatter DATE_FORMATTER = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");

    private final StaffDAO staffDAO = new StaffDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String path = request.getServletPath();
        if ("/admin/staff/new".equals(path)) {
            showCreateForm(request, response);
        } else if ("/admin/staff/edit".equals(path)) {
            showEditForm(request, response);
        } else {
            showStaffList(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String path = request.getServletPath();
        if ("/admin/staff".equals(path)) {
            handleActionPost(request, response);
        } else if ("/admin/staff/new".equals(path)) {
            handleCreate(request, response);
        } else if ("/admin/staff/edit".equals(path)) {
            handleUpdate(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/staff");
        }
    }

    private void handleActionPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String action = request.getParameter("action");
        if ("delete".equals(action)) {
            handleDelete(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/staff");
        }
    }

    private void showStaffList(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        List<User> staffMembers = staffDAO.findAll();
        if (staffMembers == null) {
            staffMembers = Collections.emptyList();
        }
        request.setAttribute("staffMembers", staffMembers);
        request.setAttribute("staffStatuses", STAFF_STATUSES);
        request.setAttribute("dateFormatter", DATE_FORMATTER);
        request.setAttribute("activeMenu", "staff");
        forward(request, response, "/WEB-INF/admin/staff/staff-list.jsp");
    }

    private void showCreateForm(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        prepareStaffForm(request, null);
        forward(request, response, "/WEB-INF/admin/staff/staff-create.jsp");
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Integer userId = parseInteger(request.getParameter("id"));
        if (userId == null) {
            setFlash(request.getSession(), "staffMessage", "Không tìm thấy nhân viên.", "danger");
            response.sendRedirect(request.getContextPath() + "/admin/staff");
            return;
        }

        User staff = staffDAO.findById(userId);
        if (staff == null) {
            setFlash(request.getSession(), "staffMessage", "Không tìm thấy nhân viên.", "danger");
            response.sendRedirect(request.getContextPath() + "/admin/staff");
            return;
        }

        prepareStaffForm(request, staff);
        forward(request, response, "/WEB-INF/admin/staff/staff-edit.jsp");
    }

    private void handleCreate(HttpServletRequest request, HttpServletResponse response) throws IOException {
        User staff = buildStaffFromRequest(request);
        if (!validatePassword(request, staff)) {
            response.sendRedirect(request.getContextPath() + "/admin/staff/new");
            return;
        }
        if (!isValidStaff(staff, true)) {
            setFlash(request.getSession(), "staffMessage", "Vui lòng nhập đầy đủ thông tin bắt buộc.", "danger");
            response.sendRedirect(request.getContextPath() + "/admin/staff/new");
            return;
        }
        if (!validateStaffFields(request, staff)) {
            response.sendRedirect(request.getContextPath() + "/admin/staff/new");
            return;
        }

        boolean inserted = staffDAO.insert(staff);
        if (inserted) {
            setFlash(request.getSession(), "staffMessage", "Tạo nhân viên thành công.", "success");
        } else {
            setFlash(request.getSession(), "staffMessage", "Không thể tạo nhân viên, vui lòng thử lại.", "danger");
        }
        response.sendRedirect(request.getContextPath() + "/admin/staff");
    }

    private void handleUpdate(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Integer userId = parseInteger(request.getParameter("userId"));
        if (userId == null) {
            setFlash(request.getSession(), "staffMessage", "Không tìm thấy nhân viên để cập nhật.", "danger");
            response.sendRedirect(request.getContextPath() + "/admin/staff");
            return;
        }
        User staff = buildStaffFromRequest(request);
        staff.setUserId(userId);

        if (!isValidStaff(staff, false)) {
            setFlash(request.getSession(), "staffMessage", "Vui lòng nhập đầy đủ thông tin bắt buộc.", "danger");
            response.sendRedirect(request.getContextPath() + "/admin/staff/edit?id=" + userId);
            return;
        }
        if (!validateStaffFields(request, staff)) {
            response.sendRedirect(request.getContextPath() + "/admin/staff/edit?id=" + userId);
            return;
        }

        if (!applyPasswordUpdateIfPresent(request, staff)) {
            response.sendRedirect(request.getContextPath() + "/admin/staff/edit?id=" + userId);
            return;
        }

        boolean updated = staffDAO.update(staff);
        if (updated) {
            setFlash(request.getSession(), "staffMessage", "Cập nhật nhân viên thành công.", "success");
        } else {
            setFlash(request.getSession(), "staffMessage", "Không thể cập nhật nhân viên, vui lòng thử lại.", "danger");
        }
        response.sendRedirect(request.getContextPath() + "/admin/staff");
    }

    private boolean validateStaffFields(HttpServletRequest request, User staff) {
        if (!InputValidator.isAlphabeticName(staff.getFullName())) {
            setFlash(request.getSession(), "staffMessage", "Họ và tên chỉ được chứa chữ cái và khoảng trắng.", "danger");
            return false;
        }
        if (!InputValidator.isDigitsOnly(staff.getPhoneNumber())) {
            setFlash(request.getSession(), "staffMessage", "Số điện thoại chỉ được chứa chữ số.", "danger");
            return false;
        }
        return true;
    }

    private void handleDelete(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Integer userId = parseInteger(request.getParameter("userId"));
        if (userId == null) {
            setFlash(request.getSession(), "staffMessage", "Không tìm thấy nhân viên để xóa.", "danger");
        } else {
            boolean deleted = staffDAO.delete(userId);
            if (deleted) {
                setFlash(request.getSession(), "staffMessage", "Đã xóa nhân viên thành công.", "success");
            } else {
                setFlash(request.getSession(), "staffMessage", "Không thể xóa nhân viên, vui lòng thử lại.", "danger");
            }
        }
        response.sendRedirect(request.getContextPath() + "/admin/staff");
    }

    private User buildStaffFromRequest(HttpServletRequest request) {
        User staff = new User();
        staff.setFullName(trim(request.getParameter("fullName")));
        staff.setEmail(trim(request.getParameter("email")));
        staff.setPhoneNumber(trim(request.getParameter("phone")));
        staff.setAddress(trim(request.getParameter("address")));
        staff.setStatus(defaultIfBlank(request.getParameter("status"), STAFF_STATUSES[0]));
        staff.setRole(DEFAULT_ROLE);
        return staff;
    }

    private boolean isValidStaff(User staff, boolean requirePassword) {
        boolean passwordReady = !requirePassword || (staff.getPasswordHash() != null && !staff.getPasswordHash().isBlank());
        return staff.getFullName() != null && !staff.getFullName().isBlank()
                && staff.getEmail() != null && !staff.getEmail().isBlank()
                && staff.getPhoneNumber() != null && !staff.getPhoneNumber().isBlank()
                && passwordReady;
    }

    private boolean validatePassword(HttpServletRequest request, User staff) {
        String password = trim(request.getParameter("password"));
        if (password == null || password.length() < 6) {
            setFlash(request.getSession(), "staffMessage", "Mật khẩu phải có ít nhất 6 ký tự.", "danger");
            return false;
        }
        String hashed = PasswordUtils.hashPassword(password);
        if (hashed == null) {
            setFlash(request.getSession(), "staffMessage", "Không thể tạo mật khẩu, vui lòng thử lại.", "danger");
            return false;
        }
        staff.setPasswordHash(hashed);
        return true;
    }

    private boolean applyPasswordUpdateIfPresent(HttpServletRequest request, User staff) {
        String password = trim(request.getParameter("password"));
        if (password == null || password.isBlank()) {
            staff.setPasswordHash(null);
            return true;
        }
        if (password.length() < 6) {
            setFlash(request.getSession(), "staffMessage", "Mật khẩu phải có ít nhất 6 ký tự.", "danger");
            return false;
        }
        String hashed = PasswordUtils.hashPassword(password);
        if (hashed == null) {
            setFlash(request.getSession(), "staffMessage", "Không thể cập nhật mật khẩu, vui lòng thử lại.", "danger");
            return false;
        }
        staff.setPasswordHash(hashed);
        return true;
    }

    private void prepareStaffForm(HttpServletRequest request, User staff) {
        request.setAttribute("staff", staff);
        request.setAttribute("staffStatuses", STAFF_STATUSES);
        request.setAttribute("dateFormatter", DATE_FORMATTER);
        request.setAttribute("activeMenu", "staff");
    }

    private void forward(HttpServletRequest request, HttpServletResponse response, String path) throws ServletException, IOException {
        request.getRequestDispatcher(path).forward(request, response);
    }

    private void setFlash(HttpSession session, String messageKey, String message, String type) {
        session.setAttribute(messageKey, message);
        session.setAttribute(messageKey + "Type", type);
    }

    private Integer parseInteger(String value) {
        try {
            return value != null ? Integer.valueOf(value) : null;
        } catch (NumberFormatException ex) {
            LOGGER.warn("Failed to parse integer: {}", value);
            return null;
        }
    }

    private String trim(String value) {
        if (value == null) {
            return null;
        }
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }

    private String defaultIfBlank(String value, String fallback) {
        if (value == null) {
            return fallback;
        }
        String trimmed = value.trim();
        return trimmed.isEmpty() ? fallback : trimmed;
    }

    @Override
    public String getServletInfo() {
        return "Staff management controller";
    }
}
