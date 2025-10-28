<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="app" tagdir="/WEB-INF/tags" %>

<c:set var="trips" value="${requestScope.trips}" />
<c:set var="tableFormatter" value="${requestScope.tableFormatter}" />
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="assetBase" value="${contextPath}/assets/sneat-1.0.0/assets" />
<c:set var="vendorPath" value="${assetBase}/vendor" />
<c:set var="cssPath" value="${assetBase}/css" />
<c:set var="jsPath" value="${assetBase}/js" />
<c:set var="imgPath" value="${assetBase}/img" />

<c:set var="flashMessage" value="${sessionScope.tripMessage}" />
<c:set var="flashType" value="${sessionScope.tripMessageType}" />
<c:if test="${not empty flashMessage}">
    <c:remove var="tripMessage" scope="session" />
    <c:remove var="tripMessageType" scope="session" />
</c:if>

<c:set var="activeMenu" value="trips" scope="request" />
<c:set var="navbarSearchPlaceholder" value="Tìm kiếm chuyến đi..." scope="request" />
<c:set var="navbarSearchAriaLabel" value="Tìm kiếm chuyến đi" scope="request" />
<!DOCTYPE html>
<html
    lang="vi"
    class="light-style layout-menu-fixed"
    dir="ltr"
    data-theme="theme-default"
    data-assets-path="${assetBase}/"
    data-template="vertical-menu-template-free"
>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý chuyến đi</title>

    <link rel="icon" type="image/x-icon" href="${imgPath}/favicon/favicon.ico" />

    <!-- Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
    <link href="https://fonts.googleapis.com/css2?family=Public+Sans:wght@300;400;500;600;700&display=swap" rel="stylesheet" />

    <!-- Icons -->
    <link rel="stylesheet" href="${vendorPath}/fonts/boxicons.css" />

    <!-- Core CSS -->
    <link rel="stylesheet" href="${vendorPath}/css/core.css" class="template-customizer-core-css" />
    <link rel="stylesheet" href="${vendorPath}/css/theme-default.css" class="template-customizer-theme-css" />
    <link rel="stylesheet" href="${cssPath}/demo.css" />

    <!-- Vendors CSS -->
    <link rel="stylesheet" href="${vendorPath}/libs/perfect-scrollbar/perfect-scrollbar.css" />

    <!-- Helpers -->
    <script src="${vendorPath}/js/helpers.js"></script>
    <script src="${jsPath}/config.js"></script>

    <style>
        .table thead th { white-space: nowrap; }
        .modal-body .form-label { font-weight: 600; }
    </style>
