package All;

import org.mindrot.jbcrypt.BCrypt;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;

@WebServlet("/RegisterServlet")
public class RegisterServlet extends HttpServlet {
  @Override
  protected void doPost(HttpServletRequest req, HttpServletResponse resp)
      throws ServletException, IOException {

    String userID        = req.getParameter("userID");
    String name          = req.getParameter("name");
    String pass          = req.getParameter("password");
    String confirm       = req.getParameter("confirmPassword");
    String phone         = req.getParameter("phoneNumber");
    String role          = req.getParameter("role");
    String position      = req.getParameter("position");
    String clubSessionID = req.getParameter("clubSessionID");
    String gpIdStr       = req.getParameter("gamingPassID");

    // 1) Password match check
    if (!pass.equals(confirm)) {
      req.setAttribute("message", "❌ Passwords do not match.");
      req.getRequestDispatcher("registerResult.jsp").forward(req, resp);
      return;
    }

    String hash = BCrypt.hashpw(pass, BCrypt.gensalt());
    Integer rpId;

    try (Connection c = DBConnection.getConnection();
         PreparedStatement getRp = c.prepareStatement(
           "SELECT id FROM role_positions WHERE role = ? "
         + (position==null||position.isEmpty()
            ? "AND position IS NULL"
            : "AND position = ?"))) {
      getRp.setString(1, role);
      if (position!=null && !position.isEmpty()) {
        getRp.setString(2, position);
      }
      try (ResultSet r = getRp.executeQuery()) {
        if (!r.next()) {
          req.setAttribute("message", "❌ Invalid role/position.");
          req.getRequestDispatcher("registerResult.jsp").forward(req, resp);
          return;
        }
        rpId = r.getInt("id");
      }

      // 2) Insert new user
      String sql =
        "INSERT INTO users "
      + "(userID, name, password_hash, phoneNumber, rpid, clubSessionID, gamingPassID) "
      + "VALUES (?,?,?,?,?,?,?)";
      try (PreparedStatement ps = c.prepareStatement(sql)) {
        ps.setString(1, userID);
        ps.setString(2, name);
        ps.setString(3, hash);
        ps.setString(4, phone);
        ps.setInt(5, rpId);
        ps.setString(6, clubSessionID);
        if (gpIdStr==null || gpIdStr.isEmpty()) {
          ps.setNull(7, Types.INTEGER);
        } else {
          ps.setInt(7, Integer.parseInt(gpIdStr));
        }
        int rows = ps.executeUpdate();
        req.setAttribute("message",
          rows > 0 ? "✅ Registration successful!" : "⚠️ No rows inserted.");
      }
    } catch (SQLIntegrityConstraintViolationException e) {
      req.setAttribute("message", "❌ That UserID already exists.");
    } catch (Exception e) {
      req.setAttribute("message", "❌ Registration failed: " + e.getMessage());
    }

    req.getRequestDispatcher("registerResult.jsp").forward(req, resp);
  }
}
