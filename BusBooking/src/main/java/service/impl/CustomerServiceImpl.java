package service.impl;

import DAO.UserDAO;
import dto.customer.CustomerProfileForm;
import dto.customer.CustomerProfileView;
import dto.customer.ProfileUpdateResult;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.regex.Pattern;
import model.User;
import service.CustomerService;

public class CustomerServiceImpl implements CustomerService {

    private static final Pattern PHONE_PATTERN = Pattern.compile("^0[0-9]{9,10}$");

    private final UserDAO userDAO = new UserDAO();

    @Override
    public Optional<CustomerProfileView> loadProfile(int userId) {
        User user = userDAO.findById(userId);
        if (user == null) {
            return Optional.empty();
        }
        return Optional.of(mapToView(user));
    }

    @Override
    public ProfileUpdateResult updateProfile(int userId, CustomerProfileForm form) {
        CustomerProfileForm sanitizedForm = sanitize(form);
        Optional<CustomerProfileView> currentOpt = loadProfile(userId);
        if (currentOpt.isEmpty()) {
            List<String> errors = List.of("Không tìm thấy tài khoản của bạn. Vui lòng đăng nhập lại.");
            return ProfileUpdateResult.failure(null, sanitizedForm, errors);
        }

        CustomerProfileView current = currentOpt.get();
        List<String> errors = validate(userId, sanitizedForm);
        if (!errors.isEmpty()) {
            return ProfileUpdateResult.failure(current, sanitizedForm, errors);
        }

        boolean updated = userDAO.updateCustomerProfile(userId,
                sanitizedForm.getFullName(), sanitizedForm.getPhoneNumber(), sanitizedForm.getAddress());
        if (!updated) {
            errors.add("Không thể cập nhật thông tin vào lúc này. Vui lòng thử lại sau.");
            return ProfileUpdateResult.failure(current, sanitizedForm, errors);
        }

        current.setFullName(sanitizedForm.getFullName());
        current.setPhoneNumber(sanitizedForm.getPhoneNumber());
        current.setAddress(sanitizedForm.getAddress());
        return ProfileUpdateResult.success(current, "Cập nhật thông tin thành công.");
    }

    private CustomerProfileForm sanitize(CustomerProfileForm form) {
        CustomerProfileForm sanitized = new CustomerProfileForm();
        if (form != null) {
            sanitized.setFullName(trim(form.getFullName()));
            sanitized.setPhoneNumber(trim(form.getPhoneNumber()));
            sanitized.setAddress(trim(form.getAddress()));
        }
        return sanitized;
    }

    private List<String> validate(int userId, CustomerProfileForm form) {
        List<String> errors = new ArrayList<>();
        if (form.getFullName() == null || form.getFullName().isBlank()) {
            errors.add("Vui lòng nhập họ và tên.");
        }
        if (form.getPhoneNumber() == null || !PHONE_PATTERN.matcher(form.getPhoneNumber()).matches()) {
            errors.add("Số điện thoại không hợp lệ. Vui lòng nhập 10-11 số và bắt đầu bằng 0.");
        } else if (userDAO.phoneExistsForOtherUser(form.getPhoneNumber(), userId)) {
            errors.add("Số điện thoại đã được sử dụng bởi tài khoản khác.");
        }
        return errors;
    }

    private CustomerProfileView mapToView(User user) {
        CustomerProfileView view = new CustomerProfileView();
        view.setUserId(user.getUserId());
        view.setFullName(user.getFullName());
        view.setEmail(user.getEmail());
        view.setPhoneNumber(user.getPhoneNumber());
        view.setAddress(user.getAddress());
        view.setRole(user.getRole());
        view.setEmployeeCode(user.getEmployeeCode());
        return view;
    }

    private String trim(String value) {
        return value != null ? value.trim() : null;
    }
}
