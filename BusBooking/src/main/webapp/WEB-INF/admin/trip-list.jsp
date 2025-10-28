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
    DateTimeFormatter tableFormatter = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
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
%>
<!DOCTYPE html>
<html
    lang="vi"
    class="light-style layout-menu-fixed"
    dir="ltr"
    data-theme="theme-default"
    data-assets-path="<%= assetBase %>/"
    data-template="vertical-menu-template-free"
>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý chuyến đi</title>

    <link rel="icon" type="image/x-icon" href="<%= imgPath %>/favicon/favicon.ico" />

    <!-- Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
    <link href="https://fonts.googleapis.com/css2?family=Public+Sans:wght@300;400;500;600;700&display=swap" rel="stylesheet" />

    <!-- Icons -->
    <link rel="stylesheet" href="<%= vendorPath %>/fonts/boxicons.css" />

    <!-- Core CSS -->
    <link rel="stylesheet" href="<%= vendorPath %>/css/core.css" class="template-customizer-core-css" />
    <link rel="stylesheet" href="<%= vendorPath %>/css/theme-default.css" class="template-customizer-theme-css" />
    <link rel="stylesheet" href="<%= cssPath %>/demo.css" />

    <!-- Vendors CSS -->
    <link rel="stylesheet" href="<%= vendorPath %>/libs/perfect-scrollbar/perfect-scrollbar.css" />

    <!-- Helpers -->
    <script src="<%= vendorPath %>/js/helpers.js"></script>
    <script src="<%= jsPath %>/config.js"></script>

    <style>
        .table thead th { white-space: nowrap; }
        .modal-body .form-label { font-weight: 600; }
    </style>
