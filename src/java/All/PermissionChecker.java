package All;

import java.sql.*;
import java.util.List;

public class PermissionChecker {

    /**
     * @param effectiveRoles from the session
     * @param position       from the session (may be null)
     * @param url            servletPath (e.g. "/dashboard.jsp")
     */
    public static boolean hasAccess(
        List<String> effectiveRoles,
        String position,
        String url
    ) {
        final String PAGE_SQL =
          "SELECT page_id, inherit_permission " +
          "  FROM pages " +
          " WHERE url = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement psPage = conn.prepareStatement(PAGE_SQL)) {
             
            psPage.setString(1, url);
            try (ResultSet rsPage = psPage.executeQuery()) {
                if (!rsPage.next()) return false;  // page not registered
                int pageId      = rsPage.getInt("page_id");
                boolean inherit = rsPage.getBoolean("inherit_permission");

                final String PERM_SQL =
                  "SELECT rp.role AS perm_role, rp.position AS perm_pos " +
                  "  FROM permissions p " +
                  "  JOIN role_positions rp ON p.rp_id = rp.id " +
                  " WHERE p.page_id = ?";

                try (PreparedStatement psPerm = conn.prepareStatement(PERM_SQL)) {
                    psPerm.setInt(1, pageId);
                    try (ResultSet rsPerm = psPerm.executeQuery()) {
                        while (rsPerm.next()) {
                            String permRole = rsPerm.getString("perm_role");
                            String permPos  = rsPerm.getString("perm_pos"); // may be null

                            // position must match
                            if (permPos != null && !permPos.equals(position)) {
                                continue;
                            }

                            if (inherit) {
                                // allow via inheritance
                                if (RoleUtils.isAllowedRole(
                                        effectiveRoles, permRole, position)) {
                                    return true;
                                }
                            } else {
                                // exact-role only
                                if (effectiveRoles.contains(permRole)) {
                                    return true;
                                }
                            }
                        }
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}
