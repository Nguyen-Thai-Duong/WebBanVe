<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String contextPath = request.getContextPath();
    String assetBase = contextPath + "/assets/sneat-1.0.0/assets";
    String vendorPath = assetBase + "/vendor";
    String cssPath = assetBase + "/css";
    String jsPath = assetBase + "/js";
    String imgPath = assetBase + "/img";
    request.setAttribute("activeMenu", "account-settings");
    request.setAttribute("navbarSearchPlaceholder", "Tìm kiếm...");
    request.setAttribute("navbarHideSearch", Boolean.TRUE);
%>
<!DOCTYPE html>
<html lang="vi" class="light-style layout-menu-fixed" dir="ltr" data-theme="theme-default"
      data-assets-path="<%= assetBase %>/" data-template="vertical-menu-template-free">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cài đặt tài khoản</title>

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
                    <h4 class="fw-bold py-3 mb-4"><span class="text-muted fw-light">Cài đặt tài khoản /</span> Thông tin</h4>

                    <div class="row">
                        <div class="col-md-12">
                            <ul class="nav nav-pills flex-column flex-md-row mb-3">
                                <li class="nav-item">
                                    <a class="nav-link active" href="javascript:void(0);"><i class="bx bx-user me-1"></i> Tài khoản</a>
                                </li>
<!--                                <li class="nav-item">
                                    <a class="nav-link" href="javascript:void(0);"><i class="bx bx-bell me-1"></i> Thông báo</a>
                                </li>-->
