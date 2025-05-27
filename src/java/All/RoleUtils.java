package All;

import java.util.List;

public class RoleUtils {
    /**
     * @param effectiveRoles list of role-names in the session
     * @param permRole       a single role from the permissions table
     * @param position       the user's position (may be null)
     * @return true if permRole is satisfied via inheritance or exact match
     */
    public static boolean isAllowedRole(
        List<String> effectiveRoles,
        String permRole,
        String position
    ) {
        // president → superadmin override
        if (effectiveRoles.contains("high_council")
            && "president".equals(position)
            && "superadmin".equals(permRole)) {
            return true;
        }
        // otherwise, inherit if permRole is in the list
        return effectiveRoles.contains(permRole);
    }
}
