<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ page import="model.User" %>
        <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
            <%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
                <!DOCTYPE html>
                <html lang="vi">

                <head>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1">
                    <title>Tìm chuyến xe - FUTA Bus Lines</title>
                    <link rel="shortcut icon"
                        href="https://storage.googleapis.com/futa-busline-web-cms-prod/2257_x_501_px_2ecaaa00d0/2257_x_501_px_2ecaaa00d0.png">
                    <link rel="stylesheet"
                        href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
                    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/boxicons@2.1.4/css/boxicons.min.css">
                    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/homepage.css">
                    <link
                        href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap&subset=latin-ext,vietnamese"
                        rel="stylesheet">
                </head>

                <body>
                    <%@ include file="../shared/header.jsp" %>

                        <main class="py-5">
                            <div class="container">
                                <!-- Search Form -->
                                <div class="search-card mb-4">
                                    <form method="POST" action="${pageContext.request.contextPath}/trips/search"
                                        class="d-flex flex-column flex-lg-row align-items-lg-center gap-4">
                                        <div class="flex-grow-1">
                                            <label class="form-label text-uppercase fw-semibold text-secondary">Điểm
                                                đi</label>
                                            <input type="text" name="departure" class="form-control form-control-lg"
                                                value="${departure}" placeholder="Chọn điểm khởi hành" required>
                                        </div>
                                        <button class="btn btn-light rounded-circle shadow" type="button"
                                            aria-label="Đổi điểm đi/đến">
                                            <i class="bx bx-transfer-alt fs-3 text-secondary"></i>
                                        </button>
                                        <div class="flex-grow-1">
                                            <label class="form-label text-uppercase fw-semibold text-secondary">Điểm
                                                đến</label>
                                            <input type="text" name="destination" class="form-control form-control-lg"
                                                value="${destination}" placeholder="Chọn điểm đến" required>
                                        </div>
                                        <div class="flex-grow-1">
                                            <label class="form-label text-uppercase fw-semibold text-secondary">Ngày
                                                đi</label>
                                            <input type="date" name="departureDate" class="form-control form-control-lg"
                                                value="${departureDate}" required>
                                        </div>
                                        <div class="flex-grow-1">
                                            <label class="form-label text-uppercase fw-semibold text-secondary">Số
                                                vé</label>
                                            <select name="passengers" class="form-select form-select-lg">
                                                <option value="1" ${passengers=='1' ? 'selected' : '' }>1 hành khách
                                                </option>
                                                <option value="2" ${passengers=='2' ? 'selected' : '' }>2 hành khách
                                                </option>
                                                <option value="3" ${passengers=='3' ? 'selected' : '' }>3 hành khách
                                                </option>
                                                <option value="4" ${passengers=='4' ? 'selected' : '' }>4 hành khách
                                                </option>
                                            </select>
                                        </div>
                                        <div>
                                            <button class="btn btn-lg btn-warning text-white px-4" type="submit">
                                                <strong>Tìm chuyến xe</strong>
                                            </button>
                                        </div>
                                    </form>
                                </div>

                                <!-- Trip Results -->
                                <div class="card border-0 shadow-sm">
                                    <div class="card-body p-4">
                                        <c:choose>
                                            <c:when test="${empty trips}">
                                                <div class="text-center py-5">
                                                    <i class="bx bx-calendar-x text-warning"
                                                        style="font-size: 4rem;"></i>
                                                    <h5 class="mt-3">Không tìm thấy chuyến xe phù hợp</h5>
                                                    <p class="text-secondary">Vui lòng thử lại với điểm đi/đến hoặc ngày
                                                        khác
                                                    </p>
                                                </div>
                                            </c:when>
                                            <c:otherwise>
                                                <h5 class="card-title mb-4">Danh sách chuyến xe</h5>
                                                <div class="table-responsive">
                                                    <table class="table table-hover align-middle">
                                                        <thead class="table-light text-secondary text-uppercase small">
                                                            <tr>
                                                                <th>Tuyến đường</th>
                                                                <th>Thời gian khởi hành</th>
                                                                <th>Thời gian đến</th>
                                                                <th>Thời gian dự kiến</th>
                                                                <th>Giá vé</th>
                                                                <th>Trạng thái</th>
                                                                <th></th>
                                                            </tr>
                                                        </thead>
                                                        <tbody>
                                                            <c:forEach var="trip" items="${trips}">
                                                                <tr>
                                                                    <td>
                                                                        <div class="fw-semibold">${trip.route.origin} →
                                                                            ${trip.route.destination}</div>
                                                                        <small class="text-secondary">Xe
                                                                            ${trip.vehicle.licensePlate}</small>
                                                                    </td>
                                                                    <td>
                                                                        <fmt:parseDate value="${trip.departureTime}"
                                                                            pattern="yyyy-MM-dd'T'HH:mm"
                                                                            var="parsedDeparture" type="both" />
                                                                        <div>
                                                                            <fmt:formatDate value="${parsedDeparture}"
                                                                                pattern="HH:mm" />
                                                                        </div>
                                                                        <small class="text-secondary">
                                                                            <fmt:formatDate value="${parsedDeparture}"
                                                                                pattern="dd/MM/yyyy" />
                                                                        </small>
                                                                    </td>
                                                                    <td>
                                                                        <fmt:parseDate value="${trip.arrivalTime}"
                                                                            pattern="yyyy-MM-dd'T'HH:mm"
                                                                            var="parsedArrival" type="both" />
                                                                        <div>
                                                                            <fmt:formatDate value="${parsedArrival}"
                                                                                pattern="HH:mm" />
                                                                        </div>
                                                                        <small class="text-secondary">
                                                                            <fmt:formatDate value="${parsedArrival}"
                                                                                pattern="dd/MM/yyyy" />
                                                                        </small>
                                                                    </td>
                                                                    <td>${trip.route.durationMinutes} phút</td>
                                                                    <td class="fw-semibold text-warning">
                                                                        <fmt:formatNumber value="${trip.price}"
                                                                            type="number" maxFractionDigits="0" />đ
                                                                    </td>
                                                                    <td>
                                                                        <c:choose>
                                                                            <c:when
                                                                                test="${trip.status == 'Available'}">
                                                                                <span
                                                                                    class="badge bg-success-subtle border border-success-subtle text-success">Còn
                                                                                    chỗ</span>
                                                                            </c:when>
                                                                            <c:when test="${trip.status == 'Full'}">
                                                                                <span
                                                                                    class="badge bg-danger-subtle border border-danger-subtle text-danger">Hết
                                                                                    chỗ</span>
                                                                            </c:when>
                                                                            <c:otherwise>
                                                                                <span
                                                                                    class="badge bg-warning-subtle border border-warning-subtle text-warning">${trip.status}</span>
                                                                            </c:otherwise>
                                                                        </c:choose>
                                                                    </td>
                                                                    <td>
                                                                        <a href="${pageContext.request.contextPath}/trips/details/${trip.tripId}"
                                                                            class="btn btn-warning text-white">
                                                                            <i class="bx bx-calendar-check"></i>
                                                                            Đặt vé
                                                                        </a>
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
                        </main>

                        <%@ include file="../shared/footer.jsp" %>

                            <!-- Core JS -->
                            <script
                                src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
                            <script>
                                // Set min date for date picker to today
                                document.getElementById('departureDate').min = new Date().toISOString().split('T')[0];

                                // Swap departure and destination when clicking transfer button
                                document.querySelector('[aria-label="Đổi điểm đi/đến"]').addEventListener('click', function () {
                                    const departure = document.querySelector('input[name="departure"]');
                                    const destination = document.querySelector('input[name="destination"]');
                                    const temp = departure.value;
                                    departure.value = destination.value;
                                    destination.value = temp;
                                });
                            </script>
                </body>

                </html>