package controller.busoperator;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import model.User;

/**
 * Serves the account settings page for bus operators.
 */
@WebServlet(name = "OperatorAccountSettingsController", urlPatterns = {"/bus-operator/account-settings"})
public class OperatorAccountSettingsController extends HttpServlet {

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
        request.getRequestDispatcher("/WEB-INF/busOperator/account-settings.jsp").forward(request, response);
    }

    @Override
    public String getServletInfo() {
        return "Bus operator account settings controller";
    }
}
