package controller.core;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Defines a single unit of work handled by the front controller.
 */
@FunctionalInterface
public interface Command {

    CommandResult execute(HttpServletRequest request, HttpServletResponse response) throws Exception;
}
