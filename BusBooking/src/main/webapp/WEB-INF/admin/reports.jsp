<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="dto.dashboard.AdminDashboardSnapshot" %>
<%@ page import="dto.dashboard.MonthlyRevenue" %>
<%@ page import="dto.dashboard.PaymentMethodSummary" %>
<%@ page import="dto.dashboard.RouteSalesSummary" %>
<%@ page import="dto.ticket.TicketSummary" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.util.Collections" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Locale" %>
<%@ page import="java.util.Map" %>
<%
    String contextPath = request.getContextPath();
    String assetBase = contextPath + "/assets/sneat-1.0.0/assets";
    String vendorPath = assetBase + "/vendor";
    String cssPath = assetBase + "/css";
    String jsPath = assetBase + "/js";
    String imgPath = assetBase + "/img";
    request.setAttribute("activeMenu", "reports");
    request.setAttribute("navbarSearchPlaceholder", "Lọc báo cáo...");

    AdminDashboardSnapshot snapshot = (AdminDashboardSnapshot) request.getAttribute("dashboardSnapshot");
    Map<String, Long> ticketStatusCounts = (Map<String, Long>) request.getAttribute("ticketStatusCounts");
    List<MonthlyRevenue> monthlyRevenue = (List<MonthlyRevenue>) request.getAttribute("monthlyRevenue");
    List<PaymentMethodSummary> paymentSummaries = (List<PaymentMethodSummary>) request.getAttribute("paymentSummaries");
    List<RouteSalesSummary> topRoutes = (List<RouteSalesSummary>) request.getAttribute("topRoutes");
    List<TicketSummary> recentTickets = (List<TicketSummary>) request.getAttribute("recentTickets");

    int rangeDays = request.getAttribute("reportRangeDays") != null ? (Integer) request.getAttribute("reportRangeDays") : 90;
    int revenueMonths = request.getAttribute("revenueMonths") != null ? (Integer) request.getAttribute("revenueMonths") : 12;

    long supportOpen = request.getAttribute("supportOpenCount") != null ? (Long) request.getAttribute("supportOpenCount") : 0L;
    long supportInProgress = request.getAttribute("supportInProgressCount") != null ? (Long) request.getAttribute("supportInProgressCount") : 0L;
    long supportClosed = request.getAttribute("supportClosedCount") != null ? (Long) request.getAttribute("supportClosedCount") : 0L;

    Locale locale = new Locale("vi", "VN");
    NumberFormat currencyFormat = NumberFormat.getCurrencyInstance(locale);
    NumberFormat numberFormat = NumberFormat.getIntegerInstance(locale);
    DateTimeFormatter dateTimeFormatter = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");

    if (monthlyRevenue == null) {
        monthlyRevenue = Collections.emptyList();
    }
    if (paymentSummaries == null) {
        paymentSummaries = Collections.emptyList();
    }
    if (topRoutes == null) {
        topRoutes = Collections.emptyList();
    }
    if (recentTickets == null) {
        recentTickets = Collections.emptyList();
    }

    long issuedCount = ticketStatusCounts != null && ticketStatusCounts.get("Issued") != null ? ticketStatusCounts.get("Issued") : 0L;
    long usedCount = ticketStatusCounts != null && ticketStatusCounts.get("Used") != null ? ticketStatusCounts.get("Used") : 0L;
    long cancelledCount = ticketStatusCounts != null && ticketStatusCounts.get("Cancelled") != null ? ticketStatusCounts.get("Cancelled") : 0L;
    long totalTicketCount = issuedCount + usedCount + cancelledCount;

    BigDecimal totalRevenue = snapshot != null && snapshot.getTotalRevenue() != null ? snapshot.getTotalRevenue() : BigDecimal.ZERO;
    BigDecimal recentRevenue = snapshot != null && snapshot.getRecentRevenue() != null ? snapshot.getRecentRevenue() : BigDecimal.ZERO;

    StringBuilder monthlyLabelsBuilder = new StringBuilder("[");
    StringBuilder monthlyValuesBuilder = new StringBuilder("[");
    for (int i = monthlyRevenue.size() - 1; i >= 0; i--) {
        MonthlyRevenue entry = monthlyRevenue.get(i);
        String label = entry.getPeriod();
        BigDecimal amount = entry.getAmount() != null ? entry.getAmount() : BigDecimal.ZERO;
        monthlyLabelsBuilder.append('"').append(label).append('"');
        monthlyValuesBuilder.append(amount);
        if (i > 0) {
            monthlyLabelsBuilder.append(',');
            monthlyValuesBuilder.append(',');
        }
    }
    monthlyLabelsBuilder.append(']');
    monthlyValuesBuilder.append(']');
    String monthlyRevenueLabels = monthlyLabelsBuilder.toString();
    String monthlyRevenueValues = monthlyValuesBuilder.toString();

    StringBuilder paymentLabelsBuilder = new StringBuilder("[");
    StringBuilder paymentValuesBuilder = new StringBuilder("[");
    for (int i = 0; i < paymentSummaries.size(); i++) {
        PaymentMethodSummary summary = paymentSummaries.get(i);
        String label = summary.getMethod() != null ? summary.getMethod() : "Khác";
        BigDecimal amount = summary.getNetAmount() != null ? summary.getNetAmount() : BigDecimal.ZERO;
        paymentLabelsBuilder.append('"').append(label).append('"');
        paymentValuesBuilder.append(amount);
        if (i < paymentSummaries.size() - 1) {
            paymentLabelsBuilder.append(',');
            paymentValuesBuilder.append(',');
        }
    }
    paymentLabelsBuilder.append(']');
    paymentValuesBuilder.append(']');
    String paymentLabelsJson = paymentLabelsBuilder.toString();
    String paymentValuesJson = paymentValuesBuilder.toString();

    String monthlyRevenueLabelsEscaped = monthlyRevenueLabels.replace("\\", "\\\\").replace("'", "\\'");
    String monthlyRevenueValuesEscaped = monthlyRevenueValues.replace("\\", "\\\\").replace("'", "\\'");
    String paymentLabelsEscaped = paymentLabelsJson.replace("\\", "\\\\").replace("'", "\\'");
    String paymentValuesEscaped = paymentValuesJson.replace("\\", "\\\\").replace("'", "\\'");
