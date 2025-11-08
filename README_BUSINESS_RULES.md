# Business Rules Documentation

## Giới Thiệu (Introduction)

Tài liệu này mô tả chi tiết các quy tắc nghiệp vụ của Hệ Thống Đặt Vé Xe (Bus Booking System). Tất cả các quy tắc được trích xuất trực tiếp từ mã nguồn thực tế của hệ thống.

This document describes in detail the business rules of the Bus Booking System. All rules are extracted directly from the actual system source code.

## Mục Đích (Purpose)

- **Làm rõ yêu cầu nghiệp vụ**: Giúp các bên liên quan hiểu rõ cách hệ thống hoạt động
- **Hướng dẫn phát triển**: Cung cấp tài liệu tham khảo cho lập trình viên
- **Kiểm thử**: Cơ sở để tạo test cases
- **Bảo trì**: Dễ dàng onboarding cho thành viên mới
- **Tuân thủ**: Đảm bảo tính nhất quán trong toàn hệ thống

## Tài Liệu Chính (Main Document)

📄 **[BUSINESS_RULES.md](./BUSINESS_RULES.md)** - Tài liệu quy tắc nghiệp vụ đầy đủ

## Cấu Trúc Tài Liệu (Document Structure)

Tài liệu được chia thành 13 phần chính:

### 1. Quản Lý Người Dùng & Vai Trò
- Các vai trò trong hệ thống (Admin, Staff, BusOperator, Customer)
- Trạng thái tài khoản
- Mã nhân viên tự động
- Thông tin người dùng bắt buộc và tùy chọn

### 2. Xác Thực & Phân Quyền
- Quy trình đăng ký
- Quy trình đăng nhập
- Quên mật khẩu & đặt lại
- Mã hóa mật khẩu (SHA-256)
- Phân quyền theo vai trò

### 3. Quản Lý Tuyến Đường
- Thông tin tuyến (điểm đi, điểm đến, khoảng cách)
- Trạng thái tuyến (Active/Inactive)
- Ràng buộc duy nhất

### 4. Quản Lý Phương Tiện
- Thông tin xe (biển số, sức chứa, model)
- Trạng thái xe (Available, InTrip, InMaintenance, Retired)
- Liên kết với nhà điều hành

### 5. Quản Lý Chuyến Đi
- Thông tin chuyến đi (tuyến, giờ, giá vé)
- Trạng thái chuyến (Scheduled, Departed, Arrived, Delayed, Cancelled)
- Validation và tính toán thời gian

### 6. Quản Lý Đặt Chỗ
- Booking cho Customer vs Guest
- Trạng thái booking và ghế
- Thời gian giữ chỗ (TTL)

### 7. Quản Lý Vé
- Quan hệ 1-1 giữa Booking và Ticket
- Mã vé duy nhất
- Quy trình check-in
- Trạng thái vé (Issued, Used, Void)

### 8. Quản Lý Thanh Toán
- Loại giao dịch (Payment, Refund, Fee)
- Phương thức thanh toán
- Mã tham chiếu từ Payment Gateway

### 9. Quản Lý Đánh Giá
- Đánh giá chuyến đi
- Rating từ 1-5 sao
- Nhận xét tùy chọn

### 10. Quản Lý Hỗ Trợ
- Support ticket cho Customer và Guest
- Trạng thái ticket (Open, InProgress, Closed)
- Quy trình xử lý

### 11. Kiểm Tra & Xác Thực Dữ Liệu
- Input validators (số, tên, tiền)
- Database constraints
- Foreign key relationships

### 12. Các Quy Tắc Kỹ Thuật
- Logging với SLF4J + Logback
- Transaction management
- Database connection handling
- Error handling
- Date/Time handling

### 13. Bảo Mật
- Mã hóa mật khẩu
- Session security
- Input sanitization
- Authorization
- OTP cho password reset

## Nguồn Dữ Liệu (Data Sources)

Các quy tắc nghiệp vụ được trích xuất từ:

1. **Database Schema** (`DB_BusBooking.txt`)
   - Cấu trúc bảng
   - Constraints
   - Foreign keys
   - Check constraints

2. **Model Classes** (Package `model`)
   - Entity definitions
   - Field validations
   - Relationships

3. **DAO Classes** (Package `DAO`)
   - Data access logic
   - Transaction handling
   - Business rules at data layer

4. **Controller Classes** (Package `controller`)
   - Request handling
   - Input validation
   - Business logic
   - Authorization checks

5. **Utility Classes** (Package `util`)
   - InputValidator
   - PasswordUtils
   - OtpGenerator

6. **Security Filters** (Package `filter`)
   - AdminAuthorizationFilter
   - StaffAuthorizationFilter
   - BusOperatorAuthorizationFilter

## Cách Sử Dụng (How to Use)

### Cho Lập Trình Viên (For Developers)
- Tham khảo khi implement tính năng mới
- Đảm bảo tuân thủ các quy tắc validation
- Hiểu rõ business logic trước khi code

### Cho Kiểm Thử Viên (For Testers)
- Tạo test cases dựa trên quy tắc
- Kiểm tra boundary conditions
- Verify constraints và validations

### Cho Business Analysts
- Hiểu rõ cách hệ thống hoạt động
- Validate requirements
- Identify gaps hoặc inconsistencies

### Cho Product Owners
- Review business logic
- Plan new features
- Ensure system meets business needs

## Cập Nhật Tài Liệu (Updating Documentation)

Khi có thay đổi trong hệ thống:

1. **Code changes**: Cập nhật BUSINESS_RULES.md để phản ánh thay đổi
2. **New features**: Thêm section mới hoặc mở rộng section hiện tại
3. **Deprecated rules**: Đánh dấu rõ ràng và giải thích lý do
4. **Version**: Cập nhật version number và ngày tháng

## Liên Hệ & Đóng Góp (Contact & Contribution)

Nếu bạn phát hiện:
- Quy tắc nghiệp vụ thiếu sót
- Thông tin không chính xác
- Cần bổ sung chi tiết

Vui lòng tạo issue hoặc pull request trong repository.

## License

Tài liệu này là một phần của Bus Booking System project.

---

**Lưu ý**: Tài liệu được tạo tự động từ phân tích mã nguồn. Luôn verify với code thực tế khi có thắc mắc.

**Note**: This documentation is automatically generated from source code analysis. Always verify with actual code when in doubt.
