<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true" %>
<%@ page import="java.util.List,java.util.Map" %>
<%
    String userId = (String) session.getAttribute("username");
    if (userId==null) { response.sendRedirect("login.jsp"); return; }
    Map<String,Object> team  = (Map<String,Object>) request.getAttribute("team");
    List<Map<String,Object>> members  = (List<Map<String,Object>>) request.getAttribute("members");
    List<Map<String,Object>> pendings = (List<Map<String,Object>>) request.getAttribute("pendings");
    boolean isLeader   = (boolean) request.getAttribute("isLeader");
    boolean isCoLeader = (boolean) request.getAttribute("isCoLeader");
%>
<!DOCTYPE html>
<html>
<head>
  <title>Team Details – NexGen Esports</title>
  <link rel="stylesheet" href="styles.css">
</head>
<body>
<jsp:include page="header.jsp"/>
<div class="container">
  <div class="sidebar"><jsp:include page="sidebar.jsp"/></div>
  <div class="content">
    <div class="card">
      <div class="card-header"><h1>${team.teamName}</h1></div>
      <p><strong>Game:</strong> ${team.gameID}</p>
      <p><strong>Description:</strong> ${team.description}</p>
      <p><strong>Created By:</strong> ${team.createdBy} on ${team.createdAt}</p>

      <h2>Members</h2>
      <table class="summary-table">
        <thead><tr><th>User</th><th>Role</th><th>Joined</th><th>Action</th></tr></thead>
        <tbody>
        <c:forEach var="m" items="${members}">
          <tr>
            <td>${m.userID}</td>
            <td>${m.teamRole}</td>
            <td>${m.joinedAt}</td>
            <td>
              <c:if test="${isLeader && m.userID!=userId}">
                <form method="post" action="teamMember" style="display:inline">
                  <input type="hidden" name="action" value="remove"/>
                  <input type="hidden" name="teamID" value="${team.teamID}"/>
                  <input type="hidden" name="userID" value="${m.userID}"/>
                  <button type="submit">Kick</button>
                </form>
                <form method="post" action="teamMember" style="display:inline">
                  <input type="hidden" name="action" value="transfer"/>
                  <input type="hidden" name="teamID" value="${team.teamID}"/>
                  <input type="hidden" name="newLeader" value="${m.userID}"/>
                  <button type="submit">Make Leader</button>
                </form>
              </c:if>
            </td>
          </tr>
        </c:forEach>
        </tbody>
      </table>

      <c:if test="${isLeader || isCoLeader}">
        <h3>Invite Member</h3>
        <form method="post" action="teamMember">
          <input type="hidden" name="action" value="invite"/>
          <input type="hidden" name="teamID" value="${team.teamID}"/>
          <label>User ID to invite:</label>
          <input type="text" name="userID" required/>
          <button type="submit">Invite</button>
        </form>
      </c:if>

      <c:if test="${isLeader}">
        <h3>Pending Requests</h3>
        <table class="summary-table">
          <thead><tr><th>User</th><th>Requested At</th><th>Action</th></tr></thead>
          <tbody>
          <c:forEach var="p" items="${pendings}">
            <tr>
              <td>${p.userID}</td>
              <td>${p.requestedAt}</td>
              <td>
                <form method="post" action="teamMember" style="display:inline">
                  <input type="hidden" name="action" value="approve"/>
                  <input type="hidden" name="teamID" value="${team.teamID}"/>
                  <input type="hidden" name="userID" value="${p.userID}"/>
                  <button type="submit">Approve</button>
                </form>
                <form method="post" action="teamMember" style="display:inline">
                  <input type="hidden" name="action" value="decline"/>
                  <input type="hidden" name="teamID" value="${team.teamID}"/>
                  <input type="hidden" name="userID" value="${p.userID}"/>
                  <button type="submit">Decline</button>
                </form>
              </td>
            </tr>
          </c:forEach>
          </tbody>
        </table>
      </c:if>

      <c:if test="${isLeader}">
        <form method="post" action="team" style="margin-top:20px">
          <input type="hidden" name="action" value="delete"/>
          <input type="hidden" name="teamID" value="${team.teamID}"/>
          <button type="submit" class="btn-back">Disband Team</button>
        </form>
      </c:if>
    </div>
  </div>
</div>
<jsp:include page="footer.jsp"/>
</body>
</html>
