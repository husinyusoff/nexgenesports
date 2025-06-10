<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*, All.DBConnection" %>
<!DOCTYPE html>
<html>
    <head>
        <title>Manage RBAC</title>
        <link rel="stylesheet" href="styles.css">
    </head>
    <body class="sidebar-collapsed">

        <jsp:include page="header.jsp"/>
        <button id="openToggle" class="open-toggle">☰</button>

        <div class="container">
            <div class="sidebar">
                <button id="closeToggle" class="close-toggle">×</button>
                <jsp:include page="sidebar.jsp"/>
            </div>

            <div class="content">
                <h2>RBAC Control Center</h2>
                <form action="RBACAdminServlet" method="post">
                    <!-- Add Role -->
                    <table>
                        <tr><th colspan="2">Add Role</th></tr>
                        <tr>
                            <td><input name="roleName" placeholder="role (e.g. athlete)" required/></td>
                            <td><button name="action" value="addRole">Add Role</button></td>
                        </tr>
                    </table>

                    <!-- Add Position -->
                    <table>
                        <tr><th colspan="2">Add Position</th></tr>
                        <tr>
                            <td><input name="positionName" placeholder="position (e.g. secretary)" required/></td>
                            <td><button name="action" value="addPosition">Add Position</button></td>
                        </tr>
                    </table>

                    <!-- Add Page -->
                    <table>
                        <tr><th colspan="3">Add Page</th></tr>
                        <tr>
                            <td><input name="pageName" placeholder="Page name" required/></td>
                            <td><input name="pageURL"  placeholder="/foo.jsp" required/></td>
                            <td><button name="action" value="addPage">Add Page</button></td>
                        </tr>
                    </table>

                    <!-- Grant Permission -->
                    <table>
                        <tr><th colspan="4">Grant Permission</th></tr>
                        <tr>
                            <td>
                                <select name="perm_role">
                                    <% try (Connection c = DBConnection.getConnection();
                                           Statement s = c.createStatement();
                                           ResultSet rs = s.executeQuery("SELECT role FROM roles")) {
                                         while (rs.next()) { %>
                                    <option value="<%=rs.getString("role")%>">
                                        <%=rs.getString("role")%>
                                    </option>
                                    <% } } %>
                                </select>
                            </td>
                            <td>
                                <select name="perm_position">
                                    <option value="">(none)</option>
                                    <% try (Connection c = DBConnection.getConnection();
                                           Statement s = c.createStatement();
                                           ResultSet rs = s.executeQuery("SELECT position FROM positions")) {
                                         while (rs.next()) { %>
                                    <option value="<%=rs.getString("position")%>">
                                        <%=rs.getString("position")%>
                                    </option>
                                    <% } } %>
                                </select>
                            </td>
                            <td>
                                <select name="perm_page">
                                    <% try (Connection c = DBConnection.getConnection();
                                           Statement s = c.createStatement();
                                           ResultSet rs = s.executeQuery("SELECT page_id, name FROM pages")) {
                                         while (rs.next()) { %>
                                    <option value="<%=rs.getInt("page_id")%>">
                                        [<%=rs.getInt("page_id")%>] <%=rs.getString("name")%>
                                    </option>
                                    <% } } %>
                                </select>
                            </td>
                            <td><button name="action" value="addPermission">Grant</button></td>
                        </tr>
                    </table>
                </form>

                <hr/>

                <h3>Existing Users &amp; Roles</h3>
                <ul>
                    <% try (Connection c = DBConnection.getConnection();
                           Statement s = c.createStatement();
                           ResultSet rs = s.executeQuery(
                             "SELECT u.userID, rp.role, rp.position "
                           + "  FROM users u "
                           + "  JOIN role_positions rp ON u.rpid = rp.id")) {
                         while (rs.next()) { %>
                    <li>
                        <%=rs.getString("userID")%> →
                        <%=rs.getString("role")%>
                        (<%= rs.getString("position")==null?"none":rs.getString("position") %>)
                    </li>
                    <% } } %>
                </ul>

                <h3>Existing Permissions</h3>
                <ul>
                    <% try (Connection c = DBConnection.getConnection();
                           Statement s = c.createStatement();
                           ResultSet rs = s.executeQuery(
                             "SELECT rp.role, rp.position, p.page_id "
                           + "  FROM permissions p "
                           + "  JOIN role_positions rp ON p.rp_id = rp.id")) {
                         while (rs.next()) { %>
                    <li>
                        <%=rs.getString("role")%>
                        (<%= rs.getString("position")==null?"none":rs.getString("position") %>)
                        → page_id=<%=rs.getInt("page_id")%>
                    </li>
                    <% } } %>
                </ul>
            </div>
        </div>

        <jsp:include page="footer.jsp"/>
        <script>
            document.getElementById('openToggle').addEventListener('click', () =>
                document.body.classList.remove('sidebar-collapsed')
            );
            document.getElementById('closeToggle').addEventListener('click', () =>
                document.body.classList.add('sidebar-collapsed')
            );
        </script>
    </body>
</html>
