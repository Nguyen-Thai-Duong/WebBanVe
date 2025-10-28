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

<c:set var="staff" value="${requestScope.staff}" />
<c:set var="currentStatus" value="${staff != null && not empty staff.status ? staff.status : 'Active'}" />
<c:set var="dateFormatter" value="${requestScope.dateFormatter}" />

<!DOCTYPE html>
<html lang="vi" class="light-style layout-menu-fixed" dir="ltr" data-theme="theme-default" data-assets-path="${assetBase}/" data-template="vertical-menu-template-free">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chỉnh sửa nhân viên</title>
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
                            <h4 class="fw-bold mb-1">Chỉnh sửa nhân viên</h4>
                            <c:choose>
                                <c:when test="${staff != null}">
                                    <span class="text-muted">
                                        Cập nhật thông tin cho nhân viên
                                        <c:choose>
                                            <c:when test="${not empty staff.employeeCode}">
                                                ${staff.employeeCode}
                                            </c:when>
                                            <c:otherwise>
                                                #${staff.userId}
                                            </c:otherwise>
                                        </c:choose>.
                                    </span>
                                </c:when>
                                <c:otherwise>
                                    <span class="text-muted">Không tìm thấy nhân viên.</span>
                                </c:otherwise>
                            </c:choose>
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
                        <div class="card-header d-flex justify-content-between align-items-center flex-wrap gap-2">
                            <h5 class="card-title mb-0">Thông tin nhân viên</h5>
                            <c:if test="${staff != null}">
                                <c:set var="createdAtFormatted" value="${staff.formatCreatedAt(dateFormatter)}" />
                                <c:if test="${not empty createdAtFormatted}">
                                    <small class="text-muted">Tạo ngày: ${createdAtFormatted}</small>
                                </c:if>
                            </c:if>
                        </div>
                        <div class="card-body">
                            <c:choose>
                                <c:when test="${staff == null}">
                                    <div class="alert alert-warning mb-0" role="alert">
                                        Không thể tải dữ liệu nhân viên. Vui lòng quay lại danh sách.
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <form action="${contextPath}/admin/staff/edit" method="post" class="needs-validation" novalidate>
                                        <input type="hidden" name="userId" value="${staff.userId}">
                                        <div class="row g-3">
                                            <div class="col-md-6">
                                                <label class="form-label" for="fullName">Họ và tên</label>
                                                <input type="text" class="form-control" id="fullName" name="fullName" value="${staff.fullName != null ? staff.fullName : ''}" required>
                                            </div>
                                            <div class="col-md-6">
                                                <label class="form-label" for="email">Email</label>
                                                <input type="email" class="form-control" id="email" name="email" value="${staff.email != null ? staff.email : ''}" required>
                                            </div>
                                            <div class="col-md-6">
                                                <label class="form-label" for="phone">Điện thoại</label>
                                                <input type="text" class="form-control" id="phone" name="phone" value="${staff.phoneNumber != null ? staff.phoneNumber : ''}" required>
                                            </div>
                                            <div class="col-md-6">
                                                <label class="form-label" for="status">Trạng thái</label>
                                                <select class="form-select" id="status" name="status" required>
                                                    <c:forEach var="status" items="${statuses}">
                                                        <option value="${status}"<c:if test="${status eq currentStatus}"> selected</c:if>>${status}</option>
                                                    </c:forEach>
                                                </select>
                                            </div>
                                            <div class="col-md-6">
                                                <label class="form-label">Mã nhân viên</label>
                                                <input type="text" class="form-control" value="${not empty staff.employeeCode ? staff.employeeCode : 'Chưa cấp'}" disabled>
                                            </div>
                                            <div class="col-md-6">
                                                <label class="form-label">Vai trò</label>
                                                <input type="text" class="form-control" value="${staff.role}" disabled>
                                            </div>
                                            <div class="col-12">
                                                <label class="form-label" for="address">Địa chỉ</label>
                                                <textarea class="form-control" id="address" name="address" rows="3">${staff.address != null ? staff.address : ''}</textarea>
                                            </div>
                                            <div class="col-md-6">
                                                <label class="form-label" for="password">Đặt lại mật khẩu (tùy chọn)</label>
                                                <input type="password" class="form-control" id="password" name="password" placeholder="Nhập mật khẩu mới nếu muốn thay đổi">
                                                <div class="form-text">Để trống nếu không muốn thay đổi mật khẩu.</div>
                                            </div>
                                        </div>
                                        <div class="d-flex justify-content-end gap-2 mt-4">
                                            <a class="btn btn-outline-secondary" href="${contextPath}/admin/staff">Hủy</a>
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
