<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi" class="light-style customizer-hide" dir="ltr" data-theme="theme-default"
      data-assets-path="<%= request.getContextPath() %>/assets/sneat-1.0.0/assets/"
      data-template="vertical-menu-template-free">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no, minimum-scale=1.0, maximum-scale=1.0">
    <title>Xác nhận mã & đặt lại mật khẩu | FUTA Bus Lines</title>

    <link rel="icon" type="image/png" href="https://cdn.futabus.vn/futa-busline-web-cms-prod/Logo_Futa_Moi_98dac5d84a/Logo_Futa_Moi_98dac5d84a.png">

    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap&subset=latin-ext,vietnamese" rel="stylesheet">

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
        <div class="authentication-inner py-4">
            <div class="card shadow-sm">
                <div class="card-body">
                    <div class="app-brand justify-content-center mb-4">
                        <a href="<%= request.getContextPath() %>/homepage.jsp" class="app-brand-link gap-2">
                            <span class="app-brand-logo demo">
                                <img src="https://cdn.futabus.vn/futa-busline-web-cms-prod/Logo_Futa_Moi_98dac5d84a/Logo_Futa_Moi_98dac5d84a.png" alt="FUTA Bus Lines" height="48">
                            </span>
                            <span class="app-brand-text demo text-body fw-semibold">FUTA Bus Lines</span>
                        </a>
                    </div>

                    <h4 class="mb-2 text-center">Xác nhận mã & đặt lại mật khẩu</h4>
                    <p class="mb-4 text-center text-secondary">Nhập mã xác nhận vừa nhận qua email và đặt mật khẩu mới.</p>

                    <% String errorMessage = (String) request.getAttribute("errorMessage"); %>
                    <% if (errorMessage != null) { %>
                        <div class="alert alert-danger" role="alert"><%= errorMessage %></div>
                    <% } %>
                    <% String successMessage = (String) request.getAttribute("successMessage"); %>
                    <% if (successMessage != null) { %>
                        <div class="alert alert-success" role="alert"><%= successMessage %></div>
                    <% } %>

                    <form id="formResetPassword" class="mb-3" action="<%= request.getContextPath() %>/reset-password" method="post">
                        <div class="mb-3">
                            <label for="email" class="form-label">Email</label>
                            <input type="email" class="form-control" id="email" name="email"
                                   value="<%= request.getParameter("email") != null ? request.getParameter("email") : "" %>"
                                   placeholder="Nhập email" required>
                        </div>
                        <div class="mb-3">
                            <label for="otp" class="form-label">Mã xác nhận</label>
                            <input type="text" class="form-control" id="otp" name="otp" maxlength="6" minlength="6"
                                   placeholder="Nhập mã gồm 6 chữ số" required>
                        </div>
                        <div class="mb-3 form-password-toggle">
                            <label class="form-label" for="password">Mật khẩu mới</label>
                            <div class="input-group input-group-merge">
                                <input type="password" id="password" class="form-control" name="password" placeholder="••••••••" required>
                                <span class="input-group-text cursor-pointer"><i class="bx bx-hide"></i></span>
                            </div>
                        </div>
                        <div class="mb-3 form-password-toggle">
                            <label class="form-label" for="confirmPassword">Xác nhận mật khẩu</label>
                            <div class="input-group input-group-merge">
                                <input type="password" id="confirmPassword" class="form-control" name="confirmPassword" placeholder="••••••••" required>
                                <span class="input-group-text cursor-pointer"><i class="bx bx-hide"></i></span>
                            </div>
                        </div>
                        <button class="btn btn-primary d-grid w-100" type="submit">Đặt lại mật khẩu</button>
                    </form>
                    <div class="text-center">
                        <a href="<%= request.getContextPath() %>/forgot-password" class="d-flex align-items-center justify-content-center">
                            <i class="bx bx-chevron-left bx-sm"></i>
                            Quay lại nhận mã mới
                        </a>
                    </div>
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
