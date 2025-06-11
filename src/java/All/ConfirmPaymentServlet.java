package All;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.time.*;
import java.time.temporal.ChronoUnit;

@WebServlet("/confirmPayment")
public class ConfirmPaymentServlet extends HttpServlet {
  @Override
  protected void doPost(HttpServletRequest req, HttpServletResponse resp)
      throws ServletException, IOException {

    HttpSession sess = req.getSession(false);
    String userId = (sess != null) ? (String) sess.getAttribute("username") : null;
    if (userId == null) {
      resp.sendRedirect(req.getContextPath() + "/login.jsp");
      return;
    }

    String type   = req.getParameter("type");
    double amount = Double.parseDouble(req.getParameter("price"));
    String details; // build a description as needed

    // 1) Insert into payments
    int paymentID;
    try (Connection conn = DBConnection.getConnection()) {
      conn.setAutoCommit(false);

      try (PreparedStatement p = conn.prepareStatement(
             "INSERT INTO payments(userID,transactionDate,transactionTime," +
             "transactionAmount,transactionDetails,paymentMethod,relatedObjectType)" +
             " VALUES(?,?,?,?,?,?,?)", Statement.RETURN_GENERATED_KEYS)) {
        p.setString(1, userId);
        p.setDate(2, new java.sql.Date(System.currentTimeMillis()));
        p.setTime(3, new java.sql.Time(System.currentTimeMillis()));
        p.setDouble(4, amount);
        p.setString(5, "Payment for " + type);
        p.setString(6, "MOCK");
        p.setString(7, type);
        p.executeUpdate();
        try (ResultSet rs = p.getGeneratedKeys()) {
          rs.next();
          paymentID = rs.getInt(1);
        }
      }

      // 2) Depending on type, insert into child
      if ("booking".equals(type)) {
        // parse and insert booking…
        try (PreparedStatement p = conn.prepareStatement(
               "INSERT INTO gamingstationbooking(" +
               "userID,stationID,date,startTime,endTime,status,priceType," +
               "playerCount,price,paymentStatus,paymentReference,hourCount)" +
               " VALUES(?,?,?,?,?,?,?,?,?,?,?,?)")) {
          p.setString(1, userId);
          p.setString(2, req.getParameter("stationID"));
          p.setDate(3, java.sql.Date.valueOf(req.getParameter("date")));
          p.setTime(4, java.sql.Time.valueOf(req.getParameter("startTime")));
          p.setTime(5, java.sql.Time.valueOf(req.getParameter("endTime")));
          p.setString(6, "Confirmed");
          p.setString(7, req.getParameter("priceType"));
          p.setInt(8, Integer.parseInt(req.getParameter("playerCount")));
          p.setDouble(9, amount);
          p.setString(10, "PAID");
          p.setInt(11, paymentID);
          p.setInt(12, Integer.parseInt(req.getParameter("hourCount")));
          p.executeUpdate();
        }
      }
      else if ("club".equals(type)) {
        // insert club membership
        Date expiry = null;
        try (PreparedStatement q = conn.prepareStatement(
               "SELECT endMembershipDate FROM membershipsessions WHERE sessionId=?")) {
          q.setString(1, req.getParameter("sessionId"));
          try (ResultSet rs = q.executeQuery()) {
            if (rs.next()) expiry = rs.getDate(1);
          }
        }
        try (PreparedStatement p = conn.prepareStatement(
               "INSERT INTO userclubmemberships(" +
               "userId,sessionId,purchaseDate,expiryDate,paymentReference)" +
               " VALUES(?,?,CURDATE(),?,?)")) {
          p.setString(1, userId);
          p.setString(2, req.getParameter("sessionId"));
          p.setDate(3, expiry);
          p.setInt(4, paymentID);
          p.executeUpdate();
        }
      }
      else if ("pass".equals(type)) {
        // extend days logic
        LocalDate today      = LocalDate.now();
        LocalDate currExpiry = LocalDate.parse(req.getParameter("currentExpiry"));
        int planLength       = Integer.parseInt(req.getParameter("planLength"));
        long daysLeft        = ChronoUnit.DAYS.between(today, currExpiry);
        if (daysLeft < 0) daysLeft = 0;
        LocalDate newExpiry  = today.plusDays(daysLeft + planLength);

        try (PreparedStatement p = conn.prepareStatement(
               "INSERT INTO usergamingpasses(" +
               "userId,tierId,purchaseDate,expiryDate,paymentReference)" +
               " VALUES(?,?,CURDATE(),?,?)")) {
          p.setString(1, userId);
          p.setInt(2, Integer.parseInt(req.getParameter("tierId")));
          p.setDate(3, java.sql.Date.valueOf(newExpiry));
          p.setInt(4, paymentID);
          p.executeUpdate();
        }
      }

      conn.commit();
    } catch (Exception e) {
      throw new ServletException(e);
    }

    // 3) Redirect back
    String dest = "booking".equals(type)
                ? "manageBooking.jsp"
                : "manageMembershipPass";
    resp.sendRedirect(req.getContextPath() + "/" + dest);
  }
}
