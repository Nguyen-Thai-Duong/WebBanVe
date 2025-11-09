package controller.admin;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import model.Route;
import service.admin.AdminRouteService;

/**
 * Controller responsible for route management flows.
 */
@WebServlet(name = "RouteController", urlPatterns = {"/admin/routes", "/admin/routes/new", "/admin/routes/edit"})
public class RouteController extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final int MAX_TRIPS_PER_ROUTE = 5;
    private static final String DEFAULT_ROUTE_STATUS = "Active";
    private static final List<String> ROUTE_STATUS_OPTIONS = Collections.unmodifiableList(Arrays.asList("Active", "Inactive"));
    private static final Set<String> ROUTE_STATUS_SET = Collections.unmodifiableSet(new HashSet<>(ROUTE_STATUS_OPTIONS));

    private final AdminRouteService routeService = new AdminRouteService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String path = request.getServletPath();
        if ("/admin/routes/new".equals(path)) {
            showCreateForm(request, response);
        } else if ("/admin/routes/edit".equals(path)) {
            showEditForm(request, response);
        } else {
            showRouteList(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String path = request.getServletPath();
        if ("/admin/routes".equals(path)) {
            handleActionPost(request, response);
        } else if ("/admin/routes/new".equals(path)) {
            handleCreate(request, response);
        } else if ("/admin/routes/edit".equals(path)) {
            handleUpdate(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/routes");
        }
    }

    private void showRouteList(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        List<Route> routes = routeService.getAllRoutes();
        request.setAttribute("routes", routes);
        request.setAttribute("maxTripsPerRoute", MAX_TRIPS_PER_ROUTE);
        request.setAttribute("activeMenu", "routes");
        forward(request, response, "/WEB-INF/admin/routes/route-list.jsp");
    }

    private void showCreateForm(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        prepareRouteForm(request, null);
        forward(request, response, "/WEB-INF/admin/routes/route-create.jsp");
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Integer routeId = routeService.parseInteger(request.getParameter("routeId"));
        if (routeId == null) {
            routeService.setFlash(request.getSession(), "routeMessage", "Không tìm thấy tuyến đường.", "danger");
            response.sendRedirect(request.getContextPath() + "/admin/routes");
            return;
        }
        Route route = routeService.getRouteById(routeId);
        if (route == null) {
            routeService.setFlash(request.getSession(), "routeMessage", "Không tìm thấy tuyến đường.", "danger");
            response.sendRedirect(request.getContextPath() + "/admin/routes");
            return;
        }
        prepareRouteForm(request, route);
        forward(request, response, "/WEB-INF/admin/routes/route-edit.jsp");
    }

    private void handleCreate(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Route route = routeService.buildRouteFromRequest(request, ROUTE_STATUS_SET);
        if (!routeService.validateRoute(request.getSession(), request, route, ROUTE_STATUS_SET)) {
            response.sendRedirect(request.getContextPath() + "/admin/routes/new");
            return;
        }
        boolean created = routeService.createRoute(route);
        routeService.setFlash(request.getSession(), "routeMessage", 
                created ? "Tạo tuyến đường thành công." : "Không thể tạo tuyến đường.", 
                created ? "success" : "danger");
        response.sendRedirect(request.getContextPath() + "/admin/routes");
    }

    private void handleUpdate(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Integer routeId = routeService.parseInteger(request.getParameter("routeId"));
        if (routeId == null) {
            routeService.setFlash(request.getSession(), "routeMessage", "Không tìm thấy tuyến đường cần cập nhật.", "danger");
            response.sendRedirect(request.getContextPath() + "/admin/routes");
            return;
        }
        Route route = routeService.buildRouteFromRequest(request, ROUTE_STATUS_SET);
        route.setRouteId(routeId);
        if (!routeService.validateRoute(request.getSession(), request, route, ROUTE_STATUS_SET)) {
            response.sendRedirect(request.getContextPath() + "/admin/routes/edit?routeId=" + routeId);
            return;
        }
        boolean updated = routeService.updateRoute(route);
        routeService.setFlash(request.getSession(), "routeMessage", 
                updated ? "Cập nhật tuyến đường thành công." : "Không thể cập nhật tuyến đường.", 
                updated ? "success" : "danger");
        response.sendRedirect(request.getContextPath() + "/admin/routes");
    }

    private void handleActionPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String action = request.getParameter("action");
        if ("delete".equals(action)) {
            handleDelete(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/routes");
        }
    }

    private void handleDelete(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Integer routeId = routeService.parseInteger(request.getParameter("routeId"));
        if (routeId == null) {
            routeService.setFlash(request.getSession(), "routeMessage", "Không tìm thấy tuyến đường cần xóa.", "danger");
        } else {
            boolean deleted = routeService.deleteRoute(routeId);
            routeService.setFlash(request.getSession(), "routeMessage", 
                    deleted ? "Đã xóa tuyến đường." : "Không thể xóa tuyến đường.", 
                    deleted ? "success" : "danger");
        }
        response.sendRedirect(request.getContextPath() + "/admin/routes");
    }

    private void prepareRouteForm(HttpServletRequest request, Route route) {
        Route resolvedRoute = route != null ? route : new Route();
        if (resolvedRoute.getRouteStatus() == null || resolvedRoute.getRouteStatus().isBlank()) {
            resolvedRoute.setRouteStatus(DEFAULT_ROUTE_STATUS);
        }
        request.setAttribute("route", resolvedRoute);
        request.setAttribute("activeMenu", "routes");
        request.setAttribute("formAction", resolvedRoute.getRouteId() != null
                ? request.getContextPath() + "/admin/routes/edit"
                : request.getContextPath() + "/admin/routes/new");
        request.setAttribute("submitLabel", resolvedRoute.getRouteId() != null ? "Cập nhật" : "Tạo tuyến");
        request.setAttribute("cancelHref", request.getContextPath() + "/admin/routes");
        request.setAttribute("routeStatuses", ROUTE_STATUS_OPTIONS);
    }

    private void forward(HttpServletRequest request, HttpServletResponse response, String path) throws ServletException, IOException {
        request.getRequestDispatcher(path).forward(request, response);
    }

    @Override
    public String getServletInfo() {
        return "Route management controller";
    }
}
