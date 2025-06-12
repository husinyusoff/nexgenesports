package All;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.*;

@WebServlet("/achievements")
public class AchievementsServlet extends HttpServlet {
  @Override
  protected void doGet(HttpServletRequest req, HttpServletResponse resp)
      throws ServletException, IOException {
    HttpSession sess = req.getSession(false);
    String userId = (sess != null) ? (String) sess.getAttribute("username") : null;
    if (userId == null) {
      resp.sendRedirect("login.jsp");
      return;
    }

    List<Map<String,Object>> teamBoard = new ArrayList<>();
    List<Map<String,Object>> myBoard   = new ArrayList<>();

    try (Connection c = DBConnection.getConnection()) {
      // Team leaderboard
      String sqlTeam =
        "SELECT t.teamName, pt.programName, ta.placement, ta.pointsAwarded, ta.achievedAt " +
        "  FROM teamachievement ta " +
        "  JOIN tournamentparticipant tp ON ta.participantID = tp.participantID " +
        "  JOIN program_tournament pt ON tp.progID = pt.progID " +
        "  JOIN team t ON tp.teamID = t.teamID " +
        " ORDER BY ta.pointsAwarded DESC";
      try (PreparedStatement p = c.prepareStatement(sqlTeam);
           ResultSet rs = p.executeQuery()) {
        while (rs.next()) {
          teamBoard.add(Map.of(
            "teamName",      rs.getString("teamName"),
            "programName",   rs.getString("programName"),
            "placement",     rs.getInt("placement"),
            "pointsAwarded", rs.getInt("pointsAwarded"),
            "achievedAt",    rs.getDate("achievedAt")
          ));
        }
      }

      // My achievements
      String sqlMine =
        "SELECT pt.programName, t.teamName, pa.points, ta.achievedAt " +
        "  FROM personalachievement pa " +
        "  JOIN teamachievement ta ON pa.achievementID = ta.achievementID " +
        "  JOIN tournamentparticipant tp ON ta.participantID = tp.participantID " +
        "  JOIN program_tournament pt ON tp.progID = pt.progID " +
        "  JOIN team t ON tp.teamID = t.teamID " +
        " WHERE pa.userID = ? " +
        " ORDER BY pa.points DESC";
      try (PreparedStatement p = c.prepareStatement(sqlMine)) {
        p.setString(1, userId);
        try (ResultSet rs = p.executeQuery()) {
          while (rs.next()) {
            myBoard.add(Map.of(
              "programName", rs.getString("programName"),
              "teamName",    rs.getString("teamName"),
              "points",      rs.getInt("points"),
              "achievedAt",  rs.getDate("achievedAt")
            ));
          }
        }
      }

    } catch (SQLException e) {
      throw new ServletException(e);
    }

    req.setAttribute("teamBoard", teamBoard);
    req.setAttribute("myBoard",   myBoard);
    req.getRequestDispatcher("achievements.jsp")
       .forward(req, resp);
  }
}
