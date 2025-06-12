package All;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.*;

@WebServlet("/auditLog")
public class AuditLogServlet extends HttpServlet {
  @Override
  protected void doGet(HttpServletRequest req, HttpServletResponse resp)
      throws ServletException, IOException {

    HttpSession sess = req.getSession(false);
    String userId = sess!=null ? (String)sess.getAttribute("username") : null;
    if (userId==null) {
      resp.sendRedirect("login.jsp");
      return;
    }
    // Only allow admins
    Boolean isAdmin = Boolean.TRUE.equals(sess.getAttribute("isAdmin"));
    if (!isAdmin) {
      resp.sendRedirect("accessDenied.jsp");
      return;
    }

    List<Map<String,Object>> logs = new ArrayList<>();
    try (Connection c = DBConnection.getConnection();
         PreparedStatement p = c.prepareStatement(
           "SELECT timestamp,performedBy,entityType,entityID,actionType,details " +
           "  FROM AuditLog " +
           " ORDER BY timestamp DESC LIMIT 500")) {
      try (ResultSet rs = p.executeQuery()) {
        while (rs.next()) {
          Map<String,Object> row = new HashMap<>();
          row.put("timestamp",     rs.getTimestamp("timestamp"));
          row.put("performedBy",   rs.getString("performedBy"));
          row.put("entityType",    rs.getString("entityType"));
          row.put("entityID",      rs.getString("entityID"));
          row.put("actionType",    rs.getString("actionType"));
          row.put("details",       rs.getString("details"));
          logs.add(row);
        }
      }
    } catch (SQLException e) {
      throw new ServletException(e);
    }

    req.setAttribute("logs", logs);
    req.getRequestDispatcher("auditLog.jsp").forward(req, resp);
  }
}
