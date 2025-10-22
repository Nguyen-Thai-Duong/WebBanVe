package model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToOne;
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
@Table(name = "TICKET")
public class Ticket implements Serializable {

    private static final long serialVersionUID = 1L;

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "TicketID")
    private Integer ticketId;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "BookingID", nullable = false, unique = true)
    private Booking booking;

    @Column(name = "TicketNumber", nullable = false, length = 100, unique = true)
    private String ticketNumber;

    @Column(name = "TicketStatus", nullable = false, length = 50)
    private String ticketStatus = "Issued";

    @Column(name = "IssuedDate")
    private LocalDateTime issuedDate;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "CheckedInBy")
    private User checkedInBy;

    @Column(name = "CheckedInAt")
    private LocalDateTime checkedInAt;
}