</head>
<body>
<div class="layout-wrapper layout-content-navbar">
    <div class="layout-container">
        <%@ include file="../includes/sidebar.jspf" %>

        <!-- Layout container -->
        <div class="layout-page">
            <!-- Navbar -->
            <%@ include file="../includes/navbar.jspf" %>
            <!-- / Navbar -->

            <!-- Content wrapper -->
            <div class="content-wrapper">
                <div class="container-xxl flex-grow-1 container-p-y">
                    <div class="d-flex flex-wrap align-items-center justify-content-between mb-4">
                        <div>
                            <h4 class="fw-bold mb-1">Quản lý chuyến đi</h4>
                            <span class="text-muted">Thêm, sửa, xóa và theo dõi trạng thái chuyến đi.</span>
                        </div>
                        <a class="btn btn-primary" href="${contextPath}/admin/trips/new">
                            <i class="bx bx-plus"></i> Thêm chuyến đi
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
                                <h5 class="card-title mb-0">Danh sách chuyến đi</h5>
                                <small class="text-muted">Tổng cộng <strong>${fn:length(trips)}</strong> chuyến.</small>
                            </div>
                        </div>
                        <div class="table-responsive">
                            <table class="table table-hover table-striped mb-0">
                                <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>Tuyến</th>
                                    <th>Giờ khởi hành</th>
                                    <th>Giờ đến</th>
                                    <th>Giá vé</th>
                                    <th>Xe</th>
                                    <th>Nhà xe</th>
                                    <th>Trạng thái</th>
                                    <th class="text-end">Thao tác</th>
                                </tr>
                                </thead>
                                <tbody>
                                <c:if test="${fn:length(trips) == 0}">
                                    <tr>
                                        <td colspan="9" class="text-center text-muted py-4">Chưa có chuyến đi nào.</td>
                                    </tr>
                                </c:if>
                                <c:forEach var="trip" items="${trips}">
                                    <c:set var="viewId" value="viewTripModal${trip.tripId}" />
                                    <c:set var="deleteId" value="deleteTripModal${trip.tripId}" />
                                    <tr>
                                        <td><strong>#${trip.tripId}</strong></td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${trip.route != null}">
                                                    <span class="fw-semibold">${trip.route.origin} → ${trip.route.destination}</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="text-muted">N/A</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>${trip.formatDeparture(tableFormatter) != null ? trip.formatDeparture(tableFormatter) : 'N/A'}</td>
                                        <td>${trip.formatArrival(tableFormatter) != null ? trip.formatArrival(tableFormatter) : 'N/A'}</td>
                                        <td><app:currency value="${trip.price}" /></td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${trip.vehicle != null}">
                                                    <span class="badge bg-label-primary">${trip.vehicle.licensePlate}</span>
                                                    <small class="text-muted d-block">${trip.vehicle.model != null ? trip.vehicle.model : ''}</small>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="text-muted">N/A</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${trip.operator != null}">
                                                    <span class="fw-semibold">${trip.operator.fullName}</span>
                                                    <small class="text-muted d-block">${trip.operator.email != null ? trip.operator.email : ''}</small>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="text-muted">N/A</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <span class="badge bg-label-info">${trip.tripStatus}</span>
                                        </td>
                                        <td class="text-end">
                                            <button type="button" class="btn btn-sm btn-icon btn-info text-white" data-bs-toggle="modal" data-bs-target="#${viewId}">
                                                <i class="bx bx-show"></i>
                                            </button>
                                            <a class="btn btn-sm btn-icon btn-primary" href="${contextPath}/admin/trips/edit?tripId=${trip.tripId}">
                                                <i class="bx bx-edit"></i>
                                            </a>
                                            <button type="button" class="btn btn-sm btn-icon btn-danger" data-bs-toggle="modal" data-bs-target="#${deleteId}">
                                                <i class="bx bx-trash"></i>
                                            </button>
                                        </td>
                                    </tr>
                                </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </div>
                    <c:forEach var="trip" items="${trips}">
                    <c:set var="viewId" value="viewTripModal${trip.tripId}" />
                    <c:set var="deleteId" value="deleteTripModal${trip.tripId}" />
                    <c:set var="totalDurationMinutes" value="${trip.durationMinutesTotal}" />
                    <c:set var="durationHours" value="${trip.durationHoursPart}" />
                    <c:set var="durationMinutes" value="${trip.durationMinutesPart}" />
                    <div class="modal fade" id="${viewId}" tabindex="-1" aria-hidden="true">
                        <div class="modal-dialog modal-lg modal-dialog-centered">
                            <div class="modal-content">
                                <div class="modal-header">
                                    <h5 class="modal-title">Chi tiết chuyến đi #${trip.tripId}</h5>
                                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                </div>
                                <div class="modal-body">
                                    <div class="row g-4">
                                        <div class="col-md-6">
                                            <small class="text-muted text-uppercase">Tuyến đường</small>
                                            <p class="mb-1 fw-semibold">
                                                <c:choose>
                                                    <c:when test="${trip.route != null}">
                                                        ${trip.route.origin} &rarr; ${trip.route.destination}
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="text-muted">Chưa cập nhật</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </p>
                                            <c:if test="${trip.route != null && trip.route.distance != null}">
                                                <small class="text-secondary">Khoảng cách: ${trip.route.distance} km</small>
                                            </c:if>
                                        </div>
                                        <div class="col-md-3">
                                            <small class="text-muted text-uppercase d-block">Giờ khởi hành</small>
                                            <span class="fw-semibold">
                                                ${trip.formatDeparture(tableFormatter) != null ? trip.formatDeparture(tableFormatter) : 'Chưa cập nhật'}
                                            </span>
                                        </div>
                                        <div class="col-md-3">
                                            <small class="text-muted text-uppercase d-block">Giờ đến</small>
                                            <span class="fw-semibold">
                                                ${trip.formatArrival(tableFormatter) != null ? trip.formatArrival(tableFormatter) : 'Chưa cập nhật'}
                                            </span>
                                        </div>
                                        <div class="col-md-3">
                                            <small class="text-muted text-uppercase d-block">Thời lượng</small>
                                            <span class="fw-semibold">
                                                <c:choose>
                                                    <c:when test="${totalDurationMinutes >= 0}">
                                                        ${durationHours} giờ ${durationMinutes} phút
                                                    </c:when>
                                                    <c:otherwise>Chưa cập nhật</c:otherwise>
                                                </c:choose>
                                            </span>
                                        </div>
                                        <div class="col-md-3">
                                            <small class="text-muted text-uppercase d-block">Giá vé</small>
                                            <span class="fw-semibold text-warning"><app:currency value="${trip.price}" /></span>
                                        </div>
                                        <div class="col-md-3">
                                            <small class="text-muted text-uppercase d-block">Trạng thái</small>
                                            <span class="badge bg-label-primary">${trip.tripStatus}</span>
                                        </div>
                                        <div class="col-md-6">
                                            <div class="border rounded-3 p-3 h-100">
                                                <small class="text-muted text-uppercase d-block mb-2">Phương tiện</small>
                                                <c:choose>
                                                    <c:when test="${trip.vehicle != null}">
                                                        <p class="mb-1 fw-semibold">Biển số: ${trip.vehicle.licensePlate}</p>
                                                        <c:if test="${trip.vehicle.model != null}">
                                                            <p class="mb-1 text-secondary">Dòng xe: ${trip.vehicle.model}</p>
                                                        </c:if>
                                                        <p class="mb-1 text-secondary">Số ghế: ${trip.vehicle.capacity != null ? trip.vehicle.capacity : 'Chưa rõ'}</p>
                                                        <c:if test="${trip.vehicle.vehicleStatus != null}">
                                                            <span class="badge bg-label-success">${trip.vehicle.vehicleStatus}</span>
                                                        </c:if>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="text-muted">Chưa cập nhật</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                        </div>
                                        <div class="col-md-6">
                                            <div class="border rounded-3 p-3 h-100">
                                                <small class="text-muted text-uppercase d-block mb-2">Nhà xe / Điều hành</small>
                                                <c:choose>
                                                    <c:when test="${trip.operator != null}">
                                                        <p class="mb-1 fw-semibold">${trip.operator.fullName}</p>
                                                        <c:if test="${trip.operator.employeeCode != null}">
                                                            <p class="mb-1 text-secondary">Mã nhân viên: ${trip.operator.employeeCode}</p>
                                                        </c:if>
                                                        <p class="mb-1 text-secondary">Email: ${trip.operator.email}</p>
                                                        <p class="mb-0 text-secondary">Điện thoại: ${trip.operator.phoneNumber}</p>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="text-muted">Chưa cập nhật</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="modal-footer">
                                    <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Đóng</button>
                                    <a class="btn btn-primary" href="${contextPath}/admin/trips/edit?tripId=${trip.tripId}">
                                        <i class="bx bx-edit me-1"></i> Chỉnh sửa chuyến đi
                                    </a>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="modal fade" id="${deleteId}" tabindex="-1" aria-hidden="true">
                        <div class="modal-dialog modal-dialog-centered">
                            <div class="modal-content">
                                <form action="${contextPath}/admin/trips" method="post">
                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="tripId" value="${trip.tripId}">
                                    <div class="modal-header">
                                        <h5 class="modal-title">Xóa chuyến đi</h5>
                                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                    </div>
                                    <div class="modal-body">
                                        Bạn có chắc chắn muốn xóa chuyến đi <strong>#${trip.tripId}</strong>?<br>
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

<!-- Sneat scripts -->
<script src="${vendorPath}/js/helpers.js"></script>
<script src="${jsPath}/config.js"></script>
<script src="${vendorPath}/libs/popper/popper.js"></script>
<script src="${vendorPath}/js/bootstrap.js"></script>
<script src="${vendorPath}/js/menu.js"></script>
<script src="${jsPath}/main.js"></script>
</body>
</html>