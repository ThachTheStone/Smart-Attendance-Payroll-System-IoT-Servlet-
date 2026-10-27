<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="pageTitle" value="${form.create ? 'Add User' : 'Edit User'}"/>
<c:set var="activeNav" value="users"/>
<%@ include file="../common/header.jspf" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<style>
    .form-hero {
        margin-bottom: 24px;
        background: #ffffff;
        border: 1px solid var(--border);
        border-radius: var(--radius-lg);
        box-shadow: var(--shadow-sm);
        padding: 20px 24px;
    }
    .form-hero .back-link {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        font-size: 13px;
        font-weight: 500;
        color: #64748b;
        text-decoration: none;
        transition: color var(--transition-fast);
        margin-bottom: 8px;
    }
    .form-hero .back-link:hover {
        color: #1d4ed8;
    }
    .form-hero h1 {
        font-size: 22px;
        font-weight: 700;
        letter-spacing: -0.02em;
        margin: 0;
        color: #0f172a;
    }

    /* Form Card */
    .user-form-card {
        background: #ffffff;
        border: 1px solid var(--border);
        border-radius: var(--radius-lg);
        padding: 28px;
        max-width: 720px;
        color: #0f172a;
        box-shadow: var(--shadow-sm);
    }
    .form-section-title {
        font-size: 14px;
        font-weight: 700;
        color: #0f172a;
        margin: 24px 0 16px 0;
        padding-top: 18px;
        border-top: 1px solid var(--border);
        display: flex;
        align-items: center;
        gap: 8px;
    }
    .form-section-title:first-of-type {
        border-top: 0;
        padding-top: 0;
        margin-top: 0;
    }
    .form-row {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 16px 20px;
    }
    .form-field {
        display: flex;
        flex-direction: column;
        gap: 6px;
    }
    .form-field.full {
        grid-column: 1 / -1;
    }
    .form-label {
        font-weight: 600;
        font-size: 12px;
        color: #334155;
    }
    .form-label .required {
        color: #dc2626;
    }
    .form-field input {
        padding: 9px 12px;
        border: 1px solid #cbd5e1 !important;
        border-radius: 7px;
        font-size: 13px;
        font-family: inherit;
        background: #ffffff !important;
        color: #0f172a !important;
        transition: border-color var(--transition-fast), box-shadow var(--transition-fast);
        width: 100%;
        outline: none;
    }
    .form-field select {
        padding: 9px 34px 9px 12px;
        border: 1px solid #cbd5e1 !important;
        border-radius: 7px;
        font-size: 13px;
        font-family: inherit;
        background-color: #ffffff !important;
        background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='16' height='16' viewBox='0 0 24 24' fill='none' stroke='%2364748b' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpolyline points='6 9 12 15 18 9'%3E%3C/polyline%3E%3C/svg%3E") !important;
        background-repeat: no-repeat !important;
        background-position: right 10px center !important;
        background-size: 14px 14px !important;
        color: #0f172a !important;
        transition: border-color var(--transition-fast), box-shadow var(--transition-fast);
        width: 100%;
        appearance: none !important;
        -webkit-appearance: none !important;
        cursor: pointer;
        outline: none;
    }
    .form-field select::-ms-expand {
        display: none !important;
    }
    .form-field input:focus,
    .form-field select:focus {
        border-color: #1d4ed8 !important;
        box-shadow: 0 0 0 3px rgba(29, 78, 216, 0.12) !important;
        outline: none;
    }
    .form-field.has-error input,
    .form-field.has-error select {
        border-color: #dc2626 !important;
        background: #fef2f2 !important;
    }
    .form-hint {
        font-size: 11px;
        color: #64748b;
    }
    .form-error {
        font-size: 12px;
        color: #dc2626;
        font-weight: 500;
    }
    .form-error:empty { display: none; }

    .form-footer {
        display: flex;
        justify-content: flex-end;
        gap: 10px;
        margin-top: 24px;
        padding-top: 18px;
        border-top: 1px solid var(--border);
    }

    @media (max-width: 640px) {
        .form-row { grid-template-columns: 1fr; }
        .user-form-card { padding: 20px 16px; }
    }
</style>

<div class="form-hero">
    <a class="back-link" href="${ctx}/admin/users">
        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 18 9 12 15 6"/></svg>
        Back to Users
    </a>
    <h1>${pageTitle}</h1>
</div>

<c:if test="${not empty errors}">
    <div class="alert alert-error" style="max-width: 720px;">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="flex-shrink:0;"><circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/></svg>
        Found ${errors.size()} error(s). Please check the highlighted fields below.
    </div>
</c:if>

