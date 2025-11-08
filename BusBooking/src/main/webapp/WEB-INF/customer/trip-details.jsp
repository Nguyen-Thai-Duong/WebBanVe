<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
            <!DOCTYPE html>
            <html>

            <head>
                <meta charset="UTF-8">
                <title>Trip Details - Bus Booking System</title>
                <link rel="stylesheet"
                    href="${pageContext.request.contextPath}/assets/sneat-1.0.0/assets/vendor/css/core.css">
                <link rel="stylesheet"
                    href="${pageContext.request.contextPath}/assets/sneat-1.0.0/assets/vendor/css/theme-default.css">
                <style>
                    .seat-map {
                        display: grid;
                        grid-template-columns: repeat(4, 1fr);
                        gap: 10px;
                        padding: 20px;
                        max-width: 400px;
                        margin: 0 auto;
                    }

                    .seat {
                        padding: 10px;
                        text-align: center;
                        border: 1px solid #ddd;
                        border-radius: 5px;
                        cursor: not-allowed;
                    }

                    .seat.available {
                        background-color: #e8f5e9;
                        color: #2e7d32;
                    }

                    .seat.booked {
                        background-color: #ffebee;
                        color: #c62828;
                    }

                    .seat-legend {
                        display: flex;
                        justify-content: center;
                        gap: 20px;
                        margin: 20px 0;
                    }

                    .legend-item {
                        display: flex;
                        align-items: center;
                        gap: 5px;
                    }

                    .legend-box {
                        width: 20px;
                        height: 20px;
                        border-radius: 3px;
                    }

                    .trip-info {
                        margin-bottom: 30px;
                    }

                    .info-row {
                        display: flex;
                        margin-bottom: 10px;
                    }

                    .info-label {
                        width: 150px;
                        font-weight: bold;
                    }
                </style>
            </head>

            <body>
                <div class="container-xxl flex-grow-1 container-p-y">
                    <div class="row">
                        <div class="col-12">
                            <a href="${pageContext.request.contextPath}/trips/search" class="btn btn-secondary mb-4">
                                <i class="bx bx-arrow-back"></i> Back to Search
                            </a>

                            <div class="card">
                                <div class="card-body">
                                    <h4 class="card-title">Trip Details</h4>

                                    <div class="trip-info">
                                        <div class="info-row">
                                            <span class="info-label">Route:</span>
                                            <span>${trip.route.origin} → ${trip.route.destination}</span>
                                        </div>
                                        <div class="info-row">
                                            <span class="info-label">Departure:</span>
                                            <span>
                                                <fmt:parseDate value="${trip.departureTime}"
                                                    pattern="yyyy-MM-dd'T'HH:mm" var="parsedDate" type="both" />
                                                <fmt:formatDate value="${parsedDate}" pattern="dd/MM/yyyy HH:mm" />
                                            </span>
                                        </div>
                                        <div class="info-row">
                                            <span class="info-label">Arrival:</span>
                                            <span>
                                                <fmt:parseDate value="${trip.arrivalTime}" pattern="yyyy-MM-dd'T'HH:mm"
                                                    var="parsedDate" type="both" />
                                                <fmt:formatDate value="${parsedDate}" pattern="dd/MM/yyyy HH:mm" />
                                            </span>
                                        </div>
                                        <div class="info-row">
                                            <span class="info-label">Duration:</span>
                                            <span>${trip.route.durationMinutes} minutes</span>
                                        </div>
                                        <div class="info-row">
                                            <span class="info-label">Price:</span>
                                            <span>₫
                                                <fmt:formatNumber value="${trip.price}" type="number"
                                                    maxFractionDigits="0" />
                                            </span>
                                        </div>
                                        <div class="info-row">
                                            <span class="info-label">Vehicle:</span>
                                            <span>${trip.vehicle.licensePlate} (${trip.vehicle.model})</span>
                                        </div>
                                        <div class="info-row">
                                            <span class="info-label">Status:</span>
                                            <span>
                                                <c:choose>
                                                    <c:when test="${trip.status == 'Available'}">
                                                        <span class="badge bg-success">Available</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge bg-warning">${trip.status}</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </span>
                                        </div>
                                    </div>

                                    <h5 class="card-subtitle mb-3">Seat Map</h5>

                                    <div class="seat-legend">
                                        <div class="legend-item">
                                            <div class="legend-box" style="background-color: #e8f5e9;"></div>
                                            <span>Available</span>
                                        </div>
                                        <div class="legend-item">
                                            <div class="legend-box" style="background-color: #ffebee;"></div>
                                            <span>Booked</span>
                                        </div>
                                    </div>

                                    <div class="seat-map">
                                        <c:set var="totalSeats" value="${trip.vehicle.capacity}" />
                                        <c:forEach var="i" begin="1" end="${totalSeats}">
                                            <c:set var="seatNumber" value="${i}" />
                                            <c:set var="isBooked" value="false" />
                                            <c:forEach var="bookedSeat" items="${bookedSeats}">
                                                <c:if test="${bookedSeat eq seatNumber}">
                                                    <c:set var="isBooked" value="true" />
                                                </c:if>
                                            </c:forEach>
                                            <div class="seat ${isBooked ? 'booked' : 'available'}">
                                                Seat ${seatNumber}
                                            </div>
                                        </c:forEach>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Core JS -->
                <script
                    src="${pageContext.request.contextPath}/assets/sneat-1.0.0/assets/vendor/libs/jquery/jquery.js"></script>
                <script
                    src="${pageContext.request.contextPath}/assets/sneat-1.0.0/assets/vendor/libs/popper/popper.js"></script>
                <script
                    src="${pageContext.request.contextPath}/assets/sneat-1.0.0/assets/vendor/js/bootstrap.js"></script>
            </body>

            </html>