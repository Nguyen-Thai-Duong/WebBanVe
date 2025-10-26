package controller.customer.command;

import controller.core.Command;
import controller.core.CommandResult;
import dto.customer.CustomerProfileForm;
import dto.customer.CustomerProfileView;
import dto.customer.ProfileUpdateResult;
import dto.customer.CustomerTicketOverview;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.util.List;
import model.User;
import service.CustomerService;
import service.CustomerTicketService;
import service.impl.CustomerServiceImpl;
import service.impl.CustomerTicketServiceImpl;

public class CustomerProfileUpdateCommand implements Command {

    private final CustomerService customerService = new CustomerServiceImpl();
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

        CustomerProfileForm form = new CustomerProfileForm();
        form.setFullName(request.getParameter("fullName"));
        form.setPhoneNumber(request.getParameter("phoneNumber"));
        form.setAddress(request.getParameter("address"));

        ProfileUpdateResult result = customerService.updateProfile(currentUser.getUserId(), form);
        if (result.isSuccess()) {
            updateSessionUser(currentUser, result.getProfileData(), session);
            if (session != null) {
                session.setAttribute(CustomerProfileViewCommand.FLASH_KEY, result.getSuccessMessage());
            }
            return CommandResult.redirect("/app/customer/profile");
        }

        CustomerProfileView profileView = result.getProfileData();
        if (profileView == null) {
            return CommandResult.redirect("/login");
        }

        CustomerTicketOverview overview = ticketService.buildTicketOverview(profileView.getUserId());

        request.setAttribute(CustomerProfileViewCommand.PROFILE_ATTRIBUTE, profileView);
        request.setAttribute(CustomerProfileViewCommand.FORM_ATTRIBUTE, result.getForm());
        List<String> errors = result.getErrors();
        if (!errors.isEmpty()) {
            request.setAttribute("errorMessage", errors.get(0));
        }
        request.setAttribute(CustomerProfileViewCommand.ERROR_LIST_ATTRIBUTE, errors);
        request.setAttribute(CustomerTicketListCommand.OVERVIEW_ATTRIBUTE, overview);
        return CommandResult.forward("/WEB-INF/customer/profile.jsp");
    }

    private void updateSessionUser(User sessionUser, CustomerProfileView profile, HttpSession session) {
        sessionUser.setFullName(profile.getFullName());
        sessionUser.setPhoneNumber(profile.getPhoneNumber());
        sessionUser.setAddress(profile.getAddress());
        if (session != null) {
            session.setAttribute("currentUser", sessionUser);
        }
    }
}
