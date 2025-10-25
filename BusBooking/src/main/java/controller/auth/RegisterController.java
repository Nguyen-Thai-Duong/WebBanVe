package controller.auth;

import DAO.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.regex.Pattern;
import util.PasswordUtils;

/**
 * Handles customer self-registration flow.
 */
@WebServlet(name = "RegisterController", urlPatterns = {"/register"})
public class RegisterController extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final int MIN_PASSWORD_LENGTH = 8;
    private static final Pattern PHONE_PATTERN = Pattern.compile("^0[0-9]{9,10}$");

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/register-form.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        String fullName = trim(request.getParameter("fullName"));
        String phone = trim(request.getParameter("phone"));
        String email = trim(request.getParameter("email"));
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        boolean agreedToTerms = "on".equalsIgnoreCase(request.getParameter("agree"));

        request.setAttribute("prefillFullName", fullName);
        request.setAttribute("prefillPhone", phone);
        request.setAttribute("prefillEmail", email);
    request.setAttribute("prefillAgree", agreedToTerms);

        String validationError = validateInput(fullName, phone, email, password, confirmPassword, agreedToTerms);
        if (validationError != null) {
            forwardWithError(request, response, validationError);
            return;
        }

        if (userDAO.emailExists(email)) {
            forwardWithError(request, response, "Email đã được sử dụng. Vui lòng chọn email khác.");
            return;
        }
        if (userDAO.phoneExists(phone)) {
            forwardWithError(request, response, "Số điện thoại đã được đăng ký. Vui lòng sử dụng số khác.");
            return;
        }

        String passwordHash = PasswordUtils.hashPassword(password);
        Integer userId;
        try {
            userId = userDAO.createCustomer(fullName, email, phone, passwordHash);
        } catch (RuntimeException ex) {
            String rootMessage = ex.getCause() instanceof Exception ? ex.getCause().getMessage() : null;
            String friendly = buildFriendlyDatabaseMessage(rootMessage);
            forwardWithError(request, response, friendly);
            return;
        }
        if (userId == null) {
            forwardWithError(request, response, "Không thể tạo tài khoản vào lúc này. Vui lòng thử lại sau.");
            return;
        }

        HttpSession session = request.getSession(true);
        session.setAttribute("registrationSuccess", "Đăng ký thành công! Bạn có thể đăng nhập để bắt đầu sử dụng.");
        response.sendRedirect(request.getContextPath() + "/login");
    }

    private void forwardWithError(HttpServletRequest request, HttpServletResponse response, String message)
            throws ServletException, IOException {
        request.setAttribute("errorMessage", message);
        request.getRequestDispatcher("/register-form.jsp").forward(request, response);
    }

    private String validateInput(String fullName, String phone, String email, String password,
                                 String confirmPassword, boolean agreedToTerms) {
        if (fullName == null || fullName.isBlank()) {
            return "Vui lòng nhập họ và tên.";
        }
        if (phone == null || phone.isBlank()) {
            return "Vui lòng nhập số điện thoại.";
        }
        if (!PHONE_PATTERN.matcher(phone).matches()) {
            return "Số điện thoại không hợp lệ. Vui lòng nhập 10-11 số và bắt đầu bằng 0.";
        }
        if (email == null || email.isBlank()) {
            return "Vui lòng nhập email.";
        }
        if (password == null || password.isBlank()) {
            return "Vui lòng nhập mật khẩu.";
        }
        if (password.length() < MIN_PASSWORD_LENGTH) {
            return "Mật khẩu phải có ít nhất " + MIN_PASSWORD_LENGTH + " ký tự.";
        }
        if (confirmPassword == null || !password.equals(confirmPassword)) {
            return "Mật khẩu và xác nhận mật khẩu không khớp.";
        }
        if (!agreedToTerms) {
            return "Bạn cần đồng ý với điều khoản sử dụng để tiếp tục.";
        }
        return null;
    }

    private String trim(String value) {
        return value != null ? value.trim() : null;
    }

    private String buildFriendlyDatabaseMessage(String dbMessage) {
        if (dbMessage == null || dbMessage.isBlank()) {
            return "Không thể tạo tài khoản vào lúc này. Vui lòng thử lại sau.";
        }
        String normalized = dbMessage.toLowerCase();
        if (normalized.contains("unique") && normalized.contains("email")) {
            return "Email đã được sử dụng. Vui lòng chọn email khác.";
        }
        if (normalized.contains("unique") && normalized.contains("phone")) {
            return "Số điện thoại đã được đăng ký. Vui lòng sử dụng số khác.";
        }
        if (normalized.contains("chk_customer_or_guest")) {
            return "Vui lòng cung cấp đầy đủ thông tin khách hàng hoặc số điện thoại.";
        }
        return "Không thể tạo tài khoản vào lúc này. Vui lòng thử lại sau. Chi tiết: " + dbMessage;
    }
}
