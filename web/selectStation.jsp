<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*" %>
<%@ page import="All.DBConnection, All.PermissionChecker" %>
<%@ page session="true" %>

<%
    // 1) Ensure user is logged in
    HttpSession sessionObj = request.getSession(false);
    if (sessionObj == null || sessionObj.getAttribute("username") == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    // 2) RBAC check for /selectStation.jsp (page_id = 12)
    @SuppressWarnings(
            "unchecked")
    List<String> roles = (List<String>) sessionObj.getAttribute("effectiveRoles");
    String chosenRole = (String) sessionObj.getAttribute("role");
    String position = (String) sessionObj.getAttribute("position");
    if (roles == null
            || !PermissionChecker.hasAccess(roles, chosenRole, position, "/selectStation.jsp")) {
        response.sendRedirect(request.getContextPath() + "/accessDenied.jsp");
        return;
    }

    // 3) Fetch all stations from DB
    class Station {

        String id, name;
        Double n1, n2, h1, h2;
    }
    List<Station> allStations = new ArrayList<>();
    try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(
            "SELECT stationID, stationName, normalPrice1Player, normalPrice2Player, "
            + "       happyHourPrice1Player, happyHourPrice2Player "
            + "  FROM GamingStation")) {
        try (ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Station s = new Station();
                s.id = rs.getString("stationID");
                s.name = rs.getString("stationName");
                s.n1 = rs.getDouble("normalPrice1Player");
                s.n2 = (rs.getObject("normalPrice2Player") != null)
                        ? rs.getDouble("normalPrice2Player")
                        : null;
                s.h1 = rs.getDouble("happyHourPrice1Player");
                s.h2 = (rs.getObject("happyHourPrice2Player") != null)
                        ? rs.getDouble("happyHourPrice2Player")
                        : null;
                allStations.add(s);
            }
        }
    } catch (SQLException ex) {
        out.println("<p style='color:red;'>DB error: " + ex.getMessage() + "</p>");
    }
%>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Select Station & Players – NexGen Esports</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/styles.css">
        <script>
            // Whenever a radio button is clicked, check if its value == "RSM".
            // If so, disable the “2 Players” option, else enable it.
            function onStationChange(radio) {
                const twoOpt = document.getElementById('opt-2-players');
                if (radio.value === 'RSM') {
                    twoOpt.disabled = true;
                    twoOpt.text = '2 Players (Not Available)';
                } else {
                    twoOpt.disabled = false;
                    twoOpt.text = '2 Players';
                }
            }
        </script>
    </head>
    <body>
        <%@ include file="header.jsp" %>

        <div class="container">
            <div class="sidebar">
                <jsp:include page="sidebar.jsp" />
            </div>
            <div class="content">
                <div class="select-station-box">
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
                    <!-- Centered Heading -->
                    <h2>SELECT SESSION</h2>

                    <form method="GET" action="bookStation.jsp">
                        <table class="select-station-table">
                            <thead>
                                <tr>
                                    <th>Select</th>
                                    <th>Station ID</th>
                                    <th>Station Name</th>
                                    <th>Normal Price (1P)</th>
                                    <th>Normal Price (2P)</th>
                                    <th>Happy Hour (1P)</th>
                                    <th>Happy Hour (2P)</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    for (Station s : allStations) {
                                %>
                                <tr>
                                    <td>
                                        <input type="radio"
                                               name="stationID"
                                               value="<%= s.id%>"
                                               required
                                               onchange="onStationChange(this)">
                                    </td>
                                    <td><%= s.id%></td>
                                    <td><%= s.name%></td>
                                    <td>RM<%= String.format("%.2f", s.n1)%></td>
                                    <td>
                                        <%
                                            if (s.n2 != null) {
                                                out.print("RM" + String.format("%.2f", s.n2));
                                            } else {
                                                out.print("—");
                                            }
                                        %>
                                    </td>
                                    <td>RM<%= String.format("%.2f", s.h1)%></td>
                                    <td>
                                        <%
                                            if (s.h2 != null) {
                                                out.print("RM" + String.format("%.2f", s.h2));
                                            } else {
                                                out.print("—");
                                            }
                                        %>
                                    </td>
                                </tr>
                                <%
                                    }
                                %>
                            </tbody>
                        </table>

                        <div class="player-count-wrapper">
                            <label for="playerCount">Number of Players:</label>
                            <select name="playerCount" id="playerCount" required>
                                <option value="1">1 Player</option>
                                <!-- We will disable/hide this if “RSM” is chosen -->
                                <option value="2" id="opt-2-players">2 Players</option>
                            </select>
                        </div>

                        <div class="buttons">
                            <button type="submit" class="button green-button">Next</button>
                            <button type="button"
                                    onclick="window.location = 'dashboard.jsp';"
                                    class="button blue-button cancel-btn">
                                Cancel
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <%@ include file="footer.jsp" %>
    </body>
</html>
