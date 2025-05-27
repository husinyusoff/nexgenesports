package All;

import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;

@WebServlet("/RBACAdminServlet")
public class RBACAdminServlet extends HttpServlet {
  @Override
  protected void doPost(HttpServletRequest req, HttpServletResponse resp)
      throws ServletException, IOException {

    String action = req.getParameter("action");
    try (Connection c = DBConnection.getConnection()) {
      switch (action) {
        case "addRole":
          try (PreparedStatement ps = c.prepareStatement(
                   "INSERT IGNORE INTO roles(role) VALUES(?)")) {
            ps.setString(1, req.getParameter("roleName").trim());
            ps.executeUpdate();
          }
          break;

        case "addPosition":
          try (PreparedStatement ps = c.prepareStatement(
                   "INSERT IGNORE INTO positions(position) VALUES(?)")) {
            ps.setString(1, req.getParameter("positionName").trim());
            ps.executeUpdate();
          }
          break;

        case "addPage":
          try (PreparedStatement ps = c.prepareStatement(
                   "INSERT IGNORE INTO pages(name,url) VALUES(?,?)")) {
            ps.setString(1, req.getParameter("pageName").trim());
            ps.setString(2, req.getParameter("pageURL").trim());
            ps.executeUpdate();
          }
          break;

        case "addPermission":
          // 1) lookup the role_positions.id
          String role = req.getParameter("perm_role");
          String pos  = req.getParameter("perm_position");
          int rpId;
          try (PreparedStatement getRp = c.prepareStatement(
                 "SELECT id FROM role_positions WHERE role = ? "
               + (pos==null||pos.isEmpty()
                  ? "AND position IS NULL"
                  : "AND position = ?"))) {
            getRp.setString(1, role);
            if (pos!=null && !pos.isEmpty()) getRp.setString(2, pos);
            try (ResultSet r = getRp.executeQuery()) {
              if (!r.next()) {
                throw new ServletException("Unknown role/position combo");
              }
              rpId = r.getInt("id");
            }
          }

          // 2) insert into permissions via rp_id
          try (PreparedStatement ps = c.prepareStatement(
                 "INSERT IGNORE INTO permissions(rp_id, page_id) VALUES(?,?)")) {
            ps.setInt(1, rpId);
            ps.setInt(2, Integer.parseInt(req.getParameter("perm_page")));
            ps.executeUpdate();
          }
          break;
      }
    } catch (SQLException | ServletException e) {
      throw new ServletException(e);
    }

    resp.sendRedirect(req.getContextPath() + "/manageRBAC.jsp");
  }
}
