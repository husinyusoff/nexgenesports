<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
  <title>Login – NexGen Esports</title>
  <link rel="stylesheet" href="styles.css">
</head>
<body>

  <!-- Header -->
  <div class="header">
    <img src="${pageContext.request.contextPath}/images/umt-logo.png"
         alt="UMT Logo" class="logo umt-logo">
    <img src="${pageContext.request.contextPath}/images/esports-logo.png"
         alt="Esports Logo" class="logo esports-logo">
    <h1>NEXGEN ESPORTS</h1>
  </div>

  <!-- Open-toggle “pimple” -->
  <button id="openToggle" class="open-toggle">☰</button>

  <div class="container">
    <!-- Sidebar (open by default) -->
    <div class="sidebar">
      <!-- Close button inside sidebar -->
      <button id="closeToggle" class="close-toggle">&times;</button>

      <a href="${pageContext.request.contextPath}/login.jsp">LOGIN</a>
      <a href="${pageContext.request.contextPath}/register.jsp">SIGN UP</a>
    </div>

    <!-- Main content -->
    <div class="content">
      <div class="login-container">
        <h2>LOGIN</h2>
        <form action="LoginServlet" method="post">
          <div class="roles-grid">
            <label for="roleAthlete">
              <input type="radio" id="roleAthlete" name="selectedRole" value="athlete" checked>
              Athlete
            </label>
            <label for="roleReferee">
              <input type="radio" id="roleReferee" name="selectedRole" value="referee">
              Referee
            </label>
            <label for="roleExecCouncil">
              <input type="radio" id="roleExecCouncil" name="selectedRole" value="executive_council">
              Exec Council
            </label>
            <label for="roleHighCouncil">
              <input type="radio" id="roleHighCouncil" name="selectedRole" value="high_council">
              High Council
            </label>
          </div>

          <label for="userID">User ID</label>
          <input type="text" id="userID" name="userID" required>

          <label for="password">Password</label>
          <input type="password" id="password" name="password" required>

          <a href="#" class="forgot">forgot password</a>
          <button type="submit">Login</button>
        </form>

        <c:if test="${param.error=='badcreds'}">
          <script>
            window.addEventListener('load', () => {
              alert('Invalid credentials or role.');
              const u = new URL(location);
              u.searchParams.delete('error');
              history.replaceState(null,'',u.pathname);
            });
          </script>
        </c:if>
      </div>
    </div>
  </div>

  <div class="footer">
    © NexGen Esports 2025 All Rights Reserved.
  </div>

  <script>
    const openBtn  = document.getElementById('openToggle');
    const closeBtn = document.getElementById('closeToggle');

    openBtn.addEventListener('click', () => {
      document.body.classList.remove('sidebar-collapsed');
    });
    closeBtn.addEventListener('click', () => {
      document.body.classList.add('sidebar-collapsed');
    });
  </script>
</body>
</html>
