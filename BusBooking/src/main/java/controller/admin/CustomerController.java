package controller.admin;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.time.format.DateTimeFormatter;
import java.util.List;
import model.User;
import service.admin.AdminCustomerService;

/**
 * Controller for managing customer accounts in the admin module.
 */
@WebServlet(name = "CustomerController", urlPatterns = {"/admin/customers", "/admin/customers/new", "/admin/customers/edit"})
public class CustomerController extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final String[] CUSTOMER_STATUSES = {"Active", "Inactive", "Suspended", "Locked"};
    private static final DateTimeFormatter TABLE_FORMATTER = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");

    private final AdminCustomerService customerService = new AdminCustomerService();

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
        User customer = customerService.buildCustomerFromRequest(request, true);
        if (!customerService.isValidCustomer(customer, true)) {
            setFlash(request.getSession(), "danger", "Vui lòng nhập đầy đủ thông tin bắt buộc.");
            response.sendRedirect(request.getContextPath() + "/admin/customers/new");
            return;
        }
        if (!customerService.validateCustomerFields(request.getSession(), customer)) {
            response.sendRedirect(request.getContextPath() + "/admin/customers/new");
            return;
        }
        boolean created = customerService.createCustomer(customer);
        setFlash(request.getSession(), created ? "success" : "danger",
                created ? "Tạo khách hàng thành công." : "Không thể tạo khách hàng. Vui lòng thử lại.");
        response.sendRedirect(request.getContextPath() + "/admin/customers");
    }

    private void handleUpdate(HttpServletRequest request, HttpServletResponse response) throws IOException {
        User customer = customerService.buildCustomerFromRequest(request, false);
        customer.setUserId(customerService.parseInteger(request.getParameter("userId")));
        if (customer.getUserId() == null) {
            setFlash(request.getSession(), "danger", "Thiếu mã khách hàng cần cập nhật.");
            response.sendRedirect(request.getContextPath() + "/admin/customers");
            return;
        }
        if (!customerService.isValidCustomer(customer, false)) {
            setFlash(request.getSession(), "danger", "Vui lòng nhập đầy đủ thông tin bắt buộc.");
            response.sendRedirect(request.getContextPath() + "/admin/customers/edit?userId=" + customer.getUserId());
            return;
        }
        if (!customerService.validateCustomerFields(request.getSession(), customer)) {
            response.sendRedirect(request.getContextPath() + "/admin/customers/edit?userId=" + customer.getUserId());
            return;
        }
        boolean updated = customerService.updateCustomer(customer);
        setFlash(request.getSession(), updated ? "success" : "danger",
                updated ? "Cập nhật khách hàng thành công." : "Không thể cập nhật khách hàng. Vui lòng thử lại.");
        response.sendRedirect(request.getContextPath() + "/admin/customers");
    }

    private void handleDelete(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Integer userId = customerService.parseInteger(request.getParameter("userId"));
        if (userId == null) {
            setFlash(request.getSession(), "danger", "Thiếu mã khách hàng cần xóa.");
            response.sendRedirect(request.getContextPath() + "/admin/customers");
            return;
        }
        boolean deleted = customerService.deleteCustomer(userId);
        setFlash(request.getSession(), deleted ? "success" : "danger",
                deleted ? "Đã xóa khách hàng." : "Không thể xóa khách hàng. Vui lòng thử lại.");
        response.sendRedirect(request.getContextPath() + "/admin/customers");
    }

    private void loadCustomers(HttpServletRequest request) {
        List<User> customers = customerService.getAllCustomers();
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
        Integer userId = customerService.parseInteger(request.getParameter("userId"));
        if (userId == null) {
            setFlash(request.getSession(), "danger", "Thiếu mã khách hàng cần chỉnh sửa.");
            response.sendRedirect(request.getContextPath() + "/admin/customers");
            return;
        }
        User customer = customerService.getCustomerById(userId);
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

    private void setFlash(HttpSession session, String type, String message) {
        session.setAttribute("customerMessage", message);
        session.setAttribute("customerMessageType", type);
    }

    @Override
    public String getServletInfo() {
        return "Customer management controller";
    }
}
