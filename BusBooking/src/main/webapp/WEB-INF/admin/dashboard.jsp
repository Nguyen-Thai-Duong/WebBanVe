<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<c:set var="view" value="${adminView}" />
<c:set var="recentTickets" value="${requestScope.recentTickets}" />
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="assetBase" value="${contextPath}/assets/sneat-1.0.0/assets" />
<c:set var="vendorPath" value="${assetBase}/vendor" />
<c:set var="cssPath" value="${assetBase}/css" />
<c:set var="jsPath" value="${assetBase}/js" />
<c:set var="imgPath" value="${assetBase}/img" />
<c:set var="chartHasData" value="${not empty view and view.hasRevenueData}" />
<c:set var="chartLabelsJson" value="${not empty view ? view.revenueChartLabelsJson : '[]'}" />
<c:set var="chartValuesJson" value="${not empty view ? view.revenueChartValuesJson : '[]'}" />
<!DOCTYPE html>
<html lang="vi" class="light-style layout-menu-fixed" dir="ltr" data-theme="theme-default"
      data-assets-path="${assetBase}/" data-template="vertical-menu-template-free">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Bảng điều khiển quản trị</title>
    <%@ include file="includes/fragment-admin-head.jspf" %>
</head>
<body>
<div class="layout-wrapper layout-content-navbar">
    <div class="layout-container">
        <%@ include file="includes/sidebar.jspf" %>

        <div class="layout-page">
            <%@ include file="includes/navbar.jspf" %>

            <div class="content-wrapper">
                <div class="container-xxl flex-grow-1 container-p-y">
                    <div class="row g-4">
                        <%@ include file="includes/fragment-dashboard-cards.jspf" %>
                    </div>

                    <div class="row g-4 mt-1">
                        <div class="col-lg-7">
                            <div class="card h-100">
                                <div class="card-header d-flex justify-content-between align-items-center">
                                    <h5 class="mb-0">Xu hướng doanh thu theo tháng</h5>
                                    <small class="text-muted">6 tháng gần nhất</small>
                                </div>
                                <div class="card-body">
                                    <div id="revenueChart" style="min-height: 320px;"></div>
                                </div>
                            </div>
                        </div>
                        <div class="col-lg-5">
                            <div class="card h-100">
                                <div class="card-header d-flex justify-content-between align-items-center">
                                    <h5 class="mb-0">Doanh thu theo phương thức thanh toán</h5>
                                    <small class="text-muted">30 ngày</small>
                                </div>
                                <div class="card-body">
                                    <div class="table-responsive">
                                        <table class="table table-borderless align-middle mb-0">
                                            <thead>
                                                <tr>
                                                    <th>Phương thức</th>
                                                    <th class="text-end">Doanh thu</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                            <c:choose>
                                                <c:when test="${empty view or empty view.paymentSummaries}">
                                                    <tr>
                                                        <td colspan="2" class="text-center text-muted">Chưa có dữ liệu</td>
                                                    </tr>
                                                </c:when>
                                                <c:otherwise>
                                                    <c:forEach items="${view.paymentSummaries}" var="summary">
                                                        <tr>
                                                            <td><c:out value="${summary.methodLabel}" /></td>
                                                            <td class="text-end"><c:out value="${summary.amountLabel}" /></td>
                                                        </tr>
                                                    </c:forEach>
                                                </c:otherwise>
                                            </c:choose>
                                            </tbody>
                                        </table>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="row g-4 mt-1">
                        <div class="col-lg-5">
                            <div class="card h-100">
                                <div class="card-header d-flex justify-content-between align-items-center">
                                    <h5 class="mb-0">Tuyến bán chạy</h5>
                                    <small class="text-muted">90 ngày</small>
                                </div>
                                <div class="card-body">
                                    <div class="table-responsive">
                                        <table class="table table-borderless mb-0 align-middle">
                                            <thead>
                                                <tr>
                                                    <th>Tuyến</th>
                                                    <th class="text-end">Số vé</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                            <c:choose>
                                                <c:when test="${empty view or empty view.routeSummaries}">
                                                    <tr>
                                                        <td colspan="2" class="text-center text-muted">Chưa có dữ liệu</td>
                                                    </tr>
                                                </c:when>
                                                <c:otherwise>
                                                    <c:forEach items="${view.routeSummaries}" var="route">
                                                        <tr>
                                                            <td><c:out value="${route.routeLabel}" /></td>
                                                            <td class="text-end"><c:out value="${route.ticketCountLabel}" /></td>
                                                        </tr>
                                                    </c:forEach>
                                                </c:otherwise>
                                            </c:choose>
                                            </tbody>
                                        </table>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="col-lg-7">
                            <div class="card h-100">
                                <div class="card-header d-flex justify-content-between align-items-center">
                                    <h5 class="mb-0">Vé gần đây</h5>
                                    <a href="${contextPath}/admin/tickets" class="btn btn-sm btn-outline-primary">Xem tất cả</a>
                                </div>
                                <div class="card-body">
                                    <div class="table-responsive">
                                        <table class="table table-hover">
                                            <thead>
                                                <tr>
                                                    <th>#</th>
                                                    <th>Tuyến</th>
                                                    <th>Khởi hành</th>
                                                    <th>Khách hàng</th>
                                                    <th>Trạng thái</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                            <c:choose>
                                                <c:when test="${empty recentTickets}">
                                                    <tr>
                                                        <td colspan="5" class="text-center text-muted">Chưa có vé mới</td>
                                                    </tr>
                                                </c:when>
                                                <c:otherwise>
                                                    <c:forEach items="${recentTickets}" var="ticket">
                                                        <tr>
                                                            <td><c:out value="${ticket.ticketNumber}" /></td>
                                                            <td><c:out value="${empty ticket.routeLabel ? '-' : ticket.routeLabel}" /></td>
                                                            <td><c:out value="${ticket.departureDisplay}" /></td>
                                                            <td><c:out value="${ticket.preferredContact}" /></td>
                                                            <td><span class="badge ${ticket.statusBadgeClass}"><c:out value="${ticket.statusLabel}" /></span></td>
                                                        </tr>
                                                    </c:forEach>
                                                </c:otherwise>
                                            </c:choose>
                                            </tbody>
                                        </table>
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

