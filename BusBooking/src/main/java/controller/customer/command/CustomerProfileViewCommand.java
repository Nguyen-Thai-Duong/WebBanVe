package controller.customer.command;

import controller.core.Command;
import controller.core.CommandResult;
import dto.customer.CustomerProfileForm;
import dto.customer.CustomerProfileView;
import dto.customer.CustomerTicketOverview;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.util.Collections;
import java.util.Optional;
import model.User;
import service.CustomerService;
import service.CustomerTicketService;
import service.impl.CustomerServiceImpl;
import service.impl.CustomerTicketServiceImpl;

public class CustomerProfileViewCommand implements Command {

    public static final String PROFILE_ATTRIBUTE = "profileView";
    public static final String FORM_ATTRIBUTE = "profileForm";
    public static final String ERROR_LIST_ATTRIBUTE = "validationErrors";
    public static final String SUCCESS_ATTRIBUTE = "successMessage";
    public static final String FLASH_KEY = "customerProfileSuccess";

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

        Optional<CustomerProfileView> profileOpt = customerService.loadProfile(currentUser.getUserId());
        if (profileOpt.isEmpty()) {
            if (session != null) {
                session.invalidate();
            }
            return CommandResult.redirect("/login");
        }

        if (session != null) {
            Object flash = session.getAttribute(FLASH_KEY);
            if (flash != null) {
                request.setAttribute(SUCCESS_ATTRIBUTE, flash.toString());
                session.removeAttribute(FLASH_KEY);
            }
        }

        CustomerProfileView profile = profileOpt.get();
        CustomerTicketOverview overview = ticketService.buildTicketOverview(profile.getUserId());

        request.setAttribute(PROFILE_ATTRIBUTE, profile);
        request.setAttribute(FORM_ATTRIBUTE, buildFormFromProfile(profile));
        request.setAttribute(ERROR_LIST_ATTRIBUTE, Collections.emptyList());
        request.setAttribute(CustomerTicketListCommand.OVERVIEW_ATTRIBUTE, overview);
        return CommandResult.forward("/WEB-INF/customer/profile.jsp");
    }

    private CustomerProfileForm buildFormFromProfile(CustomerProfileView profile) {
        CustomerProfileForm form = new CustomerProfileForm();
        form.setFullName(profile.getFullName());
        form.setPhoneNumber(profile.getPhoneNumber());
        form.setAddress(profile.getAddress());
        return form;
    }
}
