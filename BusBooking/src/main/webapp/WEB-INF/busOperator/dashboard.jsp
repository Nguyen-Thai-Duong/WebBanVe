<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Collections" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Locale" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.time.LocalDateTime" %>
<%@ page import="model.Trip" %>
<%@ page import="model.Route" %>
<%@ page import="model.Vehicle" %>
<%
    List<Trip> upcomingTrips = (List<Trip>) request.getAttribute("upcomingTrips");
    if (upcomingTrips == null) {
        upcomingTrips = Collections.emptyList();
    }
    Number totalUpcomingAttr = (Number) request.getAttribute("totalUpcomingTrips");
    long totalUpcomingTrips = totalUpcomingAttr != null ? totalUpcomingAttr.longValue() : 0L;
    Number todayTripsAttr = (Number) request.getAttribute("todayTripCount");
    long todayTripCount = todayTripsAttr != null ? todayTripsAttr.longValue() : 0L;
    Number seatCapacityAttr = (Number) request.getAttribute("totalSeatCapacity");
    int totalSeatCapacity = seatCapacityAttr != null ? seatCapacityAttr.intValue() : 0;
    LocalDateTime nextDeparture = (LocalDateTime) request.getAttribute("nextDeparture");

    String contextPath = request.getContextPath();
    String assetBase = contextPath + "/assets/sneat-1.0.0/assets";
    String vendorPath = assetBase + "/vendor";
    String cssPath = assetBase + "/css";
    String jsPath = assetBase + "/js";
    String imgPath = assetBase + "/img";

    DateTimeFormatter fullDateTimeFormatter = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
    NumberFormat currencyFormatter = NumberFormat.getCurrencyInstance(new Locale("vi", "VN"));
%>
<!DOCTYPE html>
<html lang="vi" class="light-style layout-menu-fixed" dir="ltr" data-theme="theme-default" data-assets-path="<%= assetBase %>/" data-template="vertical-menu-template-free">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Nhà xe - Tổng quan</title>

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
        <%@ include file="includes/sidebar.jspf" %>

        <div class="layout-page">
            <%@ include file="includes/navbar.jspf" %>

            <div class="content-wrapper">
                <div class="container-xxl flex-grow-1 container-p-y">
                    <div class="d-flex flex-wrap align-items-center justify-content-between mb-4">
                        <div>
                            <h4 class="fw-bold mb-1">Bảng điều khiển nhà xe</h4>
                            <span class="text-muted">Theo dõi nhanh các chuyến sắp khởi hành và trạng thái vận hành.</span>
                        </div>
                    </div>

                    <div class="row g-4 mb-4">
                        <div class="col-sm-6 col-lg-3">
                            <div class="card">
                                <div class="card-body">
                                    <span class="d-block text-muted mb-1">Chuyến sắp khởi hành</span>
                                    <h4 class="card-title mb-2">
                                        <% if (nextDeparture != null) { %>
                                            <%= nextDeparture.format(fullDateTimeFormatter) %>
                                        <% } else { %>
                                            Không có
                                        <% } %>
                                    </h4>
                                    <small class="text-secondary">Giờ xuất phát gần nhất của bạn.</small>
                                </div>
                            </div>
                        </div>
                        <div class="col-sm-6 col-lg-3">
                            <div class="card">
                                <div class="card-body">
                                    <span class="d-block text-muted mb-1">Chuyến hôm nay</span>
                                    <h4 class="card-title mb-2"><%= todayTripCount %></h4>
                                    <small class="text-secondary">Số chuyến rời bến trong ngày.</small>
                                </div>
                            </div>
                        </div>
                        <div class="col-sm-6 col-lg-3">
                            <div class="card">
                                <div class="card-body">
                                    <span class="d-block text-muted mb-1">Tổng chuyến sắp tới</span>
                                    <h4 class="card-title mb-2"><%= totalUpcomingTrips %></h4>
                                    <small class="text-secondary">Trong vòng vài ngày tới.</small>
                                </div>
                            </div>
                        </div>
                        <div class="col-sm-6 col-lg-3">
                            <div class="card">
                                <div class="card-body">
                                    <span class="d-block text-muted mb-1">Tổng sức chứa</span>
                                    <h4 class="card-title mb-2"><%= totalSeatCapacity %></h4>
                                    <small class="text-secondary">Số ghế khả dụng cho các chuyến.</small>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="card">
                        <div class="card-header d-flex justify-content-between align-items-center">
                            <h5 class="card-title mb-0">Chuyến sắp khởi hành</h5>
                            <span class="badge bg-label-primary"><%= totalUpcomingTrips %> chuyến</span>
                        </div>
                        <div class="table-responsive text-nowrap">
                            <table class="table table-hover mb-0">
                                <thead class="table-light">
                                <tr>
                                    <th>Tuyến</th>
                                    <th>Khởi hành</th>
                                    <th>Phương tiện</th>
                                    <th>Trạng thái</th>
                                    <th>Giá vé</th>
                                </tr>
                                </thead>
                                <tbody>
                                <% if (upcomingTrips.isEmpty()) { %>
                                    <tr>
                                        <td colspan="5" class="text-center text-muted py-4">Chưa có chuyến nào được phân công.</td>
                                    </tr>
                                <% } else {
                                       for (Trip trip : upcomingTrips) {
                                           Route route = trip.getRoute();
                                           Vehicle vehicle = trip.getVehicle();
                                           String routeLabel = route != null ? route.getOrigin() + " → " + route.getDestination() : "--";
                                           LocalDateTime departureTime = trip.getDepartureTime();
                                           String departureLabel = departureTime != null ? departureTime.format(fullDateTimeFormatter) : "--";
                                           String vehicleLabel = vehicle != null ? vehicle.getLicensePlate() : "--";
                                           Integer capacity = vehicle != null ? vehicle.getCapacity() : null;
                                           String status = trip.getTripStatus() != null ? trip.getTripStatus() : "--";
                                           String priceLabel = trip.getPrice() != null ? currencyFormatter.format(trip.getPrice()) : "--";
                                %>
                                    <tr>
                                        <td class="fw-semibold"><%= routeLabel %></td>
                                        <td><%= departureLabel %></td>
                                        <td>
                                            <div class="fw-semibold"><%= vehicleLabel %></div>
                                            <% if (capacity != null) { %>
                                                <small class="text-muted">Sức chứa: <%= capacity %> ghế</small>
                                            <% } %>
                                        </td>
                                        <td>
                                            <span class="badge bg-label-info"><%= status %></span>
                                        </td>
                                        <td><%= priceLabel %></td>
                                    </tr>
                                <%   }
                                   }
                                %>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>

            <div class="content-backdrop fade"></div>
        </div>
    </div>

    <div class="layout-overlay layout-menu-toggle"></div>
</div>

<script src="<%= vendorPath %>/libs/jquery/jquery.js"></script>
<script src="<%= vendorPath %>/libs/popper/popper.js"></script>
<script src="<%= vendorPath %>/js/bootstrap.js"></script>
<script src="<%= vendorPath %>/libs/perfect-scrollbar/perfect-scrollbar.js"></script>
<script src="<%= vendorPath %>/js/menu.js"></script>
<script src="<%= jsPath %>/main.js"></script>
</body>
</html>
