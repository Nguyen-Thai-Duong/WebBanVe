package strategy;

import model.User;

/**
 * Redirect strategy for BusOperator role.
 */
public class BusOperatorRedirectStrategy implements RoleRedirectStrategy {
    
    @Override
    public String resolve(User user, String contextPath) {
        return contextPath + "/bus-operator/dashboard";
    }
}
