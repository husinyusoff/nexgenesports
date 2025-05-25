package All;

import org.mindrot.jbcrypt.BCrypt;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String userID = req.getParameter("userID");
        String password = req.getParameter("password");
        String selectedRole = req.getParameter("selectedRole");
        try (Connection c = DBConnection.getConnection(); 
             PreparedStatement ps = c.prepareStatement("SELECT password_hash, role, position FROM users WHERE userID=?")) {
            ps.setString(1, userID);
            ResultSet rs = ps.executeQuery();
            if (!rs.next() || !BCrypt.checkpw(password, rs.getString("password_hash")) || !RoleUtils.isAllowedRole(rs.getString("role"), selectedRole)) {
                resp.sendRedirect("login.jsp?error=badcreds");
                return;
            }
            String dbRole = rs.getString("role");
            String position = rs.getString("position");
            String actualRole = ("high_council".equals(dbRole) && "president".equals(position)) ? "superadmin" : selectedRole;
            HttpSession sess = req.getSession(true);
            sess.setAttribute("username", userID);
            sess.setAttribute("role", actualRole);
            sess.setAttribute("position", position);

            try (PreparedStatement ups = c.prepareStatement("UPDATE users SET sessionID=? WHERE userID=?")) {
                ups.setString(1, sess.getId());
                ups.setString(2, userID);
                ups.executeUpdate();
            }
            switch (actualRole) {
                case "athlete":
                    resp.sendRedirect("athleteDashboard.jsp");
                    break;
                case "executive_council":
                    resp.sendRedirect("execDashboard.jsp");
                    break;
                case "high_council":
                    resp.sendRedirect("adminDashboard.jsp");
                    break;
                case "superadmin":
                    resp.sendRedirect("superAdmin.jsp");
                    break;
                case "referee":
                    resp.sendRedirect("refereeDashboard.jsp");
                    break;
                default:
                    resp.sendRedirect("accessDenied.jsp");
                    break;
            }
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }
}