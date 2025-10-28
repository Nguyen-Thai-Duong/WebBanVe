<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="app" tagdir="/WEB-INF/tags" %>

<c:set var="payments" value="${requestScope.payments}" />
<c:set var="dateFormatter" value="${requestScope.dateFormatter}" />
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="assetBase" value="${contextPath}/assets/sneat-1.0.0/assets" />
<c:set var="vendorPath" value="${assetBase}/vendor" />
<c:set var="cssPath" value="${assetBase}/css" />
<c:set var="jsPath" value="${assetBase}/js" />
<c:set var="imgPath" value="${assetBase}/img" />

<c:set var="flashMessage" value="${sessionScope.paymentMessage}" />
<c:set var="flashType" value="${sessionScope.paymentMessageType}" />
<c:if test="${not empty flashMessage}">
    <c:remove var="paymentMessage" scope="session" />
    <c:remove var="paymentMessageType" scope="session" />
</c:if>

<c:set var="activeMenu" value="payments" scope="request" />
<c:set var="navbarSearchPlaceholder" value="Tìm kiếm giao dịch..." scope="request" />
<c:set var="navbarSearchAriaLabel" value="Tìm kiếm giao dịch" scope="request" />

<!DOCTYPE html>
<html lang="vi" class="light-style layout-menu-fixed" dir="ltr" data-theme="theme-default" data-assets-path="${assetBase}/" data-template="vertical-menu-template-free">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý thanh toán</title>
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
        .route-label { font-weight: 600; }
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
                            <h4 class="fw-bold mb-1">Danh sách giao dịch</h4>
                            <span class="text-muted">Theo dõi các khoản thanh toán, hoàn tiền và phí phát sinh. Giao dịch chưa thanh toán được ưu tiên hiển thị trước.</span>
                        </div>
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
                                <h5 class="card-title mb-0">Tổng quan giao dịch</h5>
                                <small class="text-muted">Có <strong>${fn:length(payments)}</strong> dòng giao dịch.</small>
                            </div>
                        </div>
                        <div class="table-responsive">
                            <table class="table table-hover table-striped align-middle">
                                <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>Đơn đặt chỗ</th>
                                    <th>Số tiền</th>
                                    <th>Loại</th>
                                    <th>Trạng thái đơn</th>
                                    <th>Ngày giao dịch</th>
                                    <th>Mã tham chiếu</th>
                                    <th class="text-end">Chi tiết</th>
                                </tr>
                                </thead>
                                <tbody>
                                <c:if test="${empty payments}">
                                    <tr>
                                        <td colspan="8" class="text-center text-muted py-4">Chưa có giao dịch nào.</td>
                                    </tr>
                                </c:if>
                                <c:forEach var="payment" items="${payments}">
                                    <c:set var="typeLower" value="${fn:toLowerCase(payment.type)}" />
                                    <c:set var="typeBadge" value="${typeLower eq 'payment' ? 'success' : (typeLower eq 'refund' ? 'warning' : 'info')}" />
                                    <c:set var="statusLower" value="${fn:toLowerCase(payment.bookingStatus)}" />
                                    <c:set var="statusBadge" value="${statusLower eq 'pending' ? 'warning' : (statusLower eq 'confirmed' ? 'success' : (statusLower eq 'cancelled' ? 'danger' : 'secondary'))}" />
                                    <c:set var="rowClass" value="${payment.pending ? 'table-warning' : ''}" />
                                    <tr class="${rowClass}">
                                        <td><strong>#${payment.paymentId}</strong></td>
                                        <td>
                                            <div class="d-flex flex-column">
                                                <span class="route-label">${payment.buildRouteLabel()}</span>
                                                <small class="text-muted">
                                                    Ghế ${payment.seatNumber != null ? payment.seatNumber : '?'}
                                                    <c:if test="${payment.customerName != null}">
                                                        &middot; ${payment.customerName}
                                                    </c:if>
                                                    <c:if test="${payment.formatDepartureTime(dateFormatter) != null}">
                                                        &middot; ${payment.formatDepartureTime(dateFormatter)}
                                                    </c:if>
                                                </small>
                                            </div>
                                        </td>
                                        <td>
                                            <strong><app:currency value="${payment.amount}" /></strong>
                                        </td>
                                        <td>
                                            <span class="badge bg-label-${typeBadge}">${payment.type}</span>
                                        </td>
                                        <td>
                                            <span class="badge bg-label-${statusBadge}">
                                                ${payment.bookingStatus != null ? payment.bookingStatus : 'Không rõ'}
                                            </span>
                                        </td>
                                        <td>${payment.formatTransactionDate(dateFormatter) != null ? payment.formatTransactionDate(dateFormatter) : 'Chưa rõ'}</td>
                                        <td>${payment.transactionRef != null ? payment.transactionRef : '-'}</td>
                                        <td class="text-end">
                                            <a class="btn btn-sm btn-outline-primary" href="${contextPath}/admin/payments/detail?paymentId=${payment.paymentId}">
                                                Xem chi tiết
                                            </a>
                                        </td>
                                    </tr>
                                </c:forEach>
                                </tbody>
                            </table>
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
