package dto.dashboard;

/**
 * View model for displaying payment method revenue summaries.
 */
public class PaymentSummaryView {

    private final String methodLabel;
    private final String amountLabel;

    public PaymentSummaryView(String methodLabel, String amountLabel) {
        this.methodLabel = methodLabel;
        this.amountLabel = amountLabel;
    }

    public String getMethodLabel() {
        return methodLabel;
    }

    public String getAmountLabel() {
        return amountLabel;
    }
}
