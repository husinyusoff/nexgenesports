<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
  <title>Sign Up – NexGen Esports</title>
  <link rel="stylesheet" href="styles.css">
</head>
<body>
  <div class="header">
    <button id="sidebarToggle" aria-label="Toggle sidebar">☰</button>
    <img src="${pageContext.request.contextPath}/images/umt-logo.png"
         alt="UMT Logo" class="logo umt-logo">
    <img src="${pageContext.request.contextPath}/images/esports-logo.png"
         alt="Esports Logo" class="logo esports-logo">
    <h1>NEXGEN ESPORTS</h1>
  </div>

  <div class="container">
    <div class="sidebar">
      <a href="login.jsp">LOGIN</a>
      <a href="register.jsp">SIGN UP</a>
    </div>

    <div class="content">
      <div class="register-container">
        <h2>SIGN UP</h2>

        <form action="RegisterServlet" method="post">
          <div class="roles">
            <input type="radio" name="studentType" value="umt" id="umtStudent" checked/>
            <label for="umtStudent">UMT Student</label>
            <input type="radio" name="studentType" value="non" id="nonUmt"/>
            <label for="nonUmt">Not UMT Student</label>
          </div>

          <label for="matricOrUser">Matric Number (UMT) | User ID (Non-UMT)</label>
          <input id="matricOrUser" name="userID" required/>

          <label for="icNumber">IC Number (0000-00-0000)</label>
          <input id="icNumber" name="icNumber" required/>

          <label for="fullName">Full Name (CAPITAL LETTER)</label>
          <input id="fullName" name="fullName" required/>

          <label for="password">Password</label>
          <input id="password" name="password" type="password" required/>

          <label for="phone">Phone Number</label>
          <input id="phone" name="phoneNumber"/>

          <div class="roles">
            <span>Register as Esports Club Member (RM10)?</span><br/>
            <input type="radio" name="member" value="yes" id="memberYes" checked/>
            <label for="memberYes">Yes</label>
            <input type="radio" name="member" value="no" id="memberNo"/>
            <label for="memberNo">Not Interested</label>
          </div>

          <button type="submit">Register</button>
        </form>

        <c:if test="${param.error=='exists'}">
          <p style="color:red">UserID already exists.</p>
        </c:if>
        <c:if test="${param.error=='mismatch'}">
          <p style="color:red">Passwords do not match.</p>
        </c:if>
        <c:if test="${param.error=='sql'}">
          <p style="color:red">Registration failed. Please try again.</p>
        </c:if>
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
