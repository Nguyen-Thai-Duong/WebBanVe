package controller.customer;

import DAO.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.regex.Pattern;
import model.User;

/**
 * Allows customers to view and update their profile information.
 */
@WebServlet(name = "CustomerProfileController", urlPatterns = {"/customer/profile"})
public class CustomerProfileController extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final Pattern PHONE_PATTERN = Pattern.compile("^0[0-9]{9,10}$");

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        String contextPath = request.getContextPath();
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect(contextPath + "/login");
            return;
        }
        User sessionUser = (User) session.getAttribute("currentUser");
        if (!isCustomer(sessionUser)) {
            response.sendRedirect(contextPath + "/");
            return;
        }

        User freshUser = userDAO.findById(sessionUser.getUserId());
        if (freshUser != null) {
            mergeIntoSession(sessionUser, freshUser);
        }

        Object successFlash = session.getAttribute("profileUpdateSuccess");
        if (successFlash != null) {
            request.setAttribute("successMessage", successFlash);
            session.removeAttribute("profileUpdateSuccess");
        }

        request.setAttribute("profileUser", sessionUser);
        request.getRequestDispatcher("/WEB-INF/customer/profile.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        String contextPath = request.getContextPath();
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect(contextPath + "/login");
            return;
        }
        User sessionUser = (User) session.getAttribute("currentUser");
        if (!isCustomer(sessionUser)) {
            response.sendRedirect(contextPath + "/");
            return;
        }

        String fullName = trim(request.getParameter("fullName"));
        String phone = trim(request.getParameter("phoneNumber"));
        String address = trim(request.getParameter("address"));

        request.setAttribute("prefillFullName", fullName);
        request.setAttribute("prefillPhone", phone);
        request.setAttribute("prefillAddress", address);

        if (fullName == null || fullName.isBlank()) {
            forwardWithError("Vui lòng nhập họ và tên.", sessionUser, request, response);
            return;
        }
        if (phone == null || !PHONE_PATTERN.matcher(phone).matches()) {
            forwardWithError("Số điện thoại không hợp lệ. Vui lòng nhập 10-11 số và bắt đầu bằng 0.", sessionUser, request, response);
            return;
        }
        if (userDAO.phoneExistsForOtherUser(phone, sessionUser.getUserId())) {
            forwardWithError("Số điện thoại đã được sử dụng bởi tài khoản khác.", sessionUser, request, response);
            return;
        }

        boolean updated = userDAO.updateCustomerProfile(sessionUser.getUserId(), fullName, phone, address);
        if (!updated) {
            forwardWithError("Không thể cập nhật thông tin vào lúc này. Vui lòng thử lại sau.", sessionUser, request, response);
            return;
        }

        sessionUser.setFullName(fullName);
        sessionUser.setPhoneNumber(phone);
        sessionUser.setAddress(address);
        session.setAttribute("currentUser", sessionUser);
        session.setAttribute("profileUpdateSuccess", "Cập nhật thông tin thành công.");
        response.sendRedirect(contextPath + "/customer/profile");
    }

    private void forwardWithError(String message, User sessionUser,
            HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setAttribute("errorMessage", message);
        request.setAttribute("profileUser", sessionUser);
        request.getRequestDispatcher("/WEB-INF/customer/profile.jsp").forward(request, response);
    }

    private boolean isCustomer(User user) {
        return user != null && "Customer".equalsIgnoreCase(user.getRole());
    }

    private void mergeIntoSession(User sessionUser, User reference) {
        sessionUser.setFullName(reference.getFullName());
        sessionUser.setPhoneNumber(reference.getPhoneNumber());
        sessionUser.setAddress(reference.getAddress());
        sessionUser.setEmail(reference.getEmail());
        sessionUser.setEmployeeCode(reference.getEmployeeCode());
        sessionUser.setStatus(reference.getStatus());
        sessionUser.setUpdatedAt(reference.getUpdatedAt());
    }

    private String trim(String value) {
        return value != null ? value.trim() : null;
    }
}
