package controller.admin;

import DAO.StaffDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import model.User;
import util.PasswordUtils;

/**
 * Admin controller responsible for CRUD operations on staff accounts.
 */
@WebServlet(name = "StaffController", urlPatterns = {"/admin/staff"})
public class StaffController extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(StaffController.class.getName());
    private static final String FLASH_KEY = "staffMessage";
    private static final String FLASH_TYPE_KEY = "staffMessageType";

    private final StaffDAO staffDAO = new StaffDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        loadFlash(request);
        List<User> staffMembers = staffDAO.findAll();
        request.setAttribute("staffMembers", staffMembers);
        request.setAttribute("activeMenu", "staff");
        request.setAttribute("navbarSearchPlaceholder", "Tìm kiếm nhân viên...");
        request.getRequestDispatcher("/WEB-INF/admin/staff-list.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        if (action == null) {
            response.sendRedirect(buildRedirectUrl(request));
            return;
        }

        switch (action) {
            case "create":
                handleCreate(request, response);
                break;
            case "update":
                handleUpdate(request, response);
                break;
            case "delete":
                handleDelete(request, response);
                break;
            default:
                setFlash(request, "warning", "Hành động không được hỗ trợ.");
                response.sendRedirect(buildRedirectUrl(request));
        }
    }

    private void handleCreate(HttpServletRequest request, HttpServletResponse response) throws IOException {
        User staff = buildUserFromRequest(request, true);
        if (!isValid(staff, true)) {
            setFlash(request, "danger", "Vui lòng nhập đầy đủ thông tin bắt buộc.");
            response.sendRedirect(buildRedirectUrl(request));
            return;
        }
        boolean created = staffDAO.insert(staff);
        setFlash(request, created ? "success" : "danger",
                created ? "Đã tạo tài khoản nhân viên." : "Không thể tạo nhân viên. Vui lòng thử lại.");
        response.sendRedirect(buildRedirectUrl(request));
    }

    private void handleUpdate(HttpServletRequest request, HttpServletResponse response) throws IOException {
        User staff = buildUserFromRequest(request, false);
        staff.setUserId(parseInteger(request.getParameter("userId")));
        if (staff.getUserId() == null) {
            setFlash(request, "danger", "Thiếu mã nhân viên cần cập nhật.");
            response.sendRedirect(buildRedirectUrl(request));
            return;
        }
        if (!isValid(staff, false)) {
            setFlash(request, "danger", "Vui lòng nhập đầy đủ thông tin bắt buộc.");
            response.sendRedirect(buildRedirectUrl(request));
            return;
        }
        boolean updated = staffDAO.update(staff);
        setFlash(request, updated ? "success" : "danger",
                updated ? "Đã cập nhật thông tin nhân viên." : "Không thể cập nhật nhân viên. Vui lòng thử lại.");
        response.sendRedirect(buildRedirectUrl(request));
    }

    private void handleDelete(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Integer userId = parseInteger(request.getParameter("userId"));
        if (userId == null) {
            setFlash(request, "danger", "Thiếu mã nhân viên cần xóa.");
            response.sendRedirect(buildRedirectUrl(request));
            return;
        }
        boolean deleted = staffDAO.delete(userId);
        setFlash(request, deleted ? "success" : "danger",
                deleted ? "Đã xóa nhân viên khỏi hệ thống." : "Không thể xóa nhân viên. Vui lòng thử lại.");
        response.sendRedirect(buildRedirectUrl(request));
    }

    private User buildUserFromRequest(HttpServletRequest request, boolean requirePassword) {
        User user = new User();
        user.setFullName(trim(request.getParameter("fullName")));
        user.setEmail(trim(request.getParameter("email")));
        user.setPhoneNumber(trim(request.getParameter("phoneNumber")));
        user.setStatus(trim(request.getParameter("status")));
        user.setAddress(trim(request.getParameter("address")));

        String password = request.getParameter("password");
        if (password != null && !password.isBlank()) {
            try {
                user.setPasswordHash(PasswordUtils.hashPassword(password));
            } catch (RuntimeException ex) {
                LOGGER.log(Level.SEVERE, "Không thể mã hóa mật khẩu", ex);
                user.setPasswordHash(null);
            }
        } else if (requirePassword) {
            user.setPasswordHash(null);
        }
        return user;
    }

    private boolean isValid(User user, boolean requirePassword) {
        return user.getFullName() != null && !user.getFullName().isBlank()
                && user.getEmail() != null && !user.getEmail().isBlank()
                && user.getPhoneNumber() != null && !user.getPhoneNumber().isBlank()
                && (!requirePassword || (user.getPasswordHash() != null && !user.getPasswordHash().isBlank()));
    }

    private Integer parseInteger(String value) {
        try {
            return value != null && !value.isBlank() ? Integer.valueOf(value) : null;
        } catch (NumberFormatException ex) {
            return null;
        }
    }

    private void loadFlash(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) {
            return;
        }
        Object message = session.getAttribute(FLASH_KEY);
        Object type = session.getAttribute(FLASH_TYPE_KEY);
        if (message != null) {
            request.setAttribute("flashMessage", message);
            session.removeAttribute(FLASH_KEY);
        }
        if (type != null) {
            request.setAttribute("flashType", type);
            session.removeAttribute(FLASH_TYPE_KEY);
        }
    }

    private void setFlash(HttpServletRequest request, String type, String message) {
        HttpSession session = request.getSession(true);
        session.setAttribute(FLASH_KEY, message);
        session.setAttribute(FLASH_TYPE_KEY, type);
    }

    private String trim(String value) {
        return value != null ? value.trim() : null;
    }

    private String buildRedirectUrl(HttpServletRequest request) {
        return request.getContextPath() + "/admin/staff";
    }
}
