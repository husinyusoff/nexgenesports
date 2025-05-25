<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, java.util.*, All.DBConnection" %>

<%
    HttpSession sess = request.getSession(false);
    String role     = sess==null ? null : (String)sess.getAttribute("role");
    String position = sess==null ? null : (String)sess.getAttribute("position");

    out.println("<!-- DEBUG: sidebar.jsp run – role=" + role + " position=" + position + " -->");

    List<Map<String,String>> menu = new ArrayList<>();

    String sql =
      "SELECT q.name, q.url " +
      "  FROM permissions p " +
      "  JOIN pages q ON p.page_id = q.page_id " +
      " WHERE p.role = ? " +
      "   AND (p.position IS NULL OR p.position = ?) " +
      " ORDER BY q.page_id";

    try (
        Connection conn = DBConnection.getConnection();
        PreparedStatement ps = conn.prepareStatement(sql)
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
        out.println("<!-- DEBUG: sidebar.jsp exception: " + e.getMessage() + " -->");
    }
%>

<nav style="border:1px solid #ccc; padding:0.5em; width:200px;">
  <ul>
  <% if (menu.isEmpty()) { %>
    <li><em>(no menu items)</em></li>
  <% } else {
       for (Map<String,String> item : menu) { %>
      <li>
        <a href="<%= request.getContextPath() + item.get("url") %>">
          <%= item.get("name") %>
        </a>
      </li>
  <% } } %>
  </ul>
</nav>
