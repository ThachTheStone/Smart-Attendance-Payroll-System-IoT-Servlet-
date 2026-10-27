<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="pageTitle" value="Shift Management"/>
<c:set var="activeNav" value="shifts"/>
<c:set var="scheduleTab" value="types"/>
<%@ include file="../../common/header.jspf" %>
<%@ include file="../../common/schedule-tabs.jspf" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<style>
    .shifts-hero {
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
    .shifts-hero h1 {
        font-size: 22px;
        font-weight: 700;
        letter-spacing: -0.02em;
        margin: 0;
        color: #0f172a;
    }
    .hero-actions {
        display: flex;
        gap: 8px;
    }

    /* 2-Column Layout */
    .shifts-grid {
        display: grid;
        grid-template-columns: 2fr 1fr;
        gap: 20px;
        align-items: start;
    }

    /* Table Section */
    .shifts-table-card {
        background: #ffffff;
        border: 1px solid var(--border);
        border-radius: var(--radius-lg);
        overflow: hidden;
        box-shadow: var(--shadow-xs);
    }
    .shifts-table-header {
        padding: 14px 18px;
        border-bottom: 1px solid var(--border);
        display: flex;
        align-items: center;
        gap: 8px;
        font-weight: 600;
        font-size: 14px;
        color: #0f172a;
        background: #f8fafc;
    }
    .shifts-table {
        width: 100%;
        border-collapse: collapse;
    }
    .shifts-table th {
        font-size: 11px;
        font-weight: 700;
        color: #475569;
        background: #f8fafc;
        padding: 10px 14px;
        border-bottom: 1px solid var(--border);
        text-transform: uppercase;
        letter-spacing: 0.05em;
    }
    .shifts-table td {
        padding: 12px 14px;
        border-bottom: 1px solid #f1f5f9;
        font-size: 13px;
        vertical-align: middle;
        color: #334155;
    }
    .shifts-table tr:last-child td { border-bottom: 0; }
    .shifts-table tr:hover td {
        background: #f8fafc;
    }

    .shift-type-badge {
        display: inline-flex;
        align-items: center;
        gap: 5px;
        padding: 3px 8px;
        border-radius: 6px;
        font-size: 11px;
        font-weight: 600;
    }
    .shift-type-badge.day {
        background: #eff6ff;
        color: #1d4ed8;
        border: 1px solid #bfdbfe;
    }
    .shift-type-badge.night {
        background: #fffbeb;
        color: #b45309;
        border: 1px solid #fde68a;
    }

    /* Form Card */
    .shift-form-card {
        background: #ffffff;
        border: 1px solid var(--border);
        border-radius: var(--radius-lg);
        padding: 20px;
        position: sticky;
        top: 80px;
        box-shadow: var(--shadow-sm);
    }
    .shift-form-title {
        font-size: 15px;
        font-weight: 700;
        color: #0f172a;
        margin: 0 0 16px 0;
        display: flex;
        align-items: center;
        gap: 8px;
    }
    .form-field {
        margin-bottom: 14px;
    }
    .form-field-label {
        display: block;
        font-weight: 600;
        margin-bottom: 4px;
        font-size: 12px;
        color: #334155;
    }
    .form-field-label .required {
        color: #dc2626;
    }
    .form-field input {
        width: 100%;
        padding: 8px 12px;
        border: 1px solid #cbd5e1 !important;
        border-radius: 7px;
        font-size: 13px;
        background: #ffffff !important;
        color: #0f172a !important;
        transition: border-color var(--transition-fast), box-shadow var(--transition-fast);
        outline: none;
    }
    .form-field select {
        width: 100%;
        padding: 8px 34px 8px 12px;
        border: 1px solid #cbd5e1 !important;
        border-radius: 7px;
        font-size: 13px;
        background-color: #ffffff !important;
        background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='16' height='16' viewBox='0 0 24 24' fill='none' stroke='%2364748b' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpolyline points='6 9 12 15 18 9'%3E%3C/polyline%3E%3C/svg%3E") !important;
        background-repeat: no-repeat !important;
        background-position: right 10px center !important;
        background-size: 14px 14px !important;
        color: #0f172a !important;
        transition: border-color var(--transition-fast), box-shadow var(--transition-fast);
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
    .form-field .hint {
        display: block;
        margin-top: 4px;
        color: #64748b;
        font-size: 11px;
    }

    @media (max-width: 900px) {
        .shifts-grid { grid-template-columns: 1fr; }
        .shift-form-card { position: static; }
    }
</style>

<!-- Hero Header -->
<div class="shifts-hero">
    <div>
        <h1>Shift types</h1>
        <p class="muted" style="margin: 4px 0 0;">The shifts you can assign on the weekly schedule: start and end times, breaks, overnight shifts</p>
    </div>
</div>

<!-- 2-Column Layout -->
<div class="shifts-grid">
    <!-- Left: Shifts Table -->
    <div class="shifts-table-card">
        <div class="shifts-table-header">
            <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
            Shift Definitions
        </div>
        <table class="shifts-table">
            <thead>
                <tr>
                    <th>Shift Name</th>
                    <th>Start</th>
                    <th>End</th>
                    <th>Break</th>
                    <th>Type</th>
                    <th style="text-align: right;">Actions</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="s" items="${shifts}">
                    <tr>
                        <td><strong style="color: #0f172a;"><c:out value="${s.name}"/></strong></td>
                        <td class="mono font-bold" style="color:#059669;">${s.startTime}</td>
                        <td class="mono font-bold" style="color:#2563eb;">${s.endTime}</td>
                        <td>${s.breakMinutes} mins</td>
                        <td>
                            <c:choose>
                                <c:when test="${s.overnight}">
                                    <span class="shift-type-badge night">
                                        <svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"/></svg>
                                        Overnight
                                    </span>
                                </c:when>
                                <c:otherwise>
                                    <span class="shift-type-badge day">
                                        <svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="5"/><line x1="12" y1="1" x2="12" y2="3"/><line x1="12" y1="21" x2="12" y2="23"/><line x1="4.22" y1="4.22" x2="5.64" y2="5.64"/><line x1="18.36" y1="18.36" x2="19.78" y2="19.78"/><line x1="1" y1="12" x2="3" y2="12"/><line x1="21" y1="12" x2="23" y2="12"/><line x1="4.22" y1="19.78" x2="5.64" y2="18.36"/><line x1="18.36" y1="5.64" x2="19.78" y2="4.22"/></svg>
                                        Daytime
                                    </span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <td style="text-align: right;">
                            <div class="actions">
                                <a class="btn btn-ghost btn-sm" href="${ctx}/admin/shifts?action=edit&id=${s.id}">Edit</a>
                                <form action="${ctx}/admin/shifts" method="post" style="display: inline;" onsubmit="return confirm('Delete this shift?');">
                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="id" value="${s.id}">
                                    <button type="submit" class="btn btn-ghost btn-sm" style="color:var(--danger);">Delete</button>
                                </form>
                            </div>
                        </td>
                    </tr>
                </c:forEach>
                <c:if test="${empty shifts}">
                    <tr><td colspan="6" style="text-align:center; padding: 32px; color: var(--muted);">No shifts configured yet. Add one using the form on the right.</td></tr>
                </c:if>
            </tbody>
        </table>
    </div>

    <!-- Right: Add / Edit Form -->
    <div class="shift-form-card">
        <h3 class="shift-form-title">
            <c:choose>
                <c:when test="${not empty shift}">
                    <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
                    Edit Shift
                </c:when>
                <c:otherwise>
                    <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                    Add New Shift
                </c:otherwise>
            </c:choose>
        </h3>
        <form action="${ctx}/admin/shifts" method="post">
            <input type="hidden" name="action" value="save">
            <input type="hidden" name="id" value="${not empty shift ? shift.id : ''}">

            <div class="form-field">
                <span class="form-field-label">Shift Name <span class="required">*</span></span>
                <input type="text" name="name" required value="<c:out value='${shift.name}'/>" placeholder="e.g. Morning Shift (06:00 - 14:00)">
            </div>

            <div class="form-field">
                <span class="form-field-label">Start Time <span class="required">*</span></span>
                <input type="time" name="startTime" required value="${not empty shift ? shift.formattedStartTime : '06:00'}">
            </div>

            <div class="form-field">
                <span class="form-field-label">End Time <span class="required">*</span></span>
                <input type="time" name="endTime" required value="${not empty shift ? shift.formattedEndTime : '14:00'}">
                <span class="hint">If end &lt; start (e.g. 22:00 &rarr; 06:00), treated as overnight.</span>
            </div>

            <div class="form-field">
                <span class="form-field-label">Break Duration (minutes)</span>
                <input type="number" name="breakMinutes" min="0" max="180" value="${not empty shift ? shift.breakMinutes : 30}">
            </div>

            <div style="display:flex; gap:8px; margin-top: 16px;">
                <button type="submit" class="btn btn-primary" style="flex:1; justify-content:center;">
                    <c:choose>
                        <c:when test="${not empty shift}">Save Changes</c:when>
                        <c:otherwise>Add Shift</c:otherwise>
                    </c:choose>
                </button>
                <c:if test="${not empty shift}">
                    <a href="${ctx}/admin/shifts" class="btn btn-secondary">Cancel</a>
                </c:if>
            </div>
        </form>
    </div>
</div>

<%@ include file="../../common/footer.jspf" %>
