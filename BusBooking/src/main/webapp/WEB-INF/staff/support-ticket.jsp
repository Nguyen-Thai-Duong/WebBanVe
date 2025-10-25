<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Collections" %>
<%@ page import="dto.SupportTicketView" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%
    List<SupportTicketView> tickets = (List<SupportTicketView>) request.getAttribute("tickets");
    if (tickets == null) {
        tickets = Collections.emptyList();
    }
    String flashMessage = (String) request.getAttribute("flashMessage");
    String flashType = (String) request.getAttribute("flashType");
    String filterStatus = (String) request.getAttribute("filterStatus");
    String filterKeyword = (String) request.getAttribute("filterKeyword");

    String contextPath = request.getContextPath();
    String assetBase = contextPath + "/assets/sneat-1.0.0/assets";
    String vendorPath = assetBase + "/vendor";
    String cssPath = assetBase + "/css";
    String jsPath = assetBase + "/js";
    String imgPath = assetBase + "/img";

    DateTimeFormatter dateTimeFormatter = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
    String[] statuses = {"Open", "InProgress", "Closed"};
    model.User currentUser = (model.User) session.getAttribute("currentUser");
%>
<!DOCTYPE html>
<html lang="vi" class="light-style layout-menu-fixed" dir="ltr" data-theme="theme-default" data-assets-path="<%= assetBase %>/" data-template="vertical-menu-template-free">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hỗ trợ khách hàng</title>

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
                            <h4 class="fw-bold mb-1">Ticket hỗ trợ khách hàng</h4>
                            <span class="text-muted">Theo dõi và cập nhật tiến độ giải quyết yêu cầu.</span>
                        </div>
                    </div>

                    <div class="card mb-4">
                        <div class="card-body">
                            <form class="row g-3" action="<%= contextPath %>/staff/support" method="get">
                                <div class="col-md-6">
                                    <label class="form-label" for="filterKeyword">Tìm kiếm</label>
                                    <input type="text" class="form-control" id="filterKeyword" name="q" placeholder="Từ khóa, khách hàng, email" value="<%= filterKeyword != null ? filterKeyword : "" %>">
                                </div>
                                <div class="col-md-4">
                                    <label class="form-label" for="filterStatus">Trạng thái</label>
                                    <select id="filterStatus" name="status" class="form-select">
                                        <option value="">Tất cả</option>
                                        <% for (String status : statuses) { %>
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
                            <table class="table table-striped table-hover align-middle mb-0">
                                <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>Khách hàng</th>
                                    <th>Liên quan</th>
                                    <th>Trạng thái</th>
                                    <th>Mô tả</th>
                                    <th>Cập nhật</th>
                                    <th class="text-end">Thao tác</th>
                                </tr>
                                </thead>
                                <tbody>
                                <% if (tickets.isEmpty()) { %>
                                    <tr>
                                        <td colspan="7" class="text-center text-muted py-4">Không có ticket hỗ trợ nào.</td>
                                    </tr>
                                <% } else {
                                       for (SupportTicketView ticket : tickets) {
                                           String modalId = "supportModal" + ticket.getSupportId();
                                           String customerName = ticket.getCustomerName() != null ? ticket.getCustomerName() : "Khách ẩn danh";
                                           String status = ticket.getStatus() != null ? ticket.getStatus() : "Open";
                                           String badgeClass = "Open".equalsIgnoreCase(status) ? "warning"
                                                   : ("Closed".equalsIgnoreCase(status) ? "success" : "info");
                                %>
                                    <tr>
                                        <td>#<%= ticket.getSupportId() %></td>
                                        <td>
                                            <div class="fw-semibold"><%= customerName %></div>
                                            <% if (ticket.getCustomerEmail() != null) { %>
                                                <small class="text-muted"><%= ticket.getCustomerEmail() %></small>
                                            <% } else if (ticket.getCustomerPhone() != null) { %>
                                                <small class="text-muted"><%= ticket.getCustomerPhone() %></small>
                                            <% } %>
                                        </td>
                                        <td>
                                            <% if (ticket.getBookingId() != null) { %>
                                                <div>Booking #<%= ticket.getBookingId() %></div>
                                            <% } %>
                                            <% if (ticket.getRouteLabel() != null) { %>
                                                <small class="text-muted"><%= ticket.getRouteLabel() %></small>
                                            <% } %>
                                            <% if (ticket.getDepartureTime() != null) { %>
                                                <small class="text-muted d-block">Chuyến: <%= ticket.getDepartureTime().format(dateTimeFormatter) %></small>
                                            <% } %>
                                        </td>
                                        <td>
                                            <span class="badge bg-label-<%= badgeClass %>"><%= status %></span>
                                            <% if (ticket.getStaffAssignedName() != null) { %>
                                                <div><small class="text-muted">Phụ trách: <%= ticket.getStaffAssignedName() %></small></div>
                                            <% } %>
                                        </td>
                                        <td>
                                            <div class="fw-semibold"><%= ticket.getCategory() != null ? ticket.getCategory() : "--" %></div>
                                            <div class="text-muted"><%= ticket.getIssueDescription() %></div>
                                        </td>
                                        <td>
                                            <% if (ticket.getOpenedDate() != null) { %>
                                                <div class="text-secondary">Mở: <%= ticket.getOpenedDate().format(dateTimeFormatter) %></div>
                                            <% } %>
                                            <% if (ticket.getClosedDate() != null) { %>
                                                <div class="text-success">Đóng: <%= ticket.getClosedDate().format(dateTimeFormatter) %></div>
                                            <% } %>
                                        </td>
                                        <td class="text-end">
                                            <button type="button" class="btn btn-sm btn-icon btn-info text-white" data-bs-toggle="modal" data-bs-target="#<%= modalId %>">
                                                <i class="bx bx-edit"></i>
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
       for (SupportTicketView ticket : tickets) {
           String modalId = "supportModal" + ticket.getSupportId();
           String status = ticket.getStatus() != null ? ticket.getStatus() : "Open";
%>
<div class="modal fade" id="<%= modalId %>" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content">
            <form action="<%= contextPath %>/staff/support" method="post" class="needs-validation" novalidate>
                <input type="hidden" name="action" value="update">
                <input type="hidden" name="supportId" value="<%= ticket.getSupportId() %>">
                <div class="modal-header">
                    <h5 class="modal-title">Cập nhật ticket #<%= ticket.getSupportId() %></h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <div class="row g-3">
                        <div class="col-md-6">
                            <label class="form-label" for="status<%= ticket.getSupportId() %>">Trạng thái</label>
                            <select class="form-select" id="status<%= ticket.getSupportId() %>" name="status">
                                <% for (String st : statuses) { %>
                                    <option value="<%= st %>" <%= st.equalsIgnoreCase(status) ? "selected" : "" %>><%= st %></option>
                                <% } %>
                            </select>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Nhân viên phụ trách</label>
                            <input type="text" class="form-control" value="<%= currentUser != null ? currentUser.getFullName() : "Bạn" %>" disabled>
                        </div>
                        <div class="col-12">
                            <label class="form-label" for="resolution<%= ticket.getSupportId() %>">Hướng xử lý</label>
                            <textarea class="form-control" id="resolution<%= ticket.getSupportId() %>" name="resolution" rows="4" placeholder="Ghi chú xử lý"><%= ticket.getResolutionDetails() != null ? ticket.getResolutionDetails() : "" %></textarea>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Hủy</button>
                    <button type="submit" class="btn btn-primary">Cập nhật</button>
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
