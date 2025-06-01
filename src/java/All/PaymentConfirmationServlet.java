import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import All.DBConnection;

@WebServlet("/confirmPayment")
public class PaymentConfirmationServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // 1) Ensure user is logged in
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("username") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        // 2) Read hidden booking parameters
        String stationID      = request.getParameter("stationID");
        String stationName    = request.getParameter("stationName");
        String dateStr        = request.getParameter("date");
        String playerCountStr = request.getParameter("playerCount");
        String totalPriceStr  = request.getParameter("totalPrice");
        String[] timesArr     = request.getParameterValues("timeSlots");

        if (stationID == null || stationName == null
            || dateStr == null || playerCountStr == null
            || totalPriceStr == null || timesArr == null || timesArr.length == 0) {
            // Missing data → go back or show error
            response.setContentType("text/html");
            response.getWriter().println(
                "<p style='color:red;'>Missing payment details. Please go back to Checkout.</p>");
            return;
        }

        // 3) Parse numeric fields
        int playerCount;
        try {
            playerCount = Integer.parseInt(playerCountStr.trim());
        } catch (NumberFormatException e) {
            playerCount = 1;
        }

        double totalPrice;
        try {
            totalPrice = Double.parseDouble(totalPriceStr.trim());
        } catch (NumberFormatException e) {
            totalPrice = 0.0;
        }

        LocalDate selectedDate;
        try {
            selectedDate = LocalDate.parse(dateStr.trim());
        } catch (Exception e) {
            response.setContentType("text/html");
            response.getWriter().println("<p style='color:red;'>Invalid date format.</p>");
            return;
        }

        // 4) Build sorted list of hours
        List<Integer> hours = new ArrayList<>();
        for (String hr : timesArr) {
            try {
                hours.add(Integer.parseInt(hr.trim()));
            } catch (NumberFormatException ignore) {
            }
        }
        if (hours.isEmpty()) {
            response.setContentType("text/html");
            response.getWriter().println("<p style='color:red;'>No valid times selected.</p>");
            return;
        }
        Collections.sort(hours);
        int startHour = hours.get(0);
        int endHour   = hours.get(hours.size() - 1);
        int hourCount = hours.size();

        // 5) Determine openingHour logic again (Sun–Thu=14; Fri/Sat=15)
        DayOfWeek dow = selectedDate.getDayOfWeek();
        int openingHour = (dow == DayOfWeek.FRIDAY || dow == DayOfWeek.SATURDAY) 
                          ? 15 : 14;

        // 6) Determine priceType for record (we trust totalPrice passed from Checkout)
        String priceType = (startHour >= openingHour && startHour < 19) 
                           ? "HappyHour" 
                           : "Normal";

        // 7) Insert booking row
        String userID = (String) session.getAttribute("username");
        String insertSQL = "INSERT INTO GamingStationBooking "
                         + "(userID, stationID, date, startTime, endTime, status, priceType, playerCount, price, paymentStatus, hourCount) "
                         + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(insertSQL)) {

            ps.setString(1,             userID);
            ps.setString(2,             stationID);
            ps.setDate(3,               java.sql.Date.valueOf(selectedDate));
            ps.setTime(4,               java.sql.Time.valueOf(LocalTime.of(startHour, 0)));
            ps.setTime(5,               java.sql.Time.valueOf(LocalTime.of(endHour, 59)));
            ps.setString(6,             "Confirmed");
            ps.setString(7,             priceType);
            ps.setInt(8,                playerCount);
            ps.setDouble(9,             totalPrice);
            ps.setString(10,            "PAID");
            ps.setInt(11,               hourCount);

            ps.executeUpdate();
        } catch (SQLException ex) {
            response.setContentType("text/html");
            response.getWriter().println(
                "<p style='color:red;'>Error inserting booking: " + ex.getMessage() + "</p>");
            return;
        }

        // 8) Redirect to success page
        response.sendRedirect("paymentSuccess.jsp");
    }
}
