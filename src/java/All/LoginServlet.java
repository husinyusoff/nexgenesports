package All;

import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.getRequestDispatcher("/login.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String username = req.getParameter("username");
        String password = req.getParameter("password");

        String sql = "SELECT role FROM users WHERE username = ? AND password = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, username);
            ps.setString(2, password);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String role = rs.getString("role");
                    HttpSession s = req.getSession();
                    s.setAttribute("username", username);
                    s.setAttribute("role", role);
                    resp.sendRedirect(req.getContextPath() + "/dashboard.jsp");
                    return;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        req.setAttribute("error", "Invalid username or password");
        req.getRequestDispatcher("/login.jsp").forward(req, resp);
    }
}
