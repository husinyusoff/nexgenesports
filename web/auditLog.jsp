<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true"%>
<%@ page import="java.util.List,java.util.Map"%>
<%
    String userId = (String) session.getAttribute("username");
    if (userId == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    // Optionally restrict to admins only
    Boolean isAdmin = Boolean.TRUE.equals(session.getAttribute("isAdmin"));
    if (!isAdmin) {
        response.sendRedirect("accessDenied.jsp");
        return;
    }
    List<Map<String,Object>> logs = (List<Map<String,Object>>)request.getAttribute("logs");
%>
<!DOCTYPE html>
<html>
<head>
  <title>Audit Log – NexGen Esports</title>
  <link rel="stylesheet" href="styles.css">
</head>
<body>
<jsp:include page="header.jsp"/>
<div class="container">
  <div class="sidebar"><jsp:include page="sidebar.jsp"/></div>
  <div class="content">
    <div class="card">
      <div class="card-header"><h1>Audit Log</h1></div>
      <table class="summary-table">
        <thead>
          <tr>
            <th>Time</th><th>User</th><th>Entity</th><th>Action</th><th>Details</th>
          </tr>
        </thead>
        <tbody>
          <c:forEach var="log" items="${logs}">
            <tr>
              <td>${log.timestamp}</td>
              <td>${log.performedBy}</td>
              <td>${log.entityType}:${log.entityID}</td>
              <td>${log.actionType}</td>
              <td><pre style="white-space:pre-wrap;">${log.details}</pre></td>
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
