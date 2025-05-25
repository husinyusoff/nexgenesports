<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
  <title>Login – NexGen Esports</title>
  <link rel="stylesheet" href="styles.css">
</head>
<body>
  <h2>Login</h2>
  <form action="LoginServlet" method="post">
    <label>UserID:</label>
    <input name="userID" required /><br/>
    <label>Password:</label>
    <input name="password" type="password" required /><br/>
    <label>Role:</label><br/>
    <input type="radio" name="selectedRole" value="athlete" checked/> Athlete<br/>
    <input type="radio" name="selectedRole" value="executive_council"/> Exec Council<br/>
    <input type="radio" name="selectedRole" value="high_council"/> High Council<br/>
    <input type="radio" name="selectedRole" value="referee"/> Referee<br/>
    <button type="submit">Login</button>
  </form>
  <c:if test="${param.error=='badcreds'}">
    <p style="color:red">Invalid credentials or role.</p>
  </c:if>
</body>
</html>