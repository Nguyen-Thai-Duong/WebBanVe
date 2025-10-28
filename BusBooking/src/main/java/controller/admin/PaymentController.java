package controller.admin;

import DAO.PaymentDAO;
import dto.PaymentAdminView;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.time.format.DateTimeFormatter;
import java.util.Collections;
import java.util.List;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Controller responsible for payment management within the admin console.
 */
@WebServlet(name = "PaymentController", urlPatterns = {"/admin/payments", "/admin/payments/detail"})
public class PaymentController extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = LoggerFactory.getLogger(PaymentController.class);

    private static final DateTimeFormatter DISPLAY_FORMATTER = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");

    private final PaymentDAO paymentDAO = new PaymentDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String path = request.getServletPath();
        if ("/admin/payments/detail".equals(path)) {
            showPaymentDetail(request, response);
        } else {
            showPaymentList(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED, "Chức năng thanh toán chỉ hỗ trợ xem.");
    }

    private void showPaymentList(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        List<PaymentAdminView> payments = paymentDAO.findAll();
        if (payments == null) {
            payments = Collections.emptyList();
        }
        request.setAttribute("payments", payments);
        request.setAttribute("dateFormatter", DISPLAY_FORMATTER);
        request.setAttribute("activeMenu", "payments");
        forward(request, response, "/WEB-INF/admin/payments/payment-list.jsp");
    }

    private void showPaymentDetail(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        Integer paymentId = parseInteger(request.getParameter("paymentId"));
        if (paymentId == null) {
            setFlash(request.getSession(), "paymentMessage", "Không tìm thấy giao dịch thanh toán.", "danger");
            response.sendRedirect(request.getContextPath() + "/admin/payments");
            return;
        }
        PaymentAdminView payment = paymentDAO.findById(paymentId);
        if (payment == null) {
            setFlash(request.getSession(), "paymentMessage", "Không tìm thấy giao dịch thanh toán.", "danger");
            response.sendRedirect(request.getContextPath() + "/admin/payments");
            return;
        }

    request.setAttribute("payment", payment);
    request.setAttribute("dateFormatter", DISPLAY_FORMATTER);
    request.setAttribute("activeMenu", "payments");
        forward(request, response, "/WEB-INF/admin/payments/payment-detail.jsp");
    }

    private void setFlash(HttpSession session, String key, String message, String type) {
        session.setAttribute(key, message);
        session.setAttribute(key + "Type", type);
    }

    private void forward(HttpServletRequest request, HttpServletResponse response, String path) throws ServletException, IOException {
        request.getRequestDispatcher(path).forward(request, response);
    }

    private Integer parseInteger(String value) {
        try {
            return value != null && !value.isBlank() ? Integer.valueOf(value) : null;
        } catch (NumberFormatException ex) {
            LOGGER.warn("Failed to parse integer value: {}", value);
            return null;
        }
    }

    @Override
    public String getServletInfo() {
        return "Payment management controller";
    }
}
