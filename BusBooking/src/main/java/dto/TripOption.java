package dto;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

/**
 * Represents a simplified trip projection for selection lists.
 */
public class TripOption {

    private Integer tripId;
    private String routeLabel;
    private LocalDateTime departureTime;
    private LocalDateTime arrivalTime;
    private String vehicleLabel;

    public Integer getTripId() {
        return tripId;
    }

    public void setTripId(Integer tripId) {
        this.tripId = tripId;
    }

    public String getRouteLabel() {
        return routeLabel;
    }

    public void setRouteLabel(String routeLabel) {
        this.routeLabel = routeLabel;
    }

    public LocalDateTime getDepartureTime() {
        return departureTime;
    }

    public void setDepartureTime(LocalDateTime departureTime) {
        this.departureTime = departureTime;
    }

    public LocalDateTime getArrivalTime() {
        return arrivalTime;
    }

    public void setArrivalTime(LocalDateTime arrivalTime) {
        this.arrivalTime = arrivalTime;
    }

    public String getVehicleLabel() {
        return vehicleLabel;
    }

    public void setVehicleLabel(String vehicleLabel) {
        this.vehicleLabel = vehicleLabel;
    }

    public String formatDeparture(DateTimeFormatter formatter) {
        return formatDate(departureTime, formatter);
    }

    public String formatArrival(DateTimeFormatter formatter) {
        return formatDate(arrivalTime, formatter);
    }

    private String formatDate(LocalDateTime dateTime, DateTimeFormatter formatter) {
        if (dateTime == null || formatter == null) {
            return null;
        }
        return formatter.format(dateTime);
    }
}
