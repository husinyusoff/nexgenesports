<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true" %>
<%@ page import="java.util.Map" %>
<%
  @SuppressWarnings("unchecked")
  Map<String,Object> t = (Map<String,Object>) request.getAttribute("tournament");
  boolean isNew = (t == null);
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title><%= isNew ? "Create Tournament" : "Edit Tournament" %> – NexGen Esports</title>
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
          <h1><%= isNew ? "Create Tournament" : "Edit Tournament" %></h1>
        </div>

        <form method="post"
              action="${pageContext.request.contextPath}/tournament">
          <input type="hidden" name="action" value="save"/>
          <% if (isNew) { %>
            <input type="hidden" name="isNew" value="true"/>
          <% } else { %>
            <input type="hidden" name="progID" value="<%= t.get("progID") %>"/>
          <% } %>

          <label for="progID">Tournament ID</label>
          <% if (isNew) { %>
            <input type="text" id="progID" name="progID" required/>
          <% } else { %>
            <input type="text" id="progID" name="progID"
                   value="<%= t.get("progID") %>" readonly/>
          <% } %>

          <label for="gameID">Game</label>
          <select id="gameID" name="gameID" required>
            <%
              @SuppressWarnings("unchecked")
              java.util.List<String> games =
                (java.util.List<String>) request.getAttribute("games");
              for (String g : games) {
                String sel = (!isNew && g.equals(t.get("gameID"))) ? "selected" : "";
            %>
            <option value="<%= g %>" <%= sel %>><%= g %></option>
            <% } %>
          </select>

          <label for="programName">Name</label>
          <input type="text" id="programName" name="programName"
                 value="<%= !isNew ? t.get("programName") : "" %>" required/>

          <label for="progFee">Fee (RM)</label>
          <input type="number" step="0.01" id="progFee" name="progFee"
                 value="<%= !isNew ? t.get("progFee") : "" %>" required/>

          <label for="startDate">Start Date</label>
          <input type="date" id="startDate" name="startDate"
                 value="<%= !isNew ? t.get("startDate") : "" %>" required/>

          <label for="endDate">End Date</label>
          <input type="date" id="endDate" name="endDate"
                 value="<%= !isNew && t.get("endDate")!=null ? t.get("endDate") : "" %>"/>

          <label for="startTime">Start Time</label>
          <input type="time" id="startTime" name="startTime"
                 value="<%= !isNew ? t.get("startTime") : "" %>" required/>

          <label for="endTime">End Time</label>
          <input type="time" id="endTime" name="endTime"
                 value="<%= !isNew && t.get("endTime")!=null ? t.get("endTime") : "" %>"/>

          <label for="prizePool">Prize Pool (RM)</label>
          <input type="number" step="0.01" id="prizePool" name="prizePool"
                 value="<%= !isNew ? t.get("prizePool") : "" %>" required/>

          <div class="buttons" style="margin-top:16px;">
            <button type="submit" class="btn-buy">
              <%= isNew ? "Create" : "Update" %>
            </button>
            <a href="${pageContext.request.contextPath}/tournament"
               class="btn-back">Cancel</a>
          </div>
        </form>
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
