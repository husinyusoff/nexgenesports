<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true" %>
<%@ page import="java.util.List, java.util.Map" %>
<%
    String userId = (String) session.getAttribute("username");
    if (userId == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    List<Map<String,Object>> teamAchievements     = (List<Map<String,Object>>) request.getAttribute("teamAchievements");
    List<Map<String,Object>> personalAchievements = (List<Map<String,Object>>) request.getAttribute("personalAchievements");
%>
<!DOCTYPE html>
<html>
<head>
  <title>Achievements – NexGen Esports</title>
  <link rel="stylesheet" href="styles.css">
</head>
<body>
<jsp:include page="header.jsp"/>
<div class="container">
  <div class="sidebar"><jsp:include page="sidebar.jsp"/></div>
  <div class="content">
    <div class="card">
      <div class="card-header"><h1>Achievements</h1></div>
      <div class="tab-switcher">
        <span class="tab-btn active" id="tabTeams">Team Leaderboard</span>
        <span class="tab-btn" id="tabPersonal">My Achievements</span>
      </div>

      <!-- Team Leaderboard -->
      <div id="panelTeams" class="panel active">
        <table class="summary-table">
          <thead>
            <tr>
              <th>Team</th><th>Tournament</th><th>Placement</th><th>Points</th><th>Date</th>
            </tr>
          </thead>
          <tbody>
            <c:forEach var="a" items="${teamAchievements}">
              <tr>
                <td>${a.teamName}</td>
                <td>${a.programName}</td>
                <td>${a.placement}</td>
                <td>${a.pointsAwarded}</td>
                <td>${a.achievedAt}</td>
              </tr>
            </c:forEach>
          </tbody>
        </table>
      </div>

      <!-- Personal Achievements -->
      <div id="panelPersonal" class="panel">
        <table class="summary-table">
          <thead>
            <tr>
              <th>Tournament</th><th>Team</th><th>Points</th><th>Date</th>
            </tr>
          </thead>
          <tbody>
            <c:forEach var="p" items="${personalAchievements}">
              <tr>
                <td>${p.programName}</td>
                <td>${p.teamName}</td>
                <td>${p.points}</td>
                <td>${p.achievedAt}</td>
              </tr>
            </c:forEach>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</div>
<jsp:include page="footer.jsp"/>

<script>
  const tabTeams = document.getElementById('tabTeams');
  const tabPers  = document.getElementById('tabPersonal');
  const panelT   = document.getElementById('panelTeams');
  const panelP   = document.getElementById('panelPersonal');

  tabTeams.onclick = () => {
    tabTeams.classList.add('active');
    tabPers.classList.remove('active');
    panelT.classList.add('active');
    panelP.classList.remove('active');
  };
  tabPers.onclick = () => {
    tabPers.classList.add('active');
    tabTeams.classList.remove('active');
    panelP.classList.add('active');
    panelT.classList.remove('active');
  };
</script>
</body>
</html>
