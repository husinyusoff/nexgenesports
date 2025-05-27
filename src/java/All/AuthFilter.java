package All;

import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.Collections;
import java.util.List;
import java.util.Set;

@WebFilter("/*")
public class AuthFilter implements Filter {

  private static final Set<String> PUBLIC = Set.of(
      "/index.jsp", "/login.jsp", "/register.jsp",
      "/accessDenied.jsp", "/styles.css", "/logout.jsp",
      "/dbtest.jsp", "/RegisterServlet", "/LoginServlet"
  );

  @Override
  public void init(FilterConfig filterConfig) {}

  @Override
  public void doFilter(ServletRequest rq, ServletResponse rs, FilterChain chain)
      throws IOException, ServletException {

    HttpServletRequest  req = (HttpServletRequest)  rq;
    HttpServletResponse res = (HttpServletResponse) rs;
    String path = req.getServletPath();

    // 1) allow all public resources
    if (PUBLIC.contains(path) || path.startsWith("/images/")) {
      chain.doFilter(rq, rs);
      return;
    }

    // 2) require login
    HttpSession s = req.getSession(false);
    if (s == null || s.getAttribute("username") == null) {
      res.sendRedirect(req.getContextPath() + "/login.jsp");
      return;
    }

    // 3) always allow dashboard
    if ("/dashboard.jsp".equals(path)) {
      chain.doFilter(rq, rs);
      return;
    }

    // 4) check permissions via rp_ids
    @SuppressWarnings("unchecked")
    List<Integer> rpIds = (List<Integer>)s.getAttribute("effectiveRpIds");
    if (rpIds == null || rpIds.isEmpty()) {
      res.sendRedirect(req.getContextPath() + "/accessDenied.jsp");
      return;
    }

    // build an IN-clause
    String inClause = String.join(",", Collections.nCopies(rpIds.size(), "?"));
    String sql =
      "SELECT 1 "
    + "  FROM permissions p "
    + "  JOIN pages       pg ON p.page_id = pg.page_id "
    + " WHERE p.rp_id IN (" + inClause + ")"
    + "   AND pg.url = ? "
    + " LIMIT 1";

    try (Connection c = DBConnection.getConnection();
         PreparedStatement ps = c.prepareStatement(sql)) {
      int i = 1;
      for (Integer id : rpIds) {
        ps.setInt(i++, id);
      }
      ps.setString(i, path);

      try (ResultSet rs2 = ps.executeQuery()) {
        if (rs2.next()) {
          chain.doFilter(rq, rs);
        } else {
          res.sendRedirect(req.getContextPath() + "/accessDenied.jsp");
        }
      }
    } catch (Exception e) {
      throw new ServletException(e);
    }
  }

  @Override
  public void destroy() {}
}
