<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
  <title>Register – NexGen Esports</title>
  <link rel="stylesheet" href="styles.css">
</head>
<body>
  <h2>Register</h2>
  <form action="RegisterServlet" method="post">
    <label>UserID:</label>
    <input name="userID" required /><br/>

    <label>Name:</label>
    <input name="name" required /><br/>

    <label>Password:</label>
    <input name="password" type="password" required /><br/>

    <label>Confirm Password:</label>
    <input name="confirmPassword" type="password" required /><br/>

    <label>Phone Number:</label>
    <input name="phoneNumber" /><br/>

    <label>Role:</label><br/>
    <input type="radio" name="role" value="athlete" checked/> Athlete<br/>
    <input type="radio" name="role" value="executive_council"/> Exec Council<br/>
    <input type="radio" name="role" value="high_council"/> High Council<br/>
    <input type="radio" name="role" value="referee"/> Referee<br/>

    <label>Position (if applicable):</label>
    <select name="position">
      <option value="">None</option>
      <option value="secretary">Secretary</option>
      <option value="treasurer">Treasurer</option>
      <option value="vice_president">Vice President</option>
      <option value="president">President</option>
    </select><br/>

    <label>Gaming Pass ID:</label>
    <input name="gamingPassID" type="number" /><br/><br/>

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
</body>
</html>
