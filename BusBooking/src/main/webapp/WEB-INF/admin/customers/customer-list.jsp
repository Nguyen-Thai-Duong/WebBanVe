<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="customers" value="${requestScope.customers}" />
<c:set var="dateFormatter" value="${requestScope.dateFormatter}" />
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
<c:set var="navbarSearchAriaLabel" value="Tìm kiếm khách hàng..." scope="request" />
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
    <title>Quản lý khách hàng</title>

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

    <style>
        .table thead th { white-space: nowrap; }
        .customer-avatar {
            width: 42px;
            height: 42px;
            border-radius: 50%;
            background-color: #f0f2ff;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 600;
            color: #5f61e6;
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
                            <h4 class="fw-bold mb-1">Danh sách khách hàng</h4>
                            <span class="text-muted">Theo dõi, tạo mới và cập nhật thông tin khách hàng.</span>
                        </div>
                        <a class="btn btn-primary" href="${contextPath}/admin/customers/new">
                            <i class="bx bx-user-plus"></i> Thêm khách hàng
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
                                <h5 class="card-title mb-0">Tổng quan khách hàng</h5>
                                <small class="text-muted">Hiện có <strong>${fn:length(customers)}</strong> khách hàng.</small>
                            </div>
                        </div>
                        <div class="table-responsive">
                            <table class="table table-hover table-striped align-middle">
                                <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>Khách hàng</th>
                                    <th>Email</th>
                                    <th>Điện thoại</th>
                                    <th>Trạng thái</th>
                                    <th>Ngày tạo</th>
                                    <th class="text-end">Thao tác</th>
                                </tr>
                                </thead>
                                <tbody>
                                <c:if test="${empty customers}">
                                    <tr>
                                        <td colspan="7" class="text-center text-muted py-4">Chưa có khách hàng nào.</td>
                                    </tr>
                                </c:if>
                                <c:forEach var="customer" items="${customers}">
                                    <c:set var="initials" value="${not empty customer.fullName ? fn:toUpperCase(fn:substring(customer.fullName, 0, 1)) : 'C'}" />
                                    <c:set var="statusLower" value="${not empty customer.status ? fn:toLowerCase(customer.status) : ''}" />
                                    <c:set var="statusBadgeClass" value="${statusLower eq 'active' ? 'success' : 'secondary'}" />
                                    <tr>
                                        <td><strong>#${customer.userId}</strong></td>
                                        <td>
                                            <div class="d-flex align-items-center gap-3">
                                                <div class="customer-avatar">${initials}</div>
                                                <div>
                                                    <div class="fw-semibold">${customer.fullName}</div>
                                                    <small class="text-muted">${not empty customer.address ? customer.address : ''}</small>
                                                </div>
                                            </div>
                                        </td>
                                        <td>${customer.email}</td>
                                        <td>${customer.phoneNumber}</td>
                                        <td>
                                            <span class="badge bg-label-${statusBadgeClass}">
                                                ${customer.status}
                                            </span>
                                        </td>
                                        <td>
                                            ${customer.formatCreatedAt(dateFormatter) != null ? customer.formatCreatedAt(dateFormatter) : 'Chưa rõ'}
                                        </td>
                                        <td class="text-end">
                                            <button type="button" class="btn btn-sm btn-icon btn-info text-white" data-bs-toggle="modal" data-bs-target="#viewCustomerModal${customer.userId}">
                                                <i class="bx bx-show"></i>
                                            </button>
                                            <a class="btn btn-sm btn-icon btn-primary" href="${contextPath}/admin/customers/edit?userId=${customer.userId}">
                                                <i class="bx bx-edit"></i>
                                            </a>
                                            <button type="button" class="btn btn-sm btn-icon btn-danger" data-bs-toggle="modal" data-bs-target="#deleteCustomerModal${customer.userId}">
                                                <i class="bx bx-trash"></i>
                                            </button>
                                        </td>
                                    </tr>
                                </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </div>

                    <c:forEach var="customer" items="${customers}">
                    <div class="modal fade" id="viewCustomerModal${customer.userId}" tabindex="-1" aria-hidden="true">
                        <div class="modal-dialog modal-lg modal-dialog-centered">
                            <div class="modal-content">
                                <div class="modal-header">
                                    <h5 class="modal-title">Thông tin khách hàng #${customer.userId}</h5>
                                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                </div>
                                <div class="modal-body">
                                    <div class="row g-4">
                                        <div class="col-md-6">
                                            <small class="text-muted text-uppercase">Họ và tên</small>
                                            <p class="fw-semibold mb-2">${customer.fullName}</p>
                                        </div>
                                        <div class="col-md-6">
                                            <small class="text-muted text-uppercase">Email</small>
                                            <p class="fw-semibold mb-2">${customer.email}</p>
                                        </div>
                                        <div class="col-md-6">
                                            <small class="text-muted text-uppercase">Điện thoại</small>
                                            <p class="fw-semibold mb-2">${customer.phoneNumber}</p>
                                        </div>
                                        <div class="col-md-6">
                                            <small class="text-muted text-uppercase">Trạng thái</small>
                                            <p class="fw-semibold mb-2">${customer.status}</p>
                                        </div>
                                        <div class="col-md-12">
                                            <small class="text-muted text-uppercase">Địa chỉ</small>
                                            <p class="mb-0">${not empty customer.address ? customer.address : 'Chưa cập nhật'}</p>
                                        </div>
                                        <div class="col-md-6">
                                            <small class="text-muted text-uppercase">Ngày tạo</small>
                                            <p class="text-secondary mb-0">${customer.formatCreatedAt(dateFormatter) != null ? customer.formatCreatedAt(dateFormatter) : 'Chưa rõ'}</p>
                                        </div>
                                        <div class="col-md-6">
                                            <small class="text-muted text-uppercase">Cập nhật gần nhất</small>
                                            <p class="text-secondary mb-0">${customer.formatUpdatedAt(dateFormatter) != null ? customer.formatUpdatedAt(dateFormatter) : 'Chưa rõ'}</p>
                                        </div>
                                    </div>
                                </div>
                                <div class="modal-footer">
                                    <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Đóng</button>
                                    <a class="btn btn-primary" href="${contextPath}/admin/customers/edit?userId=${customer.userId}">
                                        <i class="bx bx-edit me-1"></i> Chỉnh sửa thông tin
                                    </a>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="modal fade" id="deleteCustomerModal${customer.userId}" tabindex="-1" aria-hidden="true">
                        <div class="modal-dialog modal-dialog-centered">
                            <div class="modal-content">
                                <form action="${contextPath}/admin/customers" method="post">
                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="userId" value="${customer.userId}">
                                    <div class="modal-header">
                                        <h5 class="modal-title">Xóa khách hàng</h5>
                                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                    </div>
                                    <div class="modal-body">
                                        Bạn có chắc chắn muốn xóa khách hàng <strong>${customer.fullName}</strong>?<br>
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
