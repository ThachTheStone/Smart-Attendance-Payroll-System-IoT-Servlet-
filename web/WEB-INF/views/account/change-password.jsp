<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="pageTitle" value="Đổi mật khẩu"/>
<c:set var="activeNav" value="password"/>
<%@ include file="../common/header.jspf" %>

<div class="page-head"><div><h1>Đổi mật khẩu</h1></div></div>

<form method="post" action="${pageContext.request.contextPath}/account/password" class="card form narrow" novalidate>
    <label class="${not empty errors.currentPassword ? 'has-error' : ''}">Mật khẩu hiện tại *
        <input type="password" name="currentPassword" autocomplete="current-password">
        <span class="err"><c:out value="${errors.currentPassword}"/></span>
    </label>
    <label class="${not empty errors.password ? 'has-error' : ''}">Mật khẩu mới *
        <input type="password" name="password" autocomplete="new-password">
        <span class="hint">≥ 8 ký tự, có chữ hoa, chữ thường, số, ký tự đặc biệt</span>
        <span class="err"><c:out value="${errors.password}"/></span>
    </label>
    <label class="${not empty errors.confirmPassword ? 'has-error' : ''}">Nhập lại mật khẩu mới *
        <input type="password" name="confirmPassword" autocomplete="new-password">
        <span class="err"><c:out value="${errors.confirmPassword}"/></span>
    </label>
    <div class="form-actions">
        <button class="btn" type="submit">Cập nhật</button>
    </div>
</form>

<%@ include file="../common/footer.jspf" %>
