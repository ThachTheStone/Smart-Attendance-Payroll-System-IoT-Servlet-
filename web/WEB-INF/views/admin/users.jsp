<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="pageTitle" value="User Management"/>
<c:set var="activeNav" value="users"/>
<%@ include file="../common/header.jspf" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<div class="page-head">
    <div>
        <h1>User Management</h1>
        <p class="muted">Accounts, roles, and employee directory</p>
    </div>
    <a class="btn" href="${ctx}/admin/users/create">+ Add User</a>
</div>

<div class="stats">
    <div class="stat"><span class="stat-num">${totalCount}</span><span class="stat-label">Total Accounts</span></div>
    <div class="stat"><span class="stat-num">${adminCount}</span><span class="stat-label">Admins</span></div>
    <div class="stat"><span class="stat-num">${staffCount}</span><span class="stat-label">Staff</span></div>
    <div class="stat"><span class="stat-num">${inactiveCount}</span><span class="stat-label">Deactivated</span></div>
</div>

<form class="filters" method="get" action="${ctx}/admin/users">
    <input type="search" name="q" value="<c:out value='${q}'/>" placeholder="Search username, full name, code, email...">
    <select name="role">
        <option value="">All Roles</option>
        <c:forEach var="r" items="${roles}">
            <option value="${r}" ${roleFilter == r.name() ? 'selected' : ''}>${r.label}</option>
        </c:forEach>
    </select>
    <select name="status">
        <option value="">All Statuses</option>
        <option value="ACTIVE" ${statusFilter == 'ACTIVE' ? 'selected' : ''}>Active</option>
        <option value="INACTIVE" ${statusFilter == 'INACTIVE' ? 'selected' : ''}>Deactivated</option>
    </select>
    <button class="btn btn-secondary" type="submit">Filter</button>
    <c:if test="${not empty q or not empty roleFilter or not empty statusFilter}">
        <a class="btn btn-ghost" href="${ctx}/admin/users">Clear</a>
    </c:if>
</form>

<div class="table-wrap">
<table class="table">
    <thead>
    <tr>
        <th>Code</th><th>Full Name</th><th>Username</th><th>Role</th>
        <th>Department</th><th>Contact</th><th>Last Login</th><th>Status</th><th>Actions</th>
    </tr>
    </thead>
    <tbody>
    <c:forEach var="u" items="${users}">
        <tr class="${u.active ? '' : 'row-inactive'}">
            <td class="mono"><c:out value="${u.employee.code}" default="—"/></td>
            <td>
                <b><c:out value="${u.employee.fullName}" default="(Kiosk Terminal)"/></b>
                <div class="muted small"><c:out value="${u.employee.position}"/></div>
            </td>
            <td class="mono"><c:out value="${u.username}"/></td>
            <td><span class="role-badge role-${u.role}">${u.role.label}</span></td>
            <td><c:out value="${u.employee.department}" default="—"/></td>
            <td class="small">
                <c:out value="${u.employee.email}"/><br><c:out value="${u.employee.phone}"/>
            </td>
            <td class="small">
                <c:choose>
                    <c:when test="${not empty u.lastLogin}">${u.lastLogin.toString().replace('T', ' ').substring(0, 16)}</c:when>
                    <c:otherwise><span class="muted">Never</span></c:otherwise>
                </c:choose>
            </td>
            <td>
                <span class="status status-${u.status}">${u.active ? 'Active' : 'Inactive'}</span>
            </td>
            <td class="actions">
                <c:if test="${not empty u.employeeId}">
                    <a href="${ctx}/admin/employees/enroll?id=${u.employeeId}" style="color: var(--primary); font-weight: 500;">Biometrics</a>
                </c:if>
                <a href="${ctx}/admin/users/edit?id=${u.id}">Edit</a>
                <a href="${ctx}/admin/users/reset-password?id=${u.id}">Reset Pwd</a>
                <c:if test="${u.id != me.id}">
                    <form method="post" action="${ctx}/admin/users/status" class="inline"
                          onsubmit="return confirm('${u.active ? 'Deactivate' : 'Activate'} account ${u.username}?')">
                        <input type="hidden" name="id" value="${u.id}">
                        <input type="hidden" name="status" value="${u.active ? 'INACTIVE' : 'ACTIVE'}">
                        <button type="submit" class="link ${u.active ? 'danger' : ''}">${u.active ? 'Lock' : 'Unlock'}</button>
                    </form>
                </c:if>
            </td>
        </tr>
    </c:forEach>
    <c:if test="${empty users}">
        <tr><td colspan="9" class="empty">No users match the criteria.</td></tr>
    </c:if>
    </tbody>
</table>
</div>
<p class="muted small">Showing ${users.size()} of ${totalCount} accounts.</p>

<%@ include file="../common/footer.jspf" %>
