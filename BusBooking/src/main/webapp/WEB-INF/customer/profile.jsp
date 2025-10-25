<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User" %>
<%
    String contextPath = request.getContextPath();
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null || !"Customer".equalsIgnoreCase(currentUser.getRole())) {
        response.sendRedirect(contextPath + "/login");
        return;
    }
    User profileUser = (User) request.getAttribute("profileUser");
    if (profileUser == null) {
        profileUser = currentUser;
    }
    String assetBase = contextPath + "/assets/sneat-1.0.0/assets";
    String vendorPath = assetBase + "/vendor";
    String cssPath = assetBase + "/css";
    String jsPath = assetBase + "/js";
    String imgPath = assetBase + "/img";

    String successMessage = (String) request.getAttribute("successMessage");
    String errorMessage = (String) request.getAttribute("errorMessage");

    String prefillFullName = (String) request.getAttribute("prefillFullName");
    String prefillPhone = (String) request.getAttribute("prefillPhone");
    String prefillAddress = (String) request.getAttribute("prefillAddress");

    String fullNameValue = prefillFullName != null ? prefillFullName : profileUser.getFullName();
    String phoneValue = prefillPhone != null ? prefillPhone : profileUser.getPhoneNumber();
    String addressValue = prefillAddress != null ? prefillAddress : profileUser.getAddress();
%>
<!DOCTYPE html>
<html lang="vi" class="light-style layout-menu-fixed" dir="ltr" data-theme="theme-default"
      data-assets-path="<%= assetBase %>/" data-template="vertical-menu-template-free">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thông tin tài khoản</title>

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
        <div class="layout-page">
            <div class="content-wrapper">
                <div class="container-xxl flex-grow-1 container-p-y">
                    <div class="d-flex align-items-center justify-content-between flex-wrap gap-2 mb-4">
                        <div>
                            <h4 class="fw-bold mb-1">Xin chào, <%= fullNameValue %></h4>
                            <p class="text-muted mb-0">Khách hàng · Mã: <%= currentUser.getEmployeeCode() != null ? currentUser.getEmployeeCode() : "Đang cập nhật" %></p>
                        </div>
                        <a href="<%= contextPath %>/homepage.jsp" class="btn btn-outline-secondary">
                            <i class="bx bx-chevron-left"></i> Quay lại trang chủ
                        </a>
                    </div>

                    <% if (successMessage != null) { %>
                        <div class="alert alert-success" role="alert"><%= successMessage %></div>
                    <% } %>
                    <% if (errorMessage != null) { %>
                        <div class="alert alert-danger" role="alert"><%= errorMessage %></div>
                    <% } %>

                    <div class="card mb-4">
                        <h5 class="card-header">Thông tin cá nhân</h5>
                        <div class="card-body">
                            <div class="d-flex align-items-start align-items-sm-center gap-4">
                                <div class="avatar avatar-xl">
                                    <span class="avatar-initial rounded-circle bg-warning text-white fs-3">
                                        <%= fullNameValue != null && !fullNameValue.isBlank() ? fullNameValue.substring(0, 1).toUpperCase() : "C" %>
                                    </span>
                                </div>
                                <div>
                                    <p class="mb-1 fw-semibold"><%= fullNameValue %></p>
                                    <p class="text-muted mb-0"><%= currentUser.getEmail() %></p>
                                </div>
                            </div>
                        </div>
                        <hr class="my-0" />
                        <div class="card-body">
                            <form id="customerProfileForm" method="post" action="<%= contextPath %>/customer/profile">
                                <div class="row">
                                    <div class="mb-3 col-md-6">
                                        <label for="fullName" class="form-label">Họ và tên</label>
                                        <input class="form-control" type="text" id="fullName" name="fullName" value="<%= fullNameValue != null ? fullNameValue : "" %>" required />
                                    </div>
                                    <div class="mb-3 col-md-6">
                                        <label for="email" class="form-label">Email</label>
                                        <input class="form-control" type="email" id="email" value="<%= currentUser.getEmail() %>" readonly />
                                    </div>
                                    <div class="mb-3 col-md-6">
                                        <label class="form-label" for="phoneNumber">Số điện thoại</label>
                                        <div class="input-group input-group-merge">
                                            <span class="input-group-text">VN (+84)</span>
                                            <input type="text" id="phoneNumber" name="phoneNumber" class="form-control" placeholder="0900 000 000" value="<%= phoneValue != null ? phoneValue : "" %>" required />
                                        </div>
                                    </div>
                                    <div class="mb-3 col-md-6">
                                        <label for="address" class="form-label">Địa chỉ</label>
                                        <input type="text" class="form-control" id="address" name="address" placeholder="Nhập địa chỉ" value="<%= addressValue != null ? addressValue : "" %>" />
                                    </div>
                                </div>
                                <div class="mt-2 d-flex gap-2">
                                    <button type="submit" class="btn btn-warning text-white">Lưu thay đổi</button>
                                    <a href="<%= contextPath %>/homepage.jsp" class="btn btn-outline-secondary">Hủy</a>
                                </div>
                            </form>
                        </div>
                    </div>

                    <div class="card">
                        <h5 class="card-header">Bảo mật</h5>
                        <div class="card-body">
                            <p class="mb-3 text-muted">Nếu bạn muốn đổi mật khẩu, vui lòng sử dụng chức năng "Quên mật khẩu" tại trang đăng nhập.</p>
                            <a class="btn btn-outline-primary" href="<%= contextPath %>/forgot-password">Yêu cầu đặt lại mật khẩu</a>
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
