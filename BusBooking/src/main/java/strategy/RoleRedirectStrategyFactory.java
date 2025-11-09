package strategy;

import java.util.HashMap;
import java.util.Map;

/**
 * Factory for getting the appropriate RoleRedirectStrategy based on user role.
 */
public class RoleRedirectStrategyFactory {
    
    private static final Map<String, RoleRedirectStrategy> strategies = new HashMap<>();
    private static final RoleRedirectStrategy defaultStrategy = new DefaultRedirectStrategy();
    
    static {
        strategies.put("Admin", new AdminRedirectStrategy());
        strategies.put("Staff", new StaffRedirectStrategy());
        strategies.put("BusOperator", new BusOperatorRedirectStrategy());
        strategies.put("Customer", new CustomerRedirectStrategy());
    }
    
    /**
     * Get the redirect strategy for the given role.
     * 
     * @param role the user role
     * @return the appropriate redirect strategy, or default if role is not recognized
     */
    public static RoleRedirectStrategy get(String role) {
        return strategies.getOrDefault(role, defaultStrategy);
    }
}
