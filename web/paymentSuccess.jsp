<%@ page contentType="text/html; charset=UTF-8" session="true" %>
<%
  if (session.getAttribute("username")==null) {
    response.sendRedirect("login.jsp"); return;
  }
%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Payment Success – NexGen Esports</title>
        <link rel="stylesheet" href="styles.css">
    </head>
    <body>
        <jsp:include page="header.jsp"/>
        <div class="content">
            <div class="success-box">
                <h2>Payment Successful!</h2>
                <p>Thank you. Your transaction has been completed.</p>
                <a href="dashboard.jsp" class="btn">Go to Dashboard</a>
            </div>
        </div>
        <jsp:include page="footer.jsp"/>
    </body>
</html>
