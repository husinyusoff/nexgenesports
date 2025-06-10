<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page session="true" %>
<!DOCTYPE html>
<html>
    <head>
        <title>Dashboard – NexGen Esports</title>
        <link rel="stylesheet" href="styles.css">
    </head>
    <body>
        <jsp:include page="header.jsp"/>
        <!-- ☰ open button -->
        <button id="openToggle" class="open-toggle">☰</button>

        <div class="container">
            <!-- one sidebar wrapper -->
            <div class="sidebar">
                <!-- × close button -->
                <button id="closeToggle" class="close-toggle">×</button>
                <!-- dynamic links -->
                <jsp:include page="sidebar.jsp"/>
            </div>

            <div class="content">
                <!-- your dashboard content here -->
                <div class="dashboard-container">
                    <img src="${pageContext.request.contextPath}/images/welcome.png"
                         alt="Welcome" class="welcome-image">
                </div>
            </div>
        </div>

        <div class="footer">
            © NexGen Esports 2025 All Rights Reserved.
        </div>

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
