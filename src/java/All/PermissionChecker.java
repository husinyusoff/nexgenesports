package All;

import java.sql.*;
import java.util.List;

public class PermissionChecker {

    /**
     * Determine if a user may access a given URL.
     *
     * @param effectiveRoles  The user’s list of inherited roles (e.g. ["high_council","executive_council","athlete"])
     * @param chosenRole      The exact role the user picked at login (e.g. "athlete", "high_council", "superadmin")
     * @param position        The user’s position (may be null), e.g. "president"
     * @param url             The servletPath or JSP URL (e.g. "/bookStation.jsp")
     * @return true if allowed; false otherwise
     */
    public static boolean hasAccess(
        List<String> effectiveRoles,
        String chosenRole,
        String position,
        String url
    ) {
        // 1) Lookup page_id and inherit_permission for this URL
        final String PAGE_SQL =
          "SELECT page_id, inherit_permission "
        + "  FROM pages "
        + " WHERE url = ?";

        int pageId;
        boolean inheritPermission;
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement psPage = conn.prepareStatement(PAGE_SQL)) {

            psPage.setString(1, url);
            try (ResultSet rsPage = psPage.executeQuery()) {
                if (!rsPage.next()) {
                    // URL not registered in pages → deny
                    return false;
                }
                pageId           = rsPage.getInt("page_id");
                inheritPermission = rsPage.getBoolean("inherit_permission");
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }

        // 2) Fetch all permission rows for this page_id
        final String PERM_SQL =
          "SELECT rp.role AS perm_role, rp.position AS perm_pos "
        + "  FROM permissions p "
        + "  JOIN role_positions rp ON p.rp_id = rp.id "
        + " WHERE p.page_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement psPerm = conn.prepareStatement(PERM_SQL)) {

            psPerm.setInt(1, pageId);
            try (ResultSet rsPerm = psPerm.executeQuery()) {
                while (rsPerm.next()) {
                    String permRole = rsPerm.getString("perm_role");
                    String permPos  = rsPerm.getString("perm_pos"); // may be null

                    // 3a) If permission row specifies a position, skip if mismatch
                    if (permPos != null && !permPos.equals(position)) {
                        continue;
                    }

                    // 3b) Inherit-friendly pages (inherit_permission = 1)
                    if (inheritPermission) {
                        if (RoleUtils.isAllowedRole(effectiveRoles, permRole, position)) {
                            return true;
                        }
                    }
                    // 3c) Exact-role-only pages (inherit_permission = 0)
                    else {
                        if (permRole.equals(chosenRole)) {
                            return true;
                        }
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }

        // 4) No permission matched → deny
        return false;
    }
}
