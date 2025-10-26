<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Collections" %>
<%@ page import="model.User" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%
    List<User> operators = (List<User>) request.getAttribute("operators");
    if (operators == null) {
        operators = Collections.emptyList();
    }

    DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
    String contextPath = request.getContextPath();
    String assetBase = contextPath + "/assets/sneat-1.0.0/assets";
    String vendorPath = assetBase + "/vendor";
    String cssPath = assetBase + "/css";
    String jsPath = assetBase + "/js";
    String imgPath = assetBase + "/img";

    String flashMessage = (String) request.getAttribute("flashMessage");
    String flashType = (String) request.getAttribute("flashType");
    if (flashMessage == null) {
        flashMessage = (String) session.getAttribute("operatorMessage");
        flashType = (String) session.getAttribute("operatorMessageType");
        if (flashMessage != null) {
            session.removeAttribute("operatorMessage");
            session.removeAttribute("operatorMessageType");
        }
    }

    request.setAttribute("activeMenu", "operators");
    request.setAttribute("navbarSearchPlaceholder", "Tìm kiếm nhà xe...");
    request.setAttribute("navbarSearchAriaLabel", "Tìm kiếm nhà xe...");
    String[] statuses = {"Active", "Inactive", "Suspended", "Locked"};
%>
<!DOCTYPE html>
<html
    lang="vi"
    class="light-style layout-menu-fixed"
    dir="ltr"
    data-theme="theme-default"
    data-assets-path="<%= assetBase %>/"
    data-template="vertical-menu-template-free"
>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý nhà xe</title>

    <link rel="icon" type="image/x-icon" href="<%= imgPath %>/favicon/favicon.ico" />

    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
    <link href="https://fonts.googleapis.com/css2?family=Public+Sans:wght@300;400;500;600;700&display=swap" rel="stylesheet" />

    <link rel="stylesheet" href="<%= vendorPath %>/fonts/boxicons.css" />
    <link rel="stylesheet" href="<%= vendorPath %>/css/core.css" class="template-customizer-core-css" />
    <link rel="stylesheet" href="<%= vendorPath %>/css/theme-default.css" class="template-customizer-theme-css" />
    <link rel="stylesheet" href="<%= cssPath %>/demo.css" />
    <link rel="stylesheet" href="<%= vendorPath %>/libs/perfect-scrollbar/perfect-scrollbar.css" />

    <script src="<%= vendorPath %>/js/helpers.js"></script>
    <script src="<%= jsPath %>/config.js"></script>

    <style>
        .table thead th { white-space: nowrap; }
        .operator-avatar {
            width: 42px;
            height: 42px;
            border-radius: 50%;
            background-color: #fff3cd;
            color: #d17f00;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 600;
        }
    </style>
