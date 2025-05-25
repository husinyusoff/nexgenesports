package All;

import java.sql.*;

public class PermissionChecker {

    public static boolean hasAccess(String role, String position, String url) {
        String sql = "SELECT 1 FROM permissions p JOIN pages q ON p.page_id=q.page_id "
                + " WHERE p.role=? AND q.url=? AND (p.position IS NULL OR p.position=?) LIMIT 1";

        try (Connection c = DBConnection.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, role);
            ps.setString(2, url);
            ps.setString(3, position);
            return ps.executeQuery().next();
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}
