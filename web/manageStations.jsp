<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ page import="java.sql.*, All.DBConnection" %>
<%@ page session="true" %>
<!DOCTYPE html>
<html>
<head>
    <title>Manage Stations</title>
    <link rel="stylesheet" type="text/css" href="styles.css">
</head>
<body>
    <div class="header">
        <div class="logo-title">
            <img src="${pageContext.request.contextPath}/images/umt-logo.jpg" alt="UMT Logo" class="logo">
            <h1>NEXGEN ESPORTS</h1>
        </div>
        <div class="user-info">
            <img src="${pageContext.request.contextPath}/images/user.png" alt="User Icon">
            <span>${sessionScope.username}</span>
        </div>
    </div>

    <div class="container">
        <div class="sidebar">
            <a href="dashboard.jsp">Dashboard</a>
            <a href="profile.jsp">Profile</a>
            <a href="team.jsp">Team</a>
            <a href="tournament.jsp">Tournament</a>
            <div class="dropdown">
                <div class="dropdown-btn">Leaderboard</div>
                <div class="dropdown-content">
                    <a href="leaderboard.jsp">Player Stats</a>
                </div>
            </div>
            <div class="dropdown">
                <div class="dropdown-btn">Multiplayer Lounge</div>
                <div class="dropdown-content">
                    <a href="multiplayerLounge.jsp">Lounge</a>
                    <a href="calendar.jsp">Calendar</a>
                    <%
                        if ("HighCouncil".equals(session.getAttribute("role"))) {
                    %>
                    <a href="manageStations.jsp">Manage Stations</a>
                    <a href="manageBookings.jsp">Manage Bookings</a>
                    <%
                        }
                    %>
                </div>
            </div>

            <a href="logout.jsp" class="logout-btn">Logout</a>
            <div class="user-role">
                <%
                    String role = (String) session.getAttribute("role");
                    if (role != null) {
                        out.println(role + " Mode");
                    } else {
                        out.println("Role Unknown");
                    }
                %>
            </div>
        </div>

        <div class="content">
            <div class="manage-stations-container">
                <h2>Manage Stations</h2>
                <a href="addStation.jsp" class="add-station-button">Add Station</a>
                <table class="stations-table">
                    <thead>
                        <tr>
                            <th>Station ID</th>
                            <th>Station Name</th>
                            <th>Normal Price (1P)</th>
                            <th>Normal Price (2P)</th>
                            <th>Happy Hour Price (1P)</th>
                            <th>Happy Hour Price (2P)</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            // Now the GamingStation table has four price columns, not "normalPrice" / "happyHourPrice".
                            String sql = "SELECT stationID, stationName, "
                                       + "normalPrice1Player, normalPrice2Player, "
                                       + "happyHourPrice1Player, happyHourPrice2Player "
                                       + "FROM GamingStation";
                            try (Connection conn = DBConnection.getConnection();
                                 PreparedStatement stmt = conn.prepareStatement(sql);
                                 ResultSet rs = stmt.executeQuery()) {

                                while (rs.next()) {
                                    String id   = rs.getString("stationID");
                                    String name = rs.getString("stationName");
                                    double np1  = rs.getDouble("normalPrice1Player");
                                    double np2  = rs.getDouble("normalPrice2Player");
                                    double hp1  = rs.getDouble("happyHourPrice1Player");
                                    double hp2  = rs.getDouble("happyHourPrice2Player");
                        %>
                        <tr>
                            <td><%= id %></td>
                            <td><%= name %></td>
                            <td>RM<%= String.format("%.2f", np1) %></td>
                            <td>RM<%= String.format("%.2f", np2) %></td>
                            <td>RM<%= String.format("%.2f", hp1) %></td>
                            <td>RM<%= String.format("%.2f", hp2) %></td>
                            <td>
                                <a href="editStation.jsp?stationID=<%= id %>" class="edit-button">Edit</a>
                                <form action="DeleteStationServlet" method="post" style="display:inline;">
                                    <input type="hidden" name="stationID" value="<%= id %>">
                                    <button type="submit" class="delete-button">Delete</button>
                                </form>
                            </td>
                        </tr>
                        <%
                                }
                            } catch (SQLException e) {
                                e.printStackTrace();
                            }
                        %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <div class="footer">
        &copy; NexGen Esports 2025 All Rights Reserved.
    </div>
</body>
</html>
