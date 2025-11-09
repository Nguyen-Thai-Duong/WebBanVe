package controller.admin;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.time.format.DateTimeFormatter;
import java.util.List;
import model.User;
import service.admin.AdminOperatorService;

@WebServlet(name = "OperatorController", urlPatterns = {"/admin/operators", "/admin/operators/new", "/admin/operators/edit"})
public class OperatorController extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final String[] OPERATOR_STATUSES = {"Active", "Inactive", "Suspended", "Locked"};
    private static final DateTimeFormatter DATE_FORMATTER = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");

    private final AdminOperatorService operatorService = new AdminOperatorService();

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
        List<User> operators = operatorService.getAllOperators();
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
        Integer userId = operatorService.parseInteger(request.getParameter("id"));
        if (userId == null) {
            operatorService.setFlash(request.getSession(), "operatorMessage", "Không tìm thấy tài khoản phụ trách.", "danger");
            response.sendRedirect(request.getContextPath() + "/admin/operators");
            return;
        }
        User operator = operatorService.getOperatorById(userId);
        if (operator == null) {
            operatorService.setFlash(request.getSession(), "operatorMessage", "Không tìm thấy tài khoản phụ trách.", "danger");
            response.sendRedirect(request.getContextPath() + "/admin/operators");
            return;
        }
        prepareOperatorForm(request, operator);
        forward(request, response, "/WEB-INF/admin/operators/operator-edit.jsp");
    }

    private void handleCreate(HttpServletRequest request, HttpServletResponse response) throws IOException {
        User operator = operatorService.buildOperatorFromRequest(request, OPERATOR_STATUSES);
        if (!operatorService.validatePassword(request.getSession(), request, operator)) {
            response.sendRedirect(request.getContextPath() + "/admin/operators/new");
            return;
        }
        if (!operatorService.isValidOperator(operator, true)) {
            operatorService.setFlash(request.getSession(), "operatorMessage", "Vui lòng nhập đầy đủ thông tin bắt buộc.", "danger");
            response.sendRedirect(request.getContextPath() + "/admin/operators/new");
            return;
        }
        if (!operatorService.validateOperatorFields(request.getSession(), operator)) {
            response.sendRedirect(request.getContextPath() + "/admin/operators/new");
            return;
        }
        boolean inserted = operatorService.createOperator(operator);
        operatorService.setFlash(request.getSession(), "operatorMessage", 
                inserted ? "Tạo tài khoản thành công." : "Không thể tạo tài khoản.", 
                inserted ? "success" : "danger");
        response.sendRedirect(request.getContextPath() + "/admin/operators");
    }

    private void handleUpdate(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Integer userId = operatorService.parseInteger(request.getParameter("userId"));
        if (userId == null) {
            operatorService.setFlash(request.getSession(), "operatorMessage", "Không tìm thấy tài khoản cần cập nhật.", "danger");
            response.sendRedirect(request.getContextPath() + "/admin/operators");
            return;
        }
        User operator = operatorService.buildOperatorFromRequest(request, OPERATOR_STATUSES);
        operator.setUserId(userId);
        if (!operatorService.isValidOperator(operator, false)) {
            operatorService.setFlash(request.getSession(), "operatorMessage", "Vui lòng nhập đầy đủ thông tin bắt buộc.", "danger");
            response.sendRedirect(request.getContextPath() + "/admin/operators/edit?id=" + userId);
            return;
        }
        if (!operatorService.validateOperatorFields(request.getSession(), operator)) {
            response.sendRedirect(request.getContextPath() + "/admin/operators/edit?id=" + userId);
            return;
        }
        if (!operatorService.applyPasswordUpdateIfPresent(request.getSession(), request, operator)) {
            response.sendRedirect(request.getContextPath() + "/admin/operators/edit?id=" + userId);
            return;
        }
        boolean updated = operatorService.updateOperator(operator);
        operatorService.setFlash(request.getSession(), "operatorMessage", 
                updated ? "Cập nhật tài khoản thành công." : "Không thể cập nhật tài khoản.", 
                updated ? "success" : "danger");
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
        Integer userId = operatorService.parseInteger(request.getParameter("userId"));
        if (userId == null) {
            operatorService.setFlash(request.getSession(), "operatorMessage", "Không tìm thấy tài khoản cần xóa.", "danger");
        } else {
            boolean deleted = operatorService.deleteOperator(userId);
            operatorService.setFlash(request.getSession(), "operatorMessage", 
                    deleted ? "Đã xóa tài khoản." : "Không thể xóa tài khoản.", 
                    deleted ? "success" : "danger");
        }
        response.sendRedirect(request.getContextPath() + "/admin/operators");
    }

    private void prepareOperatorForm(HttpServletRequest request, User operator) {
        request.setAttribute("operator", operator);
        request.setAttribute("operatorStatuses", OPERATOR_STATUSES);
        request.setAttribute("dateFormatter", DATE_FORMATTER);
        request.setAttribute("activeMenu", "operators");
    }

    private void forward(HttpServletRequest request, HttpServletResponse response, String path) throws ServletException, IOException {
        request.getRequestDispatcher(path).forward(request, response);
    }

    @Override
    public String getServletInfo() {
        return "Operator management controller";
    }
}
