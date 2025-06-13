<%@ page contentType="text/html; charset=UTF-8" session="true" %>
<%@ page import="java.util.*, java.sql.Date, java.math.BigDecimal, java.time.LocalDate" %>
<%@ page import="All.PermissionChecker" %>

<%
    // Data from servlet
    @SuppressWarnings("unchecked")
    Map<String,Object> latestClub    = (Map<String,Object>) request.getAttribute("latestClub");
    @SuppressWarnings("unchecked")
    Map<String,Object> nextSession   = (Map<String,Object>) request.getAttribute("nextSession");
    @SuppressWarnings("unchecked")
    Map<String,Object> latestPass    = (Map<String,Object>) request.getAttribute("latestPass");
    @SuppressWarnings("unchecked")
    List<Map<String,Object>> tiers   = (List<Map<String,Object>>) request.getAttribute("allTiers");

    // Determine current pass tier or null
    Integer currentTier = latestPass != null
        ? (Integer) latestPass.get("tierId")
        : null;

    // Today for gating
    Date sqlToday = (Date) request.getAttribute("today");
    LocalDate today;
    if (sqlToday != null) {
        today = sqlToday.toLocalDate();
    } else {
        today = LocalDate.now();
    }

    // Club renewal gating
    Date startDate = (nextSession != null)
        ? (Date) nextSession.get("startMembershipDate")
        : null;
    boolean canRenewClub = startDate != null && !sqlToday.before(startDate);

    // Tab index
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
                            <td><%= latestClub != null ? latestClub.get("sessionName") : "-" %></td>
                            <td><%= latestClub != null ? "RM" + latestClub.get("fee") : "-" %></td>
                            <td><%= latestClub != null ? latestClub.get("purchaseDate") : "-" %></td>
                            <td><%= latestClub != null ? latestClub.get("expiryDate") : "-" %></td>
                            <td>
                                <% if (nextSession != null && nextSession.get("sessionId") != null) { %>
                                    <form action="checkout.jsp" method="get">
                                        <input type="hidden" name="type"        value="club"/>
                                        <input type="hidden" name="sessionId"   value="<%= nextSession.get("sessionId") %>" />
                                        <input type="hidden" name="sessionName" value="<%= nextSession.get("sessionName") %>" />
                                        <input type="hidden" name="fee"         value="<%= nextSession.get("fee") %>" />
                                        <button class="btn-renew" <%= canRenewClub ? "" : "disabled" %>>
                                            Renew
                                        </button>
                                    </form>
                                <% } else { %>
                                    <button class="btn-renew" disabled>
                                        No upcoming session
                                    </button>
                                <% } %>
                            </td>
                        </tr>

                        <!-- Monthly Gaming Pass row (unchanged) -->
                        <tr>
                            <td>Monthly Gaming Pass</td>
                            <td><%= latestPass != null ? latestPass.get("tierName") : "-" %></td>
                            <td>
                                <%= latestPass != null
                                    ? "RM" + ((BigDecimal) latestPass.get("price")).setScale(2)
                                    : "-" %>
                            </td>
                            <td><%= latestPass != null ? latestPass.get("purchaseDate") : "-" %></td>
                            <td><%= latestPass != null ? latestPass.get("expiryDate") : "-" %></td>
                            <td>
                                <% if (latestPass == null) { %>
                                    <form action="checkout.jsp" method="get">
                                        <input type="hidden" name="type"          value="pass"/>
                                        <input type="hidden" name="tierId"        value="<%= tiers.get(0).get("tierId") %>"/>
                                        <input type="hidden" name="tierName"      value="<%= tiers.get(0).get("tierName") %>"/>
                                        <input type="hidden" name="price"         value="<%= tiers.get(0).get("price") %>"/>
                                        <input type="hidden" name="currentExpiry" value="<%= sqlToday %>"/>
                                        <input type="hidden" name="planLength"    value="30"/>
                                        <button class="btn-buy">Buy</button>
                                    </form>
                                <% } else {
                                    LocalDate expiry = ((Date) latestPass.get("expiryDate")).toLocalDate();
                                    if (!today.isBefore(expiry)) { %>
                                        <form action="checkout.jsp" method="get">
                                            <input type="hidden" name="type"          value="pass"/>
                                            <input type="hidden" name="tierId"        value="<%= latestPass.get("tierId") %>"/>
                                            <input type="hidden" name="tierName"      value="<%= latestPass.get("tierName") %>"/>
                                            <input type="hidden" name="price"         value="<%= latestPass.get("price") %>"/>
                                            <input type="hidden" name="currentExpiry" value="<%= sqlToday %>"/>
                                            <input type="hidden" name="planLength"    value="30"/>
                                            <button class="btn-renew">Renew</button>
                                        </form>
                                    <% } else { %>
                                        <button class="btn-renew" disabled title="Renews on <%= expiry %>">
                                            Renew
                                        </button>
                                    <% }
                                } %>
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
                            <!-- ... your static benefit rows here ... -->
                            <tr>
                                <td></td>
                                <td>
                                    <% if (nextSession != null && nextSession.get("sessionId") != null) { %>
                                        <form action="checkout.jsp" method="get">
                                            <input type="hidden" name="type"        value="club"/>
                                            <input type="hidden" name="sessionId"   value="<%= nextSession.get("sessionId") %>" />
                                            <input type="hidden" name="sessionName" value="<%= nextSession.get("sessionName") %>" />
                                            <input type="hidden" name="fee"         value="<%= nextSession.get("fee") %>" />
                                            <button class="btn-renew" <%= canRenewClub ? "" : "disabled" %>>
                                                Renew Membership
                                            </button>
                                        </form>
                                    <% } else { %>
                                        <button class="btn-renew" disabled>
                                            No upcoming session
                                        </button>
                                    <% } %>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>

                <!-- Pass Panel (unchanged) -->
                <div id="panel-pass" class="panel">
                    <table class="benefits-table">
                        <!-- ... your pass‐benefits markup here ... -->
                    </table>
                </div>

            </div>  <!-- /.card -->
        </div>  <!-- /.content -->
    </div>  <!-- /.container -->

    <%@ include file="footer.jsp" %>

    <script>
        (function () {
            var tabs   = ['club','pass'], idx = 0,
                labels = document.querySelectorAll('.tab-label'),
                prev   = document.getElementById('prev'),
                next   = document.getElementById('next');

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
