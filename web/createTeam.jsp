<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true" %>
<%@ page import="java.util.List" %>
<%
    if (session.getAttribute("username")==null) {
      response.sendRedirect("login.jsp"); return;
    }
    List<String> games = (List<String>) request.getAttribute("games");
%>
<!DOCTYPE html>
<html>
<head>
  <title>Create Team – NexGen Esports</title>
  <link rel="stylesheet" href="styles.css">
</head>
<body>
<jsp:include page="header.jsp"/>
<div class="container">
  <div class="sidebar"><jsp:include page="sidebar.jsp"/></div>
  <div class="content">
    <div class="card">
      <div class="card-header"><h1>Create Team</h1></div>
      <form method="post" action="team">
        <input type="hidden" name="action" value="create"/>
        <label>Game</label>
        <select name="gameID" required>
          <c:forEach var="g" items="${games}">
            <option value="${g}">${g}</option>
          </c:forEach>
        </select>
        <label>Team Name</label>
        <input type="text" name="teamName" required/>
        <label>Description</label>
        <textarea name="description"></textarea>
        <label>Logo URL</label>
        <input type="text" name="logoURL"/>
        <button type="submit" class="btn-submit">Create</button>
        <a href="team" class="btn-back">Cancel</a>
      </form>
    </div>
  </div>
</div>
<jsp:include page="footer.jsp"/>
</body>
</html>
