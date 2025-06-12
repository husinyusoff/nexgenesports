package All;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;

@WebServlet("/teamMember")
public class TeamMemberServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession sess = req.getSession(false);
        String actor = (sess != null) ? (String) sess.getAttribute("username") : null;
        if (actor == null) {
            resp.sendRedirect("login.jsp");
            return;
        }

        String action = req.getParameter("action");
        int teamID = Integer.parseInt(req.getParameter("teamID"));
        String target = req.getParameter("userID");

        try (Connection c = DBConnection.getConnection()) {
            if (null != action) {
                switch (action) {
                    case "invite":
                        // snapshot inGameID
                        String snap = "";
                        try (PreparedStatement q = c.prepareStatement(
                                "SELECT inGameUserID FROM InGame WHERE userID=? AND gameID=("
                                + " SELECT gameID FROM Team WHERE teamID=?)")) {
                            q.setString(1, target);
                            q.setInt(2, teamID);
                            try (ResultSet rs = q.executeQuery()) {
                                if (rs.next()) {
                                    snap = rs.getString(1);
                                }
                            }
                        }
                        try (PreparedStatement p = c.prepareStatement(
                                "INSERT INTO TeamMember(teamID,userID,status,teamRole,joinedAt,"
                                + "roleAssignedAt,snapshotInGameID) VALUES(?,?,?,?,NOW(),NOW(),?)")) {
                            p.setInt(1, teamID);
                            p.setString(2, target);
                            p.setString(3, "pending");
                            p.setString(4, "Member");
                            p.setString(5, snap);
                            p.executeUpdate();
                        }
                        break;
                    case "approve":
                        try (PreparedStatement p = c.prepareStatement(
                                "UPDATE TeamMember SET status='active', joinedAt=NOW() "
                                + " WHERE teamID=? AND userID=?")) {
                            p.setInt(1, teamID);
                            p.setString(2, target);
                            p.executeUpdate();
                        }
                        break;
                    case "decline":
                        try (PreparedStatement p = c.prepareStatement(
                                "DELETE FROM TeamMember WHERE teamID=? AND userID=? AND status='pending'")) {
                            p.setInt(1, teamID);
                            p.setString(2, target);
                            p.executeUpdate();
                        }
                        break;
                    case "remove":
                        try (PreparedStatement p = c.prepareStatement(
                                "DELETE FROM TeamMember WHERE teamID=? AND userID=? AND status='active'")) {
                            p.setInt(1, teamID);
                            p.setString(2, target);
                            p.executeUpdate();
                        }
                        break;
                    case "transfer":
                        String newLeader = req.getParameter("newLeader");
                        // demote old leader
                        try (PreparedStatement p1 = c.prepareStatement(
                                "UPDATE TeamMember SET teamRole='Member' WHERE teamID=? AND teamRole='Leader'")) {
                            p1.setInt(1, teamID);
                            p1.executeUpdate();
                        }       // promote new
                        try (PreparedStatement p2 = c.prepareStatement(
                                "UPDATE TeamMember SET teamRole='Leader', roleAssignedAt=NOW() "
                                + " WHERE teamID=? AND userID=?")) {
                            p2.setInt(1, teamID);
                            p2.setString(2, newLeader);
                            p2.executeUpdate();
                        }
                        break;
                    default:
                        break;
                }
            }
            // after action, go back to team details
            resp.sendRedirect("team?action=view&teamID=" + teamID);
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }
}
