<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<div class="header">
  <img src="${pageContext.request.contextPath}/images/umt-logo.png"
       alt="UMT Logo" class="logo umt-logo">
  <img src="${pageContext.request.contextPath}/images/esports-logo.png"
       alt="Esports Logo" class="logo esports-logo">
  <h1>NEXGEN ESPORTS</h1>
  <!-- optional user‐avatar slot in top right -->
  <div class="user-avatar">
    <img src="${pageContext.request.contextPath}/images/user.png"
         alt="User">
    <span style="color:#fff; margin-left:4px;">
      <%= session.getAttribute("username") != null ? session.getAttribute("username") : "" %>
    </span>
  </div>
</div>
