<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="pageTitle" value="Không có quyền"/>
<%@ include file="header.jspf" %>
<div class="empty-state">
    <div class="big-code">403</div>
    <h1>Bạn không có quyền truy cập trang này</h1>
    <p>Tài khoản <b><c:out value="${sessionScope.account.username}"/></b> có vai trò
        <b><c:out value="${sessionScope.account.role.label}"/></b>.</p>
    <a class="btn" href="${pageContext.request.contextPath}${sessionScope.account.role.homePath}">Về trang chủ</a>
</div>
<%@ include file="footer.jspf" %>
