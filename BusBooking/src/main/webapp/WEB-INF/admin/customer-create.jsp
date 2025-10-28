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
%>
<!DOCTYPE html>
<html lang="vi" class="light-style layout-menu-fixed" dir="ltr" data-theme="theme-default" data-assets-path="<%= assetBase %>/" data-template="vertical-menu-template-free">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tạo khách hàng</title>
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
                            <h4 class="fw-bold mb-1">Tạo khách hàng mới</h4>
                            <span class="text-muted">Nhập thông tin chi tiết cho khách hàng mới.</span>
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
                        <div class="card-header">
                            <h5 class="card-title mb-0">Thông tin khách hàng</h5>
                        </div>
                        <div class="card-body">
                            <form action="<%= contextPath %>/admin/customers/new" method="post" class="needs-validation" novalidate>
                                <div class="row g-3">
                                    <div class="col-md-6">
                                        <label class="form-label" for="fullName">Họ và tên</label>
                                        <input type="text" class="form-control" id="fullName" name="fullName" required>
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label" for="email">Email</label>
                                        <input type="email" class="form-control" id="email" name="email" required>
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label" for="phoneNumber">Điện thoại</label>
                                        <input type="text" class="form-control" id="phoneNumber" name="phoneNumber" required>
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label" for="status">Trạng thái</label>
                                        <select class="form-select" id="status" name="status" required>
                                            <% for (String status : statuses) { %>
                                                <option value="<%= status %>" <%= "Active".equalsIgnoreCase(status) ? "selected" : "" %>><%= status %></option>
                                            <% } %>
                                        </select>
                                    </div>
                                    <div class="col-12">
                                        <label class="form-label" for="address">Địa chỉ</label>
                                        <textarea class="form-control" id="address" name="address" rows="3" placeholder="Số nhà, đường, quận/huyện, tỉnh/thành"></textarea>
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label" for="password">Mật khẩu</label>
                                        <input type="password" class="form-control" id="password" name="password" required>
                                        <div class="form-text">Mật khẩu sẽ được mã hóa SHA-256 trước khi lưu.</div>
                                    </div>
                                </div>
                                <div class="d-flex justify-content-end gap-2 mt-4">
                                    <a class="btn btn-outline-secondary" href="<%= contextPath %>/admin/customers">Hủy</a>
                                    <button type="submit" class="btn btn-primary">Tạo khách hàng</button>
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
