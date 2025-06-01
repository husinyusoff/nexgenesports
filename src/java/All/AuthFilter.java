package All;

import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;
import java.util.Set;

@WebFilter("/*")
public class AuthFilter implements Filter {

    private static final Set<String> PUBLIC = Set.of(
        "/index.jsp",
        "/login.jsp",
        "/register.jsp",
        "/accessDenied.jsp",
        "/styles.css",
        "/logout.jsp",
        "/dbtest.jsp",
        "/RegisterServlet",
        "/LoginServlet"
    );

    @Override
    public void init(FilterConfig filterConfig) {
        // No initialization needed
    }

    @Override
    public void doFilter(ServletRequest rq,
                         ServletResponse rs,
                         FilterChain chain)
                     throws IOException, ServletException {

        HttpServletRequest  req  = (HttpServletRequest)  rq;
        HttpServletResponse res  = (HttpServletResponse) rs;
        String path = req.getServletPath();

        // 1) Allow all public resources (login, register, CSS, etc.)
        if (PUBLIC.contains(path) || path.startsWith("/images/")) {
            chain.doFilter(rq, rs);
            return;
        }

        // 2) Require login
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("username") == null) {
            res.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        // 3) Always allow dashboard
        if ("/dashboard.jsp".equals(path)) {
            chain.doFilter(rq, rs);
            return;
        }

        // 4) Retrieve the user’s roles and chosen role from session
        @SuppressWarnings("unchecked")
        List<String> effectiveRoles = (List<String>) session.getAttribute("effectiveRoles");
        String chosenRole = (String) session.getAttribute("role");     // exact role picked
        String position   = (String) session.getAttribute("position"); // may be null

        if (effectiveRoles == null || effectiveRoles.isEmpty() || chosenRole == null) {
            res.sendRedirect(req.getContextPath() + "/accessDenied.jsp");
            return;
        }

        // 5) Check permission via PermissionChecker
        boolean allowed = PermissionChecker.hasAccess(
            effectiveRoles, chosenRole, position, path
        );
        if (allowed) {
            chain.doFilter(rq, rs);
        } else {
            res.sendRedirect(req.getContextPath() + "/accessDenied.jsp");
        }
    }

    @Override
    public void destroy() {
        // No teardown needed
    }
}
