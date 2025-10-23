package controller.admin;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * Serves the admin account settings page based on the Sneat template.
 */
@WebServlet(name = "AccountSettingsController", urlPatterns = {"/admin/account-settings"})
public class AccountSettingsController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/WEB-INF/admin/account-settings.jsp").forward(request, response);
    }

    @Override
    public String getServletInfo() {
        return "Admin account settings controller";
    }
}
