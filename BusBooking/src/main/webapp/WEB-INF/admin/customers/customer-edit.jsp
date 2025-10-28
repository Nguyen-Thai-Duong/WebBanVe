<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="assetBase" value="${contextPath}/assets/sneat-1.0.0/assets" />
<c:set var="vendorPath" value="${assetBase}/vendor" />
<c:set var="cssPath" value="${assetBase}/css" />
<c:set var="jsPath" value="${assetBase}/js" />
<c:set var="imgPath" value="${assetBase}/img" />

<c:set var="flashMessage" value="${sessionScope.customerMessage}" />
<c:set var="flashType" value="${sessionScope.customerMessageType}" />
<c:if test="${not empty flashMessage}">
    <c:remove var="customerMessage" scope="session" />
    <c:remove var="customerMessageType" scope="session" />
</c:if>

<c:set var="activeMenu" value="customers" scope="request" />
<c:set var="navbarSearchPlaceholder" value="Tìm kiếm khách hàng..." scope="request" />
<c:set var="navbarSearchAriaLabel" value="Tìm kiếm khách hàng" scope="request" />

<c:set var="statuses" value="${requestScope.customerStatuses}" />
<c:if test="${empty statuses}">
    <c:set var="statuses" value="${fn:split('Active,Inactive,Suspended,Locked', ',')}" />
</c:if>

<c:set var="customer" value="${requestScope.customer}" />
<c:set var="currentStatus" value="${customer != null && not empty customer.status ? customer.status : 'Active'}" />
<c:set var="dateFormatter" value="${requestScope.dateFormatter}" />

<!DOCTYPE html>
<html lang="vi" class="light-style layout-menu-fixed" dir="ltr" data-theme="theme-default" data-assets-path="${assetBase}/" data-template="vertical-menu-template-free">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chỉnh sửa khách hàng</title>
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
                            <h4 class="fw-bold mb-1">Chỉnh sửa khách hàng</h4>
                            <c:choose>
                                <c:when test="${customer != null}">
                                    <span class="text-muted">Cập nhật thông tin cho khách hàng #${customer.userId}.</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="text-muted">Không tìm thấy khách hàng.</span>
                                </c:otherwise>
                            </c:choose>
                        </div>
                        <a class="btn btn-secondary" href="${contextPath}/admin/customers">
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
                            <h5 class="card-title mb-0">Thông tin khách hàng</h5>
                            <c:if test="${customer != null}">
                                <c:set var="createdAtFormatted" value="${customer.formatCreatedAt(dateFormatter)}" />
                                <c:if test="${not empty createdAtFormatted}">
                                    <small class="text-muted">Tạo ngày: ${createdAtFormatted}</small>
                                </c:if>
                            </c:if>
                        </div>
                        <div class="card-body">
                            <c:choose>
                                <c:when test="${customer == null}">
                                    <div class="alert alert-warning mb-0" role="alert">
                                        Không thể tải dữ liệu khách hàng. Vui lòng quay lại danh sách.
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <form action="${contextPath}/admin/customers/edit" method="post" class="needs-validation" novalidate>
                                    <input type="hidden" name="userId" value="${customer.userId}">
                                    <div class="row g-3">
                                        <div class="col-md-6">
                                            <label class="form-label" for="fullName">Họ và tên</label>
                                            <input type="text" class="form-control" id="fullName" name="fullName" value="${customer.fullName != null ? customer.fullName : ''}" required>
                                        </div>
                                        <div class="col-md-6">
                                            <label class="form-label" for="email">Email</label>
                                            <input type="email" class="form-control" id="email" name="email" value="${customer.email != null ? customer.email : ''}" required>
                                        </div>
                                        <div class="col-md-6">
                                            <label class="form-label" for="phoneNumber">Điện thoại</label>
                                            <input type="text" class="form-control" id="phoneNumber" name="phoneNumber" value="${customer.phoneNumber != null ? customer.phoneNumber : ''}" required>
                                        </div>
                                        <div class="col-md-6">
                                            <label class="form-label" for="status">Trạng thái</label>
                                            <select class="form-select" id="status" name="status" required>
                                                <c:forEach var="status" items="${statuses}">
                                                    <option value="${status}"<c:if test="${status eq currentStatus}"> selected</c:if>>${status}</option>
                                                </c:forEach>
                                            </select>
                                        </div>
                                        <div class="col-12">
                                            <label class="form-label" for="address">Địa chỉ</label>
                                            <textarea class="form-control" id="address" name="address" rows="3">${customer.address != null ? customer.address : ''}</textarea>
                                        </div>
                                        <div class="col-md-6">
                                            <label class="form-label" for="password">Đặt lại mật khẩu (tùy chọn)</label>
                                            <input type="password" class="form-control" id="password" name="password" placeholder="Nhập mật khẩu mới nếu muốn thay đổi">
                                            <div class="form-text">Để trống nếu không muốn thay đổi mật khẩu.</div>
                                        </div>
                                    </div>
                                    <div class="d-flex justify-content-end gap-2 mt-4">
                                        <a class="btn btn-outline-secondary" href="${contextPath}/admin/customers">Hủy</a>
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
