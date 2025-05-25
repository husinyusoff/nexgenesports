package All;

import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.*;
import java.io.IOException;
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

        // 1) always allow public resources
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

        // --- NEW: allow all authenticated users into dashboard.jsp ---
        if ("/dashboard.jsp".equals(path)) {
            chain.doFilter(rq, rs);
            return;
        }

        // 3) enforce per-page permissions
        String role     = (String) s.getAttribute("role");
        String position = (String) s.getAttribute("position");
        if (!PermissionChecker.hasAccess(role, position, path)) {
            res.sendRedirect(req.getContextPath() + "/accessDenied.jsp");
            return;
        }

        chain.doFilter(rq, rs);
    }

    @Override
    public void destroy() {}
}
