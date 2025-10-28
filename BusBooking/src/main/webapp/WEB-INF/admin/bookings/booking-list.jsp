<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="bookings" value="${requestScope.bookings}" />
<c:set var="dateFormatter" value="${requestScope.dateFormatter}" />
<c:set var="bookingStatuses" value="${requestScope.bookingStatuses}" />
<c:set var="seatStatuses" value="${requestScope.seatStatuses}" />
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="assetBase" value="${contextPath}/assets/sneat-1.0.0/assets" />
<c:set var="vendorPath" value="${assetBase}/vendor" />
<c:set var="cssPath" value="${assetBase}/css" />
<c:set var="jsPath" value="${assetBase}/js" />
<c:set var="imgPath" value="${assetBase}/img" />

<c:set var="flashMessage" value="${sessionScope.bookingMessage}" />
<c:set var="flashType" value="${sessionScope.bookingMessageType}" />
<c:if test="${not empty flashMessage}">
    <c:remove var="bookingMessage" scope="session" />
    <c:remove var="bookingMessageType" scope="session" />
</c:if>

<c:set var="activeMenu" value="bookings" scope="request" />
<c:set var="navbarSearchPlaceholder" value="Tìm kiếm đơn đặt chỗ..." scope="request" />
<c:set var="navbarSearchAriaLabel" value="Tìm kiếm đơn đặt chỗ" scope="request" />

