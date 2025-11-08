<%-- 
    Document   : booking-success
    Created on : Nov 9, 2025, 1:43:09 AM
    Author     : Tran Quang Duyen
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đặt vé thành công</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css" />
    <style>
        body { background-color: #f4f7f6; }
        .success-card {
            max-width: 600px;
            margin: 50px auto;
            border: none;
            border-radius: 12px;
            box-shadow: 0 6px 16px rgba(0, 0, 0, 0.08);
            text-align: center;
            padding: 40px;
        }
        .success-icon {
            font-size: 60px;
            color: #198754;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="card success-card">
            <div class="card-body">
                <i class="fas fa-check-circle success-icon mb-3"></i>
                <h1 class="card-title text-success">Đặt vé thành công!</h1>
                <p class="text-muted">Cảm ơn bạn đã sử dụng dịch vụ của chúng tôi.</p>
                <p>Thông tin vé đã được gửi đến email của bạn. Vui lòng kiểm tra hộp thư.</p>
                
                <c:if test="${not empty sessionScope.confirmedBookingIds}">
                    <p classsmall">Mã đặt vé của bạn (Booking IDs):</p>
                    <h4 class="text-primary">
                        <c:forEach var="id" items="${sessionScope.confirmedBookingIds}" varStatus="loop">
                            ${id}${!loop.last ? ', ' : ''}
                        </c:forEach>
                    </h4>
                </c:if>
                
                <hr class="my-4">
                
                <a href="${pageContext.request.contextPath}/homepage.jsp" class="btn btn-primary">
                    <i class="fas fa-home"></i> Về trang chủ
                </a>
                <a href="${pageContext.request.contextPath}/my-tickets" class="btn btn-outline-secondary">
                    <i class="fas fa-ticket-alt"></i> Xem vé của tôi
                </a>
            </div>
        </div>
    </div>
    
    <%-- Xóa attribute khỏi session sau khi đã dùng --%>
    <c:remove var="confirmedBookingIds" scope="session" />
</body>
</html>
