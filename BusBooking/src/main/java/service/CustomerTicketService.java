package service;

import dto.customer.CustomerTicketOverview;

public interface CustomerTicketService {

    CustomerTicketOverview buildTicketOverview(int userId);
}
