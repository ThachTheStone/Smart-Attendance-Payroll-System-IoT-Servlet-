<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="pageTitle" value="Reset Password"/>
<c:set var="activeNav" value="users"/>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<%@ include file="../common/header.jspf" %>

<style>
    .pwd-card {
        max-width: 520px;
        margin: 32px auto;
        background: #ffffff;
        border: 1px solid var(--border);
        border-radius: var(--radius-lg);
        padding: 28px;
        box-shadow: var(--shadow-sm);
        color: #0f172a;
    }
    .pwd-field {
        margin-bottom: 18px;
    }
    .pwd-label {
        display: block;
        font-size: 12px;
        font-weight: 600;
        color: #334155;
        margin-bottom: 6px;
    }
    .pwd-input {
        width: 100%;
        height: 40px;
        padding: 0 12px;
        border: 1px solid #cbd5e1;
        border-radius: 7px;
        font-family: inherit;
        font-size: 13px;
        background: #ffffff;
        color: #0f172a;
        transition: border-color var(--transition-fast), box-shadow var(--transition-fast);
    }
    .pwd-input:focus {
        border-color: #1d4ed8;
        box-shadow: 0 0 0 3px rgba(29, 78, 216, 0.12);
        outline: none;
    }
    .pwd-field.has-error .pwd-input {
        border-color: #dc2626;
        background: #fef2f2;
    }
    .pwd-err {
        color: #dc2626;
        font-size: 12px;
        font-weight: 500;
        margin-top: 4px;
        display: block;
    }
    .pwd-hint {
        font-size: 11px;
        color: var(--muted);
        margin-top: 5px;
        display: block;
    }
</style>

<div style="max-width: 520px; margin: 0 auto 16px;">
    <a class="btn btn-ghost btn-sm" href="${ctx}/admin/users" style="padding-left: 0;">
        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="margin-right: 4px;"><line x1="19" y1="12" x2="5" y2="12"></line><polyline points="12 19 5 12 12 5"></polyline></svg>
        Back to Users List
    </a>
</div>

<div class="pwd-card">
    <div style="margin-bottom: 22px;">
        <h1 style="font-size: 20px; font-weight: 700; margin: 0; color: #0f172a; display: flex; align-items: center; gap: 8px;">
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#1d4ed8" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="7.5" cy="15.5" r="5.5"></circle><path d="m21 2-9.6 9.6"></path><path d="m15.5 7.5 3 3L22 7l-3-3"></path></svg>
            Reset User Password
        </h1>
        <p class="muted small" style="margin-top: 6px;">
            Resetting credentials for account <strong class="mono" style="color: #1d4ed8;"><c:out value="${target.username}"/></strong> (<c:out value="${target.displayName}"/>)
        </p>
    </div>

    <form method="post" action="${ctx}/admin/users/reset-password" novalidate>
        <input type="hidden" name="id" value="${target.id}">

        <div class="pwd-field ${not empty errors.password ? 'has-error' : ''}">
            <label class="pwd-label">New Password <span style="color:#f87171;">*</span></label>
            <input type="password" name="password" class="pwd-input" autocomplete="new-password" placeholder="Enter new password">
            <span class="pwd-hint">Minimum 8 characters with letters, numbers, and symbols</span>
            <c:if test="${not empty errors.password}">
                <span class="pwd-err"><c:out value="${errors.password}"/></span>
            </c:if>
        </div>

        <div class="pwd-field ${not empty errors.confirmPassword ? 'has-error' : ''}">
            <label class="pwd-label">Confirm Password <span style="color:#f87171;">*</span></label>
            <input type="password" name="confirmPassword" class="pwd-input" autocomplete="new-password" placeholder="Re-enter password to confirm">
            <c:if test="${not empty errors.confirmPassword}">
                <span class="pwd-err"><c:out value="${errors.confirmPassword}"/></span>
            </c:if>
        </div>

        <div style="display: flex; justify-content: flex-end; gap: 10px; margin-top: 24px; padding-top: 18px; border-top: 1px solid var(--border);">
            <a class="btn btn-ghost" href="${ctx}/admin/users">Cancel</a>
            <button class="btn btn-primary" type="submit">Update Password</button>
        </div>
    </form>
</div>

<%@ include file="../common/footer.jspf" %>
