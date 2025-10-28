<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="operators" value="${requestScope.operators}" />
<c:set var="dateFormatter" value="${requestScope.dateFormatter}" />
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="assetBase" value="${contextPath}/assets/sneat-1.0.0/assets" />
<c:set var="vendorPath" value="${assetBase}/vendor" />
<c:set var="cssPath" value="${assetBase}/css" />
<c:set var="jsPath" value="${assetBase}/js" />
<c:set var="imgPath" value="${assetBase}/img" />

<c:set var="flashMessage" value="${sessionScope.operatorMessage}" />
<c:set var="flashType" value="${sessionScope.operatorMessageType}" />
<c:if test="${not empty flashMessage}">
    <c:remove var="operatorMessage" scope="session" />
    <c:remove var="operatorMessageType" scope="session" />
</c:if>

<c:set var="activeMenu" value="operators" scope="request" />
<c:set var="navbarSearchPlaceholder" value="Tìm kiếm người phụ trách..." scope="request" />
<c:set var="navbarSearchAriaLabel" value="Tìm kiếm người phụ trách" scope="request" />
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
    <title>Quản lý người phụ trách</title>

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
        .operator-avatar {
            width: 42px;
            height: 42px;
            border-radius: 50%;
            background-color: #e6f0ff;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 600;
            color: #0d6efd;
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
                            <h4 class="fw-bold mb-1">Danh sách người phụ trách</h4>
                            <span class="text-muted">Quản lý đội ngũ bus operator chịu trách nhiệm vận hành chuyến đi.</span>
                        </div>
                        <a class="btn btn-primary" href="${contextPath}/admin/operators/new">
                            <i class="bx bx-user-plus"></i> Thêm người phụ trách
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
                                <h5 class="card-title mb-0">Tổng quan người phụ trách</h5>
                                <small class="text-muted">Hiện có <strong>${fn:length(operators)}</strong> bus operator.</small>
                            </div>
                        </div>
                        <div class="table-responsive">
                            <table class="table table-hover table-striped align-middle">
                                <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>Họ tên</th>
                                    <th>Email</th>
                                    <th>Điện thoại</th>
                                    <th>Trạng thái</th>
                                    <th>Ngày tạo</th>
                                    <th class="text-end">Thao tác</th>
                                </tr>
                                </thead>
                                <tbody>
                                <c:if test="${empty operators}">
                                    <tr>
                                        <td colspan="7" class="text-center text-muted py-4">Chưa có người phụ trách nào.</td>
                                    </tr>
                                </c:if>
                                <c:forEach var="operator" items="${operators}">
                                    <c:set var="initials" value="${not empty operator.fullName ? fn:toUpperCase(fn:substring(operator.fullName, 0, 1)) : 'O'}" />
                                    <c:set var="statusLower" value="${not empty operator.status ? fn:toLowerCase(operator.status) : ''}" />
                                    <c:set var="statusBadgeClass" value="${statusLower eq 'active' ? 'success' : 'secondary'}" />
                                    <tr>
                                        <td><strong>#${operator.userId}</strong></td>
                                        <td>
                                            <div class="d-flex align-items-center gap-3">
                                                <div class="operator-avatar">${initials}</div>
                                                <div>
                                                    <div class="fw-semibold">${operator.fullName}</div>
                                                    <small class="text-muted">
                                                        <c:choose>
                                                            <c:when test="${not empty operator.employeeCode}">Mã NV: ${operator.employeeCode}</c:when>
                                                            <c:otherwise>Chưa cấp mã</c:otherwise>
                                                        </c:choose>
                                                    </small>
                                                </div>
                                            </div>
                                        </td>
                                        <td>${operator.email}</td>
                                        <td>${operator.phoneNumber}</td>
                                        <td>
                                            <span class="badge bg-label-${statusBadgeClass}">
                                                ${operator.status}
                                            </span>
                                        </td>
                                        <td>${operator.formatCreatedAt(dateFormatter) != null ? operator.formatCreatedAt(dateFormatter) : 'Chưa rõ'}</td>
                                        <td class="text-end">
                                            <button type="button" class="btn btn-sm btn-icon btn-info text-white" data-bs-toggle="modal" data-bs-target="#viewOperatorModal${operator.userId}">
                                                <i class="bx bx-show"></i>
                                            </button>
                                            <a class="btn btn-sm btn-icon btn-primary" href="${contextPath}/admin/operators/edit?id=${operator.userId}">
                                                <i class="bx bx-edit"></i>
                                            </a>
                                            <button type="button" class="btn btn-sm btn-icon btn-danger" data-bs-toggle="modal" data-bs-target="#deleteOperatorModal${operator.userId}">
                                                <i class="bx bx-trash"></i>
                                            </button>
                                        </td>
                                    </tr>
                                </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </div>

                    <c:forEach var="operator" items="${operators}">
                    <div class="modal fade" id="viewOperatorModal${operator.userId}" tabindex="-1" aria-hidden="true">
                        <div class="modal-dialog modal-lg modal-dialog-centered">
                            <div class="modal-content">
                                <div class="modal-header">
                                    <h5 class="modal-title">Thông tin người phụ trách #${operator.userId}</h5>
                                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                </div>
                                <div class="modal-body">
                                    <div class="row g-4">
                                        <div class="col-md-6">
                                            <small class="text-muted text-uppercase">Họ và tên</small>
                                            <p class="fw-semibold mb-2">${operator.fullName}</p>
                                        </div>
                                        <div class="col-md-6">
                                            <small class="text-muted text-uppercase">Email</small>
                                            <p class="fw-semibold mb-2">${operator.email}</p>
                                        </div>
                                        <div class="col-md-6">
                                            <small class="text-muted text-uppercase">Điện thoại</small>
                                            <p class="fw-semibold mb-2">${operator.phoneNumber}</p>
                                        </div>
                                        <div class="col-md-6">
                                            <small class="text-muted text-uppercase">Trạng thái</small>
                                            <p class="fw-semibold mb-2">${operator.status}</p>
                                        </div>
                                        <div class="col-md-6">
                                            <small class="text-muted text-uppercase">Mã nhân viên</small>
                                            <p class="fw-semibold mb-2">
                                                <c:choose>
                                                    <c:when test="${not empty operator.employeeCode}">${operator.employeeCode}</c:when>
                                                    <c:otherwise>Chưa cấp</c:otherwise>
                                                </c:choose>
                                            </p>
                                        </div>
                                        <div class="col-md-6">
                                            <small class="text-muted text-uppercase">Địa chỉ</small>
                                            <p class="fw-semibold mb-2">${not empty operator.address ? operator.address : 'Chưa cập nhật'}</p>
                                        </div>
                                        <div class="col-md-6">
                                            <small class="text-muted text-uppercase">Ngày tạo</small>
                                            <p class="text-secondary mb-2">${operator.formatCreatedAt(dateFormatter) != null ? operator.formatCreatedAt(dateFormatter) : 'Chưa rõ'}</p>
                                        </div>
                                        <div class="col-md-6">
                                            <small class="text-muted text-uppercase">Cập nhật gần nhất</small>
                                            <p class="text-secondary mb-2">${operator.formatUpdatedAt(dateFormatter) != null ? operator.formatUpdatedAt(dateFormatter) : 'Chưa rõ'}</p>
                                        </div>
                                    </div>
                                </div>
                                <div class="modal-footer">
                                    <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Đóng</button>
                                    <a class="btn btn-primary" href="${contextPath}/admin/operators/edit?id=${operator.userId}">
                                        <i class="bx bx-edit me-1"></i> Chỉnh sửa
                                    </a>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="modal fade" id="deleteOperatorModal${operator.userId}" tabindex="-1" aria-hidden="true">
                        <div class="modal-dialog modal-dialog-centered">
                            <div class="modal-content">
                                <form action="${contextPath}/admin/operators" method="post">
                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="userId" value="${operator.userId}">
                                    <div class="modal-header">
                                        <h5 class="modal-title">Xóa người phụ trách</h5>
                                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                    </div>
                                    <div class="modal-body">
                                        Bạn có chắc chắn muốn xóa tài khoản của <strong>${operator.fullName}</strong>?<br>
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
