package controller.admin;

import DAO.OperatorDAO;
import DAO.VehicleDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import model.User;
import model.Vehicle;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@WebServlet(name = "VehicleController", urlPatterns = {"/admin/vehicles", "/admin/vehicles/new", "/admin/vehicles/edit"})
public class VehicleController extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = LoggerFactory.getLogger(VehicleController.class);
    private static final String[] VEHICLE_STATUSES = {"Available", "In Service", "Maintenance", "Repair", "Retired"};
    private static final DateTimeFormatter DATE_TIME_FORMATTER = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
    private static final DateTimeFormatter DATE_FORMATTER = DateTimeFormatter.ofPattern("dd/MM/yyyy");

    private final VehicleDAO vehicleDAO = new VehicleDAO();
    private final OperatorDAO operatorDAO = new OperatorDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String path = request.getServletPath();
        if ("/admin/vehicles/new".equals(path)) {
            showCreateForm(request, response);
        } else if ("/admin/vehicles/edit".equals(path)) {
            showEditForm(request, response);
        } else {
            showVehicleList(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String path = request.getServletPath();
        if ("/admin/vehicles".equals(path)) {
            handleActionPost(request, response);
        } else if ("/admin/vehicles/new".equals(path)) {
            handleCreate(request, response);
        } else if ("/admin/vehicles/edit".equals(path)) {
            handleUpdate(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/vehicles");
        }
    }

    private void showVehicleList(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        List<Vehicle> vehicles = vehicleDAO.findAll();
        if (vehicles == null) {
            vehicles = Collections.emptyList();
        }
        request.setAttribute("vehicles", vehicles);
        request.setAttribute("vehicleStatuses", VEHICLE_STATUSES);
        request.setAttribute("dateTimeFormatter", DATE_TIME_FORMATTER);
        request.setAttribute("dateFormatter", DATE_FORMATTER);
        request.setAttribute("activeMenu", "vehicles");
        forward(request, response, "/WEB-INF/admin/vehicles/vehicle-list.jsp");
    }

    private void showCreateForm(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        prepareVehicleForm(request, null);
        forward(request, response, "/WEB-INF/admin/vehicles/vehicle-create.jsp");
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Integer vehicleId = parseInteger(request.getParameter("id"));
        if (vehicleId == null) {
            setFlash(request.getSession(), "vehicleMessage", "Không tìm thấy phương tiện.", "danger");
            response.sendRedirect(request.getContextPath() + "/admin/vehicles");
            return;
        }
        Vehicle vehicle = vehicleDAO.findById(vehicleId);
        if (vehicle == null) {
            setFlash(request.getSession(), "vehicleMessage", "Không tìm thấy phương tiện.", "danger");
            response.sendRedirect(request.getContextPath() + "/admin/vehicles");
            return;
        }
        prepareVehicleForm(request, vehicle);
        forward(request, response, "/WEB-INF/admin/vehicles/vehicle-edit.jsp");
    }

    private void handleCreate(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Vehicle vehicle = buildVehicleFromRequest(request);
        vehicle.setDateAdded(LocalDateTime.now());
        if (!isValidVehicle(vehicle)) {
            setFlash(request.getSession(), "vehicleMessage", "Vui lòng điền đầy đủ thông tin bắt buộc.", "danger");
            response.sendRedirect(request.getContextPath() + "/admin/vehicles/new");
            return;
        }
        boolean created = vehicleDAO.insert(vehicle);
        setFlash(request.getSession(), "vehicleMessage", created ? "Tạo phương tiện thành công." : "Không thể tạo phương tiện.", created ? "success" : "danger");
        response.sendRedirect(request.getContextPath() + "/admin/vehicles");
    }

    private void handleUpdate(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Integer vehicleId = parseInteger(request.getParameter("vehicleId"));
        if (vehicleId == null) {
            setFlash(request.getSession(), "vehicleMessage", "Không tìm thấy phương tiện để cập nhật.", "danger");
            response.sendRedirect(request.getContextPath() + "/admin/vehicles");
            return;
        }
        Vehicle vehicle = buildVehicleFromRequest(request);
        vehicle.setVehicleId(vehicleId);
        if (!isValidVehicle(vehicle)) {
            setFlash(request.getSession(), "vehicleMessage", "Vui lòng điền đầy đủ thông tin bắt buộc.", "danger");
            response.sendRedirect(request.getContextPath() + "/admin/vehicles/edit?id=" + vehicleId);
            return;
        }
        boolean updated = vehicleDAO.update(vehicle);
        setFlash(request.getSession(), "vehicleMessage", updated ? "Cập nhật phương tiện thành công." : "Không thể cập nhật phương tiện.", updated ? "success" : "danger");
        response.sendRedirect(request.getContextPath() + "/admin/vehicles");
    }

    private void handleActionPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String action = request.getParameter("action");
        if ("delete".equals(action)) {
            handleDelete(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/vehicles");
        }
    }

    private void handleDelete(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Integer vehicleId = parseInteger(request.getParameter("vehicleId"));
        if (vehicleId == null) {
            setFlash(request.getSession(), "vehicleMessage", "Không tìm thấy phương tiện để xóa.", "danger");
        } else {
            boolean deleted = vehicleDAO.delete(vehicleId);
            setFlash(request.getSession(), "vehicleMessage", deleted ? "Đã xóa phương tiện." : "Không thể xóa phương tiện.", deleted ? "success" : "danger");
        }
        response.sendRedirect(request.getContextPath() + "/admin/vehicles");
    }

    private Vehicle buildVehicleFromRequest(HttpServletRequest request) {
        Vehicle vehicle = new Vehicle();
        vehicle.setLicensePlate(trim(request.getParameter("licensePlate")));
        vehicle.setModel(trim(request.getParameter("model")));
        vehicle.setCapacity(parseInteger(request.getParameter("capacity")));
        vehicle.setMaintenanceIntervalDays(parseInteger(request.getParameter("maintenanceIntervalDays")));
        vehicle.setLastMaintenanceDate(parseDate(request.getParameter("lastMaintenanceDate")));
        vehicle.setLastRepairDate(parseDate(request.getParameter("lastRepairDate")));
        vehicle.setDetails(trim(request.getParameter("details")));
        vehicle.setVehicleStatus(defaultIfBlank(request.getParameter("vehicleStatus"), VEHICLE_STATUSES[0]));
        vehicle.setCurrentCondition(trim(request.getParameter("currentCondition")));

        String operatorCode = trim(request.getParameter("operatorCode"));
        if (operatorCode != null) {
            User operator = new User();
            operator.setEmployeeCode(operatorCode);
            vehicle.setOperator(operator);
        }
        return vehicle;
    }

    private boolean isValidVehicle(Vehicle vehicle) {
        boolean hasOperator = vehicle.getOperator() != null && vehicle.getOperator().getEmployeeCode() != null;
        return vehicle.getLicensePlate() != null && !vehicle.getLicensePlate().isBlank()
                && vehicle.getCapacity() != null && vehicle.getCapacity() > 0
                && hasOperator;
    }

    private void prepareVehicleForm(HttpServletRequest request, Vehicle vehicle) {
        List<User> operators = operatorDAO.findAll();
        if (operators == null) {
            operators = Collections.emptyList();
        } else {
            List<User> filtered = new ArrayList<>();
            for (User operator : operators) {
                if (operator != null && operator.getEmployeeCode() != null && !operator.getEmployeeCode().isBlank()) {
                    filtered.add(operator);
                }
            }
            operators = filtered;
        }
        request.setAttribute("vehicle", vehicle);
        request.setAttribute("busOperators", operators);
        request.setAttribute("vehicleStatuses", VEHICLE_STATUSES);
        request.setAttribute("dateTimeFormatter", DATE_TIME_FORMATTER);
        request.setAttribute("activeMenu", "vehicles");
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

    private LocalDate parseDate(String value) {
        try {
            return value != null && !value.isBlank() ? LocalDate.parse(value) : null;
        } catch (Exception ex) {
            LOGGER.warn("Failed to parse date value: {}", value);
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
        return "Vehicle management controller";
    }
}
