<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

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

<c:set var="statuses" value="${requestScope.vehicleStatuses}" />
<c:if test="${empty statuses}">
    <c:set var="statuses" value="${fn:split('Available,In Service,Maintenance,Repair,Retired', ',')}" />
</c:if>

<c:set var="vehicle" value="${requestScope.vehicle}" />
<c:set var="busOperators" value="${requestScope.busOperators}" />
<c:set var="dateTimeFormatter" value="${requestScope.dateTimeFormatter}" />
<c:set var="currentOperatorCode" value="${vehicle != null && vehicle.operator != null ? vehicle.operator.employeeCode : ''}" />
<c:set var="currentStatus" value="${vehicle != null && not empty vehicle.vehicleStatus ? vehicle.vehicleStatus : 'Available'}" />

<!DOCTYPE html>
<html lang="vi" class="light-style layout-menu-fixed" dir="ltr" data-theme="theme-default" data-assets-path="${assetBase}/" data-template="vertical-menu-template-free">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chỉnh sửa phương tiện</title>
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
                            <h4 class="fw-bold mb-1">Chỉnh sửa phương tiện</h4>
                            <c:choose>
                                <c:when test="${vehicle != null}">
                                    <span class="text-muted">Cập nhật thông tin cho phương tiện #${vehicle.vehicleId}.</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="text-muted">Không tìm thấy phương tiện.</span>
                                </c:otherwise>
                            </c:choose>
                        </div>
                        <a class="btn btn-secondary" href="${contextPath}/admin/vehicles">
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
                        <div class="card-header d-flex justify-content-between align-items-center flex-wrap gap-2">
                            <h5 class="card-title mb-0">Thông tin phương tiện</h5>
                            <c:if test="${vehicle != null}">
                                <c:set var="createdAtFormatted" value="${vehicle.formatDateAdded(dateTimeFormatter)}" />
                                <c:if test="${not empty createdAtFormatted}">
                                    <small class="text-muted">Ngày thêm: ${createdAtFormatted}</small>
                                </c:if>
                            </c:if>
                        </div>
                        <div class="card-body">
                            <c:choose>
                                <c:when test="${vehicle == null}">
                                    <div class="alert alert-warning mb-0" role="alert">
                                        Không thể tải dữ liệu phương tiện. Vui lòng quay lại danh sách.
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <form action="${contextPath}/admin/vehicles/edit" method="post" class="needs-validation" novalidate>
                                        <input type="hidden" name="vehicleId" value="${vehicle.vehicleId}">
                                        <div class="row g-3">
                                            <div class="col-md-6">
                                                <label class="form-label" for="licensePlate">Biển số</label>
                                                <input type="text" class="form-control" id="licensePlate" name="licensePlate" value="${vehicle.licensePlate}" required>
                                            </div>
                                            <div class="col-md-6">
                                                <label class="form-label" for="model">Mẫu xe</label>
                                                <input type="text" class="form-control" id="model" name="model" value="${vehicle.model != null ? vehicle.model : ''}">
                                            </div>
                                            <div class="col-md-4">
                                                <label class="form-label" for="capacity">Sức chứa</label>
                                                <input type="number" min="1" class="form-control" id="capacity" name="capacity" value="${vehicle.capacity}" required>
                                            </div>
                                            <div class="col-md-4">
                                                <label class="form-label" for="maintenanceIntervalDays">Chu kỳ bảo trì (ngày)</label>
                                                <input type="number" min="1" class="form-control" id="maintenanceIntervalDays" name="maintenanceIntervalDays" value="${vehicle.maintenanceIntervalDays != null ? vehicle.maintenanceIntervalDays : ''}">
                                            </div>
                                            <div class="col-md-4">
                                                <label class="form-label" for="vehicleStatus">Trạng thái</label>
                                                <select class="form-select" id="vehicleStatus" name="vehicleStatus" required>
                                                    <c:forEach var="status" items="${statuses}">
                                                        <option value="${status}"<c:if test="${status eq currentStatus}"> selected</c:if>>${status}</option>
                                                    </c:forEach>
                                                </select>
                                            </div>
                                            <div class="col-md-6">
                                                <label class="form-label" for="operatorCode">Người phụ trách (Bus Operator)</label>
                                                <select class="form-select" id="operatorCode" name="operatorCode" required>
                                                    <option value="" disabled<c:if test="${empty currentOperatorCode}"> selected</c:if>>-- Chọn bus operator phụ trách --</option>
                                                    <c:forEach var="operator" items="${busOperators}">
                                                        <option value="${operator.employeeCode}"<c:if test="${operator.employeeCode eq currentOperatorCode}"> selected</c:if>>${operator.fullName} (${operator.employeeCode})</option>
                                                    </c:forEach>
                                                </select>
                                            </div>
                                            <div class="col-md-6">
                                                <label class="form-label" for="currentCondition">Tình trạng hiện tại</label>
                                                <input type="text" class="form-control" id="currentCondition" name="currentCondition" value="${vehicle.currentCondition != null ? vehicle.currentCondition : ''}">
                                            </div>
                                            <div class="col-md-6">
                                                <label class="form-label" for="lastMaintenanceDate">Bảo trì gần nhất</label>
                                                <input type="date" class="form-control" id="lastMaintenanceDate" name="lastMaintenanceDate" value="${vehicle.lastMaintenanceDate != null ? vehicle.lastMaintenanceDate : ''}">
                                            </div>
                                            <div class="col-md-6">
                                                <label class="form-label" for="lastRepairDate">Sửa chữa gần nhất</label>
                                                <input type="date" class="form-control" id="lastRepairDate" name="lastRepairDate" value="${vehicle.lastRepairDate != null ? vehicle.lastRepairDate : ''}">
                                            </div>
                                            <div class="col-12">
                                                <label class="form-label" for="details">Ghi chú chi tiết</label>
                                                <textarea class="form-control" id="details" name="details" rows="3">${vehicle.details != null ? vehicle.details : ''}</textarea>
                                            </div>
                                        </div>
                                        <div class="d-flex justify-content-end gap-2 mt-4">
                                            <a class="btn btn-outline-secondary" href="${contextPath}/admin/vehicles">Hủy</a>
                                            <button type="submit" class="btn btn-primary">Lưu thay đổi</button>
                                        </div>
                                    </form>
                                </c:otherwise>
                            </c:choose>
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
