<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="routes" value="${requestScope.routes}" />
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="assetBase" value="${contextPath}/assets/sneat-1.0.0/assets" />
<c:set var="vendorPath" value="${assetBase}/vendor" />
<c:set var="cssPath" value="${assetBase}/css" />
<c:set var="jsPath" value="${assetBase}/js" />
<c:set var="imgPath" value="${assetBase}/img" />

<c:set var="flashMessage" value="${sessionScope.routeMessage}" />
<c:set var="flashType" value="${sessionScope.routeMessageType}" />
<c:if test="${not empty flashMessage}">
    <c:remove var="routeMessage" scope="session" />
    <c:remove var="routeMessageType" scope="session" />
</c:if>

<c:set var="activeMenu" value="routes" scope="request" />
<c:set var="navbarSearchPlaceholder" value="Tìm kiếm tuyến đường..." scope="request" />
<c:set var="navbarSearchAriaLabel" value="Tìm kiếm tuyến đường" scope="request" />
<c:set var="maxTripsPerRoute" value="${requestScope.maxTripsPerRoute}" />
<c:if test="${empty maxTripsPerRoute}">
    <c:set var="maxTripsPerRoute" value="5" />
</c:if>

<!DOCTYPE html>
<html lang="vi" class="light-style layout-menu-fixed" dir="ltr" data-theme="theme-default" data-assets-path="${assetBase}/" data-template="vertical-menu-template-free">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý tuyến đường</title>
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
                            <h4 class="fw-bold mb-1">Danh sách tuyến đường</h4>
                            <span class="text-muted">Quản lý điểm đi, điểm đến và khoảng cách.</span>
                        </div>
                        <a class="btn btn-primary" href="${contextPath}/admin/routes/new">
                            <i class="bx bx-plus"></i> Thêm tuyến đường
                        </a>
                    </div>

                    <c:if test="${not empty flashMessage}">
                        <div class="alert alert-${not empty flashType ? flashType : 'info'} alert-dismissible" role="alert">
                            ${flashMessage}
                            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                        </div>
                    </c:if>

                    <div class="card">
                        <div class="card-header d-flex justify-content-between align-items-center flex-wrap gap-2">
                            <div>
                                <h5 class="card-title mb-0">Tổng quan tuyến đường</h5>
                                <small class="text-muted">Có <strong>${fn:length(routes)}</strong> tuyến đường đã cấu hình. Mỗi tuyến tối đa ${maxTripsPerRoute} chuyến.</small>
                            </div>
                        </div>
                        <div class="table-responsive">
                            <table class="table table-hover table-striped align-middle">
                                <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>Tuyến</th>
                                    <th>Khoảng cách (km)</th>
                                    <th>Thời gian (phút)</th>
                                    <th>Số chuyến</th>
                                    <th>Trạng thái</th>
                                    <th class="text-end">Thao tác</th>
                                </tr>
                                </thead>
                                <tbody>
                                <c:if test="${empty routes}">
                                    <tr>
                                        <td colspan="7" class="text-center text-muted py-4">Chưa có tuyến đường nào.</td>
                                    </tr>
                                </c:if>
                                <c:forEach var="route" items="${routes}">
                                    <c:set var="tripCount" value="${route.tripCount}" />
                                    <c:if test="${empty tripCount}">
                                        <c:set var="tripCount" value="0" />
                                    </c:if>
                                    <c:set var="routeFull" value="${tripCount >= maxTripsPerRoute}" />
                                    <tr>
                                        <td><strong>#${route.routeId}</strong></td>
                                        <td>
                                            <div class="fw-semibold">${route.origin} -> ${route.destination}</div>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${not empty route.distance}">
                                                    ${route.distance}
                                                </c:when>
                                                <c:otherwise>
                                                    Chưa cập nhật
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${route.durationMinutes != null}">
                                                    ${route.durationMinutes}
                                                </c:when>
                                                <c:otherwise>
                                                    Chưa cập nhật
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <span class="badge bg-label-${routeFull ? 'danger' : 'info'}">${tripCount}/${maxTripsPerRoute}</span>
                                        </td>
                                        <td>
                                            <c:set var="routeActive" value="${route.routeStatus eq 'Active'}" />
                                            <span class="badge bg-label-${routeActive ? 'success' : 'secondary'}">
                                                <c:choose>
                                                    <c:when test="${routeActive}">Đang hoạt động</c:when>
                                                    <c:otherwise>Tạm ngưng</c:otherwise>
                                                </c:choose>
                                            </span>
                                        </td>
                                        <td class="text-end">
                                            <a class="btn btn-sm btn-icon btn-primary" href="${contextPath}/admin/routes/edit?routeId=${route.routeId}">
                                                <i class="bx bx-edit"></i>
                                            </a>
                                            <button type="button" class="btn btn-sm btn-icon btn-danger" data-bs-toggle="modal" data-bs-target="#deleteRouteModal${route.routeId}">
                                                <i class="bx bx-trash"></i>
                                            </button>
                                        </td>
                                    </tr>
                                </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </div>

                    <c:forEach var="route" items="${routes}">
                        <div class="modal fade" id="deleteRouteModal${route.routeId}" tabindex="-1" aria-hidden="true">
                            <div class="modal-dialog modal-dialog-centered">
                                <div class="modal-content">
                                    <form action="${contextPath}/admin/routes" method="post">
                                        <input type="hidden" name="action" value="delete">
                                        <input type="hidden" name="routeId" value="${route.routeId}">
                                        <div class="modal-header">
                                            <h5 class="modal-title">Xóa tuyến đường</h5>
                                            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                        </div>
                                        <div class="modal-body">
                                            Bạn có chắc chắn muốn xóa tuyến <strong>${route.origin} -> ${route.destination}</strong>?<br>
                                            Thao tác này không thể hoàn tác.
                                        </div>
                                        <div class="modal-footer">
                                            <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Hủy</button>
                                            <button type="submit" class="btn btn-danger">Xóa</button>
                                        </div>
                                    </form>
                                </div>
                            </div>
                        </div>
                    </c:forEach>

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
