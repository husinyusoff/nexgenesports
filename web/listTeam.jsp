<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true" %>
<%@ page import="java.util.List, java.util.Map" %>
<%
    String userId = (String) session.getAttribute("username");
    if (userId == null) { response.sendRedirect("login.jsp"); return; }
    List<Map<String,Object>> teams = (List<Map<String,Object>>) request.getAttribute("teams");
%>
<!DOCTYPE html>
<html>
<head>
  <title>Your Teams – NexGen Esports</title>
  <link rel="stylesheet" href="styles.css">
</head>
<body>
<jsp:include page="header.jsp"/>
<div class="container">
  <div class="sidebar"><jsp:include page="sidebar.jsp"/></div>
  <div class="content">
    <div class="card">
      <div class="card-header"><h1>Your Teams</h1></div>
      <a href="team?action=create" class="btn-buy">+ Create Team</a>
      <table class="summary-table">
        <thead>
          <tr><th>Team ID</th><th>Name</th><th>Game</th><th>Role</th><th>Action</th></tr>
        </thead>
        <tbody>
        <c:forEach var="t" items="${teams}">
          <tr>
            <td>${t.teamID}</td>
            <td>${t.teamName}</td>
            <td>${t.gameID}</td>
            <td>${t.teamRole}</td>
            <td>
              <a href="team?action=view&teamID=${t.teamID}">View</a>
            </td>
          </tr>
        </c:forEach>
        </tbody>
      </table>
    </div>
  </div>
</div>
<jsp:include page="footer.jsp"/>
</body>
</html>
