<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%
    String contextPath = request.getContextPath();
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null || !"Customer".equalsIgnoreCase(currentUser.getRole())) {
        response.sendRedirect(contextPath + "/login");
        return;
    }
    User profileUser = (User) request.getAttribute("profileUser");
    if (profileUser == null) {
        profileUser = currentUser;
    }
    String assetBase = contextPath + "/assets/sneat-1.0.0/assets";
    String vendorPath = assetBase + "/vendor";
    String cssPath = assetBase + "/css";
    String jsPath = assetBase + "/js";
    String imgPath = assetBase + "/img";

    String successMessage = (String) request.getAttribute("successMessage");
    String errorMessage = (String) request.getAttribute("errorMessage");

    String prefillFullName = (String) request.getAttribute("prefillFullName");
    String prefillPhone = (String) request.getAttribute("prefillPhone");
    String prefillAddress = (String) request.getAttribute("prefillAddress");

    String fullNameValue = prefillFullName != null ? prefillFullName : profileUser.getFullName();
    String phoneValue = prefillPhone != null ? prefillPhone : profileUser.getPhoneNumber();
    String addressValue = prefillAddress != null ? prefillAddress : profileUser.getAddress();


    String profileUpdateSuccess = (String) session.getAttribute("profileUpdateSuccess");
    if (profileUpdateSuccess != null) session.removeAttribute("profileUpdateSuccess");

    String reviewSuccess = (String) session.getAttribute("reviewSuccess");
    String reviewError = (String) session.getAttribute("reviewError");

    // Xóa ngay lập tức để thông báo không hiển thị lại khi refresh
    if (reviewSuccess != null) session.removeAttribute("reviewSuccess");
    if (reviewError != null) session.removeAttribute("reviewError");

    // Đặt lại các biến này vào request để JSTL có thể đọc dễ dàng hơn
    request.setAttribute("reviewSuccess", reviewSuccess);
    request.setAttribute("reviewError", reviewError);
    request.setAttribute("profileUpdateSuccess", profileUpdateSuccess);
    // =======================================================
