<%@page import="All.DBConnection"%>
<%@ page import="java.sql.*" %>
<%
  try (Connection c = DBConnection.getConnection()) {
    out.println("<p style='color:green'>DB OK: " + c.getMetaData().getDatabaseProductName() 
                + " " + c.getMetaData().getDatabaseProductVersion() + "</p>");
  } catch (Exception e) {
    out.println("<p style='color:red'>DB ERROR: " + e.getMessage() + "</p>");
  }
%>
