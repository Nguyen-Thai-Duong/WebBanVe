<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Route" %>
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
%>
<!DOCTYPE html>
<html lang="vi" class="light-style layout-menu-fixed" dir="ltr" data-theme="theme-default" data-assets-path="<%= assetBase %>/" data-template="vertical-menu-template-free">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tạo chuyến đi</title>
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
                            <h4 class="fw-bold mb-1">Tạo chuyến đi mới</h4>
                            <span class="text-muted">Thiết lập tuyến, nhà xe và lịch khởi hành.</span>
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
                        <div class="card-header">
                            <h5 class="card-title mb-0">Thông tin chuyến đi</h5>
                        </div>
                        <div class="card-body">
                            <form action="<%= contextPath %>/admin/trips/new" method="post" class="needs-validation" novalidate>
                                <div class="row g-3">
                                    <div class="col-md-6">
                                        <label class="form-label" for="routeId">Tuyến đường</label>
                                        <select class="form-select" id="routeId" name="routeId" required>
                                            <option value="" selected disabled>Chọn tuyến</option>
                                            <% if (routes != null) {
                                                   for (Route route : routes) { %>
                                                <option value="<%= route.getRouteId() %>"><%= route.getOrigin() %> → <%= route.getDestination() %></option>
                                            <%     }
                                               } %>
                                        </select>
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label" for="vehicleId">Xe</label>
                                        <select class="form-select" id="vehicleId" name="vehicleId" required>
                                            <option value="" selected disabled>Chọn xe</option>
                                            <% if (vehicles != null) {
                                                   for (Vehicle vehicle : vehicles) { %>
                                                <option value="<%= vehicle.getVehicleId() %>"><%= vehicle.getLicensePlate() %> - <%= vehicle.getModel() != null ? vehicle.getModel() : "" %></option>
                                            <%     }
                                               } %>
                                        </select>
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label" for="operatorId">Nhà xe</label>
                                        <select class="form-select" id="operatorId" name="operatorId" required>
                                            <option value="" selected disabled>Chọn nhà xe</option>
                                            <% if (operators != null) {
                                                   for (User operator : operators) { %>
                                                <option value="<%= operator.getUserId() %>"><%= operator.getFullName() %> (<%= operator.getEmployeeCode() != null ? operator.getEmployeeCode() : "" %>)</option>
                                            <%     }
                                               } %>
                                        </select>
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label" for="price">Giá vé (VND)</label>
                                        <input type="number" class="form-control" id="price" name="price" step="0.01" min="0" required>
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label" for="departureTime">Giờ khởi hành</label>
                                        <input type="datetime-local" class="form-control" id="departureTime" name="departureTime" required>
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label" for="arrivalTime">Giờ đến</label>
                                        <input type="datetime-local" class="form-control" id="arrivalTime" name="arrivalTime">
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label" for="tripStatus">Trạng thái</label>
                                        <select class="form-select" id="tripStatus" name="tripStatus" required>
                                            <% for (String status : statuses) { %>
                                                <option value="<%= status %>" <%= "Scheduled".equalsIgnoreCase(status) ? "selected" : "" %>><%= status %></option>
                                            <% } %>
                                        </select>
                                    </div>
                                </div>
                                <div class="d-flex justify-content-end gap-2 mt-4">
                                    <a class="btn btn-outline-secondary" href="<%= contextPath %>/admin/trips">Hủy</a>
                                    <button type="submit" class="btn btn-primary">Tạo chuyến</button>
                                </div>
                            </form>
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
