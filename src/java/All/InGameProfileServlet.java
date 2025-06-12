package All;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.*;

@WebServlet("/inGameProfile")
public class InGameProfileServlet extends HttpServlet {
  @Override
  protected void doGet(HttpServletRequest req, HttpServletResponse resp)
      throws ServletException, IOException {
    HttpSession sess = req.getSession(false);
    String userId = (sess != null) ? (String) sess.getAttribute("username") : null;
    if (userId == null) {
      resp.sendRedirect("login.jsp");
      return;
    }

    List<Map<String,Object>> ingames = new ArrayList<>();
    List<Map<String,Object>> locks   = new ArrayList<>();

    String selectInGame =
      "SELECT inGameID, gameID, inGameUserID, gamePlatformID, regionCode " +
      "  FROM ingame WHERE userID = ?";
    String checkLock =
      "SELECT 1 FROM tournamentparticipant tp " +
      "  JOIN program_tournament pt ON tp.progID = pt.progID " +
      " WHERE tp.userID = ? AND pt.gameID = ? AND tp.status IN('Registered','In-Progress')";

    try (Connection c = DBConnection.getConnection();
         PreparedStatement ps = c.prepareStatement(selectInGame)) {

      ps.setString(1, userId);
      try (ResultSet rs = ps.executeQuery()) {
        while (rs.next()) {
          Map<String,Object> row = new HashMap<>();
          row.put("inGameID",       rs.getInt("inGameID"));
          row.put("gameID",         rs.getString("gameID"));
          row.put("inGameUserID",   rs.getString("inGameUserID"));
          row.put("gamePlatformID", rs.getString("gamePlatformID"));
          row.put("regionCode",     rs.getString("regionCode"));
          ingames.add(row);

          try (PreparedStatement q = c.prepareStatement(checkLock)) {
            q.setString(1, userId);
            q.setString(2, rs.getString("gameID"));
            try (ResultSet r2 = q.executeQuery()) {
              locks.add(Collections.singletonMap("lock", r2.next()));
            }
          }
        }
      }
    } catch (SQLException e) {
      throw new ServletException(e);
    }

    req.setAttribute("ingames", ingames);
    req.setAttribute("locks",   locks);
    req.getRequestDispatcher("inGameProfile.jsp")
       .forward(req, resp);
  }

  @Override
  protected void doPost(HttpServletRequest req, HttpServletResponse resp)
      throws ServletException, IOException {
    HttpSession sess = req.getSession(false);
    String userId = (sess != null) ? (String) sess.getAttribute("username") : null;
    if (userId == null) {
      resp.sendRedirect("login.jsp");
      return;
    }

    int    inGameID = Integer.parseInt(req.getParameter("inGameID"));
    String id       = req.getParameter("inGameUserID");
    String platform = req.getParameter("gamePlatformID");
    String region   = req.getParameter("regionCode");

    String updateSql =
      "UPDATE ingame " +
      "   SET inGameUserID = ?, gamePlatformID = ?, regionCode = ? " +
      " WHERE inGameID = ? AND userID = ?";

    try (Connection c = DBConnection.getConnection();
         PreparedStatement p = c.prepareStatement(updateSql)) {

      p.setString(1, id);
      p.setString(2, platform);
      p.setString(3, region);
      p.setInt(4, inGameID);
      p.setString(5, userId);
      p.executeUpdate();

    } catch (SQLException e) {
      req.setAttribute("error", e.getMessage());
    }

    resp.sendRedirect("inGameProfile");
  }
}
