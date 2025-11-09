<%-- 
    Document   : checkout
    Created on : Nov 9, 2025, 1:40:14 AM
    Author     : Tran Quang Duyen
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<%-- 
  GIẢ ĐỊNH:
  1. Servlet đã set "checkoutBookings" (List<BookingAdminView>)
  2. Servlet đã set "checkoutBookingIds" (Chuỗi "123,124")
--%>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Điền thông tin</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css" />
        <style>
            body {
                background-color: #f4f7f6;
            }
        </style>
    </head>
    <body>
        <div class="container my-4 my-md-5">
            <div class="row justify-content-center">
                <div class="col-lg-10">

                    <div class="progress mb-4" style="height: 20px;">
                        <div class="progress-bar bg-success" role="progressbar" style="width: 100%;" aria-valuenow="100" aria-valuemin="0" aria-valuemax="100">
                            Bước 2: Điền thông tin & Thanh toán
                        </div>
                    </div>

                    <div class="row g-4">
                        <div class="col-lg-7">
                            <div class="card shadow-sm border-0 rounded-3">
                                <div class="card-body p-4 p-md-5">
                                    <h3 class="card-title mb-4">Thông tin hành khách</h3>

                                    <form action="${pageContext.request.contextPath}/process-payment" method="POST">

                                        <input type="hidden" name="bookingIds" value="${checkoutBookingIds}" />

                                        <div class="mb-3">
                                            <label for="fullName" class="form-label">Họ và tên</label>
                                            <input type="text" class="form-control" id="fullName" name="fullName" value="" required>
                                        </div>
                                        <div class="mb-3">
                                            <label for="email" class="form-label">Email</label>
                                            <input type="email" class="form-control" id="email" name="email" value="" required>
                                        </div>
                                        <div class="mb-3">
                                            <label for="phone" class="form-label">Số điện thoại</label>
                                            <input type="tel" class="form-control" id="phone" name="phone" value="" required>
                                        </div>

                                        <hr class="my-4">

                                        <h4 class="mb-3">Phương thức thanh toán</h4>
                                        <div class="form-check">
                                            <input class="form-check-input" type="radio" name="paymentMethod" id="payOnArrival" value="COD" checked>
                                            <label class="form-check-label" for="payOnArrival">
                                                Thanh toán khi lên xe
                                            </label>
                                        </div>
                                        <button type="submit" class="btn btn-primary btn-lg w-100 mt-4">
                                            Xác nhận đặt vé
                                        </button>
                                    </form>
                                </div>
                            </div>
                        </div>

                        <div class="col-lg-5">
                            <div class="card shadow-sm border-0 rounded-3 position-sticky" style="top: 20px;">
                                <div class="card-header bg-light">
                                    <h4 class="mb-0">Tóm tắt vé</h4>
                                </div>
                                <div class="card-body">
                                    <c:set var="firstBooking" value="${checkoutBookings[0]}" />
                                    <c:set var="trip" value="${firstBooking.trip}" /> <%-- Giả sử DTO của bạn có đối tượng Trip lồng vào --%>

                                    <h5 class="card-title">${firstBooking.routeOrigin} <i class="fa-solid fa-arrow-right-long"></i> ${firstBooking.routeDestination}</h5>
                                    <p class="card-text mb-1">
                                        <i class="fa-regular fa-calendar-alt"></i> 
                                    <fmt:formatDate value="${firstBooking.departureTime}" pattern="HH:mm 'ngày' dd/MM/yyyy" />
                                    </p>

                                    <hr>

                                    <ul class="list-group list-group-flush">
                                        <c:set var="totalPrice" value="0" />
                                        <c:forEach var="booking" items="${checkoutBookings}">
                                            <li class="list-group-item d-flex justify-content-between">
                                                <span>Ghế ${booking.seatNumber}</span>
                                                <%-- Bạn cần thêm cột Price vào DTO/Booking --%>
                                                <%-- Tạm thời lấy giá từ Trip --%>
                                            <c:set var="tripPrice" value="150000" /> <%-- Thay bằng ${booking.trip.price} --%>
                                            <strong><fmt:formatNumber value="${tripPrice}" type="currency" currencySymbol="₫" maxFractionDigits="0" /></strong>
                                            </li>
                                            <c:set var="totalPrice" value="${totalPrice + tripPrice}" />
                                        </c:forEach>
                                    </ul>
                                </div>
                                <div class="card-footer bg-light">
                                    <div class="d-flex justify-content-between align-items-center">
                                        <h5 class="mb-0">Tổng cộng:</h5>
                                        <h4 class="mb-0 text-danger fw-bold">
                                            <fmt:formatNumber value="${totalPrice}" type="currency" currencySymbol="₫" maxFractionDigits="0" />
                                        </h4>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>