<%@ include file="includes/fragment-admin-scripts.jspf" %>
<script>
    (function () {
        const chartElement = document.querySelector('#revenueChart');
        if (!chartElement || typeof ApexCharts === 'undefined') {
            return;
        }
        const hasData = <c:out value="${chartHasData ? 'true' : 'false'}" />;
        if (!hasData) {
            chartElement.innerHTML = '<p class="text-muted text-center mb-0 pt-5 pb-5">Chưa có dữ liệu để hiển thị</p>';
            return;
        }
        const labels = <c:out value="${chartLabelsJson}" escapeXml="false" />;
        const values = <c:out value="${chartValuesJson}" escapeXml="false" />;
        const options = {
            chart: {
                type: 'area',
                height: 320,
                toolbar: { show: false }
            },
            dataLabels: { enabled: false },
            series: [{ name: 'Doanh thu', data: values }],
            xaxis: {
                categories: labels,
                labels: {
                    rotate: -45,
                    style: {
                        fontSize: '12px'
                    }
                }
            },
            stroke: { curve: 'smooth', width: 3 },
            colors: ['#696cff'],
            fill: {
                type: 'gradient',
                gradient: {
                    shadeIntensity: 0.35,
                    opacityFrom: 0.6,
                    opacityTo: 0,
                    stops: [0, 90, 100]
                }
            },
            yaxis: {
                labels: {
                    formatter: function (value) {
                        return new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND', maximumFractionDigits: 0 }).format(value);
                    }
                }
            },
            tooltip: {
                x: { show: true },
                y: {
                    formatter: function (value) {
                        return new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(value);
                    }
                }
            }
        };
        const chart = new ApexCharts(chartElement, options);
        chart.render();
    })();
</script>
</body>
</html>
