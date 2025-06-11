<%@ page contentType="text/html; charset=UTF-8" session="true" %>
<%@ page import="java.util.*, java.sql.Date, java.math.BigDecimal, java.time.LocalDate" %>
<%@ page import="All.PermissionChecker" %>
<%
  // Data from servlet
  @SuppressWarnings("unchecked")
  Map<String,Object> latestClub   = (Map<String,Object>) request.getAttribute("latestClub");
  Map<String,Object> nextSession  = (Map<String,Object>) request.getAttribute("nextSession");
  @SuppressWarnings("unchecked")
  Map<String,Object> latestPass   = (Map<String,Object>) request.getAttribute("latestPass");
  @SuppressWarnings("unchecked")
  List<Map<String,Object>> tiers  = (List<Map<String,Object>>) request.getAttribute("allTiers");

  // Determine current pass tier or null
  Integer currentTier = latestPass!=null
                      ? (Integer)latestPass.get("tierId")
                      : null;

  // Club renewal gating
  Date sqlToday   = (Date) request.getAttribute("today");
  LocalDate today = sqlToday.toLocalDate();
  Date startDate  = nextSession!=null
                  ? (Date) nextSession.get("startMembershipDate")
                  : null;
  boolean canRenewClub = startDate!=null && ! sqlToday.before(startDate);

  // Tab index: 0=club, 1=pass
  int idx = 0;
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Manage Membership &amp; Pass – NexGen Esports</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/styles.css">
</head>
<body class="manage-membership-page">
  <%@ include file="header.jsp" %>
  <button id="openToggle" class="open-toggle">☰</button>

  <div class="container">
    <div class="sidebar"><jsp:include page="sidebar.jsp"/></div>
    <div class="content">
      <div class="card">
        <!-- Header -->
        <div class="card-header">
          <h1>Manage Membership &amp; Pass</h1>
        </div>

        <!-- Summary Table -->
        <table class="summary-table">
          <thead>
            <tr>
              <th>Type</th><th>Tier/Session</th><th>Price (RM)</th>
              <th>Purchased</th><th>Expires</th><th>Action</th>
            </tr>
          </thead>
          <tbody>
            <!-- Club Membership row -->
            <tr>
              <td>Club Membership</td>
              <td><%= latestClub!=null ? latestClub.get("sessionName") : "-" %></td>
              <td><%= latestClub!=null ? "RM"+latestClub.get("fee") : "-" %></td>
              <td><%= latestClub!=null ? latestClub.get("purchaseDate") : "-" %></td>
              <td><%= latestClub!=null ? latestClub.get("expiryDate") : "-" %></td>
              <td>
                <form action="checkout.jsp" method="get">
                  <input type="hidden" name="type"      value="club"/>
                  <input type="hidden" name="sessionId" value="<%= nextSession.get("sessionId") %>"/>
                  <input type="hidden" name="sessionName" value="<%= nextSession.get("sessionName") %>"/>
                  <input type="hidden" name="fee"        value="<%= nextSession.get("fee") %>"/>
                  <button class="btn-renew" <%= canRenewClub? "" : "disabled" %>>Renew</button>
                </form>
              </td>
            </tr>
            <!-- Monthly Gaming Pass row -->
            <tr>
              <td>Monthly Gaming Pass</td>
              <td><%= latestPass!=null ? latestPass.get("tierName") : "-" %></td>
              <td>
                <%= latestPass!=null
                   ? "RM" + ((BigDecimal)latestPass.get("price")).setScale(2)
                   : "-" %>
              </td>
              <td><%= latestPass!=null ? latestPass.get("purchaseDate") : "-" %></td>
              <td><%= latestPass!=null ? latestPass.get("expiryDate")   : "-" %></td>
              <td>
                <%
                  if (latestPass == null) {
                %>
                <form action="checkout.jsp" method="get">
                  <input type="hidden" name="type"          value="pass"/>
                  <input type="hidden" name="tierId"        value="<%= tiers.get(0).get("tierId") %>"/>
                  <input type="hidden" name="tierName"      value="<%= tiers.get(0).get("tierName") %>"/>
                  <input type="hidden" name="price"         value="<%= tiers.get(0).get("price") %>"/>
                  <input type="hidden" name="currentExpiry" value="<%= sqlToday %>"/>
                  <input type="hidden" name="planLength"    value="30"/>
                  <button class="btn-buy">Buy</button>
                </form>
                <%
                  } else {
                    LocalDate expiry = ((Date)latestPass.get("expiryDate")).toLocalDate();
                    if (!today.isBefore(expiry)) {
                %>
                <form action="checkout.jsp" method="get">
                  <input type="hidden" name="type"          value="pass"/>
                  <input type="hidden" name="tierId"        value="<%= latestPass.get("tierId")   %>"/>
                  <input type="hidden" name="tierName"      value="<%= latestPass.get("tierName") %>"/>
                  <input type="hidden" name="price"         value="<%= latestPass.get("price")    %>"/>
                  <input type="hidden" name="currentExpiry" value="<%= sqlToday %>"/>
                  <input type="hidden" name="planLength"    value="30"/>
                  <button class="btn-renew">Renew</button>
                </form>
                <%
                    } else {
                %>
                <button class="btn-renew" disabled title="Renews on <%= expiry %>">
                  Renew
                </button>
                <%
                    }
                  }
                %>
              </td>
            </tr>
          </tbody>
        </table>

        <!-- Two‐Label Nav -->
        <div class="tab-switcher">
          <div id="prev" class="tab-btn">&lt;</div>
          <div id="lbl-club" class="tab-label active" data-tab="club">
            Club Membership
          </div>
          <div id="lbl-pass" class="tab-label" data-tab="pass">
            Gaming Pass
          </div>
          <div id="next" class="tab-btn">&gt;</div>
        </div>

        <!-- Club Panel -->
        <div id="panel-club" class="panel active">
          <table class="benefits-table club">
            <thead>
              <tr><th>#</th><th>Benefit</th></tr>
            </thead>
            <tbody>
              <tr><td>1</td><td>Receive 5% discount on all online purchases.</td></tr>
              <tr><td>2</td><td>Eligible to nominate for the Esports Club Executive Council (24/25).</td></tr>
              <tr><td>3</td><td>Eligible to vote in Supreme Council nominations.</td></tr>
              <tr><td>4</td><td>Become a member of the Game Community.</td></tr>
              <tr><td>5</td><td>Opportunity to represent UMT Esports Club in external tournaments.</td></tr>
              <tr><td>6</td><td>Access to training platforms and scrimmages.</td></tr>
              <tr><td>7</td><td>Member pricing for all major programs &amp; tournaments organized by UMT Esports Club.</td></tr>
              <tr><td>8</td><td>Opportunity to serve on committees for UMT Esports Club events.</td></tr>
              <tr><td>9</td><td>Privileged access to the Esports Gaming Room.</td></tr>
              <tr>
                <td></td>
                <td>
                  <form action="checkout.jsp" method="get">
                    <input type="hidden" name="type"        value="club"/>
                    <input type="hidden" name="sessionId"   value="<%= nextSession.get("sessionId") %>"/>
                    <input type="hidden" name="sessionName" value="<%= nextSession.get("sessionName") %>"/>
                    <input type="hidden" name="fee"         value="<%= nextSession.get("fee") %>"/>
                    <button class="btn-renew" <%= canRenewClub? "" : "disabled"%>>
                      Renew Membership
                    </button>
                  </form>
                </td>
              </tr>
            </tbody>
          </table>
        </div>

        <!-- Pass Panel -->
        <div id="panel-pass" class="panel">
          <table class="benefits-table">
            <thead>
              <tr><th>Benefits</th>
                  <th>Essential</th>
                  <th>Extra</th>
                  <th>Premium</th></tr>
            </thead>
            <tbody>
              <tr><td>Discount Per Hour</td><td>10%</td><td>30%</td><td>50%</td></tr>
              <tr><td>No Booking Fees</td><td>✗</td><td>✓</td><td>✓</td></tr>
              <tr><td>Priority Booking</td><td>✗</td><td>✓</td><td>✓</td></tr>
              <tr><td>Free Hours Per Month</td><td>✗</td><td>1 Hour</td><td>2 Hours</td></tr>
              <tr><td>Friends Pass</td><td>✗</td><td>✗</td><td>1 Guest Free/Session</td></tr>
              <tr><td>Price</td>
                <% for (Map<String,Object> tier : tiers) { %>
                  <td>RM<%= ((BigDecimal)tier.get("price")).setScale(2) %></td>
                <% } %>
              </tr>
              <tr>
                <td></td>
                <% for (Map<String,Object> tier : tiers) {
                     Integer id   = (Integer) tier.get("tierId");
                     String  nm   = (String)  tier.get("tierName");
                     BigDecimal pr= (BigDecimal) tier.get("price");
                %>
                <td>
                  <% if (currentTier == null) { %>
                    <form action="checkout.jsp" method="get">
                      <input type="hidden" name="type"          value="pass"/>
                      <input type="hidden" name="tierId"        value="<%= id %>"/>
                      <input type="hidden" name="tierName"      value="<%= nm %>"/>
                      <input type="hidden" name="price"         value="<%= pr %>"/>
                      <input type="hidden" name="currentExpiry" value="<%= sqlToday %>"/>
                      <input type="hidden" name="planLength"    value="30"/>
                      <button class="btn-buy">Buy</button>
                    </form>
                  <% } else if (id > currentTier) { %>
                    <form action="checkout.jsp" method="get">
                      <input type="hidden" name="type"          value="pass"/>
                      <input type="hidden" name="tierId"        value="<%= id %>"/>
                      <input type="hidden" name="tierName"      value="<%= nm %>"/>
                      <input type="hidden" name="price"         value="<%= pr %>"/>
                      <input type="hidden" name="currentExpiry" value="<%= ((Date)latestPass.get("expiryDate")) %>"/>
                      <input type="hidden" name="planLength"    value="30"/>
                      <button class="btn-buy">Upgrade</button>
                    </form>
                  <% } else if (id.equals(currentTier)) { %>
                    <button class="btn-renew" disabled>Current</button>
                  <% } else { %>
                    <button class="btn-renew" disabled title="Available after expiry">Locked</button>
                  <% } %>
                </td>
                <% } %>
              </tr>
            </tbody>
          </table>
        </div>

      </div>  <!-- /.card -->
    </div>  <!-- /.content -->
  </div>  <!-- /.container -->

  <%@ include file="footer.jsp" %>

  <script>
    (function(){
      var idx = 0;
      var tabs = ['club','pass'];
      var labels = document.querySelectorAll('.tab-label');
      var prev = document.getElementById('prev'),
          next = document.getElementById('next');

      function update() {
        tabs.forEach(function(t,i){
          document.getElementById('panel-'+t)
                  .classList.toggle('active', i===idx);
          labels[i].classList.toggle('active', i===idx);
        });
        prev.classList.toggle('disabled', idx===0);
        next.classList.toggle('disabled', idx===tabs.length-1);
      }

      prev.onclick = function(){ if(idx>0){ idx--; update(); } };
      next.onclick = function(){ if(idx<tabs.length-1){ idx++; update(); } };
      labels.forEach(function(lbl,i){ lbl.onclick = function(){ idx=i; update(); }; });

      update();
    })();
  </script>
</body>
</html>
