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
import java.time.LocalDateTime;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@Entity
@Table(name = "BOOKING")
public class Booking implements Serializable {

    private static final long serialVersionUID = 1L;

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "BookingID")
    private Integer bookingId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "TripID", nullable = false)
    private Trip trip;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "UserID")
    private User customer;

    @Column(name = "GuestPhoneNumber", length = 20)
    private String guestPhoneNumber;

    @Column(name = "GuestEmail", length = 100)
    private String guestEmail;

    @Column(name = "BookingDate")
    private LocalDateTime bookingDate;

    @Column(name = "BookingStatus", nullable = false, length = 50)
    private String bookingStatus = "Pending";

    @Column(name = "SeatNumber", nullable = false, length = 10)
    private String seatNumber;

    @Column(name = "SeatStatus", nullable = false, length = 50)
    private String seatStatus = "Booked";

    @Column(name = "TTL_Expiry")
    private LocalDateTime ttlExpiry;
}