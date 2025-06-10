<%@ page import="java.util.*, java.sql.Date" %>
<%@ page contentType="text/html; charset=UTF-8" session="true"%>
<%
    if (session.getAttribute("username") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    @SuppressWarnings("unchecked")
    Map<String, Object> latestClub = (Map<String, Object>) request.getAttribute("latestClub");
    @SuppressWarnings("unchecked")
    Map<String, Object> currentClubSession = (Map<String, Object>) request.getAttribute("currentClubSession");
    @SuppressWarnings("unchecked")
    Map<String, Object> latestPass = (Map<String, Object>) request.getAttribute("latestPass");
    @SuppressWarnings("unchecked")
    List<Map<String, Object>> allTiers = (List<Map<String, Object>>) request.getAttribute("allTiers");
    Date today = (Date) request.getAttribute("today");
%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Manage Membership &amp; Pass</title>
        <link rel="stylesheet" href="styles.css">
        <style>
            .tab-btn{
                font-size:24px;
                cursor:pointer;
                color:gray;
                margin:0 16px;
            }
            .tab-btn.active{
                color:black;
            }
            .panel{
                display:none;
                background:#fff;
                padding:20px;
                border-radius:8px;
                box-shadow:0 2px 6px rgba(0,0,0,0.1);
            }
            .panel.active{
                display:block;
            }
        </style>
    </head>
    <body>
        <jsp:include page="header.jsp"/>
        <button id="openToggle" class="open-toggle">☰</button>
        <div class="container">
            <div class="sidebar">
                <button id="closeToggle" class="close-toggle">×</button>
                <jsp:include page="sidebar.jsp"/>
            </div>
            <div class="content">
                <h1>Manage Membership &amp; Pass</h1>
                <div style="text-align:center;margin:16px 0;">
                    <span id="btn-pass" class="tab-btn active">&lt;</span>
                    <strong id="tab-title">Monthly Gaming Pass</strong>
                    <span id="btn-club" class="tab-btn">&gt;</span>
                </div>

                <!-- PASS PANEL -->
                <div id="panel-pass" class="panel active">
                    <table class="pass-table">
                        <tr><th>Tier</th><th>Price</th><th>Disc %</th>
                            <th>Purchased</th><th>Expires</th><th>Action</th></tr>
                        <tr>
                            <% if (latestPass != null) {%>
                            <td><%=latestPass.get("tierName")%></td>
                            <td>RM<%=latestPass.get("price")%></td>
                            <td><%=latestPass.get("discountRate")%></td>
                            <td><%=latestPass.get("purchaseDate")%></td>
                            <td><%=latestPass.get("expiryDate")%></td>
                            <td>
                                <form action="checkout.jsp" method="get">
                                    <input type="hidden" name="type"         value="pass"/>
                                    <input type="hidden" name="tierId"       value="<%=latestPass.get("tierId")%>"/>
                                    <input type="hidden" name="tierName"     value="<%=latestPass.get("tierName")%>"/>
                                    <input type="hidden" name="price"        value="<%=latestPass.get("price")%>"/>
                                    <input type="hidden" name="discountRate" value="<%=latestPass.get("discountRate")%>"/>
                                    <button class="renewBtn">RENEW</button>
                                </form>
                            </td>
                            <% } else { %>
                            <td colspan="5">You have no active pass.</td>
                            <td>
                                <form action="checkout.jsp" method="get">
                                    <input type="hidden" name="type" value="pass"/>
                                    <select name="tierId" required>
                                        <% for (Map<String, Object> t : allTiers) {%>
                                        <option value="<%=t.get("tierId")%>">
                                            <%=t.get("tierName")%> – RM<%=t.get("price")%>
                                            (Disc <%=t.get("discountRate")%>%)
                                        </option>
                                        <% } %>
                                    </select>
                                    <button class="renewBtn">BUY NOW</button>
                                </form>
                            </td>
                            <% } %>
                        </tr>
                    </table>
                    <h3 style="margin-top:24px;">PASS BENEFITS</h3>
                    <table class="benefitsTable">
                        <tr><th>Benefit</th><th>Essential</th><th>Extra</th><th>Premium</th></tr>
                        <tr><td>Discount/Hour</td><td>10%</td><td>30%</td><td>50%</td></tr>
                        <tr><td>No Fees</td><td>❌</td><td>✅</td><td>✅</td></tr>
                        <tr><td>Priority</td><td>❌</td><td>✅</td><td>✅</td></tr>
                        <tr><td>Free Hrs/Mon</td><td>❌</td><td>1</td><td>2</td></tr>
                        <tr><td>Guest Pass</td><td>❌</td><td>❌</td><td>1/session</td></tr>
                        <tr><td>Price</td><td>RM30</td><td>RM60</td><td>RM110</td></tr>
                    </table>
                </div>

                <!-- CLUB PANEL -->
                <div id="panel-club" class="panel">
                    <table class="membership-table">
                        <tr><th>Session</th><th>Fee (RM)</th>
                            <th>Purchased</th><th>Expires</th><th>Action</th></tr>
                        <tr>
                            <% if (latestClub != null) {%>
                            <td><%=latestClub.get("sessionName")%></td>
                            <td><%=latestClub.get("fee")%></td>
                            <td><%=latestClub.get("purchaseDate")%></td>
                            <td><%=latestClub.get("expiryDate")%></td>
                            <td>
                                <form action="checkout.jsp" method="get">
                                    <input type="hidden" name="type"        value="club"/>
                                    <input type="hidden" name="sessionId"   value="<%=latestClub.get("sessionId")%>"/>
                                    <input type="hidden" name="sessionName" value="<%=latestClub.get("sessionName")%>"/>
                                    <input type="hidden" name="fee"         value="<%=latestClub.get("fee")%>"/>
                                    <input type="hidden" name="expiryDate"  value="<%=latestClub.get("expiryDate")%>"/>
                                    <button class="renewBtn">RENEW</button>
                                </form>
                            </td>
                            <% } else if (currentClubSession != null) {%>
                            <td colspan="5">Not a member yet. Buy below:</td>
                        </tr><tr>
                            <td><%=currentClubSession.get("sessionName")%></td>
                            <td><%=currentClubSession.get("fee")%></td>
                            <td>—</td><td>—</td>
                            <td>
                                <form action="checkout.jsp" method="get">
                                    <input type="hidden" name="type"        value="club"/>
                                    <input type="hidden" name="sessionId"   value="<%=currentClubSession.get("sessionId")%>"/>
                                    <input type="hidden" name="sessionName" value="<%=currentClubSession.get("sessionName")%>"/>
                                    <input type="hidden" name="fee"         value="<%=currentClubSession.get("fee")%>"/>
                                    <input type="hidden" name="expiryDate"  value="<%=currentClubSession.get("expiryDate")%>"/>
                                    <button class="renewBtn">BUY NOW</button>
                                </form>
                            </td>
                            <% } else { %>
                            <td colspan="5"><em>No session available.</em></td>
                            <% }%>
                        </tr>
                    </table>
                    <h3 style="margin-top:24px;">CLUB BENEFITS</h3>
                    <table class="benefitsTable">
                        <tr><th>Benefit</th><th>Detail</th></tr>
                        <tr><td>5% Store Off</td><td>All purchases</td></tr>
                        <tr><td>Club Events</td><td>Priority invites</td></tr>
                        <tr><td>Newsletter</td><td>Email updates</td></tr>
                        <tr><td>Guest Pass</td><td>1/semester</td></tr>
                    </table>
                </div>
            </div>
        </div>
        <jsp:include page="footer.jsp"/>
        <script>
            var btnP = document.getElementById('btn-pass'),
                    btnC = document.getElementById('btn-club'),
                    panP = document.getElementById('panel-pass'),
                    panC = document.getElementById('panel-club'),
                    title = document.getElementById('tab-title');
            btnP.onclick = function () {
                panP.classList.add('active');
                panC.classList.remove('active');
                btnP.classList.add('active');
                btnC.classList.remove('active');
                title.textContent = 'Monthly Gaming Pass';
            };
            btnC.onclick = function () {
                panC.classList.add('active');
                panP.classList.remove('active');
                btnC.classList.add('active');
                btnP.classList.remove('active');
                title.textContent = 'Club Membership';
            };
            document.getElementById('openToggle')
                    .addEventListener('click', function () {
                        document.body.classList.remove('sidebar-collapsed');
                    });
            document.getElementById('closeToggle')
                    .addEventListener('click', function () {
                        document.body.classList.add('sidebar-collapsed');
                    });
        </script>
    </body>
</html>