%>
<!DOCTYPE html>
<html lang="vi" class="light-style layout-menu-fixed" dir="ltr" data-theme="theme-default"
      data-assets-path="<%= assetBase %>/" data-template="vertical-menu-template-free">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thông tin tài khoản</title>

    <link rel="icon" type="image/x-icon" href="<%= imgPath %>/favicon/favicon.ico" />

    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap&subset=latin-ext,vietnamese" rel="stylesheet" />

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
        <div class="layout-page">
            <div class="content-wrapper">
                <div class="container-xxl flex-grow-1 container-p-y">
                    <div class="d-flex align-items-center justify-content-between flex-wrap gap-2 mb-4">
                        <div>
                            <h4 class="fw-bold mb-1">Xin chào, <%= fullNameValue %></h4>
                            <p class="text-muted mb-0">Khách hàng · Mã: <%= currentUser.getEmployeeCode() != null ? currentUser.getEmployeeCode() : "Đang cập nhật" %></p>
                        </div>
                        <a href="<%= contextPath %>/homepage.jsp" class="btn btn-outline-secondary">
                            <i class="bx bx-chevron-left"></i> Quay lại trang chủ
                        </a>
                    </div>

                    <% if (successMessage != null) { %>
                        <div class="alert alert-success" role="alert"><%= successMessage %></div>
                    <% } %>
                    <% if (errorMessage != null) { %>
                        <div class="alert alert-danger" role="alert"><%= errorMessage %></div>
                    <% } %>

                    <div class="card mb-4">
                        <h5 class="card-header">Thông tin cá nhân</h5>
                        <div class="card-body">
                            <div class="d-flex align-items-start align-items-sm-center gap-4">
                                <div class="avatar avatar-xl">
                                    <span class="avatar-initial rounded-circle bg-warning text-white fs-3">
                                        <%= fullNameValue != null && !fullNameValue.isBlank() ? fullNameValue.substring(0, 1).toUpperCase() : "C" %>
                                    </span>
                                </div>
                                <div>
                                    <p class="mb-1 fw-semibold"><%= fullNameValue %></p>
                                    <p class="text-muted mb-0"><%= currentUser.getEmail() %></p>
                                </div>
                            </div>
                        </div>
                        <hr class="my-0" />
                        <div class="card-body">
                            <form id="customerProfileForm" method="post" action="<%= contextPath %>/customer/profile">
                                <div class="row">
                                    <div class="mb-3 col-md-6">
                                        <label for="fullName" class="form-label">Họ và tên</label>
                                        <input class="form-control" type="text" id="fullName" name="fullName" value="<%= fullNameValue != null ? fullNameValue : "" %>" required />
                                    </div>
                                    <div class="mb-3 col-md-6">
                                        <label for="email" class="form-label">Email</label>
                                        <input class="form-control" type="email" id="email" value="<%= currentUser.getEmail() %>" readonly />
                                    </div>
                                    <div class="mb-3 col-md-6">
                                        <label class="form-label" for="phoneNumber">Số điện thoại</label>
                                        <div class="input-group input-group-merge">
                                            <span class="input-group-text">VN (+84)</span>
                                            <input type="text" id="phoneNumber" name="phoneNumber" class="form-control" placeholder="0900 000 000" value="<%= phoneValue != null ? phoneValue : "" %>" required />
                                        </div>
                                    </div>
                                    <div class="mb-3 col-md-6">
                                        <label for="address" class="form-label">Địa chỉ</label>
                                        <input type="text" class="form-control" id="address" name="address" placeholder="Nhập địa chỉ" value="<%= addressValue != null ? addressValue : "" %>" />
                                    </div>
                                </div>
                                <div class="mt-2 d-flex gap-2">
                                    <button type="submit" class="btn btn-warning text-white">Lưu thay đổi</button>
                                    <a href="<%= contextPath %>/homepage.jsp" class="btn btn-outline-secondary">Hủy</a>
                                </div>
                            </form>
                        </div>
                    </div>

                    <div class="card-body">
                        <c:choose>
                            <c:when test="${not empty userTickets}">
                                <div class="table-responsive text-nowrap">
                                    <table class="table table-hover">
                                        <thead>
                                        <tr>
                                            <th>Mã vé</th>
                                            <th>Tuyến đường</th>
                                            <th>Ghế</th>
                                            <th>Giờ khởi hành</th>
                                            <th>Ngày đặt</th>
                                            <th>Trạng thái</th>
                                            <th>Thao tác</th> <%-- Cột thao tác chung --%>
                                        </tr>
                                        </thead>
                                        <tbody class="table-border-bottom-0">
                                        <c:forEach var="ticket" items="${userTickets}">
                                            <tr>
                                                <td><i class="bx bx-bus-marker bx-sm text-info me-3"></i> <strong>${ticket.ticketNumber}</strong></td>
                                                <td>${ticket.routeDetails}</td>
                                                <td><span class="badge bg-label-info me-1">${ticket.seatNumber}</span></td>
                                                <td>${ticket.formattedDepartureTime}</td>
                                                <td>${ticket.formattedIssuedDate}</td>
                                                <td>
                                                        <%-- Logic hiển thị trạng thái --%>
                                                    <c:choose>
                                                        <c:when test="${ticket.ticketStatus eq 'Issued'}">
                                                            <c:set var="badgeClass" value="bg-label-success" />
                                                        </c:when>
                                                        <c:when test="${ticket.ticketStatus eq 'Cancelled'}">
                                                            <c:set var="badgeClass" value="bg-label-danger" />
                                                        </c:when>
                                                        <c:when test="${ticket.ticketStatus eq 'Used'}">
                                                            <c:set var="badgeClass" value="bg-label-primary" />
                                                        </c:when>
                                                        <c:otherwise>
                                                            <c:set var="badgeClass" value="bg-label-warning" />
                                                        </c:otherwise>
                                                    </c:choose>
                                                    <span class="badge ${badgeClass} me-1">${ticket.ticketStatus}</span>
                                                </td>
                                                <td> <%-- CỘT NÚT HÀNH ĐỘNG --%>
                                                    <div class="d-flex gap-2">
                                                            <%-- 1. NÚT XEM CHI TIẾT (Detail) --%>
                                                        <button type="button" class="btn btn-sm btn-outline-info btn-icon"
                                                                data-bs-toggle="modal"
                                                                data-bs-target="#ticketDetailModal"
                                                                data-ticket-number="${ticket.ticketNumber}"
                                                                data-issued-date="${ticket.formattedIssuedDate}"
                                                                data-depart-time="${ticket.formattedDepartureTime}"
                                                                data-price="${ticket.formattedPrice}"
                                                                data-origin="${ticket.origin}"
                                                                data-destination="${ticket.destination}"
                                                                data-seat-number="${ticket.seatNumber}"
                                                                data-operator-code="${ticket.vehicleOperatorEmployeeCode}"
                                                                data-status="${ticket.ticketStatus}"
                                                                title="Chi tiết vé"
                                                        >
                                                            <i class='bx bx-search-alt-2'></i>
                                                        </button>

                                                            <%-- 2. NÚT ĐÁNH GIÁ (Review) - CHỈ HIỂN THỊ KHI STATUS LÀ "Used" --%>
                                                        <c:if test="${ticket.ticketStatus eq 'Used'}">
                                                            <a href="<%= contextPath %>/customer/review?tripId=${ticket.tripId}"
                                                               class="btn btn-sm btn-outline-warning btn-icon"
                                                               title="Đánh giá chuyến đi">
                                                                <i class='bx bxs-star'></i>
                                                            </a>
                                                        </c:if>
                                                    </div>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                        </tbody>
                                    </table>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <p class="text-muted">Bạn chưa mua vé xe nào.</p>
                            </c:otherwise>
                        </c:choose>
                    </div>

                    <div class="card">
                        <h5 class="card-header">Bảo mật</h5>
                        <div class="card-body">
                            <p class="mb-3 text-muted">Nếu bạn muốn đổi mật khẩu, vui lòng sử dụng chức năng "Quên mật khẩu" tại trang đăng nhập.</p>
                            <a class="btn btn-outline-primary" href="<%= contextPath %>/forgot-password">Yêu cầu đặt lại mật khẩu</a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="ticketDetailModal" tabindex="-1" aria-labelledby="ticketDetailModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="ticketDetailModalLabel">Chi tiết vé xe</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <dl class="row">
                    <dt class="col-sm-5">Mã vé:</dt>
                    <dd class="col-sm-7" id="detail-ticket-number"></dd>

                    <dt class="col-sm-5">Tuyến đường:</dt>
                    <dd class="col-sm-7" id="detail-route"></dd>

                    <dt class="col-sm-5">Giờ khởi hành:</dt>
                    <dd class="col-sm-7" id="detail-depart-time"></dd>

                    <dt class="col-sm-5">Ngày đặt (Phát hành):</dt>
                    <dd class="col-sm-7" id="detail-issued-date"></dd>

                    <dt class="col-sm-5">Giá vé:</dt>
                    <dd class="col-sm-7 text-success" id="detail-price"></dd>

                    <dt class="col-sm-5">Ghế số:</dt>
                    <dd class="col-sm-7" id="detail-seat-number"></dd>

                    <dt class="col-sm-5">Trạng thái:</dt>
                    <dd class="col-sm-7" id="detail-status"></dd>

                    <dt class="col-sm-5">Mã nhân viên lái xe:</dt>
                    <dd class="col-sm-7" id="detail-operator-code"></dd>
                </dl>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Đóng</button>
            </div>
        </div>
    </div>
