package All;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.*;

@WebServlet("/notifications")
public class NotificationsServlet extends HttpServlet {
  @Override
  protected void doGet(HttpServletRequest req, HttpServletResponse resp)
      throws ServletException, IOException {
    HttpSession sess = req.getSession(false);
    String userId = (sess!=null)?(String)sess.getAttribute("username"):null;
    if (userId == null) {
      resp.sendRedirect("login.jsp");
      return;
    }

    List<Map<String,Object>> notes = new ArrayList<>();
    try (Connection c = DBConnection.getConnection();
         PreparedStatement p = c.prepareStatement(
           "SELECT notificationID, type, referenceType, referenceID, severity, channel, isRead, createdAt " +
           "  FROM Notification WHERE userID = ? ORDER BY createdAt DESC")) {
      p.setString(1, userId);
      try (ResultSet rs = p.executeQuery()) {
        while (rs.next()) {
          Map<String,Object> n = new HashMap<>();
          n.put("notificationID", rs.getInt("notificationID"));
          n.put("type",           rs.getString("type"));
          n.put("referenceType",  rs.getString("referenceType"));
          n.put("referenceID",    rs.getString("referenceID"));
          n.put("severity",       rs.getString("severity"));
          n.put("channel",        rs.getString("channel"));
          n.put("isRead",         rs.getBoolean("isRead"));
          n.put("createdAt",      rs.getTimestamp("createdAt"));
          notes.add(n);
        }
      }
    } catch (SQLException e) {
      throw new ServletException(e);
    }

    req.setAttribute("notifications", notes);
    req.getRequestDispatcher("notifications.jsp").forward(req, resp);
  }

  @Override
  protected void doPost(HttpServletRequest req, HttpServletResponse resp)
      throws ServletException, IOException {
    HttpSession sess = req.getSession(false);
    String userId = (sess!=null)?(String)sess.getAttribute("username"):null;
    if (userId == null) {
      resp.sendRedirect("login.jsp");
      return;
    }

    String action = req.getParameter("action");
    if ("markRead".equals(action)) {
      int nid = Integer.parseInt(req.getParameter("notificationID"));
      try (Connection c = DBConnection.getConnection();
           PreparedStatement p = c.prepareStatement(
             "UPDATE Notification SET isRead=TRUE WHERE notificationID=? AND userID=?")) {
        p.setInt(1, nid);
        p.setString(2, userId);
        p.executeUpdate();
      } catch (SQLException e) {
        throw new ServletException(e);
      }
    }
    resp.sendRedirect("notifications");
  }
}
