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
    DateTimeFormatter inputFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm");
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
        <!-- Menu -->
        <aside id="layout-menu" class="layout-menu menu-vertical menu bg-menu-theme">
            <div class="app-brand demo">
                <a href="<%= contextPath %>/admin/trips" class="app-brand-link">
                    <span class="app-brand-logo demo">
                        <svg
                            width="26"
                            viewBox="0 0 25 42"
                            version="1.1"
                            xmlns="http://www.w3.org/2000/svg"
                            xmlns:xlink="http://www.w3.org/1999/xlink"
                        >
                            <defs>
                                <path
                                    d="M13.7918663,0.358365126 L3.39788168,7.44174259 C0.566865006,9.69408886 -0.379795268,12.4788597 0.557900856,15.7960551 C0.68998853,16.2305145 1.09562888,17.7872135 3.12357076,19.2293357 C3.8146334,19.7207684 5.32369333,20.3834223 7.65075054,21.2172976 L7.59773219,21.2525164 L2.63468769,24.5493413 C0.445452254,26.3002124 0.0884951797,28.5083815 1.56381646,31.1738486 C2.83770406,32.8170431 5.20850219,33.2640127 7.09180128,32.5391577 C8.347334,32.0559211 11.4559176,30.0011079 16.4175519,26.3747182 C18.0338572,24.4997857 18.6973423,22.4544883 18.4080071,20.2388261 C17.963753,17.5346866 16.1776345,15.5799961 13.0496516,14.3747546 L10.9194936,13.4715819 L18.6192054,7.984237 L13.7918663,0.358365126 Z"
                                    id="path-1"
                                ></path>
                                <path
                                    d="M5.47320593,6.00457225 C4.05321814,8.216144 4.36334763,10.0722806 6.40359441,11.5729822 C8.61520715,12.571656 10.0999176,13.2171421 10.8577257,13.5094407 L15.5088241,14.433041 L18.6192054,7.984237 C15.5364148,3.11535317 13.9273018,0.573395879 13.7918663,0.358365126 C13.5790555,0.511491653 10.8061687,2.3935607 5.47320593,6.00457225 Z"
                                    id="path-3"
                                ></path>
                                <path
                                    d="M7.50063644,21.2294429 L12.3234468,23.3159332 C14.1688022,24.7579751 14.397098,26.4880487 13.008334,28.506154 C11.6195701,30.5242593 10.3099883,31.790241 9.07958868,32.3040991 C5.78142938,33.4346997 4.13234973,34 4.13234973,34 C4.13234973,34 2.75489982,33.0538207 2.37032616e-14,31.1614621 C-0.55822714,27.8186216 -0.55822714,26.0572515 -4.05231404e-15,25.8773518 C0.83734071,25.6075023 2.77988457,22.8248993 3.3049379,22.52991 C3.65497346,22.3332504 5.05353963,21.8997614 7.50063644,21.2294429 Z"
                                    id="path-4"
                                ></path>
                                <path
                                    d="M20.6,7.13333333 L25.6,13.8 C26.2627417,14.6836556 26.0836556,15.9372583 25.2,16.6 C24.8538077,16.8596443 24.4327404,17 24,17 L14,17 C12.8954305,17 12,16.1045695 12,15 C12,14.5672596 12.1403557,14.1461923 12.4,13.8 L17.4,7.13333333 C18.0627417,6.24967773 19.3163444,6.07059163 20.2,6.73333333 C20.3516113,6.84704183 20.4862915,6.981722 20.6,7.13333333 Z"
                                    id="path-5"
                                ></path>
                            </defs>
                            <g stroke="none" stroke-width="1" fill="none" fill-rule="evenodd">
                                <g transform="translate(-27.000000, -15.000000)">
                                    <g transform="translate(27.000000, 15.000000)">
                                        <g transform="translate(0.000000, 8.000000)">
                                            <mask id="mask-2" fill="white">
                                                <use xlink:href="#path-1"></use>
                                            </mask>
                                            <use fill="#696cff" xlink:href="#path-1"></use>
                                            <g mask="url(#mask-2)">
                                                <use fill="#696cff" xlink:href="#path-3"></use>
                                                <use fill-opacity="0.2" fill="#FFFFFF" xlink:href="#path-3"></use>
                                            </g>
                                            <g mask="url(#mask-2)">
                                                <use fill="#696cff" xlink:href="#path-4"></use>
                                                <use fill-opacity="0.2" fill="#FFFFFF" xlink:href="#path-4"></use>
                                            </g>
                                        </g>
                                        <g transform="translate(19.000000, 11.000000) rotate(-300.000000) translate(-19.000000, -11.000000)">
                                            <use fill="#696cff" xlink:href="#path-5"></use>
                                            <use fill-opacity="0.2" fill="#FFFFFF" xlink:href="#path-5"></use>
                                        </g>
                                    </g>
                                </g>
                            </g>
                        </svg>
                    </span>
                    <span class="app-brand-text demo menu-text fw-bolder ms-2">BusBooking</span>
                </a>

                <a href="javascript:void(0);" class="layout-menu-toggle menu-link text-large ms-auto d-block d-xl-none">
                    <i class="bx bx-chevron-left bx-sm align-middle"></i>
                </a>
            </div>

            <div class="menu-inner-shadow"></div>

            <ul class="menu-inner py-1">
                <li class="menu-item">
                    <a href="<%= contextPath %>/admin/dashboard" class="menu-link">
                        <i class="menu-icon tf-icons bx bx-home-circle"></i>
                        <div data-i18n="Dashboard">Dashboard</div>
                    </a>
                </li>

                <li class="menu-header small text-uppercase">
                    <span class="menu-header-text">Quản trị</span>
                </li>

                <li class="menu-item active">
                    <a href="<%= contextPath %>/admin/trips" class="menu-link">
                        <i class="menu-icon tf-icons bx bx-bus"></i>
                        <div data-i18n="Trips">Chuyến đi</div>
                    </a>
                </li>
                <li class="menu-item">
                    <a href="<%= contextPath %>/admin/routes" class="menu-link">
                        <i class="menu-icon tf-icons bx bx-map"></i>
                        <div data-i18n="Routes">Tuyến đường</div>
                    </a>
                </li>
                <li class="menu-item">
                    <a href="<%= contextPath %>/admin/vehicles" class="menu-link">
                        <i class="menu-icon tf-icons bx bx-car"></i>
                        <div data-i18n="Vehicles">Phương tiện</div>
                    </a>
                </li>
            </ul>
        </aside>
        <!-- / Menu -->

        <!-- Layout container -->
        <div class="layout-page">
            <!-- Navbar -->
            <nav
                class="layout-navbar container-xxl navbar navbar-expand-xl navbar-detached align-items-center bg-navbar-theme"
                id="layout-navbar"
            >
                <div class="layout-menu-toggle navbar-nav align-items-xl-center me-3 me-xl-0 d-xl-none">
                    <a class="nav-item nav-link px-0 me-xl-4" href="javascript:void(0)">
                        <i class="bx bx-menu bx-sm"></i>
                    </a>
                </div>

                <div class="navbar-nav-right d-flex align-items-center" id="navbar-collapse">
                    <div class="navbar-nav align-items-center">
                        <div class="nav-item d-flex align-items-center">
                            <i class="bx bx-search fs-4 lh-0"></i>
                            <input
                                type="text"
                                class="form-control border-0 shadow-none"
                                placeholder="Tìm kiếm..."
                                aria-label="Tìm kiếm..."
                            />
                        </div>
                    </div>

                    <ul class="navbar-nav flex-row align-items-center ms-auto">
                        <li class="nav-item navbar-dropdown dropdown-user dropdown">
                            <a class="nav-link dropdown-toggle hide-arrow" href="javascript:void(0);" data-bs-toggle="dropdown">
                                <div class="avatar avatar-online">
                                    <img src="<%= imgPath %>/avatars/1.png" alt class="w-px-40 h-auto rounded-circle" />
                                </div>
                            </a>
                            <ul class="dropdown-menu dropdown-menu-end">
                                <li>
                                    <span class="dropdown-item-text fw-semibold">Quản trị viên</span>
                                </li>
                                <li>
                                    <div class="dropdown-divider"></div>
                                </li>
                                <li>
                                    <a class="dropdown-item" href="<%= contextPath %>/logout">
                                        <i class="bx bx-power-off me-2"></i>
                                        <span class="align-middle">Đăng xuất</span>
                                    </a>
                                </li>
                            </ul>
                        </li>
                    </ul>
                </div>
            </nav>
            <!-- / Navbar -->

            <!-- Content wrapper -->
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
                                    <% } %>
                                <% } %>
                                </tbody>
                            </table>
                        </div>
                    </div>
                    <% if (!trips.isEmpty()) {
                           for (Trip trip : trips) {
                               String modalId = "editTripModal" + trip.getTripId();
                               String deleteId = "deleteTripModal" + trip.getTripId();
                    %>
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
                                                <input type="datetime-local" class="form-control" id="departureTime<%= trip.getTripId() %>" name="departureTime" value="<%= trip.getDepartureTime() != null ? trip.getDepartureTime().format(inputFormatter) : "" %>" required>
                                            </div>
                                            <div class="col-md-6">
                                                <label class="form-label" for="arrivalTime<%= trip.getTripId() %>">Giờ đến</label>
                                                <input type="datetime-local" class="form-control" id="arrivalTime<%= trip.getTripId() %>" name="arrivalTime" value="<%= trip.getArrivalTime() != null ? trip.getArrivalTime().format(inputFormatter) : "" %>">
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
<script src="<%= jsPath %>/main.js"></script>
</body>
</html>