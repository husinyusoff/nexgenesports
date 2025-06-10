package All;

import java.util.List;

public class RoleUtils {

    /**
     * @param effectiveRoles list of role-names (including inherited ancestors)
     * @param permRole a single role from the permission row
     * @param position the user’s position (may be null)
     * @return true if permRole is in effectiveRoles
     */
    public static boolean isAllowedRole(
            List<String> effectiveRoles,
            String permRole,
            String position
    ) {
        // No overrides. Just check membership.
        return effectiveRoles.contains(permRole);
    }
}
