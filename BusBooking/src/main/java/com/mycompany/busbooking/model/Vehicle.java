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
import java.time.LocalDate;
import java.time.LocalDateTime;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@Entity
@Table(name = "VEHICLE")
public class Vehicle implements Serializable {

    private static final long serialVersionUID = 1L;

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "VehicleID")
    private Integer vehicleId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "EmployeeCode", referencedColumnName = "EmployeeCode", nullable = false)
    private User operator;

    @Column(name = "LicensePlate", nullable = false, length = 50, unique = true)
    private String licensePlate;

    @Column(name = "Model", length = 100)
    private String model;

    @Column(name = "Capacity", nullable = false)
    private Integer capacity;

    @Column(name = "DateAdded")
    private LocalDateTime dateAdded;

    @Column(name = "MaintenanceIntervalDays")
    private Integer maintenanceIntervalDays;

    @Column(name = "LastMaintenanceDate")
    private LocalDate lastMaintenanceDate;

    @Column(name = "LastRepairDate")
    private LocalDate lastRepairDate;

    @Column(name = "Details", columnDefinition = "NVARCHAR(MAX)")
    private String details;

    @Column(name = "VehicleStatus", nullable = false, length = 50)
    private String vehicleStatus = "Available";

    @Column(name = "CurrentCondition", length = 50)
    private String currentCondition;
}