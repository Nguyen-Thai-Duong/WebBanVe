<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Collections" %>
<%@ page import="model.User" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%
    List<User> staffMembers = (List<User>) request.getAttribute("staffMembers");
    if (staffMembers == null) {
        staffMembers = Collections.emptyList();
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
        flashMessage = (String) session.getAttribute("staffMessage");
        flashType = (String) session.getAttribute("staffMessageType");
        if (flashMessage != null) {
            session.removeAttribute("staffMessage");
            session.removeAttribute("staffMessageType");
        }
    }

    request.setAttribute("activeMenu", "staff");
    request.setAttribute("navbarSearchPlaceholder", "Tìm kiếm nhân viên...");
    request.setAttribute("navbarSearchAriaLabel", "Tìm kiếm nhân viên...");
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
    <title>Quản lý nhân viên</title>

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
        .avatar-initials {
            width: 42px;
            height: 42px;
            border-radius: 50%;
            background-color: #e8f0ff;
            color: #4169e1;
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
                            <h4 class="fw-bold mb-1">Danh sách nhân viên</h4>
                            <span class="text-muted">Quản lý tài khoản và phân quyền nhân sự phòng vé.</span>
                        </div>
                        <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#createStaffModal">
                            <i class="bx bx-user-plus"></i> Thêm nhân viên
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
                                <h5 class="card-title mb-0">Tổng quan nhân sự</h5>
                                <small class="text-muted">Hiện có <strong><%= staffMembers.size() %></strong> nhân viên hoạt động.</small>
                            </div>
                        </div>
                        <div class="table-responsive">
                            <table class="table table-hover table-striped align-middle">
                                <thead>
                                <tr>
                                    <th>Mã nhân sự</th>
                                    <th>Nhân viên</th>
                                    <th>Email</th>
                                    <th>Điện thoại</th>
                                    <th>Trạng thái</th>
                                    <th>Ngày tạo</th>
                                    <th class="text-end">Thao tác</th>
                                </tr>
                                </thead>
                                <tbody>
                                <% if (staffMembers.isEmpty()) { %>
                                    <tr>
                                        <td colspan="7" class="text-center text-muted py-4">Chưa có nhân viên nào.</td>
                                    </tr>
                                <% } else {
                                       for (User staff : staffMembers) {
                                           String viewId = "viewStaffModal" + staff.getUserId();
                                           String editId = "editStaffModal" + staff.getUserId();
                                           String deleteId = "deleteStaffModal" + staff.getUserId();
                                           String initials = staff.getFullName() != null && !staff.getFullName().isBlank()
                                                   ? staff.getFullName().substring(0, 1).toUpperCase()
                                                   : "S";
                                %>
                                    <tr>
                                        <td><strong><%= staff.getEmployeeCode() != null ? staff.getEmployeeCode() : "--" %></strong></td>
                                        <td>
                                            <div class="d-flex align-items-center gap-3">
                                                <div class="avatar-initials"><%= initials %></div>
                                                <div>
                                                    <div class="fw-semibold"><%= staff.getFullName() %></div>
                                                    <small class="text-muted"><%= staff.getAddress() != null ? staff.getAddress() : "Chưa cập nhật" %></small>
                                                </div>
                                            </div>
                                        </td>
                                        <td><%= staff.getEmail() %></td>
                                        <td><%= staff.getPhoneNumber() %></td>
                                        <td>
                                            <span class="badge bg-label-<%= "Active".equalsIgnoreCase(staff.getStatus()) ? "success" : "secondary" %>">
                                                <%= staff.getStatus() %>
                                            </span>
                                        </td>
                                        <td>
                                            <%= staff.getCreatedAt() != null ? staff.getCreatedAt().format(dateFormatter) : "Chưa rõ" %>
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

                    <% if (!staffMembers.isEmpty()) {
                           for (User staff : staffMembers) {
                               String viewId = "viewStaffModal" + staff.getUserId();
                               String editId = "editStaffModal" + staff.getUserId();
                               String deleteId = "deleteStaffModal" + staff.getUserId();
                    %>
                    <div class="modal fade" id="<%= viewId %>" tabindex="-1" aria-hidden="true">
                        <div class="modal-dialog modal-lg modal-dialog-centered">
                            <div class="modal-content">
                                <div class="modal-header">
                                    <h5 class="modal-title">Thông tin nhân viên #<%= staff.getUserId() %></h5>
                                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                </div>
                                <div class="modal-body">
                                    <div class="row g-4">
                                        <div class="col-md-4">
                                            <small class="text-muted text-uppercase">Mã nhân sự</small>
                                            <p class="fw-semibold mb-2"><%= staff.getEmployeeCode() != null ? staff.getEmployeeCode() : "--" %></p>
                                        </div>
                                        <div class="col-md-4">
                                            <small class="text-muted text-uppercase">Họ và tên</small>
                                            <p class="fw-semibold mb-2"><%= staff.getFullName() %></p>
                                        </div>
                                        <div class="col-md-4">
                                            <small class="text-muted text-uppercase">Trạng thái</small>
                                            <p class="fw-semibold mb-2"><%= staff.getStatus() %></p>
                                        </div>
                                        <div class="col-md-6">
                                            <small class="text-muted text-uppercase">Email</small>
                                            <p class="fw-semibold mb-2"><%= staff.getEmail() %></p>
                                        </div>
                                        <div class="col-md-6">
                                            <small class="text-muted text-uppercase">Điện thoại</small>
                                            <p class="fw-semibold mb-2"><%= staff.getPhoneNumber() %></p>
                                        </div>
                                        <div class="col-md-12">
                                            <small class="text-muted text-uppercase">Địa chỉ</small>
                                            <p class="mb-0"><%= staff.getAddress() != null ? staff.getAddress() : "Chưa cập nhật" %></p>
                                        </div>
                                        <div class="col-md-6">
                                            <small class="text-muted text-uppercase">Ngày tạo</small>
                                            <p class="text-secondary mb-0">
                                                <%= staff.getCreatedAt() != null ? staff.getCreatedAt().format(dateFormatter) : "Chưa rõ" %>
                                            </p>
                                        </div>
                                        <div class="col-md-6">
                                            <small class="text-muted text-uppercase">Cập nhật gần nhất</small>
                                            <p class="text-secondary mb-0">
                                                <%= staff.getUpdatedAt() != null ? staff.getUpdatedAt().format(dateFormatter) : "Chưa rõ" %>
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
                                <form action="<%= contextPath %>/admin/staff" method="post" class="needs-validation" novalidate>
                                    <input type="hidden" name="action" value="update">
                                    <input type="hidden" name="userId" value="<%= staff.getUserId() %>">
                                    <div class="modal-header">
                                        <h5 class="modal-title">Cập nhật nhân viên <%= staff.getEmployeeCode() != null ? staff.getEmployeeCode() : "#" + staff.getUserId() %></h5>
                                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                    </div>
                                    <div class="modal-body">
                                        <div class="row g-3">
                                            <div class="col-md-6">
                                                <label class="form-label" for="fullName<%= staff.getUserId() %>">Họ và tên</label>
                                                <input type="text" class="form-control" id="fullName<%= staff.getUserId() %>" name="fullName" value="<%= staff.getFullName() %>" required>
                                            </div>
                                            <div class="col-md-6">
                                                <label class="form-label" for="email<%= staff.getUserId() %>">Email</label>
                                                <input type="email" class="form-control" id="email<%= staff.getUserId() %>" name="email" value="<%= staff.getEmail() %>" required>
                                            </div>
                                            <div class="col-md-6">
                                                <label class="form-label" for="phone<%= staff.getUserId() %>">Điện thoại</label>
                                                <input type="text" class="form-control" id="phone<%= staff.getUserId() %>" name="phoneNumber" value="<%= staff.getPhoneNumber() %>" required>
                                            </div>
                                            <div class="col-md-6">
                                                <label class="form-label" for="status<%= staff.getUserId() %>">Trạng thái</label>
                                                <select class="form-select" id="status<%= staff.getUserId() %>" name="status" required>
                                                    <% for (String status : statuses) { %>
                                                        <option value="<%= status %>" <%= status.equalsIgnoreCase(staff.getStatus()) ? "selected" : "" %>><%= status %></option>
                                                    <% } %>
                                                </select>
                                            </div>
                                            <div class="col-12">
                                                <label class="form-label" for="address<%= staff.getUserId() %>">Địa chỉ</label>
                                                <textarea class="form-control" id="address<%= staff.getUserId() %>" name="address" rows="2"><%= staff.getAddress() != null ? staff.getAddress() : "" %></textarea>
                                            </div>
                                            <div class="col-12">
                                                <label class="form-label" for="password<%= staff.getUserId() %>">Đặt lại mật khẩu (tùy chọn)</label>
                                                <input type="password" class="form-control" id="password<%= staff.getUserId() %>" name="password" placeholder="Nhập mật khẩu mới nếu muốn thay đổi">
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
                                <form action="<%= contextPath %>/admin/staff" method="post">
                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="userId" value="<%= staff.getUserId() %>">
                                    <div class="modal-header">
                                        <h5 class="modal-title">Xóa nhân viên</h5>
                                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                    </div>
                                    <div class="modal-body">
                                        Bạn có chắc chắn muốn xóa nhân viên <strong><%= staff.getFullName() %></strong>?<br>
                                        Thao tác này không thể hoàn tác và sẽ thu hồi quyền truy cập của nhân viên.
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

<div class="modal fade" id="createStaffModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content">
            <form action="<%= contextPath %>/admin/staff" method="post" class="needs-validation" novalidate>
                <input type="hidden" name="action" value="create">
                <div class="modal-header">
                    <h5 class="modal-title">Tạo nhân viên mới</h5>
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
                            <label class="form-label" for="createPassword">Mật khẩu mặc định</label>
                            <input type="password" class="form-control" id="createPassword" name="password" required>
                            <div class="form-text">Mật khẩu sẽ được mã hóa SHA-256 trước khi lưu.</div>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Hủy</button>
                    <button type="submit" class="btn btn-primary">Tạo nhân viên</button>
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