<!DOCTYPE html>
<html lang="vi" class="light-style layout-menu-fixed" dir="ltr" data-theme="theme-default" data-assets-path="${assetBase}/" data-template="vertical-menu-template-free">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý đơn đặt chỗ</title>
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
        .trip-route { font-weight: 600; }
        .customer-avatar {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            background-color: #eef1ff;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 600;
            color: #5f61e6;
        }
        .table thead th { white-space: nowrap; }
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
                            <h4 class="fw-bold mb-1">Danh sách đơn đặt chỗ</h4>
                            <span class="text-muted">Theo dõi trạng thái, cập nhật và xử lý đơn đặt chỗ.</span>
                        </div>
                        <a class="btn btn-primary" href="${contextPath}/admin/bookings/new">
                            <i class="bx bx-plus"></i> Tạo đơn mới
                        </a>
                    </div>

                    <c:if test="${not empty flashMessage}">
                        <div class="alert alert-${not empty flashType ? flashType : 'info'} alert-dismissible" role="alert">
                            ${flashMessage}
                            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                        </div>
                    </c:if>

                    <div class="card">
                        <div class="card-header">
                            <div class="d-flex justify-content-between align-items-center flex-wrap gap-2">
                                <div>
                                    <h5 class="card-title mb-0">Tổng quan booking</h5>
                                    <small class="text-muted">Có <strong>${fn:length(bookings)}</strong> đơn đặt chỗ.</small>
                                </div>
                            </div>
                        </div>
                        <div class="table-responsive">
                            <table class="table table-hover table-striped align-middle">
                                <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>Chuyến đi</th>
                                    <th>Khách/Khách lẻ</th>
                                    <th>Ghế</th>
                                    <th>Trạng thái</th>
                                    <th>Đặt lúc</th>
                                    <th>TTL</th>
                                    <th class="text-end">Thao tác</th>
                                </tr>
                                </thead>
                                <tbody>
                                <c:if test="${empty bookings}">
                                    <tr>
                                        <td colspan="8" class="text-center text-muted py-4">Chưa có đơn đặt chỗ nào.</td>
                                    </tr>
                                </c:if>
                                <c:forEach var="booking" items="${bookings}">
                                    <c:set var="hasCustomer" value="${not empty booking.customerName}" />
                                    <c:set var="customerLabel" value="${hasCustomer ? booking.customerName : 'Khách lẻ'}" />
                                    <c:set var="statusLower" value="${fn:toLowerCase(booking.bookingStatus)}" />
                                    <c:set var="statusBadge" value="${statusLower eq 'confirmed' ? 'success' : (statusLower eq 'pending' ? 'warning' : (statusLower eq 'cancelled' ? 'danger' : 'secondary'))}" />
                                    <c:set var="seatStatusLower" value="${fn:toLowerCase(booking.seatStatus)}" />
                                    <c:set var="seatBadge" value="${seatStatusLower eq 'booked' ? 'primary' : (seatStatusLower eq 'reserved' ? 'info' : 'secondary')}" />
                                    <tr>
                                        <td><strong>#${booking.bookingId}</strong></td>
                                        <td>
                                            <div class="d-flex flex-column">
                                                <span class="trip-route">${booking.routeOrigin} &rarr; ${booking.routeDestination}</span>
                                                <small class="text-muted">
                                                    ${booking.formatDepartureTime(dateFormatter) != null ? booking.formatDepartureTime(dateFormatter) : 'Chưa rõ'}
                                                    <c:if test="${booking.formatArrivalTime(dateFormatter) != null}">
                                                        &middot; đến ${booking.formatArrivalTime(dateFormatter)}
                                                    </c:if>
                                                    <c:if test="${not empty booking.vehiclePlate}">
                                                        &middot; Xe ${booking.vehiclePlate}
                                                    </c:if>
                                                </small>
                                            </div>
                                        </td>
                                        <td>
                                            <div class="d-flex align-items-center gap-3">
                                                <div class="customer-avatar">
                                                    <c:choose>
                                                        <c:when test="${hasCustomer}">
                                                            ${fn:toUpperCase(fn:substring(customerLabel, 0, 1))}
                                                        </c:when>
                                                        <c:when test="${not empty booking.guestPhoneNumber}">
                                                            G
                                                        </c:when>
                                                        <c:otherwise>
                                                            ?
                                                        </c:otherwise>
                                                    </c:choose>
                                                </div>
                                                <div>
                                                    <div class="fw-semibold">${customerLabel}</div>
                                                    <small class="text-muted">
                                                        <c:choose>
                                                            <c:when test="${hasCustomer}">
                                                                ${booking.customerEmail}
                                                            </c:when>
                                                            <c:otherwise>
                                                                ${not empty booking.guestPhoneNumber ? booking.guestPhoneNumber : 'Chưa có liên hệ'}
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </small>
                                                </div>
                                            </div>
                                        </td>
                                        <td>
                                            <div class="d-flex flex-column">
                                                <span class="fw-semibold">${booking.seatNumber}</span>
                                                <span class="badge bg-label-${seatBadge} mt-1">${booking.seatStatus}</span>
                                            </div>
                                        </td>
                                        <td>
                                            <span class="badge bg-label-${statusBadge}">
                                                ${booking.bookingStatus}
                                            </span>
                                        </td>
                                        <td>
                                            ${booking.formatBookingDate(dateFormatter) != null ? booking.formatBookingDate(dateFormatter) : 'Chưa rõ'}
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${booking.formatTtlExpiry(dateFormatter) != null}">
                                                    ${booking.formatTtlExpiry(dateFormatter)}
                                                </c:when>
                                                <c:otherwise>
                                                    -
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="text-end">
                                            <button type="button" class="btn btn-sm btn-icon btn-info text-white" data-bs-toggle="modal" data-bs-target="#viewBookingModal${booking.bookingId}">
                                                <i class="bx bx-show"></i>
                                            </button>
                                            <a class="btn btn-sm btn-icon btn-primary" href="${contextPath}/admin/bookings/edit?bookingId=${booking.bookingId}">
                                                <i class="bx bx-edit"></i>
                                            </a>
                                            <button type="button" class="btn btn-sm btn-icon btn-danger" data-bs-toggle="modal" data-bs-target="#deleteBookingModal${booking.bookingId}">
                                                <i class="bx bx-trash"></i>
                                            </button>
                                        </td>
                                    </tr>
                                </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </div>

                    <c:forEach var="booking" items="${bookings}">
                        <div class="modal fade" id="viewBookingModal${booking.bookingId}" tabindex="-1" aria-hidden="true">
                            <div class="modal-dialog modal-lg modal-dialog-centered">
                                <div class="modal-content">
                                    <div class="modal-header">
                                        <h5 class="modal-title">Chi tiết đơn đặt chỗ #${booking.bookingId}</h5>
                                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                    </div>
                                    <div class="modal-body">
                                        <div class="row g-4">
                                            <div class="col-md-6">
                                                <small class="text-muted text-uppercase">Chuyến đi</small>
                                                <p class="fw-semibold mb-2">${booking.routeOrigin} &rarr; ${booking.routeDestination}</p>
                                                <small class="text-muted">Khởi hành:</small>
                                                <p class="mb-0">${booking.formatDepartureTime(dateFormatter) != null ? booking.formatDepartureTime(dateFormatter) : 'Chưa rõ'}</p>
                                            </div>
                                            <div class="col-md-6">
                                                <small class="text-muted text-uppercase">Khách</small>
                                                <p class="fw-semibold mb-2">
                                                    <c:choose>
                                                        <c:when test="${not empty booking.customerName}">${booking.customerName}</c:when>
                                                        <c:otherwise>Khách lẻ</c:otherwise>
                                                    </c:choose>
                                                </p>
                                                <small class="text-muted">Liên hệ:</small>
                                                <p class="mb-0">
                                                    <c:choose>
                                                        <c:when test="${not empty booking.customerEmail}">${booking.customerEmail}</c:when>
                                                        <c:otherwise>${not empty booking.guestPhoneNumber ? booking.guestPhoneNumber : 'Chưa có'}</c:otherwise>
                                                    </c:choose>
                                                </p>
                                            </div>
                                            <div class="col-md-4">
                                                <small class="text-muted text-uppercase">Ghế</small>
                                                <p class="fw-semibold mb-0">${booking.seatNumber}</p>
                                                <span class="badge bg-label-info mt-1">${booking.seatStatus}</span>
                                            </div>
                                            <div class="col-md-4">
                                                <small class="text-muted text-uppercase">Trạng thái đơn</small>
                                                <p class="fw-semibold mb-0">${booking.bookingStatus}</p>
                                            </div>
                                            <div class="col-md-4">
                                                <small class="text-muted text-uppercase">Đặt lúc</small>
                                                <p class="mb-0">${booking.formatBookingDate(dateFormatter) != null ? booking.formatBookingDate(dateFormatter) : 'Chưa rõ'}</p>
                                            </div>
                                            <div class="col-md-6">
                                                <small class="text-muted text-uppercase">TTL giữ chỗ</small>
                                                <p class="mb-0">
                                                    <c:choose>
                                                        <c:when test="${booking.formatTtlExpiry(dateFormatter) != null}">${booking.formatTtlExpiry(dateFormatter)}</c:when>
                                                        <c:otherwise>Không thiết lập</c:otherwise>
                                                    </c:choose>
                                                </p>
                                            </div>
                                            <div class="col-md-6">
                                                <small class="text-muted text-uppercase">Biển số xe</small>
                                                <p class="mb-0">${not empty booking.vehiclePlate ? booking.vehiclePlate : 'Chưa rõ'}</p>
                                            </div>
                                            <div class="col-md-12">
                                                <small class="text-muted text-uppercase">Thông tin khách lẻ</small>
                                                <p class="mb-0">Email: ${not empty booking.guestEmail ? booking.guestEmail : 'Chưa có'}<br>Điện thoại: ${not empty booking.guestPhoneNumber ? booking.guestPhoneNumber : 'Chưa có'}</p>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="modal-footer">
                                        <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Đóng</button>
                                        <a class="btn btn-primary" href="${contextPath}/admin/bookings/edit?bookingId=${booking.bookingId}">
                                            <i class="bx bx-edit me-1"></i> Chỉnh sửa
                                        </a>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="modal fade" id="deleteBookingModal${booking.bookingId}" tabindex="-1" aria-hidden="true">
                            <div class="modal-dialog modal-dialog-centered">
                                <div class="modal-content">
                                    <form action="${contextPath}/admin/bookings" method="post">
                                        <input type="hidden" name="action" value="delete">
                                        <input type="hidden" name="bookingId" value="${booking.bookingId}">
                                        <div class="modal-header">
                                            <h5 class="modal-title">Xóa đơn đặt chỗ</h5>
                                            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                        </div>
                                        <div class="modal-body">
                                            Bạn có chắc chắn muốn xóa đơn đặt chỗ <strong>#${booking.bookingId}</strong>?
                                            <br>Thao tác này không thể hoàn tác.
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
