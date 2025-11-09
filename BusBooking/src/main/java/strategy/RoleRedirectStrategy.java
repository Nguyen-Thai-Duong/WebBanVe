package strategy;

import model.User;

/**
 * Strategy interface for role-based redirect after login.
 */
public interface RoleRedirectStrategy {
    
    /**
     * Resolve the redirect path for the given user.
     * 
     * @param user the authenticated user
     * @param contextPath the servlet context path
     * @return the redirect URL path
     */
    String resolve(User user, String contextPath);
}
