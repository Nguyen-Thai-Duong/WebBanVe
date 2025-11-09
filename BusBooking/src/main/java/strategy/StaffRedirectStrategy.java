package strategy;

import model.User;

/**
 * Redirect strategy for Staff role.
 */
public class StaffRedirectStrategy implements RoleRedirectStrategy {
    
    @Override
    public String resolve(User user, String contextPath) {
        return contextPath + "/staff/dashboard";
    }
}
