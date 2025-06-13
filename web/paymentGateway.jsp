<%@page import="All.PermissionChecker"%>
<%@ page import="java.util.*" %>
<%@ page contentType="text/html; charset=UTF-8" session="true" %>
<%
    // 1) Auth + RBAC
    HttpSession sessionObj = request.getSession(false);
    if (sessionObj == null || sessionObj.getAttribute("username") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    @SuppressWarnings("unchecked")
    List<String> roles = (List<String>) sessionObj.getAttribute("effectiveRoles");
    String role = (String) sessionObj.getAttribute("role"),
            position = (String) sessionObj.getAttribute("position");
    // assume PermissionChecker.hasAccess(...) works for all
    if (roles == null || !PermissionChecker.hasAccess(roles, role, position, "/paymentGateway.jsp")) {
        response.sendRedirect("accessDenied.jsp");
        return;
    }

    // 2) Detect flow by parameters
    boolean isBooking = request.getParameter("stationID") != null;
    boolean isClub = "club".equals(request.getParameter("type"));
    boolean isPass = "pass".equals(request.getParameter("type"));

    String title;
    if (isBooking) {
        title = "Station Booking Payment";
    } else if (isClub) {
        title = "Club Membership Payment";
    } else if (isPass) {
        title = "Monthly Pass Payment";
    } else {
        title = "Payment";
    }

    // 3) Copy all incoming params so we can re-POST them as hidden fields
    Map<String, String[]> params = request.getParameterMap();
%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title><%=title%> – NexGen Esports</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/styles.css">
    </head>
    <body>
        <%@ include file="header.jsp" %>
        <div class="container">
            <div class="sidebar"><jsp:include page="sidebar.jsp"/></div>
            <div class="content">
                <div class="payment-container">
                    <h2><%=title%></h2>
                    <p class="note">Please enter your mock card details.</p>

                    <!-- Optionally show a summary -->
                    <div class="summary">
                        <% if (isBooking) {%>
                        <p><strong>Station:</strong> <%=request.getParameter("stationName")%></p>
                        <p><strong>Date:</strong>    <%=request.getParameter("date")%></p>
                        <p><strong>Players:</strong> <%=request.getParameter("playerCount")%></p>
                        <% } else if (isClub) {%>
                        <p><strong>Membership:</strong> <%=request.getParameter("sessionName")%></p>
                        <p><strong>Price:</strong> RM<%=request.getParameter("fee")%></p>
                        <% } else if (isPass) {%>
                        <p><strong>Pass Tier:</strong> <%=request.getParameter("tierName")%></p>
                        <p><strong>Price:</strong> RM<%=request.getParameter("price")%></p>
                        <% } %>
                    </div>

                    <!-- 4) Mock payment form → confirmPayment -->
                    <form method="POST" action="${pageContext.request.contextPath}/confirmPayment">
                        <%-- replay all incoming params as hidden --%>
                        <% for (String key : params.keySet()) {
                                for (String v : params.get(key)) {%>
                        <input type="hidden" name="<%=key%>" value="<%=v%>"/>
                        <% }
                            }%>

                        <!-- Card Logos -->
                        <div class="card-logos">
                            <img src="https://upload.wikimedia.org/wikipedia/commons/4/41/Visa_Logo.png" alt="Visa">
                            <img src="https://upload.wikimedia.org/wikipedia/commons/0/04/Mastercard-logo.png" alt="Mastercard">
                            <img src="https://upload.wikimedia.org/wikipedia/commons/3/30/Amex-logo.png" alt="Amex">
                        </div>

                        <!-- Card Fields -->
                        <label>Card Number</label>
                        <input type="text" name="cardNumber" required maxlength="16"/>

                        <label>Name on Card</label>
                        <input type="text" name="cardName" required/>

                        <div class="half">
                            <label>Expiry (MM/YY)</label>
                            <input type="month" name="expiryDate" required
                                   min="<%= java.time.YearMonth.now().toString()%>"/>
                        </div>
                        <div class="half">
                            <label>CVV</label>
                            <input type="text" name="cvv" required/>
                        </div>

                        <div class="buttons">
                            <button type="submit" class="btn-submit">Submit Payment</button>
                            <a href="<%= isBooking
                                    ? "checkoutBook.jsp"
                                    : (isClub ? "checkout.jsp?type=club"
                                            : "checkout.jsp?type=pass")%>"
                               class="btn-back">Cancel</a>
                        </div>
                    </form>
                </div>
            </div>
        </div>
        <%@ include file="footer.jsp" %>
    </body>
</html>
