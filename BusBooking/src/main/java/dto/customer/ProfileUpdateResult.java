package dto.customer;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class ProfileUpdateResult {

    private final boolean success;
    private final CustomerProfileView profileData;
    private final CustomerProfileForm form;
    private final List<String> errors;
    private final String successMessage;

    private ProfileUpdateResult(boolean success, CustomerProfileView profileData, CustomerProfileForm form,
            List<String> errors, String successMessage) {
        this.success = success;
        this.profileData = profileData;
        this.form = form;
        this.errors = errors != null ? new ArrayList<>(errors) : Collections.emptyList();
        this.successMessage = successMessage;
    }

    public static ProfileUpdateResult success(CustomerProfileView profileData, String successMessage) {
        return new ProfileUpdateResult(true, profileData, toForm(profileData), Collections.emptyList(), successMessage);
    }

    public static ProfileUpdateResult failure(CustomerProfileView profileData, CustomerProfileForm form, List<String> errors) {
        return new ProfileUpdateResult(false, profileData, form, errors, null);
    }

    private static CustomerProfileForm toForm(CustomerProfileView profile) {
        CustomerProfileForm form = new CustomerProfileForm();
        if (profile != null) {
            form.setFullName(profile.getFullName());
            form.setPhoneNumber(profile.getPhoneNumber());
            form.setAddress(profile.getAddress());
        }
        return form;
    }

    public boolean isSuccess() {
        return success;
    }

    public CustomerProfileView getProfileData() {
        return profileData;
    }

    public CustomerProfileForm getForm() {
        return form;
    }

    public List<String> getErrors() {
        return Collections.unmodifiableList(errors);
    }

    public String getSuccessMessage() {
        return successMessage;
    }
}
