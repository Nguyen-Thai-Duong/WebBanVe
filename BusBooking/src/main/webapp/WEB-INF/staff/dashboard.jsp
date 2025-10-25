<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.Collections" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.time.LocalDateTime" %>
<%@ page import="dto.TicketSummary" %>
<%@ page import="dto.SupportTicketView" %>
<%
    Map<String, Number> metrics = (Map<String, Number>) request.getAttribute("metrics");
    long ticketsIssuedToday = metrics != null && metrics.get("ticketsIssuedToday") != null ? metrics.get("ticketsIssuedToday").longValue() : 0L;
    long ticketsVerifiedToday = metrics != null && metrics.get("ticketsVerifiedToday") != null ? metrics.get("ticketsVerifiedToday").longValue() : 0L;
    long ticketsAwaitingVerification = metrics != null && metrics.get("ticketsAwaitingVerification") != null ? metrics.get("ticketsAwaitingVerification").longValue() : 0L;
    long openSupportTickets = metrics != null && metrics.get("openSupportTickets") != null ? metrics.get("openSupportTickets").longValue() : 0L;

    List<TicketSummary> recentTickets = (List<TicketSummary>) request.getAttribute("recentTickets");
    if (recentTickets == null) {
        recentTickets = Collections.emptyList();
    }
    List<TicketSummary> pendingTickets = (List<TicketSummary>) request.getAttribute("pendingTickets");
    if (pendingTickets == null) {
        pendingTickets = Collections.emptyList();
    }
    List<SupportTicketView> recentSupportTickets = (List<SupportTicketView>) request.getAttribute("recentSupportTickets");
    if (recentSupportTickets == null) {
        recentSupportTickets = Collections.emptyList();
    }

    String contextPath = request.getContextPath();
    String assetBase = contextPath + "/assets/sneat-1.0.0/assets";
    String vendorPath = assetBase + "/vendor";
    String cssPath = assetBase + "/css";
    String jsPath = assetBase + "/js";
    String imgPath = assetBase + "/img";

    DateTimeFormatter dateTimeFormatter = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
