package service;

import dto.customer.CustomerProfileForm;
import dto.customer.CustomerProfileView;
import dto.customer.ProfileUpdateResult;
import java.util.Optional;

public interface CustomerService {

    Optional<CustomerProfileView> loadProfile(int userId);

    ProfileUpdateResult updateProfile(int userId, CustomerProfileForm form);
}