%>
<!DOCTYPE html>
<html lang="vi" class="light-style layout-menu-fixed" dir="ltr" data-theme="theme-default"
      data-assets-path="<%= assetBase %>/" data-template="vertical-menu-template-free">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Báo cáo hoạt động</title>

    <link rel="icon" type="image/x-icon" href="<%= imgPath %>/favicon/favicon.ico" />

    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
    <link href="https://fonts.googleapis.com/css2?family=Public+Sans:wght@300;400;500;600;700&display=swap" rel="stylesheet" />

    <link rel="stylesheet" href="<%= vendorPath %>/fonts/boxicons.css" />
    <link rel="stylesheet" href="<%= vendorPath %>/css/core.css" class="template-customizer-core-css" />
    <link rel="stylesheet" href="<%= vendorPath %>/css/theme-default.css" class="template-customizer-theme-css" />
    <link rel="stylesheet" href="<%= cssPath %>/demo.css" />
    <link rel="stylesheet" href="<%= vendorPath %>/libs/perfect-scrollbar/perfect-scrollbar.css" />

    <script src="<%= vendorPath %>/js/helpers.js"></script>
    <script src="<%= jsPath %>/config.js"></script>
</head>
<body>
<div class="layout-wrapper layout-content-navbar">
    <div class="layout-container">
        <%@ include file="includes/sidebar.jspf" %>

        <div class="layout-page">
            <%@ include file="includes/navbar.jspf" %>

            <div class="content-wrapper">
                <div class="container-xxl flex-grow-1 container-p-y">
                    <div class="d-flex flex-wrap justify-content-between align-items-center mb-4">
                        <div>
                            <h4 class="mb-1">Báo cáo hoạt động</h4>
                            <p class="text-muted mb-0">Tổng hợp doanh thu, vé và hỗ trợ khách hàng trong <%= rangeDays %> ngày gần nhất.</p>
                        </div>
                        <form class="d-flex align-items-center gap-2" method="get" action="<%= contextPath %>/admin/reports">
                            <div>
                                <label for="range" class="form-label mb-1">Khoảng thời gian (ngày)</label>
                                <select class="form-select" id="range" name="range" onchange="this.form.submit()">
                                    <option value="30" <%= rangeDays == 30 ? "selected" : "" %>>30</option>
                                    <option value="60" <%= rangeDays == 60 ? "selected" : "" %>>60</option>
                                    <option value="90" <%= rangeDays == 90 ? "selected" : "" %>>90</option>
                                    <option value="180" <%= rangeDays == 180 ? "selected" : "" %>>180</option>
                                </select>
                            </div>
                            <div>
                                <label for="months" class="form-label mb-1">Số tháng hiển thị</label>
                                <select class="form-select" id="months" name="months" onchange="this.form.submit()">
                                    <option value="6" <%= revenueMonths == 6 ? "selected" : "" %>>6</option>
                                    <option value="12" <%= revenueMonths == 12 ? "selected" : "" %>>12</option>
                                    <option value="18" <%= revenueMonths == 18 ? "selected" : "" %>>18</option>
                                </select>
                            </div>
                        </form>
                    </div>

                    <div class="row g-4 mb-4">
                        <div class="col-lg-4">
                            <div class="card">
                                <div class="card-body">
                                    <span class="text-muted">Doanh thu tích lũy</span>
                                    <h4 class="my-2"><%= currencyFormat.format(totalRevenue) %></h4>
                                    <small class="text-muted">Tổng tất cả giao dịch</small>
                                </div>
                            </div>
                        </div>
                        <div class="col-lg-4">
                            <div class="card">
                                <div class="card-body">
                                    <span class="text-muted">Doanh thu <%= rangeDays %> ngày</span>
                                    <h4 class="my-2"><%= currencyFormat.format(recentRevenue) %></h4>
                                    <small class="text-muted">Bao gồm hoàn/huỷ</small>
                                </div>
                            </div>
                        </div>
                        <div class="col-lg-4">
                            <div class="card">
                                <div class="card-body">
                                    <span class="text-muted">Vé theo trạng thái</span>
                                    <div class="d-flex justify-content-between mt-2">
                                        <span class="badge bg-label-success">Đã dùng: <%= numberFormat.format(usedCount) %></span>
                                        <span class="badge bg-label-warning">Chưa dùng: <%= numberFormat.format(issuedCount) %></span>
                                        <span class="badge bg-label-danger">Huỷ: <%= numberFormat.format(cancelledCount) %></span>
                                    </div>
                                    <small class="text-muted">Tổng: <%= numberFormat.format(totalTicketCount) %> vé</small>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="row g-4">
                        <div class="col-xl-7">
                            <div class="card h-100">
                                <div class="card-header d-flex justify-content-between align-items-center">
                                    <h5 class="mb-0">Biểu đồ doanh thu theo tháng</h5>
                                    <small class="text-muted"><%= revenueMonths %> tháng gần nhất</small>
                                </div>
                                <div class="card-body">
                                    <div id="reportsRevenueChart" style="min-height: 360px"></div>
                                </div>
                            </div>
                        </div>
                        <div class="col-xl-5">
                            <div class="card h-100">
                                <div class="card-header d-flex justify-content-between align-items-center">
                                    <h5 class="mb-0">Cơ cấu phương thức thanh toán</h5>
                                    <small class="text-muted"><%= rangeDays %> ngày</small>
                                </div>
                                <div class="card-body">
                                    <div id="paymentMethodChart" style="min-height: 360px"></div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="row g-4 mt-1">
                        <div class="col-xl-6">
                            <div class="card">
                                <div class="card-header">
                                    <h5 class="mb-0">Tuyến bán chạy</h5>
                                </div>
                                <div class="card-body">
                                    <div class="table-responsive">
                                        <table class="table table-striped align-middle">
                                            <thead>
                                                <tr>
                                                    <th>#</th>
                                                    <th>Tuyến</th>
                                                    <th class="text-end">Số vé</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                            <%
                                                if (topRoutes.isEmpty()) {
                                            %>
                                                <tr>
                                                    <td colspan="3" class="text-center text-muted">Chưa có dữ liệu</td>
                                                </tr>
                                            <%
                                                } else {
                                                    int index = 1;
                                                    for (RouteSalesSummary route : topRoutes) {
                                            %>
                                                <tr>
                                                    <td><%= index++ %></td>
                                                    <td><%= (route.getOrigin() != null ? route.getOrigin() : "?") + " → " + (route.getDestination() != null ? route.getDestination() : "?") %></td>
                                                    <td class="text-end"><%= numberFormat.format(route.getTicketCount()) %></td>
                                                </tr>
                                            <%
                                                    }
                                                }
                                            %>
                                            </tbody>
                                        </table>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="col-xl-6">
                            <div class="card">
                                <div class="card-header">
                                    <h5 class="mb-0">Tổng hợp hỗ trợ khách hàng</h5>
                                </div>
                                <div class="card-body">
                                    <div class="table-responsive">
                                        <table class="table table-borderless align-middle mb-0">
                                            <tbody>
                                            <tr>
                                                <td>
                                                    <span class="badge bg-label-info">Đang mở</span>
                                                </td>
                                                <td class="text-end"><%= numberFormat.format(supportOpen) %></td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <span class="badge bg-label-warning">Đang xử lý</span>
                                                </td>
                                                <td class="text-end"><%= numberFormat.format(supportInProgress) %></td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <span class="badge bg-label-success">Đã đóng</span>
                                                </td>
                                                <td class="text-end"><%= numberFormat.format(supportClosed) %></td>
                                            </tr>
                                            </tbody>
                                        </table>
                                    </div>
                                    <div class="mt-3">
                                        <span class="text-muted small">Liên hệ đội hỗ trợ để xem chi tiết từng yêu cầu.</span>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="card mt-4">
                        <div class="card-header d-flex justify-content-between align-items-center">
                            <h5 class="mb-0">Vé phát hành gần đây</h5>
                            <a class="btn btn-sm btn-outline-primary" href="<%= contextPath %>/admin/tickets">Quản lý vé</a>
                        </div>
                        <div class="card-body">
                            <div class="table-responsive">
                                <table class="table table-hover">
                                    <thead>
                                        <tr>
                                            <th>Mã vé</th>
                                            <th>Tuyến</th>
                                            <th>Khởi hành</th>
                                            <th>Khách hàng</th>
                                            <th>Trạng thái</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                    <%
                                        if (recentTickets.isEmpty()) {
                                    %>
                                        <tr>
                                            <td colspan="5" class="text-center text-muted">Chưa có vé mới trong giai đoạn này</td>
                                        </tr>
                                    <%
                                        } else {
                                            for (TicketSummary ticket : recentTickets) {
                                                String departure = ticket.getDepartureTime() != null ? ticket.getDepartureTime().format(dateTimeFormatter) : "-";
                                                String status = ticket.getTicketStatus() != null ? ticket.getTicketStatus() : "N/A";
                                                String badgeClass = "bg-label-primary";
                                                if ("Used".equalsIgnoreCase(status)) {
                                                    badgeClass = "bg-label-success";
                                                } else if ("Cancelled".equalsIgnoreCase(status)) {
                                                    badgeClass = "bg-label-danger";
                                                } else if ("Issued".equalsIgnoreCase(status)) {
                                                    badgeClass = "bg-label-warning";
                                                }
                                                String customerLabel;
                                                if (ticket.getCustomerName() != null && !ticket.getCustomerName().isBlank()) {
                                                    customerLabel = ticket.getCustomerName();
                                                } else if (ticket.getCustomerPhone() != null && !ticket.getCustomerPhone().isBlank()) {
                                                    customerLabel = ticket.getCustomerPhone();
                                                } else if (ticket.getGuestPhone() != null && !ticket.getGuestPhone().isBlank()) {
                                                    customerLabel = ticket.getGuestPhone();
                                                } else if (ticket.getGuestEmail() != null && !ticket.getGuestEmail().isBlank()) {
                                                    customerLabel = ticket.getGuestEmail();
                                                } else {
                                                    customerLabel = "Khách lẻ";
                                                }
                                    %>
                                        <tr>
                                            <td><%= ticket.getTicketNumber() %></td>
                                            <td><%= ticket.getRouteLabel() != null ? ticket.getRouteLabel() : "-" %></td>
                                            <td><%= departure %></td>
                                            <td><%= customerLabel %></td>
                                            <td><span class="badge <%= badgeClass %>"><%= status %></span></td>
                                        </tr>
                                    <%
                                            }
                                        }
                                    %>
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

