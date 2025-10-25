package controller.auth;

import DAO.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.time.Instant;
import model.User;
import util.PasswordUtils;

/**
 * Handles OTP verification and password reset submissions.
 */
@WebServlet(name = "ResetPasswordController", urlPatterns = {"/reset-password"})
public class ResetPasswordController extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        populateFlashFromSession(request.getSession(false), request);
        request.getRequestDispatcher("/reset-password.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect(request.getContextPath() + "/forgot-password");
            return;
        }

        String sessionEmail = (String) session.getAttribute("passwordResetEmail");
        String sessionOtp = (String) session.getAttribute("passwordResetOtp");
        Instant expiry = (Instant) session.getAttribute("passwordResetExpiry");

        String email = trim(request.getParameter("email"));
        String otp = trim(request.getParameter("otp"));
        String newPassword = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");

        if (sessionEmail == null || sessionOtp == null || expiry == null) {
            setError(request, "Phiên khôi phục không hợp lệ hoặc đã hết hạn. Vui lòng yêu cầu lại.");
            request.getRequestDispatcher("/reset-password.jsp").forward(request, response);
            return;
        }
        if (!sessionEmail.equalsIgnoreCase(email)) {
            setError(request, "Email không trùng khớp với yêu cầu ban đầu.");
            request.getRequestDispatcher("/reset-password.jsp").forward(request, response);
            return;
        }
        if (Instant.now().isAfter(expiry)) {
            setError(request, "Mã xác nhận đã hết hạn. Vui lòng yêu cầu mã mới.");
            clearOtp(session);
            request.getRequestDispatcher("/reset-password.jsp").forward(request, response);
            return;
        }
        if (otp == null || !otp.equals(sessionOtp)) {
            setError(request, "Mã xác nhận không chính xác.");
            request.getRequestDispatcher("/reset-password.jsp").forward(request, response);
            return;
        }
        if (newPassword == null || newPassword.isBlank() || !newPassword.equals(confirmPassword)) {
            setError(request, "Mật khẩu mới không hợp lệ hoặc không trùng khớp.");
            request.getRequestDispatcher("/reset-password.jsp").forward(request, response);
            return;
        }

        User user = userDAO.findByIdentifier(email);
        if (user == null) {
            setError(request, "Không tìm thấy tài khoản để cập nhật.");
            request.getRequestDispatcher("/reset-password.jsp").forward(request, response);
            return;
        }

        boolean updated = userDAO.updatePassword(user.getUserId(), PasswordUtils.hashPassword(newPassword));
        if (!updated) {
            setError(request, "Không thể cập nhật mật khẩu. Vui lòng thử lại sau.");
            request.getRequestDispatcher("/reset-password.jsp").forward(request, response);
            return;
        }

        clearOtp(session);
        session.setAttribute("passwordResetSuccess", "Mật khẩu của bạn đã được cập nhật. Vui lòng đăng nhập lại.");
        response.sendRedirect(request.getContextPath() + "/login");
    }

    private void setError(HttpServletRequest request, String message) {
        request.setAttribute("errorMessage", message);
    }

    private void populateFlashFromSession(HttpSession session, HttpServletRequest request) {
        if (session == null) {
            return;
        }
        Object notice = session.getAttribute("passwordResetNotice");
        if (notice != null) {
            request.setAttribute("successMessage", notice);
            session.removeAttribute("passwordResetNotice");
        }
    }

    private void clearOtp(HttpSession session) {
        session.removeAttribute("passwordResetEmail");
        session.removeAttribute("passwordResetOtp");
        session.removeAttribute("passwordResetExpiry");
        session.removeAttribute("passwordResetNotice");
    }

    private String trim(String value) {
        return value != null ? value.trim() : null;
    }
}
