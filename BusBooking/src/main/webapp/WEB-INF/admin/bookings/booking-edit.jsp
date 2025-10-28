<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="assetBase" value="${contextPath}/assets/sneat-1.0.0/assets" />
<c:set var="vendorPath" value="${assetBase}/vendor" />
<c:set var="cssPath" value="${assetBase}/css" />
<c:set var="jsPath" value="${assetBase}/js" />
<c:set var="imgPath" value="${assetBase}/img" />

<c:set var="booking" value="${requestScope.booking}" />
<c:set var="flashMessage" value="${sessionScope.bookingMessage}" />
<c:set var="flashType" value="${sessionScope.bookingMessageType}" />
<c:if test="${not empty flashMessage}">
    <c:remove var="bookingMessage" scope="session" />
    <c:remove var="bookingMessageType" scope="session" />
</c:if>

<c:set var="activeMenu" value="bookings" scope="request" />
<c:set var="navbarSearchPlaceholder" value="Tìm kiếm đơn đặt chỗ..." scope="request" />
<c:set var="navbarSearchAriaLabel" value="Tìm kiếm đơn đặt chỗ" scope="request" />
<c:set var="formAction" value="${contextPath}/admin/bookings/edit" scope="request" />
<c:set var="submitLabel" value="Cập nhật" scope="request" />
<c:set var="cancelHref" value="${contextPath}/admin/bookings" scope="request" />

<!DOCTYPE html>
<html lang="vi" class="light-style layout-menu-fixed" dir="ltr" data-theme="theme-default" data-assets-path="${assetBase}/" data-template="vertical-menu-template-free">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cập nhật đơn đặt chỗ</title>
    <link rel="icon" type="image/x-icon" href="${imgPath}/favicon/favicon.ico" />
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap&subset=latin-ext,vietnamese" rel="stylesheet" />
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
                            <h4 class="fw-bold mb-1">Cập nhật đơn đặt chỗ #${booking.bookingId}</h4>
                            <span class="text-muted">Điều chỉnh thông tin giữ chỗ và trạng thái xử lý.</span>
                        </div>
                        <a class="btn btn-secondary" href="${contextPath}/admin/bookings">
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
                            <h5 class="card-title mb-0">Thông tin đơn đặt chỗ</h5>
                        </div>
                        <div class="card-body">
                            <%@ include file="booking-form.jspf" %>
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
