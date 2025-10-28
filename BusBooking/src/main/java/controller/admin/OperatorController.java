package controller.admin;

import DAO.OperatorDAO;
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
import util.PasswordUtils;

@WebServlet(name = "OperatorController", urlPatterns = {"/admin/operators", "/admin/operators/new", "/admin/operators/edit"})
public class OperatorController extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = LoggerFactory.getLogger(OperatorController.class);
    private static final String[] OPERATOR_STATUSES = {"Active", "Inactive", "Suspended", "Locked"};
    private static final DateTimeFormatter DATE_FORMATTER = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");

    private final OperatorDAO operatorDAO = new OperatorDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String path = request.getServletPath();
        if ("/admin/operators/new".equals(path)) {
            showCreateForm(request, response);
        } else if ("/admin/operators/edit".equals(path)) {
            showEditForm(request, response);
        } else {
            showOperatorList(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String path = request.getServletPath();
        if ("/admin/operators".equals(path)) {
            handleActionPost(request, response);
        } else if ("/admin/operators/new".equals(path)) {
            handleCreate(request, response);
        } else if ("/admin/operators/edit".equals(path)) {
            handleUpdate(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/operators");
        }
    }

    private void showOperatorList(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        List<User> operators = operatorDAO.findAll();
        if (operators == null) {
            operators = Collections.emptyList();
        }
        request.setAttribute("operators", operators);
        request.setAttribute("operatorStatuses", OPERATOR_STATUSES);
        request.setAttribute("dateFormatter", DATE_FORMATTER);
        request.setAttribute("activeMenu", "operators");
        forward(request, response, "/WEB-INF/admin/operators/operator-list.jsp");
    }

    private void showCreateForm(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        prepareOperatorForm(request, null);
        forward(request, response, "/WEB-INF/admin/operators/operator-create.jsp");
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Integer userId = parseInteger(request.getParameter("id"));
        if (userId == null) {
            setFlash(request.getSession(), "operatorMessage", "Không tìm thấy tài khoản phụ trách.", "danger");
            response.sendRedirect(request.getContextPath() + "/admin/operators");
            return;
        }
        User operator = operatorDAO.findById(userId);
        if (operator == null) {
            setFlash(request.getSession(), "operatorMessage", "Không tìm thấy tài khoản phụ trách.", "danger");
            response.sendRedirect(request.getContextPath() + "/admin/operators");
            return;
        }
        prepareOperatorForm(request, operator);
        forward(request, response, "/WEB-INF/admin/operators/operator-edit.jsp");
    }

    private void handleCreate(HttpServletRequest request, HttpServletResponse response) throws IOException {
        User operator = buildOperatorFromRequest(request);
        if (!validatePassword(request, operator)) {
            response.sendRedirect(request.getContextPath() + "/admin/operators/new");
            return;
        }
        if (!isValidOperator(operator, true)) {
            setFlash(request.getSession(), "operatorMessage", "Vui lòng nhập đầy đủ thông tin bắt buộc.", "danger");
            response.sendRedirect(request.getContextPath() + "/admin/operators/new");
            return;
        }
        boolean inserted = operatorDAO.insert(operator);
        setFlash(request.getSession(), "operatorMessage", inserted ? "Tạo tài khoản thành công." : "Không thể tạo tài khoản.", inserted ? "success" : "danger");
        response.sendRedirect(request.getContextPath() + "/admin/operators");
    }

    private void handleUpdate(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Integer userId = parseInteger(request.getParameter("userId"));
        if (userId == null) {
            setFlash(request.getSession(), "operatorMessage", "Không tìm thấy tài khoản cần cập nhật.", "danger");
            response.sendRedirect(request.getContextPath() + "/admin/operators");
            return;
        }
        User operator = buildOperatorFromRequest(request);
        operator.setUserId(userId);
        if (!isValidOperator(operator, false)) {
            setFlash(request.getSession(), "operatorMessage", "Vui lòng nhập đầy đủ thông tin bắt buộc.", "danger");
            response.sendRedirect(request.getContextPath() + "/admin/operators/edit?id=" + userId);
            return;
        }
        if (!applyPasswordUpdateIfPresent(request, operator)) {
            response.sendRedirect(request.getContextPath() + "/admin/operators/edit?id=" + userId);
            return;
        }
        boolean updated = operatorDAO.update(operator);
        setFlash(request.getSession(), "operatorMessage", updated ? "Cập nhật tài khoản thành công." : "Không thể cập nhật tài khoản.", updated ? "success" : "danger");
        response.sendRedirect(request.getContextPath() + "/admin/operators");
    }

    private void handleActionPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String action = request.getParameter("action");
        if ("delete".equals(action)) {
            handleDelete(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/operators");
        }
    }

    private void handleDelete(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Integer userId = parseInteger(request.getParameter("userId"));
        if (userId == null) {
            setFlash(request.getSession(), "operatorMessage", "Không tìm thấy tài khoản cần xóa.", "danger");
        } else {
            boolean deleted = operatorDAO.delete(userId);
            setFlash(request.getSession(), "operatorMessage", deleted ? "Đã xóa tài khoản." : "Không thể xóa tài khoản.", deleted ? "success" : "danger");
        }
        response.sendRedirect(request.getContextPath() + "/admin/operators");
    }

    private User buildOperatorFromRequest(HttpServletRequest request) {
        User operator = new User();
        operator.setFullName(trim(request.getParameter("fullName")));
        operator.setEmail(trim(request.getParameter("email")));
        operator.setPhoneNumber(trim(request.getParameter("phone")));
        operator.setAddress(trim(request.getParameter("address")));
        operator.setStatus(defaultIfBlank(request.getParameter("status"), OPERATOR_STATUSES[0]));
        operator.setRole("BusOperator");
        return operator;
    }

    private boolean validatePassword(HttpServletRequest request, User operator) {
        String password = trim(request.getParameter("password"));
        if (password == null || password.length() < 6) {
            setFlash(request.getSession(), "operatorMessage", "Mật khẩu phải có ít nhất 6 ký tự.", "danger");
            return false;
        }
        String hashed = PasswordUtils.hashPassword(password);
        operator.setPasswordHash(hashed);
        return true;
    }

    private boolean applyPasswordUpdateIfPresent(HttpServletRequest request, User operator) {
        String password = trim(request.getParameter("password"));
        if (password == null || password.isBlank()) {
            operator.setPasswordHash(null);
            return true;
        }
        if (password.length() < 6) {
            setFlash(request.getSession(), "operatorMessage", "Mật khẩu phải có ít nhất 6 ký tự.", "danger");
            return false;
        }
        operator.setPasswordHash(PasswordUtils.hashPassword(password));
        return true;
    }

    private boolean isValidOperator(User operator, boolean requirePassword) {
        boolean passwordReady = !requirePassword || (operator.getPasswordHash() != null && !operator.getPasswordHash().isBlank());
        return operator.getFullName() != null && !operator.getFullName().isBlank()
                && operator.getEmail() != null && !operator.getEmail().isBlank()
                && operator.getPhoneNumber() != null && !operator.getPhoneNumber().isBlank()
                && passwordReady;
    }

    private void prepareOperatorForm(HttpServletRequest request, User operator) {
        request.setAttribute("operator", operator);
        request.setAttribute("operatorStatuses", OPERATOR_STATUSES);
        request.setAttribute("dateFormatter", DATE_FORMATTER);
        request.setAttribute("activeMenu", "operators");
    }

    private void setFlash(HttpSession session, String key, String message, String type) {
        session.setAttribute(key, message);
        session.setAttribute(key + "Type", type);
    }

    private void forward(HttpServletRequest request, HttpServletResponse response, String path) throws ServletException, IOException {
        request.getRequestDispatcher(path).forward(request, response);
    }

    private Integer parseInteger(String value) {
        try {
            return value != null && !value.isBlank() ? Integer.valueOf(value) : null;
        } catch (NumberFormatException ex) {
            LOGGER.warn("Failed to parse integer value: {}", value);
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
        return "Operator management controller";
    }
}
