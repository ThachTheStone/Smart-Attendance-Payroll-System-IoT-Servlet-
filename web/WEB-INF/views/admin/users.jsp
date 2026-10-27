<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="pageTitle" value="User Management"/>
<c:set var="activeNav" value="users"/>
<%@ include file="../common/header.jspf" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<style>
    .users-hero {
        display: flex;
        justify-content: space-between;
        align-items: center;
        flex-wrap: wrap;
        gap: 16px;
        margin-bottom: 24px;
        padding: 20px 24px;
        background: #ffffff;
        border: 1px solid var(--border);
        border-radius: var(--radius-lg);
        box-shadow: var(--shadow-sm);
    }
    .users-hero-title {
        font-size: 22px;
        font-weight: 700;
        letter-spacing: -0.02em;
        color: #0f172a;
        margin: 0;
    }
    .users-hero-desc {
        color: var(--muted);
        font-size: 13px;
        margin-top: 4px;
    }
    .add-user-btn {
        display: inline-flex;
        align-items: center;
        gap: 8px;
        padding: 9px 16px;
        background: #1d4ed8;
        color: #ffffff;
        border: 1px solid #1e40af;
        border-radius: 8px;
        font-family: inherit;
        font-size: 13px;
        font-weight: 600;
        text-decoration: none;
        cursor: pointer;
        transition: background-color var(--transition-fast);
        box-shadow: 0 1px 2px rgba(29, 78, 216, 0.2);
    }
    .add-user-btn:hover {
        background: #1e40af;
        color: #ffffff;
    }

    /* KPI Row */
    .user-kpi-row {
        display: grid;
        grid-template-columns: repeat(4, 1fr);
        gap: 14px;
        margin-bottom: 20px;
    }
    .user-kpi {
        background: #ffffff !important;
        border: 1px solid var(--border) !important;
        border-radius: var(--radius-lg) !important;
        padding: 16px 20px !important;
        display: flex !important;
        flex-direction: row !important;
        align-items: center !important;
        text-align: left !important;
        gap: 16px !important;
        box-shadow: var(--shadow-xs);
        transition: border-color var(--transition-fast), box-shadow var(--transition-fast);
    }
    .user-kpi:hover {
        border-color: var(--border-hover) !important;
        box-shadow: var(--shadow-sm) !important;
    }
    .user-kpi-icon {
        width: 44px !important;
        height: 44px !important;
        border-radius: 10px !important;
        display: flex !important;
        align-items: center !important;
        justify-content: center !important;
        flex-shrink: 0 !important;
    }
    .user-kpi-icon.total { background: #eff6ff !important; color: #1d4ed8 !important; }
    .user-kpi-icon.admins { background: #eff6ff !important; color: #1d4ed8 !important; }
    .user-kpi-icon.staff { background: #ecfdf5 !important; color: #059669 !important; }
    .user-kpi-icon.inactive { background: #fef2f2 !important; color: #dc2626 !important; }
    .user-kpi-info {
        display: flex;
        flex-direction: column;
        justify-content: center;
        text-align: left !important;
    }
    .user-kpi-val {
        font-size: 24px !important;
        font-weight: 700 !important;
        font-family: var(--font-ui); font-variant-numeric: tabular-nums;
        line-height: 1.1 !important;
        color: #0f172a !important;
        text-align: left !important;
    }
    .user-kpi-label {
        font-size: 11px !important;
        color: var(--muted) !important;
        font-weight: 600 !important;
        text-transform: uppercase !important;
        letter-spacing: 0.04em !important;
        margin-top: 3px !important;
        text-align: left !important;
    }

    /* Filter Card */
    .filter-card {
        background: #ffffff;
        border: 1px solid var(--border);
        border-radius: var(--radius);
        padding: 12px 16px;
        margin-bottom: 20px;
        display: flex;
        gap: 10px;
        flex-wrap: wrap;
        align-items: center;
        box-shadow: var(--shadow-xs);
    }
    .filter-card input[type=search] {
        flex: 1;
        min-width: 220px;
        padding: 8px 12px;
        border: 1px solid #cbd5e1;
        border-radius: 7px;
        font-size: 13px;
        background: #ffffff;
        color: #0f172a;
    }
    .filter-card select {
        padding: 8px 32px 8px 12px;
        border: 1px solid #cbd5e1;
        border-radius: 7px;
        font-size: 13px;
        background-color: #ffffff;
        background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='16' height='16' viewBox='0 0 24 24' fill='none' stroke='%2364748b' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpolyline points='6 9 12 15 18 9'%3E%3C/polyline%3E%3C/svg%3E");
        background-repeat: no-repeat;
        background-position: right 10px center;
        background-size: 14px 14px;
        color: #0f172a;
        width: auto;
        appearance: none;
        -webkit-appearance: none;
        cursor: pointer;
        outline: none;
    }
    .filter-card select::-ms-expand {
        display: none;
    }
    .filter-card select:focus {
        border-color: #1d4ed8;
        box-shadow: 0 0 0 3px rgba(29, 78, 216, 0.12);
    }

    /* Enhanced Table */
    .users-table-wrap {
        background: #ffffff;
        border: 1px solid var(--border);
        border-radius: var(--radius-lg);
        overflow-x: auto;
        box-shadow: var(--shadow-xs);
    }
    .users-table {
        width: 100%;
        min-width: 960px;
        border-collapse: collapse;
    }

    /* Role and status: larger, easy to scan */
    .users-table .role-badge {
        font-size: 13px;
        font-weight: 600;
        padding: 4px 10px;
        white-space: nowrap;
    }
    .users-table .status-active { background: #ecfdf3; color: #15803d; border: 1px solid #bbf7d0; }
    .users-table .status-inactive { background: #f1f5f9; color: #475569; border: 1px solid #e2e8f0; }

    /* Row actions: equal buttons in a fixed 2 x 2 grid (Edit, Bio / Reset, Lock),
       one row on wide screens. Every row keeps the same positions. */
    .users-table .actions {
        display: grid;
        grid-template-columns: repeat(2, 64px);
        gap: 6px;
    }
    .users-table .actions form.inline { margin: 0; }
    .users-table .actions .action-link { width: 100%; min-width: 0; }
    .users-table .actions .action-link.is-empty { visibility: hidden; }
    @media (min-width: 1680px) {
        .users-table .actions { grid-template-columns: repeat(4, 64px); }
    }
    .users-table th {
        font-size: 11px;
        font-weight: 700;
        color: #475569;
        background: #f8fafc;
        padding: 11px 12px;
        border-bottom: 1px solid var(--border);
        text-transform: uppercase;
        letter-spacing: 0.05em;
        white-space: nowrap;
    }
    .users-table td {
        padding: 12px 12px;
        border-bottom: 1px solid #f1f5f9;
        vertical-align: middle;
        font-size: 13px;
        color: #334155;
    }
    .users-table tr:last-child td { border-bottom: 0; }
    .users-table tbody tr:hover td {
        background: #f8fafc;
    }
    .users-table .row-inactive td {
        opacity: 0.5;
    }

    /* User Avatar Circle */
    .user-avatar {
        width: 32px;
        height: 32px;
        border-radius: 8px;
        display: grid;
        place-items: center;
        font-size: 12px;
        font-weight: 700;
        flex-shrink: 0;
    }
    .user-avatar.admin-av { background: #eff6ff; color: #1d4ed8; }
    .user-avatar.staff-av { background: #eff6ff; color: #1d4ed8; }
    .user-avatar.kiosk-av { background: #f5f3ff; color: #7c3aed; }

    .user-name-cell {
        display: flex;
        align-items: center;
        gap: 10px;
    }

    .action-link {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        gap: 5px;
        height: 30px;
        min-width: 58px;
        padding: 0 10px;
        border: 1px solid var(--border) !important;
        border-radius: 5px;
        background: #ffffff !important;
        font-family: inherit;
        font-size: 12.5px;
        font-weight: 500;
        color: var(--text);
        text-decoration: none;
        white-space: nowrap;
        cursor: pointer;
        transition: border-color var(--transition-fast), color var(--transition-fast);
    }
    .action-link:hover {
        border-color: var(--primary) !important;
        color: var(--primary);
        text-decoration: none;
    }
    .action-link.danger {
        color: var(--danger);
    }
    .action-link.danger:hover {
        border-color: var(--danger) !important;
        color: var(--danger);
    }

    .results-info {
        padding: 11px 16px;
        background: #f8fafc;
        border-top: 1px solid var(--border);
        font-size: 12px;
        color: var(--muted);
    }

    @media (max-width: 900px) {
        .user-kpi-row { grid-template-columns: repeat(2, 1fr); }
    }
    @media (max-width: 640px) {
        .user-kpi-row { grid-template-columns: 1fr; }
    }
</style>

<!-- Page Hero Header -->
<div class="users-hero">
    <div>
        <h1 class="users-hero-title">User Management</h1>
        <p class="users-hero-desc">Accounts, role permissions, biometric enrollment, and staff directory</p>
    </div>
    <a class="add-user-btn" href="${ctx}/admin/users/create">
        <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
        Add New User
    </a>
</div>

<!-- KPI Stats Row -->
<div class="user-kpi-row">
    <div class="user-kpi">
        <div class="user-kpi-icon total">
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
        </div>
        <div class="user-kpi-info">
            <div class="user-kpi-val">${totalCount}</div>
            <div class="user-kpi-label">Total Accounts</div>
        </div>
    </div>
    <div class="user-kpi">
        <div class="user-kpi-icon admins">
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 15a3 3 0 1 0 0-6 3 3 0 0 0 0 6z"/><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-2.82.33V21a2 2 0 0 1-4 0v-.09a1.65 1.65 0 0 0-2.82-.33l-.06.06a2 2 0 0 1-2.83-2.83l.06-.06A1.65 1.65 0 0 0 4.6 15H3a2 2 0 0 1 0-4h.09A1.65 1.65 0 0 0 4.6 9l-.06-.06a2 2 0 0 1 2.83-2.83l.06.06A1.65 1.65 0 0 0 10 5.6V3a2 2 0 0 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 2.83l-.06.06A1.65 1.65 0 0 0 19.4 9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z"/></svg>
        </div>
        <div class="user-kpi-info">
            <div class="user-kpi-val">${adminCount}</div>
            <div class="user-kpi-label">Administrators</div>
        </div>
    </div>
    <div class="user-kpi">
        <div class="user-kpi-icon staff">
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
        </div>
        <div class="user-kpi-info">
            <div class="user-kpi-val">${staffCount}</div>
            <div class="user-kpi-label">Staff Members</div>
        </div>
    </div>
    <div class="user-kpi">
        <div class="user-kpi-icon inactive">
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="4.93" y1="4.93" x2="19.07" y2="19.07"/></svg>
        </div>
        <div class="user-kpi-info">
            <div class="user-kpi-val">${inactiveCount}</div>
            <div class="user-kpi-label">Deactivated</div>
        </div>
    </div>
</div>

<!-- Filter Bar -->
<form class="filter-card" method="get" action="${ctx}/admin/users">
    <input type="search" name="q" value="<c:out value='${q}'/>" placeholder="Search username, name, code, email...">
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
    <button class="btn btn-secondary" type="submit">
        <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
        Filter
    </button>
    <c:if test="${not empty q or not empty roleFilter or not empty statusFilter}">
        <a class="btn btn-ghost" href="${ctx}/admin/users">Clear</a>
    </c:if>
</form>

<!-- Users Table -->
<div class="users-table-wrap">
    <table class="users-table">
        <thead>
        <tr>
            <th>Employee</th><th>Username</th><th>Role</th>
            <th>Department</th><th>Contact</th><th>Last Login</th><th>Status</th><th>Actions</th>
        </tr>
        </thead>
        <tbody>
        <c:forEach var="u" items="${users}">
            <tr class="${u.active ? '' : 'row-inactive'}">
                <td>
                    <div class="user-name-cell">
                        <div class="user-avatar ${u.role == 'ADMIN' ? 'admin-av' : u.role == 'KIOSK' ? 'kiosk-av' : 'staff-av'}">
                            <c:choose>
                                <c:when test="${not empty u.employee.fullName}">
                                    ${u.employee.fullName.substring(0, 1)}
                                </c:when>
                                <c:otherwise>K</c:otherwise>
                            </c:choose>
                        </div>
                        <div>
                            <b><c:out value="${u.employee.fullName}" default="(Kiosk Terminal)"/></b>
                            <div class="muted small"><c:if test="${not empty u.employee.code}"><span style="color: var(--text); font-weight: 600;"><c:out value="${u.employee.code}"/></span> &middot; </c:if><c:out value="${u.employee.position}"/></div>
                        </div>
                    </div>
                </td>
                <td class="mono"><c:out value="${u.username}"/></td>
                <td><span class="role-badge role-${u.role}">${u.role.label}</span></td>
                <td><c:out value="${u.employee.department}" default="—"/></td>
                <td class="small">
                    <c:out value="${u.employee.email}"/><br><c:out value="${u.employee.phone}"/>
                </td>
                <td class="small mono">
                    <c:choose>
                        <c:when test="${not empty u.lastLogin}">${u.lastLogin.toString().replace('T', ' ').substring(0, 16)}</c:when>
                        <c:otherwise><span class="muted">Never</span></c:otherwise>
                    </c:choose>
                </td>
                <td>
                    <span class="role-badge ${u.active ? 'status-active' : 'status-inactive'}">${u.active ? 'Active' : 'Locked'}</span>
                </td>
                <td>
                    <div class="actions">
                        <a href="${ctx}/admin/users/edit?id=${u.id}" class="action-link" title="Edit account and employee details">Edit</a>
                        <c:choose>
                            <c:when test="${not empty u.employeeId}">
                                <a href="${ctx}/admin/employees/enroll?id=${u.employeeId}" class="action-link" title="Enroll or manage fingerprints">Bio</a>
                            </c:when>
                            <c:otherwise><span class="action-link is-empty" aria-hidden="true"></span></c:otherwise>
                        </c:choose>
                        <a href="${ctx}/admin/users/reset-password?id=${u.id}" class="action-link" title="Reset password">Reset</a>
                        <c:if test="${u.id != me.id}">
                            <form method="post" action="${ctx}/admin/users/status" class="inline"
                                  onsubmit="return confirm('${u.active ? 'Deactivate' : 'Activate'} account ${u.username}?')">
                                <input type="hidden" name="id" value="${u.id}">
                                <input type="hidden" name="status" value="${u.active ? 'INACTIVE' : 'ACTIVE'}">
                                <button type="submit" class="action-link ${u.active ? 'danger' : ''}" title="${u.active ? 'Lock this account' : 'Unlock this account'}">
                                    ${u.active ? 'Lock' : 'Unlock'}
                                </button>
                            </form>
                        </c:if>
                    </div>
                </td>
            </tr>
        </c:forEach>
        <c:if test="${empty users}">
            <tr><td colspan="8" class="empty" style="text-align: center; padding: 32px; color: var(--muted);">No users match the criteria.</td></tr>
        </c:if>
        </tbody>
    </table>
    <div class="results-info">
        Showing ${users.size()} of ${totalCount} accounts
    </div>
</div>

<%@ include file="../common/footer.jspf" %>
