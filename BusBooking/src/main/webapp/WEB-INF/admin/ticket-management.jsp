<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Collections" %>
<%@ page import="dto.ticket.TicketSummary" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%
    List<TicketSummary> tickets = (List<TicketSummary>) request.getAttribute("tickets");
    if (tickets == null) {
        tickets = Collections.emptyList();
    }
    String flashMessage = (String) request.getAttribute("flashMessage");
    String flashType = (String) request.getAttribute("flashType");
    String filterKeyword = (String) request.getAttribute("filterKeyword");
    String filterStatus = (String) request.getAttribute("filterStatus");

    String contextPath = request.getContextPath();
    String assetBase = contextPath + "/assets/sneat-1.0.0/assets";
    String vendorPath = assetBase + "/vendor";
    String cssPath = assetBase + "/css";
    String jsPath = assetBase + "/js";
    String imgPath = assetBase + "/img";

    DateTimeFormatter dateTimeFormatter = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
    String[] ticketStatuses = {"Issued", "Used", "Void"};
    String[] bookingStatuses = {"Confirmed", "Pending", "Cancelled", "Void"};
    String[] seatStatuses = {"Booked", "Reserved", "Cancelled"};

    request.setAttribute("activeMenu", "tickets");
    request.setAttribute("navbarSearchPlaceholder", "Tìm kiếm vé...");
