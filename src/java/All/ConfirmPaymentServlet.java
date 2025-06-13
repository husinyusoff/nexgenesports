package All;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Date;        // ← java.sql.Date
import java.time.LocalDate;

@WebServlet("/confirmPayment")
public class ConfirmPaymentServlet extends HttpServlet {
  @Override
  protected void doPost(HttpServletRequest req, HttpServletResponse resp)
      throws ServletException, IOException {

    HttpSession session = req.getSession(false);
    String userId = (session != null)
                  ? (String) session.getAttribute("username")
                  : null;
    if (userId == null) {
      resp.sendRedirect(req.getContextPath() + "/login.jsp");
      return;
    }

    boolean isClub = "club".equals(req.getParameter("type"));
    boolean isPass = "pass".equals(req.getParameter("type"));

    try (Connection conn = DBConnection.getConnection()) {

      if (isClub) {
        // Club flow
        String sessionId = req.getParameter("sessionId");
        Date expiry = null;
        try (PreparedStatement ps = conn.prepareStatement(
               "SELECT endMembershipDate FROM membershipsessions WHERE sessionId=?")) {
          ps.setString(1, sessionId);
          try (ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
              expiry = rs.getDate("endMembershipDate");
            }
          }
        }
        try (PreparedStatement ps = conn.prepareStatement(
               "INSERT INTO userclubmemberships " +
               "(userId, sessionId, purchaseDate, expiryDate) " +
               "VALUES(?, ?, CURDATE(), ?)")) {
          ps.setString(1, userId);
          ps.setString(2, sessionId);
          ps.setDate(3, expiry);
          ps.executeUpdate();
        }
      }
      else if (isPass) {
        // Pass flow
        int tierId = Integer.parseInt(req.getParameter("tierId"));
        try (PreparedStatement ps = conn.prepareStatement(
               "INSERT INTO usergamingpasses " +
               "(userId, tierId, purchaseDate, expiryDate) " +
               "VALUES(?, ?, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 30 DAY))")) {
          ps.setString(1, userId);
          ps.setInt(2, tierId);
          ps.executeUpdate();
        }
      }

      // Redirect back to view
      resp.sendRedirect(req.getContextPath() + "/manageMembershipPass");
    }
    catch (Exception e) {
      throw new ServletException(e);
    }
  }
}