</head>
<body>
<div class="layout-wrapper layout-content-navbar">
    <div class="layout-container">
        <%@ include file="includes/sidebar.jspf" %>

        <!-- Layout container -->
        <div class="layout-page">
            <!-- Navbar -->
            <%@ include file="includes/navbar.jspf" %>
            <!-- / Navbar -->

            <!-- Content wrapper -->
            <div class="content-wrapper">
                <div class="container-xxl flex-grow-1 container-p-y">
                    <div class="d-flex flex-wrap align-items-center justify-content-between mb-4">
                        <div>
                            <h4 class="fw-bold mb-1">Quản lý chuyến đi</h4>
                            <span class="text-muted">Thêm, sửa, xóa và theo dõi trạng thái chuyến đi.</span>
                        </div>
                        <a class="btn btn-primary" href="<%= contextPath %>/admin/trips/new">
                            <i class="bx bx-plus"></i> Thêm chuyến đi
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
                                           String viewId = "viewTripModal" + trip.getTripId();
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
                                                    <button type="button" class="btn btn-sm btn-icon btn-info text-white" data-bs-toggle="modal" data-bs-target="#<%= viewId %>">
                                                        <i class="bx bx-show"></i>
                                                    </button>
                                                    <a class="btn btn-sm btn-icon btn-primary" href="<%= contextPath %>/admin/trips/edit?tripId=<%= trip.getTripId() %>">
                                                        <i class="bx bx-edit"></i>
                                                    </a>
                                                    <button type="button" class="btn btn-sm btn-icon btn-danger" data-bs-toggle="modal" data-bs-target="#<%= deleteId %>">
                                                        <i class="bx bx-trash"></i>
                                                    </button>
                                            </td>
                                        </tr>
                                    <% } %>
                                <% } %>
                                </tbody>
                            </table>
                        </div>
                    </div>
                    <% if (!trips.isEmpty()) {
                           for (Trip trip : trips) {
                               String viewId = "viewTripModal" + trip.getTripId();
                               String deleteId = "deleteTripModal" + trip.getTripId();
                               java.time.Duration tripDuration = (trip.getDepartureTime() != null && trip.getArrivalTime() != null)
                                       ? java.time.Duration.between(trip.getDepartureTime(), trip.getArrivalTime())
                                       : null;
                               long totalDurationMinutes = tripDuration != null ? tripDuration.toMinutes() : -1;
                               long durationHours = totalDurationMinutes >= 0 ? totalDurationMinutes / 60 : -1;
                               long durationMinutes = totalDurationMinutes >= 0 ? totalDurationMinutes % 60 : -1;
                    %>
                    <div class="modal fade" id="<%= viewId %>" tabindex="-1" aria-hidden="true">
                        <div class="modal-dialog modal-lg modal-dialog-centered">
                            <div class="modal-content">
                                <div class="modal-header">
                                    <h5 class="modal-title">Chi tiết chuyến đi #<%= trip.getTripId() %></h5>
                                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                </div>
                                <div class="modal-body">
                                    <div class="row g-4">
                                        <div class="col-md-6">
                                            <small class="text-muted text-uppercase">Tuyến đường</small>
                                            <p class="mb-1 fw-semibold">
                                                <% if (trip.getRoute() != null) { %>
                                                    <%= trip.getRoute().getOrigin() %> &rarr; <%= trip.getRoute().getDestination() %>
                                                <% } else { %>
                                                    <span class="text-muted">Chưa cập nhật</span>
                                                <% } %>
                                            </p>
                                            <% if (trip.getRoute() != null && trip.getRoute().getDistance() != null) { %>
                                                <small class="text-secondary">Khoảng cách: <%= trip.getRoute().getDistance() %> km</small>
                                            <% } %>
                                        </div>
                                        <div class="col-md-3">
                                            <small class="text-muted text-uppercase d-block">Giờ khởi hành</small>
                                            <span class="fw-semibold">
                                                <%= trip.getDepartureTime() != null ? trip.getDepartureTime().format(tableFormatter) : "Chưa cập nhật" %>
                                            </span>
                                        </div>
                                        <div class="col-md-3">
                                            <small class="text-muted text-uppercase d-block">Giờ đến</small>
                                            <span class="fw-semibold">
                                                <%= trip.getArrivalTime() != null ? trip.getArrivalTime().format(tableFormatter) : "Chưa cập nhật" %>
                                            </span>
                                        </div>
                                        <div class="col-md-3">
                                            <small class="text-muted text-uppercase d-block">Thời lượng</small>
                                            <span class="fw-semibold">
                                                <%= totalDurationMinutes >= 0 ? (durationHours + " giờ " + durationMinutes + " phút") : "Chưa cập nhật" %>
                                            </span>
                                        </div>
                                        <div class="col-md-3">
                                            <small class="text-muted text-uppercase d-block">Giá vé</small>
                                            <span class="fw-semibold text-warning"><%= trip.getPrice() != null ? trip.getPrice().toPlainString() : "0" %> VND</span>
                                        </div>
                                        <div class="col-md-3">
                                            <small class="text-muted text-uppercase d-block">Trạng thái</small>
                                            <span class="badge bg-label-primary"><%= trip.getTripStatus() %></span>
                                        </div>
                                        <div class="col-md-6">
                                            <div class="border rounded-3 p-3 h-100">
                                                <small class="text-muted text-uppercase d-block mb-2">Phương tiện</small>
                                                <% if (trip.getVehicle() != null) { %>
                                                    <p class="mb-1 fw-semibold">Biển số: <%= trip.getVehicle().getLicensePlate() %></p>
                                                    <% if (trip.getVehicle().getModel() != null) { %>
                                                        <p class="mb-1 text-secondary">Dòng xe: <%= trip.getVehicle().getModel() %></p>
                                                    <% } %>
                                                    <p class="mb-1 text-secondary">Số ghế: <%= trip.getVehicle().getCapacity() != null ? trip.getVehicle().getCapacity() : "Chưa rõ" %></p>
                                                    <% if (trip.getVehicle().getVehicleStatus() != null) { %>
                                                        <span class="badge bg-label-success"><%= trip.getVehicle().getVehicleStatus() %></span>
                                                    <% } %>
                                                <% } else { %>
                                                    <span class="text-muted">Chưa cập nhật</span>
                                                <% } %>
                                            </div>
                                        </div>
                                        <div class="col-md-6">
                                            <div class="border rounded-3 p-3 h-100">
                                                <small class="text-muted text-uppercase d-block mb-2">Nhà xe / Điều hành</small>
                                                <% if (trip.getOperator() != null) { %>
                                                    <p class="mb-1 fw-semibold"><%= trip.getOperator().getFullName() %></p>
                                                    <% if (trip.getOperator().getEmployeeCode() != null) { %>
                                                        <p class="mb-1 text-secondary">Mã nhân viên: <%= trip.getOperator().getEmployeeCode() %></p>
                                                    <% } %>
                                                    <p class="mb-1 text-secondary">Email: <%= trip.getOperator().getEmail() %></p>
                                                    <p class="mb-0 text-secondary">Điện thoại: <%= trip.getOperator().getPhoneNumber() %></p>
                                                <% } else { %>
                                                    <span class="text-muted">Chưa cập nhật</span>
                                                <% } %>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="modal-footer">
                                    <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Đóng</button>
                                    <a class="btn btn-primary" href="<%= contextPath %>/admin/trips/edit?tripId=<%= trip.getTripId() %>">
                                        <i class="bx bx-edit me-1"></i> Chỉnh sửa chuyến đi
                                    </a>
                                </div>
                            </div>
                        </div>
                    </div>
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
                    <%       }
                       }
                    %>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Sneat scripts -->
<script src="<%= vendorPath %>/js/helpers.js"></script>
<script src="<%= jsPath %>/config.js"></script>
<script src="<%= vendorPath %>/libs/popper/popper.js"></script>
<script src="<%= vendorPath %>/js/bootstrap.js"></script>
<script src="<%= vendorPath %>/js/menu.js"></script>
<script src="<%= jsPath %>/main.js"></script>
</body>
</html>