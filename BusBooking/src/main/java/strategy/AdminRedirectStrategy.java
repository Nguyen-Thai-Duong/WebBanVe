package strategy;

import model.User;

/**
 * Redirect strategy for Admin role.
 */
public class AdminRedirectStrategy implements RoleRedirectStrategy {
    
    @Override
    public String resolve(User user, String contextPath) {
        return contextPath + "/admin/dashboard";
    }
}
