package service.admin;

import DAO.PaymentDAO;
import dto.PaymentAdminView;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.Collections;
import java.util.List;

/**
 * Service layer for payment management in admin module.
 */
public class AdminPaymentService extends BaseAdminService {
    
    private static final Logger LOGGER = LoggerFactory.getLogger(AdminPaymentService.class);
    private final PaymentDAO paymentDAO;
    
    public AdminPaymentService() {
        this.paymentDAO = new PaymentDAO();
    }
    
    /**
     * Get all payments.
     */
    public List<PaymentAdminView> getAllPayments() {
        List<PaymentAdminView> payments = paymentDAO.findAll();
        return payments != null ? payments : Collections.emptyList();
    }
    
    /**
     * Get payment by ID.
     */
    public PaymentAdminView getPaymentById(Integer paymentId) {
        if (paymentId == null) {
            LOGGER.warn("Attempted to get payment with null ID");
            return null;
        }
        return paymentDAO.findById(paymentId);
    }
}
