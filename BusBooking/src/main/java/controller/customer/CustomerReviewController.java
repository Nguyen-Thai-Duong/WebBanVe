package controller.customer;

import DAO.TripReviewDAO;
import DAO.TripReviewDAO.TripReviewDetails;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;
import model.User;

/**
 * Servlet handling customer requests for trip reviews.
 * Maps to /customer/review
 */
@WebServlet(name = "CustomerReviewController", urlPatterns = {"/customer/review"})
public class CustomerReviewController extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(CustomerReviewController.class.getName());
    private final TripReviewDAO reviewDAO = new TripReviewDAO();
    private final String REVIEW_JSP = "/WEB-INF/customer/review.jsp";
    private final String PROFILE_URL = "/customer/profile";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        String contextPath = request.getContextPath();
        User currentUser = (User) (session != null ? session.getAttribute("currentUser") : null);

        // 1. Kiểm tra đăng nhập và vai trò
        if (currentUser == null || !"Customer".equalsIgnoreCase(currentUser.getRole())) {
            response.sendRedirect(contextPath + "/login");
            return;
        }

        try {
            String tripIdStr = request.getParameter("tripId");
            if (tripIdStr == null || !tripIdStr.matches("\\d+")) {
                // *** FIX 1: Passing 'response' to the helper method ***
                handleErrorRedirect(session, response, contextPath, "ID chuyến đi không hợp lệ.");
                return;
            }
            int tripId = Integer.parseInt(tripIdStr);
            int customerId = currentUser.getUserId();

            // 2. Kiểm tra nếu đã đánh giá
            if (reviewDAO.isReviewSubmitted(tripId, customerId)) {
                // *** FIX 2: Passing 'response' to the helper method ***
                handleErrorRedirect(session, response, contextPath, "Bạn đã đánh giá chuyến đi này rồi.");
                return;
            }

            // 3. Lấy chi tiết chuyến đi
            TripReviewDetails details = reviewDAO.getTripDetailsForReview(tripId);
            if (details == null) {
                // *** FIX 3: Passing 'response' to the helper method ***
                handleErrorRedirect(session, response, contextPath, "Không tìm thấy thông tin chuyến đi.");
                return;
            }

            // 4. Chuyển tiếp đến JSP
            request.setAttribute("tripId", tripId);
            request.setAttribute("tripDetails", details);
            request.getRequestDispatcher(REVIEW_JSP).forward(request, response);

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error in doGet for CustomerReviewController", e);
            // *** FIX 4: Passing 'response' to the helper method ***
            handleErrorRedirect(session, response, contextPath, "Đã xảy ra lỗi hệ thống khi chuẩn bị form đánh giá.");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        String contextPath = request.getContextPath();
        User currentUser = (User) (session != null ? session.getAttribute("currentUser") : null);

        // 1. Kiểm tra đăng nhập và vai trò
        if (currentUser == null || !"Customer".equalsIgnoreCase(currentUser.getRole())) {
            response.sendRedirect(contextPath + "/login");
            return;
        }

        try {
            // 2. Lấy và kiểm tra tham số
            String tripIdStr = request.getParameter("tripId");
            String ratingStr = request.getParameter("rating");
            String comment = request.getParameter("comment");

            if (tripIdStr == null || !tripIdStr.matches("\\d+") ||
                    ratingStr == null || !ratingStr.matches("[1-5]")) {
                session.setAttribute("reviewError", "Dữ liệu đánh giá không hợp lệ (TripID hoặc Rating).");
                response.sendRedirect(contextPath + PROFILE_URL);
                return;
            }

            int tripId = Integer.parseInt(tripIdStr);
            int rating = Integer.parseInt(ratingStr);
            int customerId = currentUser.getUserId();

            // 3. Kiểm tra trùng lặp trước khi lưu
            if (reviewDAO.isReviewSubmitted(tripId, customerId)) {
                session.setAttribute("reviewError", "Bạn đã đánh giá chuyến đi này rồi.");
                response.sendRedirect(contextPath + PROFILE_URL);
                return;
            }

            // 4. Lưu đánh giá
            boolean success = reviewDAO.saveReview(tripId, customerId, rating, comment);

            // 5. Xử lý phản hồi
            if (success) {
                session.setAttribute("reviewSuccess", "Cảm ơn bạn! Đánh giá đã được gửi thành công.");
            } else {
                session.setAttribute("reviewError", "Đã xảy ra lỗi trong quá trình gửi đánh giá. Vui lòng thử lại.");
            }
            response.sendRedirect(contextPath + PROFILE_URL);

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error in doPost for CustomerReviewController", e);
            session.setAttribute("reviewError", "Đã xảy ra lỗi hệ thống khi xử lý đánh giá.");
            response.sendRedirect(contextPath + PROFILE_URL);
        }
    }

    // Phương thức tiện ích để chuyển hướng về profile và hiển thị lỗi
    private void handleErrorRedirect(HttpSession session, HttpServletResponse response, String contextPath, String message) throws IOException {
        if (session != null) {
            session.setAttribute("reviewError", message);
        }
        response.sendRedirect(contextPath + PROFILE_URL);
    }
}