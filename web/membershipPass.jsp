<%@page import="java.util.Map"%>
<%@ page import="java.time.*, java.time.format.DateTimeFormatter, java.sql.Date" %>
<%@ page contentType="text/html; charset=UTF-8" session="true" %>
<%
  // 0) Redirect here if someone loads the JSP directly OR isn't logged in
  if (session.getAttribute("username") == null
      || request.getAttribute("today") == null) {
    response.sendRedirect("manageMembershipPass");
    return;
  }

  // 1) Pull in all the attributes set by MembershipPassViewServlet
  @SuppressWarnings("unchecked")
  Map<String,Object> latestClub   = (Map<String,Object>) request.getAttribute("latestClub");
  @SuppressWarnings("unchecked")
  Map<String,Object> nextSession  = (Map<String,Object>) request.getAttribute("nextSession");
  @SuppressWarnings("unchecked")
  Map<String,Object> latestPass   = (Map<String,Object>) request.getAttribute("latestPass");
  @SuppressWarnings("unchecked")
  java.util.List<Map<String,Object>> allTiers =
      (java.util.List<Map<String,Object>>) request.getAttribute("allTiers");

  // 2) Compute “today” and renewal gating
  LocalDate today     = ((Date) request.getAttribute("today")).toLocalDate();
  LocalDate startDate = (nextSession != null)
                      ? ((Date)nextSession.get("startMembershipDate")).toLocalDate()
                      : null;
  boolean canRenew    = startDate != null && !today.isBefore(startDate);
  String startLabel   = (startDate != null)
                      ? startDate.format(DateTimeFormatter.ISO_DATE)
                      : "";
%>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Manage Membership &amp; Pass</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/styles.css">
</head>
<body>
  <jsp:include page="header.jsp"/>
  <button id="openToggle" class="open-toggle">☰</button>
  <div class="container">
    <div class="sidebar">
      <jsp:include page="sidebar.jsp"/>
    </div>

    <div class="content">
      <div class="card">
        <div class="card-header">
          <h1>Manage Membership &amp; Pass</h1>
        </div>

        <table class="summary-table">
          <thead>
            <tr>
              <th>Type</th><th>Tier/Session</th><th>Price (RM)</th>
              <th>Purchased</th><th>Expires</th><th>Action</th>
            </tr>
          </thead>
          <tbody>
            <!-- Club Membership -->
            <tr>
              <td>Club Membership</td>
              <% if (latestClub != null) { %>
              <td><%= latestClub.get("sessionName") %></td>
              <td>RM<%= latestClub.get("fee") %></td>
              <td><%= latestClub.get("purchaseDate") %></td>
              <td><%= latestClub.get("expiryDate") %></td>
              <td>
                <form action="checkout.jsp" method="get">
                  <input type="hidden" name="type"        value="club"/>
                  <input type="hidden" name="sessionId"   value="<%= nextSession.get("sessionId") %>"/>
                  <input type="hidden" name="sessionName" value="<%= nextSession.get("sessionName") %>"/>
                  <input type="hidden" name="fee"         value="<%= nextSession.get("fee") %>"/>
                  <button class="btn-renew"
                          <%= canRenew ? "" : "disabled" %>
                          title="<%= canRenew
                            ? ""
                            : "Renewals open on " + startLabel %>">
                    RENEW
                  </button>
                </form>
              </td>
              <% } else { %>
              <td colspan="6" style="text-align:center;">
                You have no active club membership.<br/>
                <form action="checkout.jsp" method="get">
                  <input type="hidden" name="type"        value="club"/>
                  <input type="hidden" name="sessionId"
                         value="<%= nextSession!=null ? nextSession.get("sessionId") : "" %>"/>
                  <input type="hidden" name="sessionName"
                         value="<%= nextSession!=null ? nextSession.get("sessionName") : "" %>"/>
                  <button class="btn-buy">BUY NOW</button>
                </form>
              </td>
              <% } %>
            </tr>

            <!-- Monthly Gaming Pass -->
            <tr>
              <td>Monthly Gaming Pass</td>
              <% if (latestPass != null) { %>
              <td><%= latestPass.get("tierName") %></td>
              <td>RM<%= latestPass.get("price") %></td>
              <td><%= latestPass.get("purchaseDate") %></td>
              <td><%= latestPass.get("expiryDate") %></td>
              <td>
                <form action="checkout.jsp" method="get">
                  <input type="hidden" name="type"   value="pass"/>
                  <input type="hidden" name="tierId" value="<%= latestPass.get("tierId") %>"/>
                  <input type="hidden" name="tierName"
                         value="<%= latestPass.get("tierName") %>"/>
                  <input type="hidden" name="price"
                         value="<%= latestPass.get("price") %>"/>
                  <button class="btn-renew">RENEW</button>
                </form>
              </td>
              <% } else { %>
              <td colspan="6" style="text-align:center;">
                You have no active gaming pass.<br/>
                <form action="checkout.jsp" method="get">
                  <input type="hidden" name="type" value="pass"/>
                  <select name="tierId" required>
                    <% for (Map<String,Object> t : allTiers) { %>
                    <option value="<%= t.get("tierId") %>">
                      <%= t.get("tierName") %> – RM<%= t.get("price") %>
                      (Disc <%= t.get("discountRate") %>%)
                    </option>
                    <% } %>
                  </select>
                  <button class="btn-buy">BUY NOW</button>
                </form>
              </td>
              <% } %>
            </tr>

          </tbody>
        </table>
      </div>
    </div>
  </div>
  <jsp:include page="footer.jsp"/>
</body>
</html>
