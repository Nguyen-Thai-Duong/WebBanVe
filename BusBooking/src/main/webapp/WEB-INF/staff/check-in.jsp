<%-- 
    Document   : check-in
    Created on : Nov 9, 2025, 1:57:21 AM
    Author     : Tran Quang Duyen
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quầy Check-in</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css" />
    <style>
        body { background-color: #f0f2f5; }
        .checkin-container { max-width: 700px; }
    </style>
</head>
<body>

    <div class="container checkin-container my-5">
        <div class="card shadow-sm border-0 rounded-3">
            <div class="card-header bg-primary text-white py-3">
                <h4 class="mb-0"><i class="fa-solid fa-ticket-alt"></i> Kiểm tra & In vé (Check-in)</h4>
            </div>
            <div class="card-body p-4">

                <div class="mb-3">
                    <label for="ticket-code-input" class="form-label fs-5">Nhập Mã Vé (Booking ID):</label>
                    <div class="input-group input-group-lg">
                        <span class="input-group-text"><i class="fa-solid fa-barcode"></i></span>
                        <input type="text" class="form-control" id="ticket-code-input" placeholder="Nhập mã đặt vé, ví dụ: 123">
                        <button class="btn btn-primary" type="button" id="check-ticket-btn">
                            <i class="fa-solid fa-search"></i> Kiểm tra
                        </button>
                    </div>
                </div>

                <hr class="my-4">

                <div id="ticket-result-area" class="d-none">
                
                    <div id="invalid-ticket-box" class="alert alert-danger d-none" role="alert">
                        <h5 class="alert-heading"><i class="fa-solid fa-times-circle"></i> Vé không hợp lệ!</h5>
                        <p id="error-message-text"></p>
                    </div>

                    <div id="valid-ticket-box" class="d-none">
                        <div class="alert alert-success" role="alert">
                             <h5 class="alert-heading"><i class="fa-solid fa-check-circle"></i> Vé hợp lệ!</h5>
                        </div>
                        
                        <h3 class="mb-3">Thông tin vé</h3>
                        <ul class="list-group list-group-flush fs-5">
                            <li class="list-group-item">
                                <i class="fa-solid fa-user me-2 text-muted"></i>
                                <strong>Hành khách:</strong> <span id="info-customer-name"></span>
                            </li>
                            <li class="list-group-item">
                                <i class="fa-solid fa-phone me-2 text-muted"></i>
                                <strong>SĐT:</strong> <span id="info-customer-phone"></span>
                            </li>
                            <li class="list-group-item">
                                <i class="fa-solid fa-road me-2 text-muted"></i>
                                <strong>Tuyến:</strong> <span id="info-route"></span>
                            </li>
                            <li class="list-group-item">
                                <i class="fa-solid fa-clock me-2 text-muted"></i>
                                <strong>Khởi hành:</strong> <span id="info-departure-time"></span>
                            </li>
                            <li class="list-group-item">
                                <i class="fa-solid fa-chair me-2 text-muted"></i>
                                <strong>Ghế:</strong> <span id="info-seat-number" class="fw-bold text-danger"></span>
                            </li>
                        </ul>

                        <div class="text-center mt-4">
                            <button class="btn btn-success btn-lg w-100" id="print-ticket-btn" data-booking-id="">
                                <i class="fa-solid fa-print"></i> Xác nhận & In vé vật lý
                            </button>
                        </div>
                    </div>
                </div>

            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            const checkBtn = document.getElementById('check-ticket-btn');
            const ticketInput = document.getElementById('ticket-code-input');
            const resultArea = document.getElementById('ticket-result-area');
            const validBox = document.getElementById('valid-ticket-box');
            const invalidBox = document.getElementById('invalid-ticket-box');
            const errorText = document.getElementById('error-message-text');
            const printBtn = document.getElementById('print-ticket-btn');
            
            // API Servlet URL
            const checkApiUrl = '${pageContext.request.contextPath}/api/check-in';
            const printUrl = '${pageContext.request.contextPath}/print-ticket';

            // Xử lý sự kiện nhấn nút "Kiểm tra"
            checkBtn.addEventListener('click', checkTicket);
            // Xử lý nhấn Enter trong ô input
            ticketInput.addEventListener('keyup', function(e) {
                if (e.key === 'Enter') {
                    checkTicket();
                }
            });

            async function checkTicket() {
                const bookingId = ticketInput.value.trim();
                if (!bookingId) {
                    showError('Vui lòng nhập Mã Vé.');
                    return;
                }

                // Reset UI
                resultArea.classList.add('d-none');
                validBox.classList.add('d-none');
                invalidBox.classList.add('d-none');
                checkBtn.disabled = true;
                checkBtn.innerHTML = '<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span> Đang kiểm tra...';

                try {
                    // Gọi API (CheckInServlet)
                    const formData = new URLSearchParams();
                    formData.append('bookingId', bookingId);

                    const response = await fetch(checkApiUrl, {
                        method: 'POST',
                        body: formData
                    });

                    const data = await response.json();

                    if (!response.ok) {
                        throw new Error(data.message || 'Lỗi không xác định');
                    }
                    
                    // THÀNH CÔNG: Hiển thị thông tin vé
                    showSuccess(data);

                } catch (error) {
                    // THẤT BẠI: Hiển thị lỗi
                    showError(error.message);
                } finally {
                    checkBtn.disabled = false;
                    checkBtn.innerHTML = '<i class="fa-solid fa-search"></i> Kiểm tra';
                }
            }
            
            // Hàm hiển thị lỗi
            function showError(message) {
                errorText.textContent = message;
                invalidBox.classList.remove('d-none');
                resultArea.classList.remove('d-none');
            }
            
            // Hàm hiển thị thông tin vé hợp lệ
            function showSuccess(data) {
                document.getElementById('info-customer-name').textContent = data.customerName;
                document.getElementById('info-customer-phone').textContent = data.customerPhone;
                document.getElementById('info-route').textContent = data.route;
                document.getElementById('info-departure-time').textContent = data.departureTime;
                document.getElementById('info-seat-number').textContent = data.seatNumber;
                
                // Lưu bookingId vào nút In để sử dụng sau
                printBtn.dataset.bookingId = data.bookingId;
                
                validBox.classList.remove('d-none');
                resultArea.classList.remove('d-none');
            }

            // Xử lý sự kiện nhấn nút "In Vé"
            printBtn.addEventListener('click', function() {
                const bookingId = this.dataset.bookingId;
                if (!bookingId) return;

                // 1. Mở cửa sổ pop-up trỏ đến PrintTicketServlet
                const printWindow = window.open(
                    `${printUrl}?id=${bookingId}`, 
                    'printTicket', 
                    'height=500,width=800' // Kích thước cửa sổ in
                );
                
                // 2. (Tùy chọn) Cập nhật trạng thái vé là "Đã sử dụng" (Used)
                // Bạn có thể gọi 1 API khác ở đây để update status
                // ...
                
                // 3. Xóa input và reset form để check vé tiếp theo
                ticketInput.value = '';
                resultArea.classList.add('d-none');
            });
        });
    </script>
</body>
</html>
