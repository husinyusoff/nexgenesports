<%@page import="java.time.temporal.ChronoUnit"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.Date, java.time.*"%>
<%@ page import="java.util.Map"%>
<%@ page session="true" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>CHECKOUT – NexGen Esports</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/styles.css">
</head>
<body class="checkout-page">
  <%@ include file="header.jsp" %>
  <div class="container">
    <div class="sidebar"><jsp:include page="sidebar.jsp"/></div>
    <div class="content">
      <div class="content-card">
        <h2>CHECKOUT</h2>
        <div class="summary">
          <%
            String type = request.getParameter("type");
            if ("booking".equals(type)) {
              // Booking summary
              out.write("<p><strong>Station:</strong> "   + request.getParameter("stationName") + "</p>");
              out.write("<p><strong>Date:</strong> "      + request.getParameter("date")        + "</p>");
              out.write("<p><strong>Start Time:</strong> " + request.getParameter("startTime")   + "</p>");
              out.write("<p><strong>End Time:</strong> "   + request.getParameter("endTime")     + "</p>");
              out.write("<p><strong>Players:</strong> "    + request.getParameter("playerCount") + "</p>");
              out.write("<p><strong>Total Price:</strong> RM" + request.getParameter("totalPrice")+ "</p>");
            }
            else if ("club".equals(type)) {
              // Club membership summary
              String sid  = request.getParameter("sessionId");
              String name = request.getParameter("sessionName");
              String fee  = request.getParameter("fee");
              Date start=null, end=null;
              try (java.sql.Connection c = All.DBConnection.getConnection();
                   java.sql.PreparedStatement p = c.prepareStatement(
                     "SELECT startMembershipDate,endMembershipDate FROM membershipsessions WHERE sessionId=?")) {
                p.setString(1, sid);
                try (java.sql.ResultSet r = p.executeQuery()) {
                  if (r.next()) { start = r.getDate(1); end = r.getDate(2); }
                }
              }
              out.write("<p><strong>Membership:</strong> " + name + "</p>");
              out.write("<p><strong>Start Date:</strong> "   + start + "</p>");
              out.write("<p><strong>Expiry Date:</strong> "  + end   + "</p>");
              out.write("<p><strong>Fee:</strong> RM"        + fee   + "</p>");
            }
            else if ("pass".equals(type)) {
              // Gaming pass extension summary
              LocalDate today      = LocalDate.now();
              LocalDate currExpiry = LocalDate.parse(request.getParameter("currentExpiry"));
              int planLength       = Integer.parseInt(request.getParameter("planLength"));
              long daysLeft        = ChronoUnit.DAYS.between(today, currExpiry);
              if (daysLeft < 0) daysLeft = 0;
              LocalDate newExpiry  = today.plusDays(daysLeft + planLength);
              out.write("<p><strong>Pass Tier:</strong> "     + request.getParameter("tierName") + "</p>");
              out.write("<p><strong>Days Remaining:</strong> " + daysLeft + "</p>");
              out.write("<p><strong>Plan Length:</strong> "    + planLength + " days</p>");
              out.write("<p><strong>New Expiry:</strong> "      + newExpiry + "</p>");
              out.write("<p><strong>Price:</strong> RM"         + request.getParameter("price") + "</p>");
            }
          %>
        </div>
        <div class="buttons">
          <form action="paymentGateway.jsp" method="post">
            <% // carry every parameter forward %>
            <%
              for (Map.Entry<String,String[]> e : request.getParameterMap().entrySet()) {
                for (String v : e.getValue()) {
                  out.write("<input type=\"hidden\" name=\"" 
                            + e.getKey() + "\" value=\"" + v + "\"/>");
                }
              }
            %>
            <button type="submit" class="btn-submit">PAY NOW</button>
            <a href="dashboard.jsp" class="btn-back">CANCEL</a>
          </form>
        </div>
      </div>
    </div>
  </div>
  <%@ include file="footer.jsp" %>
</body>
</html>