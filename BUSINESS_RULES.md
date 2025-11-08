# Quy Tắc Nghiệp Vụ - Hệ Thống Đặt Vé Xe (Bus Booking System)

## Mục Lục
1. [Quản Lý Người Dùng & Vai Trò](#1-quản-lý-người-dùng--vai-trò)
2. [Xác Thực & Phân Quyền](#2-xác-thực--phân-quyền)
3. [Quản Lý Tuyến Đường](#3-quản-lý-tuyến-đường)
4. [Quản Lý Phương Tiện](#4-quản-lý-phương-tiện)
5. [Quản Lý Chuyến Đi](#5-quản-lý-chuyến-đi)
6. [Quản Lý Đặt Chỗ](#6-quản-lý-đặt-chỗ)
7. [Quản Lý Vé](#7-quản-lý-vé)
8. [Quản Lý Thanh Toán](#8-quản-lý-thanh-toán)
9. [Quản Lý Đánh Giá](#9-quản-lý-đánh-giá)
10. [Quản Lý Hỗ Trợ](#10-quản-lý-hỗ-trợ)
11. [Kiểm Tra & Xác Thực Dữ Liệu](#11-kiểm-tra--xác-thực-dữ-liệu)

---

## 1. Quản Lý Người Dùng & Vai Trò

### 1.1. Vai Trò Người Dùng
- Hệ thống hỗ trợ 4 vai trò chính:
  - **Admin**: Quản trị viên hệ thống
  - **Staff**: Nhân viên hỗ trợ khách hàng
  - **BusOperator**: Nhà điều hành xe buýt
  - **Customer**: Khách hàng

### 1.2. Trạng Thái Tài Khoản
- Tài khoản có 3 trạng thái:
  - **Active**: Hoạt động bình thường
  - **Inactive**: Tạm ngưng hoạt động
  - **Blocked**: Bị khóa
- Chỉ tài khoản có trạng thái `Active` mới được phép đăng nhập vào hệ thống

### 1.3. Mã Nhân Viên (EmployeeCode)
- Mã nhân viên được tự động sinh theo vai trò:
  - Admin: `AD` + 3 số (VD: AD001, AD002)
  - Staff: `ST` + 3 số (VD: ST001, ST002)
  - BusOperator: `BO` + 3 số (VD: BO001, BO002)
  - Customer: `CST` + số UserID (VD: CST01, CST123)
- Mã nhân viên là duy nhất trong toàn hệ thống
- Mã được tính toán tự động và không thể thay đổi thủ công

### 1.4. Thông Tin Người Dùng
- **Bắt buộc**:
  - Họ và tên (FullName)
  - Email (phải duy nhất)
  - Số điện thoại (phải duy nhất)
  - Mật khẩu
  - Vai trò
- **Tùy chọn**:
  - Địa chỉ

### 1.5. Audit Trail
- Mỗi người dùng có:
  - `CreatedAt`: Thời gian tạo tài khoản
  - `UpdatedAt`: Thời gian cập nhật lần cuối
- Các trường này được tự động cập nhật bởi hệ thống

---

## 2. Xác Thực & Phân Quyền

### 2.1. Đăng Ký Khách Hàng
- Khách hàng có thể tự đăng ký tài khoản
- Quy tắc đăng ký:
  - Họ tên: Bắt buộc, không được để trống
  - Số điện thoại: 
    - Bắt buộc
    - Phải có định dạng: 10-11 chữ số
    - Bắt đầu bằng số 0
    - Regex pattern: `^0[0-9]{9,10}$`
    - Phải duy nhất trong hệ thống
  - Email:
    - Bắt buộc
    - Phải duy nhất trong hệ thống
  - Mật khẩu:
    - Bắt buộc
    - Độ dài tối thiểu: 8 ký tự
    - Phải khớp với xác nhận mật khẩu
  - Điều khoản sử dụng: Phải đồng ý

### 2.2. Đăng Nhập
- Người dùng có thể đăng nhập bằng:
  - Email HOẶC Số điện thoại
  - Mật khẩu
- Quy tắc đăng nhập:
  - Cả hai trường đều bắt buộc
  - Tài khoản phải tồn tại trong hệ thống
  - Mật khẩu phải đúng (sử dụng SHA-256 hash)
  - Tài khoản phải có trạng thái `Active`
- Nếu đăng nhập thành công, người dùng được chuyển hướng theo vai trò:
  - Admin → `/admin/dashboard`
  - BusOperator → `/bus-operator/dashboard`
  - Staff → `/staff/dashboard`
  - Customer → `/homepage.jsp`

### 2.3. Quên Mật Khẩu & Đặt Lại Mật Khẩu
- Người dùng có thể yêu cầu đặt lại mật khẩu qua email
- Hệ thống gửi mã OTP để xác thực
- Mật khẩu mới phải tuân thủ quy tắc mật khẩu (tối thiểu 8 ký tự)

### 2.4. Mã Hóa Mật Khẩu
- Tất cả mật khẩu được mã hóa bằng SHA-256
- Không lưu trữ mật khẩu dạng plain text

### 2.5. Phân Quyền Truy Cập
- **URL Pattern `/admin/*`**: 
  - Chỉ cho phép vai trò: Admin, Staff, BusOperator
  - Người dùng phải đăng nhập
  - Vai trò không phù hợp → chuyển hướng về `/homepage.jsp`
- **URL Pattern `/staff/*`**:
  - Chỉ cho phép vai trò: Staff
- **URL Pattern `/bus-operator/*`**:
  - Chỉ cho phép vai trò: BusOperator

### 2.6. Session Management
- Thông tin người dùng được lưu trong session với key `currentUser`
- Khi logout, session được invalidate hoàn toàn
- Thông tin nhạy cảm (password hash) không được lưu trong session

---

## 3. Quản Lý Tuyến Đường

### 3.1. Thông Tin Tuyến Đường
- **Bắt buộc**:
  - Điểm đi (Origin)
  - Điểm đến (Destination)
- **Tùy chọn**:
  - Khoảng cách (Distance) - số thập phân
  - Thời gian di chuyển (DurationMinutes) - số nguyên, >= 0

### 3.2. Trạng Thái Tuyến Đường
- Tuyến đường có 2 trạng thái:
  - **Active**: Đang hoạt động
  - **Inactive**: Ngưng hoạt động
- Mặc định khi tạo: `Active`

### 3.3. Ràng Buộc Duy Nhất
- Cặp (Origin, Destination) phải duy nhất trong hệ thống
- Không được tạo 2 tuyến đường giống nhau

### 3.4. Validation
- Origin và Destination không được trống
- Khoảng cách (nếu có) phải >= 0
- Thời gian di chuyển (nếu có) phải >= 0

---

## 4. Quản Lý Phương Tiện

### 4.1. Thông Tin Phương Tiện
- **Bắt buộc**:
  - Mã nhân viên điều hành (EmployeeCode) - phải là BusOperator
  - Biển số xe (LicensePlate) - phải duy nhất
  - Sức chứa (Capacity) - phải > 0
- **Tùy chọn**:
  - Model xe
  - Khoảng thời gian bảo trì (MaintenanceIntervalDays)
  - Ngày bảo trì lần cuối (LastMaintenanceDate)
  - Ngày sửa chữa lần cuối (LastRepairDate)
  - Chi tiết bổ sung (Details)
  - Tình trạng hiện tại (CurrentCondition)

### 4.2. Trạng Thái Phương Tiện
- Phương tiện có các trạng thái:
  - **Available**: Sẵn sàng sử dụng
  - **InTrip**: Đang trong chuyến đi
  - **InMaintenance**: Đang bảo trì
  - **Retired**: Ngưng hoạt động vĩnh viễn
- Mặc định khi tạo: `Available`

### 4.3. Liên Kết với Nhà Điều Hành
- Mỗi phương tiện phải được gán cho một BusOperator (qua EmployeeCode)
- Foreign key tham chiếu đến bảng USER thông qua cột EmployeeCode

### 4.4. Ngày Thêm Phương Tiện
- `DateAdded` được tự động gán khi tạo phương tiện mới
- Giá trị mặc định: thời điểm hiện tại

### 4.5. Validation
- Biển số xe phải duy nhất
- Sức chứa phải là số dương (> 0)
- EmployeeCode phải tồn tại và thuộc vai trò BusOperator

---

## 5. Quản Lý Chuyến Đi

### 5.1. Thông Tin Chuyến Đi
- **Bắt buộc**:
  - Tuyến đường (RouteID)
  - Thời gian khởi hành (DepartureTime)
  - Giá vé (Price) - phải >= 0
  - Phương tiện (VehicleID)
  - Nhà điều hành (OperatorID) - phải là BusOperator
- **Tùy chọn**:
  - Thời gian đến (ArrivalTime)

### 5.2. Trạng Thái Chuyến Đi
- Chuyến đi có các trạng thái:
  - **Scheduled**: Đã lên lịch
  - **Departed**: Đã khởi hành
  - **Arrived**: Đã đến nơi
  - **Delayed**: Bị trễ
  - **Cancelled**: Đã hủy
- Mặc định khi tạo: `Scheduled`

### 5.3. Validation Chuyến Đi
- RouteID phải tồn tại và tuyến đường phải ở trạng thái `Active`
- VehicleID phải tồn tại
- OperatorID phải tồn tại và có vai trò BusOperator
- Giá vé phải là số hợp lệ và >= 0
- Thời gian khởi hành không được trống
- Nếu có ArrivalTime, phải sau DepartureTime

### 5.4. Tính Toán Thời Gian
- Hệ thống hỗ trợ tính toán:
  - Thời lượng chuyến đi (Duration) = ArrivalTime - DepartureTime
  - Số phút (DurationMinutesTotal)
  - Số giờ (DurationHoursPart)
  - Số phút lẻ (DurationMinutesPart)

### 5.5. Giới Hạn Tạo Chuyến
- Có thể có giới hạn số lượng chuyến đi mỗi tuyến (MAX_TRIPS_PER_ROUTE = 5)
  - Lưu ý: Quy tắc này được khai báo nhưng có thể chưa được enforce

---

## 6. Quản Lý Đặt Chỗ

### 6.1. Loại Booking
Hệ thống hỗ trợ 2 loại đặt chỗ:
1. **Customer Booking**: Khách hàng đã đăng ký
   - Có UserID
   - GuestPhoneNumber và GuestEmail = NULL
2. **Guest Booking**: Khách vãng lai
   - UserID = NULL
   - Phải có GuestPhoneNumber
   - Có thể có GuestEmail

### 6.2. Ràng Buộc Customer hoặc Guest
- Mỗi booking phải có:
  - UserID (Customer) HOẶC
  - GuestPhoneNumber (Guest)
- Không được cả hai đều NULL
- Database constraint: `CHK_CUSTOMER_OR_GUEST`

### 6.3. Thông Tin Booking
- **Bắt buộc**:
  - Chuyến đi (TripID)
  - Số ghế (SeatNumber)
  - Thông tin khách (UserID hoặc GuestPhoneNumber)
- **Tự động**:
  - Ngày đặt (BookingDate) - mặc định: thời điểm hiện tại
  - Trạng thái đặt chỗ (BookingStatus) - mặc định: `Pending`
  - Trạng thái ghế (SeatStatus) - mặc định: `Booked`
- **Tùy chọn**:
  - Thời gian hết hạn giữ chỗ (TTL_Expiry)

### 6.4. Trạng Thái Booking
- **BookingStatus** có các giá trị:
  - **Pending**: Chờ xác nhận
  - **Confirmed**: Đã xác nhận
  - **Cancelled**: Đã hủy
  - **Void**: Vô hiệu

### 6.5. Trạng Thái Ghế
- **SeatStatus** có các giá trị:
  - **Booked**: Đã đặt
  - **Reserved**: Đang giữ chỗ
  - **Cancelled**: Đã hủy

### 6.6. Thời Gian Giữ Chỗ (TTL)
- TTL_Expiry: Thời gian hết hạn cho việc giữ chỗ tạm thời
- Sau khi hết hạn, ghế có thể được giải phóng cho khách khác

### 6.7. Validation Booking
- TripID phải tồn tại
- SeatNumber không được trống
- Phải có UserID hoặc GuestPhoneNumber (ít nhất một)
- Mỗi ghế trên một chuyến đi chỉ có thể được đặt một lần (không trùng SeatNumber cho cùng TripID)

---

## 7. Quản Lý Vé

### 7.1. Quan Hệ Booking - Ticket
- Mỗi Ticket liên kết 1-1 với một Booking
- BookingID trong bảng TICKET là UNIQUE
- Một Booking chỉ có thể có một Ticket

### 7.2. Thông Tin Vé
- **Bắt buộc**:
  - Booking liên quan (BookingID)
  - Mã vé (TicketNumber) - phải duy nhất
- **Tự động**:
  - Trạng thái vé (TicketStatus) - mặc định: `Issued`
  - Ngày phát hành (IssuedDate) - mặc định: thời điểm hiện tại
- **Tùy chọn**:
  - Nhân viên check-in (CheckedInBy)
  - Thời gian check-in (CheckedInAt)

### 7.3. Trạng Thái Vé
- **TicketStatus** có các giá trị:
  - **Issued**: Đã phát hành
  - **Used**: Đã sử dụng
  - **Void**: Vô hiệu

### 7.4. Mã Vé (TicketNumber)
- Mã vé được tự động sinh
- Phải duy nhất trong toàn hệ thống
- Có thể sử dụng làm QR code hoặc barcode
- Format: UUID hoặc pattern đặc biệt (ví dụ: `TKT-{TripID}-{UUID}`)

### 7.5. Quy Trình Tạo Vé Vật Lý
- Hệ thống hỗ trợ tạo vé trực tiếp (Physical Ticket):
  1. Tạo Booking với trạng thái `Confirmed`
  2. Tạo Ticket liên kết với Booking
  3. Cả hai thao tác phải thành công trong một transaction
  4. Nếu một bước thất bại, rollback toàn bộ

### 7.6. Check-in Vé
- Chỉ Staff có quyền check-in vé
- Khi check-in:
  - TicketStatus → `Used`
  - CheckedInBy → UserID của Staff
  - CheckedInAt → Thời điểm hiện tại
  - BookingStatus → `Confirmed`
  - SeatStatus → `Booked`
- Thao tác check-in là atomic (transaction)

### 7.7. Cập Nhật Vé
- Có thể cập nhật:
  - SeatNumber
  - BookingStatus
  - SeatStatus
  - TicketStatus
- Khi cập nhật TicketStatus về trạng thái khác `Used`:
  - CheckedInBy và CheckedInAt được reset về NULL

### 7.8. Truy Vấn Vé
- Hệ thống hỗ trợ tìm kiếm vé theo:
  - Mã vé (TicketNumber)
  - Số ghế (SeatNumber)
  - Tên khách hàng
  - Số điện thoại
  - Trạng thái vé
- Giới hạn kết quả: TOP 200 vé
- Sắp xếp theo ngày phát hành (mới nhất trước)

### 7.9. Thống Kê Vé
- Hệ thống hỗ trợ đếm số vé theo trạng thái
- Dùng để dashboard và báo cáo

---

## 8. Quản Lý Thanh Toán

### 8.1. Thông Tin Thanh Toán
- **Bắt buộc**:
  - Booking liên quan (BookingID)
  - Số tiền (Amount)
  - Loại giao dịch (Type)
- **Tự động**:
  - Ngày giao dịch (TransactionDate) - mặc định: thời điểm hiện tại
- **Tùy chọn**:
  - Phương thức thanh toán (Method)
  - Mã tham chiếu giao dịch (TransactionRef) - từ Payment Gateway

### 8.2. Loại Giao Dịch
- **Type** có các giá trị:
  - **Payment**: Thanh toán
  - **Refund**: Hoàn tiền
  - **Fee**: Phí dịch vụ

### 8.3. Phương Thức Thanh Toán
- Method có thể là:
  - Tiền mặt (Cash)
  - Chuyển khoản (Transfer)
  - Ví điện tử (E-Wallet)
  - Thẻ tín dụng/ghi nợ (Card)
  - Cổng thanh toán khác

### 8.4. Mã Tham Chiếu
- TransactionRef: Lưu mã giao dịch từ bên thứ ba
- Dùng để đối chiếu và tra cứu

### 8.5. Validation
- Amount phải >= 0
- BookingID phải tồn tại
- Type phải thuộc một trong các giá trị cho phép

### 8.6. Chức Năng Admin
- Admin và Staff có thể:
  - Xem danh sách giao dịch
  - Xem chi tiết giao dịch
- **KHÔNG** cho phép:
  - Tạo/sửa/xóa giao dịch thủ công qua admin panel
  - POST request trả về lỗi 405 (Method Not Allowed)

---

## 9. Quản Lý Đánh Giá

### 9.1. Thông Tin Đánh Giá
- **Bắt buộc**:
  - Chuyến đi (TripID)
  - Khách hàng (CustomerID)
  - Điểm đánh giá (Rating)
- **Tự động**:
  - Ngày đánh giá (ReviewDate) - mặc định: thời điểm hiện tại
- **Tùy chọn**:
  - Nhận xét (Comment) - tối đa 256 ký tự

### 9.2. Điểm Đánh Giá
- Rating phải nằm trong khoảng 1-5
- Check constraint: `Rating >= 1 AND Rating <= 5`

### 9.3. Validation
- TripID phải tồn tại
- CustomerID phải tồn tại và có vai trò Customer
- Rating phải từ 1 đến 5
- Comment (nếu có) không vượt quá 256 ký tự

### 9.4. Quyền Đánh Giá
- Chỉ Customer mới có thể đánh giá chuyến đi
- Có thể yêu cầu Customer phải đã có vé (booking) cho chuyến đi đó

---

## 10. Quản Lý Hỗ Trợ

### 10.1. Loại Support Ticket
Hệ thống hỗ trợ ticket từ:
1. **Customer đã đăng ký**: Có CustomerID
2. **Guest/Anonymous**: CustomerID = NULL

### 10.2. Thông Tin Support Ticket
- **Bắt buộc**:
  - Mô tả vấn đề (IssueDescription)
- **Tùy chọn**:
  - Khách hàng (CustomerID)
  - Booking liên quan (BookingID)
  - Nhân viên được giao (StaffAssigned)
  - Danh mục (Category)
  - Chi tiết xử lý (ResolutionDetails)
- **Tự động**:
  - Trạng thái (Status) - mặc định: `Open`
  - Ngày mở (OpenedDate) - mặc định: thời điểm hiện tại

### 10.3. Trạng Thái Support Ticket
- **Status** có các giá trị:
  - **Open**: Mới mở
  - **InProgress**: Đang xử lý
  - **Closed**: Đã đóng

### 10.4. Quy Trình Xử Lý
1. Ticket được tạo với trạng thái `Open`
2. Staff được gán (StaffAssigned)
3. Trạng thái chuyển sang `InProgress`
4. Staff xử lý và cập nhật ResolutionDetails
5. Ticket được đóng, trạng thái → `Closed`, ClosedDate được ghi nhận

### 10.5. Validation
- IssueDescription không được trống
- Nếu có CustomerID, phải tồn tại trong hệ thống
- Nếu có BookingID, phải tồn tại
- Nếu có StaffAssigned, phải là User có vai trò Staff

---

## 11. Kiểm Tra & Xác Thực Dữ Liệu

### 11.1. Input Validator
Hệ thống cung cấp các hàm validation chuẩn:

#### 11.1.1. Kiểm Tra Chỉ Chứa Số
- Method: `isDigitsOnly(String value)`
- Pattern: `^\d{1,20}$`
- Cho phép: 1-20 chữ số
- Không cho phép: chữ cái, ký tự đặc biệt, khoảng trắng

#### 11.1.2. Kiểm Tra Tên Người
- Method: `isAlphabeticName(String value)`
- Pattern: `^[\p{L}][\p{L}\s'.-]*$`
- Cho phép:
  - Chữ cái Unicode (bao gồm tiếng Việt có dấu)
  - Khoảng trắng
  - Ký tự đặc biệt: dấu nháy đơn ('), dấu chấm (.), dấu gạch ngang (-)
- Phải bắt đầu bằng chữ cái

#### 11.1.3. Kiểm Tra Số Tiền
- Method: `isValidMonetaryAmount(String value)`
- Pattern: `^\d+(\.\d{1,2})?$`
- Cho phép:
  - Số nguyên
  - Số thập phân với tối đa 2 chữ số sau dấu chấm
- Ví dụ hợp lệ: `100`, `99.99`, `1000.5`
- Ví dụ không hợp lệ: `100.999`, `-50`, `abc`

### 11.2. Validation Chung
- Tất cả input từ form đều được trim() trước khi xử lý
- Các trường bắt buộc không được NULL hoặc blank
- Encoding: UTF-8 cho tất cả request

### 11.3. Database Constraints
- Unique constraints:
  - User.Email
  - User.PhoneNumber
  - User.EmployeeCode
  - Vehicle.LicensePlate
  - Route.(Origin, Destination)
  - Ticket.TicketNumber
  - Booking.BookingID trong Ticket
- Check constraints:
  - User.Role IN ('Admin', 'Staff', 'BusOperator', 'Customer')
  - User.Status IN ('Active', 'Inactive', 'Blocked')
  - Vehicle.Capacity > 0
  - Trip.Price >= 0
  - Booking: CHK_CUSTOMER_OR_GUEST
  - TripReview.Rating BETWEEN 1 AND 5

### 11.4. Foreign Key Constraints
Tất cả foreign key đều có ON DELETE và ON UPDATE behavior phù hợp:
- Vehicle.EmployeeCode → User.EmployeeCode
- Trip.RouteID → Route.RouteID
- Trip.VehicleID → Vehicle.VehicleID
- Trip.OperatorID → User.UserID
- Booking.TripID → Trip.TripID
- Booking.UserID → User.UserID
- Ticket.BookingID → Booking.BookingID
- Payment.BookingID → Booking.BookingID
- TripReview.TripID → Trip.TripID
- TripReview.CustomerID → User.UserID
- SupportTicket.CustomerID → User.UserID
- SupportTicket.BookingID → Booking.BookingID
- SupportTicket.StaffAssigned → User.UserID

---

## 12. Các Quy Tắc Kỹ Thuật

### 12.1. Logging
- Bắt buộc sử dụng SLF4J + Logback
- Không sử dụng `System.out` hoặc `System.err`
- Các mức log:
  - **DEBUG**: Thông tin chi tiết cho chẩn đoán
  - **INFO**: Luồng xử lý chính
  - **WARN**: Cảnh báo bất thường
  - **ERROR**: Lỗi nghiêm trọng
- Mỗi log cần có context (userId, requestId nếu có)

### 12.2. Transaction Management
- Các thao tác quan trọng sử dụng transaction:
  - Tạo vé (Booking + Ticket)
  - Check-in vé (cập nhật Ticket + Booking)
  - Cập nhật vé (Ticket + Booking)
- Transaction properties:
  - Atomic: Tất cả hoặc không có gì
  - Rollback khi có lỗi
  - Restore AutoCommit sau khi hoàn thành

### 12.3. Database Connection
- Sử dụng try-with-resources để đảm bảo đóng connection
- Connection pool được quản lý bởi DBContext
- Kiểm tra connection != null trước khi sử dụng
- Log lỗi khi connection thất bại

### 12.4. Error Handling
- Không để exception lan truyền ra ngoài controller
- Xử lý SQLException và log chi tiết
- Trả về thông báo lỗi thân thiện cho người dùng
- Không tiết lộ thông tin kỹ thuật trong error message

### 12.5. Date/Time Handling
- Sử dụng Java 8 Time API:
  - LocalDateTime cho timestamp
  - LocalDate cho date only
- Formatters chuẩn:
  - Display: `dd/MM/yyyy HH:mm`
  - Input form: `yyyy-MM-dd'T'HH:mm`
  - Database: SQL Timestamp/Date types
- Timezone: Xử lý theo server timezone

### 12.6. Pagination
- Giới hạn kết quả mặc định: 100 items
- Ticket search: TOP 200
- Trip options: TOP 50 (configurable)
- Hỗ trợ page và perPage parameters

---

## 13. Bảo Mật

### 13.1. Mã Hóa Mật Khẩu
- Thuật toán: SHA-256
- Không lưu plain text password
- So sánh hash case-insensitive

### 13.2. Session Security
- Session được tạo chỉ khi cần thiết
- Không lưu password hash trong session
- Invalidate session khi logout
- Session timeout theo cấu hình server

### 13.3. Input Sanitization
- Tất cả input được trim
- Validate format trước khi xử lý
- Parameterized queries để tránh SQL injection
- Character encoding: UTF-8

### 13.4. Authorization
- Kiểm tra quyền truy cập mỗi request
- Filter-based authorization
- Role-based access control (RBAC)
- Chuyển hướng khi không có quyền

### 13.5. OTP cho Password Reset
- OTP được sinh ngẫu nhiên
- Gửi qua email
- Có thời gian hết hạn
- Xác thực trước khi cho phép đặt lại mật khẩu

---

## Phụ Lục: Các Giá Trị Enum

### A.1. User.Role
- `Admin`
- `Staff`
- `BusOperator`
- `Customer`

### A.2. User.Status
- `Active`
- `Inactive`
- `Blocked`

### A.3. Route.RouteStatus
- `Active`
- `Inactive`

### A.4. Vehicle.VehicleStatus
- `Available`
- `InTrip`
- `InMaintenance`
- `Retired`

### A.5. Trip.TripStatus
- `Scheduled`
- `Departed`
- `Arrived`
- `Delayed`
- `Cancelled`

### A.6. Booking.BookingStatus
- `Pending`
- `Confirmed`
- `Cancelled`
- `Void`

### A.7. Booking.SeatStatus
- `Booked`
- `Reserved`
- `Cancelled`

### A.8. Ticket.TicketStatus
- `Issued`
- `Used`
- `Void`

### A.9. Payment.Type
- `Payment`
- `Refund`
- `Fee`

### A.10. SupportTicket.Status
- `Open`
- `InProgress`
- `Closed`

---

## Ghi Chú

Tài liệu này được tạo ra dựa trên phân tích mã nguồn của hệ thống Bus Booking System. Các quy tắc nghiệp vụ được trích xuất từ:
- Database schema (DB_BusBooking.txt)
- Model classes (JPA entities)
- DAO classes (data access layer)
- Controller classes (business logic)
- Validation utilities
- Security filters

Tài liệu có thể cần được cập nhật khi hệ thống phát triển thêm tính năng mới hoặc thay đổi quy tắc nghiệp vụ.

**Phiên bản**: 1.0  
**Ngày tạo**: 2025-01-08  
**Người tạo**: Automated Code Analysis
