<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true" %>
<%@ page import="java.util.List, java.util.Map" %>
<%
    String userId = (String) session.getAttribute("username");
    if (userId == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    List<Map<String,Object>> ingames = (List<Map<String,Object>>) request.getAttribute("ingames");
    List<Map<String,Object>> locks   = (List<Map<String,Object>>) request.getAttribute("locks");
%>
<!DOCTYPE html>
<html>
<head>
  <title>In-Game Profile – NexGen Esports</title>
  <link rel="stylesheet" href="styles.css">
</head>
<body>
<jsp:include page="header.jsp"/>
<div class="container">
  <div class="sidebar"><jsp:include page="sidebar.jsp"/></div>
  <div class="content">
    <div class="card">
      <div class="card-header"><h1>In-Game Profile</h1></div>
      <table class="summary-table">
        <thead>
          <tr><th>Game ID</th><th>Your Handle</th><th>Platform</th><th>Region</th><th>Action</th></tr>
        </thead>
        <tbody>
        <c:forEach var="row" items="${ingames}">
          <tr>
            <form method="post" action="inGameProfile">
              <td><input type="hidden" name="inGameID" value="${row.inGameID}"/>
                  ${row.gameID}</td>
            <td>
              <input type="text" name="inGameUserID" 
                     value="${row.inGameUserID}"
                     ${locks[row_index] ? "readonly" : ""}/>
            </td>
            <td><input type="text" name="gamePlatformID"
                       value="${row.gamePlatformID}"/></td>
            <td><input type="text" name="regionCode"
                       value="${row.regionCode}"/></td>
            <td>
              <button type="submit" ${locks[row_index] ? "disabled" : ""}>Update</button>
            </td>
            </form>
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
