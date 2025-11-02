<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <% String contextPath=request.getContextPath(); User currentUser=(User) session.getAttribute("currentUser");
            String role=currentUser !=null ? currentUser.getRole() : null; String dashboardLink=null; String
            profileLink=null; String roleLabel=null; if (role !=null) { switch (role) { case "Admin" :
            dashboardLink=contextPath + "/admin/dashboard" ; roleLabel="Quản trị" ; break; case "Staff" :
            dashboardLink=contextPath + "/staff/dashboard" ; roleLabel="Nhân viên" ; break; case "BusOperator" :
            dashboardLink=contextPath + "/bus-operator/dashboard" ; roleLabel="Điều hành" ; break; case "Customer" :
            default: roleLabel="Khách hàng" ; profileLink=contextPath + "/customer/profile" ; break; } } %>
            <header>
                <div class="topbar py-2">
                    <div class="container d-flex align-items-center justify-content-between flex-wrap gap-2">
                        <div class="d-flex align-items-center gap-3">
                            <a href="#" class="text-white text-decoration-none"><i class="bx bxl-apple"></i> Tải App</a>
                            <a href="#" class="text-white text-decoration-none"><i class="bx bx-globe"></i> VI</a>
                            <a href="#" class="text-white text-decoration-none">EN</a>
                        </div>
                        <div class="d-flex align-items-center gap-2">
                            <% if (currentUser==null) { %>
                                <a href="<%= contextPath %>/login-form.jsp"
                                    class="btn btn-light btn-sm rounded-pill px-3 d-flex align-items-center gap-2">
                                    <i class="bx bx-user-circle fs-5 text-warning"></i>
                                    <span>Đăng nhập</span>
                                </a>
                                <a href="<%= contextPath %>/register-form.jsp"
                                    class="btn btn-outline-light btn-sm rounded-pill px-3 d-flex align-items-center gap-2">
                                    <i class="bx bx-edit-alt fs-5"></i>
                                    <span>Đăng ký</span>
                                </a>
                                <% } else { %>
                                    <% if (profileLink !=null) { %>
                                        <a href="<%= profileLink %>" class="text-white text-decoration-none">
                                            <div class="d-flex align-items-center gap-2 text-white"
                                                style="cursor: pointer;">
                                                <i class="bx bx-user-circle fs-4 text-warning"></i>
                                                <div class="lh-sm">
                                                    <div class="fw-semibold">Xin chào, <%= currentUser.getFullName() %>
                                                    </div>
                                                    <small class="text-white-50">
                                                        <%= roleLabel %>
                                                            <% if (currentUser.getEmployeeCode() !=null &&
                                                                !currentUser.getEmployeeCode().isBlank()) { %> · Mã: <%=
                                                                    currentUser.getEmployeeCode() %>
                                                                    <% } %>
                                                    </small>
                                                </div>
                                            </div>
                                        </a>
                                        <% } else { %>
                                            <div class="d-flex align-items-center gap-2 text-white">
                                                <i class="bx bx-user-circle fs-4 text-warning"></i>
                                                <div class="lh-sm">
                                                    <div class="fw-semibold">Xin chào, <%= currentUser.getFullName() %>
                                                    </div>
                                                    <small class="text-white-50">
                                                        <%= roleLabel %>
                                                            <% if (currentUser.getEmployeeCode() !=null &&
                                                                !currentUser.getEmployeeCode().isBlank()) { %> · Mã: <%=
                                                                    currentUser.getEmployeeCode() %>
                                                                    <% } %>
                                                    </small>
                                                </div>
                                            </div>
                                            <% } %>
                                                <a href="<%= contextPath %>/logout"
                                                    class="btn btn-outline-light btn-sm rounded-pill px-3 d-flex align-items-center gap-2">
                                                    <i class="bx bx-log-out fs-5"></i>
                                                    <span>Đăng xuất</span>
                                                </a>
                                                <% } %>
                        </div>
                    </div>
                </div>
                <nav class="main-nav navbar navbar-expand-lg navbar-dark py-3">
                    <div class="container">
                        <a class="navbar-brand d-flex align-items-center gap-2" href="<%= contextPath %>">
                            <img src="https://cdn.futabus.vn/futa-busline-web-cms-prod/Logo_Futa_Moi_98dac5d84a/Logo_Futa_Moi_98dac5d84a.png"
                                alt="FUTA" height="42">
                        </a>
                        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#mainNav"
                            aria-controls="mainNav" aria-expanded="false" aria-label="Toggle navigation">
                            <span class="navbar-toggler-icon"></span>
                        </button>
                        <div class="collapse navbar-collapse" id="mainNav">
                            <ul class="navbar-nav ms-auto gap-lg-3 text-center">
                                <li class="nav-item"><a class="nav-link" href="<%= contextPath %>">Trang chủ</a></li>
                                <li class="nav-item"><a class="nav-link active" href="#schedule">Lịch trình</a></li>
                                <li class="nav-item"><a class="nav-link" href="#ticket">Tra cứu vé</a></li>
                                <li class="nav-item"><a class="nav-link" href="#news">Tin tức</a></li>
                                <li class="nav-item"><a class="nav-link" href="#contact">Liên hệ</a></li>
                                <li class="nav-item"><a class="nav-link" href="#about">Về chúng tôi</a></li>
                            </ul>
                        </div>
                    </div>
                </nav>
            </header>