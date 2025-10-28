<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Collections" %>
<%@ page import="model.User" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%
    List<User> customers = (List<User>) request.getAttribute("customers");
    if (customers == null) {
        customers = Collections.emptyList();
    }

    String contextPath = request.getContextPath();
    String assetBase = contextPath + "/assets/sneat-1.0.0/assets";
    String vendorPath = assetBase + "/vendor";
    String cssPath = assetBase + "/css";
    String jsPath = assetBase + "/js";
    String imgPath = assetBase + "/img";

    String flashMessage = (String) request.getAttribute("flashMessage");
    String flashType = (String) request.getAttribute("flashType");
    if (flashMessage == null) {
        flashMessage = (String) session.getAttribute("staffCustomerMessage");
        flashType = (String) session.getAttribute("staffCustomerMessageType");
        if (flashMessage != null) {
            session.removeAttribute("staffCustomerMessage");
            session.removeAttribute("staffCustomerMessageType");
        }
    }

    DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
    String[] statuses = {"Active", "Inactive", "Suspended", "Locked"};
%>
<!DOCTYPE html>
<html lang="vi" class="light-style layout-menu-fixed" dir="ltr" data-theme="theme-default" data-assets-path="<%= assetBase %>/" data-template="vertical-menu-template-free">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý khách hàng</title>

    <link rel="icon" type="image/x-icon" href="<%= imgPath %>/favicon/favicon.ico" />
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap&subset=latin-ext,vietnamese" rel="stylesheet" />

    <link rel="stylesheet" href="<%= vendorPath %>/fonts/boxicons.css" />
    <link rel="stylesheet" href="<%= vendorPath %>/css/core.css" class="template-customizer-core-css" />
    <link rel="stylesheet" href="<%= vendorPath %>/css/theme-default.css" class="template-customizer-theme-css" />
    <link rel="stylesheet" href="<%= cssPath %>/demo.css" />
    <link rel="stylesheet" href="<%= vendorPath %>/libs/perfect-scrollbar/perfect-scrollbar.css" />

    <script src="<%= vendorPath %>/js/helpers.js"></script>
    <script src="<%= jsPath %>/config.js"></script>

    <style>
        .table thead th { white-space: nowrap; }
        .customer-avatar {
            width: 42px;
            height: 42px;
            border-radius: 50%;
            background-color: #f0f2ff;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 600;
            color: #5f61e6;
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
                            <h4 class="fw-bold mb-1">Danh sách khách hàng</h4>
                            <span class="text-muted">Tạo mới, xem và chỉnh sửa thông tin khách hàng.</span>
                        </div>
                        <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#createCustomerModal">
                            <i class="bx bx-user-plus"></i> Thêm khách hàng
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
                                <h5 class="card-title mb-0">Tổng quan khách hàng</h5>
                                <small class="text-muted">Hiện có <strong><%= customers.size() %></strong> khách hàng.</small>
                            </div>
                        </div>
                        <div class="table-responsive">
                            <table class="table table-hover table-striped align-middle">
                                <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>Khách hàng</th>
                                    <th>Email</th>
                                    <th>Điện thoại</th>
                                    <th>Trạng thái</th>
                                    <th>Ngày tạo</th>
                                    <th class="text-end">Thao tác</th>
                                </tr>
                                </thead>
                                <tbody>
                                <% if (customers.isEmpty()) { %>
                                    <tr>
                                        <td colspan="7" class="text-center text-muted py-4">Chưa có khách hàng nào.</td>
                                    </tr>
                                <% } else {
                                       for (User customer : customers) {
                                           String initials = customer.getFullName() != null && !customer.getFullName().isBlank()
                                                   ? customer.getFullName().substring(0, 1).toUpperCase()
                                                   : "C";
                                           String viewId = "viewCustomerModal" + customer.getUserId();
                                           String editId = "editCustomerModal" + customer.getUserId();
                                %>
                                    <tr>
                                        <td><strong>#<%= customer.getUserId() %></strong></td>
                                        <td>
                                            <div class="d-flex align-items-center gap-3">
                                                <div class="customer-avatar"><%= initials %></div>
                                                <div>
                                                    <div class="fw-semibold"><%= customer.getFullName() %></div>
                                                    <small class="text-muted"><%= customer.getAddress() != null ? customer.getAddress() : "" %></small>
                                                </div>
                                            </div>
                                        </td>
                                        <td><%= customer.getEmail() %></td>
                                        <td><%= customer.getPhoneNumber() %></td>
                                        <td>
                                            <span class="badge bg-label-<%= "Active".equalsIgnoreCase(customer.getStatus()) ? "success" : "secondary" %>">
                                                <%= customer.getStatus() %>
                                            </span>
                                        </td>
                                        <td><%= customer.getCreatedAt() != null ? customer.getCreatedAt().format(dateFormatter) : "Chưa rõ" %></td>
                                        <td class="text-end">
                                            <button type="button" class="btn btn-sm btn-icon btn-info text-white" data-bs-toggle="modal" data-bs-target="#<%= viewId %>">
                                                <i class="bx bx-show"></i>
                                            </button>
                                            <button type="button" class="btn btn-sm btn-icon btn-primary" data-bs-toggle="modal" data-bs-target="#<%= editId %>">
                                                <i class="bx bx-edit"></i>
                                            </button>
                                        </td>
                                    </tr>

                                    <div class="modal fade" id="<%= viewId %>" tabindex="-1" aria-hidden="true">
                                        <div class="modal-dialog modal-lg modal-dialog-centered">
                                            <div class="modal-content">
                                                <div class="modal-header">
                                                    <h5 class="modal-title">Thông tin khách hàng #<%= customer.getUserId() %></h5>
                                                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                                </div>
                                                <div class="modal-body">
                                                    <div class="row g-4">
                                                        <div class="col-md-6">
                                                            <small class="text-muted text-uppercase">Họ và tên</small>
                                                            <p class="fw-semibold mb-2"><%= customer.getFullName() %></p>
                                                        </div>
                                                        <div class="col-md-6">
                                                            <small class="text-muted text-uppercase">Email</small>
                                                            <p class="fw-semibold mb-2"><%= customer.getEmail() %></p>
                                                        </div>
                                                        <div class="col-md-6">
                                                            <small class="text-muted text-uppercase">Điện thoại</small>
                                                            <p class="fw-semibold mb-2"><%= customer.getPhoneNumber() %></p>
                                                        </div>
                                                        <div class="col-md-6">
                                                            <small class="text-muted text-uppercase">Trạng thái</small>
                                                            <p class="fw-semibold mb-2"><%= customer.getStatus() %></p>
                                                        </div>
                                                        <div class="col-md-12">
                                                            <small class="text-muted text-uppercase">Địa chỉ</small>
                                                            <p class="mb-0"><%= customer.getAddress() != null ? customer.getAddress() : "Chưa cập nhật" %></p>
                                                        </div>
                                                        <div class="col-md-6">
                                                            <small class="text-muted text-uppercase">Ngày tạo</small>
                                                            <p class="text-secondary mb-0"><%= customer.getCreatedAt() != null ? customer.getCreatedAt().format(dateFormatter) : "Chưa rõ" %></p>
                                                        </div>
                                                        <div class="col-md-6">
                                                            <small class="text-muted text-uppercase">Cập nhật gần nhất</small>
                                                            <p class="text-secondary mb-0"><%= customer.getUpdatedAt() != null ? customer.getUpdatedAt().format(dateFormatter) : "Chưa rõ" %></p>
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
                                                <form action="<%= contextPath %>/staff/customers" method="post" class="needs-validation" novalidate>
                                                    <input type="hidden" name="action" value="update">
                                                    <input type="hidden" name="userId" value="<%= customer.getUserId() %>">
                                                    <div class="modal-header">
                                                        <h5 class="modal-title">Cập nhật khách hàng #<%= customer.getUserId() %></h5>
                                                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                                    </div>
                                                    <div class="modal-body">
                                                        <div class="row g-3">
                                                            <div class="col-md-6">
                                                                <label class="form-label" for="fullName<%= customer.getUserId() %>">Họ và tên</label>
                                                                <input type="text" class="form-control" id="fullName<%= customer.getUserId() %>" name="fullName" value="<%= customer.getFullName() %>" required>
                                                            </div>
                                                            <div class="col-md-6">
                                                                <label class="form-label" for="email<%= customer.getUserId() %>">Email</label>
                                                                <input type="email" class="form-control" id="email<%= customer.getUserId() %>" name="email" value="<%= customer.getEmail() %>" required>
                                                            </div>
                                                            <div class="col-md-6">
                                                                <label class="form-label" for="phone<%= customer.getUserId() %>">Điện thoại</label>
                                                                <input type="text" class="form-control" id="phone<%= customer.getUserId() %>" name="phoneNumber" value="<%= customer.getPhoneNumber() %>" required>
                                                            </div>
                                                            <div class="col-md-6">
                                                                <label class="form-label" for="status<%= customer.getUserId() %>">Trạng thái</label>
                                                                <select class="form-select" id="status<%= customer.getUserId() %>" name="status" required>
                                                                    <% for (String status : statuses) { %>
                                                                        <option value="<%= status %>" <%= status.equalsIgnoreCase(customer.getStatus()) ? "selected" : "" %>><%= status %></option>
                                                                    <% } %>
                                                                </select>
                                                            </div>
                                                            <div class="col-12">
                                                                <label class="form-label" for="address<%= customer.getUserId() %>">Địa chỉ</label>
                                                                <textarea class="form-control" id="address<%= customer.getUserId() %>" name="address" rows="2"><%= customer.getAddress() != null ? customer.getAddress() : "" %></textarea>
                                                            </div>
                                                            <div class="col-12">
                                                                <label class="form-label" for="password<%= customer.getUserId() %>">Đặt lại mật khẩu (tùy chọn)</label>
                                                                <input type="password" class="form-control" id="password<%= customer.getUserId() %>" name="password" placeholder="Nhập mật khẩu mới nếu muốn thay đổi">
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
                                <%   }
                                   }
                                %>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="createCustomerModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content">
            <form action="<%= contextPath %>/staff/customers" method="post" class="needs-validation" novalidate>
                <input type="hidden" name="action" value="create">
                <div class="modal-header">
                    <h5 class="modal-title">Tạo khách hàng mới</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <div class="row g-3">
                        <div class="col-md-6">
                            <label class="form-label" for="createFullName">Họ và tên</label>
                            <input type="text" class="form-control" id="createFullName" name="fullName" required>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label" for="createEmail">Email</label>
                            <input type="email" class="form-control" id="createEmail" name="email" required>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label" for="createPhone">Điện thoại</label>
                            <input type="text" class="form-control" id="createPhone" name="phoneNumber" required>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label" for="createStatus">Trạng thái</label>
                            <select class="form-select" id="createStatus" name="status" required>
                                <% for (String status : statuses) { %>
                                    <option value="<%= status %>" <%= "Active".equals(status) ? "selected" : "" %>><%= status %></option>
                                <% } %>
                            </select>
                        </div>
                        <div class="col-12">
                            <label class="form-label" for="createAddress">Địa chỉ</label>
                            <textarea class="form-control" id="createAddress" name="address" rows="2"></textarea>
                        </div>
                        <div class="col-12">
                            <label class="form-label" for="createPassword">Mật khẩu</label>
                            <input type="password" class="form-control" id="createPassword" name="password" required>
                            <div class="form-text">Mật khẩu sẽ được mã hóa SHA-256 trước khi lưu.</div>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Hủy</button>
                    <button type="submit" class="btn btn-primary">Tạo khách hàng</button>
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
