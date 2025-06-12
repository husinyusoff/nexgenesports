<%@page import="java.util.Map"%>
<%@page import="java.util.List"%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Tournaments – NexGen Esports</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/styles.css">
</head>
<body>
  <jsp:include page="header.jsp"/>

  <!-- ☰ open button -->
  <button id="openToggle" class="open-toggle">☰</button>

  <div class="container">
    <!-- Sidebar -->
    <div class="sidebar">
      <button id="closeToggle" class="close-toggle">×</button>
      <jsp:include page="sidebar.jsp"/>
    </div>

    <!-- Main content -->
    <div class="content">
      <div class="card">
        <div class="card-header">
          <h1>Your Tournaments</h1>
        </div>

        <a href="${pageContext.request.contextPath}/tournament?action=form"
           class="btn-buy" style="margin-bottom:16px; display:inline-block;">
          + New Tournament
        </a>

        <table class="summary-table">
          <thead>
            <tr>
              <th>ID</th>
              <th>Game</th>
              <th>Name</th>
              <th>Fee (RM)</th>
              <th>Start Date</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            <%
              @SuppressWarnings("unchecked")
              List<Map<String,Object>> list =
                (List<Map<String,Object>>) request.getAttribute("tournaments");
              if (list != null) {
                for (Map<String,Object> t : list) {
            %>
            <tr>
              <td><%= t.get("progID") %></td>
              <td><%= t.get("gameID") %></td>
              <td><%= t.get("programName") %></td>
              <td>RM<%= t.get("progFee") %></td>
              <td><%= t.get("startDate") %></td>
              <td>
                <a href="${pageContext.request.contextPath}/tournament?action=form&amp;progID=<%= t.get("progID") %>">
                  Edit
                </a>
                |
                <form method="post"
                      action="${pageContext.request.contextPath}/tournament"
                      style="display:inline"
                      onsubmit="return confirm('Delete this tournament?');">
                  <input type="hidden" name="action" value="delete"/>
                  <input type="hidden" name="progID" value="<%= t.get("progID") %>"/>
                  <button type="submit" style="background:none;border:none;color:#c00;cursor:pointer;">
                    Delete
                  </button>
                </form>
              </td>
            </tr>
            <%    }
              } else { %>
            <tr><td colspan="6" style="text-align:center;">No tournaments found.</td></tr>
            <% } %>
          </tbody>
        </table>
      </div>
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
