<%@ page import="All.PermissionChecker" %>
<%@ page import="java.util.List" %>
<%@ page session="true" %>
<%
    @SuppressWarnings("unchecked")
    List<String> roles       = (List<String>) session.getAttribute("effectiveRoles");
    String       chosenRole  = (String) session.getAttribute("role");
    String       position    = (String) session.getAttribute("position");
    if (roles == null || chosenRole == null) {
        return; // no sidebar if not logged in
    }
%>
<nav>
    <ul>
        <!-- Dashboard (always) -->
        <li>
            <a href="${pageContext.request.contextPath}/dashboard.jsp">Dashboard</a>
        </li>

        <!-- Profile dropdown -->
        <li class="dropdown">
            <a href="javascript:void(0)" class="dropdown-btn">Profile</a>
            <ul class="dropdown-content">
                <!-- 1) My Profile (everyone) -->
                <li>
                    <a href="${pageContext.request.contextPath}/manageProfile.jsp">
                        My Profile
                    </a>
                </li>
                <!-- 2) In-Game Profile (if allowed) -->
                <% if (PermissionChecker.hasAccess(roles, chosenRole, position, "/inGameProfile.jsp")) { %>
                <li>
                    <a href="${pageContext.request.contextPath}/inGameProfile.jsp">
                        In-Game Profile
                    </a>
                </li>
                <% } %>

                <!-- 3) Membership & Pass -->
                <li>
                    <a href="${pageContext.request.contextPath}/membershipPass.jsp">
                        Membership &amp; Pass
                    </a>
                </li>
            </ul>
        </li>

        <!-- Multiplayer Lounge dropdown (unchanged) -->
        <li class="dropdown">
            <a href="javascript:void(0)" class="dropdown-btn">Multiplayer Lounge</a>
            <ul class="dropdown-content">
                <% if (PermissionChecker.hasAccess(roles, chosenRole, position, "/selectStation.jsp")) { %>
                <li>
                    <a href="${pageContext.request.contextPath}/selectStation.jsp">
                        Book Gaming Session
                    </a>
                </li>
                <% } %>
                <% if (PermissionChecker.hasAccess(roles, chosenRole, position, "/manageBooking.jsp")) { %>
                <li>
                    <a href="${pageContext.request.contextPath}/manageBooking.jsp">
                        Manage Booking
                    </a>
                </li>
                <% } %>
                <% if ("president".equals(position)
                      && PermissionChecker.hasAccess(roles, chosenRole, position, "/manageAllBooking.jsp")) { %>
                <li>
                    <a href="${pageContext.request.contextPath}/manageAllBooking.jsp">
                        Manage All Booking
                    </a>
                </li>
                <% } %>
                <% if (PermissionChecker.hasAccess(roles, chosenRole, position, "/calendar.jsp")) { %>
                <li>
                    <a href="${pageContext.request.contextPath}/calendar.jsp">
                        Calendar
                    </a>
                </li>
                <% } %>
            </ul>
        </li>

        <!-- Logout (always) -->
        <li class="logout-btn">
            <a href="${pageContext.request.contextPath}/logout.jsp">Logout</a>
        </li>
    </ul>
</nav>
