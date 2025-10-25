<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi" class="light-style customizer-hide" dir="ltr" data-theme="theme-default"
      data-assets-path="<%= request.getContextPath() %>/assets/sneat-1.0.0/assets/"
      data-template="vertical-menu-template-free">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no, minimum-scale=1.0, maximum-scale=1.0">
    <title>Quên mật khẩu | FUTA Bus Lines</title>

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

                    <h4 class="mb-2 text-center">Quên mật khẩu?</h4>
                    <p class="mb-4 text-center text-secondary">Nhập email đã đăng ký để nhận mã xác nhận đặt lại mật khẩu.</p>

                    <% String errorMessage = (String) request.getAttribute("errorMessage"); %>
                    <% if (errorMessage != null) { %>
                        <div class="alert alert-danger" role="alert"><%= errorMessage %></div>
                    <% } %>

                    <form id="formAuthentication" class="mb-3" action="<%= request.getContextPath() %>/forgot-password" method="post">
                        <div class="mb-3">
                            <label for="email" class="form-label">Email</label>
                            <input type="email" class="form-control" id="email" name="email"
                                   value="<%= request.getAttribute("prefillEmail") != null ? request.getAttribute("prefillEmail") : "" %>"
                                   placeholder="Nhập email của bạn" required autofocus>
                        </div>
                        <button class="btn btn-primary d-grid w-100" type="submit">Gửi mã xác nhận</button>
                    </form>
                    <div class="text-center">
                        <a href="<%= request.getContextPath() %>/login" class="d-flex align-items-center justify-content-center">
                            <i class="bx bx-chevron-left bx-sm"></i>
                            Quay lại đăng nhập
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
