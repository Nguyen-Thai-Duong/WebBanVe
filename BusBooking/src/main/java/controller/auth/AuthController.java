package controller.auth;

import DAO.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import model.User;
import strategy.RoleRedirectStrategyFactory;
import util.PasswordUtils;

/**
 * Handles authentication flow (login/logout) and role-based redirects.
 */
@WebServlet(name = "AuthController", urlPatterns = {"/login", "/logout"})
public class AuthController extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String servletPath = request.getServletPath();
        if ("/logout".equals(servletPath)) {
            handleLogout(request, response);
            return;
        }

        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("currentUser") != null) {
            response.sendRedirect(resolveRedirectPath((User) session.getAttribute("currentUser"), request));
            return;
        }
        request.getRequestDispatcher("/login-form.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String identifier = trim(request.getParameter("identifier"));
        String password = request.getParameter("password");

        if (identifier == null || password == null || password.isBlank()) {
            request.setAttribute("errorMessage", "Vui lòng nhập đầy đủ email/số điện thoại và mật khẩu.");
            request.setAttribute("prefillIdentifier", identifier);
            request.getRequestDispatcher("/login-form.jsp").forward(request, response);
            return;
        }

        User user = userDAO.findByIdentifier(identifier);
        if (user == null || !verifyPassword(user, password)) {
            request.setAttribute("errorMessage", "Thông tin đăng nhập không hợp lệ.");
            request.setAttribute("prefillIdentifier", identifier);
            request.getRequestDispatcher("/login-form.jsp").forward(request, response);
            return;
        }

        if (!"Active".equalsIgnoreCase(user.getStatus())) {
            request.setAttribute("errorMessage", "Tài khoản của bạn đang bị khóa hoặc chưa kích hoạt.");
            request.setAttribute("prefillIdentifier", identifier);
            request.getRequestDispatcher("/login-form.jsp").forward(request, response);
            return;
        }

        HttpSession session = request.getSession(true);
        User sessionUser = sanitizeForSession(user);
        session.setAttribute("currentUser", sessionUser);

        response.sendRedirect(resolveRedirectPath(sessionUser, request));
    }

    private void handleLogout(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.invalidate();
        }
        response.sendRedirect(request.getContextPath() + "/login");
    }

    private boolean verifyPassword(User user, String rawPassword) {
        String hashedInput = PasswordUtils.hashPassword(rawPassword);
        return hashedInput.equalsIgnoreCase(user.getPasswordHash());
    }

    private User sanitizeForSession(User user) {
        User sessionUser = new User();
        sessionUser.setUserId(user.getUserId());
        sessionUser.setEmployeeCode(user.getEmployeeCode());
        sessionUser.setFullName(user.getFullName());
        sessionUser.setEmail(user.getEmail());
        sessionUser.setPhoneNumber(user.getPhoneNumber());
        sessionUser.setRole(user.getRole());
        sessionUser.setStatus(user.getStatus());
        sessionUser.setAddress(user.getAddress());
        sessionUser.setCreatedAt(user.getCreatedAt());
        sessionUser.setUpdatedAt(user.getUpdatedAt());
        return sessionUser;
    }

    private String resolveRedirectPath(User user, HttpServletRequest request) {
        String contextPath = request.getContextPath();
        String role = user != null ? user.getRole() : null;
        return RoleRedirectStrategyFactory.get(role).resolve(user, contextPath);
    }

    private String trim(String value) {
        return value != null ? value.trim() : null;
    }

    public static void applyResetSuccessFlash(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session != null) {
            Object success = session.getAttribute("passwordResetSuccess");
            if (success != null) {
                request.setAttribute("successMessage", success);
                session.removeAttribute("passwordResetSuccess");
                return;
            }
            Object registrationSuccess = session.getAttribute("registrationSuccess");
            if (registrationSuccess != null) {
                request.setAttribute("successMessage", registrationSuccess);
                session.removeAttribute("registrationSuccess");
            }
        }
    }

    @Override
    public String getServletInfo() {
        return "Authentication controller";
    }
}