</div>

<c:if test="${not empty profileUpdateSuccess}">
    <div class="alert alert-success alert-dismissible" role="alert">
        <i class='bx bx-check-circle me-1'></i>
            ${profileUpdateSuccess}
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    </div>
</c:if>

<c:if test="${not empty reviewSuccess}">
    <div class="alert alert-success alert-dismissible" role="alert">
        <i class='bx bx-check-circle me-1'></i>
            ${reviewSuccess}
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    </div>
</c:if>

<c:if test="${not empty reviewError || not empty errorMessage}">
    <div class="alert alert-danger alert-dismissible" role="alert">
        <i class='bx bx-error-alt me-1'></i>
        <c:choose>
            <c:when test="${not empty reviewError}">${reviewError}</c:when>
            <c:otherwise>${errorMessage}</c:otherwise>
        </c:choose>
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    </div>
</c:if>

<h4 class="fw-bold py-3 mb-4"><span class="text-muted fw-light">Khách hàng /</span> Thông tin cá nhân</h4>

<%-- JavaScript để điền dữ liệu vào modal chi tiết (đặt bên trong thẻ <script> trước </body>) --%>
<script>
    document.addEventListener('DOMContentLoaded', function() {
        const ticketDetailModal = document.getElementById('ticketDetailModal');

        if (ticketDetailModal) {
            ticketDetailModal.addEventListener('show.bs.modal', function (event) {
                const button = event.relatedTarget;

                // Trích xuất thông tin từ các thuộc tính data-bs-*
                const ticketNumber = button.getAttribute('data-ticket-number');
                const issuedDate = button.getAttribute('data-issued-date');
                const departTime = button.getAttribute('data-depart-time');
                const price = button.getAttribute('data-price');
                const origin = button.getAttribute('data-origin');
                const destination = button.getAttribute('data-destination');
                const seatNumber = button.getAttribute('data-seat-number');
                const operatorCode = button.getAttribute('data-operator-code');
                const status = button.getAttribute('data-status');

                // Cập nhật nội dung của modal.
                document.getElementById('detail-ticket-number').textContent = ticketNumber;
                document.getElementById('detail-route').textContent = origin + ' -> ' + destination;
                document.getElementById('detail-depart-time').textContent = departTime;
                document.getElementById('detail-issued-date').textContent = issuedDate;
                document.getElementById('detail-price').textContent = price;
                document.getElementById('detail-seat-number').textContent = seatNumber;
                document.getElementById('detail-operator-code').textContent = operatorCode;
                document.getElementById('detail-status').textContent = status;

                // Cập nhật tiêu đề modal
                document.getElementById('ticketDetailModalLabel').textContent = 'Chi tiết vé xe: ' + ticketNumber;
            });
        }
    });
</script>

<script src="<%= vendorPath %>/libs/popper/popper.js"></script>
<script src="<%= vendorPath %>/js/bootstrap.js"></script>
<script src="<%= vendorPath %>/js/menu.js"></script>
<script src="<%= jsPath %>/main.js"></script>
</body>
</html>
