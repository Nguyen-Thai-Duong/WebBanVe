package model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@Entity
@Table(name = "PAYMENT")
public class Payment implements Serializable {

    private static final long serialVersionUID = 1L;

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "PaymentID")
    private Integer paymentId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "BookingID", nullable = false)
    private Booking booking;

    @Column(name = "Amount", nullable = false)
    private BigDecimal amount;

    @Column(name = "TransactionDate")
    private LocalDateTime transactionDate;

    @Column(name = "Method", length = 50)
    private String method;

    @Column(name = "Type", nullable = false, length = 50)
    private String type;

    @Column(name = "TransactionRef", length = 100)
    private String transactionRef;
}