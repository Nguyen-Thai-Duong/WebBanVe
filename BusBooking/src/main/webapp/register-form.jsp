<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi" class="light-style customizer-hide" dir="ltr" data-theme="theme-default"
      data-assets-path="<%= request.getContextPath() %>/assets/sneat-1.0.0/assets/"
      data-template="vertical-menu-template-free">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no, minimum-scale=1.0, maximum-scale=1.0">
    <title>Đăng ký | FUTA Bus Lines</title>
    <meta name="description" content="Tạo tài khoản FUTA Bus Lines để quản lý và đặt vé dễ dàng.">

    <link rel="icon" type="image/png" href="https://cdn.futabus.vn/futa-busline-web-cms-prod/Logo_Futa_Moi_98dac5d84a/Logo_Futa_Moi_98dac5d84a.png">

    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Public+Sans:wght@300;400;500;600;700&display=swap" rel="stylesheet">

    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/sneat-1.0.0/assets/vendor/fonts/boxicons.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/sneat-1.0.0/assets/vendor/css/core.css" class="template-customizer-core-css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/sneat-1.0.0/assets/vendor/css/theme-default.css" class="template-customizer-theme-css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/sneat-1.0.0/assets/css/demo.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/sneat-1.0.0/assets/vendor/libs/perfect-scrollbar/perfect-scrollbar.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/sneat-1.0.0/assets/vendor/css/pages/page-auth.css">

    <script src="<%= request.getContextPath() %>/assets/sneat-1.0.0/assets/vendor/js/helpers.js"></script>
    <script src="<%= request.getContextPath() %>/assets/sneat-1.0.0/assets/js/config.js"></script>
</head>
<body>
<div class="container-xxl">
    <div class="authentication-wrapper authentication-basic container-p-y">
        <div class="authentication-inner">
            <div class="card shadow-sm">
                <div class="card-body">
                    <%
                        String errorMessage = (String) request.getAttribute("errorMessage");
                        String successMessage = (String) request.getAttribute("successMessage");
                        String prefillFullName = (String) request.getAttribute("prefillFullName");
                        String prefillPhone = (String) request.getAttribute("prefillPhone");
                        String prefillEmail = (String) request.getAttribute("prefillEmail");
                        Boolean prefillAgree = (Boolean) request.getAttribute("prefillAgree");
                        boolean agreeChecked = prefillAgree != null && prefillAgree;
                    %>
                    <div class="app-brand justify-content-center mb-4">
                        <a href="<%= request.getContextPath() %>/homepage.jsp" class="app-brand-link gap-2">
                            <span class="app-brand-logo demo">
                                <img src="https://cdn.futabus.vn/futa-busline-web-cms-prod/Logo_Futa_Moi_98dac5d84a/Logo_Futa_Moi_98dac5d84a.png" alt="FUTA Bus Lines" height="48">
                            </span>
                            <span class="app-brand-text demo text-body fw-semibold">FUTA Bus Lines</span>
                        </a>
                    </div>

                    <h4 class="mb-2 text-center">Khởi đầu hành trình cùng FUTA 🚀</h4>
                    <p class="mb-4 text-center text-secondary">Tạo tài khoản để quản lý đặt vé nhanh chóng và tiện lợi.</p>

                    <% if (errorMessage != null) { %>
                        <div class="alert alert-danger" role="alert"><%= errorMessage %></div>
                    <% } else if (successMessage != null) { %>
                        <div class="alert alert-success" role="alert"><%= successMessage %></div>
                    <% } %>

                    <form id="registerForm" class="mb-3" action="<%= request.getContextPath() %>/register" method="post">
                        <div class="mb-3">
                            <label for="fullname" class="form-label">Họ và tên</label>
                            <input type="text" class="form-control" id="fullname" name="fullName"
                                   placeholder="Nhập họ và tên" value="<%= prefillFullName != null ? prefillFullName : "" %>" required>
                        </div>
                        <div class="mb-3">
                            <label for="phone" class="form-label">Số điện thoại</label>
                            <input type="tel" class="form-control" id="phone" name="phone"
                                   placeholder="Nhập số điện thoại" value="<%= prefillPhone != null ? prefillPhone : "" %>" required>
                        </div>
                        <div class="mb-3">
                            <label for="email" class="form-label">Email</label>
                            <input type="email" class="form-control" id="email" name="email"
                                   placeholder="Nhập email của bạn" value="<%= prefillEmail != null ? prefillEmail : "" %>" required>
                        </div>
                        <div class="mb-3 form-password-toggle">
                            <label class="form-label" for="password">Mật khẩu</label>
                            <div class="input-group input-group-merge">
                                <input type="password" id="password" class="form-control" name="password"
                                       placeholder="••••••••" aria-describedby="password" required>
                                <span class="input-group-text cursor-pointer"><i class="bx bx-hide"></i></span>
                            </div>
                        </div>
                        <div class="mb-3 form-password-toggle">
                            <label class="form-label" for="confirmPassword">Xác nhận mật khẩu</label>
                            <div class="input-group input-group-merge">
                                <input type="password" id="confirmPassword" class="form-control" name="confirmPassword"
                                       placeholder="Nhập lại mật khẩu" required>
                                <span class="input-group-text cursor-pointer"><i class="bx bx-hide"></i></span>
                            </div>
                        </div>
                        <div class="mb-4">
                            <div class="form-check">
                                <input class="form-check-input" type="checkbox" id="terms-conditions" name="agree" <%= agreeChecked ? "checked" : "" %> required>
                                <label class="form-check-label" for="terms-conditions">
                                    Tôi đồng ý với <a href="https://futabus.vn/dieu-khoan-su-dung" target="_blank" rel="noreferrer">Điều khoản sử dụng</a>
                                    và <a href="https://futabus.vn/chinh-sach-bao-mat" target="_blank" rel="noreferrer">Chính sách bảo mật</a>.
                                </label>
                            </div>
                        </div>
                        <button class="btn btn-warning d-grid w-100 text-white" type="submit">Đăng ký</button>
                    </form>

                    <p class="text-center mb-0">
                        <span>Đã có tài khoản?</span>
                        <a href="<%= request.getContextPath() %>/login-form.jsp">Đăng nhập ngay</a>
                    </p>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="<%= request.getContextPath() %>/assets/sneat-1.0.0/assets/vendor/libs/jquery/jquery.js"></script>
<script src="<%= request.getContextPath() %>/assets/sneat-1.0.0/assets/vendor/libs/popper/popper.js"></script>
<script src="<%= request.getContextPath() %>/assets/sneat-1.0.0/assets/vendor/js/bootstrap.js"></script>
<script src="<%= request.getContextPath() %>/assets/sneat-1.0.0/assets/vendor/libs/perfect-scrollbar/perfect-scrollbar.js"></script>
<script src="<%= request.getContextPath() %>/assets/sneat-1.0.0/assets/vendor/js/menu.js"></script>
<script src="<%= request.getContextPath() %>/assets/sneat-1.0.0/assets/js/main.js"></script>
</body>
</html>
