package controller.auth;

import DAO.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.Optional;
import model.User;
import service.EmailService;
import util.OtpGenerator;

/**
 * Handles forgot password requests and dispatches reset codes via email.
 */
@WebServlet(name = "ForgotPasswordController", urlPatterns = {"/forgot-password"})
public class ForgotPasswordController extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final int OTP_LENGTH = 6;
    private static final int OTP_EXPIRATION_MINUTES = 10;

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/forgot-password.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String email = trim(request.getParameter("email"));
        if (email == null) {
            request.setAttribute("errorMessage", "Vui lòng nhập email đã đăng ký.");
            request.getRequestDispatcher("/forgot-password.jsp").forward(request, response);
            return;
        }

        User user = userDAO.findByIdentifier(email);
        if (user == null || user.getEmail() == null || !user.getEmail().equalsIgnoreCase(email)) {
            request.setAttribute("errorMessage", "Không tìm thấy tài khoản với email này.");
            request.getRequestDispatcher("/forgot-password.jsp").forward(request, response);
            return;
        }

        String otp = OtpGenerator.generateNumericCode(OTP_LENGTH);
        boolean sent = buildEmailService().map(service -> service.sendMail(
                email,
                "FUTA Bus Lines - Mã đặt lại mật khẩu",
                buildEmailBody(user.getFullName(), otp)
        )).orElse(false);

        if (!sent) {
            request.setAttribute("errorMessage", "Không thể gửi email đặt lại mật khẩu. Vui lòng thử lại sau.");
            request.getRequestDispatcher("/forgot-password.jsp").forward(request, response);
            return;
        }

    HttpSession session = request.getSession(true);
    storeOtpInSession(session, email, otp);
    session.setAttribute("passwordResetNotice", "Mã xác nhận đã được gửi tới email của bạn. Vui lòng kiểm tra hộp thư.");
    String redirectUrl = request.getContextPath() + "/reset-password?email="
        + URLEncoder.encode(email, StandardCharsets.UTF_8);
    response.sendRedirect(redirectUrl);
    }

    private Optional<EmailService> buildEmailService() {
        String username = System.getenv("GMAIL_USERNAME");
        String password = System.getenv("GMAIL_APP_PASSWORD");
        if (username == null || password == null) {
            username = System.getProperty("mail.username");
            password = System.getProperty("mail.password");
        }
        if (username == null) {
            username = "thachthoi26@gmail.com"; // default sender provided by project owner
        }
        if (password == null) {
            return Optional.empty();
        }
        return Optional.of(new EmailService(username, password));
    }

    private void storeOtpInSession(HttpSession session, String email, String otp) {
        session.setAttribute("passwordResetEmail", email);
        session.setAttribute("passwordResetOtp", otp);
        session.setAttribute("passwordResetExpiry", Instant.now().plus(OTP_EXPIRATION_MINUTES, ChronoUnit.MINUTES));
    }

    private String buildEmailBody(String fullName, String otp) {
        String greeting = fullName != null && !fullName.isBlank() ? fullName : "bạn";
        return "Xin chào " + greeting + ",\n\n"
                + "Bạn hoặc ai đó đã yêu cầu đặt lại mật khẩu cho tài khoản FUTA Bus Lines.\n"
                + "Mã xác nhận của bạn là: " + otp + "\n\n"
                + "Mã có hiệu lực trong " + OTP_EXPIRATION_MINUTES + " phút.\n"
                + "Nếu bạn không yêu cầu, vui lòng bỏ qua email này.\n\n"
                + "Trân trọng,\n"
                + "FUTA Bus Lines";
    }

    private String trim(String value) {
        return value != null ? value.trim() : null;
    }
}
