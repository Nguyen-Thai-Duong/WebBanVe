package controller.admin;

import DAO.CustomerDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import model.User;
import util.PasswordUtils;
import java.time.format.DateTimeFormatter;
import java.util.Collections;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Controller for managing customer accounts in the admin module.
 */
@WebServlet(name = "CustomerController", urlPatterns = {"/admin/customers", "/admin/customers/new", "/admin/customers/edit"})
public class CustomerController extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = LoggerFactory.getLogger(CustomerController.class);
    private static final String DEFAULT_ROLE = "Customer";
    private static final String[] CUSTOMER_STATUSES = {"Active", "Inactive", "Suspended", "Locked"};
    private static final DateTimeFormatter TABLE_FORMATTER = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");

    private final CustomerDAO customerDAO = new CustomerDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String path = request.getServletPath();
        switch (path) {
            case "/admin/customers":
                loadCustomers(request);
                request.getRequestDispatcher("/WEB-INF/admin/customers/customer-list.jsp").forward(request, response);
                break;
            case "/admin/customers/new":
                prepareCustomerForm(request, null);
                request.getRequestDispatcher("/WEB-INF/admin/customers/customer-create.jsp").forward(request, response);
                break;
            case "/admin/customers/edit":
                handleEditForm(request, response);
                break;
            default:
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String path = request.getServletPath();
        switch (path) {
            case "/admin/customers":
                handleActionPost(request, response);
                break;
            case "/admin/customers/new":
                handleCreate(request, response);
                break;
            case "/admin/customers/edit":
                handleUpdate(request, response);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/admin/customers");
        }
    }

    private void handleCreate(HttpServletRequest request, HttpServletResponse response) throws IOException {
        User customer = buildCustomerFromRequest(request, true);
        if (!isValidCustomer(customer, true)) {
            setFlash(request.getSession(), "danger", "Vui lòng nhập đầy đủ thông tin bắt buộc.");
            response.sendRedirect(request.getContextPath() + "/admin/customers/new");
            return;
        }
        boolean created = customerDAO.insert(customer);
        setFlash(request.getSession(), created ? "success" : "danger",
                created ? "Tạo khách hàng thành công." : "Không thể tạo khách hàng. Vui lòng thử lại.");
        response.sendRedirect(request.getContextPath() + "/admin/customers");
    }

    private void handleUpdate(HttpServletRequest request, HttpServletResponse response) throws IOException {
        User customer = buildCustomerFromRequest(request, false);
        customer.setUserId(parseInteger(request.getParameter("userId")));
        if (customer.getUserId() == null) {
            setFlash(request.getSession(), "danger", "Thiếu mã khách hàng cần cập nhật.");
            response.sendRedirect(request.getContextPath() + "/admin/customers");
            return;
        }
        if (!isValidCustomer(customer, false)) {
            setFlash(request.getSession(), "danger", "Vui lòng nhập đầy đủ thông tin bắt buộc.");
            response.sendRedirect(request.getContextPath() + "/admin/customers/edit?userId=" + customer.getUserId());
            return;
        }
        boolean updated = customerDAO.update(customer);
        setFlash(request.getSession(), updated ? "success" : "danger",
                updated ? "Cập nhật khách hàng thành công." : "Không thể cập nhật khách hàng. Vui lòng thử lại.");
        response.sendRedirect(request.getContextPath() + "/admin/customers");
    }

    private void handleDelete(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Integer userId = parseInteger(request.getParameter("userId"));
        if (userId == null) {
            setFlash(request.getSession(), "danger", "Thiếu mã khách hàng cần xóa.");
            response.sendRedirect(request.getContextPath() + "/admin/customers");
            return;
        }
        boolean deleted = customerDAO.delete(userId);
        setFlash(request.getSession(), deleted ? "success" : "danger",
                deleted ? "Đã xóa khách hàng." : "Không thể xóa khách hàng. Vui lòng thử lại.");
        response.sendRedirect(request.getContextPath() + "/admin/customers");
    }

    private void loadCustomers(HttpServletRequest request) {
        List<User> customers = customerDAO.findAll();
        if (customers == null) {
            customers = Collections.emptyList();
        }
        request.setAttribute("customers", customers);
        request.setAttribute("activeMenu", "customers");
        request.setAttribute("customerStatuses", CUSTOMER_STATUSES);
        request.setAttribute("dateFormatter", TABLE_FORMATTER);
    }

    private void prepareCustomerForm(HttpServletRequest request, User customer) {
        request.setAttribute("customer", customer);
        request.setAttribute("activeMenu", "customers");
        request.setAttribute("customerStatuses", CUSTOMER_STATUSES);
        request.setAttribute("dateFormatter", TABLE_FORMATTER);
    }

    private void handleEditForm(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        Integer userId = parseInteger(request.getParameter("userId"));
        if (userId == null) {
            setFlash(request.getSession(), "danger", "Thiếu mã khách hàng cần chỉnh sửa.");
            response.sendRedirect(request.getContextPath() + "/admin/customers");
            return;
        }
        User customer = customerDAO.findById(userId);
        if (customer == null) {
            setFlash(request.getSession(), "danger", "Không tìm thấy khách hàng.");
            response.sendRedirect(request.getContextPath() + "/admin/customers");
            return;
        }
        prepareCustomerForm(request, customer);
    request.getRequestDispatcher("/WEB-INF/admin/customers/customer-edit.jsp").forward(request, response);
    }

    private void handleActionPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String action = request.getParameter("action");
        if ("delete".equals(action)) {
            handleDelete(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/customers");
        }
    }

    private User buildCustomerFromRequest(HttpServletRequest request, boolean requirePassword) {
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

    private boolean isValidCustomer(User customer, boolean requirePassword) {
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

    private String defaultIfBlank(String value, String defaultValue) {
        return (value == null || value.isBlank()) ? defaultValue : value.trim();
    }

    private void setFlash(HttpSession session, String type, String message) {
        session.setAttribute("customerMessage", message);
        session.setAttribute("customerMessageType", type);
    }

    @Override
    public String getServletInfo() {
        return "Customer management controller";
    }
}
