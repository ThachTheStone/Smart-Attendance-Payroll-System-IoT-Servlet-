<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="pageTitle" value="Access Denied"/>
<%@ include file="header.jspf" %>
<div class="empty-state">
    <div class="big-code">403</div>
    <h1>You do not have permission to access this page</h1>
    <p>Account <b><c:out value="${sessionScope.account.username}"/></b> has role
        <b><c:out value="${sessionScope.account.role.label}"/></b>.</p>
    <a class="btn" href="${pageContext.request.contextPath}${sessionScope.account.role.homePath}">Return to Home</a>
</div>
<%@ include file="footer.jspf" %>
