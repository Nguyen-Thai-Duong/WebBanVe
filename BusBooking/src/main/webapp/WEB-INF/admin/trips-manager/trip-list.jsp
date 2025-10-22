<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Collections" %>
<%@ page import="model.Trip" %>
<%@ page import="model.Route" %>
<%@ page import="model.Vehicle" %>
<%@ page import="model.User" %>
<%@ page import="java.time.format.DateTimeFormatter" %>

<%
    List<Trip> trips = (List<Trip>) request.getAttribute("trips");
    if (trips == null) {
        trips = Collections.emptyList();
    }
    List<Route> routes = (List<Route>) request.getAttribute("routes");
    if (routes == null) {
        routes = Collections.emptyList();
    }
    List<Vehicle> vehicles = (List<Vehicle>) request.getAttribute("vehicles");
    if (vehicles == null) {
        vehicles = Collections.emptyList();
    }
    List<User> operators = (List<User>) request.getAttribute("operators");
    if (operators == null) {
        operators = Collections.emptyList();
    }

    String[] statuses = {"Scheduled", "Departed", "Arrived", "Delayed", "Cancelled"};
    DateTimeFormatter tableFormatter = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
    String contextPath = request.getContextPath();
    String assetRoot = contextPath + "/sneat-1.0.0/sneat-1.0.0";
    String vendorPath = assetRoot + "/assets/vendor";
    String cssPath = assetRoot + "/assets/css";
    String jsPath = assetRoot + "/assets/js";

    String flashMessage = (String) session.getAttribute("tripMessage");
    String flashType = (String) session.getAttribute("tripMessageType");
    if (flashMessage != null) {
        session.removeAttribute("tripMessage");
        session.removeAttribute("tripMessageType");
    }
%>
<!DOCTYPE html>
<html lang="vi" class="light-style layout-menu-fixed" data-theme="theme-default">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý chuyến đi</title>

    <!-- Sneat core styles -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Public+Sans:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="<%= vendorPath %>/fonts/boxicons.css">
    <link rel="stylesheet" href="<%= vendorPath %>/css/core.css">
    <link rel="stylesheet" href="<%= vendorPath %>/css/theme-default.css">
    <link rel="stylesheet" href="<%= cssPath %>/demo.css">

    <style>
        .table thead th { white-space: nowrap; }
        .modal-body .form-label { font-weight: 600; }
    </style>
