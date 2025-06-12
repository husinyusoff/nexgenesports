<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true" %>
<%@ page import="java.util.List, java.util.Map" %>
<%
    String userId = (String) session.getAttribute("username");
    if (userId == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    List<Map<String,Object>> notes = (List<Map<String,Object>>) request.getAttribute("notifications");
%>
<!DOCTYPE html>
<html>
<head>
  <title>Notifications – NexGen Esports</title>
  <link rel="stylesheet" href="styles.css">
</head>
<body>
<jsp:include page="header.jsp"/>
<div class="container">
  <div class="sidebar"><jsp:include page="sidebar.jsp"/></div>
  <div class="content">
    <div class="card">
      <div class="card-header"><h1>Notifications</h1></div>
      <table class="summary-table">
        <thead>
          <tr>
            <th>Type</th><th>Entity</th><th>Severity</th><th>Channel</th><th>Date</th><th>Action</th>
          </tr>
        </thead>
        <tbody>
          <c:forEach var="n" items="${notifications}">
            <tr style="${n.isRead ? '' : 'font-weight:bold;'}">
              <td>${n.type}</td>
              <td>${n.referenceType}:${n.referenceID}</td>
              <td>${n.severity}</td>
              <td>${n.channel}</td>
              <td>${n.createdAt}</td>
              <td>
                <c:if test="${!n.isRead}">
                  <form method="post" action="notifications" style="display:inline">
                    <input type="hidden" name="action" value="markRead"/>
                    <input type="hidden" name="notificationID" value="${n.notificationID}"/>
                    <button type="submit">Mark as Read</button>
                  </form>
                </c:if>
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