%>
<!DOCTYPE html>
<html lang="vi" class="light-style layout-menu-fixed" dir="ltr" data-theme="theme-default" data-assets-path="<%= assetBase %>/" data-template="vertical-menu-template-free">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Staff - Tổng quan</title>

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
                            <h4 class="fw-bold mb-1">Bảng điều khiển nhân viên</h4>
                            <span class="text-muted">Tổng hợp nhanh các số liệu phục vụ vận hành quầy vé và hỗ trợ khách.</span>
                        </div>
                    </div>

                    <div class="row g-4 mb-4">
                        <div class="col-sm-6 col-lg-3">
                            <div class="card">
                                <div class="card-body">
                                    <span class="d-block text-muted mb-1">Vé phát hành hôm nay</span>
                                    <h4 class="card-title mb-2"><%= ticketsIssuedToday %></h4>
                                    <small class="text-secondary">Tính từ 00:00 đến hiện tại.</small>
                                </div>
                            </div>
                        </div>
                        <div class="col-sm-6 col-lg-3">
                            <div class="card">
                                <div class="card-body">
                                    <span class="d-block text-muted mb-1">Vé xác thực hôm nay</span>
                                    <h4 class="card-title mb-2"><%= ticketsVerifiedToday %></h4>
                                    <small class="text-secondary">Đã check-in thành công.</small>
                                </div>
                            </div>
                        </div>
                        <div class="col-sm-6 col-lg-3">
                            <div class="card">
                                <div class="card-body">
                                    <span class="d-block text-muted mb-1">Vé chờ xác thực</span>
                                    <h4 class="card-title mb-2"><%= ticketsAwaitingVerification %></h4>
                                    <small class="text-secondary">Trạng thái "Issued" cần xử lý.</small>
                                </div>
                            </div>
                        </div>
                        <div class="col-sm-6 col-lg-3">
                            <div class="card">
                                <div class="card-body">
                                    <span class="d-block text-muted mb-1">Yêu cầu hỗ trợ mở</span>
                                    <h4 class="card-title mb-2"><%= openSupportTickets %></h4>
                                    <small class="text-secondary">Bao gồm trạng thái New &amp; InProgress.</small>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="row g-4 mb-4">
                        <div class="col-lg-6">
                            <div class="card h-100">
                                <div class="card-header d-flex justify-content-between align-items-center">
                                    <h5 class="card-title mb-0">Vé sắp khởi hành cần xác thực</h5>
                                    <span class="badge bg-label-warning"><%= pendingTickets.size() %></span>
                                </div>
                                <div class="table-responsive text-nowrap">
                                    <table class="table table-hover mb-0">
                                        <thead class="table-light">
                                        <tr>
                                            <th>Vé</th>
                                            <th>Tuyến</th>
                                            <th>Khởi hành</th>
                                            <th>Ghế</th>
                                        </tr>
                                        </thead>
                                        <tbody>
                                        <% if (pendingTickets.isEmpty()) { %>
                                            <tr>
                                                <td colspan="4" class="text-center text-muted py-4">Không có vé nào chờ xác thực.</td>
                                            </tr>
                                        <% } else {
                                               for (TicketSummary ticket : pendingTickets) {
                                                   String routeLabel = ticket.getRouteLabel() != null ? ticket.getRouteLabel() : "--";
                                                   LocalDateTime departure = ticket.getDepartureTime();
                                                   String departureLabel = departure != null ? departure.format(dateTimeFormatter) : "--";
                                                   String seatLabel = ticket.getSeatNumber() != null ? ticket.getSeatNumber() : "--";
                                        %>
                                            <tr>
                                                <td>
                                                    <strong><%= ticket.getTicketNumber() %></strong><br>
                                                    <small class="text-muted">Booking #<%= ticket.getBookingId() %></small>
                                                </td>
                                                <td><%= routeLabel %></td>
                                                <td><%= departureLabel %></td>
                                                <td>
                                                    <span class="badge bg-label-primary">Ghế <%= seatLabel %></span>
                                                </td>
                                            </tr>
                                        <%       }
                                               }
                                        %>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                        <div class="col-lg-6">
                            <div class="card h-100">
                                <div class="card-header d-flex justify-content-between align-items-center">
                                    <h5 class="card-title mb-0">Yêu cầu hỗ trợ gần đây</h5>
                                    <span class="badge bg-label-info"><%= recentSupportTickets.size() %></span>
                                </div>
                                <div class="table-responsive text-nowrap">
                                    <table class="table table-hover mb-0">
                                        <thead class="table-light">
                                        <tr>
                                            <th>Mã</th>
                                            <th>Khách hàng</th>
                                            <th>Trạng thái</th>
                                            <th>Thời gian mở</th>
                                        </tr>
                                        </thead>
                                        <tbody>
                                        <% if (recentSupportTickets.isEmpty()) { %>
                                            <tr>
                                                <td colspan="4" class="text-center text-muted py-4">Chưa có yêu cầu hỗ trợ.</td>
                                            </tr>
                                        <% } else {
                                               for (SupportTicketView support : recentSupportTickets) {
                                                   String customer = support.getCustomerName() != null ? support.getCustomerName() : "Khách vãng lai";
                                                   LocalDateTime opened = support.getOpenedDate();
                                                   String openedLabel = opened != null ? opened.format(dateTimeFormatter) : "--";
                                                   String status = support.getStatus() != null ? support.getStatus() : "--";
                                        %>
                                            <tr>
                                                <td>#<%= support.getSupportId() %></td>
                                                <td>
                                                    <div class="fw-semibold"><%= customer %></div>
                                                    <% if (support.getCustomerPhone() != null) { %>
                                                        <small class="text-muted">SĐT: <%= support.getCustomerPhone() %></small>
                                                    <% } %>
                                                </td>
                                                <td>
                                                    <span class="badge bg-label-success"><%= status %></span>
                                                </td>
                                                <td><%= openedLabel %></td>
                                            </tr>
                                        <%       }
                                               }
                                        %>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="card">
                        <div class="card-header d-flex justify-content-between align-items-center">
                            <h5 class="card-title mb-0">Vé được tạo gần đây</h5>
                            <span class="badge bg-label-primary"><%= recentTickets.size() %></span>
                        </div>
                        <div class="table-responsive text-nowrap">
                            <table class="table table-hover mb-0">
                                <thead class="table-light">
                                <tr>
                                    <th>Vé</th>
                                    <th>Tuyến</th>
                                    <th>Khởi hành</th>
                                    <th>Khách hàng</th>
                                    <th>Trạng thái</th>
                                </tr>
                                </thead>
                                <tbody>
                                <% if (recentTickets.isEmpty()) { %>
                                    <tr>
                                        <td colspan="5" class="text-center text-muted py-4">Chưa ghi nhận vé mới.</td>
                                    </tr>
                                <% } else {
                                       for (TicketSummary ticket : recentTickets) {
                                           String routeLabel = ticket.getRouteLabel() != null ? ticket.getRouteLabel() : "--";
                                           LocalDateTime departure = ticket.getDepartureTime();
                                           String departureLabel = departure != null ? departure.format(dateTimeFormatter) : "--";
                                           String customerLabel;
                                           if (ticket.getCustomerName() != null && !ticket.getCustomerName().isBlank()) {
                                               customerLabel = ticket.getCustomerName();
                                           } else if (ticket.getGuestPhone() != null && !ticket.getGuestPhone().isBlank()) {
                                               customerLabel = "Khách vãng lai - " + ticket.getGuestPhone();
                                           } else {
                                               customerLabel = "Khách vãng lai";
                                           }
                                           String ticketStatus = ticket.getTicketStatus() != null ? ticket.getTicketStatus() : "--";
                                %>
                                    <tr>
                                        <td>
                                            <strong><%= ticket.getTicketNumber() %></strong><br>
                                            <small class="text-muted">Phát hành: <%= ticket.getIssuedDate() != null ? ticket.getIssuedDate().format(dateTimeFormatter) : "--" %></small>
                                        </td>
                                        <td><%= routeLabel %></td>
                                        <td><%= departureLabel %></td>
                                        <td><%= customerLabel %></td>
                                        <td>
                                            <span class="badge bg-label-info"><%= ticketStatus %></span>
                                        </td>
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
