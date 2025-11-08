<%@ page contentType="text/html;charset=UTF-8" language="java" %>
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
            <!-- Tổng quan -->
            <li class="menu-item ${pageContext.request.requestURI.endsWith('/dashboard.jsp') ? 'active' : ''}">
                <a href="${pageContext.request.contextPath}/bus-operator/dashboard" class="menu-link">
                    <i class="menu-icon tf-icons bx bx-home-circle"></i>
                    <div data-i18n="Analytics">Tổng quan</div>
                </a>
            </li>

            <!-- Tuyến đường -->
            <li class="menu-item ${pageContext.request.requestURI.endsWith('/routes.jsp') ? 'active' : ''}">
                <a href="${pageContext.request.contextPath}/bus-operator/routes" class="menu-link">
                    <i class="menu-icon tf-icons bx bx-map-alt"></i>
                    <div data-i18n="Routes">Tuyến đường</div>
                </a>
            </li>

            <!-- Xe -->
            <li class="menu-item ${pageContext.request.requestURI.endsWith('/vehicles.jsp') ? 'active' : ''}">
                <a href="${pageContext.request.contextPath}/bus-operator/vehicles" class="menu-link">
                    <i class="menu-icon tf-icons bx bx-bus"></i>
                    <div data-i18n="Vehicles">Quản lý xe</div>
                </a>
            </li>

            <!-- Chuyến xe -->
            <li class="menu-item ${pageContext.request.requestURI.endsWith('/trips.jsp') ? 'active' : ''}">
                <a href="${pageContext.request.contextPath}/bus-operator/trips" class="menu-link">
                    <i class="menu-icon tf-icons bx bx-calendar"></i>
                    <div data-i18n="Trips">Chuyến xe</div>
                </a>
            </li>

            <!-- Đặt vé -->
            <li class="menu-item ${pageContext.request.requestURI.endsWith('/bookings.jsp') ? 'active' : ''}">
                <a href="${pageContext.request.contextPath}/bus-operator/bookings" class="menu-link">
                    <i class="menu-icon tf-icons bx bx-receipt"></i>
                    <div data-i18n="Bookings">Đặt vé</div>
                </a>
            </li>

            <!-- Thống kê -->
            <li class="menu-item ${pageContext.request.requestURI.endsWith('/statistics.jsp') ? 'active' : ''}">
                <a href="${pageContext.request.contextPath}/bus-operator/statistics" class="menu-link">
                    <i class="menu-icon tf-icons bx bx-line-chart"></i>
                    <div data-i18n="Statistics">Thống kê</div>
                </a>
            </li>

            <!-- Tài khoản -->
            <li class="menu-item">
                <a href="javascript:void(0);" class="menu-link menu-toggle">
                    <i class="menu-icon tf-icons bx bx-user"></i>
                    <div data-i18n="Account">Tài khoản</div>
                </a>
                <ul class="menu-sub">
                    <li class="menu-item">
                        <a href="${pageContext.request.contextPath}/bus-operator/profile" class="menu-link">
                            <div data-i18n="Profile">Thông tin cá nhân</div>
                        </a>
                    </li>
                    <li class="menu-item">
                        <a href="${pageContext.request.contextPath}/bus-operator/password" class="menu-link">
                            <div data-i18n="Change Password">Đổi mật khẩu</div>
                        </a>
                    </li>
                    <li class="menu-item">
                        <a href="${pageContext.request.contextPath}/logout" class="menu-link">
                            <div data-i18n="Log Out">Đăng xuất</div>
                        </a>
                    </li>
                </ul>
            </li>
        </ul>
    </aside>
    <!-- / Menu -->