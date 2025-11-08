<%@ page contentType="text/html" pageEncoding="UTF-8" %>
    <%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

        <!-- Menu -->
        <aside id="layout-menu" class="layout-menu menu-vertical menu bg-menu-theme">
            <div class="app-brand demo">
                <a href="${pageContext.request.contextPath}/homepage.jsp" class="app-brand-link">
                    <span class="app-brand-logo demo">
                        <img src="https://cdn.futabus.vn/assets/images/logo-img.png" alt="Logo" height="50">
                    </span>
                    <span class="app-brand-text demo menu-text fw-bolder ms-2">FUTA Bus</span>
                </a>

                <a href="javascript:void(0);" class="layout-menu-toggle menu-link text-large ms-auto d-block d-xl-none">
                    <i class="bx bx-chevron-left bx-sm align-middle"></i>
                </a>
            </div>

            <div class="menu-inner-shadow"></div>

            <ul class="menu-inner py-1">
                <!-- Dashboard -->
                <li class="menu-item ${pageContext.request.requestURI.endsWith('/dashboard.jsp') ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/bus-operator/dashboard" class="menu-link">
                        <i class="menu-icon tf-icons bx bx-home-circle"></i>
                        <div>Tổng quan</div>
                    </a>
                </li>

                <!-- Routes -->
                <li class="menu-item ${pageContext.request.requestURI.endsWith('/routes.jsp') ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/bus-operator/routes" class="menu-link">
                        <i class="menu-icon tf-icons bx bx-map-alt"></i>
                        <div>Tuyến đường</div>
                    </a>
                </li>

                <!-- Vehicles -->
                <li class="menu-item ${pageContext.request.requestURI.endsWith('/vehicles.jsp') ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/bus-operator/vehicles" class="menu-link">
                        <i class="menu-icon tf-icons bx bx-bus"></i>
                        <div>Quản lý xe</div>
                    </a>
                </li>

                <!-- Trips -->
                <li class="menu-item ${pageContext.request.requestURI.endsWith('/trips.jsp') ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/bus-operator/trips" class="menu-link">
                        <i class="menu-icon tf-icons bx bx-calendar"></i>
                        <div>Lịch trình</div>
                    </a>
                </li>

                <!-- Bookings -->
                <li class="menu-item ${pageContext.request.requestURI.endsWith('/bookings.jsp') ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/bus-operator/bookings" class="menu-link">
                        <i class="menu-icon tf-icons bx bx-receipt"></i>
                        <div>Đặt vé</div>
                    </a>
                </li>

                <!-- Stats -->
                <li class="menu-item ${pageContext.request.requestURI.endsWith('/statistics.jsp') ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/bus-operator/statistics" class="menu-link">
                        <i class="menu-icon tf-icons bx bx-line-chart"></i>
                        <div>Thống kê</div>
                    </a>
                </li>

                <!-- Settings -->
                <li class="menu-header small text-uppercase">
                    <span class="menu-header-text">Cài đặt</span>
                </li>

                <li class="menu-item">
                    <a href="javascript:void(0);" class="menu-link menu-toggle">
                        <i class="menu-icon tf-icons bx bx-user"></i>
                        <div>Tài khoản</div>
                    </a>
                    <ul class="menu-sub">
                        <li class="menu-item">
                            <a href="${pageContext.request.contextPath}/bus-operator/profile" class="menu-link">
                                <div>Thông tin cá nhân</div>
                            </a>
                        </li>
                        <li class="menu-item">
                            <a href="${pageContext.request.contextPath}/bus-operator/password" class="menu-link">
                                <div>Đổi mật khẩu</div>
                            </a>
                        </li>
                    </ul>
                </li>

                <!-- Support -->
                <li class="menu-item">
                    <a href="${pageContext.request.contextPath}/bus-operator/support" class="menu-link">
                        <i class="menu-icon tf-icons bx bx-support"></i>
                        <div>Hỗ trợ</div>
                    </a>
                </li>
            </ul>
        </aside>
        <!-- / Menu -->