<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="model.Route" %>
<%@ page import="model.Trip" %>
<%@ page import="model.Vehicle" %>
<%@ page import="model.User" %>
<%
    String contextPath = request.getContextPath();
    String assetBase = contextPath + "/assets/sneat-1.0.0/assets";
    String vendorPath = assetBase + "/vendor";
    String cssPath = assetBase + "/css";
    String jsPath = assetBase + "/js";
    String imgPath = assetBase + "/img";

    String flashMessage = (String) session.getAttribute("tripMessage");
    String flashType = (String) session.getAttribute("tripMessageType");
    if (flashMessage != null) {
        session.removeAttribute("tripMessage");
        session.removeAttribute("tripMessageType");
    }

    request.setAttribute("activeMenu", "trips");
    request.setAttribute("navbarSearchPlaceholder", "Tìm kiếm chuyến đi...");
    request.setAttribute("navbarSearchAriaLabel", "Tìm kiếm chuyến đi");

    List<Route> routes = (List<Route>) request.getAttribute("routes");
    List<Vehicle> vehicles = (List<Vehicle>) request.getAttribute("vehicles");
    List<User> operators = (List<User>) request.getAttribute("operators");
    String[] statuses = (String[]) request.getAttribute("tripStatuses");
    if (statuses == null) {
        statuses = new String[]{"Scheduled", "Departed", "Arrived", "Delayed", "Cancelled"};
    }
    Trip trip = (Trip) request.getAttribute("trip");
    DateTimeFormatter formFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm");
%>
<!DOCTYPE html>
<html lang="vi" class="light-style layout-menu-fixed" dir="ltr" data-theme="theme-default" data-assets-path="<%= assetBase %>/" data-template="vertical-menu-template-free">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chỉnh sửa chuyến đi</title>
    <link rel="icon" type="image/x-icon" href="<%= imgPath %>/favicon/favicon.ico" />
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
    <link href="https://fonts.googleapis.com/css2?family=Public+Sans:wght@300;400;500;600;700&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="<%= vendorPath %>/fonts/boxicons.css" />
    <link rel="stylesheet" href="<%= vendorPath %>/css/core.css" class="template-customizer-core-css" />
    <link rel="stylesheet" href="<%= vendorPath %>/css/theme-default.css" class="template-customizer-theme-css" />
    <link rel="stylesheet" href="<%= cssPath %>/demo.css" />
    <link rel="stylesheet" href="<%= vendorPath %>/libs/perfect-scrollbar/perfect-scrollbar.css" />
    <script src="<%= vendorPath %>/js/helpers.js"></script>
    <script src="<%= jsPath %>/config.js"></script>
