<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true" %>
<%@ page import="java.util.List" %>
<%@ page import="All.PermissionChecker" %>

<%
    @SuppressWarnings("unchecked")
    List<String> roles       = (List<String>) session.getAttribute("effectiveRoles");
    String       chosenRole  = (String) session.getAttribute("role");
    String       position    = (String) session.getAttribute("position");
    if (roles == null || chosenRole == null) {
        return;  // nothing to render if not logged in
    }
    String ctx = request.getContextPath();  // ← use the implicit request
%>
<nav>
  <ul>
    <!-- Dashboard -->
    <li><a href="<%=ctx%>/dashboard.jsp">Dashboard</a></li>

    <!-- Profile -->
    <li class="dropdown">
      <a href="javascript:void(0)" class="dropdown-btn">Profile</a>
      <ul class="dropdown-content">
        <li><a href="<%=ctx%>/manageProfile.jsp">My Profile</a></li>
        <% if (PermissionChecker.hasAccess(roles, chosenRole, position, "/inGameProfile")) { %>
          <li><a href="<%=ctx%>/inGameProfile">In-Game Profile</a></li>
        <% } %>
        <li><a href="<%=ctx%>/manageMembershipPass">Membership &amp; Pass</a></li>
      </ul>
    </li>

    <!-- Multiplayer Lounge -->
    <li class="dropdown">
      <a href="javascript:void(0)" class="dropdown-btn">Multiplayer Lounge</a>
      <ul class="dropdown-content">
        <% if (PermissionChecker.hasAccess(roles, chosenRole, position, "/selectStation.jsp")) { %>
          <li><a href="<%=ctx%>/selectStation.jsp">Book Gaming Session</a></li>
        <% } %>
        <% if (PermissionChecker.hasAccess(roles, chosenRole, position, "/manageBooking.jsp")) { %>
          <li><a href="<%=ctx%>/manageBooking.jsp">Manage My Booking</a></li>
        <% } %>
        <% if (PermissionChecker.hasAccess(roles, chosenRole, position, "/manageAllBooking.jsp")) { %>
          <li><a href="<%=ctx%>/manageAllBooking.jsp">Manage All Booking</a></li>
        <% } %>
      </ul>
    </li>

    <!-- Team Management -->
    <% if (PermissionChecker.hasAccess(roles, chosenRole, position, "/team")) { %>
      <li><a href="<%=ctx%>/team">Team Management</a></li>
    <% } %>

    <!-- Notifications -->
    <% if (PermissionChecker.hasAccess(roles, chosenRole, position, "/notifications")) { %>
      <li><a href="<%=ctx%>/notifications">Notifications</a></li>
    <% } %>

    <!-- Audit Log -->
    <% if (PermissionChecker.hasAccess(roles, chosenRole, position, "/auditLog")) { %>
      <li><a href="<%=ctx%>/auditLog">Audit Log</a></li>
    <% } %>

    <!-- Logout -->
    <li class="logout-btn"><a href="<%=ctx%>/logout.jsp">Logout</a></li>
  </ul>
</nav>
