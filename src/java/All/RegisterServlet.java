// src/All/RegisterServlet.java
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

    ServletContext ctx = getServletContext();
    ctx.log("[RegisterServlet] doPost() invoked");

    String userID   = req.getParameter("userID");
    String name     = req.getParameter("name");
    String pass     = req.getParameter("password");
    String confirm  = req.getParameter("confirmPassword");
    String phone    = req.getParameter("phoneNumber");
    String role     = req.getParameter("role");
    String position = req.getParameter("position");
    String gpIdStr  = req.getParameter("gamingPassID");

    ctx.log("[RegisterServlet] Params – userID=" + userID
            + ", name=" + name + ", role=" + role
            + ", position=" + position
            + ", gamingPassID=" + gpIdStr);

    // 1) Password match check
    if (!pass.equals(confirm)) {
      ctx.log("[RegisterServlet] Password mismatch for userID=" + userID);
      req.setAttribute("message", "❌ Passwords do not match.");
      req.getRequestDispatcher("registerResult.jsp").forward(req, resp);
      return;
    }

    // 2) Hash the password
    String hash = BCrypt.hashpw(pass, BCrypt.gensalt());
    ctx.log("[RegisterServlet] Password hashed");

    String sql = "INSERT INTO users "
               + "(userID, name, password_hash, phoneNumber, role, position, gamingPassID) "
               + "VALUES (?, ?, ?, ?, ?, ?, ?)";

    try (Connection c = DBConnection.getConnection();
         PreparedStatement ps = c.prepareStatement(sql)) {

      ctx.log("[RegisterServlet] Got DB connection and preparing INSERT");

      ps.setString(1, userID);
      ps.setString(2, name);
      ps.setString(3, hash);
      ps.setString(4, phone);
      ps.setString(5, role);

      if (position == null || position.isEmpty()) {
        ps.setNull(6, Types.VARCHAR);
        ctx.log("[RegisterServlet] position → NULL");
      } else {
        ps.setString(6, position);
        ctx.log("[RegisterServlet] position → " + position);
      }

      if (gpIdStr == null || gpIdStr.isEmpty()) {
        ps.setNull(7, Types.INTEGER);
        ctx.log("[RegisterServlet] gamingPassID → NULL");
      } else {
        int gpId = Integer.parseInt(gpIdStr);
        ps.setInt(7, gpId);
        ctx.log("[RegisterServlet] gamingPassID → " + gpId);
      }

      int rows = ps.executeUpdate();
      ctx.log("[RegisterServlet] executeUpdate() returned rows=" + rows);

      if (rows > 0) {
        req.setAttribute("message", "✅ Registration successful! Rows inserted: " + rows);
      } else {
        req.setAttribute("message", "⚠️ No rows were inserted. Check your SQL/table.");
      }

    } catch (SQLIntegrityConstraintViolationException e) {
      ctx.log("[RegisterServlet] Duplicate key for userID=" + userID, e);
      req.setAttribute("message", "❌ That UserID already exists.");
    } catch (Exception e) {
      ctx.log("[RegisterServlet] Unexpected error", e);
      req.setAttribute("message", "❌ Registration failed: " + e.getMessage());
    }

    // 3) Forward to result page so you can see both the message and tail the logs
    req.getRequestDispatcher("registerResult.jsp").forward(req, resp);
  }
}
