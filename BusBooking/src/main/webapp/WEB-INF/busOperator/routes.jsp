<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Quản lý Tuyến đường - FUTA Bus Lines</title>
                <!-- Favicon -->
                <link rel="shortcut icon" href="https://cdn.futabus.vn/assets/images/favicon.ico">
                <!-- Core CSS -->
                <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/sneat/vendor/css/core.css">
                <link rel="stylesheet"
                    href="${pageContext.request.contextPath}/assets/sneat/vendor/css/theme-default.css">
                <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/sneat/css/demo.css">
                <!-- Vendors CSS -->
                <link rel="stylesheet"
                    href="${pageContext.request.contextPath}/assets/sneat/vendor/libs/perfect-scrollbar/perfect-scrollbar.css">
                <!-- Page CSS -->
                <link rel="stylesheet"
                    href="${pageContext.request.contextPath}/assets/sneat/vendor/libs/datatables/dataTables.bootstrap5.css">
            </head>

            <body>
                <!-- Layout wrapper -->
                <div class="layout-wrapper layout-content-navbar">
                    <div class="layout-container">
                        <!-- Include Menu -->
                        <jsp:include page="shared/menu.jsp" />

                        <!-- Layout container -->
                        <div class="layout-page">
                            <!-- Include Navbar -->
                            <jsp:include page="shared/navbar.jsp" />

                            <!-- Content wrapper -->
                            <div class="content-wrapper">
                                <!-- Content -->
                                <div class="container-xxl flex-grow-1 container-p-y">
                                    <h4 class="fw-bold py-3 mb-4">Quản lý Tuyến đường</h4>

                                    <!-- Route Table -->
                                    <div class="card">
                                        <div class="card-header d-flex align-items-center justify-content-between">
                                            <h5 class="mb-0">Danh sách tuyến đường</h5>
                                            <button type="button" class="btn btn-primary" data-bs-toggle="modal"
                                                data-bs-target="#addRouteModal">
                                                <i class="bx bx-plus"></i> Thêm tuyến mới
                                            </button>
                                        </div>
                                        <div class="card-body">
                                            <div class="table-responsive text-nowrap">
                                                <table class="table table-hover datatables-basic">
                                                    <thead>
                                                        <tr>
                                                            <th>ID</th>
                                                            <th>Điểm đi</th>
                                                            <th>Điểm đến</th>
                                                            <th>Khoảng cách</th>
                                                            <th>Thời gian</th>
                                                            <th>Số chuyến</th>
                                                            <th>Trạng thái</th>
                                                            <th>Thao tác</th>
                                                        </tr>
                                                    </thead>
                                                    <tbody>
                                                        <c:forEach var="route" items="${routes}">
                                                            <tr>
                                                                <td>${route.routeId}</td>
                                                                <td>${route.origin}</td>
                                                                <td>${route.destination}</td>
                                                                <td>${route.distance} km</td>
                                                                <td>${route.durationMinutes} phút</td>
                                                                <td>${route.tripCount}</td>
                                                                <td>
                                                                    <span
                                                                        class="badge bg-label-${route.routeStatus == 'Active' ? 'success' : 'danger'}">
                                                                        ${route.routeStatus == 'Active' ? 'Đang hoạt
                                                                        động' : 'Ngừng hoạt động'}
                                                                    </span>
                                                                </td>
                                                                <td>
                                                                    <div class="dropdown">
                                                                        <button type="button"
                                                                            class="btn p-0 dropdown-toggle hide-arrow"
                                                                            data-bs-toggle="dropdown">
                                                                            <i class="bx bx-dots-vertical-rounded"></i>
                                                                        </button>
                                                                        <div class="dropdown-menu">
                                                                            <a class="dropdown-item"
                                                                                href="javascript:void(0);"
                                                                                onclick="editRoute('${route.routeId}')">
                                                                                <i class="bx bx-edit-alt me-1"></i> Sửa
                                                                            </a>
                                                                            <a class="dropdown-item"
                                                                                href="javascript:void(0);"
                                                                                onclick="toggleRouteStatus('${route.routeId}')">
                                                                                <i
                                                                                    class="bx bx-${route.routeStatus == 'Active' ? 'power-off' : 'play'} me-1"></i>
                                                                                ${route.routeStatus == 'Active' ? 'Ngừng
                                                                                hoạt động' : 'Kích hoạt'}
                                                                            </a>
                                                                            <a class="dropdown-item text-danger"
                                                                                href="javascript:void(0);"
                                                                                onclick="deleteRoute('${route.routeId}')">
                                                                                <i class="bx bx-trash me-1"></i> Xóa
                                                                            </a>
                                                                        </div>
                                                                    </div>
                                                                </td>
                                                            </tr>
                                                        </c:forEach>
                                                    </tbody>
                                                </table>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- Add Route Modal -->
                                    <div class="modal fade" id="addRouteModal" tabindex="-1" aria-hidden="true">
                                        <div class="modal-dialog" role="document">
                                            <div class="modal-content">
                                                <div class="modal-header">
                                                    <h5 class="modal-title">Thêm tuyến đường mới</h5>
                                                    <button type="button" class="btn-close" data-bs-dismiss="modal"
                                                        aria-label="Close"></button>
                                                </div>
                                                <form id="addRouteForm" method="POST"
                                                    action="${pageContext.request.contextPath}/bus-operator/routes/add">
                                                    <div class="modal-body">
                                                        <div class="row">
                                                            <div class="col mb-3">
                                                                <label class="form-label">Điểm đi</label>
                                                                <input type="text" name="origin" class="form-control"
                                                                    placeholder="Nhập điểm khởi hành" required>
                                                            </div>
                                                        </div>
                                                        <div class="row">
                                                            <div class="col mb-3">
                                                                <label class="form-label">Điểm đến</label>
                                                                <input type="text" name="destination"
                                                                    class="form-control" placeholder="Nhập điểm đến"
                                                                    required>
                                                            </div>
                                                        </div>
                                                        <div class="row">
                                                            <div class="col mb-3">
                                                                <label class="form-label">Khoảng cách (km)</label>
                                                                <input type="number" name="distance"
                                                                    class="form-control" min="1" step="0.1" required>
                                                            </div>
                                                        </div>
                                                        <div class="row">
                                                            <div class="col mb-3">
                                                                <label class="form-label">Thời gian (phút)</label>
                                                                <input type="number" name="durationMinutes"
                                                                    class="form-control" min="1" required>
                                                            </div>
                                                        </div>
                                                    </div>
                                                    <div class="modal-footer">
                                                        <button type="button" class="btn btn-outline-secondary"
                                                            data-bs-dismiss="modal">Hủy</button>
                                                        <button type="submit" class="btn btn-primary">Thêm
                                                            tuyến</button>
                                                    </div>
                                                </form>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- Edit Route Modal -->
                                    <div class="modal fade" id="editRouteModal" tabindex="-1" aria-hidden="true">
                                        <div class="modal-dialog" role="document">
                                            <div class="modal-content">
                                                <div class="modal-header">
                                                    <h5 class="modal-title">Chỉnh sửa tuyến đường</h5>
                                                    <button type="button" class="btn-close" data-bs-dismiss="modal"
                                                        aria-label="Close"></button>
                                                </div>
                                                <form id="editRouteForm" method="POST">
                                                    <div class="modal-body">
                                                        <input type="hidden" name="routeId" id="editRouteId">
                                                        <div class="row">
                                                            <div class="col mb-3">
                                                                <label class="form-label">Điểm đi</label>
                                                                <input type="text" name="origin" id="editOrigin"
                                                                    class="form-control" required>
                                                            </div>
                                                        </div>
                                                        <div class="row">
                                                            <div class="col mb-3">
                                                                <label class="form-label">Điểm đến</label>
                                                                <input type="text" name="destination"
                                                                    id="editDestination" class="form-control" required>
                                                            </div>
                                                        </div>
                                                        <div class="row">
                                                            <div class="col mb-3">
                                                                <label class="form-label">Khoảng cách (km)</label>
                                                                <input type="number" name="distance" id="editDistance"
                                                                    class="form-control" min="1" step="0.1" required>
                                                            </div>
                                                        </div>
                                                        <div class="row">
                                                            <div class="col mb-3">
                                                                <label class="form-label">Thời gian (phút)</label>
                                                                <input type="number" name="durationMinutes"
                                                                    id="editDuration" class="form-control" min="1"
                                                                    required>
                                                            </div>
                                                        </div>
                                                    </div>
                                                    <div class="modal-footer">
                                                        <button type="button" class="btn btn-outline-secondary"
                                                            data-bs-dismiss="modal">Hủy</button>
                                                        <button type="submit" class="btn btn-primary">Lưu thay
                                                            đổi</button>
                                                    </div>
                                                </form>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <!-- / Content -->

                                <!-- Footer -->
                                <footer class="content-footer footer bg-footer-theme">
                                    <div
                                        class="container-xxl d-flex flex-wrap justify-content-between py-2 flex-md-row flex-column">
                                        <div class="mb-2 mb-md-0">
                                            ©
                                            <c:out value="<%= java.time.Year.now().getValue() %>" /> FUTA Bus Lines.
                                            Đã đăng ký bản quyền.
                                        </div>
                                    </div>
                                </footer>
                                <!-- / Footer -->

                                <div class="content-backdrop fade"></div>
                            </div>
                            <!-- Content wrapper -->
                        </div>
                        <!-- / Layout page -->
                    </div>
                </div>
                <!-- / Layout wrapper -->

                <!-- Core JS -->
                <script src="${pageContext.request.contextPath}/assets/sneat/vendor/libs/jquery/jquery.js"></script>
                <script src="${pageContext.request.contextPath}/assets/sneat/vendor/libs/popper/popper.js"></script>
                <script src="${pageContext.request.contextPath}/assets/sneat/vendor/js/bootstrap.js"></script>
                <script
                    src="${pageContext.request.contextPath}/assets/sneat/vendor/libs/perfect-scrollbar/perfect-scrollbar.js"></script>
                <script src="${pageContext.request.contextPath}/assets/sneat/vendor/js/menu.js"></script>
                <!-- Vendors JS -->
                <script
                    src="${pageContext.request.contextPath}/assets/sneat/vendor/libs/datatables/jquery.dataTables.js"></script>
                <script
                    src="${pageContext.request.contextPath}/assets/sneat/vendor/libs/datatables/dataTables.bootstrap5.js"></script>
                <!-- Main JS -->
                <script src="${pageContext.request.contextPath}/assets/sneat/js/main.js"></script>
                <!-- Page JS -->
                <script>
                    $(document).ready(function () {
                        // Initialize DataTable
                        $('.datatables-basic').DataTable({
                            dom: '<"card-header flex-column flex-md-row"<"head-label text-center"><"dt-action-buttons text-end pt-3 pt-md-0"B>><"row"<"col-sm-12 col-md-6"l><"col-sm-12 col-md-6 d-flex justify-content-center justify-content-md-end"f>>t<"row"<"col-sm-12 col-md-6"i><"col-sm-12 col-md-6"p>>',
                            displayLength: 7,
                            lengthMenu: [7, 10, 25, 50, 75, 100],
                            language: {
                                search: "Tìm kiếm:",
                                lengthMenu: "Hiển thị _MENU_ mục",
                                info: "Hiển thị _START_ đến _END_ trong _TOTAL_ mục",
                                paginate: {
                                    first: "Đầu",
                                    last: "Cuối",
                                    next: "Sau",
                                    previous: "Trước"
                                }
                            }
                        });
                    });

                    // Edit Route
                    function editRoute(routeId) {
                        // Fetch route details using AJAX
                        $.get("${pageContext.request.contextPath}/bus-operator/routes/" + routeId, function (route) {
                            $('#editRouteId').val(route.routeId);
                            $('#editOrigin').val(route.origin);
                            $('#editDestination').val(route.destination);
                            $('#editDistance').val(route.distance);
                            $('#editDuration').val(route.durationMinutes);
                            $('#editRouteModal').modal('show');
                        });
                    }

                    // Toggle Route Status
                    function toggleRouteStatus(routeId) {
                        if (confirm("Bạn có chắc chắn muốn thay đổi trạng thái tuyến đường này?")) {
                            $.post("${pageContext.request.contextPath}/bus-operator/routes/toggle-status", {
                                routeId: routeId
                            }, function () {
                                location.reload();
                            });
                        }
                    }

                    // Delete Route
                    function deleteRoute(routeId) {
                        if (confirm("Bạn có chắc chắn muốn xóa tuyến đường này?")) {
                            $.post("${pageContext.request.contextPath}/bus-operator/routes/delete", {
                                routeId: routeId
                            }, function () {
                                location.reload();
                            });
                        }
                    }
                </script>
            </body>

            </html>