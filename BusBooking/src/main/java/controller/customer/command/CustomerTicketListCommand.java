package controller.customer.command;

import controller.core.Command;
import controller.core.CommandResult;
import dto.customer.CustomerTicketOverview;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;
import service.CustomerTicketService;
import service.impl.CustomerTicketServiceImpl;

public class CustomerTicketListCommand implements Command {

    public static final String OVERVIEW_ATTRIBUTE = "ticketOverview";

    private final CustomerTicketService ticketService = new CustomerTicketServiceImpl();

    @Override
    public CommandResult execute(HttpServletRequest request, HttpServletResponse response) throws Exception {
        HttpSession session = request.getSession(false);
        User currentUser = session != null ? (User) session.getAttribute("currentUser") : null;
        if (currentUser == null) {
            return CommandResult.redirect("/login");
        }
        if (!"Customer".equalsIgnoreCase(currentUser.getRole())) {
            return CommandResult.redirect("/");
        }

        CustomerTicketOverview overview = ticketService.buildTicketOverview(currentUser.getUserId());
        if (overview == null) {
            return CommandResult.redirect("/app/customer/profile");
        }
        request.setAttribute(OVERVIEW_ATTRIBUTE, overview);
        request.setAttribute("customerName", currentUser.getFullName());
        return CommandResult.forward("/WEB-INF/customer/tickets.jsp");
    }
}
