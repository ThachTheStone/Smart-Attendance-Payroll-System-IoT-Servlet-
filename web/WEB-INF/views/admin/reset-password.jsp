<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="pageTitle" value="Reset Password"/>
<c:set var="activeNav" value="users"/>
<%@ include file="../common/header.jspf" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<div class="page-head">
    <div>
        <a class="back" href="${ctx}/admin/users">← Back to Users</a>
        <h1>Reset Password</h1>
        <p class="muted">For account <b class="mono"><c:out value="${target.username}"/></b>
            (<c:out value="${target.displayName}"/>)</p>
    </div>
</div>

<form method="post" action="${ctx}/admin/users/reset-password" class="card form narrow" novalidate>
    <input type="hidden" name="id" value="${target.id}">
    <label class="${not empty errors.password ? 'has-error' : ''}">New Password *
        <input type="password" name="password" autocomplete="new-password">
        <span class="hint">≥ 8 characters, including uppercase, lowercase, digits &amp; symbols</span>
        <span class="err"><c:out value="${errors.password}"/></span>
    </label>
    <label class="${not empty errors.confirmPassword ? 'has-error' : ''}">Confirm Password *
        <input type="password" name="confirmPassword" autocomplete="new-password">
        <span class="err"><c:out value="${errors.confirmPassword}"/></span>
    </label>
    <div class="form-actions">
        <a class="btn btn-ghost" href="${ctx}/admin/users">Cancel</a>
        <button class="btn" type="submit">Reset Password</button>
    </div>
</form>

<%@ include file="../common/footer.jspf" %>
