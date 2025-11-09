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
import service.admin.AdminStaffService;

@WebServlet(name = "StaffController", urlPatterns = {"/admin/staff", "/admin/staff/new", "/admin/staff/edit"})
public class StaffController extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final String[] STAFF_STATUSES = {"Active", "Inactive", "Suspended", "Locked"};
    private static final DateTimeFormatter DATE_FORMATTER = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");

    private final AdminStaffService staffService = new AdminStaffService();

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
        List<User> staffMembers = staffService.getAllStaff();
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
        Integer userId = staffService.parseInteger(request.getParameter("id"));
        if (userId == null) {
            staffService.setFlash(request.getSession(), "staffMessage", "Không tìm thấy nhân viên.", "danger");
            response.sendRedirect(request.getContextPath() + "/admin/staff");
            return;
        }

        User staff = staffService.getStaffById(userId);
        if (staff == null) {
            staffService.setFlash(request.getSession(), "staffMessage", "Không tìm thấy nhân viên.", "danger");
            response.sendRedirect(request.getContextPath() + "/admin/staff");
            return;
        }

        prepareStaffForm(request, staff);
        forward(request, response, "/WEB-INF/admin/staff/staff-edit.jsp");
    }

    private void handleCreate(HttpServletRequest request, HttpServletResponse response) throws IOException {
        User staff = staffService.buildStaffFromRequest(request, STAFF_STATUSES);
        if (!staffService.validatePassword(request.getSession(), request, staff)) {
            response.sendRedirect(request.getContextPath() + "/admin/staff/new");
            return;
        }
        if (!staffService.isValidStaff(staff, true)) {
            staffService.setFlash(request.getSession(), "staffMessage", "Vui lòng nhập đầy đủ thông tin bắt buộc.", "danger");
            response.sendRedirect(request.getContextPath() + "/admin/staff/new");
            return;
        }
        if (!staffService.validateStaffFields(request.getSession(), staff)) {
            response.sendRedirect(request.getContextPath() + "/admin/staff/new");
            return;
        }

        boolean inserted = staffService.createStaff(staff);
        if (inserted) {
            staffService.setFlash(request.getSession(), "staffMessage", "Tạo nhân viên thành công.", "success");
        } else {
            staffService.setFlash(request.getSession(), "staffMessage", "Không thể tạo nhân viên, vui lòng thử lại.", "danger");
        }
        response.sendRedirect(request.getContextPath() + "/admin/staff");
    }

    private void handleUpdate(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Integer userId = staffService.parseInteger(request.getParameter("userId"));
        if (userId == null) {
            staffService.setFlash(request.getSession(), "staffMessage", "Không tìm thấy nhân viên để cập nhật.", "danger");
            response.sendRedirect(request.getContextPath() + "/admin/staff");
            return;
        }
        User staff = staffService.buildStaffFromRequest(request, STAFF_STATUSES);
        staff.setUserId(userId);

        if (!staffService.isValidStaff(staff, false)) {
            staffService.setFlash(request.getSession(), "staffMessage", "Vui lòng nhập đầy đủ thông tin bắt buộc.", "danger");
            response.sendRedirect(request.getContextPath() + "/admin/staff/edit?id=" + userId);
            return;
        }
        if (!staffService.validateStaffFields(request.getSession(), staff)) {
            response.sendRedirect(request.getContextPath() + "/admin/staff/edit?id=" + userId);
            return;
        }

        if (!staffService.applyPasswordUpdateIfPresent(request.getSession(), request, staff)) {
            response.sendRedirect(request.getContextPath() + "/admin/staff/edit?id=" + userId);
            return;
        }

        boolean updated = staffService.updateStaff(staff);
        if (updated) {
            staffService.setFlash(request.getSession(), "staffMessage", "Cập nhật nhân viên thành công.", "success");
        } else {
            staffService.setFlash(request.getSession(), "staffMessage", "Không thể cập nhật nhân viên, vui lòng thử lại.", "danger");
        }
        response.sendRedirect(request.getContextPath() + "/admin/staff");
    }

    private void handleDelete(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Integer userId = staffService.parseInteger(request.getParameter("userId"));
        if (userId == null) {
            staffService.setFlash(request.getSession(), "staffMessage", "Không tìm thấy nhân viên để xóa.", "danger");
        } else {
            boolean deleted = staffService.deleteStaff(userId);
            if (deleted) {
                staffService.setFlash(request.getSession(), "staffMessage", "Đã xóa nhân viên thành công.", "success");
            } else {
                staffService.setFlash(request.getSession(), "staffMessage", "Không thể xóa nhân viên, vui lòng thử lại.", "danger");
            }
        }
        response.sendRedirect(request.getContextPath() + "/admin/staff");
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

    @Override
    public String getServletInfo() {
        return "Staff management controller";
    }
}
