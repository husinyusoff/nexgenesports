package All;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.*;

@WebServlet("/team")
public class TeamServlet extends HttpServlet {
  @Override
  protected void doGet(HttpServletRequest req, HttpServletResponse resp)
      throws ServletException, IOException {
    HttpSession sess = req.getSession(false);
    String userId = (sess != null) ? (String) sess.getAttribute("username") : null;
    if (userId == null) {
      resp.sendRedirect("login.jsp");
      return;
    }

    String action = req.getParameter("action");
    try (Connection c = DBConnection.getConnection()) {

      // --- CREATE form
      if ("create".equals(action)) {
        List<String> games = new ArrayList<>();
        try (ResultSet rs = c.createStatement()
            .executeQuery("SELECT gameID FROM game")) {
          while (rs.next()) {
            games.add(rs.getString(1));
          }
        }
        req.setAttribute("games", games);
        req.getRequestDispatcher("createTeam.jsp")
           .forward(req, resp);
        return;
      }

      // --- VIEW details
      if ("view".equals(action)) {
        int teamID = Integer.parseInt(req.getParameter("teamID"));
        Map<String,Object> team = new HashMap<>();

        try (PreparedStatement p = c.prepareStatement(
               "SELECT gameID,teamName,description,logoURL,createdBy,createdAt " +
               "  FROM team WHERE teamID = ?")) {
          p.setInt(1, teamID);
          try (ResultSet rs = p.executeQuery()) {
            if (rs.next()) {
              team.put("teamID",      teamID);
              team.put("gameID",      rs.getString("gameID"));
              team.put("teamName",    rs.getString("teamName"));
              team.put("description", rs.getString("description"));
              team.put("logoURL",     rs.getString("logoURL"));
              team.put("createdBy",   rs.getString("createdBy"));
              team.put("createdAt",   rs.getTimestamp("createdAt"));
            }
          }
        }

        List<Map<String,Object>> members  = new ArrayList<>();
        List<Map<String,Object>> pendings = new ArrayList<>();

        try (PreparedStatement p = c.prepareStatement(
               "SELECT userID,teamRole,joinedAt " +
               "  FROM teammember " +
               " WHERE teamID = ? AND status = 'active'")) {
          p.setInt(1, teamID);
          try (ResultSet rs = p.executeQuery()) {
            while (rs.next()) {
              members.add(Map.of(
                "userID",   rs.getString("userID"),
                "teamRole", rs.getString("teamRole"),
                "joinedAt", rs.getTimestamp("joinedAt")
              ));
            }
          }
        }

        try (PreparedStatement p = c.prepareStatement(
               "SELECT userID,requestedAt " +
               "  FROM teammember " +
               " WHERE teamID = ? AND status = 'pending'")) {
          p.setInt(1, teamID);
          try (ResultSet rs = p.executeQuery()) {
            while (rs.next()) {
              pendings.add(Map.of(
                "userID",      rs.getString("userID"),
                "requestedAt", rs.getTimestamp("requestedAt")
              ));
            }
          }
        }

        boolean isLeader = false, isCoLeader = false;
        for (Map<String,Object> m : members) {
          String uid  = (String) m.get("userID");
          String role = (String) m.get("teamRole");
          if (userId.equals(uid)) {
            if ("Leader".equals(role))    isLeader   = true;
            if ("Co-Leader".equals(role)) isCoLeader = true;
          }
        }

        req.setAttribute("team",      team);
        req.setAttribute("members",   members);
        req.setAttribute("pendings",  pendings);
        req.setAttribute("isLeader",   isLeader);
        req.setAttribute("isCoLeader", isCoLeader);
        req.getRequestDispatcher("teamDetails.jsp")
           .forward(req, resp);
        return;
      }

      // --- LIST all teams
      List<Map<String,Object>> teams = new ArrayList<>();
      try (PreparedStatement p = c.prepareStatement(
             "SELECT t.teamID,t.teamName,t.gameID,tm.teamRole " +
             "  FROM team t " +
             "  JOIN teammember tm ON t.teamID=tm.teamID " +
             " WHERE tm.userID = ? AND tm.status = 'active'")) {
        p.setString(1, userId);
        try (ResultSet rs = p.executeQuery()) {
          while (rs.next()) {
            teams.add(Map.of(
              "teamID",   rs.getInt("teamID"),
              "teamName", rs.getString("teamName"),
              "gameID",   rs.getString("gameID"),
              "teamRole", rs.getString("teamRole")
            ));
          }
        }
      }
      req.setAttribute("teams", teams);
      req.getRequestDispatcher("listTeam.jsp")
         .forward(req, resp);

    } catch (SQLException e) {
      throw new ServletException(e);
    }
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

    String action = req.getParameter("action");
    try (Connection c = DBConnection.getConnection()) {
      if ("create".equals(action)) {
        try (PreparedStatement p = c.prepareStatement(
               "INSERT INTO team(gameID,teamName,description,logoURL,createdBy) " +
               "VALUES(?,?,?,?,?)")) {
          p.setString(1, req.getParameter("gameID"));
          p.setString(2, req.getParameter("teamName"));
          p.setString(3, req.getParameter("description"));
          p.setString(4, req.getParameter("logoURL"));
          p.setString(5, userId);
          p.executeUpdate();
        }
      } else if ("delete".equals(action)) {
        int teamID = Integer.parseInt(req.getParameter("teamID"));
        try (PreparedStatement p = c.prepareStatement(
               "DELETE FROM team WHERE teamID = ?")) {
          p.setInt(1, teamID);
          p.executeUpdate();
        }
      }
      resp.sendRedirect("team");
    } catch (SQLException e) {
      throw new ServletException(e);
    }
  }
}
