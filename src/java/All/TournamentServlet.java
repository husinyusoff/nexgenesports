package All;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.*;

@WebServlet("/tournament")
public class TournamentServlet extends HttpServlet {
  @Override
  protected void doGet(HttpServletRequest req, HttpServletResponse resp)
      throws ServletException, IOException {
    HttpSession sess = req.getSession(false);
    String user = sess!=null ? (String)sess.getAttribute("username") : null;
    if (user==null) {
      resp.sendRedirect("login.jsp");
      return;
    }

    String action = req.getParameter("action");
    try (Connection c = DBConnection.getConnection()) {
      // ─── LIST ──────────────────────────────────────────────
      if (action==null || action.equals("list")) {
        List<Map<String,Object>> list = new ArrayList<>();
        try (PreparedStatement ps = c.prepareStatement(
               "SELECT progID, gameID, programName, progFee, startDate FROM program_tournament"
        )) {
          try (ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
              list.add(Map.of(
                "progID",      rs.getString("progID"),
                "gameID",      rs.getString("gameID"),
                "programName", rs.getString("programName"),
                "progFee",     rs.getBigDecimal("progFee"),
                "startDate",   rs.getDate("startDate")
              ));
            }
          }
        }
        req.setAttribute("tournaments", list);
        req.getRequestDispatcher("listTournament.jsp").forward(req, resp);
        return;
      }

      // ─── SHOW FORM (create or edit) ───────────────────────
      if (action.equals("form")) {
        // load games for dropdown
        List<String> games = new ArrayList<>();
        try (ResultSet rs = c.createStatement()
            .executeQuery("SELECT gameID FROM game")) {
          while (rs.next()) games.add(rs.getString(1));
        }
        req.setAttribute("games", games);

        String prog = req.getParameter("progID");
        if (prog!=null) {
          // editing existing
          try (PreparedStatement ps = c.prepareStatement(
                 "SELECT * FROM program_tournament WHERE progID=?"
          )) {
            ps.setString(1, prog);
            try (ResultSet rs = ps.executeQuery()) {
              if (rs.next()) {
                Map<String,Object> t = new HashMap<>();
                t.put("progID",      rs.getString("progID"));
                t.put("gameID",      rs.getString("gameID"));
                t.put("programName", rs.getString("programName"));
                t.put("progFee",     rs.getBigDecimal("progFee"));
                t.put("startDate",   rs.getDate("startDate"));
                t.put("endDate",     rs.getDate("endDate"));
                t.put("startTime",   rs.getTime("startTime"));
                t.put("endTime",     rs.getTime("endTime"));
                t.put("prizePool",   rs.getBigDecimal("prizePool"));
                req.setAttribute("tournament", t);
              }
            }
          }
        }
        req.getRequestDispatcher("editTournament.jsp").forward(req, resp);
        return;
      }

      resp.sendError(400);
    }
    catch (SQLException e) {
      throw new ServletException(e);
    }
  }

  @Override
  protected void doPost(HttpServletRequest req, HttpServletResponse resp)
      throws ServletException, IOException {
    HttpSession sess = req.getSession(false);
    if (sess==null || sess.getAttribute("username")==null) {
      resp.sendRedirect("login.jsp");
      return;
    }

    String action = req.getParameter("action");
    try (Connection c = DBConnection.getConnection()) {
      if (action.equals("save")) {
        String prog    = req.getParameter("progID");
        boolean insert = (req.getParameter("isNew")!=null);
        if (insert) {
          try (PreparedStatement ps = c.prepareStatement(
                 "INSERT INTO program_tournament " +
                 "(progID,gameID,programName,progFee,startDate,endDate,startTime,endTime,prizePool) " +
                 "VALUES(?,?,?,?,?,?,?,?,?)"
          )) {
            ps.setString(1, prog);
            ps.setString(2, req.getParameter("gameID"));
            ps.setString(3, req.getParameter("programName"));
            ps.setBigDecimal(4, new java.math.BigDecimal(req.getParameter("progFee")));
            ps.setDate(5, java.sql.Date.valueOf(req.getParameter("startDate")));
            ps.setDate(6, req.getParameter("endDate").isBlank()
                           ? null
                           : java.sql.Date.valueOf(req.getParameter("endDate")));
            ps.setTime(7, java.sql.Time.valueOf(req.getParameter("startTime")));
            ps.setTime(8, req.getParameter("endTime").isBlank()
                           ? null
                           : java.sql.Time.valueOf(req.getParameter("endTime")));
            ps.setBigDecimal(9, new java.math.BigDecimal(req.getParameter("prizePool")));
            ps.executeUpdate();
          }
        } else {
          try (PreparedStatement ps = c.prepareStatement(
                 "UPDATE program_tournament SET " +
                 "gameID=?,programName=?,progFee=?,startDate=?,endDate=?,startTime=?,endTime=?,prizePool=? " +
                 "WHERE progID=?"
          )) {
            ps.setString(1, req.getParameter("gameID"));
            ps.setString(2, req.getParameter("programName"));
            ps.setBigDecimal(3, new java.math.BigDecimal(req.getParameter("progFee")));
            ps.setDate(4, java.sql.Date.valueOf(req.getParameter("startDate")));
            ps.setDate(5, req.getParameter("endDate").isBlank()
                           ? null
                           : java.sql.Date.valueOf(req.getParameter("endDate")));
            ps.setTime(6, java.sql.Time.valueOf(req.getParameter("startTime")));
            ps.setTime(7, req.getParameter("endTime").isBlank()
                           ? null
                           : java.sql.Time.valueOf(req.getParameter("endTime")));
            ps.setBigDecimal(8, new java.math.BigDecimal(req.getParameter("prizePool")));
            ps.setString(9, prog);
            ps.executeUpdate();
          }
        }
      }
      else if (action.equals("delete")) {
        try (PreparedStatement ps = c.prepareStatement(
               "DELETE FROM program_tournament WHERE progID=?"
        )) {
          ps.setString(1, req.getParameter("progID"));
          ps.executeUpdate();
        }
      }
    } catch (SQLException e) {
      throw new ServletException(e);
    }

    resp.sendRedirect("tournament");
  }
}
