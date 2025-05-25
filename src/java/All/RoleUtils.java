package All;

public class RoleUtils {

    public static boolean isAllowedRole(String dbRole, String selRole) {
        switch (dbRole) {
            case "athlete":
                return "athlete".equals(selRole);
            case "executive_council":
                return selRole.equals("athlete") || selRole.equals("executive_council");
            case "high_council":
                return selRole.equals("athlete") || selRole.equals("executive_council") || selRole.equals("high_council");
            case "referee":
                return "referee".equals(selRole);
            default:
                return false;
        }
    }
}