<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page session="true" %>
<!DOCTYPE html>
<html>
    <head>
        <title>Sign Up – NexGen Esports</title>
        <link rel="stylesheet" href="styles.css">
    </head>
    <body>

        <!-- Header -->
        <div class="header">
            <img src="${pageContext.request.contextPath}/images/umt-logo.png"
                 alt="UMT Logo" class="logo umt-logo">
            <img src="${pageContext.request.contextPath}/images/esports-logo.png"`
                 alt="Esports Logo" class="logo esports-logo">
            <h1>NEXGEN ESPORTS</h1>
        </div>

        <!-- ☰ open-sidebar button -->
        <button id="openToggle" class="open-toggle">☰</button>

        <div class="container">
            <!-- Sidebar -->
            <div class="sidebar">
                <!-- × close-sidebar button INSIDE sidebar -->
                <button id="closeToggle" class="close-toggle">×</button>

                <a href="${pageContext.request.contextPath}/login.jsp">Login</a>
                <a href="${pageContext.request.contextPath}/register.jsp">Sign Up</a>
            </div>

            <!-- Main content -->
            <div class="content">
                <div class="register-container">
                    <h2>SIGN UP</h2>

                    <form action="RegisterServlet" method="post">
                        <!-- your other fields… -->

                        <!-- Club session dropdown -->
                        <label for="clubSessionID">Club Session</label>
                        <select id="clubSessionID" name="clubSessionID" required>
                            <option value="2024/2025">2024/2025</option>
                            <option value="2025/2026">2025/2026</option>
                        </select>

                        <label for="gamingPassID">GamingPass ID</label>
                        <input id="gamingPassID" name="gamingPassID"/>

                        <button type="submit">Register</button>
                    </form>

                    <!-- inline error/message -->
                    <% if (request.getAttribute("message") != null) { %>
                    <p class="error"><%= request.getAttribute("message") %></p>
                    <% } %>
                </div>
            </div>
        </div>

        <!-- Footer -->
        <div class="footer">
            © NexGen Esports 2025 All Rights Reserved.
        </div>

        <!-- Toggle script -->
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
