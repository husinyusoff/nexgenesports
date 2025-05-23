package All;

import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;

@WebFilter("/*")
public class AuthFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // nothing to do on startup
    }

    @Override
    public void doFilter(ServletRequest req, ServletResponse res,
                         FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest  request  = (HttpServletRequest)  req;
        HttpServletResponse response = (HttpServletResponse) res;

        String uri = request.getRequestURI();
        // Allow static resources and login paths through without auth
        if (uri.endsWith("login.jsp")
         || uri.endsWith("/login")
         || uri.matches(".+\\.(css|js|png|jpg|gif)$")) {
            chain.doFilter(req, res);
            return;
        }

        HttpSession session = request.getSession(false);
        String role = (session != null) ? (String) session.getAttribute("role") : null;

        // If not logged in, redirect to login page
        if (role == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        // If logged in, check RBAC
        if (!checkPermission(role, uri)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "You don’t have access to that page.");
            return;
        }

        // All good — continue on
        chain.doFilter(req, res);
    }

    @Override
    public void destroy() {
        // nothing to clean up on shutdown
    }

    /**
     * Looks up the permissions table to see if this role is allowed
     * to access this exact URI.
     */
    private boolean checkPermission(String role, String uri) {
        String sql = "SELECT COUNT(*) FROM permissions WHERE role = ? AND page_uri = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, role);
            ps.setString(2, uri);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next() && rs.getInt(1) > 0) {
                    return true;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}
