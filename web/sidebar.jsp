<%@ page contentType="text/html; charset=UTF-8"           pageEncoding="UTF-8" %>   <!-- NEW: force UTF-8 -->
<%@ page import="java.sql.*, java.util.*, All.DBConnection" %>                  <!-- NEW: import your helper -->

<%
    // grab role & position from session
    HttpSession sess = request.getSession(false);
    String role     = (String) sess.getAttribute("role");
    String position = (String) sess.getAttribute("position");

    // prepare to collect menu items
    List<Map<String,String>> menu = new ArrayList<>();

    // your permissions → pages join
    String sql =
        "SELECT q.name, q.url " +
        "  FROM permissions p " +
        "  JOIN pages q ON p.page_id = q.page_id " +
        " WHERE p.role = ? " +
        "   AND (p.position IS NULL OR p.position = ?) " +
        " ORDER BY q.page_id";

    try (
        Connection       conn = DBConnection.getConnection();  // now resolves
        PreparedStatement ps   = conn.prepareStatement(sql)
    ) {
        ps.setString(1, role);
        ps.setString(2, position);
        try (ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String,String> item = new HashMap<>();
                item.put("name", rs.getString("name"));
                item.put("url",  rs.getString("url"));
                menu.add(item);
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
%>

<nav>
  <ul>
    <% for (Map<String,String> item : menu) { %>
      <li>
        <a href="<%= request.getContextPath() + item.get("url") %>">
          <%= item.get("name") %>
        </a>
      </li>
    <% } %>
  </ul>
</nav>
