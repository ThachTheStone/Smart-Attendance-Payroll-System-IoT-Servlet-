<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="pageTitle" value="Đặt lại mật khẩu"/>
<c:set var="activeNav" value="users"/>
<%@ include file="../common/header.jspf" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<div class="page-head">
    <div>
        <a class="back" href="${ctx}/admin/users">← Danh sách người dùng</a>
        <h1>Đặt lại mật khẩu</h1>
        <p class="muted">Cho tài khoản <b class="mono"><c:out value="${target.username}"/></b>
            (<c:out value="${target.displayName}"/>)</p>
    </div>
</div>

<form method="post" action="${ctx}/admin/users/reset-password" class="card form narrow" novalidate>
    <input type="hidden" name="id" value="${target.id}">
    <label class="${not empty errors.password ? 'has-error' : ''}">Mật khẩu mới *
        <input type="password" name="password" autocomplete="new-password">
        <span class="hint">≥ 8 ký tự, có chữ hoa, chữ thường, số, ký tự đặc biệt</span>
        <span class="err"><c:out value="${errors.password}"/></span>
    </label>
    <label class="${not empty errors.confirmPassword ? 'has-error' : ''}">Nhập lại mật khẩu *
        <input type="password" name="confirmPassword" autocomplete="new-password">
        <span class="err"><c:out value="${errors.confirmPassword}"/></span>
    </label>
    <div class="form-actions">
        <a class="btn btn-ghost" href="${ctx}/admin/users">Hủy</a>
        <button class="btn" type="submit">Đặt lại mật khẩu</button>
    </div>
</form>

<%@ include file="../common/footer.jspf" %>