<script src="<%= vendorPath %>/libs/popper/popper.js"></script>
<script src="<%= vendorPath %>/js/bootstrap.js"></script>
<script src="<%= vendorPath %>/js/menu.js"></script>
<script src="<%= vendorPath %>/libs/apex-charts/apexcharts.js"></script>
<script src="<%= jsPath %>/main.js"></script>
<script>
    (function () {
        const revenueChartEl = document.querySelector('#reportsRevenueChart');
        if (revenueChartEl && typeof ApexCharts !== 'undefined') {
            const revenueLabels = JSON.parse('<%= monthlyRevenueLabelsEscaped %>');
            const revenueValues = JSON.parse('<%= monthlyRevenueValuesEscaped %>');
            if (Array.isArray(revenueLabels) && revenueLabels.length > 0) {
                const revenueOptions = {
                    chart: {
                        type: 'bar',
                        height: 360,
                        toolbar: { show: false }
                    },
                    series: [{ name: 'Doanh thu', data: revenueValues }],
                    plotOptions: {
                        bar: {
                            borderRadius: 6,
                            columnWidth: '55%'
                        }
                    },
                    dataLabels: { enabled: false },
                    colors: ['#7367f0'],
                    xaxis: {
                        categories: revenueLabels,
                        labels: { rotate: -45 }
                    },
                    yaxis: {
                        labels: {
                            formatter: function (value) {
                                return new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND', maximumFractionDigits: 0 }).format(value);
                            }
                        }
                    },
                    tooltip: {
                        y: {
                            formatter: function (value) {
                                return new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(value);
                            }
                        }
                    }
                };
                const reportsRevenueChart = new ApexCharts(revenueChartEl, revenueOptions);
                reportsRevenueChart.render();
            } else {
                revenueChartEl.innerHTML = '<p class="text-muted text-center pt-5 pb-5">Chưa có dữ liệu để hiển thị</p>';
            }
        }

        const paymentChartEl = document.querySelector('#paymentMethodChart');
        if (paymentChartEl && typeof ApexCharts !== 'undefined') {
            const paymentLabels = JSON.parse('<%= paymentLabelsEscaped %>');
            const paymentValues = JSON.parse('<%= paymentValuesEscaped %>');
            if (Array.isArray(paymentLabels) && paymentLabels.length > 0) {
                const paymentOptions = {
                    chart: {
                        type: 'donut',
                        height: 360
                    },
                    labels: paymentLabels,
                    series: paymentValues,
                    dataLabels: { enabled: true },
                    legend: { position: 'bottom' },
                    tooltip: {
                        y: {
                            formatter: function (value) {
                                return new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(value);
                            }
                        }
                    }
                };
                const paymentChart = new ApexCharts(paymentChartEl, paymentOptions);
                paymentChart.render();
            } else {
                paymentChartEl.innerHTML = '<p class="text-muted text-center pt-5 pb-5">Chưa có dữ liệu</p>';
            }
        }
    })();
</script>
</body>
</html>
