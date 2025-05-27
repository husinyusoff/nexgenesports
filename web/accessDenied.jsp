<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page session="true" %>
<!DOCTYPE html>
<html>
<head>
  <title>Access Denied – NexGen Esports</title>
  <link rel="stylesheet" href="styles.css">
</head>
<body class="sidebar-collapsed">

  <!-- Header -->
  <jsp:include page="header.jsp"/>

  <!-- ☰ open-sidebar -->
  <button id="openToggle" class="open-toggle">☰</button>

  <div class="container">
    <!-- Sidebar w/ close button -->
    <div class="sidebar">
      <button id="closeToggle" class="close-toggle">×</button>
      <jsp:include page="sidebar.jsp"/>
    </div>

    <!-- Main content -->
    <div class="content">
      <h2>Access Denied</h2>
      <p>You don’t have permission to view that page.</p>
      <a href="index.jsp">← Home</a>
    </div>
  </div>

  <jsp:include page="footer.jsp"/>
  <script>
    document.getElementById('openToggle').addEventListener('click', () =>
      document.body.classList.remove('sidebar-collapsed')
    );
    document.getElementById('closeToggle').addEventListener('click', () =>
      document.body.classList.add('sidebar-collapsed')
    );
  </script>
</body>
</html>
