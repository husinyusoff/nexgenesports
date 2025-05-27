<%@ page contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8"
         session="true" %>
<!DOCTYPE html>
<html>
    <head>
        <title>Login – NexGen Esports</title>
        <link rel="stylesheet" href="styles.css">
    </head>
    <body>

        <!-- header include (logo + top bar) -->
        <jsp:include page="header.jsp"/>

        <!-- open-sidebar toggle -->
        <button id="openToggle" class="open-toggle">☰</button>

        <div class="container">
            <!-- Sidebar only for login/register -->
            <div class="sidebar">
                <button id="closeToggle" class="close-toggle">×</button>
                <nav>
                    <ul>
                        <li>
                            <a href="${pageContext.request.contextPath}/login.jsp">Login</a>
                        </li>
                        <li>
                            <a href="${pageContext.request.contextPath}/register.jsp">Sign Up</a>
                        </li>
                    </ul>
                </nav>
            </div>


            <!-- Main content (centered login box) -->
            <div class="content">
                <div class="login-container">
                    <h2>LOGIN</h2>

                    <% if ("badcreds".equals(request.getParameter("error"))) { %>
                    <p class="error">❌ Invalid user ID, password or role.</p>
                    <% }%>

                    <form action="LoginServlet" method="post">
                        <div class="roles-grid">
                            <label><input type="radio" name="selectedRole" value="athlete"       checked> Athlete</label>
                            <label><input type="radio" name="selectedRole" value="referee"> Referee</label>
                            <label><input type="radio" name="selectedRole" value="executive_council"> Exec Council</label>
                            <label><input type="radio" name="selectedRole" value="high_council"> High Council</label>
                        </div>

                        <label for="userID">User ID</label>
                        <input type="text" id="userID" name="userID" required>

                        <label for="password">Password</label>
                        <input type="password" id="password" name="password" required>

                        <a href="#" class="forgot">forgot password</a>
                        <button type="submit">Login</button>
                    </form>
                </div>
            </div>
        </div>

        <!-- footer include -->
        <jsp:include page="footer.jsp"/>

        <!-- sidebar toggles script -->
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
