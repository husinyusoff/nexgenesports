<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ page import="java.sql.*, java.time.*, java.time.format.DateTimeParseException, java.util.*" %>
<%@ page import="All.DBConnection, All.PermissionChecker" %>
<%@ page session="true" %>

<%
    // 1) Authenticate & authorize
    if (session == null || session.getAttribute("username") == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    @SuppressWarnings("unchecked")
    List<String> roles      = (List<String>) session.getAttribute("effectiveRoles");
    String       chosenRole = (String) session.getAttribute("role");
    String       position   = (String) session.getAttribute("position");
    if (roles == null 
     || chosenRole == null 
     || !PermissionChecker.hasAccess(roles, chosenRole, position, "/bookStation.jsp")) {
        response.sendRedirect(request.getContextPath() + "/accessDenied.jsp");
        return;
    }

    // 2) Read “stationID” & “playerCount”
    String stationIDParam   = request.getParameter("stationID");
    String playerCountParam = request.getParameter("playerCount");
    if (stationIDParam == null || stationIDParam.trim().isEmpty()
     || playerCountParam == null || playerCountParam.trim().isEmpty()) {
        out.println("<p style='color:red;'>Station or player count missing. "
                  + "Please <a href='selectStation.jsp'>choose a station first</a>.</p>");
        return;
    }
    int playerCount = 1;
    try {
        playerCount = Integer.parseInt(playerCountParam);
        if (playerCount < 1 || playerCount > 2) {
            playerCount = 1;
        }
    } catch (NumberFormatException e) {
        playerCount = 1;
    }

    // 3) Fetch “stationName” from DB
    String stationName = null;
    try (Connection conn = DBConnection.getConnection();
         PreparedStatement ps = conn.prepareStatement(
             "SELECT stationName FROM GamingStation WHERE stationID = ?"
         )) {
        ps.setString(1, stationIDParam);
        try (ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                stationName = rs.getString("stationName");
            } else {
                out.println("<p style='color:red;'>Station not found in database.</p>");
                return;
            }
        }
    } catch (SQLException e) {
        out.println("<p style='color:red;'>Error retrieving station: " + e.getMessage() + "</p>");
        return;
    }

    // 4) Read “date” and check if ≥ today
    LocalDate today        = LocalDate.now();
    String    dateParam    = request.getParameter("date");
    LocalDate selectedDate = null;
    boolean   showSlots    = false;
    if (dateParam != null && !dateParam.trim().isEmpty()) {
        try {
            selectedDate = LocalDate.parse(dateParam);
            if (!selectedDate.isBefore(today)) {
                showSlots = true;
            } else {
                selectedDate = null;
            }
        } catch (DateTimeParseException ex) {
            selectedDate = null;
        }
    }

    // 5) If “showSlots” is true, compute openingHour and fetch booked slots
    Set<Integer> bookedHours = new HashSet<>();
    int openingHour = 14;  // default 2 PM
    if (showSlots) {
        DayOfWeek dow = selectedDate.getDayOfWeek();
        if (dow == DayOfWeek.FRIDAY || dow == DayOfWeek.SATURDAY) {
            openingHour = 15; // 3 PM on Fri & Sat
        } else {
            openingHour = 14; // 2 PM on Sun–Thu
        }
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                "SELECT startTime, endTime "
              + "  FROM GamingStationBooking "
              + " WHERE stationID = ? "
              + "   AND date = ? "
              + "   AND status = 'Confirmed'"
             )) {
            ps.setString(1, stationIDParam);
            ps.setDate(2, java.sql.Date.valueOf(selectedDate));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    LocalTime st = rs.getTime("startTime").toLocalTime();
                    LocalTime et = rs.getTime("endTime").toLocalTime();
                    for (int hr = st.getHour(); hr <= et.getHour(); hr++) {
                        bookedHours.add(hr);
                    }
                }
            }
        } catch (SQLException e) {
            out.println("<p style='color:red;'>Error retrieving booked slots: " 
                      + e.getMessage() + "</p>");
        }
    }
