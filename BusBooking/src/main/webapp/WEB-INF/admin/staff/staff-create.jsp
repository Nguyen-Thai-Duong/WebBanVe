<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="assetBase" value="${contextPath}/assets/sneat-1.0.0/assets" />
<c:set var="vendorPath" value="${assetBase}/vendor" />
<c:set var="cssPath" value="${assetBase}/css" />
<c:set var="jsPath" value="${assetBase}/js" />
<c:set var="imgPath" value="${assetBase}/img" />

<c:set var="flashMessage" value="${sessionScope.staffMessage}" />
<c:set var="flashType" value="${sessionScope.staffMessageType}" />
<c:if test="${not empty flashMessage}">
    <c:remove var="staffMessage" scope="session" />
    <c:remove var="staffMessageType" scope="session" />
</c:if>

<c:set var="activeMenu" value="staff" scope="request" />
<c:set var="navbarSearchPlaceholder" value="Tìm kiếm nhân viên..." scope="request" />
<c:set var="navbarSearchAriaLabel" value="Tìm kiếm nhân viên" scope="request" />

<c:set var="statuses" value="${requestScope.staffStatuses}" />
<c:if test="${empty statuses}">
    <c:set var="statuses" value="${fn:split('Active,Inactive,Suspended,Locked', ',')}" />
</c:if>

<!DOCTYPE html>
<html lang="vi" class="light-style layout-menu-fixed" dir="ltr" data-theme="theme-default" data-assets-path="${assetBase}/" data-template="vertical-menu-template-free">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tạo nhân viên</title>
    <link rel="icon" type="image/x-icon" href="${imgPath}/favicon/favicon.ico" />
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
    <link href="https://fonts.googleapis.com/css2?family=Public+Sans:wght@300;400;500;600;700&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="${vendorPath}/fonts/boxicons.css" />
    <link rel="stylesheet" href="${vendorPath}/css/core.css" class="template-customizer-core-css" />
    <link rel="stylesheet" href="${vendorPath}/css/theme-default.css" class="template-customizer-theme-css" />
    <link rel="stylesheet" href="${cssPath}/demo.css" />
    <link rel="stylesheet" href="${vendorPath}/libs/perfect-scrollbar/perfect-scrollbar.css" />
    <script src="${vendorPath}/js/helpers.js"></script>
    <script src="${jsPath}/config.js"></script>
</head>
<body>
<div class="layout-wrapper layout-content-navbar">
    <div class="layout-container">
        <%@ include file="../includes/sidebar.jspf" %>
        <div class="layout-page">
            <%@ include file="../includes/navbar.jspf" %>
            <div class="content-wrapper">
                <div class="container-xxl flex-grow-1 container-p-y">
                    <div class="d-flex flex-wrap align-items-center justify-content-between mb-4">
                        <div>
                            <h4 class="fw-bold mb-1">Tạo nhân viên mới</h4>
                            <span class="text-muted">Nhập thông tin chi tiết cho nhân viên mới.</span>
                        </div>
                        <a class="btn btn-secondary" href="${contextPath}/admin/staff">
                            <i class="bx bx-arrow-back"></i> Quay lại danh sách
                        </a>
                    </div>

                    <c:if test="${not empty flashMessage}">
                        <div class="alert alert-${not empty flashType ? flashType : 'info'} alert-dismissible" role="alert">
                            ${flashMessage}
                            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                        </div>
                    </c:if>

                    <div class="card">
                        <div class="card-header">
                            <h5 class="card-title mb-0">Thông tin nhân viên</h5>
                        </div>
                        <div class="card-body">
                            <form action="${contextPath}/admin/staff/new" method="post" class="needs-validation" novalidate>
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
                                        <label class="form-label" for="phone">Điện thoại</label>
                                        <input type="text" class="form-control" id="phone" name="phone" required>
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label" for="status">Trạng thái</label>
                                        <select class="form-select" id="status" name="status" required>
                                            <c:forEach var="status" items="${statuses}">
                                                <option value="${status}"<c:if test="${status eq 'Active'}"> selected</c:if>>${status}</option>
                                            </c:forEach>
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
                                    <div class="col-md-6">
                                        <label class="form-label">Mã nhân viên</label>
                                        <input type="text" class="form-control" value="Sẽ được tạo tự động" disabled>
                                    </div>
                                </div>
                                <div class="d-flex justify-content-end gap-2 mt-4">
                                    <a class="btn btn-outline-secondary" href="${contextPath}/admin/staff">Hủy</a>
                                    <button type="submit" class="btn btn-primary">Tạo nhân viên</button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
<script src="${vendorPath}/libs/popper/popper.js"></script>
<script src="${vendorPath}/js/bootstrap.js"></script>
<script src="${vendorPath}/js/menu.js"></script>
<script src="${jsPath}/main.js"></script>
</body>
</html>
