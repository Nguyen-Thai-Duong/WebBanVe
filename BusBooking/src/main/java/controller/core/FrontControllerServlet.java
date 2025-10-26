package controller.core;

import controller.customer.command.CustomerProfileUpdateCommand;
import controller.customer.command.CustomerProfileViewCommand;
import controller.customer.command.CustomerTicketListCommand;
import jakarta.servlet.ServletConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.Optional;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Centralizes request routing using the Command pattern.
 */
@WebServlet(name = "FrontControllerServlet", urlPatterns = {"/app/*"}, loadOnStartup = 1)
public class FrontControllerServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(FrontControllerServlet.class.getName());

    private final CommandRegistry registry = new CommandRegistry();

    @Override
    public void init(ServletConfig config) throws ServletException {
        super.init(config);
        registerCommands();
    }

    private void registerCommands() {
        registry.register("GET", "/customer/profile", new CustomerProfileViewCommand());
        registry.register("POST", "/customer/profile", new CustomerProfileUpdateCommand());
        registry.register("GET", "/customer/tickets", new CustomerTicketListCommand());
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        dispatch(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        dispatch(request, response);
    }

    @Override
    protected void doPut(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        dispatch(request, response);
    }

    @Override
    protected void doDelete(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        dispatch(request, response);
    }

    private void dispatch(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String pathInfo = request.getPathInfo();
        String method = request.getMethod();
        Optional<Command> commandOptional = registry.lookup(method, pathInfo == null ? "/" : pathInfo);
        if (commandOptional.isEmpty()) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }
        try {
            CommandResult result = commandOptional.get().execute(request, response);
            if (result == null) {
                return;
            }
            switch (result.getType()) {
                case FORWARD:
                    request.getRequestDispatcher(result.getDestination()).forward(request, response);
                    break;
                case REDIRECT:
                    response.sendRedirect(result.resolveRedirect(request));
                    break;
                default:
                    response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                    break;
            }
        } catch (Exception ex) {
            LOGGER.log(Level.SEVERE, "Unhandled exception in front controller", ex);
            throw new ServletException("Could not process request", ex);
        }
    }
}
