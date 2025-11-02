<%--
  Created by IntelliJ IDEA.
  User: tanhu
  Date: 11/2/2025
  Time: 1:09 PM
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // This scriptlet must be repeated in every file that uses the asset paths
    // or you can pass assetBase as a request attribute from a filter/controller.
    String contextPath = request.getContextPath();
    String assetBase = contextPath + "/assets/sneat-1.0.0/assets";
    String vendorPath = assetBase + "/vendor";
    String cssPath = assetBase + "/css";
%>
<meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no, minimum-scale=1.0, maximum-scale=1.0" />
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">

<link rel="preconnect" href="https://fonts.googleapis.com" />
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
<link href="https://fonts.googleapis.com/css2?family=Public+Sans:ital,wght@0,300;0,400;0,500;0,600;0,700;1,300;1,400;1,500;1,600;1,700&display=swap" rel="stylesheet" />

<link rel="stylesheet" href="<%= vendorPath %>/fonts/boxicons.css" />
<link rel="stylesheet" href="<%= vendorPath %>/css/core.css" class="template-customizer-core-css" />
<link rel="stylesheet" href="<%= vendorPath %>/css/theme-default.css" class="template-customizer-theme-css" />
<link rel="stylesheet" href="<%= assetBase %>/css/demo.css" />

<script src="<%= vendorPath %>/js/helpers.js"></script>