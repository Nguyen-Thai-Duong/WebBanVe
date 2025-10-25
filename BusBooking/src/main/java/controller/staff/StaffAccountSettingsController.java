package controller.staff;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import model.User;

/**
 * Serves the staff account settings page using the Sneat template layout.
 */
@WebServlet(name = "StaffAccountSettingsController", urlPatterns = {"/staff/account-settings"})
public class StaffAccountSettingsController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User currentUser = session != null ? (User) session.getAttribute("currentUser") : null;
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        request.setAttribute("activeMenu", "account-settings");
        request.setAttribute("navbarHideSearch", Boolean.TRUE);
        request.setAttribute("navbarSearchPlaceholder", "Tìm kiếm...");
        request.getRequestDispatcher("/WEB-INF/staff/account-settings.jsp").forward(request, response);
    }

    @Override
    public String getServletInfo() {
        return "Staff account settings controller";
    }
}
