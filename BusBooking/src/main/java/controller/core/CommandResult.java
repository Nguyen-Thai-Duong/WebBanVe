package controller.core;

import jakarta.servlet.http.HttpServletRequest;

/**
 * Represents the outcome of a command execution.
 */
public class CommandResult {

    public enum DispatchType {
        FORWARD,
        REDIRECT
    }

    private final DispatchType type;
    private final String destination;

    private CommandResult(DispatchType type, String destination) {
        this.type = type;
        this.destination = destination;
    }

    public static CommandResult forward(String path) {
        return new CommandResult(DispatchType.FORWARD, path);
    }

    public static CommandResult redirect(String location) {
        return new CommandResult(DispatchType.REDIRECT, location);
    }

    public DispatchType getType() {
        return type;
    }

    public String getDestination() {
        return destination;
    }

    public String resolveRedirect(HttpServletRequest request) {
        if (destination == null || destination.isBlank()) {
            return request.getContextPath() + "/";
        }
        if (destination.startsWith("http://") || destination.startsWith("https://")) {
            return destination;
        }
        if (destination.startsWith("/")) {
            return request.getContextPath() + destination;
        }
        return request.getContextPath() + "/" + destination;
    }
}
