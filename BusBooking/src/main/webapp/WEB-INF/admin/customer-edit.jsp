<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User" %>
<%
    String contextPath = request.getContextPath();
    String assetBase = contextPath + "/assets/sneat-1.0.0/assets";
    String vendorPath = assetBase + "/vendor";
    String cssPath = assetBase + "/css";
    String jsPath = assetBase + "/js";
    String imgPath = assetBase + "/img";

    String flashMessage = (String) session.getAttribute("customerMessage");
    String flashType = (String) session.getAttribute("customerMessageType");
    if (flashMessage != null) {
        session.removeAttribute("customerMessage");
        session.removeAttribute("customerMessageType");
    }

    request.setAttribute("activeMenu", "customers");
    request.setAttribute("navbarSearchPlaceholder", "Tìm kiếm khách hàng...");
    request.setAttribute("navbarSearchAriaLabel", "Tìm kiếm khách hàng");
    String[] statuses = (String[]) request.getAttribute("customerStatuses");
    if (statuses == null) {
        statuses = new String[]{"Active", "Inactive", "Suspended", "Locked"};
    }
    User customer = (User) request.getAttribute("customer");
%>
<!DOCTYPE html>
<html lang="vi" class="light-style layout-menu-fixed" dir="ltr" data-theme="theme-default" data-assets-path="<%= assetBase %>/" data-template="vertical-menu-template-free">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chỉnh sửa khách hàng</title>
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
                            <h4 class="fw-bold mb-1">Chỉnh sửa khách hàng</h4>
                            <% if (customer != null) { %>
                                <span class="text-muted">Cập nhật thông tin cho khách hàng #<%= customer.getUserId() %>.</span>
                            <% } else { %>
                                <span class="text-muted">Không tìm thấy khách hàng.</span>
                            <% } %>
                        </div>
                        <a class="btn btn-secondary" href="<%= contextPath %>/admin/customers">
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
                            <h5 class="card-title mb-0">Thông tin khách hàng</h5>
                            <% if (customer != null && customer.getCreatedAt() != null) { %>
                                <small class="text-muted">Tạo ngày: <%= customer.getCreatedAt() %></small>
                            <% } %>
                        </div>
                        <div class="card-body">
                            <% if (customer == null) { %>
                                <div class="alert alert-warning mb-0" role="alert">
                                    Không thể tải dữ liệu khách hàng. Vui lòng quay lại danh sách.
                                </div>
                            <% } else { %>
                                <form action="<%= contextPath %>/admin/customers/edit" method="post" class="needs-validation" novalidate>
                                    <input type="hidden" name="userId" value="<%= customer.getUserId() %>">
                                    <div class="row g-3">
                                        <div class="col-md-6">
                                            <label class="form-label" for="fullName">Họ và tên</label>
                                            <input type="text" class="form-control" id="fullName" name="fullName" value="<%= customer.getFullName() != null ? customer.getFullName() : "" %>" required>
                                        </div>
                                        <div class="col-md-6">
                                            <label class="form-label" for="email">Email</label>
                                            <input type="email" class="form-control" id="email" name="email" value="<%= customer.getEmail() != null ? customer.getEmail() : "" %>" required>
                                        </div>
                                        <div class="col-md-6">
                                            <label class="form-label" for="phoneNumber">Điện thoại</label>
                                            <input type="text" class="form-control" id="phoneNumber" name="phoneNumber" value="<%= customer.getPhoneNumber() != null ? customer.getPhoneNumber() : "" %>" required>
                                        </div>
                                        <div class="col-md-6">
                                            <label class="form-label" for="status">Trạng thái</label>
                                            <select class="form-select" id="status" name="status" required>
                                                <% String currentStatus = customer.getStatus() != null ? customer.getStatus() : "Active"; %>
                                                <% for (String status : statuses) { %>
                                                    <option value="<%= status %>" <%= status.equalsIgnoreCase(currentStatus) ? "selected" : "" %>><%= status %></option>
                                                <% } %>
                                            </select>
                                        </div>
                                        <div class="col-12">
                                            <label class="form-label" for="address">Địa chỉ</label>
                                            <textarea class="form-control" id="address" name="address" rows="3"><%= customer.getAddress() != null ? customer.getAddress() : "" %></textarea>
                                        </div>
                                        <div class="col-md-6">
                                            <label class="form-label" for="password">Đặt lại mật khẩu (tùy chọn)</label>
                                            <input type="password" class="form-control" id="password" name="password" placeholder="Nhập mật khẩu mới nếu muốn thay đổi">
                                            <div class="form-text">Để trống nếu không muốn thay đổi mật khẩu.</div>
                                        </div>
                                    </div>
                                    <div class="d-flex justify-content-end gap-2 mt-4">
                                        <a class="btn btn-outline-secondary" href="<%= contextPath %>/admin/customers">Hủy</a>
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
