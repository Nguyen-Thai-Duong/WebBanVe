package strategy;

import model.User;

/**
 * Redirect strategy for Customer role.
 */
public class CustomerRedirectStrategy implements RoleRedirectStrategy {
    
    @Override
    public String resolve(User user, String contextPath) {
        return contextPath + "/homepage.jsp";
    }
}
