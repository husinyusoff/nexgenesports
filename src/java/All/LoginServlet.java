package All;

import org.mindrot.jbcrypt.BCrypt;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.*;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {
  @Override
  protected void doPost(HttpServletRequest req, HttpServletResponse resp)
      throws ServletException, IOException {

    String userID     = req.getParameter("userID");
    String password   = req.getParameter("password");
    String chosenRole = req.getParameter("selectedRole");

    try (Connection c = DBConnection.getConnection()) {
      // 1) authenticate & get rp_id
      int storedRpId;
      try (PreparedStatement auth = c.prepareStatement(
             "SELECT password_hash, rp_id FROM users WHERE userID = ?")) {
        auth.setString(1, userID);
        try (ResultSet rs = auth.executeQuery()) {
          if (!rs.next()
           || !BCrypt.checkpw(password, rs.getString("password_hash"))) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp?error=badcreds");
            return;
          }
          storedRpId = rs.getInt("rp_id");
        }
      }

      // 2) fetch base role & position
      String baseRole, position;
      try (PreparedStatement rpinfo = c.prepareStatement(
             "SELECT role, position FROM role_positions WHERE id = ?")) {
        rpinfo.setInt(1, storedRpId);
        try (ResultSet r2 = rpinfo.executeQuery()) {
          if (!r2.next()) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp?error=badcreds");
            return;
          }
          baseRole = r2.getString("role");
          position = r2.getString("position");
        }
      }

      // 3) build storedRoles by inheritance
      List<String> storedRoles = new ArrayList<>();
      switch (baseRole) {
        case "athlete":
          storedRoles.add("athlete"); break;
        case "executive_council":
          storedRoles.addAll(List.of("executive_council","athlete")); break;
        case "high_council":
          storedRoles.addAll(
            List.of("high_council","executive_council","athlete")); break;
        case "referee":
          storedRoles.add("referee"); break;
        default:
          resp.sendRedirect(req.getContextPath()+"/login.jsp?error=badcreds");
          return;
      }

      // 4) ensure they picked a valid role
      if (!storedRoles.contains(chosenRole)) {
        resp.sendRedirect(req.getContextPath()+"/login.jsp?error=badcreds");
        return;
      }

      // 5) build effectiveRoles based on chosenRole
      List<String> effectiveRoles = new ArrayList<>();
      switch (chosenRole) {
        case "athlete":
          effectiveRoles.add("athlete"); break;
        case "executive_council":
          effectiveRoles.addAll(List.of("executive_council","athlete")); break;
        case "high_council":
          effectiveRoles.addAll(
            List.of("high_council","executive_council","athlete")); break;
        case "referee":
          effectiveRoles.add("referee"); break;
      }

      // 6) store in session & go to dashboard
      HttpSession session = req.getSession(true);
      session.setAttribute("username",       userID);
      session.setAttribute("role",           chosenRole);
      session.setAttribute("position",       position);
      session.setAttribute("effectiveRoles", effectiveRoles);

      resp.sendRedirect(req.getContextPath() + "/dashboard.jsp");
    }
    catch (Exception e) {
      throw new ServletException(e);
    }
  }
}