</head>
<body>
<div class="layout-wrapper layout-content-navbar">
    <div class="layout-container">
        <%@ include file="includes/sidebar.jspf" %>

        <div class="layout-page">
            <%@ include file="includes/navbar.jspf" %>

            <div class="content-wrapper">
                <div class="container-xxl flex-grow-1 container-p-y">
                    <div class="d-flex flex-wrap align-items-center justify-content-between mb-4">
                        <div>
                            <h4 class="fw-bold mb-1">Danh sách nhà xe</h4>
                            <span class="text-muted">Theo dõi các đối tác vận hành và phân quyền tài khoản.</span>
                        </div>
                        <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#createOperatorModal">
                            <i class="bx bx-user-plus"></i> Thêm nhà xe
                        </button>
                    </div>

                    <% if (flashMessage != null) { %>
                        <div class="alert alert-<%= flashType != null ? flashType : "info" %> alert-dismissible" role="alert">
                            <%= flashMessage %>
                            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                        </div>
                    <% } %>

                    <div class="card">
                        <div class="card-header d-flex justify-content-between align-items-center flex-wrap gap-2">
                            <div>
                                <h5 class="card-title mb-0">Tổng quan nhà xe</h5>
                                <small class="text-muted">Hiện có <strong><%= operators.size() %></strong> tài khoản nhà xe.</small>
                            </div>
                        </div>
                        <div class="table-responsive">
                            <table class="table table-hover table-striped align-middle">
                                <thead>
                                <tr>
                                    <th>Mã nhân sự</th>
                                    <th>Nhà xe</th>
                                    <th>Email</th>
                                    <th>Điện thoại</th>
                                    <th>Trạng thái</th>
                                    <th>Ngày tạo</th>
                                    <th class="text-end">Thao tác</th>
                                </tr>
                                </thead>
                                <tbody>
                                <% if (operators.isEmpty()) { %>
                                    <tr>
                                        <td colspan="7" class="text-center text-muted py-4">Chưa có nhà xe nào.</td>
                                    </tr>
                                <% } else {
                                       for (User operator : operators) {
                                           String viewId = "viewOperatorModal" + operator.getUserId();
                                           String editId = "editOperatorModal" + operator.getUserId();
                                           String deleteId = "deleteOperatorModal" + operator.getUserId();
                                           String initials = operator.getFullName() != null && !operator.getFullName().isBlank()
                                                   ? operator.getFullName().substring(0, 1).toUpperCase()
                                                   : "O";
                                %>
                                    <tr>
                                        <td><strong><%= operator.getEmployeeCode() != null ? operator.getEmployeeCode() : "--" %></strong></td>
                                        <td>
                                            <div class="d-flex align-items-center gap-3">
                                                <div class="operator-avatar"><%= initials %></div>
                                                <div>
                                                    <div class="fw-semibold"><%= operator.getFullName() %></div>
                                                    <small class="text-muted"><%= operator.getAddress() != null ? operator.getAddress() : "Chưa cập nhật" %></small>
                                                </div>
                                            </div>
                                        </td>
                                        <td><%= operator.getEmail() %></td>
                                        <td><%= operator.getPhoneNumber() %></td>
                                        <td>
                                            <span class="badge bg-label-<%= "Active".equalsIgnoreCase(operator.getStatus()) ? "success" : "warning" %>">
                                                <%= operator.getStatus() %>
                                            </span>
                                        </td>
                                        <td>
                                            <%= operator.getCreatedAt() != null ? operator.getCreatedAt().format(dateFormatter) : "Chưa rõ" %>
                                        </td>
                                        <td class="text-end">
                                            <button type="button" class="btn btn-sm btn-icon btn-info text-white" data-bs-toggle="modal" data-bs-target="#<%= viewId %>">
                                                <i class="bx bx-show"></i>
                                            </button>
                                            <button type="button" class="btn btn-sm btn-icon btn-secondary" data-bs-toggle="modal" data-bs-target="#<%= editId %>">
                                                <i class="bx bx-edit"></i>
                                            </button>
                                            <button type="button" class="btn btn-sm btn-icon btn-danger" data-bs-toggle="modal" data-bs-target="#<%= deleteId %>">
                                                <i class="bx bx-trash"></i>
                                            </button>
                                        </td>
                                    </tr>
                                <%   }
                                   }
                                %>
                                </tbody>
                            </table>
                        </div>
                    </div>

                    <% if (!operators.isEmpty()) {
                           for (User operator : operators) {
                               String viewId = "viewOperatorModal" + operator.getUserId();
                               String editId = "editOperatorModal" + operator.getUserId();
                               String deleteId = "deleteOperatorModal" + operator.getUserId();
                    %>
                    <div class="modal fade" id="<%= viewId %>" tabindex="-1" aria-hidden="true">
                        <div class="modal-dialog modal-lg modal-dialog-centered">
                            <div class="modal-content">
                                <div class="modal-header">
                                    <h5 class="modal-title">Thông tin nhà xe #<%= operator.getUserId() %></h5>
                                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                </div>
                                <div class="modal-body">
                                    <div class="row g-4">
                                        <div class="col-md-4">
                                            <small class="text-muted text-uppercase">Mã nhân sự</small>
                                            <p class="fw-semibold mb-2"><%= operator.getEmployeeCode() != null ? operator.getEmployeeCode() : "--" %></p>
                                        </div>
                                        <div class="col-md-4">
                                            <small class="text-muted text-uppercase">Tên nhà xe</small>
                                            <p class="fw-semibold mb-2"><%= operator.getFullName() %></p>
                                        </div>
                                        <div class="col-md-4">
                                            <small class="text-muted text-uppercase">Trạng thái</small>
                                            <p class="fw-semibold mb-2"><%= operator.getStatus() %></p>
                                        </div>
                                        <div class="col-md-6">
                                            <small class="text-muted text-uppercase">Email</small>
                                            <p class="fw-semibold mb-2"><%= operator.getEmail() %></p>
                                        </div>
                                        <div class="col-md-6">
                                            <small class="text-muted text-uppercase">Điện thoại</small>
                                            <p class="fw-semibold mb-2"><%= operator.getPhoneNumber() %></p>
                                        </div>
                                        <div class="col-md-12">
                                            <small class="text-muted text-uppercase">Địa chỉ liên hệ</small>
                                            <p class="mb-0"><%= operator.getAddress() != null ? operator.getAddress() : "Chưa cập nhật" %></p>
                                        </div>
                                        <div class="col-md-6">
                                            <small class="text-muted text-uppercase">Ngày tạo</small>
                                            <p class="text-secondary mb-0">
                                                <%= operator.getCreatedAt() != null ? operator.getCreatedAt().format(dateFormatter) : "Chưa rõ" %>
                                            </p>
                                        </div>
                                        <div class="col-md-6">
                                            <small class="text-muted text-uppercase">Cập nhật gần nhất</small>
                                            <p class="text-secondary mb-0">
                                                <%= operator.getUpdatedAt() != null ? operator.getUpdatedAt().format(dateFormatter) : "Chưa rõ" %>
                                            </p>
                                        </div>
                                    </div>
                                </div>
                                <div class="modal-footer">
                                    <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Đóng</button>
                                    <button type="button" class="btn btn-primary" data-bs-dismiss="modal" data-bs-toggle="modal" data-bs-target="#<%= editId %>">
                                        <i class="bx bx-edit me-1"></i> Chỉnh sửa
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="modal fade" id="<%= editId %>" tabindex="-1" aria-hidden="true">
                        <div class="modal-dialog modal-lg modal-dialog-centered">
                            <div class="modal-content">
                                <form action="<%= contextPath %>/admin/operators" method="post" class="needs-validation" novalidate>
                                    <input type="hidden" name="action" value="update">
                                    <input type="hidden" name="userId" value="<%= operator.getUserId() %>">
                                    <div class="modal-header">
                                        <h5 class="modal-title">Cập nhật nhà xe <%= operator.getEmployeeCode() != null ? operator.getEmployeeCode() : "#" + operator.getUserId() %></h5>
                                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                    </div>
                                    <div class="modal-body">
                                        <div class="row g-3">
                                            <div class="col-md-6">
                                                <label class="form-label" for="operatorName<%= operator.getUserId() %>">Tên nhà xe</label>
                                                <input type="text" class="form-control" id="operatorName<%= operator.getUserId() %>" name="fullName" value="<%= operator.getFullName() %>" required>
                                            </div>
                                            <div class="col-md-6">
                                                <label class="form-label" for="operatorEmail<%= operator.getUserId() %>">Email</label>
                                                <input type="email" class="form-control" id="operatorEmail<%= operator.getUserId() %>" name="email" value="<%= operator.getEmail() %>" required>
                                            </div>
                                            <div class="col-md-6">
                                                <label class="form-label" for="operatorPhone<%= operator.getUserId() %>">Điện thoại</label>
                                                <input type="text" class="form-control" id="operatorPhone<%= operator.getUserId() %>" name="phoneNumber" value="<%= operator.getPhoneNumber() %>" required>
                                            </div>
                                            <div class="col-md-6">
                                                <label class="form-label" for="operatorStatus<%= operator.getUserId() %>">Trạng thái</label>
                                                <select class="form-select" id="operatorStatus<%= operator.getUserId() %>" name="status" required>
                                                    <% for (String status : statuses) { %>
                                                        <option value="<%= status %>" <%= status.equalsIgnoreCase(operator.getStatus()) ? "selected" : "" %>><%= status %></option>
                                                    <% } %>
                                                </select>
                                            </div>
                                            <div class="col-12">
                                                <label class="form-label" for="operatorAddress<%= operator.getUserId() %>">Địa chỉ</label>
                                                <textarea class="form-control" id="operatorAddress<%= operator.getUserId() %>" name="address" rows="2"><%= operator.getAddress() != null ? operator.getAddress() : "" %></textarea>
                                            </div>
                                            <div class="col-12">
                                                <label class="form-label" for="operatorPassword<%= operator.getUserId() %>">Đặt lại mật khẩu (tùy chọn)</label>
                                                <input type="password" class="form-control" id="operatorPassword<%= operator.getUserId() %>" name="password" placeholder="Nhập mật khẩu mới nếu muốn thay đổi">
                                                <div class="form-text">Để trống nếu không thay đổi mật khẩu.</div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="modal-footer">
                                        <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Hủy</button>
                                        <button type="submit" class="btn btn-primary">Lưu thay đổi</button>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>

                    <div class="modal fade" id="<%= deleteId %>" tabindex="-1" aria-hidden="true">
                        <div class="modal-dialog modal-dialog-centered">
                            <div class="modal-content">
                                <form action="<%= contextPath %>/admin/operators" method="post">
                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="userId" value="<%= operator.getUserId() %>">
                                    <div class="modal-header">
                                        <h5 class="modal-title">Xóa tài khoản nhà xe</h5>
                                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                    </div>
                                    <div class="modal-body">
                                        Bạn có chắc chắn muốn xóa nhà xe <strong><%= operator.getFullName() %></strong>?<br>
                                        Tất cả quyền truy cập vào bảng điều khiển nhà xe sẽ bị hủy.
                                    </div>
                                    <div class="modal-footer">
                                        <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Hủy</button>
                                        <button type="submit" class="btn btn-danger">Xóa</button>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>
                    <%       }
                       }
                    %>
                </div>
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="createOperatorModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content">
            <form action="<%= contextPath %>/admin/operators" method="post" class="needs-validation" novalidate>
                <input type="hidden" name="action" value="create">
                <div class="modal-header">
                    <h5 class="modal-title">Thêm nhà xe mới</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <div class="row g-3">
                        <div class="col-md-6">
                            <label class="form-label" for="createOperatorName">Tên nhà xe</label>
                            <input type="text" class="form-control" id="createOperatorName" name="fullName" required>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label" for="createOperatorEmail">Email</label>
                            <input type="email" class="form-control" id="createOperatorEmail" name="email" required>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label" for="createOperatorPhone">Điện thoại</label>
                            <input type="text" class="form-control" id="createOperatorPhone" name="phoneNumber" required>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label" for="createOperatorStatus">Trạng thái</label>
                            <select class="form-select" id="createOperatorStatus" name="status" required>
                                <% for (String status : statuses) { %>
                                    <option value="<%= status %>" <%= "Active".equals(status) ? "selected" : "" %>><%= status %></option>
                                <% } %>
                            </select>
                        </div>
                        <div class="col-12">
                            <label class="form-label" for="createOperatorAddress">Địa chỉ</label>
                            <textarea class="form-control" id="createOperatorAddress" name="address" rows="2"></textarea>
                        </div>
                        <div class="col-12">
                            <label class="form-label" for="createOperatorPassword">Mật khẩu gốc</label>
                            <input type="password" class="form-control" id="createOperatorPassword" name="password" required>
                            <div class="form-text">Mật khẩu sẽ được mã hóa SHA-256 trước khi lưu.</div>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Hủy</button>
                    <button type="submit" class="btn btn-primary">Tạo nhà xe</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script src="<%= vendorPath %>/libs/popper/popper.js"></script>
<script src="<%= vendorPath %>/js/bootstrap.js"></script>
<script src="<%= vendorPath %>/js/menu.js"></script>
<script src="<%= jsPath %>/main.js"></script>
</body>
</html>
