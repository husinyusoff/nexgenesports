<%@ page language="java"
         contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, java.time.*, java.time.format.DateTimeParseException, java.util.*" %>
<%@ page import="All.DBConnection, All.PermissionChecker" %>
<%@ page session="true" %>

<%
    // 1) Authenticate & authorize
    HttpSession sess = request.getSession(false);
    if (sess == null || sess.getAttribute("username") == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    @SuppressWarnings("unchecked")
    List<String> roles      = (List<String>) sess.getAttribute("effectiveRoles");
    String chosenRole       = (String) sess.getAttribute("role");
    String position         = (String) sess.getAttribute("position");
    if (roles == null
     || chosenRole == null
     || !PermissionChecker.hasAccess(roles, chosenRole, position, "/bookStation.jsp")) {
        response.sendRedirect(request.getContextPath() + "/accessDenied.jsp");
        return;
    }

    // 2) Read stationID & playerCount
    String stationIDParam   = request.getParameter("stationID");
    String playerCountParam = request.getParameter("playerCount");
    if (stationIDParam == null || playerCountParam == null) {
        out.println("<p style='color:red;'>Missing station or player count. "
                  + "Please <a href='selectStation.jsp'>choose a station</a>.</p>");
        return;
    }
    int playerCount = 1;
    try { playerCount = Math.max(1, Math.min(2, Integer.parseInt(playerCountParam))); }
    catch (Exception ignored) {}

    // 3) Fetch stationName
    String stationName = "";
    try (Connection conn = DBConnection.getConnection();
         PreparedStatement ps = conn.prepareStatement(
           "SELECT stationName FROM GamingStation WHERE stationID = ?")) {
      ps.setString(1, stationIDParam);
      try (ResultSet rs = ps.executeQuery()) {
        if (rs.next()) stationName = rs.getString("stationName");
        else {
          out.println("<p style='color:red;'>Station not found.</p>");
          return;
        }
      }
    } catch (SQLException e) {
      out.println("<p style='color:red;'>DB error: " + e.getMessage() + "</p>");
      return;
    }

    // 4) Date handling
    LocalDate today = LocalDate.now();
    String dateParam = request.getParameter("date");
    LocalDate selectedDate = null;
    boolean showSlots = false;
    if (dateParam != null) {
      try {
        selectedDate = LocalDate.parse(dateParam);
        if (!selectedDate.isBefore(today)) showSlots = true;
      } catch (DateTimeParseException ignored) {}
    }

    // 5) If showing slots, load booked hours and set openingHour
    Set<Integer> bookedHours = new HashSet<>();
    int openingHour = 14;
    if (showSlots) {
      DayOfWeek dow = selectedDate.getDayOfWeek();
      openingHour = (dow == DayOfWeek.FRIDAY || dow == DayOfWeek.SATURDAY) ? 15 : 14;
      try (Connection conn = DBConnection.getConnection();
           PreparedStatement ps = conn.prepareStatement(
             "SELECT startTime,endTime FROM GamingStationBooking " +
             "WHERE stationID=? AND date=? AND status='Confirmed'")) {
        ps.setString(1, stationIDParam);
        ps.setDate(2, java.sql.Date.valueOf(selectedDate));
        try (ResultSet rs = ps.executeQuery()) {
          while (rs.next()) {
            LocalTime st = rs.getTime("startTime").toLocalTime();
            LocalTime et = rs.getTime("endTime").toLocalTime();
            for (int h = st.getHour(); h <= et.getHour(); h++) {
              bookedHours.add(h);
            }
          }
        }
      } catch (SQLException e) {
        out.println("<p style='color:red;'>Error fetching bookings: " + e.getMessage() + "</p>");
      }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Book Gaming Station – NexGen Esports</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/styles.css">
  <script>
    function reloadWithDate() {
      const dt = document.getElementById('date').value;
      if (!dt) return alert("Please pick a date.");
      window.location = "bookStation.jsp"
                       + "?stationID=<%= stationIDParam %>"
                       + "&playerCount=<%= playerCount %>"
                       + "&date=" + dt;
    }
    function validateSelection() {
      const ch = document.querySelectorAll('input[name="timeSlots"]:checked');
      if (ch.length === 0) { alert("Select at least one slot."); return false; }
      let arr = Array.from(ch).map(c => +c.value).sort();
      for (let i = 0; i < arr.length - 1; i++) {
        if (arr[i] + 1 !== arr[i+1]) { alert("Slots must be consecutive."); return false; }
      }
      return true;
    }
  </script>
</head>
<body>
  <%@ include file="header.jsp" %>
  <div class="container">
    <div class="sidebar"><jsp:include page="sidebar.jsp"/></div>
    <div class="content">
      <div class="book-station-container">
        <a href="selectStation.jsp" class="back-link">← Back</a>
        <h2>Book Gaming Station</h2>
        <p><strong>Station:</strong> <%= stationName %></p>
        <p><strong>Players:</strong> <%= playerCount %></p>

        <div>
          <label for="date">Select Date:</label>
          <input type="date" id="date" name="date"
                 value="<%= selectedDate != null ? selectedDate : "" %>"
                 min="<%= today %>">
          <button type="button" class="view-slots-button" onclick="reloadWithDate()">
            View Slots
          </button>
        </div>

        <% if (showSlots) { %>
          <h3>Choose Time Slots:</h3>
          <form method="GET" action="checkout.jsp" onsubmit="return validateSelection()">
            <!-- mark booking flow -->
            <input type="hidden" name="type" value="booking"/>
            <input type="hidden" name="stationID"   value="<%= stationIDParam %>"/>
            <input type="hidden" name="stationName" value="<%= stationName    %>"/>
            <input type="hidden" name="date"        value="<%= selectedDate   %>"/>
            <input type="hidden" name="playerCount" value="<%= playerCount    %>"/>

            <table class="slot-table">
              <thead>
                <tr><th>Time</th><th>Available</th></tr>
              </thead>
              <tbody>
              <%
                for (int hr = openingHour; hr <= 22; hr++) {
                  String label = String.format("%02d:00–%02d:59", hr, hr);
                  boolean booked = bookedHours.contains(hr);
              %>
                <tr>
                  <td><%= label %></td>
                  <td>
                    <% if (booked) { %>
                      <span style="color:red;">Booked</span>
                    <% } else { %>
                      <input type="checkbox" name="timeSlots" value="<%= hr %>"/>
                    <% } %>
                  </td>
                </tr>
              <% } %>
              </tbody>
            </table>

            <div class="form-actions">
              <button type="submit" class="green-button">Next</button>
              <a href="selectStation.jsp?stationID=<%= stationIDParam %>&playerCount=<%= playerCount %>"
                 class="blue-button">Cancel</a>
            </div>
          </form>
        <% } %>

      </div>
    </div>
  </div>
  <%@ include file="footer.jsp" %>
</body>
</html>
