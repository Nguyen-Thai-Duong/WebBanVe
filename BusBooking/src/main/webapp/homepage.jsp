<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ page import="model.User" %>
        <% User currentUser=(User) session.getAttribute("currentUser"); String contextPath=request.getContextPath();
            String role=currentUser !=null ? currentUser.getRole() : null; String dashboardLink=null; String
            profileLink=null; String roleLabel=null; if (role !=null) { switch (role) { case "Admin" :
            dashboardLink=contextPath + "/admin/dashboard" ; roleLabel="Quản trị" ; break; case "Staff" :
            dashboardLink=contextPath + "/staff/dashboard" ; roleLabel="Nhân viên" ; break; case "BusOperator" :
            dashboardLink=contextPath + "/bus-operator/dashboard" ; roleLabel="Điều hành" ; break; case "Customer" :
            default: roleLabel="Khách hàng" ; profileLink=contextPath + "/customer/profile" ; break; } } %>
            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1">
                <meta name="description" content="Đặt vé xe khách liên tỉnh trực tuyến cùng FUTA Bus Lines.">
                <title>FUTA Bus Lines</title>
                <link rel="shortcut icon"
                    href="https://storage.googleapis.com/futa-busline-web-cms-prod/2257_x_501_px_2ecaaa00d0/2257_x_501_px_2ecaaa00d0.png">
                <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
                <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/boxicons@2.1.4/css/boxicons.min.css">
                <link rel="preconnect" href="https://fonts.googleapis.com">
                <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
                <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/homepage.css">
                <link
                    href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap&subset=latin-ext,vietnamese"
                    rel="stylesheet">
            </head>

            <body>
                <header>
                    <div class="topbar py-2">
                        <div class="container d-flex align-items-center justify-content-between flex-wrap gap-2">
                            <div class="d-flex align-items-center gap-3">
                                <a href="#" class="text-white text-decoration-none"><i class="bx bxl-apple"></i> Tải
                                    App</a>
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
                                                        <div class="fw-semibold">Xin chào, <%= currentUser.getFullName()
                                                                %>
                                                        </div>
                                                        <small class="text-white-50">
                                                            <%= roleLabel %>
                                                                <% if (currentUser.getEmployeeCode() !=null &&
                                                                    !currentUser.getEmployeeCode().isBlank()) { %> · Mã:
                                                                    <%= currentUser.getEmployeeCode() %>
                                                                        <% } %>
                                                        </small>
                                                    </div>
                                                </div>
                                            </a>
                                            <% } else { %>
                                                <div class="d-flex align-items-center gap-2 text-white">
                                                    <i class="bx bx-user-circle fs-4 text-warning"></i>
                                                    <div class="lh-sm">
                                                        <div class="fw-semibold">Xin chào, <%= currentUser.getFullName()
                                                                %>
                                                        </div>
                                                        <small class="text-white-50">
                                                            <%= roleLabel %>
                                                                <% if (currentUser.getEmployeeCode() !=null &&
                                                                    !currentUser.getEmployeeCode().isBlank()) { %> · Mã:
                                                                    <%= currentUser.getEmployeeCode() %>
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
                            <a class="navbar-brand d-flex align-items-center gap-2" href="#">
                                <img src="https://cdn.futabus.vn/futa-busline-web-cms-prod/Logo_Futa_Moi_98dac5d84a/Logo_Futa_Moi_98dac5d84a.png"
                                    alt="FUTA" height="42">
                            </a>
                            <button class="navbar-toggler" type="button" data-bs-toggle="collapse"
                                data-bs-target="#mainNav" aria-controls="mainNav" aria-expanded="false"
                                aria-label="Toggle navigation">
                                <span class="navbar-toggler-icon"></span>
                            </button>
                            <div class="collapse navbar-collapse" id="mainNav">
                                <ul class="navbar-nav ms-auto gap-lg-3 text-center">
                                    <li class="nav-item"><a class="nav-link active" href="#">Trang chủ</a></li>
                                    <li class="nav-item"><a class="nav-link" href="#schedule">Lịch trình</a></li>
                                    <li class="nav-item"><a class="nav-link" href="#ticket">Tra cứu vé</a></li>
                                    <li class="nav-item"><a class="nav-link" href="#news">Tin tức</a></li>
                                    <li class="nav-item"><a class="nav-link" href="#contact">Liên hệ</a></li>
                                    <li class="nav-item"><a class="nav-link" href="#about">Về chúng tôi</a></li>
                                </ul>
                            </div>
                        </div>
                    </nav>
                    <section class="hero d-flex align-items-end">
                        <div class="container hero-content">
                            <h1>FUTA Bus Lines – Đặt vé trực tuyến dễ dàng, an tâm mỗi hành trình</h1>
                            <p>Tận hưởng trải nghiệm đặt vé xe khách nhanh chóng với hàng nghìn tuyến xe mỗi ngày, hỗ
                                trợ trung chuyển và nhiều ưu đãi hấp dẫn.</p>
                            <% if (currentUser !=null) { %>
                                <div class="alert alert-warning d-inline-flex align-items-center gap-2 mt-3 shadow-sm"
                                    role="status">
                                    <i class="bx bx-smile fs-4 text-warning"></i>
                                    <span>Chào mừng trở lại, <strong>
                                            <%= currentUser.getFullName() %>
                                        </strong>!<% if ("Customer".equals(role)) { %> Sẵn sàng đặt chuyến tiếp theo của
                                            bạn chứ?<% } else if (dashboardLink !=null) { %> Truy cập bảng điều khiển để
                                                quản lý vận hành nhanh chóng.<% } %></span>
                                </div>
                                <% } %>
                        </div>
                    </section>
                </header>
                <main>
                    <section class="container position-relative">
                        <div class="search-card" id="schedule">
                            <form action="<%= contextPath %>/trips/search" method="POST"
                                class="d-flex flex-column flex-lg-row align-items-lg-center gap-4">
                                <div class="flex-grow-1">
                                    <label class="form-label text-uppercase fw-semibold text-secondary">Điểm đi</label>
                                    <input type="text" name="departure" class="form-control form-control-lg"
                                        placeholder="Chọn điểm khởi hành" required>
                                </div>
                                <button class="btn btn-light rounded-circle shadow" type="button"
                                    aria-label="Đổi điểm đi/đến">
                                    <i class="bx bx-transfer-alt fs-3 text-secondary"></i>
                                </button>
                                <div class="flex-grow-1">
                                    <label class="form-label text-uppercase fw-semibold text-secondary">Điểm đến</label>
                                    <input type="text" name="destination" class="form-control form-control-lg"
                                        placeholder="Chọn điểm đến" required>
                                </div>
                                <div class="flex-grow-1">
                                    <label class="form-label text-uppercase fw-semibold text-secondary">Ngày đi</label>
                                    <input type="date" name="departureDate" class="form-control form-control-lg"
                                        value="2025-10-23" required>
                                </div>
                                <div class="flex-grow-1">
                                    <label class="form-label text-uppercase fw-semibold text-secondary">Số vé</label>
                                    <select name="passengers" class="form-select form-select-lg">
                                        <option value="1" selected>1 hành khách</option>
                                        <option value="2">2 hành khách</option>
                                        <option value="3">3 hành khách</option>
                                        <option value="4">4 hành khách</option>
                                    </select>
                                </div>
                                <div class="d-flex flex-column flex-lg-row gap-3">
                                    <button class="btn btn-lg btn-warning text-white px-4" type="submit">
                                        <strong>
                                            <%= currentUser==null || "Customer" .equals(role) ? "Tìm chuyến xe"
                                                : "Tìm chuyến" %>
                                        </strong>
                                    </button>
                                    <% if (currentUser !=null && dashboardLink !=null && !"Customer".equals(role)) { %>
                                        <a class="btn btn-lg btn-outline-warning text-white px-4"
                                            href="<%= dashboardLink %>">
                                            <strong>Vào bảng điều khiển</strong>
                                        </a>
                                        <% } %>
                                </div>
                            </form>
                            <div class="divider"></div>
                            <div class="d-flex flex-column flex-lg-row gap-3 justify-content-between">
                                <div>
                                    <h6 class="text-secondary text-uppercase mb-2">Tìm kiếm gần đây</h6>
                                    <div class="d-flex flex-wrap gap-3">
                                        <span class="badge text-bg-light px-3 py-2">Cần Thơ – TP. Hồ Chí Minh ·
                                            23/10/2025</span>
                                        <span class="badge text-bg-light px-3 py-2">An Giang – Đà Lạt ·
                                            25/10/2025</span>
                                    </div>
                                </div>
                                <div>
                                    <a class="text-decoration-none" href="https://futabus.vn/huong-dan-dat-ve-tren-web"
                                        target="_blank" rel="noreferrer">
                                        <i class="bx bx-play-circle text-warning"></i> Hướng dẫn đặt vé trực tuyến
                                    </a>
                                </div>
                            </div>
                        </div>
                    </section>

                    <section class="py-5 py-lg-6" id="promotions">
                        <div class="container text-center">
                            <p class="section-title mb-2">Khuyến mãi nổi bật</p>
                            <h2 class="section-subtitle">Ưu đãi dành riêng cho bạn</h2>
                            <div class="row g-4 mt-1">
                                <div class="col-sm-6 col-lg-4">
                                    <article class="promo-card h-100">
                                        <img src="https://cdn.futabus.vn/futa-busline-web-cms-prod/1029x552_0b98877a44/1029x552_0b98877a44.jpg"
                                            alt="Khuyến mãi 1">
                                        <div class="p-4 text-start">
                                            <span class="badge bg-warning text-dark mb-3">Hot</span>
                                            <h5>Đặt vé online – giảm ngay 5%</h5>
                                            <p class="text-secondary">Thanh toán qua ứng dụng ngân hàng hoặc ví điện tử
                                                để nhận ưu đãi tối đa 50.000đ.</p>
                                        </div>
                                    </article>
                                </div>
                                <div class="col-sm-6 col-lg-4">
                                    <article class="promo-card h-100">
                                        <img src="https://cdn.futabus.vn/futa-busline-web-cms-prod/599_4x_8_a11d2fd200/599_4x_8_a11d2fd200.png"
                                            alt="Khuyến mãi 2">
                                        <div class="p-4 text-start">
                                            <span class="badge bg-warning text-dark mb-3">Voucher</span>
                                            <h5>Ưu đãi ShopeePay tháng 10</h5>
                                            <p class="text-secondary">Nhập mã FUTASPP để nhận giảm giá lên đến 30.000đ
                                                cho mỗi giao dịch.</p>
                                        </div>
                                    </article>
                                </div>
                                <div class="col-sm-6 col-lg-4">
                                    <article class="promo-card h-100">
                                        <img src="https://cdn.futabus.vn/futa-busline-web-cms-prod/343x184_2_660000a524/343x184_2_660000a524.png"
                                            alt="Khuyến mãi 3">
                                        <div class="p-4 text-start">
                                            <span class="badge bg-warning text-dark mb-3">Combo</span>
                                            <h5>Combo vé + trung chuyển miễn phí</h5>
                                            <p class="text-secondary">Đặt vé tuyến Sài Gòn – Đà Lạt nhận ngay dịch vụ
                                                trung chuyển miễn phí tại thành phố đích.</p>
                                        </div>
                                    </article>
                                </div>
                            </div>
                        </div>
                    </section>

                    <section class="py-5 bg-light" id="popular-routes">
                        <div class="container">
                            <div class="row align-items-center g-4">
                                <div class="col-lg-5">
                                    <p class="section-title mb-2">Tuyến phổ biến</p>
                                    <h2 class="section-subtitle mb-3">Lựa chọn hàng đầu của hành khách</h2>
                                    <p class="text-secondary">FUTA Bus Lines phục vụ hơn 6.500 chuyến xe mỗi ngày, kết
                                        nối hơn 350 phòng vé & bưu cục trên toàn quốc. Đặt vé ngay để tận hưởng hành
                                        trình an toàn, tiện nghi.</p>
                                    <ul class="list-unstyled text-secondary mt-4">
                                        <li class="mb-2"><i class="bx bx-check-circle text-success"></i> Trung chuyển
                                            tận nơi tại các thành phố lớn</li>
                                        <li class="mb-2"><i class="bx bx-check-circle text-success"></i> Ghế ngồi/giường
                                            nằm chất lượng cao</li>
                                        <li><i class="bx bx-check-circle text-success"></i> Hỗ trợ 24/7 qua tổng đài
                                            1900 6067</li>
                                    </ul>
                                </div>
                                <div class="col-lg-7">
                                    <div class="row g-4">
                                        <div class="col-sm-6">
                                            <article class="route-card h-100 p-4">
                                                <div class="d-flex justify-content-between align-items-center mb-3">
                                                    <span class="badge">Tuyến HOT</span>
                                                    <span class="text-secondary">8 giờ · 310 km</span>
                                                </div>
                                                <h5 class="mb-1">TP. Hồ Chí Minh → Đà Lạt</h5>
                                                <p class="fw-semibold text-warning mb-3">290.000đ</p>
                                                <p class="text-secondary">Khởi hành 10 chuyến mỗi ngày, giường nằm cao
                                                    cấp, phục vụ khăn lạnh và nước uống.</p>
                                            </article>
                                        </div>
                                        <div class="col-sm-6">
                                            <article class="route-card h-100 p-4">
                                                <div class="d-flex justify-content-between align-items-center mb-3">
                                                    <span class="badge">Được yêu thích</span>
                                                    <span class="text-secondary">5 giờ · 172 km</span>
                                                </div>
                                                <h5 class="mb-1">Cần Thơ → TP. Hồ Chí Minh</h5>
                                                <p class="fw-semibold text-warning mb-3">165.000đ</p>
                                                <p class="text-secondary">Lịch trình linh hoạt mỗi giờ, hỗ trợ trung
                                                    chuyển nội thành Cần Thơ và TP.HCM.</p>
                                            </article>
                                        </div>
                                        <div class="col-sm-6">
                                            <article class="route-card h-100 p-4">
                                                <div class="d-flex justify-content-between align-items-center mb-3">
                                                    <span class="badge">Mới</span>
                                                    <span class="text-secondary">14 giờ · 700 km</span>
                                                </div>
                                                <h5 class="mb-1">Đà Lạt → Đà Nẵng</h5>
                                                <p class="fw-semibold text-warning mb-3">430.000đ</p>
                                                <p class="text-secondary">Xe giường nằm cao cấp, suất ăn nhẹ giữa hành
                                                    trình và điểm dừng 5 sao.</p>
                                            </article>
                                        </div>
                                        <div class="col-sm-6">
                                            <article class="route-card h-100 p-4">
                                                <div class="d-flex justify-content-between align-items-center mb-3">
                                                    <span class="badge">Phổ biến</span>
                                                    <span class="text-secondary">10 giờ · 506 km</span>
                                                </div>
                                                <h5 class="mb-1">Đà Nẵng → Nha Trang</h5>
                                                <p class="fw-semibold text-warning mb-3">380.000đ</p>
                                                <p class="text-secondary">Hành trình ven biển tuyệt đẹp, hỗ trợ gửi hàng
                                                    và trung chuyển trong nội thành.</p>
                                            </article>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </section>

                    <section class="py-5" id="stats">
                        <div class="container">
                            <div class="stats">
                                <div class="row g-4">
                                    <div class="col-md-4 text-center text-md-start">
                                        <h3>40M+</h3>
                                        <p class="mb-0">Lượt khách phục vụ mỗi năm trên toàn quốc</p>
                                    </div>
                                    <div class="col-md-4 text-center text-md-start">
                                        <h3>350+</h3>
                                        <p class="mb-0">Phòng vé, trạm trung chuyển và bến xe</p>
                                    </div>
                                    <div class="col-md-4 text-center text-md-start">
                                        <h3>6,500+</h3>
                                        <p class="mb-0">Chuyến xe đường dài và liên tỉnh mỗi ngày</p>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </section>

                    <section class="py-5 bg-light" id="news">
                        <div class="container">
                            <p class="section-title text-center mb-2">Tin tức mới</p>
                            <h2 class="section-subtitle text-center">Cập nhật từ FUTA Bus Lines</h2>
                            <div id="newsCarousel" class="carousel slide mt-4" data-bs-ride="carousel">
                                <div class="carousel-inner">
                                    <div class="carousel-item active">
                                        <div class="row g-4">
                                            <div class="col-md-4">
                                                <article class="news-card h-100">
                                                    <img src="https://cdn.futabus.vn/futa-busline-web-cms-prod/599_Dat_ve_Online_10b0c4557f/599_Dat_ve_Online_10b0c4557f.jpg"
                                                        alt="Tin tức 1">
                                                    <div class="p-4">
                                                        <p class="text-secondary mb-1">16/09/2025</p>
                                                        <h5>Đặt vé FUTA online, khởi hành ngay – Deal hời trong tay</h5>
                                                        <p class="text-secondary">Tận hưởng ưu đãi khi đặt vé trực tuyến
                                                            qua website hoặc ứng dụng FUTA.</p>
                                                    </div>
                                                </article>
                                            </div>
                                            <div class="col-md-4">
                                                <article class="news-card h-100">
                                                    <img src="https://cdn.futabus.vn/futa-busline-web-cms-prod/599_b79445cf98/599_b79445cf98.png"
                                                        alt="Tin tức 2">
                                                    <div class="p-4">
                                                        <p class="text-secondary mb-1">10/06/2025</p>
                                                        <h5>Trải nghiệm dịch vụ trung chuyển đón trả tận nơi tại TP.HCM
                                                        </h5>
                                                        <p class="text-secondary">FUTA mở rộng vùng trung chuyển, giúp
                                                            hành khách di chuyển thuận tiện hơn.</p>
                                                    </div>
                                                </article>
                                            </div>
                                            <div class="col-md-4">
                                                <article class="news-card h-100">
                                                    <img src="https://cdn.futabus.vn/futa-busline-web-cms-prod/Website_599x337px_f228dc3a1e/Website_599x337px_f228dc3a1e.png"
                                                        alt="Tin tức 3">
                                                    <div class="p-4">
                                                        <p class="text-secondary mb-1">09/10/2025</p>
                                                        <h5>Khai trương văn phòng Phú Tài – Quy Nhơn</h5>
                                                        <p class="text-secondary">Bổ sung thêm điểm bán vé và trung
                                                            chuyển tại khu vực miền Trung.</p>
                                                    </div>
                                                </article>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="carousel-item">
                                        <div class="row g-4">
                                            <div class="col-md-4">
                                                <article class="news-card h-100">
                                                    <img src="https://cdn.futabus.vn/futa-busline-web-cms-prod/599x337_e82d3428db/599x337_e82d3428db.png"
                                                        alt="Tin tức 4">
                                                    <div class="p-4">
                                                        <p class="text-secondary mb-1">01/10/2025</p>
                                                        <h5>Khai trương văn phòng Long Hồ – Vĩnh Long</h5>
                                                        <p class="text-secondary">Hành khách miền Tây có thêm lựa chọn
                                                            đặt vé, gửi hàng tiện lợi.</p>
                                                    </div>
                                                </article>
                                            </div>
                                            <div class="col-md-4">
                                                <article class="news-card h-100">
                                                    <img src="https://cdn.futabus.vn/futa-busline-web-cms-prod/599_x_337_px_8f00e38d2d/599_x_337_px_8f00e38d2d.jpg"
                                                        alt="Tin tức 5">
                                                    <div class="p-4">
                                                        <p class="text-secondary mb-1">22/10/2025</p>
                                                        <h5>Thay đổi thời gian hoạt động văn phòng Ngã Sáu – Cần Thơ
                                                        </h5>
                                                        <p class="text-secondary">Cập nhật giờ hoạt động mới nhằm phục
                                                            vụ hành khách tốt hơn.</p>
                                                    </div>
                                                </article>
                                            </div>
                                            <div class="col-md-4">
                                                <article class="news-card h-100">
                                                    <img src="https://cdn.futabus.vn/futa-busline-web-cms-prod/SPP_T10_5232e5bfde/SPP_T10_5232e5bfde.jpg"
                                                        alt="Tin tức 6">
                                                    <div class="p-4">
                                                        <p class="text-secondary mb-1">10/10/2025</p>
                                                        <h5>Tháng 10 rộn ràng – Thanh toán ShopeePay, ưu đãi ngập tràn
                                                        </h5>
                                                        <p class="text-secondary">Hoàn tiền ngay khi thanh toán vé FUTA
                                                            bằng ShopeePay trong tháng 10.</p>
                                                    </div>
                                                </article>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <button class="carousel-control-prev" type="button" data-bs-target="#newsCarousel"
                                    data-bs-slide="prev">
                                    <span class="carousel-control-prev-icon" aria-hidden="true"></span>
                                    <span class="visually-hidden">Previous</span>
                                </button>
                                <button class="carousel-control-next" type="button" data-bs-target="#newsCarousel"
                                    data-bs-slide="next">
                                    <span class="carousel-control-next-icon" aria-hidden="true"></span>
                                    <span class="visually-hidden">Next</span>
                                </button>
                            </div>
                        </div>
                    </section>

                    <section class="py-5" id="contact">
                        <div class="container">
                            <div class="row g-4 align-items-center">
                                <div class="col-lg-7">
                                    <p class="section-title mb-2">Kết nối FUTA Group</p>
                                    <h2 class="section-subtitle mb-3">Ứng dụng FUTA – Hệ sinh thái vận chuyển toàn diện
                                    </h2>
                                    <p class="text-secondary">Chỉ với một ứng dụng, bạn có thể đặt vé xe khách, xe buýt,
                                        xe hợp đồng, gửi hàng và hơn thế nữa. Tải ngay để quản lý hành trình và nhận
                                        thông báo lịch chạy chỉ với một chạm.</p>
                                    <div class="d-flex flex-wrap gap-3 mt-4">
                                        <a class="btn btn-outline-dark d-flex align-items-center gap-2 px-3"
                                            href="http://onelink.to/futa.ios" target="_blank" rel="noreferrer">
                                            <i class="bx bxl-apple fs-3"></i>
                                            <span>
                                                <small>Tải trên</small><br>
                                                <strong>App Store</strong>
                                            </span>
                                        </a>
                                        <a class="btn btn-outline-dark d-flex align-items-center gap-2 px-3"
                                            href="http://onelink.to/futa.android" target="_blank" rel="noreferrer">
                                            <i class="bx bxl-play-store fs-3"></i>
                                            <span>
                                                <small>Tải trên</small><br>
                                                <strong>Google Play</strong>
                                            </span>
                                        </a>
                                    </div>
                                </div>
                                <div class="col-lg-5 text-center">
                                    <img class="img-fluid"
                                        src="https://cdn.futabus.vn/futa-busline-cms-dev/1_ketnoi_3c401512ac/1_ketnoi_3c401512ac.svg"
                                        alt="Kết nối FUTA">
                                </div>
                            </div>
                        </div>
                    </section>
                </main>
                <footer class="footer pt-5">
                    <div class="container">
                        <div class="row g-4">
                            <div class="col-lg-5">
                                <img src="https://cdn.futabus.vn/futa-busline-web-cms-prod/Logo_Futa_Moi_98dac5d84a/Logo_Futa_Moi_98dac5d84a.png"
                                    alt="FUTA" height="52">
                                <p class="mt-3 text-secondary">Công ty Cổ phần Xe khách Phương Trang – FUTA Bus Lines.
                                    Chất lượng là danh dự, phục vụ tận tâm trên mọi hành trình.</p>
                                <p class="mb-1"><strong>Hotline:</strong> 1900 6067</p>
                                <p class="mb-1"><strong>Email:</strong> <a href="mailto:hotro@futa.vn">hotro@futa.vn</a>
                                </p>
                                <p class="mb-1"><strong>Địa chỉ:</strong> 486-486A Lê Văn Lương, Phường Tân Hưng, Quận
                                    7, TP.HCM</p>
                                <div class="d-flex gap-3 mt-3">
                                    <a href="https://www.facebook.com/xephuongtrang" target="_blank" rel="noreferrer"
                                        class="text-secondary fs-4"><i class="bx bxl-facebook-circle"></i></a>
                                    <a href="https://www.youtube.com/channel/UCs32uT002InnxFnfXCRN48A" target="_blank"
                                        rel="noreferrer" class="text-secondary fs-4"><i class="bx bxl-youtube"></i></a>
                                </div>
                            </div>
                            <div class="col-lg-3 col-md-6">
                                <h6 class="text-uppercase fw-semibold text-secondary">FUTA Bus Lines</h6>
                                <ul class="list-unstyled mt-3 text-secondary">
                                    <li class="mb-2"><a href="#about">Về chúng tôi</a></li>
                                    <li class="mb-2"><a href="#schedule">Lịch trình</a></li>
                                    <li class="mb-2"><a href="https://vieclam.futabus.vn" target="_blank"
                                            rel="noreferrer">Tuyển dụng</a></li>
                                    <li class="mb-2"><a href="#news">Tin tức & Sự kiện</a></li>
                                    <li><a href="#contact">Kết nối FUTA</a></li>
                                </ul>
                            </div>
                            <div class="col-lg-4 col-md-6">
                                <h6 class="text-uppercase fw-semibold text-secondary">Hỗ trợ</h6>
                                <ul class="list-unstyled mt-3 text-secondary">
                                    <li class="mb-2"><a href="#ticket">Tra cứu thông tin đặt vé</a></li>
                                    <li class="mb-2"><a href="https://futabus.vn/dieu-khoan-su-dung" target="_blank"
                                            rel="noreferrer">Điều khoản sử dụng</a></li>
                                    <li class="mb-2"><a href="https://futabus.vn/hoi-dap" target="_blank"
                                            rel="noreferrer">Câu hỏi thường gặp</a></li>
                                    <li class="mb-2"><a href="https://futabus.vn/huong-dan-dat-ve-tren-web"
                                            target="_blank" rel="noreferrer">Hướng dẫn đặt vé</a></li>
                                    <li><a href="https://futabus.vn/danh-sach-chi-nhanh" target="_blank"
                                            rel="noreferrer">Mạng lưới văn phòng</a></li>
                                </ul>
                            </div>
                        </div>
                        <div class="text-center text-secondary py-4 mt-4 border-top border-light">
                            © <%= java.time.Year.now() %> FUTA Bus Lines. Chịu trách nhiệm nội dung: Ông Võ Duy Thành.
                        </div>
                    </div>
                </footer>
                <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
            </body>

            </html>