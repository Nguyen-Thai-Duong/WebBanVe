package controller.staff;

import DAO.CustomerDAO;
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
 * Staff-scoped controller offering customer CRU operations (no hard delete).
 */
@WebServlet(name = "StaffCustomerController", urlPatterns = {"/staff/customers"})
public class StaffCustomerController extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(StaffCustomerController.class.getName());
    private static final String CUSTOMER_ROLE = "Customer";

    private final CustomerDAO customerDAO = new CustomerDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session != null) {
            Object message = session.getAttribute("staffCustomerMessage");
            Object type = session.getAttribute("staffCustomerMessageType");
            if (message != null) {
                request.setAttribute("flashMessage", message);
                session.removeAttribute("staffCustomerMessage");
            }
            if (type != null) {
                request.setAttribute("flashType", type);
                session.removeAttribute("staffCustomerMessageType");
            }
        }

        List<User> customers = customerDAO.findAll();
        request.setAttribute("customers", customers);
        request.setAttribute("activeMenu", "customers");
        request.setAttribute("navbarSearchPlaceholder", "Tìm kiếm khách hàng...");

        request.getRequestDispatcher("/WEB-INF/staff/customer-list.jsp").forward(request, response);
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
            default:
                setFlash(request, "warning", "Hành động không được hỗ trợ.");
                response.sendRedirect(buildRedirectUrl(request));
        }
    }

    private void handleCreate(HttpServletRequest request, HttpServletResponse response) throws IOException {
        User customer = buildCustomerFromRequest(request, true);
        if (!isValid(customer, true)) {
            setFlash(request, "danger", "Vui lòng nhập đầy đủ thông tin bắt buộc.");
            response.sendRedirect(buildRedirectUrl(request));
            return;
        }
        boolean created = customerDAO.insert(customer);
        setFlash(request, created ? "success" : "danger",
                created ? "Đã tạo khách hàng mới." : "Không thể tạo khách hàng. Vui lòng thử lại.");
        response.sendRedirect(buildRedirectUrl(request));
    }

    private void handleUpdate(HttpServletRequest request, HttpServletResponse response) throws IOException {
        User customer = buildCustomerFromRequest(request, false);
        customer.setUserId(parseInteger(request.getParameter("userId")));
        if (customer.getUserId() == null) {
            setFlash(request, "danger", "Thiếu mã khách hàng để cập nhật.");
            response.sendRedirect(buildRedirectUrl(request));
            return;
        }
        if (!isValid(customer, false)) {
            setFlash(request, "danger", "Vui lòng nhập đầy đủ thông tin bắt buộc.");
            response.sendRedirect(buildRedirectUrl(request));
            return;
        }
        boolean updated = customerDAO.update(customer);
        setFlash(request, updated ? "success" : "danger",
                updated ? "Đã cập nhật thông tin khách hàng." : "Không thể cập nhật khách hàng. Vui lòng thử lại.");
        response.sendRedirect(buildRedirectUrl(request));
    }

    private User buildCustomerFromRequest(HttpServletRequest request, boolean requirePassword) {
        User customer = new User();
        customer.setFullName(trim(request.getParameter("fullName")));
        customer.setEmail(trim(request.getParameter("email")));
        customer.setPhoneNumber(trim(request.getParameter("phoneNumber")));
        customer.setAddress(trim(request.getParameter("address")));
        customer.setStatus(trim(request.getParameter("status")));
        customer.setRole(CUSTOMER_ROLE);

        String password = request.getParameter("password");
        if (password != null && !password.isBlank()) {
            try {
                customer.setPasswordHash(PasswordUtils.hashPassword(password));
            } catch (RuntimeException ex) {
                LOGGER.log(Level.SEVERE, "Không thể mã hóa mật khẩu", ex);
                customer.setPasswordHash(null);
            }
        } else if (requirePassword) {
            customer.setPasswordHash(null);
        }
        return customer;
    }

    private boolean isValid(User customer, boolean requirePassword) {
        return customer.getFullName() != null && !customer.getFullName().isBlank()
                && customer.getEmail() != null && !customer.getEmail().isBlank()
                && customer.getPhoneNumber() != null && !customer.getPhoneNumber().isBlank()
                && (!requirePassword || (customer.getPasswordHash() != null && !customer.getPasswordHash().isBlank()));
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
        session.setAttribute("staffCustomerMessage", message);
        session.setAttribute("staffCustomerMessageType", type);
    }

    private String trim(String value) {
        return value != null ? value.trim() : null;
    }

    private String buildRedirectUrl(HttpServletRequest request) {
        return request.getContextPath() + "/staff/customers";
    }
}
