<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="pageTitle" value="403 Forbidden · Access Denied"/>
<%@ include file="header.jspf" %>

<style>
    .error-container {
        display: flex;
        justify-content: center;
        align-items: center;
        min-height: 60vh;
        padding: 40px 20px;
    }
    .error-card {
        max-width: 520px;
        width: 100%;
        background: #ffffff;
        border: 1px solid #e2e8f0;
        border-radius: var(--radius-lg, 12px);
        padding: 44px 36px;
        text-align: center;
        box-shadow: 0 10px 25px rgba(0, 0, 0, 0.04);
        position: relative;
    }
    .error-badge {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        width: 64px;
        height: 64px;
        border-radius: 12px;
        background: #fef2f2;
        color: #dc2626;
        margin-bottom: 16px;
        border: 1px solid #fecaca;
    }
    .error-code {
        font-family: 'JetBrains Mono', monospace;
        font-size: 48px;
        font-weight: 700;
        line-height: 1;
        color: #dc2626;
        letter-spacing: -1px;
        margin-bottom: 12px;
    }
    .error-title {
        font-size: 20px;
        font-weight: 700;
        color: #0f172a;
        margin: 0 0 10px 0;
    }
    .error-desc {
        color: #64748b;
        font-size: 14px;
        line-height: 1.6;
        margin-bottom: 24px;
    }
</style>

<div class="error-container">
    <div class="error-card">
        <div class="error-badge">
            <svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"></path>
                <line x1="12" y1="8" x2="12" y2="12"></line>
                <line x1="12" y1="16" x2="12.01" y2="16"></line>
            </svg>
        </div>
        <div class="error-code">403</div>
        <h1 class="error-title">Access Denied · Insufficient Privileges</h1>
        <p class="error-desc">
            Your authenticated session as <strong style="color:#ffffff;"><c:out value="${sessionScope.account.username}"/></strong> 
            (Role: <span class="role-badge role-${sessionScope.account.role}" style="font-size:11px;"><c:out value="${sessionScope.account.role.label}"/></span>) 
            does not hold the necessary security clearance to view this resource.
        </p>
        <a class="btn btn-primary" href="${pageContext.request.contextPath}${sessionScope.account.role.homePath}" style="padding: 10px 24px;">
            Return to Dashboard
        </a>
    </div>
</div>

<%@ include file="footer.jspf" %>
