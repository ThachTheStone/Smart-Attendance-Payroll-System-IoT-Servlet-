<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="pageTitle" value="Change Password"/>
<c:set var="activeNav" value="password"/>
<%@ include file="../common/header.jspf" %>

<div class="page-head"><div><h1>Change Password</h1></div></div>

<form method="post" action="${pageContext.request.contextPath}/account/password" class="card form narrow" novalidate>
    <label class="${not empty errors.currentPassword ? 'has-error' : ''}">Current Password *
        <input type="password" name="currentPassword" autocomplete="current-password">
        <span class="err"><c:out value="${errors.currentPassword}"/></span>
    </label>
    <label class="${not empty errors.password ? 'has-error' : ''}">New Password *
        <input type="password" name="password" autocomplete="new-password">
        <span class="hint">≥ 8 characters, including uppercase, lowercase, digits &amp; symbols</span>
        <span class="err"><c:out value="${errors.password}"/></span>
    </label>
    <label class="${not empty errors.confirmPassword ? 'has-error' : ''}">Confirm New Password *
        <input type="password" name="confirmPassword" autocomplete="new-password">
        <span class="err"><c:out value="${errors.confirmPassword}"/></span>
    </label>
    <div class="form-actions">
        <button class="btn" type="submit">Update Password</button>
    </div>
</form>

<%@ include file="../common/footer.jspf" %>
