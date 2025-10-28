<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="payment" value="${requestScope.payment}" />
<c:set var="dateFormatter" value="${requestScope.dateFormatter}" />
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="assetBase" value="${contextPath}/assets/sneat-1.0.0/assets" />
<c:set var="vendorPath" value="${assetBase}/vendor" />
<c:set var="cssPath" value="${assetBase}/css" />
<c:set var="jsPath" value="${assetBase}/js" />
<c:set var="imgPath" value="${assetBase}/img" />

<c:set var="activeMenu" value="payments" scope="request" />
<c:set var="navbarSearchPlaceholder" value="Tìm kiếm giao dịch..." scope="request" />
<c:set var="navbarSearchAriaLabel" value="Tìm kiếm giao dịch" scope="request" />

<c:set var="typeLower" value="${fn:toLowerCase(payment.type)}" />
<c:set var="typeBadge" value="${typeLower eq 'payment' ? 'success' : (typeLower eq 'refund' ? 'warning' : 'info')}" />
<c:set var="statusLower" value="${fn:toLowerCase(payment.bookingStatus)}" />
<c:set var="statusBadge" value="${statusLower eq 'pending' ? 'warning' : (statusLower eq 'confirmed' ? 'success' : (statusLower eq 'cancelled' ? 'danger' : 'secondary'))}" />

<!DOCTYPE html>
<html lang="vi" class="light-style layout-menu-fixed" dir="ltr" data-theme="theme-default" data-assets-path="${assetBase}/" data-template="vertical-menu-template-free">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chi tiết giao dịch #${payment.paymentId}</title>
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
        .label-muted { color: #697a8d; font-size: 0.85rem; text-transform: uppercase; letter-spacing: 0.08em; }
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
                            <h4 class="fw-bold mb-1">Giao dịch #${payment.paymentId}</h4>
                            <span class="text-muted">Thông tin chi tiết giao dịch và đơn đặt chỗ liên quan.</span>
                        </div>
                        <a class="btn btn-outline-secondary" href="${contextPath}/admin/payments">
                            <i class="bx bx-chevron-left"></i> Quay lại danh sách
                        </a>
                    </div>

                    <c:if test="${payment.pending}">
                        <div class="alert alert-warning" role="alert">
                            <strong>Chưa thanh toán:</strong> Đơn đặt chỗ vẫn đang ở trạng thái <em>Pending</em>. Vui lòng phối hợp bộ phận liên quan để xử lý.
                        </div>
                    </c:if>

                    <div class="row g-4">
                        <div class="col-lg-7 col-12">
                            <div class="card h-100">
                                <div class="card-header">
                                    <h5 class="card-title mb-0">Thông tin chung</h5>
                                </div>
                                <div class="card-body">
                                    <div class="row g-4">
                                        <div class="col-sm-6">
                                            <div class="label-muted">Số giao dịch</div>
                                            <div class="fw-semibold">#${payment.paymentId}</div>
                                        </div>
                                        <div class="col-sm-6">
                                            <div class="label-muted">Loại giao dịch</div>
                                            <span class="badge bg-label-${typeBadge}">${payment.type}</span>
                                        </div>
                                        <div class="col-sm-6">
                                            <div class="label-muted">Số tiền</div>
                                            <div class="fw-semibold text-primary">
                                                <fmt:formatNumber value="${payment.amount}" type="number" minFractionDigits="0" maxFractionDigits="2" /> ₫
                                            </div>
                                        </div>
                                        <div class="col-sm-6">
                                            <div class="label-muted">Phương thức</div>
                                            <div>${payment.method != null ? payment.method : 'Chưa cập nhật'}</div>
                                        </div>
                                        <div class="col-sm-6">
                                            <div class="label-muted">Ngày giao dịch</div>
                                            <div>${payment.formatTransactionDate(dateFormatter) != null ? payment.formatTransactionDate(dateFormatter) : 'Chưa ghi nhận'}</div>
                                        </div>
                                        <div class="col-sm-6">
                                            <div class="label-muted">Mã tham chiếu</div>
                                            <div>${payment.transactionRef != null ? payment.transactionRef : '-'}</div>
                                        </div>
                                        <div class="col-sm-6">
                                            <div class="label-muted">Trạng thái booking</div>
                                            <span class="badge bg-label-${statusBadge}">${payment.bookingStatus != null ? payment.bookingStatus : 'Không rõ'}</span>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="col-lg-5 col-12">
                            <div class="card h-100">
                                <div class="card-header">
                                    <h5 class="card-title mb-0">Thông tin đơn đặt chỗ</h5>
                                </div>
                                <div class="card-body">
                                    <div class="mb-3">
                                        <div class="label-muted">Mã đơn</div>
                                        <div class="fw-semibold">#${payment.bookingId}</div>
                                    </div>
                                    <div class="mb-3">
                                        <div class="label-muted">Khách hàng</div>
                                        <div>${payment.customerName != null ? payment.customerName : 'Khách lẻ'}</div>
                                    </div>
                                    <div class="mb-3">
                                        <div class="label-muted">Tuyến đường</div>
                                        <div class="fw-semibold">${payment.buildRouteLabel()}</div>
                                        <c:if test="${payment.formatDepartureTime(dateFormatter) != null}">
                                            <div class="text-muted">Khởi hành: ${payment.formatDepartureTime(dateFormatter)}</div>
                                        </c:if>
                                    </div>
                                    <div>
                                        <div class="label-muted">Ghế</div>
                                        <div>${payment.seatNumber != null ? payment.seatNumber : '-'}</div>
                                    </div>
                                </div>
                            </div>
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