%>
<!DOCTYPE html>
<html lang="vi" class="light-style layout-menu-fixed" dir="ltr" data-theme="theme-default" data-assets-path="<%= assetBase %>/" data-template="vertical-menu-template-free">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý vé - Admin</title>

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

    <style>
        .table thead th { white-space: nowrap; }
        .badge-status { text-transform: uppercase; }
        .ticket-actions form { display: inline; }
    </style>
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
                            <h4 class="fw-bold mb-1">Quản lý vé</h4>
                            <span class="text-muted">Giám sát và chỉnh sửa vé, xử lý các trường hợp sai lệch.</span>
                        </div>
                    </div>

                    <div class="card mb-4">
                        <div class="card-body">
                            <form class="row g-3" action="<%= contextPath %>/admin/tickets" method="get">
                                <div class="col-md-6">
                                    <label for="filterKeyword" class="form-label">Tìm kiếm</label>
                                    <input type="text" class="form-control" id="filterKeyword" name="q" placeholder="Mã vé, ghế, khách hàng" value="<%= filterKeyword != null ? filterKeyword : "" %>">
                                </div>
                                <div class="col-md-4">
                                    <label for="filterStatus" class="form-label">Trạng thái vé</label>
                                    <select id="filterStatus" name="status" class="form-select">
                                        <option value="">Tất cả</option>
                                        <% for (String status : ticketStatuses) { %>
                                            <option value="<%= status %>" <%= status.equalsIgnoreCase(filterStatus != null ? filterStatus : "") ? "selected" : "" %>><%= status %></option>
                                        <% } %>
                                    </select>
                                </div>
                                <div class="col-md-2 d-flex align-items-end">
                                    <button type="submit" class="btn btn-outline-secondary w-100">Lọc</button>
                                </div>
                            </form>
                        </div>
                    </div>

                    <% if (flashMessage != null) { %>
                        <div class="alert alert-<%= flashType != null ? flashType : "info" %> alert-dismissible" role="alert">
                            <%= flashMessage %>
                            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                        </div>
                    <% } %>

                    <div class="card">
                        <div class="table-responsive">
                            <table class="table table-hover table-striped align-middle mb-0">
                                <thead>
                                <tr>
                                    <th>Mã vé</th>
                                    <th>Chuyến</th>
                                    <th>Ghế</th>
                                    <th>Khách hàng</th>
                                    <th>Trạng thái</th>
                                    <th>Phát hành</th>
                                    <th class="text-end">Thao tác</th>
                                </tr>
                                </thead>
                                <tbody>
                                <% if (tickets.isEmpty()) { %>
                                    <tr>
                                        <td colspan="7" class="text-center text-muted py-4">Không tìm thấy vé nào phù hợp bộ lọc.</td>
                                    </tr>
                                <% } else {
                                       for (TicketSummary ticket : tickets) {
                                           String modalId = "editTicketModal" + ticket.getTicketId();
                                           String deleteId = "deleteTicketModal" + ticket.getTicketId();
                                           boolean used = "Used".equalsIgnoreCase(ticket.getTicketStatus());
                                           String customerLabel;
                                           if (ticket.getCustomerName() != null && !ticket.getCustomerName().isBlank()) {
                                               customerLabel = ticket.getCustomerName();
                                           } else if (ticket.getGuestPhone() != null && !ticket.getGuestPhone().isBlank()) {
                                               customerLabel = "Khách vãng lai - " + ticket.getGuestPhone();
                                           } else {
                                               customerLabel = "Khách vãng lai";
                                           }
                                %>
                                    <tr>
                                        <td>
                                            <strong><%= ticket.getTicketNumber() %></strong><br>
                                            <small class="text-muted">Booking #<%= ticket.getBookingId() %></small>
                                        </td>
                                        <td>
                                            <div class="fw-semibold"><%= ticket.getRouteLabel() %></div>
                                            <% if (ticket.getDepartureTime() != null) { %>
                                                <small class="text-muted">Xuất phát: <%= ticket.getDepartureTime().format(dateTimeFormatter) %></small>
                                            <% } %>
                                        </td>
                                        <td>
                                            <span class="badge bg-label-primary">Ghế <%= ticket.getSeatNumber() %></span>
                                            <div><small class="text-muted">Seat: <%= ticket.getSeatStatus() %></small></div>
                                        </td>
                                        <td>
                                            <div class="fw-semibold"><%= customerLabel %></div>
                                            <% if (ticket.getCustomerEmail() != null) { %>
                                                <small class="text-muted"><%= ticket.getCustomerEmail() %></small>
                                            <% } else if (ticket.getGuestEmail() != null) { %>
                                                <small class="text-muted"><%= ticket.getGuestEmail() %></small>
                                            <% } %>
                                        </td>
                                        <td>
                                            <span class="badge bg-label-<%= used ? "success" : "info" %> badge-status"><%= ticket.getTicketStatus() %></span>
                                            <div><small class="text-muted">Booking: <%= ticket.getBookingStatus() %></small></div>
                                        </td>
                                        <td>
                                            <% if (ticket.getIssuedDate() != null) { %>
                                                <div class="text-secondary">Phát hành: <%= ticket.getIssuedDate().format(dateTimeFormatter) %></div>
                                            <% } %>
                                            <% if (ticket.getCheckedInAt() != null) { %>
                                                <div class="text-success">Check-in: <%= ticket.getCheckedInAt().format(dateTimeFormatter) %></div>
                                                <small class="text-muted">By <%= ticket.getCheckedInBy() != null ? ticket.getCheckedInBy() : "--" %></small>
                                            <% } %>
                                        </td>
                                        <td class="text-end ticket-actions">
                                            <button type="button" class="btn btn-sm btn-icon btn-secondary" data-bs-toggle="modal" data-bs-target="#<%= modalId %>" title="Chỉnh sửa">
                                                <i class="bx bx-edit"></i>
                                            </button>
                                            <button type="button" class="btn btn-sm btn-icon btn-danger" data-bs-toggle="modal" data-bs-target="#<%= deleteId %>" title="Xóa vé">
                                                <i class="bx bx-trash"></i>
                                            </button>
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
        </div>
    </div>
</div>

<% if (!tickets.isEmpty()) {
       for (TicketSummary ticket : tickets) {
           String modalId = "editTicketModal" + ticket.getTicketId();
           String deleteId = "deleteTicketModal" + ticket.getTicketId();
           String customerLabel;
           if (ticket.getCustomerName() != null && !ticket.getCustomerName().isBlank()) {
               customerLabel = ticket.getCustomerName();
           } else if (ticket.getGuestPhone() != null && !ticket.getGuestPhone().isBlank()) {
               customerLabel = "Khách vãng lai - " + ticket.getGuestPhone();
           } else {
               customerLabel = "Khách vãng lai";
           }
%>
<div class="modal fade" id="<%= modalId %>" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content">
            <form action="<%= contextPath %>/admin/tickets" method="post" class="needs-validation" novalidate>
                <input type="hidden" name="action" value="update">
                <input type="hidden" name="ticketId" value="<%= ticket.getTicketId() %>">
                <div class="modal-header">
                    <h5 class="modal-title">Cập nhật vé <%= ticket.getTicketNumber() %></h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <div class="row g-3">
                        <div class="col-md-4">
                            <label class="form-label" for="seatNumber<%= ticket.getTicketId() %>">Số ghế</label>
                            <input type="text" class="form-control" id="seatNumber<%= ticket.getTicketId() %>" name="seatNumber" value="<%= ticket.getSeatNumber() %>" required>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label" for="seatStatus<%= ticket.getTicketId() %>">Trạng thái ghế</label>
                            <select class="form-select" id="seatStatus<%= ticket.getTicketId() %>" name="seatStatus">
                                <% for (String status : seatStatuses) { %>
                                    <option value="<%= status %>" <%= status.equalsIgnoreCase(ticket.getSeatStatus() != null ? ticket.getSeatStatus() : "") ? "selected" : "" %>><%= status %></option>
                                <% } %>
                            </select>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label" for="bookingStatus<%= ticket.getTicketId() %>">Trạng thái booking</label>
                            <select class="form-select" id="bookingStatus<%= ticket.getTicketId() %>" name="bookingStatus">
                                <% for (String status : bookingStatuses) { %>
                                    <option value="<%= status %>" <%= status.equalsIgnoreCase(ticket.getBookingStatus() != null ? ticket.getBookingStatus() : "") ? "selected" : "" %>><%= status %></option>
                                <% } %>
                            </select>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label" for="ticketStatus<%= ticket.getTicketId() %>">Trạng thái vé</label>
                            <select class="form-select" id="ticketStatus<%= ticket.getTicketId() %>" name="ticketStatus">
                                <% for (String status : ticketStatuses) { %>
                                    <option value="<%= status %>" <%= status.equalsIgnoreCase(ticket.getTicketStatus()) ? "selected" : "" %>><%= status %></option>
                                <% } %>
                            </select>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Thông tin khách</label>
                            <input type="text" class="form-control" value="<%= customerLabel %>" disabled>
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
            <form action="<%= contextPath %>/admin/tickets" method="post">
                <input type="hidden" name="action" value="delete">
                <input type="hidden" name="ticketId" value="<%= ticket.getTicketId() %>">
                <div class="modal-header">
                    <h5 class="modal-title">Xóa vé <%= ticket.getTicketNumber() %></h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    Việc xóa sẽ đồng thời xóa booking, thanh toán và ticket support liên quan.<br>
                    Bạn có chắc chắn muốn tiếp tục?
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Hủy</button>
                    <button type="submit" class="btn btn-danger">Xóa vé</button>
                </div>
            </form>
        </div>
    </div>
</div>
<%     }
   }
%>

<script src="<%= vendorPath %>/libs/popper/popper.js"></script>
<script src="<%= vendorPath %>/js/bootstrap.js"></script>
<script src="<%= vendorPath %>/js/menu.js"></script>
<script src="<%= jsPath %>/main.js"></script>
</body>
</html>