<form method="post" class="user-form-card" novalidate
      action="${ctx}/admin/users/${form.create ? 'create' : 'edit'}">
    <c:if test="${not form.create}"><input type="hidden" name="id" value="${form.accountId}"></c:if>

    <h3 class="form-section-title">
        <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
        Account Details
    </h3>

    <div class="form-row">
        <div class="form-field ${not empty errors.role ? 'has-error' : ''}">
            <span class="form-label">Role <span class="required">*</span></span>
            <select name="role" id="role">
                <c:forEach var="r" items="${roles}">
                    <option value="${r}" ${form.role == r.name() ? 'selected' : ''}>${r.label} (${r})</option>
                </c:forEach>
            </select>
            <span class="form-error"><c:out value="${errors.role}"/></span>
        </div>

        <div class="form-field ${not empty errors.username ? 'has-error' : ''}">
            <span class="form-label">Username <span class="required">*</span></span>
            <input type="text" name="username" value="<c:out value='${form.username}'/>"
                   ${form.create ? '' : 'readonly'} maxlength="30" placeholder="e.g. an.nguyen">
            <span class="form-hint">4-30 chars: a-z, 0-9, dot (.) and underscore (_)</span>
            <span class="form-error"><c:out value="${errors.username}"/></span>
        </div>

        <c:if test="${form.create}">
            <div class="form-field ${not empty errors.password ? 'has-error' : ''}">
                <span class="form-label">Password <span class="required">*</span></span>
                <input type="password" name="password" maxlength="50" autocomplete="new-password">
                <span class="form-hint">&ge; 8 characters, uppercase, lowercase, digits &amp; symbols</span>
                <span class="form-error"><c:out value="${errors.password}"/></span>
            </div>
            <div class="form-field ${not empty errors.confirmPassword ? 'has-error' : ''}">
                <span class="form-label">Confirm Password <span class="required">*</span></span>
                <input type="password" name="confirmPassword" maxlength="50" autocomplete="new-password">
                <span class="form-error"><c:out value="${errors.confirmPassword}"/></span>
            </div>
        </c:if>
    </div>

    <div id="employee-fields">
        <h3 class="form-section-title">
            <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
            Employee Information
        </h3>

        <div class="form-row">
            <div class="form-field ${not empty errors.code ? 'has-error' : ''}">
                <span class="form-label">Employee Code <span class="required">*</span></span>
                <input type="text" name="code" value="<c:out value='${form.code}'/>" ${form.create ? '' : 'readonly'} maxlength="8">
                <span class="form-error"><c:out value="${errors.code}"/></span>
            </div>

            <div class="form-field ${not empty errors.fullName ? 'has-error' : ''}">
                <span class="form-label">Full Name <span class="required">*</span></span>
                <input type="text" name="fullName" value="<c:out value='${form.fullName}'/>" maxlength="100">
                <span class="form-error"><c:out value="${errors.fullName}"/></span>
            </div>

            <div class="form-field ${not empty errors.email ? 'has-error' : ''}">
                <span class="form-label">Email <span class="required">*</span></span>
                <input type="email" name="email" value="<c:out value='${form.email}'/>" maxlength="100">
                <span class="form-error"><c:out value="${errors.email}"/></span>
            </div>

            <div class="form-field ${not empty errors.phone ? 'has-error' : ''}">
                <span class="form-label">Phone Number <span class="required">*</span></span>
                <input type="tel" name="phone" value="<c:out value='${form.phone}'/>" maxlength="10" placeholder="09xxxxxxxx">
                <span class="form-error"><c:out value="${errors.phone}"/></span>
            </div>

            <div class="form-field ${not empty errors.department ? 'has-error' : ''}">
                <span class="form-label">Department <span class="required">*</span></span>
                <select name="department">
                    <option value="">-- Select Department --</option>
                    <c:forEach var="d" items="${departments}">
                        <option ${form.department == d ? 'selected' : ''}><c:out value="${d}"/></option>
                    </c:forEach>
                </select>
                <span class="form-error"><c:out value="${errors.department}"/></span>
            </div>

            <div class="form-field ${not empty errors.position ? 'has-error' : ''}">
                <span class="form-label">Position <span class="required">*</span></span>
                <input type="text" name="position" value="<c:out value='${form.position}'/>" maxlength="50">
                <span class="form-error"><c:out value="${errors.position}"/></span>
            </div>

            <div class="form-field ${not empty errors.salaryType ? 'has-error' : ''}">
                <span class="form-label">Salary Type <span class="required">*</span></span>
                <select name="salaryType">
                    <option value="MONTHLY" ${form.salaryType == 'MONTHLY' ? 'selected' : ''}>Monthly</option>
                    <option value="HOURLY" ${form.salaryType == 'HOURLY' ? 'selected' : ''}>Hourly</option>
                </select>
                <span class="form-error"><c:out value="${errors.salaryType}"/></span>
            </div>

            <div class="form-field ${not empty errors.baseSalary ? 'has-error' : ''}">
                <span class="form-label">Base Salary (VND) <span class="required">*</span></span>
                <input type="text" name="baseSalary" value="<c:out value='${form.baseSalary}'/>" inputmode="numeric" placeholder="8320000">
                <span class="form-error"><c:out value="${errors.baseSalary}"/></span>
            </div>
        </div>
    </div>

    <div class="form-footer">
        <a class="btn btn-ghost" href="${ctx}/admin/users">Cancel</a>
        <button class="btn btn-primary" type="submit">${form.create ? 'Create User' : 'Save Changes'}</button>
    </div>
</form>

<script>
    (function () {
        var role = document.getElementById('role');
        var box = document.getElementById('employee-fields');
        function sync() { box.style.display = role.value === 'KIOSK' ? 'none' : ''; }
        role.addEventListener('change', sync);
        sync();
    })();
</script>

<%@ include file="../common/footer.jspf" %>
