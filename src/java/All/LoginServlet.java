package All;

import org.mindrot.jbcrypt.BCrypt;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String userID       = req.getParameter("userID");
        String password     = req.getParameter("password");
        String selectedRole = req.getParameter("selectedRole");

        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(
                 "SELECT password_hash, role, position FROM users WHERE userID = ?")) {

            ps.setString(1, userID);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()
                    || !BCrypt.checkpw(password, rs.getString("password_hash"))
                    || !RoleUtils.isAllowedRole(rs.getString("role"), selectedRole)) {
                    resp.sendRedirect(req.getContextPath() + "/login.jsp?error=badcreds");
                    return;
                }

                String dbRole    = rs.getString("role");
                String position  = rs.getString("position");
                String actualRole =
                    ("high_council".equals(dbRole) && "president".equals(position))
                    ? "superadmin"
                    : selectedRole;

                HttpSession session = req.getSession(true);
                session.setAttribute("username", userID);
                session.setAttribute("role",     actualRole);
                session.setAttribute("position", position);

                // persist sessionID
                try (PreparedStatement ups = c.prepareStatement(
                    "UPDATE users SET sessionID = ? WHERE userID = ?")) {
                    ups.setString(1, session.getId());
                    ups.setString(2, userID);
                    ups.executeUpdate();
                }

                // --- NEW: Always go to the one dashboard.jsp ---
                resp.sendRedirect(req.getContextPath() + "/dashboard.jsp");  // NEW
            }

        } catch (Exception e) {
            throw new ServletException(e);
        }
    }
}
