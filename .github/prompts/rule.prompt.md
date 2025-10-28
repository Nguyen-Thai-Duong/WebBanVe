---
mode: agent
---
2. KPI tách component: nếu một khối JSP dùng ≥ 2 lần hoặc > 40 dòng, chuyển thành include/tag file tái sử dụng.
3. Tuyệt đối không dùng scriptlet (`<% %>`); mọi logic hiển thị phải thông qua JSTL/EL, tag file hoặc DTO đã xử lý sẵn.

-- Logging & Observability
4. Bắt buộc dùng SLF4J + Logback. Không dùng `System.out/err`. Ghi log mức độ hợp lý (DEBUG cho diagnostic, INFO cho flow, WARN/ERROR cho bất thường). Mỗi log cần gắn context (userId/requestId nếu có).

-- Coding Standard
5. Tuân thủ Java naming conventions (Class PascalCase, method camelCase, constant UPPER_CASE). Bật formatter chung (Google Java Style hoặc cấu hình trong repo). Không chấp nhận hard tab lẫn khoảng trắng lộn xộn. Rename biến/method/class một cách rõ ràng, tránh viết tắt.