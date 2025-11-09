package controller.admin;

import dto.PaymentAdminView;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import service.admin.AdminPaymentService;
import service.admin.BaseAdminService;

import java.io.IOException;
import java.time.format.DateTimeFormatter;
import java.util.List;

/**
 * Controller responsible for payment management within the admin console.
 */
@WebServlet(name = "PaymentController", urlPatterns = {"/admin/payments", "/admin/payments/detail"})
public class PaymentController extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final DateTimeFormatter DISPLAY_FORMATTER = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");

    private final AdminPaymentService paymentService = new AdminPaymentService();
    private final BaseAdminService baseService = new BaseAdminService() {};

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
        List<PaymentAdminView> payments = paymentService.getAllPayments();
        request.setAttribute("payments", payments);
        request.setAttribute("dateFormatter", DISPLAY_FORMATTER);
        request.setAttribute("activeMenu", "payments");
        forward(request, response, "/WEB-INF/admin/payments/payment-list.jsp");
    }

    private void showPaymentDetail(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        Integer paymentId = baseService.parseInteger(request.getParameter("paymentId"));
        if (paymentId == null) {
            setFlash(request.getSession(), "paymentMessage", "Không tìm thấy giao dịch thanh toán.", "danger");
            response.sendRedirect(request.getContextPath() + "/admin/payments");
            return;
        }
        PaymentAdminView payment = paymentService.getPaymentById(paymentId);
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

    @Override
    public String getServletInfo() {
        return "Payment management controller";
    }
}
