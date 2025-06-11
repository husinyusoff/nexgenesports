<%@ page language="java"
         contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>
<%@ page session="true" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>
            <%= "booking".equals(request.getParameter("type")) ? "BOOKING PAYMENT"
            : "club".equals(request.getParameter("type")) ? "CLUB MEMBERSHIP PAYMENT"
            : "MONTHLY PASS PAYMENT"%>
            – NexGen Esports
        </title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/styles.css">
    </head>
    <body>
        <%@ include file="header.jsp" %>

        <div class="container">
            <div class="sidebar"><%@ include file="sidebar.jsp" %></div>
            <div class="content">
                <div class="payment-container">
                    <h2>
                        <%= "booking".equals(request.getParameter("type")) ? "BOOKING PAYMENT"
                  : "club".equals(request.getParameter("type")) ? "CLUB MEMBERSHIP PAYMENT"
                  : "MONTHLY PASS PAYMENT"%>
                    </h2>

                    <div class="summary">
                        <%
                            String type = request.getParameter("type");
                            if ("booking".equals(type)) {
                                out.write("<p><strong>Station:</strong>  " + request.getParameter("stationName") + "</p>");
                                out.write("<p><strong>Date:</strong>     " + request.getParameter("date") + "</p>");
                                out.write("<p><strong>Players:</strong>  " + request.getParameter("playerCount") + "</p>");
                                out.write("<p><strong>Amount:</strong>   RM" + request.getParameter("totalPrice") + "</p>");
                            } else if ("club".equals(type)) {
                                out.write("<p><strong>Membership:</strong> " + request.getParameter("sessionName") + "</p>");
                                out.write("<p><strong>Fee:</strong>        RM" + request.getParameter("fee") + "</p>");
                            } else {
                                out.write("<p><strong>Pass Tier:</strong>  " + request.getParameter("tierName") + "</p>");
                                out.write("<p><strong>Amount:</strong>     RM" + request.getParameter("price") + "</p>");
                            }
                        %>
                    </div>

                    <form method="post" action="confirmPayment">
                        <%
                            // replay all incoming params
                            for (String key : request.getParameterMap().keySet()) {
                                for (String val : request.getParameterValues(key)) {
                                    out.write(
                                            "<input type=\"hidden\" name=\"" + key
                                            + "\" value=\"" + val + "\"/>\n"
                                    );
                                }
                            }
                        %>

                        <!-- Mock card fields -->
                        <div class="card-logos">
                            <img src="https://upload.wikimedia.org/wikipedia/commons/4/41/Visa_Logo.png" alt="Visa">
                            <img src="https://upload.wikimedia.org/wikipedia/commons/0/04/Mastercard-logo.png" alt="Mastercard">
                            <img src="https://upload.wikimedia.org/wikipedia/commons/3/30/Amex-logo.png" alt="Amex">
                        </div>

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
                            <input type="text" name="cvv" required maxlength="4"/>
                        </div>

                        <div class="buttons">
                            <button type="submit" class="btn-submit">SUBMIT PAYMENT</button>
                            <a href="checkout.jsp?type=<%=request.getParameter("type")%>"
                               class="btn-back">CANCEL</a>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <%@ include file="footer.jsp" %>
    </body>
</html>
