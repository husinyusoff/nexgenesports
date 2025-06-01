<%@ page import="java.time.YearMonth" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.util.List" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="All.PermissionChecker" %>
<%@ page session="true" %>

<%
  // 1) Ensure user is logged in
  HttpSession sessionObj = request.getSession(false);
  if (sessionObj == null || sessionObj.getAttribute("username") == null) {
      response.sendRedirect(request.getContextPath() + "/login.jsp");
      return;
  }

  // 2) RBAC: check /paymentGateway.jsp (page_id=17)
  @SuppressWarnings("unchecked")
  List<String> roles    = (List<String>) sessionObj.getAttribute("effectiveRoles");
  String chosenRole     = (String) sessionObj.getAttribute("role");
  String position       = (String) sessionObj.getAttribute("position");
  if (roles == null
      || !PermissionChecker.hasAccess(roles, chosenRole, position, "/paymentGateway.jsp")) {
      response.sendRedirect(request.getContextPath() + "/accessDenied.jsp");
      return;
  }

  // 3) Read booking info from query parameters
  String stationID   = request.getParameter("stationID");
  String stationName = request.getParameter("stationName");
  String date        = request.getParameter("date");
  String playerCount = request.getParameter("playerCount");
  String totalPrice  = request.getParameter("totalPrice");
  String[] timeSlots = request.getParameterValues("timeSlots");
%>

<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Mock Payment Gateway – NexGen Esports</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/styles.css">
</head>
<body>
  <%@ include file="header.jsp" %>
  <div class="container">
    <div class="sidebar">
      <jsp:include page="sidebar.jsp" />
    </div>
    <div class="content">
      <div class="payment-container">
        <h2>Mock Payment Gateway</h2>
        <p class="note">Please enter your mock card details below.</p>

        <!-- Card logos -->
        <div class="card-logos">
          <img src="https://upload.wikimedia.org/wikipedia/commons/4/41/Visa_Logo.png" alt="Visa">
          <img src="https://upload.wikimedia.org/wikipedia/commons/0/04/Mastercard-logo.png" alt="Mastercard">
          <img src="https://upload.wikimedia.org/wikipedia/commons/3/30/Amex-logo.png" alt="American Express">
        </div>

        <!-- Form POSTS to PaymentConfirmationServlet -->
        <form method="POST" action="${pageContext.request.contextPath}/confirmPayment">
          <!-- Hidden: booking info -->
          <input type="hidden" name="stationID"   value="<%= stationID %>">
          <input type="hidden" name="stationName" value="<%= stationName %>">
          <input type="hidden" name="date"        value="<%= date %>">
          <input type="hidden" name="playerCount" value="<%= playerCount %>">
          <input type="hidden" name="totalPrice"  value="<%= totalPrice %>">
          <%
            if (timeSlots != null) {
              for (String hr : timeSlots) {
          %>
              <input type="hidden" name="timeSlots" value="<%= hr %>">
          <%
              }
            }
          %>

          <!-- Card Number -->
          <label for="cardNumber">Card Number</label>
          <input type="text"
                 id="cardNumber"
                 name="cardNumber"
                 placeholder="1234 5678 9012 3456"
                 required />

          <!-- Name on Card -->
          <label for="cardName">Name on Card</label>
          <input type="text"
                 id="cardName"
                 name="cardName"
                 placeholder="Full Name"
                 required />

          <div class="half">
            <label for="expiryDate">Expiry Date</label>
            <!-- Use single quotes around the JSP expression so inner quotes (") are valid -->
            <input type="month"
                   id="expiryDate"
                   name="expiryDate"
                   required
                   min='<%= YearMonth.now().format(DateTimeFormatter.ofPattern("yyyy-MM")) %>' />
          </div>
          <div class="half">
            <label for="cvv">CVV</label>
            <input type="text"
                   id="cvv"
                   name="cvv"
                   placeholder="123"
                   required
                   pattern="\d{3}" />
          </div>

          <div class="buttons">
            <button type="submit" class="btn-submit">Submit Payment</button>
            <a href="checkoutBook.jsp" class="btn-back">Cancel</a>
          </div>
        </form>
      </div>
    </div>
  </div>
  <%@ include file="footer.jsp" %>
</body>
</html>