</head>
<body>
<div class="layout-wrapper layout-content-navbar">
    <div class="layout-container">
        <div class="layout-page">
            <div class="content-wrapper">
                <div class="container-xxl flex-grow-1 container-p-y">
                    <div class="d-flex flex-wrap align-items-center justify-content-between mb-4">
                        <div>
                            <h4 class="fw-bold mb-1">Quản lý chuyến đi</h4>
                            <span class="text-muted">Thêm, sửa, xóa và theo dõi trạng thái chuyến đi.</span>
                        </div>
                        <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#createTripModal">
                            <i class="bx bx-plus"></i> Thêm chuyến đi
                        </button>
                    </div>

                    <% if (flashMessage != null) { %>
                        <div class="alert alert-<%= flashType != null ? flashType : "info" %> alert-dismissible" role="alert">
                            <%= flashMessage %>
                            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                        </div>
                    <% } %>

                    <div class="card">
                        <div class="card-header d-flex justify-content-between align-items-center flex-wrap gap-2">
                            <div>
                                <h5 class="card-title mb-0">Danh sách chuyến đi</h5>
                                <small class="text-muted">Tổng cộng <strong><%= trips.size() %></strong> chuyến.</small>
                            </div>
                        </div>
                        <div class="table-responsive">
                            <table class="table table-hover table-striped mb-0">
                                <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>Tuyến</th>
                                    <th>Giờ khởi hành</th>
                                    <th>Giờ đến</th>
                                    <th>Giá vé</th>
                                    <th>Xe</th>
                                    <th>Nhà xe</th>
                                    <th>Trạng thái</th>
                                    <th class="text-end">Thao tác</th>
                                </tr>
                                </thead>
                                <tbody>
                                <% if (trips.isEmpty()) { %>
                                    <tr>
                                        <td colspan="9" class="text-center text-muted py-4">Chưa có chuyến đi nào.</td>
                                    </tr>
                                <% } else { %>
                                    <% for (Trip trip : trips) {
                                           String modalId = "editTripModal" + trip.getTripId();
                                           String deleteId = "deleteTripModal" + trip.getTripId();
                                    %>
                                        <tr>
                                            <td><strong><%= trip.getTripId() %></strong></td>
                                            <td>
                                                <% if (trip.getRoute() != null) { %>
                                                    <span class="fw-semibold"><%= trip.getRoute().getOrigin() %> → <%= trip.getRoute().getDestination() %></span>
                                                <% } else { %>
                                                    <span class="text-muted">N/A</span>
                                                <% } %>
                                            </td>
                                            <td>
                                                <%= trip.getDepartureTime() != null ? trip.getDepartureTime().format(tableFormatter) : "N/A" %>
                                            </td>
                                            <td>
                                                <%= trip.getArrivalTime() != null ? trip.getArrivalTime().format(tableFormatter) : "N/A" %>
                                            </td>
                                            <td><%= trip.getPrice() != null ? trip.getPrice().toPlainString() : "0" %></td>
                                            <td>
                                                <% if (trip.getVehicle() != null) { %>
                                                    <span class="badge bg-label-primary"><%= trip.getVehicle().getLicensePlate() %></span>
                                                    <small class="text-muted d-block"><%= trip.getVehicle().getModel() != null ? trip.getVehicle().getModel() : "" %></small>
                                                <% } else { %>
                                                    <span class="text-muted">N/A</span>
                                                <% } %>
                                            </td>
                                            <td>
                                                <% if (trip.getOperator() != null) { %>
                                                    <span class="fw-semibold"><%= trip.getOperator().getFullName() %></span>
                                                    <small class="text-muted d-block"><%= trip.getOperator().getEmail() != null ? trip.getOperator().getEmail() : "" %></small>
                                                <% } else { %>
                                                    <span class="text-muted">N/A</span>
                                                <% } %>
                                            </td>
                                            <td>
                                                <span class="badge bg-label-info"><%= trip.getTripStatus() %></span>
                                            </td>
                                            <td class="text-end">
                                                <button type="button" class="btn btn-sm btn-icon btn-primary" data-bs-toggle="modal" data-bs-target="#<%= modalId %>">
                                                    <i class="bx bx-edit"></i>
                                                </button>
                                                <button type="button" class="btn btn-sm btn-icon btn-danger" data-bs-toggle="modal" data-bs-target="#<%= deleteId %>">
                                                    <i class="bx bx-trash"></i>
                                                </button>
                                            </td>
                                        </tr>

                                        <!-- Edit modal -->
                                        <div class="modal fade" id="<%= modalId %>" tabindex="-1" aria-hidden="true">
                                            <div class="modal-dialog modal-lg modal-dialog-centered">
                                                <div class="modal-content">
                                                    <form action="<%= contextPath %>/admin/trips" method="post" class="needs-validation" novalidate>
                                                        <input type="hidden" name="action" value="update">
                                                        <input type="hidden" name="tripId" value="<%= trip.getTripId() %>">
                                                        <div class="modal-header">
                                                            <h5 class="modal-title">Cập nhật chuyến đi #<%= trip.getTripId() %></h5>
                                                            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                                        </div>
                                                        <div class="modal-body">
                                                            <div class="row g-3">
                                                                <div class="col-md-6">
                                                                    <label class="form-label" for="routeId<%= trip.getTripId() %>">Tuyến đường</label>
                                                                    <select class="form-select" id="routeId<%= trip.getTripId() %>" name="routeId" required>
                                                                        <option value="" disabled>Chọn tuyến</option>
                                                                        <% for (Route route : routes) { %>
                                                                            <option value="<%= route.getRouteId() %>" <%= trip.getRoute() != null && route.getRouteId().equals(trip.getRoute().getRouteId()) ? "selected" : "" %>>
                                                                                <%= route.getOrigin() %> → <%= route.getDestination() %>
                                                                            </option>
                                                                        <% } %>
                                                                    </select>
                                                                </div>
                                                                <div class="col-md-6">
                                                                    <label class="form-label" for="vehicleId<%= trip.getTripId() %>">Xe</label>
                                                                    <select class="form-select" id="vehicleId<%= trip.getTripId() %>" name="vehicleId" required>
                                                                        <option value="" disabled>Chọn xe</option>
                                                                        <% for (Vehicle vehicle : vehicles) { %>
                                                                            <option value="<%= vehicle.getVehicleId() %>" <%= trip.getVehicle() != null && vehicle.getVehicleId().equals(trip.getVehicle().getVehicleId()) ? "selected" : "" %>>
                                                                                <%= vehicle.getLicensePlate() %> - <%= vehicle.getModel() != null ? vehicle.getModel() : "" %>
                                                                            </option>
                                                                        <% } %>
                                                                    </select>
                                                                </div>
                                                                <div class="col-md-6">
                                                                    <label class="form-label" for="operatorId<%= trip.getTripId() %>">Nhà xe</label>
                                                                    <select class="form-select" id="operatorId<%= trip.getTripId() %>" name="operatorId" required>
                                                                        <option value="" disabled>Chọn nhà xe</option>
                                                                        <% for (User operator : operators) { %>
                                                                            <option value="<%= operator.getUserId() %>" <%= trip.getOperator() != null && operator.getUserId().equals(trip.getOperator().getUserId()) ? "selected" : "" %>>
                                                                                <%= operator.getFullName() %> (<%= operator.getEmployeeCode() != null ? operator.getEmployeeCode() : "" %>)
                                                                            </option>
                                                                        <% } %>
                                                                    </select>
                                                                </div>
                                                                <div class="col-md-6">
                                                                    <label class="form-label" for="price<%= trip.getTripId() %>">Giá vé (VND)</label>
                                                                    <input type="number" class="form-control" id="price<%= trip.getTripId() %>" name="price" step="0.01" min="0" value="<%= trip.getPrice() != null ? trip.getPrice().toPlainString() : "0" %>" required>
                                                                </div>
                                                                <div class="col-md-6">
                                                                    <label class="form-label" for="departureTime<%= trip.getTripId() %>">Giờ khởi hành</label>
                                                                    <input type="datetime-local" class="form-control" id="departureTime<%= trip.getTripId() %>" name="departureTime" value="<%= trip.getDepartureTime() != null ? trip.getDepartureTime().toString().substring(0, 16) : "" %>" required>
                                                                </div>
                                                                <div class="col-md-6">
                                                                    <label class="form-label" for="arrivalTime<%= trip.getTripId() %>">Giờ đến</label>
                                                                    <input type="datetime-local" class="form-control" id="arrivalTime<%= trip.getTripId() %>" name="arrivalTime" value="<%= trip.getArrivalTime() != null ? trip.getArrivalTime().toString().substring(0, 16) : "" %>">
                                                                </div>
                                                                <div class="col-md-6">
                                                                    <label class="form-label" for="tripStatus<%= trip.getTripId() %>">Trạng thái</label>
                                                                    <select class="form-select" id="tripStatus<%= trip.getTripId() %>" name="tripStatus" required>
                                                                        <% for (String status : statuses) { %>
                                                                            <option value="<%= status %>" <%= status.equalsIgnoreCase(trip.getTripStatus()) ? "selected" : "" %>><%= status %></option>
                                                                        <% } %>
                                                                    </select>
                                                                </div>
                                                            </div>
                                                        </div>
                                                        <div class="modal-footer">
                                                            <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Hủy</button>
                                                            <button type="submit" class="btn btn-primary">Lưu thay đổi</button>
                                                        </div>
                                                    </form>
                                                </div>
                                            </div>
                                        </div>

                                        <!-- Delete confirmation modal -->
                                        <div class="modal fade" id="<%= deleteId %>" tabindex="-1" aria-hidden="true">
                                            <div class="modal-dialog modal-dialog-centered">
                                                <div class="modal-content">
                                                    <form action="<%= contextPath %>/admin/trips" method="post">
                                                        <input type="hidden" name="action" value="delete">
                                                        <input type="hidden" name="tripId" value="<%= trip.getTripId() %>">
                                                        <div class="modal-header">
                                                            <h5 class="modal-title">Xóa chuyến đi</h5>
                                                            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                                        </div>
                                                        <div class="modal-body">
                                                            Bạn có chắc chắn muốn xóa chuyến đi <strong>#<%= trip.getTripId() %></strong>?<br>
                                                            Thao tác này không thể hoàn tác.
                                                        </div>
                                                        <div class="modal-footer">
                                                            <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Hủy</button>
                                                            <button type="submit" class="btn btn-danger">Xóa</button>
                                                        </div>
                                                    </form>
                                                </div>
                                            </div>
                                        </div>
                                    <% } %>
                                <% } %>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Create modal -->
