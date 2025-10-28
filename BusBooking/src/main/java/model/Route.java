package model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import jakarta.persistence.Transient;
import java.io.Serializable;
import java.math.BigDecimal;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@Entity
@Table(name = "ROUTE")
public class Route implements Serializable {

    private static final long serialVersionUID = 1L;

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "RouteID")
    private Integer routeId;

    @Column(name = "Origin", nullable = false, length = 100)
    private String origin;

    @Column(name = "Destination", nullable = false, length = 100)
    private String destination;

    @Column(name = "Distance")
    private BigDecimal distance;

    @Column(name = "DurationMinutes")
    private Integer durationMinutes;

    @Column(name = "RouteStatus", nullable = false, length = 20)
    private String routeStatus = "Active";

    @Transient
    private Integer tripCount;
}