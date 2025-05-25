<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page session="true" %>
<!DOCTYPE html>
<html>
<head>
  <title>Dashboard – NexGen Esports</title>
  <link rel="stylesheet" href="styles.css">
</head>
<body>
  <div class="header">
    <img src="${pageContext.request.contextPath}/images/umt-logo.png"
         alt="UMT Logo" class="logo umt-logo">
    <img src="${pageContext.request.contextPath}/images/esports-logo.png"
         alt="Esports Logo" class="logo esports-logo">
    <h1>NEXGEN ESPORTS</h1>
    <div style="position:absolute; right:20px; top:23px; display:flex; align-items:center;">
      <img src="${pageContext.request.contextPath}/images/user.png"
           alt="User" height="34" style="margin-right:8px;">
      <span>${sessionScope.name}</span>
    </div>
  </div>

  <div class="container">
    <jsp:include page="sidebar.jsp"/>
    <div class="content">
      <div class="dashboard-container">
        <img src="${pageContext.request.contextPath}/images/welcome-wordcloud.png"
             alt="Welcome" class="welcome-image">
      </div>
    </div>
  </div>

  <div class="footer">
    © NexGen Esports 2025 All Rights Reserved.
  </div>

  <script>
    document
      .getElementById('sidebarToggle')
      .addEventListener('click', () =>
        document.body.classList.toggle('sidebar-collapsed')
      );
  </script>
</body>
</html>
