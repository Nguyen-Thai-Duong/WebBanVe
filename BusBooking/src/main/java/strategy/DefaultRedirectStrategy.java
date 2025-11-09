package strategy;

import model.User;

/**
 * Default redirect strategy when role is unknown or null.
 */
public class DefaultRedirectStrategy implements RoleRedirectStrategy {
    
    @Override
    public String resolve(User user, String contextPath) {
        return contextPath + "/homepage.jsp";
    }
}
