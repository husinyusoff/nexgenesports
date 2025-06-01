<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.time.*, java.time.format.*, java.util.*" %>
<%@ page import="All.DBConnection, All.PermissionChecker" %>
<%@ page session="true" %>

<%
    // 1) Ensure user is logged in
    HttpSession sessionObj = request.getSession(false);
    if (sessionObj == null || sessionObj.getAttribute("username") == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    // 2) RBAC check for /checkoutBook.jsp (page_id=13)
    @SuppressWarnings(
    
    "unchecked")
  List<String> roles = (List<String>) sessionObj.getAttribute("effectiveRoles");
    String chosenRole = (String) sessionObj.getAttribute("role");
    String position = (String) sessionObj.getAttribute("position");
    if (roles == null
            || !PermissionChecker.hasAccess(roles, chosenRole, position, "/checkoutBook.jsp")) {
        response.sendRedirect(request.getContextPath() + "/accessDenied.jsp");
        return;
    }

    // 3) Read required booking parameters
    String stationID = request.getParameter("stationID");
    String stationName = request.getParameter("stationName");
    String dateStr = request.getParameter("date");
    String playerCountStr = request.getParameter("playerCount");
    String[] timesArr = request.getParameterValues("timeSlots");
    if (stationID == null || stationName == null
            || dateStr == null || playerCountStr == null
            || timesArr == null || timesArr.length == 0) {
        out.println("<p style='color:red;'>Missing booking data. "
                + "Please <a href='bookStation.jsp'>go back and try again</a>.</p>");
        return;
    }

    // 4) Parse numeric values
    int playerCount;
    try {
        playerCount = Integer.parseInt(playerCountStr.trim());
    } catch (Exception ex) {
        playerCount = 1;
    }

    LocalDate selectedDate;
    try {
        selectedDate = LocalDate.parse(dateStr.trim());
    } catch (Exception ex) {
        out.println("<p style='color:red;'>Invalid date format. </p>");
        return;
    }

    // 5) Build sorted list of hour‐integers, compute startHour/endHour
    List<Integer> hours = new ArrayList<>();
    for (String hr : timesArr) {
        try {
            hours.add(Integer.parseInt(hr.trim()));
        } catch (Exception ignore) {
        }
    }
    if (hours.isEmpty()) {
        out.println("<p style='color:red;'>No valid time slots selected. </p>");
        return;
    }
    Collections.sort(hours);
    int startHour = hours.get(0);
    int endHour = hours.get(hours.size() - 1);
    int hourCount = hours.size();

    // 6) Fetch station pricing from DB
    Double n1 = 0.0, n2 = 0.0, h1 = 0.0, h2 = 0.0;
    try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(
            "SELECT normalPrice1Player, normalPrice2Player, "
            + "       happyHourPrice1Player, happyHourPrice2Player "
            + "  FROM GamingStation "
            + " WHERE stationID = ?")) {
        ps.setString(1, stationID);
        try (ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                n1 = rs.getDouble("normalPrice1Player");
                if (rs.getObject("normalPrice2Player") != null) {
                    n2 = rs.getDouble("normalPrice2Player");
                }
                h1 = rs.getDouble("happyHourPrice1Player");
                if (rs.getObject("happyHourPrice2Player") != null) {
                    h2 = rs.getDouble("happyHourPrice2Player");
                }
            } else {
                out.println("<p style='color:red;'>Station not found. </p>");
                return;
            }
        }
    } catch (SQLException ex) {
        out.println("<p style='color:red;'>DB error: " + ex.getMessage() + "</p>");
        return;
    }

    // 7) Determine openingHour logic again (Sun–Thu=14; Fri/Sat=15)
    DayOfWeek dow = selectedDate.getDayOfWeek();
    int openingHour = (dow == DayOfWeek.FRIDAY || dow == DayOfWeek.SATURDAY)
            ? 15 : 14;

    // 8) Compute total price by summing each hour slot’s rate
    double totalPrice = 0.0;
    for (int hr : hours) {
        boolean isHappy = (hr >= openingHour && hr < 19);
        if (playerCount == 1) {
            totalPrice += (isHappy ? h1 : n1);
        } else {
            totalPrice += (isHappy ? h2 : n2);
        }
    }

    // 9) Format date/time for display
    DateTimeFormatter dateFmt = DateTimeFormatter.ofPattern("dd/MM/yyyy");
    String displayDate = selectedDate.format(dateFmt);
    LocalTime stTime = LocalTime.of(startHour, 0);
    LocalTime enTime = LocalTime.of(endHour, 59);
    DateTimeFormatter timeFmt = DateTimeFormatter.ofPattern("h:mm a", Locale.ENGLISH);
    String startTimeStr = stTime.format(timeFmt);
    String endTimeStr = enTime.format(timeFmt);

    // 10) Build Back URL to return to bookStation.jsp with same params
    String backURL = "bookStation.jsp"
            + "?stationID=" + stationID
            + "&playerCount=" + playerCount
            + "&date=" + dateStr;
%>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
            <title>Checkout – NexGen Esports</title>
            <link rel="stylesheet" href="${pageContext.request.contextPath}/styles.css">
                </head>
                <body>
                    <%@ include file="header.jsp" %>
                    <div class="container">
                        <div class="sidebar">
                            <jsp:include page="sidebar.jsp" />
                        </div>
                        <div class="content">
                            <div class="checkout-box">
                                <!-- Back link top-left -->
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


                                <h2>CHECKOUT</h2>
                                <p class="note-text">
                                    <span>Please note: This transaction is </span>
                                    <span class="red-part">NOT REFUNDABLE</span>
                                </p>

                                <p class="info-line"><strong>Station Name:</strong> <%= stationName%></p>
                                <p class="info-line"><strong>Date:</strong> <%= displayDate%></p>
                                <p class="info-line"><strong>Start Time:</strong> <%= startTimeStr%></p>
                                <p class="info-line"><strong>End Time:</strong> <%= endTimeStr%></p>
                                <p class="info-line"><strong>Total Hours:</strong> <%= hourCount%></p>
                                <p class="info-line"><strong>Total Price:</strong> RM<%= String.format("%.2f", totalPrice)%></p>

                                <div class="buttons">
                                    <!-- Pay Now → carry all hidden booking data forward to paymentGateway.jsp -->
                                    <form method="GET" action="paymentGateway.jsp" style="display:inline;">
                                        <input type="hidden" name="stationID"   value="<%= stationID%>">
                                            <input type="hidden" name="stationName" value="<%= stationName%>">
                                                <input type="hidden" name="date"        value="<%= dateStr%>">
                                                    <input type="hidden" name="playerCount" value="<%= playerCount%>">
                                                        <input type="hidden" name="totalPrice"  value="<%= totalPrice%>">
                                                            <% for (int hr : hours) {%>
                                                            <input type="hidden" name="timeSlots" value="<%= hr%>">
                                                                <% }%>
                                                                <button type="submit" class="btn-pay">Pay Now</button>
                                                                </form>

                                                                <!-- Cancel → return to dashboard -->
                                                                <a href="dashboard.jsp" class="btn-cancel">Cancel</a>
                                                                </div>
                                                                </div>
                                                                </div>
                                                                </div>
                                                                <%@ include file="footer.jsp" %>
                                                                </body>
                                                                </html>
