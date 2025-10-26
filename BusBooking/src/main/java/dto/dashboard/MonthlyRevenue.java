package dto.dashboard;

import java.math.BigDecimal;

public class MonthlyRevenue {
    private String period;
    private BigDecimal amount;

    public String getPeriod() {
        return period;
    }

    public void setPeriod(String period) {
        this.period = period;
    }

    public BigDecimal getAmount() {
        return amount;
    }

    public void setAmount(BigDecimal amount) {
        this.amount = amount;
    }
}
