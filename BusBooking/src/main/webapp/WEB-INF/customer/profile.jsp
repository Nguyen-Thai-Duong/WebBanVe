<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:if test="${empty profileView}">
    <c:redirect url="${contextPath}/login" />
</c:if>

<c:set var="assetBase" value="${contextPath}/assets/sneat-1.0.0/assets" />
<c:set var="vendorPath" value="${assetBase}/vendor" />
<c:set var="cssPath" value="${assetBase}/css" />
<c:set var="jsPath" value="${assetBase}/js" />
<c:set var="imgPath" value="${assetBase}/img" />

<c:set var="ticketOverview" value="${ticketOverview}" />
<c:set var="totalTickets" value="${empty ticketOverview ? 0 : ticketOverview.totalTickets}" />
<c:set var="upcomingCount" value="${empty ticketOverview ? 0 : ticketOverview.upcomingCount}" />
<c:set var="pastCount" value="${empty ticketOverview ? 0 : ticketOverview.pastCount}" />

<c:set var="fullNameValue" value="${profileForm.fullName}" />
<c:set var="initialLetter"
       value="${not empty fullNameValue ? fn:toUpperCase(fn:substring(fullNameValue, 0, 1)) : 'C'}" />
<c:set var="employeeCode"
       value="${not empty profileView.employeeCode ? profileView.employeeCode : 'Đang cập nhật'}" />

<!DOCTYPE html>
<html lang="vi" class="light-style layout-menu-fixed" dir="ltr" data-theme="theme-default"
      data-assets-path="${assetBase}/" data-template="vertical-menu-template-free">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thông tin tài khoản</title>

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
                            <h4 class="fw-bold mb-1">Xin chào, <c:out value="${not empty fullNameValue ? fullNameValue : 'Khách hàng'}" /></h4>
                            <p class="text-muted mb-0">Khách hàng · Mã: <c:out value="${employeeCode}" /></p>
                        </div>
                        <a href="${contextPath}/homepage.jsp" class="btn btn-outline-secondary">
                            <i class="bx bx-chevron-left"></i> Quay lại trang chủ
                        </a>
                    </div>

                    <c:if test="${not empty successMessage}">
                        <div class="alert alert-success" role="alert"><c:out value="${successMessage}" /></div>
                    </c:if>
                    <c:if test="${not empty errorMessage}">
                        <div class="alert alert-danger" role="alert"><c:out value="${errorMessage}" /></div>
                    </c:if>
                    <c:if test="${not empty validationErrors}">
                        <div class="alert alert-warning" role="alert">
                            <ul class="mb-0 ps-3">
                                <c:forEach var="err" items="${validationErrors}">
                                    <li><c:out value="${err}" /></li>
                                </c:forEach>
                            </ul>
                        </div>
                    </c:if>

                    <div class="row g-4 mb-4">
                        <div class="col-md-4">
                            <div class="card h-100">
                                <div class="card-body">
                                    <span class="text-muted fw-semibold">Tổng số vé</span>
                                    <h3 class="mt-2 mb-1"><c:out value="${totalTickets}" /></h3>
                                    <small class="text-muted">Bao gồm cả chuyến đã đi và sắp tới</small>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-4">
                            <div class="card h-100">
                                <div class="card-body">
                                    <span class="text-muted fw-semibold">Chuyến sắp tới</span>
                                    <h3 class="mt-2 mb-1 text-primary"><c:out value="${upcomingCount}" /></h3>
                                    <small class="text-muted">Những chuyến khởi hành trong tương lai</small>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-4">
                            <div class="card h-100">
                                <div class="card-body">
                                    <span class="text-muted fw-semibold">Chuyến đã hoàn thành</span>
                                    <h3 class="mt-2 mb-1 text-success"><c:out value="${pastCount}" /></h3>
                                    <small class="text-muted">Đã hoàn thành hoặc đã hủy</small>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="card mb-4">
                        <h5 class="card-header">Thông tin cá nhân</h5>
                        <div class="card-body">
                            <div class="d-flex align-items-start align-items-sm-center gap-4">
                                <div class="avatar avatar-xl">
                                    <span class="avatar-initial rounded-circle bg-warning text-white fs-3">
                                        <c:out value="${initialLetter}" />
                                    </span>
                                </div>
                                <div>
                                    <p class="mb-1 fw-semibold"><c:out value="${fullNameValue}" /></p>
                                    <p class="text-muted mb-0"><c:out value="${profileView.email}" /></p>
                                </div>
                            </div>
                        </div>
                        <hr class="my-0" />
                        <div class="card-body">
                            <form id="customerProfileForm" method="post" action="${contextPath}/app/customer/profile">
                                <div class="row">
                                    <div class="mb-3 col-md-6">
                                        <label for="fullName" class="form-label">Họ và tên</label>
                                        <input class="form-control" type="text" id="fullName" name="fullName" value="${fullNameValue}" required />
                                    </div>
                                    <div class="mb-3 col-md-6">
                                        <label for="email" class="form-label">Email</label>
                                        <input class="form-control" type="email" id="email" value="${profileView.email}" readonly />
                                    </div>
                                    <div class="mb-3 col-md-6">
                                        <label class="form-label" for="phoneNumber">Số điện thoại</label>
                                        <div class="input-group input-group-merge">
                                            <span class="input-group-text">VN (+84)</span>
                                            <input type="text" id="phoneNumber" name="phoneNumber" class="form-control" placeholder="0900 000 000" value="${profileForm.phoneNumber}" required />
                                        </div>
                                    </div>
                                    <div class="mb-3 col-md-6">
                                        <label for="address" class="form-label">Địa chỉ</label>
                                        <input type="text" class="form-control" id="address" name="address" placeholder="Nhập địa chỉ" value="${profileForm.address}" />
                                    </div>
                                </div>
                                <div class="mt-2 d-flex gap-2">
                                    <button type="submit" class="btn btn-warning text-white">Lưu thay đổi</button>
                                    <a href="${contextPath}/homepage.jsp" class="btn btn-outline-secondary">Hủy</a>
                                    <a href="${contextPath}/app/customer/tickets" class="btn btn-outline-primary">Vé của tôi</a>
                                </div>
                            </form>
                        </div>
                    </div>

                    <div class="card">
                        <h5 class="card-header">Bảo mật</h5>
                        <div class="card-body">
                            <p class="mb-3 text-muted">Nếu bạn muốn đổi mật khẩu, vui lòng sử dụng chức năng "Quên mật khẩu" tại trang đăng nhập.</p>
                            <a class="btn btn-outline-primary" href="${contextPath}/forgot-password">Yêu cầu đặt lại mật khẩu</a>
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
