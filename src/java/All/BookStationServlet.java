package All;

import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;
import java.util.*;
import com.google.gson.Gson;

@WebServlet("/bookStation")
public class BookStationServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        if ("true".equals(request.getParameter("fetchSlots"))) {
            response.setContentType("application/json");
            String stationID = request.getParameter("stationID");
            String dateStr   = request.getParameter("date");

            String sql = "SELECT startTime,endTime,status "
                       + "FROM GamingStationBooking "
                       + "WHERE stationID=? AND date=?";

            try (Connection conn = DBConnection.getConnection();
                 PreparedStatement ps = conn.prepareStatement(sql)) {

                ps.setString(1, stationID);
                ps.setDate(2, Date.valueOf(dateStr));

                ResultSet rs = ps.executeQuery();
                List<Map<String,Object>> slots = new ArrayList<>();

                while (rs.next()) {
                    Map<String,Object> m = new HashMap<>();
                    m.put("startTime", rs.getTime("startTime").toString());
                    m.put("endTime",   rs.getTime("endTime").toString());
                    m.put("booked",    "Booked".equalsIgnoreCase(rs.getString("status")));
                    slots.add(m);
                }

                PrintWriter out = response.getWriter();
                out.print(new Gson().toJson(slots));
            } catch (Exception e) {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                response.getWriter().write("{\"error\":\"Failed to fetch slots.\"}");
            }
        }
    }
}

