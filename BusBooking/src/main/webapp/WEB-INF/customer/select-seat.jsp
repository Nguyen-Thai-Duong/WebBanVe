<%-- 
    Document   : select-seat
    Created on : Nov 9, 2025, 1:32:44 AM
    Author     : Tran Quang Duyen
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<%-- 
  GIẢ ĐỊNH: 
  1. Servlet đã set "trip" (là đối tượng Trip, chứa Vehicle)
  2. Servlet đã set "seatStatusMap" (là Map<String, String>) 
     với key="A1", value="available" | "booked" | "held"
--%>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Chọn Ghế - ${trip.route.origin} đi ${trip.route.destination}</title>

        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css" />

        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@400;500;700&display=swap" rel="stylesheet">

        <style>
            body {
                font-family: 'Roboto', sans-serif;
                background-color: #f4f7f6;
            }

            .seat-map-container {
                background-color: #fff;
                border-radius: 12px;
                padding: 24px;
                box-shadow: 0 6px 16px rgba(0, 0, 0, 0.08);
                position: relative;
                overflow: hidden;
            }

            .bus {
                border: 2px solid #e0e0e0;
                border-radius: 10px;
                padding: 20px;
                position: relative;
            }

            .driver-cab {
                width: 60px;
                height: 80px;
                border: 2px solid #ced4da;
                border-radius: 10px 10px 0 0;
                position: relative;
                margin: 0 auto 20px auto;
                background-color: #f8f9fa;
            }
            .driver-cab::before {
                content: "Lái xe";
                font-size: 0.75rem;
                color: #6c757d;
                position: absolute;
                top: 50%;
                left: 50%;
                transform: translate(-50%, -50%);
            }

            .seat-row {
                display: flex;
                justify-content: center;
                align-items: center;
                margin-bottom: 10px;
            }

            .aisle {
                width: 40px; /* Độ rộng lối đi */
                height: 40px;
            }

            .seat {
                width: 40px;
                height: 40px;
                margin: 5px;
                border-radius: 8px;
                cursor: pointer;
                display: flex;
                justify-content: center;
                align-items: center;
                font-size: 0.75rem;
                font-weight: 500;
                transition: all 0.2s ease;
                border: 1px solid;
            }
            .seat i {
                font-size: 1.1rem;
            }

            /* 1. Ghế Trống */
            .seat.available {
                color: #0d6efd;
                border-color: #b6d4fe;
                background-color: #f0f6ff;
            }
            .seat.available:hover {
                background-color: #0d6efd;
                color: #fff;
                box-shadow: 0 0 10px rgba(13, 110, 253, 0.5);
            }

            /* 2. Ghế Đã Đặt (Bởi người khác) */
            .seat.booked,
            .seat.held {
                color: #6c757d;
                border-color: #ced4da;
                background-color: #e9ecef;
                cursor: not-allowed;
                opacity: 0.8;
            }
            .seat.booked i,
            .seat.held i {
                color: #adb5bd;
            }

            /* 3. Ghế BẠN Đang Chọn */
            .seat.selected {
                color: #fff;
                border-color: #198754;
                background-color: #198754;
                box-shadow: 0 0 10px rgba(25, 135, 84, 0.5);
            }
            .seat.selected i {
                color: #fff;
            }

            /* 4. Đang Tải (khi click) */
            .seat.loading {
                cursor: wait;
                background-color: #ffc107;
                border-color: #ffc107;
            }

            /* Chú thích */
            .seat-legend {
                display: flex;
                justify-content: center;
                flex-wrap: wrap;
                gap: 20px;
                margin-bottom: 24px;
            }
            .legend-item {
                display: flex;
                align-items: center;
            }
            .legend-item .seat {
                cursor: default;
                margin: 0 8px 0 0;
            }
            .legend-item .seat:hover { /* Vô hiệu hóa hover của legend */
                background-color: initial;
                color: initial;
                box-shadow: none;
            }
            .legend-item .seat.available:hover {
                background-color: #f0f6ff;
                color: #0d6efd;
            }

            /* Cột Tóm Tắt (Cart) */
            .summary-card {
                position: sticky;
                top: 20px;
                border-radius: 12px;
                box-shadow: 0 6px 16px rgba(0, 0, 0, 0.08);
            }
            .summary-card .list-group-item {
                display: flex;
                justify-content: space-between;
                align-items: center;
            }
            #btn-continue:disabled {
                background-color: #adb5bd;
                border-color: #adb5bd;
            }
        </style>
    </head>

    <body>

        <div class="container my-4 my-md-5">

            <div class="row justify-content-center mb-4">
                <div class="col-md-10 col-lg-8">
                    <div class="progress" style="height: 20px;">
                        <div class="progress-bar" role="progressbar" style="width: 50%;" aria-valuenow="50" aria-valuemin="0" aria-valuemax="100">
                            Bước 1: Chọn ghế
                        </div>
                    </div>
                </div>
            </div>

            <input type="hidden" id="tripId" value="${trip.tripID}" />
            <input type="hidden" id="tripPrice" value="${trip.price}" />
            <input type="hidden" id="servletUrl" value="${pageContext.request.contextPath}/api/seat-action" />

            <div classs="row">
                <div id="seat-message" class="alert alert-danger d-none" role="alert"></div>
            </div>

            <div class="row g-4">
                <div class="col-lg-7 col-md-12">
                    <div class="seat-map-container">

                        <div class="seat-legend">
                            <div class="legend-item">
                                <div class="seat available"><i class="fa-solid fa-chair"></i></div>
                                <span>Trống</span>
                            </div>
                            <div class="legend-item">
                                <div class="seat selected"><i class="fa-solid fa-user-check"></i></div>
                                <span>Đang chọn</span>
                            </div>
                            <div class="legend-item">
                                <div class="seat booked"><i class="fa-solid fa-chair"></i></div>
                                <span>Đã đặt</span>
                            </div>
                        </div>

                        <div class="bus">
                            <div class="driver-cab"></div>

                            <c:set var="columns" value="${['A', 'B', 'C', 'D']}" />

                            <div class="seat-map">
                                <c:forEach var="row" begin="1" end="${trip.vehicle.seatRows}">
                                    <div class="seat-row">
                                        <c:forEach var="col" items="${columns}" varStatus="loop">

                                            <c:set var="seatName" value="${col}${row}" />

                                            <c:set var="status" value="${seatStatusMap[seatName]}" />

                                            <c:set var="seatClass" value="${(status == 'available') ? 'available' : ((status == 'booked' || status == 'held') ? 'booked' : 'available')}" />

                                            <c:if test="${col == 'C'}">
                                                <div class="aisle"></div>
                                                </cs:if>

                                                <div class="seat ${seatClass}" data-seat-name="${seatName}">
                                                    <i class="fa-solid fa-chair"></i>
                                                </div>

                                        </c:forEach>
                                    </div>
                                </c:forEach>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="col-lg-5 col-md-12">
                    <div class="summary-card card">
                        <div class="card-header bg-primary text-white">
                            <h4 class="mb-0">Chuyến đi của bạn</h4>
                        </div>
                        <div class="card-body">
                            <h5 class="card-title">${trip.route.origin} <i class="fa-solid fa-arrow-right-long"></i> ${trip.route.destination}</h5>
                            <p class="card-text mb-1">
                                <i class="fa-regular fa-calendar-alt"></i> 
                                <fmt:formatDate value="${trip.departureTime}" pattern="HH:mm 'ngày' dd/MM/yyyy" />
                            </p>
                            <p class="card-text">
                                <i class="fa-solid fa-bus"></i> 
                                Xe: ${trip.vehicle.licensePlate} (${trip.vehicle.model})
                            </p>
                            <hr>

                            <h6 class="mb-3">Ghế đã chọn:</h6>
                            <ul class="list-group list-group-flush" id="selected-seats-list">
                                <li class="list-group-item text-muted" id="no-seat-selected">
                                    Vui lòng chọn ghế...
                                </li>
                            </ul>
                        </div>
                        <div class="card-footer bg-light">
                            <div class="d-flex justify-content-between align-items-center mb-3">
                                <h5 class="mb-0">Tổng cộng:</h5>
                                <h4 class="mb-0 text-danger fw-bold" id="total-price">
                                    0 <fmt:formatNumber type="currency" currencySymbol="₫" maxFractionDigits="0" />
                                </h4>
                            </div>

                            <form id="payment-form" action="${pageContext.request.contextPath}/payment" method="POST">
                                <input type="hidden" name="bookingIds" id="bookingIdsInput" /> 

                                <button type="submit" id="btn-continue" class="btn btn-success btn-lg w-100" disabled>
                                    Tiếp tục
                                </button>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

        <script>
            document.addEventListener('DOMContentLoaded', function () {

                // --- 1. Lấy các phần tử DOM ---
                const seatMap = document.querySelector('.seat-map');
                if (!seatMap)
                    return;

                const tripId = document.getElementById('tripId').value;
                const tripPrice = parseFloat(document.getElementById('tripPrice').value);
                const seatApiUrl = document.getElementById('servletUrl').value;

                // Cột tóm tắt (summary)
                const messageDiv = document.getElementById('seat-message');
                const selectedListUl = document.getElementById('selected-seats-list');
                const noSeatLi = document.getElementById('no-seat-selected');
                const totalPriceEl = document.getElementById('total-price');
                const btnContinue = document.getElementById('btn-continue');
                const paymentForm = document.getElementById('payment-form');
                const bookingIdsInput = document.getElementById('bookingIdsInput');

                // --- 2. Biến trạng thái ---
                // Map để lưu: { 'A1' => 123, 'B2' => 124 } (seatName => tempBookingId)
                const mySelectedSeats = new Map();
                let isSubmitting = false; // Cờ chống click nhiều lần

                // --- 3. Gắn sự kiện Click chính ---
                seatMap.addEventListener('click', function (e) {
                    // Chỉ xử lý khi bấm vào 1 cái ghế (class="seat")
                    const seatDiv = e.target.closest('.seat');
                    if (!seatDiv)
                        return;

                    const seatName = seatDiv.dataset.seatName;

                    // Xóa thông báo lỗi
                    messageDiv.classList.add('d-none');

                    if (isSubmitting)
                        return; // Không cho click khi đang gọi API

                    // --- 4. Xử lý logic bấm ---
                    if (seatDiv.classList.contains('available')) {
                        handleHoldSeat(seatDiv, seatName);
                    } else if (seatDiv.classList.contains('selected')) {
                        handleReleaseSeat(seatDiv, seatName);
                    } else if (seatDiv.classList.contains('booked') || seatDiv.classList.contains('held')) {
                        showError(`Ghế ${seatName} đã có người đặt hoặc đang được giữ.`);
                    }
                });

                // --- 5. Hàm gọi API Giữ Ghế (HOLD) ---
                async function handleHoldSeat(seatDiv, seatName) {
                    console.log(`Đang thử giữ ghế: ${seatName}`);
                    isSubmitting = true;
                    seatDiv.classList.add('loading');
                    seatDiv.classList.remove('available');

                    const formData = new URLSearchParams();
                    formData.append('action', 'hold');
                    formData.append('tripId', tripId);
                    formData.append('seatName', seatName);

                    try {
                        const response = await fetch(seatApiUrl, {
                            method: 'POST',
                            body: formData
                        });

                        const data = await response.json();

                        if (!response.ok) {
                            throw new Error(data.message || `Lỗi ${response.status}`);
                        }

                        // THÀNH CÔNG!
                        console.log(`Đã giữ thành công ghế ${data.seatName}, bookingId tạm: ${data.bookingId}`);
                        seatDiv.classList.add('selected'); // Đổi sang màu XANH
                        seatDiv.innerHTML = '<i class="fa-solid fa-user-check"></i>'; // Đổi icon

                        // Lưu lại bookingId tạm
                        mySelectedSeats.set(data.seatName, data.bookingId);

                    } catch (error) {
                        // THẤT BẠI!
                        console.error('Lỗi khi giữ ghế:', error);
                        showError(error.message);

                        // Trả ghế về 'held' (bị người khác lấy) hoặc 'available' (lỗi server)
                        if (error.message && error.message.includes('vừa bị người khác chọn')) {
                            seatDiv.classList.add('held'); // Bị người khác lấy
                        } else {
                            seatDiv.classList.add('available'); // Lỗi không xác định, cho thử lại
                        }
                        seatDiv.innerHTML = '<i class="fa-solid fa-chair"></i>'; // Trả lại icon
                    } finally {
                        seatDiv.classList.remove('loading');
                        isSubmitting = false;
                        updateSummary(); // Cập nhật cột tóm tắt
                    }
                }

                // --- 6. Hàm gọi API Hủy Giữ Ghế (RELEASE) ---
                async function handleReleaseSeat(seatDiv, seatName) {
                    console.log(`Đang thử hủy ghế: ${seatName}`);

                    const bookingId = mySelectedSeats.get(seatName);
                    if (!bookingId) {
                        console.error(`Không tìm thấy bookingId cho ghế ${seatName}!`);
                        return;
                    }

                    isSubmitting = true;
                    seatDiv.classList.add('loading');
                    seatDiv.classList.remove('selected');

                    const formData = new URLSearchParams();
                    formData.append('action', 'release');
                    formData.append('bookingId', bookingId);
                    formData.append('seatName', seatName);

                    try {
                        const response = await fetch(seatApiUrl, {
                            method: 'POST',
                            body: formData
                        });

                        const data = await response.json();

                        if (!response.ok) {
                            throw new Error(data.message || `Lỗi ${response.status}`);
                        }

                        // THÀNH CÔNG!
                        console.log(`Đã hủy giữ ghế ${data.seatName}`);
                        seatDiv.classList.add('available'); // Trả về màu TRỐNG
                        seatDiv.innerHTML = '<i class="fa-solid fa-chair"></i>'; // Đổi icon

                        // Xóa khỏi danh sách
                        mySelectedSeats.delete(data.seatName);

                    } catch (error) {
                        console.error('Lỗi khi hủy giữ ghế:', error);
                        showError(error.message);
                        // Nếu lỗi, vẫn giữ ghế là 'selected' để user biết
                        seatDiv.classList.add('selected');
                    } finally {
                        seatDiv.classList.remove('loading');
                        isSubmitting = false;
                        updateSummary(); // Cập nhật cột tóm tắt
                    }
                }

                // --- 7. Hàm Cập nhật UI Cột Tóm Tắt ---
                function updateSummary() {
                    // Xóa danh sách cũ
                    selectedListUl.innerHTML = '';

                    if (mySelectedSeats.size === 0) {
                        selectedListUl.appendChild(noSeatLi); // Thêm lại dòng "Vui lòng chọn ghế"
                        btnContinue.disabled = true; // Tắt nút Tiếp tục
                    } else {
                        btnContinue.disabled = false; // Bật nút Tiếp tục
                    }

                    let currentTotalPrice = 0;

                    mySelectedSeats.forEach((bookingId, seatName) => {
                        const li = document.createElement('li');
                        li.className = 'list-group-item';

                        const seatEl = document.createElement('span');
                        seatEl.className = 'fw-bold';
                        seatEl.textContent = `Ghế ${seatName}`;

                        const priceEl = document.createElement('span');
                        priceEl.className = 'text-muted';
                        priceEl.textContent = new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(tripPrice);

                        li.appendChild(seatEl);
                        li.appendChild(priceEl);
                        selectedListUl.appendChild(li);

                        currentTotalPrice += tripPrice;
                    });

                    // Cập nhật tổng tiền
                    totalPriceEl.textContent = new Intl.NumberFormat('vi-VN', {style: 'currency', currency: 'VND'}).format(currentTotalPrice);
                }

                // --- 8. Xử lý Form "Tiếp Tục" ---
                paymentForm.addEventListener('submit', function (e) {
                    // Ngăn form submit ngay lập tức
                    e.preventDefault();

                    if (mySelectedSeats.size === 0) {
                        showError("Bạn chưa chọn ghế nào.");
                        return;
                    }

                    // Lấy tất cả các bookingId tạm
                    const bookingIds = Array.from(mySelectedSeats.values());

                    // Đặt giá trị vào input ẩn
                    bookingIdsInput.value = bookingIds.join(',');

                    // Gửi form đi
                    console.log(`Đang gửi form với các bookingIds: ${bookingIdsInput.value}`);
                    paymentForm.submit();
                });

                // --- Hàm tiện ích ---
                function showError(message) {
                    messageDiv.textContent = message;
                    messageDiv.classList.remove('d-none');
                }
            });
        </script>
    </body>
</html>