%>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
            <title>Book Gaming Station – NexGen Esports</title>
            <link rel="stylesheet" href="${pageContext.request.contextPath}/styles.css">

                <script>
                    // Reload current JSP with the chosen date, stationID & playerCount
                    function reloadWithDate() {
                        const dateInput = document.getElementById('date');
                        if (!dateInput.value) {
                            alert("Please pick a date.");
                            return;
                        }
                        const stationID = "<%= stationIDParam %>";
                        const playerCount = "<%= playerCount %>";
                        window.location.href = "bookStation.jsp"
                                + "?stationID=" + stationID
                                + "&playerCount=" + playerCount
                                + "&date=" + dateInput.value;
                    }

                    // Ensure at least one time slot is checked and they are consecutive
                    function validateSelection() {
                        const checkboxes = document.querySelectorAll('input[name="timeSlots"]:checked');
                        if (checkboxes.length === 0) {
                            alert("Please select at least one time slot.");
                            return false;
                        }
                        let times = Array.from(checkboxes).map(cb => parseInt(cb.value)).sort();
                        for (let i = 0; i < times.length - 1; i++) {
                            if (times[i] + 1 !== times[i + 1]) {
                                alert("Please select consecutive time slots without gaps.");
                                return false;
                            }
                        }
                        return true;
                    }
                </script>
                </head>
                <body>
                    <%@ include file="header.jsp" %>

                    <div class="container">
                        <div class="sidebar">
                            <jsp:include page="sidebar.jsp"/>
                        </div>
                        <div class="content">
                            <div class="book-station-container">
                                <!-- Back link top-left -->
                                <!-- UPDATED BACK LINK: long-tailed SVG arrow, dark stroke (#333) -->
                                <a href="javascript:history.back()" class="back-link" aria-label="Go Back">
                                    <svg xmlns="http://www.w3.org/2000/svg"
                                         viewBox="0 0 24 24"
                                         width="32"
                                         height="32"
                                         aria-hidden="true"
                                         focusable="false">
                                        <path
                                            d="M20 12H8  M8 12l6-6  M8 12l6 6"
                                            stroke="#333"
                                            stroke-width="2.5"
                                            fill="none"
                                            stroke-linecap="round"
                                            stroke-linejoin="round"/>
                                    </svg>
                                </a>

                                <!-- Title -->
                                <h2>Book Gaming Station</h2>
                                <h3>Station Name: <%= stationName %></h3>
                                <h4>Number of Players: <%= playerCount %></h4>

                                <!-- 1) Date-selection form -->
                                <form method="GET" action="bookStation.jsp">
                                    <input type="hidden" name="stationID"   value="<%= stationIDParam %>">
                                        <input type="hidden" name="playerCount" value="<%= playerCount %>">

                                            <label for="date">Select Date:</label>
                                            <input 
                                                type="date"
                                                id="date"
                                                name="date"
                                                value="<%= (selectedDate != null) ? selectedDate : "" %>"
                                                min="<%= today %>"
                                                required
                                                >
                                                <button type="button" 
                                                        class="view-slots-button" 
                                                        onclick="reloadWithDate()">
                                                    View Slots
                                                </button>
                                                </form>

                                                <% if (selectedDate != null) {
                                                     DayOfWeek dow = selectedDate.getDayOfWeek();
                                                     openingHour = (dow == DayOfWeek.FRIDAY || dow == DayOfWeek.SATURDAY) 
                                                                   ? 15 : 14;
                                                %>

                                                <h3 style="margin-top: 20px;">
                                                    Select Time Slots ( <%= playerCount %> Player<%= (playerCount > 1 ? "s" : "") %> ):
                                                </h3>
                                                <form method="POST" action="checkoutBook.jsp" 
                                                      onsubmit="return validateSelection()">
                                                    <input type="hidden" name="stationID"   value="<%= stationIDParam %>">
                                                        <input type="hidden" name="stationName" value="<%= stationName %>">
                                                            <input type="hidden" name="playerCount" value="<%= playerCount %>">
                                                                <input type="hidden" name="date"        value="<%= selectedDate %>">

                                                                    <table class="slot-table">
                                                                        <thead>
                                                                            <tr>
                                                                                <th>Time Slot</th>
                                                                                <th>Availability</th>
                                                                            </tr>
                                                                        </thead>
                                                                        <tbody>
                                                                            <% 
                                                                              for (int hr = openingHour; hr <= 22; hr++) {
                                                                                  String startLabel = String.format("%02d:00", hr);
                                                                                  String endLabel   = String.format("%02d:59", hr);
                                                                                  boolean isBooked  = bookedHours.contains(hr);
                                                                            %>
                                                                            <tr>
                                                                                <td><%= startLabel %> – <%= endLabel %></td>
                                                                                <td>
                                                                                    <% if (isBooked) { %>
                                                                                    <span style="color:red;">Booked</span>
                                                                                    <% } else { %>
                                                                                    <input type="checkbox" name="timeSlots" value="<%= hr %>">
                                                                                        <% } %>
                                                                                </td>
                                                                            </tr>
                                                                            <% } %>
                                                                        </tbody>
                                                                    </table>

                                                                    <div class="form-actions">
                                                                        <button type="submit" class="button green-button">Next</button>
                                                                        <a 
                                                                            href="selectStation.jsp?stationID=<%= stationIDParam %>&playerCount=<%= playerCount %>" 
                                                                            class="button blue-button">
                                                                            Back
                                                                        </a>
                                                                    </div>
                                                                    </form>
                                                                    <% }  /* end if selectedDate != null */ %>
                                                                    </div>
                                                                    </div>
                                                                    </div>

                                                                    <%@ include file="footer.jsp" %>
                                                                    </body>
                                                                    </html>