<div class="modal fade" id="createTripModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content">
            <form action="<%= contextPath %>/admin/trips" method="post" class="needs-validation" novalidate>
                <input type="hidden" name="action" value="create">
                <div class="modal-header">
                    <h5 class="modal-title">Tạo chuyến đi mới</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <div class="row g-3">
                        <div class="col-md-6">
                            <label class="form-label" for="routeIdCreate">Tuyến đường</label>
                            <select class="form-select" id="routeIdCreate" name="routeId" required>
                                <option value="" selected disabled>Chọn tuyến</option>
                                <% for (Route route : routes) { %>
                                    <option value="<%= route.getRouteId() %>"><%= route.getOrigin() %> → <%= route.getDestination() %></option>
                                <% } %>
                            </select>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label" for="vehicleIdCreate">Xe</label>
                            <select class="form-select" id="vehicleIdCreate" name="vehicleId" required>
                                <option value="" selected disabled>Chọn xe</option>
                                <% for (Vehicle vehicle : vehicles) { %>
                                    <option value="<%= vehicle.getVehicleId() %>"><%= vehicle.getLicensePlate() %> - <%= vehicle.getModel() != null ? vehicle.getModel() : "" %></option>
                                <% } %>
                            </select>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label" for="operatorIdCreate">Nhà xe</label>
                            <select class="form-select" id="operatorIdCreate" name="operatorId" required>
                                <option value="" selected disabled>Chọn nhà xe</option>
                                <% for (User operator : operators) { %>
                                    <option value="<%= operator.getUserId() %>"><%= operator.getFullName() %> (<%= operator.getEmployeeCode() != null ? operator.getEmployeeCode() : "" %>)</option>
                                <% } %>
                            </select>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label" for="priceCreate">Giá vé (VND)</label>
                            <input type="number" class="form-control" id="priceCreate" name="price" step="0.01" min="0" required>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label" for="departureTimeCreate">Giờ khởi hành</label>
                            <input type="datetime-local" class="form-control" id="departureTimeCreate" name="departureTime" required>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label" for="arrivalTimeCreate">Giờ đến</label>
                            <input type="datetime-local" class="form-control" id="arrivalTimeCreate" name="arrivalTime">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label" for="tripStatusCreate">Trạng thái</label>
                            <select class="form-select" id="tripStatusCreate" name="tripStatus" required>
                                <% for (String status : statuses) { %>
                                    <option value="<%= status %>" <%= "Scheduled".equalsIgnoreCase(status) ? "selected" : "" %>><%= status %></option>
                                <% } %>
                            </select>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Hủy</button>
                    <button type="submit" class="btn btn-primary">Tạo chuyến</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Sneat scripts -->
<script src="<%= vendorPath %>/js/helpers.js"></script>
<script src="<%= jsPath %>/config.js"></script>
<script src="<%= vendorPath %>/libs/popper/popper.js"></script>
<script src="<%= vendorPath %>/js/bootstrap.js"></script>
<script src="<%= vendorPath %>/js/menu.js"></script>
</body>
</html>