
-- Front-end & View Layer
1. Đặt tên file fragment thống nhất: dùng prefix `fragment-` cho layout, `component-` cho phần tử nhỏ (ví dụ: `fragment-layout-head.jspf`, `component-ticket-card.jspf`). Không đặt chung tên ở nhiều thư mục.
2. KPI tách component: nếu một khối JSP dùng ≥ 2 lần hoặc > 40 dòng, chuyển thành include/tag file tái sử dụng.
3. Tuyệt đối không dùng scriptlet (`<% %>`); mọi logic hiển thị phải thông qua JSTL/EL, tag file hoặc DTO đã xử lý sẵn.

-- Logging & Observability
4. Bắt buộc dùng SLF4J + Logback. Không dùng `System.out/err`. Ghi log mức độ hợp lý (DEBUG cho diagnostic, INFO cho flow, WARN/ERROR cho bất thường). Mỗi log cần gắn context (userId/requestId nếu có).

-- Coding Standard
5. Tuân thủ Java naming conventions (Class PascalCase, method camelCase, constant UPPER_CASE). Bật formatter chung (Google Java Style hoặc cấu hình trong repo). Không chấp nhận hard tab lẫn khoảng trắng lộn xộn. Rename biến/method/class một cách rõ ràng, tránh viết tắt.
6. DAO chỉ chứa JDBC thuần; transaction và nghiệp vụ nằm ở Service. Controller/Command chỉ xử lý HTTP, không viết SQL/logic nghiệp vụ.

-- Validation & DTO
7. Sử dụng DTO/ViewModel rõ ràng giữa các tầng. Không truyền trực tiếp entity/model vào JSP. Các trường định dạng (ngày, tiền tệ, badge) phải chuẩn hóa trong DTO.

-- Compliance & CI
8. Mọi PR phải tick checklist: đặt tên fragment đúng, không scriptlet, đã dùng logger, format code, DTO chuẩn. 
9. Thiết lập Maven `verify` chạy checkstyle + unit test; build fail nếu vi phạm convention hoặc thiếu thư viện required.

-- Documentation & Knowledge Sharing
10. Cập nhật wiki khi bổ sung rule mới, kèm ví dụ tốt/xấu. Tổ chức review định kỳ để đảm bảo rule được áp dụng thực tế.
-----------------------------------------------------------------------------------
Phải làm theo các quy tắc trên để nâng cao chất lượng code, dễ bảo trì và phát triển lâu dài.
-----------------------------------------------------------------------------------
Thực hiện xong tất cả các quy tắc trên, báo cáo với lead để đánh giá và ghi nhận.