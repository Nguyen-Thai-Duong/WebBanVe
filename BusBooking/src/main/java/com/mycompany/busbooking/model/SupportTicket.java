package com.mycompany.busbooking.model;

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
@Table(name = "SUPPORT_TICKET")
public class SupportTicket implements Serializable {

    private static final long serialVersionUID = 1L;

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "SupportID")
    private Integer supportId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "CustomerID")
    private User customer;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "BookingID")
    private Booking booking;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "StaffAssigned")
    private User staffAssigned;

    @Column(name = "Category", length = 100)
    private String category;

    @Column(name = "IssueDescription", columnDefinition = "NVARCHAR(MAX)", nullable = false)
    private String issueDescription;

    @Column(name = "ResolutionDetails", columnDefinition = "NVARCHAR(MAX)")
    private String resolutionDetails;

    @Column(name = "Status", nullable = false, length = 50)
    private String status = "Open";

    @Column(name = "OpenedDate")
    private LocalDateTime openedDate;

    @Column(name = "ClosedDate")
    private LocalDateTime closedDate;
}