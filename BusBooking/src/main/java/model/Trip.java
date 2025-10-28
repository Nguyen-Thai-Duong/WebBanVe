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
import jakarta.persistence.Transient;
import java.io.Serializable;
import java.math.BigDecimal;
import java.time.Duration;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@Entity
@Table(name = "TRIP")
public class Trip implements Serializable {

    private static final long serialVersionUID = 1L;

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "TripID")
    private Integer tripId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "RouteID", nullable = false)
    private Route route;

    @Column(name = "DepartureTime", nullable = false)
    private LocalDateTime departureTime;

    @Column(name = "ArrivalTime")
    private LocalDateTime arrivalTime;

    @Column(name = "Price", nullable = false)
    private BigDecimal price;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "VehicleID", nullable = false)
    private Vehicle vehicle;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "OperatorID", nullable = false)
    private User operator;

    @Column(name = "TripStatus", nullable = false, length = 50)
    private String tripStatus = "Scheduled";

        @Transient
        public String formatDeparture(DateTimeFormatter formatter) {
            if (formatter == null || departureTime == null) {
                return null;
            }
            return formatter.format(departureTime);
        }

        @Transient
        public String formatArrival(DateTimeFormatter formatter) {
            if (formatter == null || arrivalTime == null) {
                return null;
            }
            return formatter.format(arrivalTime);
        }

        @Transient
        public Duration getDuration() {
            if (departureTime == null || arrivalTime == null) {
                return null;
            }
            return Duration.between(departureTime, arrivalTime);
        }

        @Transient
        public long getDurationMinutesTotal() {
            Duration duration = getDuration();
            return duration != null ? duration.toMinutes() : -1L;
        }

        @Transient
        public long getDurationHoursPart() {
            long totalMinutes = getDurationMinutesTotal();
            return totalMinutes >= 0 ? totalMinutes / 60 : -1L;
        }

        @Transient
        public long getDurationMinutesPart() {
            long totalMinutes = getDurationMinutesTotal();
            return totalMinutes >= 0 ? totalMinutes % 60 : -1L;
        }
}