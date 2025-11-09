package service.admin;

import jakarta.servlet.http.HttpSession;

/**
 * Base service class with common helper methods for admin services.
 */
public abstract class BaseAdminService {
    
    /**
     * Set a flash message in the session.
     * 
     * @param session the HTTP session
     * @param key the message key
     * @param message the message text
     * @param type the message type (success, danger, warning, info)
     */
    protected void setFlash(HttpSession session, String key, String message, String type) {
        if (session != null) {
            session.setAttribute(key, message);
            session.setAttribute(key + "Type", type);
        }
    }
    
    /**
     * Parse an integer from a string value.
     * 
     * @param value the string value
     * @return the integer value, or null if parsing fails
     */
    protected Integer parseInteger(String value) {
        try {
            return value != null && !value.isBlank() ? Integer.valueOf(value) : null;
        } catch (NumberFormatException ex) {
            return null;
        }
    }
    
    /**
     * Trim a string value.
     * 
     * @param value the string value
     * @return the trimmed value, or null if empty
     */
    protected String trim(String value) {
        if (value == null) {
            return null;
        }
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }
    
    /**
     * Return default value if input is blank.
     * 
     * @param value the string value
     * @param fallback the fallback value
     * @return the value or fallback
     */
    protected String defaultIfBlank(String value, String fallback) {
        if (value == null) {
            return fallback;
        }
        String trimmed = value.trim();
        return trimmed.isEmpty() ? fallback : trimmed;
    }
}
