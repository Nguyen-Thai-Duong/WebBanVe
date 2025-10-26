package controller.admin;

import DAO.BusOperatorDAO;
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
 * Admin controller for managing bus operator accounts.
 */
@WebServlet(name = "BusOperatorController", urlPatterns = {"/admin/operators"})
public class BusOperatorController extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(BusOperatorController.class.getName());
    private static final String FLASH_KEY = "operatorMessage";
    private static final String FLASH_TYPE_KEY = "operatorMessageType";

    private final BusOperatorDAO operatorDAO = new BusOperatorDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        loadFlash(request);
        List<User> operators = operatorDAO.findAll();
        request.setAttribute("operators", operators);
        request.setAttribute("activeMenu", "operators");
        request.setAttribute("navbarSearchPlaceholder", "Tìm kiếm nhà xe...");
        request.getRequestDispatcher("/WEB-INF/admin/operator-list.jsp").forward(request, response);
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
        User operator = buildUserFromRequest(request, true);
        if (!isValid(operator, true)) {
            setFlash(request, "danger", "Vui lòng nhập đầy đủ thông tin bắt buộc.");
            response.sendRedirect(buildRedirectUrl(request));
            return;
        }
        boolean created = operatorDAO.insert(operator);
        setFlash(request, created ? "success" : "danger",
                created ? "Đã tạo tài khoản nhà xe." : "Không thể tạo tài khoản nhà xe. Vui lòng kiểm tra thông tin.");
        response.sendRedirect(buildRedirectUrl(request));
    }

    private void handleUpdate(HttpServletRequest request, HttpServletResponse response) throws IOException {
        User operator = buildUserFromRequest(request, false);
        operator.setUserId(parseInteger(request.getParameter("userId")));
        if (operator.getUserId() == null) {
            setFlash(request, "danger", "Thiếu mã nhà xe cần cập nhật.");
            response.sendRedirect(buildRedirectUrl(request));
            return;
        }
        if (!isValid(operator, false)) {
            setFlash(request, "danger", "Vui lòng nhập đầy đủ thông tin bắt buộc.");
            response.sendRedirect(buildRedirectUrl(request));
            return;
        }
        boolean updated = operatorDAO.update(operator);
        setFlash(request, updated ? "success" : "danger",
                updated ? "Đã cập nhật thông tin nhà xe." : "Không thể cập nhật nhà xe. Vui lòng thử lại.");
        response.sendRedirect(buildRedirectUrl(request));
    }

    private void handleDelete(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Integer userId = parseInteger(request.getParameter("userId"));
        if (userId == null) {
            setFlash(request, "danger", "Thiếu mã nhà xe cần xóa.");
            response.sendRedirect(buildRedirectUrl(request));
            return;
        }
        boolean deleted = operatorDAO.delete(userId);
        setFlash(request, deleted ? "success" : "danger",
                deleted ? "Đã xóa tài khoản nhà xe." : "Không thể xóa tài khoản nhà xe. Vui lòng thử lại.");
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

    private void setFlash(HttpServletRequest request, String type, String message) {
        HttpSession session = request.getSession(true);
        session.setAttribute(FLASH_KEY, message);
        session.setAttribute(FLASH_TYPE_KEY, type);
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

    private String trim(String value) {
        return value != null ? value.trim() : null;
    }

    private String buildRedirectUrl(HttpServletRequest request) {
        return request.getContextPath() + "/admin/operators";
    }
}
