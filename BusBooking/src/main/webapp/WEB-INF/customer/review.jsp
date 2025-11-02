<%--
  Created by IntelliJ IDEA.
  User: tanhu
  Date: 11/2/2025
  Time: 1:03 PM
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%
    // Kỹ thuật này được giữ lại vì nó thường là cách ứng dụng xử lý các đường dẫn tài nguyên tĩnh
    String contextPath = request.getContextPath();
    String assetBase = contextPath + "/assets/sneat-1.0.0/assets";
    String vendorPath = assetBase + "/vendor";
    String jsPath = assetBase + "/js";

    // Kiểm tra và chuyển hướng: Logic này đã được xử lý trong Controller (doGet),
    // nhưng kiểm tra cuối cùng là cần thiết nếu người dùng truy cập trực tiếp.
    // Tuy nhiên, việc kiểm tra User và TripDetails đã được Controller đảm bảo
    // nên chúng ta có thể tập trung vào hiển thị.
%>
<!DOCTYPE html>
<html lang="vi" class="light-style layout-menu-fixed" dir="ltr" data-theme="theme-default" data-assets-path="<%= assetBase %>/">
<head>
    <meta charset="utf-8" />
    <title>Đánh Giá Chuyến Đi - ${tripDetails.routeDetails}</title>
    <jsp:include page="/WEB-INF/components/meta.jsp" />
    <link rel="stylesheet" href="<%= assetBase %>/vendor/fonts/boxicons.css" />

    <style>
        /* CSS Cơ bản cho Star Rating */
        .rating {
            display: inline-block;
            direction: rtl; /* Đảo ngược thứ tự để ngôi sao 5 ở bên trái */
        }
        .rating input {
            display: none; /* Ẩn radio buttons */
        }
        .rating label {
            color: #ccc; /* Màu xám mặc định */
            font-size: 30px; /* Kích thước ngôi sao */
            padding: 0 5px;
            cursor: pointer;
            transition: color .2s;
        }
        /* Highlight sao khi hover hoặc đã chọn */
        .rating input:checked ~ label,
        .rating label:hover,
        .rating label:hover ~ label {
            color: #ffc107; /* Màu vàng của sao (Bootstrap warning color) */
        }
        /* Đảm bảo sao được chọn vẫn giữ màu khi di chuột ra khỏi */
        .rating input:checked + label:hover,
        .rating input:checked ~ label:hover,
        .rating input:checked ~ label:hover ~ label,
        .rating label:hover ~ input:checked ~ label {
            color: #ffc107;
        }
    </style>
    <%-- Các thẻ <link> và <script> khác --%>
    ...
</head>
<body>
<div class="layout-wrapper layout-content-navbar">
    <div class="layout-container">
        <%-- Thay bằng sidebar của bạn --%>
        <%-- <jsp:include page="/WEB-INF/components/sidebar.jsp" /> --%>
        <div class="layout-page">
            <%-- Thay bằng navbar của bạn --%>
            <%-- <jsp:include page="/WEB-INF/components/navbar.jsp" /> --%>
            <div class="content-wrapper">
                <div class="container-xxl flex-grow-1 container-p-y">

                    <h4 class="fw-bold py-3 mb-4"><span class="text-muted fw-light">Khách hàng /</span> Đánh giá chuyến đi</h4>

                    <div class="card mb-4">
                        <h5 class="card-header">Đánh giá chuyến đi #${tripId}</h5>
                        <div class="card-body">
                            <div class="alert alert-info" role="alert">
                                <h4 class="alert-heading">Thông tin chuyến đi</h4>
                                <p class="mb-0">
                                    <strong>Tuyến:</strong> ${tripDetails.routeDetails}<br>
                                    <strong>Thời gian khởi hành:</strong> ${tripDetails.departureTime}
                                </p>
                            </div>

                            <form action="<%= contextPath %>/customer/review" method="POST">
                                <input type="hidden" name="tripId" value="${tripId}" />

                                <div class="mb-3">
                                    <label class="form-label">1. Đánh giá của bạn</label>

                                    <div class="rating d-flex justify-content-end">
                                        <input type="radio" id="star5" name="rating" value="5" required />
                                        <label for="star5" title="5 sao"><i class='bx bxs-star'></i></label>

                                        <input type="radio" id="star4" name="rating" value="4" />
                                        <label for="star4" title="4 sao"><i class='bx bxs-star'></i></label>

                                        <input type="radio" id="star3" name="rating" value="3" />
                                        <label for="star3" title="3 sao"><i class='bx bxs-star'></i></label>

                                        <input type="radio" id="star2" name="rating" value="2" />
                                        <label for="star2" title="2 sao"><i class='bx bxs-star'></i></label>

                                        <input type="radio" id="star1" name="rating" value="1" />
                                        <label for="star1" title="1 sao"><i class='bx bxs-star'></i></label>
                                    </div>
                                    <small class="form-text text-muted d-block mt-1">Vui lòng chọn từ 1 đến 5 sao.</small>
                                </div>

                                <div class="mb-3">
                                    <label for="comment" class="form-label">2. Nhận xét của bạn (Không bắt buộc, tối đa 256 ký tự)</label>
                                    <textarea class="form-control" id="comment" name="comment" rows="4" maxlength="256" placeholder="Chia sẻ trải nghiệm của bạn về chuyến đi..."></textarea>
                                </div>

                                <div class="d-flex gap-3">
                                    <button type="submit" class="btn btn-warning text-white"><i class='bx bxs-send'></i> Gửi đánh giá</button>
                                    <a href="<%= contextPath %>/customer/profile" class="btn btn-outline-secondary">Hủy bỏ</a>
                                </div>
                            </form>
                        </div>
                    </div>

                </div>
                <%-- Thay bằng footer của bạn --%>
                <%-- <jsp:include page="/WEB-INF/components/footer.jsp" /> --%>
            </div>
        </div>
    </div>
    <div class="layout-overlay layout-menu-toggle"></div>
</div>

<script src="<%= vendorPath %>/libs/popper/popper.js"></script>
<script src="<%= vendorPath %>/js/bootstrap.js"></script>
<%-- <script src="<%= vendorPath %>/js/menu.js"></script> --%>
<script src="<%= jsPath %>/main.js"></script>
</body>
</html>
