<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List, All.PermissionChecker" %>
<%@ page session="true" %>

<%
  // 1) Ensure user is logged in
  HttpSession sessionObj = request.getSession(false);
  if (sessionObj == null || sessionObj.getAttribute("username") == null) {
      response.sendRedirect(request.getContextPath() + "/login.jsp");
      return;
  }

  // 2) RBAC: check /paymentSuccess.jsp (page_id=14)
  @SuppressWarnings("unchecked")
  List<String> roles    = (List<String>) sessionObj.getAttribute("effectiveRoles");
  String chosenRole     = (String) sessionObj.getAttribute("role");
  String position       = (String) sessionObj.getAttribute("position");
  if (roles == null
      || !PermissionChecker.hasAccess(roles, chosenRole, position, "/paymentSuccess.jsp")) {
      response.sendRedirect(request.getContextPath() + "/accessDenied.jsp");
      return;
  }
%>

<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Payment Successful – NexGen Esports</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/styles.css">
</head>
<body>
  <%@ include file="header.jsp" %>
  <div class="container">
    <div class="sidebar">
      <jsp:include page="sidebar.jsp" />
    </div>
    <div class="content">
      <div class="success-container">
        <img src="https://upload.wikimedia.org/wikipedia/commons/thumb/e/e5/Green_check.svg/1200px-Green_check.svg.png"
             alt="Success" class="checkmark" />
        <h2>Payment Successful!</h2>
        <p>Your booking has been confirmed.</p>
        <p>Thank you for using NexGen Esports.</p>
        <a href="dashboard.jsp" class="btn-home">Back to Dashboard</a>
      </div>
    </div>
  </div>
  <%@ include file="footer.jsp" %>
</body>
</html>
A