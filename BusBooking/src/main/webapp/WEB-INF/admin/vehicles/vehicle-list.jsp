<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="vehicles" value="${requestScope.vehicles}" />
<c:set var="dateTimeFormatter" value="${requestScope.dateTimeFormatter}" />
<c:set var="dateFormatter" value="${requestScope.dateFormatter}" />
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="assetBase" value="${contextPath}/assets/sneat-1.0.0/assets" />
<c:set var="vendorPath" value="${assetBase}/vendor" />
<c:set var="cssPath" value="${assetBase}/css" />
<c:set var="jsPath" value="${assetBase}/js" />
<c:set var="imgPath" value="${assetBase}/img" />

<c:set var="flashMessage" value="${sessionScope.vehicleMessage}" />
<c:set var="flashType" value="${sessionScope.vehicleMessageType}" />
<c:if test="${not empty flashMessage}">
    <c:remove var="vehicleMessage" scope="session" />
    <c:remove var="vehicleMessageType" scope="session" />
</c:if>

<c:set var="activeMenu" value="vehicles" scope="request" />
<c:set var="navbarSearchPlaceholder" value="Tìm kiếm phương tiện..." scope="request" />
<c:set var="navbarSearchAriaLabel" value="Tìm kiếm phương tiện" scope="request" />
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
    <title>Quản lý phương tiện</title>

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

    <style>
        .table thead th { white-space: nowrap; }
        .vehicle-badge {
            min-width: 90px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
        }
    </style>
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
                            <h4 class="fw-bold mb-1">Danh sách phương tiện</h4>
                            <span class="text-muted">Theo dõi, tạo mới và quản lý đội xe.</span>
                        </div>
                        <a class="btn btn-primary" href="${contextPath}/admin/vehicles/new">
                            <i class="bx bx-plus"></i> Thêm phương tiện
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
                                <h5 class="card-title mb-0">Tổng quan đội xe</h5>
                                <small class="text-muted">Hiện có <strong>${fn:length(vehicles)}</strong> phương tiện.</small>
                            </div>
                        </div>
                        <div class="table-responsive">
                            <table class="table table-hover table-striped align-middle">
                                <thead>
                                <tr>
                                    <th>Mã xe</th>
                                    <th>Biển số</th>
                                    <th>Người phụ trách</th>
                                    <th>Sức chứa</th>
                                    <th>Trạng thái</th>
                                    <th>Bảo trì gần nhất</th>
                                    <th class="text-end">Thao tác</th>
                                </tr>
                                </thead>
                                <tbody>
                                <c:if test="${empty vehicles}">
                                    <tr>
                                        <td colspan="7" class="text-center text-muted py-4">Chưa có phương tiện nào.</td>
                                    </tr>
                                </c:if>
                                <c:forEach var="vehicle" items="${vehicles}">
                                    <c:set var="statusLower" value="${not empty vehicle.vehicleStatus ? fn:toLowerCase(vehicle.vehicleStatus) : ''}" />
                                    <c:set var="statusClass" value="${statusLower eq 'available' ? 'success' : (statusLower eq 'maintenance' or statusLower eq 'repair' ? 'warning' : 'secondary')}" />
                                    <tr>
                                        <td><strong>#${vehicle.vehicleId}</strong></td>
                                        <td>${vehicle.licensePlate}</td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${vehicle.operator != null}">
                                                    <div class="d-flex flex-column">
                                                        <span class="fw-semibold">${vehicle.operator.fullName != null ? vehicle.operator.fullName : 'Không rõ'}</span>
                                                        <small class="text-muted">Mã NV: ${vehicle.operator.employeeCode}</small>
                                                    </div>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="text-muted">Chưa gán</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>${vehicle.capacity}</td>
                                        <td>
                                            <span class="badge bg-label-${statusClass} vehicle-badge">${vehicle.vehicleStatus}</span>
                                        </td>
                                        <td>${vehicle.formatLastMaintenance(dateFormatter) != null ? vehicle.formatLastMaintenance(dateFormatter) : 'Chưa rõ'}</td>
                                        <td class="text-end">
                                            <button type="button" class="btn btn-sm btn-icon btn-info text-white" data-bs-toggle="modal" data-bs-target="#viewVehicleModal${vehicle.vehicleId}">
                                                <i class="bx bx-show"></i>
                                            </button>
                                            <a class="btn btn-sm btn-icon btn-primary" href="${contextPath}/admin/vehicles/edit?id=${vehicle.vehicleId}">
                                                <i class="bx bx-edit"></i>
                                            </a>
                                            <button type="button" class="btn btn-sm btn-icon btn-danger" data-bs-toggle="modal" data-bs-target="#deleteVehicleModal${vehicle.vehicleId}">
                                                <i class="bx bx-trash"></i>
                                            </button>
                                        </td>
                                    </tr>
                                </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </div>

                    <c:forEach var="vehicle" items="${vehicles}">
                    <div class="modal fade" id="viewVehicleModal${vehicle.vehicleId}" tabindex="-1" aria-hidden="true">
                        <div class="modal-dialog modal-lg modal-dialog-centered">
                            <div class="modal-content">
                                <div class="modal-header">
                                    <h5 class="modal-title">Thông tin phương tiện #${vehicle.vehicleId}</h5>
                                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                </div>
                                <div class="modal-body">
                                    <div class="row g-4">
                                        <div class="col-md-6">
                                            <small class="text-muted text-uppercase">Biển số</small>
                                            <p class="fw-semibold mb-2">${vehicle.licensePlate}</p>
                                        </div>
                                        <div class="col-md-6">
                                            <small class="text-muted text-uppercase">Mẫu xe</small>
                                            <p class="fw-semibold mb-2">${not empty vehicle.model ? vehicle.model : 'Chưa cập nhật'}</p>
                                        </div>
                                        <div class="col-md-6">
                                            <small class="text-muted text-uppercase">Người phụ trách</small>
                                            <p class="fw-semibold mb-2">
                                                <c:choose>
                                                    <c:when test="${vehicle.operator != null}">
                                                        ${vehicle.operator.fullName != null ? vehicle.operator.fullName : 'Không rõ'}
                                                        <br><small class="text-muted">Mã NV: ${vehicle.operator.employeeCode}</small>
                                                    </c:when>
                                                    <c:otherwise>
                                                        Chưa gán
                                                    </c:otherwise>
                                                </c:choose>
                                            </p>
                                        </div>
                                        <div class="col-md-6">
                                            <small class="text-muted text-uppercase">Sức chứa</small>
                                            <p class="fw-semibold mb-2">${vehicle.capacity}</p>
                                        </div>
                                        <div class="col-md-6">
                                            <small class="text-muted text-uppercase">Trạng thái</small>
                                            <p class="fw-semibold mb-2">${vehicle.vehicleStatus}</p>
                                        </div>
                                        <div class="col-md-6">
                                            <small class="text-muted text-uppercase">Tình trạng</small>
                                            <p class="fw-semibold mb-2">${not empty vehicle.currentCondition ? vehicle.currentCondition : 'Chưa cập nhật'}</p>
                                        </div>
                                        <div class="col-md-6">
                                            <small class="text-muted text-uppercase">Ngày thêm</small>
                                            <p class="text-secondary mb-2">${vehicle.formatDateAdded(dateTimeFormatter) != null ? vehicle.formatDateAdded(dateTimeFormatter) : 'Chưa rõ'}</p>
                                        </div>
                                        <div class="col-md-6">
                                            <small class="text-muted text-uppercase">Chu kỳ bảo trì (ngày)</small>
                                            <p class="text-secondary mb-2">${vehicle.maintenanceIntervalDays != null ? vehicle.maintenanceIntervalDays : 'Chưa đặt'}</p>
                                        </div>
                                        <div class="col-md-6">
                                            <small class="text-muted text-uppercase">Bảo trì gần nhất</small>
                                            <p class="text-secondary mb-2">${vehicle.formatLastMaintenance(dateFormatter) != null ? vehicle.formatLastMaintenance(dateFormatter) : 'Chưa rõ'}</p>
                                        </div>
                                        <div class="col-md-6">
                                            <small class="text-muted text-uppercase">Sửa chữa gần nhất</small>
                                            <p class="text-secondary mb-2">${vehicle.formatLastRepair(dateFormatter) != null ? vehicle.formatLastRepair(dateFormatter) : 'Chưa rõ'}</p>
                                        </div>
                                        <div class="col-12">
                                            <small class="text-muted text-uppercase">Ghi chú</small>
                                            <p class="mb-0">${not empty vehicle.details ? vehicle.details : 'Chưa có ghi chú'}</p>
                                        </div>
                                    </div>
                                </div>
                                <div class="modal-footer">
                                    <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Đóng</button>
                                    <a class="btn btn-primary" href="${contextPath}/admin/vehicles/edit?id=${vehicle.vehicleId}">
                                        <i class="bx bx-edit me-1"></i> Chỉnh sửa
                                    </a>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="modal fade" id="deleteVehicleModal${vehicle.vehicleId}" tabindex="-1" aria-hidden="true">
                        <div class="modal-dialog modal-dialog-centered">
                            <div class="modal-content">
                                <form action="${contextPath}/admin/vehicles" method="post">
                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="vehicleId" value="${vehicle.vehicleId}">
                                    <div class="modal-header">
                                        <h5 class="modal-title">Xóa phương tiện</h5>
                                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                    </div>
                                    <div class="modal-body">
                                        Bạn có chắc chắn muốn xóa phương tiện <strong>${vehicle.licensePlate}</strong>?<br>
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
