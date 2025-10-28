<%@ tag description="Format currency in Vietnamese style" pageEncoding="UTF-8" %>
<%@ attribute name="value" required="false" type="java.lang.Number" %>
<%@ attribute name="emptyText" required="false" type="java.lang.String" %>
<%@ attribute name="fractionDigits" required="false" type="java.lang.Integer" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="resolvedFraction" value="${fractionDigits != null ? fractionDigits : 0}" />
<c:set var="resolvedEmpty" value="${not empty emptyText ? emptyText : '0&nbsp;₫'}" />

<c:choose>
    <c:when test="${value != null}">
        <fmt:setLocale value="vi_VN" scope="page" />
        <fmt:formatNumber value="${value}" type="number" groupingUsed="true"
                          minFractionDigits="${resolvedFraction}" maxFractionDigits="${resolvedFraction}"
                          var="formattedValue" />
        <c:out value="${formattedValue}" />&#160;₫
    </c:when>
    <c:otherwise>
        <c:out value="${resolvedEmpty}" escapeXml="false" />
    </c:otherwise>
</c:choose>
