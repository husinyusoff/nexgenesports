<%@ page import="java.util.*" %>
<%@ page contentType="text/html; charset=UTF-8" session="true" %>
<%
  if (session.getAttribute("username") == null) {
    response.sendRedirect("login.jsp");
    return;
  }

  boolean isClub = "club".equals(request.getParameter("type"));
  boolean isPass = "pass".equals(request.getParameter("type"));
  String title = isClub
               ? "Club Membership Payment"
               : (isPass ? "Monthly Pass Payment" : "Checkout");
%>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title><%= title %> – NexGen Esports</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/styles.css">
</head>
<body>
  <jsp:include page="header.jsp"/>
  <div class="card">
    <h2><%= title %></h2>
    <div class="summary">
      <% if (isClub) { %>
        <p><strong>Membership:</strong> <%= request.getParameter("sessionName") %></p>
        <p><strong>Price:</strong> RM<%= request.getParameter("fee") %></p>
      <% } else if (isPass) { %>
        <p><strong>Pass Tier:</strong> <%= request.getParameter("tierName") %></p>
        <p><strong>Price:</strong> RM<%= request.getParameter("price") %></p>
      <% } %>
    </div>

    <form method="post" action="${pageContext.request.contextPath}/confirmPayment">
      <% 
        for (Map.Entry<String,String[]> e : request.getParameterMap().entrySet()) {
          for (String v : e.getValue()) {
      %>
      <input type="hidden" name="<%= e.getKey() %>" value="<%= v %>"/>
      <%
          }
        }
      %>

      <label>Card Number</label>
      <input type="text" name="cardNumber" required maxlength="16"/>

      <label>Name on Card</label>
      <input type="text" name="cardName" required/>

      <div class="half">
        <label>Expiry (MM/YY)</label>
        <input type="month" name="expiryDate" required
               min="<%= java.time.YearMonth.now() %>"/>
      </div>
      <div class="half">
        <label>CVV</label>
        <input type="text" name="cvv" required maxlength="4"/>
      </div>

      <div class="buttons">
        <button type="submit" class="btn-submit">Submit Payment</button>
        <a href="membershipPass.jsp" class="btn-back">Cancel</a>
      </div>
    </form>
  </div>
  <jsp:include page="footer.jsp"/>
</body>
</html>
