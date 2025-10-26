package dto.dashboard;

import java.math.BigDecimal;

public class PaymentMethodSummary {
    private String method;
    private BigDecimal netAmount;

    public String getMethod() {
        return method;
    }

    public void setMethod(String method) {
        this.method = method;
    }

    public BigDecimal getNetAmount() {
        return netAmount;
    }

    public void setNetAmount(BigDecimal netAmount) {
        this.netAmount = netAmount;
    }
}
