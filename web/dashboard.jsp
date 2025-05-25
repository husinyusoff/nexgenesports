<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="javax.servlet.http.HttpSession" %>
<%
  HttpSession s = request.getSession(false);
  if (s==null || s.getAttribute("username")==null) {
    response.sendRedirect("login.jsp");
    return;
  }
  String user = (String)s.getAttribute("username");
  String role = (String)s.getAttribute("role");
%>
<!DOCTYPE html>
<html>
<head><title>Dashboard</title></head>
<body>
  <h1>Welcome, <%= user %>!</h1>
  <p>Your current role is: <strong><%= role %></strong></p>
  <p><a href="logout">Log out</a></p>
</body>
</html>