</head>
<body>
<div class="layout-wrapper layout-content-navbar">
    <div class="layout-container">
        <%@ include file="../includes/sidebar.jspf" %>
        <div class="layout-page">
            <%@ include file="../includes/navbar.jspf" %>
            <div class="content-wrapper">
                <div class="container-xxl flex-grow-1 container-p-y">
                    <div class="d-flex flex-wrap align-items-center justify-content-between mb-4">
                        <div>
                            <h4 class="fw-bold mb-1">Chỉnh sửa chuyến đi</h4>
                            <% if (trip != null) { %>
                                <span class="text-muted">Cập nhật thông tin cho chuyến #<%= trip.getTripId() %>.</span>
                            <% } else { %>
                                <span class="text-muted">Không tìm thấy chuyến đi.</span>
                            <% } %>
                        </div>
                        <a class="btn btn-secondary" href="<%= contextPath %>/admin/trips">
                            <i class="bx bx-arrow-back"></i> Quay lại danh sách
                        </a>
                    </div>

                    <% if (flashMessage != null) { %>
                        <div class="alert alert-<%= flashType != null ? flashType : "info" %> alert-dismissible" role="alert">
                            <%= flashMessage %>
                            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                        </div>
                    <% } %>

                    <div class="card">
                        <div class="card-header d-flex justify-content-between align-items-center flex-wrap gap-2">
                            <h5 class="card-title mb-0">Thông tin chuyến đi</h5>
                            <% if (trip != null && trip.getDepartureTime() != null) { %>
                                <small class="text-muted">Khởi hành: <%= trip.getDepartureTime() %></small>
                            <% } %>
                        </div>
                        <div class="card-body">
                            <% if (trip == null) { %>
                                <div class="alert alert-warning mb-0" role="alert">
                                    Không thể tải dữ liệu chuyến đi. Vui lòng quay lại danh sách.
                                </div>
                            <% } else { %>
                                <form action="<%= contextPath %>/admin/trips/edit" method="post" class="needs-validation" novalidate>
                                    <input type="hidden" name="tripId" value="<%= trip.getTripId() %>">
                                    <div class="row g-3">
                                        <div class="col-md-6">
                                            <label class="form-label" for="routeId">Tuyến đường</label>
                                            <select class="form-select" id="routeId" name="routeId" required>
                                                <option value="" disabled>Chọn tuyến</option>
                                                <% Integer currentRouteId = trip.getRoute() != null ? trip.getRoute().getRouteId() : null;
                                                   if (routes != null) {
                                                       for (Route route : routes) { %>
                                                <option value="<%= route.getRouteId() %>" <%= currentRouteId != null && currentRouteId.equals(route.getRouteId()) ? "selected" : "" %>>
                                                    <%= route.getOrigin() %> → <%= route.getDestination() %>
                                                </option>
                                                <%     }
                                                   } %>
                                            </select>
                                        </div>
                                        <div class="col-md-6">
                                            <label class="form-label" for="vehicleId">Xe</label>
                                            <select class="form-select" id="vehicleId" name="vehicleId" required>
                                                <option value="" disabled>Chọn xe</option>
                                                <% Integer currentVehicleId = trip.getVehicle() != null ? trip.getVehicle().getVehicleId() : null;
                                                   if (vehicles != null) {
                                                       for (Vehicle vehicle : vehicles) { %>
                                                <option value="<%= vehicle.getVehicleId() %>" <%= currentVehicleId != null && currentVehicleId.equals(vehicle.getVehicleId()) ? "selected" : "" %>>
                                                    <%= vehicle.getLicensePlate() %> - <%= vehicle.getModel() != null ? vehicle.getModel() : "" %>
                                                </option>
                                                <%     }
                                                   } %>
                                            </select>
                                        </div>
                                        <div class="col-md-6">
                                            <label class="form-label" for="operatorId">Nhà xe</label>
                                            <select class="form-select" id="operatorId" name="operatorId" required>
                                                <option value="" disabled>Chọn nhà xe</option>
                                                <% Integer currentOperatorId = trip.getOperator() != null ? trip.getOperator().getUserId() : null;
                                                   if (operators != null) {
                                                       for (User operator : operators) { %>
                                                <option value="<%= operator.getUserId() %>" <%= currentOperatorId != null && currentOperatorId.equals(operator.getUserId()) ? "selected" : "" %>>
                                                    <%= operator.getFullName() %> (<%= operator.getEmployeeCode() != null ? operator.getEmployeeCode() : "" %>)
                                                </option>
                                                <%     }
                                                   } %>
                                            </select>
                                        </div>
                                        <div class="col-md-6">
                                            <label class="form-label" for="price">Giá vé (VND)</label>
                                            <input type="number" class="form-control" id="price" name="price" step="0.01" min="0" value="<%= trip.getPrice() != null ? trip.getPrice().toPlainString() : "0" %>" required>
                                        </div>
                                        <div class="col-md-6">
                                            <label class="form-label" for="departureTime">Giờ khởi hành</label>
                                            <input type="datetime-local" class="form-control" id="departureTime" name="departureTime" value="<%= trip.getDepartureTime() != null ? trip.getDepartureTime().format(formFormatter) : "" %>" required>
                                        </div>
                                        <div class="col-md-6">
                                            <label class="form-label" for="arrivalTime">Giờ đến</label>
                                            <input type="datetime-local" class="form-control" id="arrivalTime" name="arrivalTime" value="<%= trip.getArrivalTime() != null ? trip.getArrivalTime().format(formFormatter) : "" %>">
                                        </div>
                                        <div class="col-md-6">
                                            <label class="form-label" for="tripStatus">Trạng thái</label>
                                            <select class="form-select" id="tripStatus" name="tripStatus" required>
                                                <% String currentStatus = trip.getTripStatus() != null ? trip.getTripStatus() : "Scheduled";
                                                   for (String status : statuses) { %>
                                                <option value="<%= status %>" <%= status.equalsIgnoreCase(currentStatus) ? "selected" : "" %>><%= status %></option>
                                                <% } %>
                                            </select>
                                        </div>
                                    </div>
                                    <div class="d-flex justify-content-end gap-2 mt-4">
                                        <a class="btn btn-outline-secondary" href="<%= contextPath %>/admin/trips">Hủy</a>
                                        <button type="submit" class="btn btn-primary">Lưu thay đổi</button>
                                    </div>
                                </form>
                            <% } %>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
<script src="<%= vendorPath %>/libs/popper/popper.js"></script>
<script src="<%= vendorPath %>/js/bootstrap.js"></script>
<script src="<%= vendorPath %>/js/menu.js"></script>
<script src="<%= jsPath %>/main.js"></script>
</body>
</html>
