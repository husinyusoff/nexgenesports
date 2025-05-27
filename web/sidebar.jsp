<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, All.PermissionChecker" %>
<%@ page session="true" %>
<%--
  SIDEBAR.JSP
  ===========
  * Pulls “effectiveRoles” (List<String>) and “position” from the session.
  * Uses PermissionChecker.hasAccess(roles, position, "/somePage.jsp") 
    to gate individual links.
  * Renders in this order:
      1) Dashboard
      2) Profile (outer dropdown)
         - My Profile (always)
         - In-Game Profile (only if page-level permitted)
      3) Multiplayer Lounge (outer dropdown)
         - Book Gaming Session
         - Manage Booking
         - Manage All Booking (only if user.position == "president")
         - Calendar
      4) … (you can append more links or dropdowns here)
      5) Logout
--%>
<%
  @SuppressWarnings("unchecked")
  List<String> roles    = (List<String>) session.getAttribute("effectiveRoles");
  String        position = (String) session.getAttribute("position");
  if (roles == null) {
    // no session → no sidebar
    return;
  }
%>

<nav>
  <ul>
    <!-- 1) Dashboard (always) -->
    <li>
      <a href="${pageContext.request.contextPath}/dashboard.jsp">
        Dashboard
      </a>
    </li>

    <!-- 2) Profile dropdown -->
    <li class="dropdown">
      <a href="javascript:void(0)" class="dropdown-btn">Profile</a>
      <ul class="dropdown-content">
        <!-- 2a) My Profile (everyone) -->
        <li>
          <a href="${pageContext.request.contextPath}/manageProfile.jsp">
            My Profile
          </a>
        </li>
        <!-- 2b) In-Game Profile (if allowed) -->
        <% if (PermissionChecker.hasAccess(roles, position, "/inGameProfile.jsp")) { %>
        <li>
          <a href="${pageContext.request.contextPath}/inGameProfile.jsp">
            In-Game Profile
          </a>
        </li>
        <% } %>
      </ul>
    </li>

    <!-- 3) Multiplayer Lounge dropdown -->
    <li class="dropdown">
      <a href="javascript:void(0)" class="dropdown-btn">Multiplayer Lounge</a>
      <ul class="dropdown-content">
        <!-- 3a) Book Gaming Session -->
        <% if (PermissionChecker.hasAccess(roles, position, "/bookStation.jsp")) { %>
        <li>
          <a href="${pageContext.request.contextPath}/bookStation.jsp">
            Book Gaming Session
          </a>
        </li>
        <% } %>
        <!-- 3b) Manage Booking -->
        <% if (PermissionChecker.hasAccess(roles, position, "/manageBooking.jsp")) { %>
        <li>
          <a href="${pageContext.request.contextPath}/manageBooking.jsp">
            Manage Booking
          </a>
        </li>
        <% } %>
        <!-- 3c) Manage All Booking (president only) -->
        <% if ("president".equals(position)
            && PermissionChecker.hasAccess(roles, position, "/manageAllBooking.jsp")) { %>
        <li>
          <a href="${pageContext.request.contextPath}/manageAllBooking.jsp">
            Manage All Booking
          </a>
        </li>
        <% } %>
        <!-- 3d) Calendar (if allowed) -->
        <% if (PermissionChecker.hasAccess(roles, position, "/calendar.jsp")) { %>
        <li>
          <a href="${pageContext.request.contextPath}/calendar.jsp">
            Calendar
          </a>
        </li>
        <% } %>
      </ul>
    </li>

 

    <!-- 5) Logout (always) -->
    <li>
      <a href="${pageContext.request.contextPath}/logout.jsp" class="logout-btn">
        Logout
      </a>
    </li>
  </ul>
</nav>