<!--                                <li class="nav-item">
                                    <a class="nav-link" href="javascript:void(0);"><i class="bx bx-link-alt me-1"></i> Kết nối</a>
                                </li>-->
                            </ul>
                            <div class="card mb-4">
                                <h5 class="card-header">Chi tiết hồ sơ</h5>
                                <div class="card-body">
                                    <div class="d-flex align-items-start align-items-sm-center gap-4">
                                        <img src="<%= imgPath %>/avatars/1.png" alt="user-avatar"
                                             class="d-block rounded" height="100" width="100" id="uploadedAvatar" />
                                        <div class="button-wrapper">
                                            <label for="upload" class="btn btn-primary me-2 mb-4" tabindex="0">
                                                <span class="d-none d-sm-block">Tải ảnh mới</span>
                                                <i class="bx bx-upload d-block d-sm-none"></i>
                                                <input type="file" id="upload" class="account-file-input" hidden accept="image/png, image/jpeg" />
                                            </label>
                                            <button type="button" class="btn btn-outline-secondary account-image-reset mb-4">
                                                <i class="bx bx-reset d-block d-sm-none"></i>
                                                <span class="d-none d-sm-block">Đặt lại</span>
                                            </button>
                                            <p class="text-muted mb-0">Cho phép định dạng JPG, GIF hoặc PNG. Tối đa 800KB.</p>
                                        </div>
                                    </div>
                                </div>
                                <hr class="my-0" />
                                <div class="card-body">
                                    <form id="formAccountSettings" method="post" action="javascript:void(0);">
                                        <div class="row">
                                            <div class="mb-3 col-md-6">
                                                <label for="firstName" class="form-label">Họ</label>
                                                <input class="form-control" type="text" id="firstName" name="firstName" value="Nguyễn" />
                                            </div>
                                            <div class="mb-3 col-md-6">
                                                <label for="lastName" class="form-label">Tên</label>
                                                <input class="form-control" type="text" id="lastName" name="lastName" value="Anh" />
                                            </div>
                                            <div class="mb-3 col-md-6">
                                                <label for="email" class="form-label">Email</label>
                                                <input class="form-control" type="email" id="email" name="email" value="admin@example.com" />
                                            </div>
                                            <div class="mb-3 col-md-6">
                                                <label for="organization" class="form-label">Tổ chức</label>
                                                <input type="text" class="form-control" id="organization" name="organization" value="FUTA Bus" />
                                            </div>
                                            <div class="mb-3 col-md-6">
                                                <label class="form-label" for="phoneNumber">Điện thoại</label>
                                                <div class="input-group input-group-merge">
                                                    <span class="input-group-text">VN (+84)</span>
                                                    <input type="text" id="phoneNumber" name="phoneNumber" class="form-control" placeholder="0900 000 000" />
                                                </div>
                                            </div>
                                            <div class="mb-3 col-md-6">
                                                <label for="address" class="form-label">Địa chỉ</label>
                                                <input type="text" class="form-control" id="address" name="address" placeholder="123 Lê Lợi, Q1" />
                                            </div>
                                            <div class="mb-3 col-md-6">
                                                <label for="state" class="form-label">Tỉnh/Thành phố</label>
                                                <input class="form-control" type="text" id="state" name="state" placeholder="TP. Hồ Chí Minh" />
                                            </div>
                                            <div class="mb-3 col-md-6">
                                                <label for="zipCode" class="form-label">Mã bưu chính</label>
                                                <input type="text" class="form-control" id="zipCode" name="zipCode" placeholder="700000" maxlength="6" />
                                            </div>
                                            <div class="mb-3 col-md-6">
                                                <label class="form-label" for="country">Quốc gia</label>
                                                <select id="country" class="form-select">
                                                    <option value="">Chọn quốc gia</option>
                                                    <option value="Vietnam" selected>Việt Nam</option>
                                                    <option value="Singapore">Singapore</option>
                                                    <option value="Thailand">Thái Lan</option>
                                                    <option value="Malaysia">Malaysia</option>
                                                    <option value="Philippines">Philippines</option>
                                                </select>
                                            </div>
                                            <div class="mb-3 col-md-6">
                                                <label for="language" class="form-label">Ngôn ngữ</label>
                                                <select id="language" class="form-select">
                                                    <option value="">Chọn ngôn ngữ</option>
                                                    <option value="vi" selected>Tiếng Việt</option>
                                                    <option value="en">English</option>
                                                    <option value="fr">Français</option>
                                                </select>
                                            </div>
                                            <div class="mb-3 col-md-6">
                                                <label for="timeZones" class="form-label">Múi giờ</label>
                                                <select id="timeZones" class="form-select">
                                                    <option value="">Chọn múi giờ</option>
                                                    <option value="UTC+7" selected>(GMT+7) Asia/Ho_Chi_Minh</option>
                                                    <option value="UTC+8">(GMT+8) Asia/Singapore</option>
                                                    <option value="UTC+9">(GMT+9) Asia/Tokyo</option>
                                                </select>
                                            </div>
                                            <div class="mb-3 col-md-6">
                                                <label for="currency" class="form-label">Tiền tệ</label>
                                                <select id="currency" class="form-select">
                                                    <option value="">Chọn đơn vị</option>
                                                    <option value="VND" selected>VND</option>
                                                    <option value="USD">USD</option>
                                                    <option value="EUR">EUR</option>
                                                </select>
                                            </div>
                                        </div>
                                        <div class="mt-2">
                                            <button type="submit" class="btn btn-primary me-2">Lưu thay đổi</button>
                                            <button type="reset" class="btn btn-outline-secondary">Hủy</button>
                                        </div>
                                    </form>
                                </div>
                            </div>

                            <div class="card">
                                <h5 class="card-header">Xóa tài khoản</h5>
                                <div class="card-body">
                                    <div class="mb-3 col-12 mb-0">
                                        <div class="alert alert-warning">
                                            <h6 class="alert-heading fw-bold mb-1">Bạn có chắc chắn muốn xóa tài khoản?</h6>
                                            <p class="mb-0">Thao tác này không thể hoàn tác. Hãy cân nhắc kỹ trước khi thực hiện.</p>
                                        </div>
                                    </div>
                                    <form id="formAccountDeactivation" action="javascript:void(0);">
                                        <div class="form-check mb-3">
                                            <input class="form-check-input" type="checkbox" id="accountActivation" />
                                            <label class="form-check-label" for="accountActivation">Tôi xác nhận vô hiệu hóa tài khoản</label>
                                        </div>
                                        <button type="submit" class="btn btn-danger deactivate-account">Vô hiệu hóa tài khoản</button>
                                    </form>
                                </div>
                            </div>
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
<script src="<%= jsPath %>/pages-account-settings-account.js"></script>
</body>
</html>
