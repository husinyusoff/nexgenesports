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
             "/dbtest.jsp","/RegisterServlet"
    );

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // nothing to do here
    }

    @Override
    public void doFilter(ServletRequest rq, ServletResponse rs, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) rq;
        HttpServletResponse res = (HttpServletResponse) rs;
        String path = req.getServletPath();

        if (PUBLIC.contains(path) || path.startsWith("/images/")) {
            chain.doFilter(rq, rs);
            return;
        }

        HttpSession s = req.getSession(false);
        if (s == null || s.getAttribute("username") == null) {
            res.sendRedirect("login.jsp");
            return;
        }

        String role = (String) s.getAttribute("role");
        String position = (String) s.getAttribute("position");
        if (!PermissionChecker.hasAccess(role, position, path)) {
            res.sendRedirect("accessDenied.jsp");
            return;
        }

        chain.doFilter(rq, rs);
    }

    @Override
    public void destroy() {
        // nothing to do here
    }
}
