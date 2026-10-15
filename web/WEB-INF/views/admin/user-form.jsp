<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="pageTitle" value="${form.create ? 'Add User' : 'Edit User'}"/>
<c:set var="activeNav" value="users"/>
<%@ include file="../common/header.jspf" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<div class="page-head">
    <div>
        <a class="back" href="${ctx}/admin/users">← Back to Users</a>
        <h1>${pageTitle}</h1>
    </div>
</div>

<c:if test="${not empty errors}">
    <div class="alert alert-error">Found ${errors.size()} error(s). Please check the highlighted fields below.</div>
</c:if>

<form method="post" class="card form-grid" novalidate
      action="${ctx}/admin/users/${form.create ? 'create' : 'edit'}">
    <c:if test="${not form.create}"><input type="hidden" name="id" value="${form.accountId}"></c:if>

    <h2 class="section-title">Account Details</h2>

    <label class="${not empty errors.role ? 'has-error' : ''}">Role *
        <select name="role" id="role">
            <c:forEach var="r" items="${roles}">
                <option value="${r}" ${form.role == r.name() ? 'selected' : ''}>${r.label} (${r})</option>
            </c:forEach>
        </select>
        <span class="err"><c:out value="${errors.role}"/></span>
    </label>

    <label class="${not empty errors.username ? 'has-error' : ''}">Username *
        <input type="text" name="username" value="<c:out value='${form.username}'/>"
               ${form.create ? '' : 'readonly'} maxlength="30" placeholder="e.g. an.nguyen">
        <span class="hint">4-30 chars: a-z, 0-9, dot (.) and underscore (_)</span>
        <span class="err"><c:out value="${errors.username}"/></span>
    </label>

    <c:if test="${form.create}">
        <label class="${not empty errors.password ? 'has-error' : ''}">Password *
            <input type="password" name="password" maxlength="50" autocomplete="new-password">
            <span class="hint">≥ 8 characters, including uppercase, lowercase, digits &amp; symbols</span>
            <span class="err"><c:out value="${errors.password}"/></span>
        </label>
        <label class="${not empty errors.confirmPassword ? 'has-error' : ''}">Confirm Password *
            <input type="password" name="confirmPassword" maxlength="50" autocomplete="new-password">
            <span class="err"><c:out value="${errors.confirmPassword}"/></span>
        </label>
    </c:if>

    <div id="employee-fields" class="form-grid-inner">
        <h2 class="section-title">Employee Information</h2>

        <label class="${not empty errors.code ? 'has-error' : ''}">Employee Code *
            <input type="text" name="code" value="<c:out value='${form.code}'/>" ${form.create ? '' : 'readonly'} maxlength="8">
            <span class="err"><c:out value="${errors.code}"/></span>
        </label>

        <label class="${not empty errors.fullName ? 'has-error' : ''}">Full Name *
            <input type="text" name="fullName" value="<c:out value='${form.fullName}'/>" maxlength="100">
            <span class="err"><c:out value="${errors.fullName}"/></span>
        </label>

        <label class="${not empty errors.email ? 'has-error' : ''}">Email *
            <input type="email" name="email" value="<c:out value='${form.email}'/>" maxlength="100">
            <span class="err"><c:out value="${errors.email}"/></span>
        </label>

        <label class="${not empty errors.phone ? 'has-error' : ''}">Phone Number *
            <input type="tel" name="phone" value="<c:out value='${form.phone}'/>" maxlength="10" placeholder="09xxxxxxxx">
            <span class="err"><c:out value="${errors.phone}"/></span>
        </label>

        <label class="${not empty errors.department ? 'has-error' : ''}">Department *
            <select name="department">
                <option value="">-- Select Department --</option>
                <c:forEach var="d" items="${departments}">
                    <option ${form.department == d ? 'selected' : ''}><c:out value="${d}"/></option>
                </c:forEach>
            </select>
            <span class="err"><c:out value="${errors.department}"/></span>
        </label>

        <label class="${not empty errors.position ? 'has-error' : ''}">Position *
            <input type="text" name="position" value="<c:out value='${form.position}'/>" maxlength="50">
            <span class="err"><c:out value="${errors.position}"/></span>
        </label>

        <label class="${not empty errors.salaryType ? 'has-error' : ''}">Salary Type *
            <select name="salaryType">
                <option value="MONTHLY" ${form.salaryType == 'MONTHLY' ? 'selected' : ''}>Monthly</option>
                <option value="HOURLY" ${form.salaryType == 'HOURLY' ? 'selected' : ''}>Hourly</option>
            </select>
            <span class="err"><c:out value="${errors.salaryType}"/></span>
        </label>

        <label class="${not empty errors.baseSalary ? 'has-error' : ''}">Base Salary (VND) *
            <input type="text" name="baseSalary" value="<c:out value='${form.baseSalary}'/>" inputmode="numeric" placeholder="8320000">
            <span class="err"><c:out value="${errors.baseSalary}"/></span>
        </label>
    </div>

    <div class="form-actions">
        <a class="btn btn-ghost" href="${ctx}/admin/users">Cancel</a>
        <button class="btn" type="submit">${form.create ? 'Create User' : 'Save Changes'}</button>
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
