package All;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Date;              // ← java.sql.Date only
import java.time.LocalDate;
import java.util.*;

@WebServlet("/manageMembershipPass")
public class ManageMembershipPassServlet extends HttpServlet {
  @Override
  protected void doGet(HttpServletRequest req, HttpServletResponse resp)
      throws ServletException, IOException {

    // 1) Require login
    HttpSession session = req.getSession(false);
    String userId = (session != null) 
                  ? (String) session.getAttribute("username")
                  : null;
    if (userId == null) {
      resp.sendRedirect(req.getContextPath() + "/login.jsp");
      return;
    }

    try (Connection conn = DBConnection.getConnection()) {

      // 2) Latest Club Membership
      Map<String,Object> latestClub = null;
      try (PreparedStatement ps = conn.prepareStatement(
             "SELECT uc.sessionId, uc.purchaseDate, uc.expiryDate, " +
             "       ms.sessionName, ms.fee " +
             "  FROM userclubmemberships uc " +
             "  JOIN membershipsessions ms ON uc.sessionId=ms.sessionId " +
             " WHERE uc.userId=? " +
             " ORDER BY uc.expiryDate DESC LIMIT 1")) {
        ps.setString(1, userId);
        try (ResultSet rs = ps.executeQuery()) {
          if (rs.next()) {
            latestClub = new HashMap<>();
            latestClub.put("sessionId",    rs.getString("sessionId"));
            latestClub.put("sessionName",  rs.getString("sessionName"));
            latestClub.put("fee",          rs.getBigDecimal("fee"));
            latestClub.put("purchaseDate", rs.getDate("purchaseDate"));
            latestClub.put("expiryDate",   rs.getDate("expiryDate"));
          }
        }
      }

      // 3) Next Session for Renewal
      Map<String,Object> nextSession = null;
      if (latestClub != null) {
        Date currentExpiry = (Date) latestClub.get("expiryDate");
        try (PreparedStatement ps = conn.prepareStatement(
               "SELECT sessionId, sessionName, startMembershipDate, endMembershipDate, fee " +
               "  FROM membershipsessions " +
               " WHERE startMembershipDate > ? " +
               " ORDER BY startMembershipDate ASC LIMIT 1")) {
          ps.setDate(1, currentExpiry);
          try (ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
              nextSession = new HashMap<>();
              nextSession.put("sessionId",            rs.getString("sessionId"));
              nextSession.put("sessionName",          rs.getString("sessionName"));
              nextSession.put("startMembershipDate", rs.getDate("startMembershipDate"));
              nextSession.put("endMembershipDate",   rs.getDate("endMembershipDate"));
              nextSession.put("fee",                 rs.getBigDecimal("fee"));
            }
          }
        }
      }

      // 4) Latest Gaming Pass
      Map<String,Object> latestPass = null;
      try (PreparedStatement ps = conn.prepareStatement(
             "SELECT ugp.tierId, ugp.purchaseDate, ugp.expiryDate, " +
             "       mgt.tierName, mgt.price, mgt.discountRate " +
             "  FROM usergamingpasses ugp " +
             "  JOIN monthlygamingpasstiers mgt ON ugp.tierId=mgt.tierId " +
             " WHERE ugp.userId=? " +
             " ORDER BY ugp.expiryDate DESC LIMIT 1")) {
        ps.setString(1, userId);
        try (ResultSet rs = ps.executeQuery()) {
          if (rs.next()) {
            latestPass = new HashMap<>();
            latestPass.put("tierId",       rs.getInt("tierId"));
            latestPass.put("tierName",     rs.getString("tierName"));
            latestPass.put("price",        rs.getBigDecimal("price"));
            latestPass.put("discountRate", rs.getInt("discountRate"));
            latestPass.put("purchaseDate", rs.getDate("purchaseDate"));
            latestPass.put("expiryDate",   rs.getDate("expiryDate"));
          }
        }
      }

      // 5) All Pass Tiers (for buy)
      List<Map<String,Object>> allTiers = new ArrayList<>();
      try (PreparedStatement ps = conn.prepareStatement(
             "SELECT tierId, tierName, price, discountRate " +
             "  FROM monthlygamingpasstiers ORDER BY tierId ASC");
           ResultSet rs = ps.executeQuery()) {
        while (rs.next()) {
          Map<String,Object> tier = new HashMap<>();
          tier.put("tierId",       rs.getInt("tierId"));
          tier.put("tierName",     rs.getString("tierName"));
          tier.put("price",        rs.getBigDecimal("price"));
          tier.put("discountRate", rs.getInt("discountRate"));
          allTiers.add(tier);
        }
      }

      // 6) Today (for JSP gating)
      LocalDate today = LocalDate.now();
      req.setAttribute("today", Date.valueOf(today));

      // 7) Forward to JSP
      req.setAttribute("latestClub",  latestClub);
      req.setAttribute("nextSession", nextSession);
      req.setAttribute("latestPass",  latestPass);
      req.setAttribute("allTiers",    allTiers);
      req.getRequestDispatcher("/manageMembershipPass.jsp")
         .forward(req, resp);
    }
    catch (Exception e) {
      throw new ServletException(e);
    }
  }
}
