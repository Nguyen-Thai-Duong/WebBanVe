package filter;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.Set;
import model.User;

/**
 * Ensures only authenticated admin-related roles can access /admin/* resources.
 */
@WebFilter(filterName = "AdminAuthorizationFilter", urlPatterns = {"/admin/*"})
public class AdminAuthorizationFilter extends HttpFilter implements Filter {

    private static final long serialVersionUID = 1L;
    private static final Set<String> ALLOWED_ROLES = Set.of("Admin", "Staff", "BusOperator");

    @Override
    protected void doFilter(HttpServletRequest request, HttpServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpSession session = request.getSession(false);
        User currentUser = session != null ? (User) session.getAttribute("currentUser") : null;

        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        if (!ALLOWED_ROLES.contains(currentUser.getRole())) {
            response.sendRedirect(request.getContextPath() + "/homepage.jsp");
            return;
        }
        chain.doFilter(request, response);
    }
}
