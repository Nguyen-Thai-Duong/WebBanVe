<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:if test="${empty ticketOverview}">
    <c:redirect url="${contextPath}/app/customer/profile" />
</c:if>

<c:set var="assetBase" value="${contextPath}/assets/sneat-1.0.0/assets" />
<c:set var="vendorPath" value="${assetBase}/vendor" />
<c:set var="cssPath" value="${assetBase}/css" />
<c:set var="jsPath" value="${assetBase}/js" />
<c:set var="imgPath" value="${assetBase}/img" />

<c:set var="customerNameDisplay" value="${not empty customerName ? customerName : 'Khách hàng'}" />
<c:set var="statusCounts" value="${ticketOverview.statusCounts}" />
<!DOCTYPE html>
<html lang="vi" class="light-style layout-menu-fixed" dir="ltr" data-theme="theme-default"
      data-assets-path="${assetBase}/" data-template="vertical-menu-template-free">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Vé của tôi</title>

    <%@ include file="includes/fragment-customer-head.jspf" %>
</head>
<body>
<div class="layout-wrapper layout-content-navbar">
    <div class="layout-container">
        <div class="layout-page">
            <div class="content-wrapper">
                <div class="container-xxl flex-grow-1 container-p-y">
                    <div class="d-flex align-items-center justify-content-between flex-wrap gap-2 mb-4">
                        <div>
                            <h4 class="fw-bold mb-1">Lịch sử vé của <c:out value="${customerNameDisplay}" /></h4>
                            <p class="text-muted mb-0">Theo dõi các chuyến đi đã đặt và tình trạng xử lý</p>
                        </div>
                        <div class="d-flex flex-wrap gap-2">
                            <a href="${contextPath}/homepage.jsp" class="btn btn-outline-secondary">
                                <i class="bx bx-chevron-left"></i> Trang chủ
                            </a>
                            <a href="${contextPath}/app/customer/profile" class="btn btn-warning text-white">
                                <i class="bx bx-user"></i> Hồ sơ
                            </a>
                        </div>
                    </div>

                    <div class="row g-4 mb-4">
                        <div class="col-sm-6 col-xl-3">
                            <div class="card h-100">
                                <div class="card-body">
                                    <span class="d-block fw-semibold text-muted">Tổng số vé</span>
                                    <h3 class="card-title mb-2"><c:out value="${ticketOverview.totalTickets}" /></h3>
                                    <small class="text-muted">Bao gồm tất cả các trạng thái</small>
                                </div>
                            </div>
                        </div>
                        <div class="col-sm-6 col-xl-3">
                            <div class="card h-100">
                                <div class="card-body">
                                    <span class="d-block fw-semibold text-muted">Chuyến sắp tới</span>
                                    <h3 class="card-title mb-2"><c:out value="${ticketOverview.upcomingCount}" /></h3>
                                    <small class="text-muted">Khởi hành trong tương lai</small>
                                </div>
                            </div>
                        </div>
                        <div class="col-sm-6 col-xl-3">
                            <div class="card h-100">
                                <div class="card-body">
                                    <span class="d-block fw-semibold text-muted">Chuyến đã đi</span>
                                    <h3 class="card-title mb-2"><c:out value="${ticketOverview.pastCount}" /></h3>
                                    <small class="text-muted">Đã hoàn thành hoặc quá hạn</small>
                                </div>
                            </div>
                        </div>
                        <div class="col-sm-6 col-xl-3">
                            <div class="card h-100">
                                <div class="card-body">
                                    <span class="d-block fw-semibold text-muted">Trạng thái vé</span>
                                    <ul class="list-unstyled mb-0 mt-2">
                                        <c:choose>
                                            <c:when test="${empty statusCounts}">
                                                <li class="text-muted">Chưa có dữ liệu</li>
                                            </c:when>
                                            <c:otherwise>
                                                <c:forEach var="entry" items="${statusCounts}">
                                                    <li class="d-flex justify-content-between align-items-center">
                                                        <span><c:out value="${entry.key}" /></span>
                                                        <span class="badge bg-label-primary"><c:out value="${entry.value}" /></span>
                                                    </li>
                                                </c:forEach>
                                            </c:otherwise>
                                        </c:choose>
                                    </ul>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="card mb-4">
                        <div class="card-header d-flex flex-wrap justify-content-between align-items-center gap-2">
                            <div>
                                <h5 class="mb-1">Chuyến sắp tới</h5>
                                <small class="text-muted">Bao gồm các vé có thời gian khởi hành trong tương lai</small>
                            </div>
                        </div>
                        <div class="card-body p-0">
                            <c:choose>
                                <c:when test="${empty ticketOverview.upcomingTickets}">
                                    <div class="p-4 text-center text-muted">Bạn chưa có chuyến đi sắp tới</div>
                                </c:when>
                                <c:otherwise>
                                    <div class="table-responsive">
                                        <table class="table table-hover mb-0">
                                            <thead class="table-light">
                                            <tr>
                                                <th>Tuyến</th>
                                                <th>Khởi hành</th>
                                                <th>Ghế</th>
                                                <th>Trạng thái</th>
                                                <th>Vé</th>
                                            </tr>
                                            </thead>
                                            <tbody>
                                            <c:forEach var="ticket" items="${ticketOverview.upcomingTickets}">
                                                <tr>
                                                    <td>
                                                        <div class="fw-semibold"><c:out value="${ticket.routeLabel}" /></div>
                                                        <small class="text-muted">Mã đặt vé: <c:out value="${ticket.ticketNumber}" /></small>
                                                    </td>
                                                    <td><c:out value="${ticket.departureDisplay}" /></td>
                                                    <td><c:out value="${ticket.seatDisplay}" /></td>
                                                    <td><span class="badge ${ticket.statusBadgeClass}"><c:out value="${ticket.statusLabel}" /></span></td>
                                                    <td>
                                                        <small class="text-muted">Mã vé: <c:out value="${ticket.ticketId}" /></small>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                            </tbody>
                                        </table>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>

                    <div class="card">
                        <div class="card-header d-flex flex-wrap justify-content-between align-items-center gap-2">
                            <div>
                                <h5 class="mb-1">Chuyến đã đi hoặc đã hủy</h5>
                                <small class="text-muted">Theo dõi các vé đã hoàn thành</small>
                            </div>
                        </div>
                        <div class="card-body p-0">
                            <c:choose>
                                <c:when test="${empty ticketOverview.pastTickets}">
                                    <div class="p-4 text-center text-muted">Bạn chưa có lịch sử vé</div>
                                </c:when>
                                <c:otherwise>
                                    <div class="table-responsive">
                                        <table class="table table-hover mb-0">
                                            <thead class="table-light">
                                            <tr>
                                                <th>Tuyến</th>
                                                <th>Khởi hành</th>
                                                <th>Ghế</th>
                                                <th>Trạng thái</th>
                                                <th>Liên hệ</th>
                                            </tr>
                                            </thead>
                                            <tbody>
                                            <c:forEach var="ticket" items="${ticketOverview.pastTickets}">
                                                <tr>
                                                    <td>
                                                        <div class="fw-semibold"><c:out value="${ticket.routeLabel}" /></div>
                                                        <small class="text-muted">Mã vé: <c:out value="${ticket.ticketNumber}" /></small>
                                                    </td>
                                                    <td><c:out value="${ticket.departureDisplay}" /></td>
                                                    <td><c:out value="${ticket.historicalSeatDisplay}" /></td>
                                                    <td><span class="badge ${ticket.statusBadgeClass}"><c:out value="${ticket.statusLabel}" /></span></td>
                                                    <td>
                                                        <small class="text-muted">Liên hệ: <c:out value="${ticket.preferredContact}" /></small>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                            </tbody>
                                        </table>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<%@ include file="includes/fragment-customer-scripts.jspf" %>
</body>
</html>
