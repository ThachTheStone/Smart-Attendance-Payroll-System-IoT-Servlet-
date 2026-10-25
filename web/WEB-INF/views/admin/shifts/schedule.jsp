<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="pageTitle" value="Weekly Shift Schedule"/>
<c:set var="activeNav" value="shifts"/>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<%@ include file="../../common/header.jspf" %>

<style>
    .schedule-hero {
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
    .schedule-hero-title {
        font-size: 22px;
        font-weight: 700;
        letter-spacing: -0.02em;
        margin: 0;
        display: flex;
        align-items: center;
        gap: 10px;
        color: #0f172a;
    }
    .schedule-hero-desc {
        color: var(--muted);
        font-size: 13px;
        margin-top: 4px;
    }

    /* Week Navigation Toolbar */
    .week-toolbar {
        display: flex;
        justify-content: space-between;
        align-items: center;
        flex-wrap: wrap;
        gap: 14px;
        background: #ffffff;
        border: 1px solid var(--border);
        border-radius: var(--radius);
        padding: 12px 18px;
        margin-bottom: 20px;
        box-shadow: var(--shadow-xs);
    }
    .week-nav-controls {
        display: flex;
        align-items: center;
        gap: 8px;
    }
    .week-date-pill {
        display: inline-flex;
        align-items: center;
        gap: 8px;
        background: #f1f5f9;
        border: 1px solid #e2e8f0;
        padding: 6px 14px;
        border-radius: 7px;
        font-size: 13px;
        font-weight: 600;
        color: #0f172a;
        font-family: 'JetBrains Mono', monospace;
    }

    /* Matrix Table Card */
    .matrix-card {
        background: #ffffff;
        border: 1px solid var(--border);
        border-radius: var(--radius-lg);
        overflow-x: auto;
        margin-bottom: 28px;
        box-shadow: var(--shadow-xs);
    }
    .matrix-table {
        width: 100%;
        min-width: 960px;
        border-collapse: collapse;
        margin: 0;
    }
    .matrix-table th {
        background: #f8fafc;
        padding: 12px 14px;
        font-size: 11px;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 0.05em;
        color: #475569;
        border-bottom: 1px solid var(--border);
        text-align: center;
    }
    .matrix-table th.emp-th {
        text-align: left;
        width: 220px;
        background: #f8fafc;
        color: #0f172a;
        position: sticky;
        left: 0;
        z-index: 2;
        border-right: 1px solid var(--border);
    }
    .matrix-table td {
        padding: 10px 8px;
        border-bottom: 1px solid #f1f5f9;
        border-right: 1px solid #f1f5f9;
        vertical-align: top;
        font-size: 13px;
        color: #334155;
    }
    .matrix-table td.emp-td {
        background: #ffffff;
        position: sticky;
        left: 0;
        z-index: 1;
        border-right: 1px solid var(--border);
        color: #0f172a;
    }
    .matrix-table tr:hover td {
        background: #f8fafc;
    }
    .matrix-table tr:hover td.emp-td {
        background: #f1f5f9;
    }

    /* Shift Assignment Tag */
    .shift-tag {
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 6px;
        background: #eff6ff;
        color: #1d4ed8;
        border: 1px solid #bfdbfe;
        border-radius: 6px;
        padding: 4px 7px;
        font-size: 11px;
        font-weight: 600;
        margin-bottom: 4px;
    }
    .shift-tag.overnight {
        background: #fffbeb;
        color: #b45309;
        border-color: #fde68a;
    }
    .shift-tag-name {
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
        max-width: 95px;
    }
    .shift-del-btn {
        background: none;
        border: none;
        cursor: pointer;
        color: #64748b;
        font-size: 13px;
        line-height: 1;
        padding: 0 2px;
        border-radius: 3px;
    }
    .shift-del-btn:hover {
        color: #dc2626;
        background: #fef2f2;
    }

    /* Bulk Assignment Card */
    .bulk-card {
        background: #ffffff;
        border: 1px solid var(--border);
        border-radius: var(--radius-lg);
        padding: 24px;
        color: #0f172a;
        box-shadow: var(--shadow-sm);
    }
    .step-badge {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        width: 20px;
        height: 20px;
        border-radius: 50%;
        background: var(--primary);
        color: #ffffff;
        font-size: 11px;
        font-weight: 700;
        margin-right: 6px;
    }
    .emp-checkbox-grid {
        max-height: 200px;
        overflow-y: auto;
        border: 1px solid var(--border);
        border-radius: 8px;
        padding: 12px;
        background: #f8fafc;
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(210px, 1fr));
        gap: 8px;
    }
    .emp-checkbox-item {
        display: flex;
        align-items: center;
        gap: 8px;
        font-size: 12px;
        background: #ffffff;
        border: 1px solid #e2e8f0;
        color: #334155;
        padding: 6px 10px;
        border-radius: 6px;
        cursor: pointer;
    }
    .emp-checkbox-item:hover {
        border-color: var(--primary);
    }
    .day-pill-check {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        padding: 6px 12px;
        background: #ffffff;
        border: 1px solid #cbd5e1;
        color: #334155;
        border-radius: 6px;
        font-size: 12px;
        font-weight: 600;
        cursor: pointer;
    }
    .day-pill-check:hover {
        border-color: var(--primary);
        color: var(--primary);
    }
    .bulk-card select, .bulk-card input[type="date"] {
        padding: 8px 12px;
        border: 1px solid #cbd5e1;
        border-radius: 7px;
        font-size: 13px;
        background-color: #ffffff;
        color: #0f172a;
        font-family: inherit;
    }
    .bulk-card select {
        padding-right: 34px;
        background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='16' height='16' viewBox='0 0 24 24' fill='none' stroke='%2364748b' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpolyline points='6 9 12 15 18 9'%3E%3C/polyline%3E%3C/svg%3E");
        background-repeat: no-repeat;
        background-position: right 10px center;
        background-size: 14px 14px;
        appearance: none;
        -webkit-appearance: none;
        cursor: pointer;
    }
    .bulk-card select::-ms-expand {
        display: none;
    }
    .bulk-card select:focus, .bulk-card input[type="date"]:focus {
        border-color: #1d4ed8;
        box-shadow: 0 0 0 3px rgba(29, 78, 216, 0.12);
        outline: none;
    }
</style>

<!-- Hero Section -->
<div class="schedule-hero">
    <div>
        <h1 class="schedule-hero-title">
            Shift Schedule
        </h1>
        <p class="schedule-hero-desc">
            Assign employee shifts on a weekly roster or recurring pattern with overnight shift support
        </p>
    </div>
    <div style="display: flex; gap: 8px; flex-wrap: wrap;">
        <a class="btn btn-secondary" href="${ctx}/admin/shifts">Shift Definitions</a>
        <a class="btn btn-secondary" href="${ctx}/admin/holidays">Public Holidays</a>
        <a class="btn btn-primary" href="#assignBox">Bulk Assign Shifts</a>
    </div>
</div>

<!-- Week Navigation Toolbar -->
<div class="week-toolbar">
    <div class="week-nav-controls">
        <a class="btn btn-secondary btn-sm" href="${ctx}/admin/shifts/schedule?offset=${offset - 1}">
            &larr; Previous Week
        </a>
        <c:if test="${offset != 0}">
            <a class="btn btn-ghost btn-sm" href="${ctx}/admin/shifts/schedule?offset=0">
                Current Week
            </a>
        </c:if>
        <a class="btn btn-secondary btn-sm" href="${ctx}/admin/shifts/schedule?offset=${offset + 1}">
            Next Week &rarr;
        </a>
    </div>

    <div class="week-date-pill">
        <span>${monday}</span> &ndash; <span>${sunday}</span>
    </div>
</div>

<!-- Schedule Matrix Table Card -->
<div class="matrix-card">
    <table class="matrix-table">
        <thead>
            <tr>
                <th class="emp-th">Staff Member</th>
                <c:forEach var="day" items="${weekDays}">
                    <th style="width: 140px;">
                        <div style="font-weight: 700; font-size: 12px; color: var(--text);">
                            <c:choose>
                                <c:when test="${day.dayOfWeek.value == 1}">Mon</c:when>
                                <c:when test="${day.dayOfWeek.value == 2}">Tue</c:when>
                                <c:when test="${day.dayOfWeek.value == 3}">Wed</c:when>
                                <c:when test="${day.dayOfWeek.value == 4}">Thu</c:when>
                                <c:when test="${day.dayOfWeek.value == 5}">Fri</c:when>
                                <c:when test="${day.dayOfWeek.value == 6}"><span style="color:#fbbf24;">Sat</span></c:when>
                                <c:when test="${day.dayOfWeek.value == 7}"><span style="color:#f87171;">Sun</span></c:when>
                            </c:choose>
                        </div>
                        <div class="muted small mono" style="margin-top: 2px;">
                            ${day.dayOfMonth}/${day.monthValue}
                        </div>
                    </th>
                </c:forEach>
            </tr>
        </thead>
        <tbody>
            <c:forEach var="emp" items="${employees}">
                <tr>
                    <td class="emp-td">
                        <div style="font-weight: 600; color: #0f172a;"><c:out value="${emp.fullName}"/></div>
                        <div class="muted small" style="margin-top: 2px;">
                            <span class="mono font-bold" style="color: #2563eb;">${emp.code}</span>
                            <span> &bull; ${emp.department}</span>
                        </div>
                    </td>
                    <c:forEach var="day" items="${weekDays}">
                        <c:set var="cellKey" value="${emp.id}_${day}"/>
                        <c:set var="cellShifts" value="${grid[cellKey]}"/>
                        <td style="text-align: center;">
                            <c:choose>
                                <c:when test="${not empty cellShifts}">
                                    <c:forEach var="asgn" items="${cellShifts}">
                                        <div class="shift-tag ${asgn.startTime > asgn.endTime ? 'overnight' : ''}" title="${asgn.shiftName} (${asgn.startTime} - ${asgn.endTime})">
                                            <span class="shift-tag-name">
                                                ${asgn.shiftName}
                                            </span>
                                            <form action="${ctx}/admin/shifts/schedule" method="post" style="display:inline; margin:0;" onsubmit="return confirm('Cancel this shift assignment for ${emp.fullName}?');">
                                                <input type="hidden" name="action" value="delete">
                                                <input type="hidden" name="id" value="${asgn.id}">
                                                <input type="hidden" name="offset" value="${offset}">
                                                <button type="submit" class="shift-del-btn" title="Remove assignment">&times;</button>
                                            </form>
                                        </div>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <span class="muted" style="font-size: 13px;">&ndash;</span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                    </c:forEach>
                </tr>
            </c:forEach>
            <c:if test="${empty employees}">
                <tr><td colspan="8" style="text-align:center; padding: 40px; color: var(--muted);">No active staff members found in the system.</td></tr>
            </c:if>
        </tbody>
    </table>
</div>

<!-- Bulk Shift Assignment Section -->
<div class="bulk-card" id="assignBox">
    <div style="margin-bottom: 20px;">
        <h2 style="font-size: 16px; font-weight: 700; margin: 0; color: #0f172a;">
            Automated Bulk Shift Allocation
        </h2>
        <p class="muted small" style="margin-top: 4px;">
            Select multiple employees, a shift pattern, date range, and target working days to populate rosters in bulk.
        </p>
    </div>
    
    <form action="${ctx}/admin/shifts/schedule" method="post">
        <input type="hidden" name="action" value="assign">
        <input type="hidden" name="offset" value="${offset}">

        <!-- Step 1: Employees -->
        <div style="margin-bottom: 20px;">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;">
                <label style="font-weight: 600; font-size: 13px; color: #334155;">
                    <span class="step-badge">1</span> Target Employees <span style="color:#f87171;">*</span>
                </label>
                <div style="display: flex; gap: 6px;">
                    <button type="button" class="btn btn-ghost btn-sm" onclick="toggleAllEmployees(true)">Select All</button>
                    <button type="button" class="btn btn-ghost btn-sm" onclick="toggleAllEmployees(false)">Deselect All</button>
                </div>
            </div>
            <div class="emp-checkbox-grid">
                <c:forEach var="emp" items="${employees}">
                    <label class="emp-checkbox-item">
                        <input type="checkbox" name="employeeIds" value="${emp.id}" class="emp-cb" checked>
                        <span>
                            <strong class="mono" style="color: #2563eb;">${emp.code}</strong> &ndash; ${emp.fullName}
                        </span>
                    </label>
                </c:forEach>
            </div>
        </div>

        <!-- Step 2, 3, 4: Shift & Date Ranges -->
        <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 16px; margin-bottom: 20px;">
            <div>
                <label style="display:block; font-weight:600; margin-bottom:4px; font-size:12px; color: #334155;">
                    <span class="step-badge">2</span> Shift Template <span style="color:#f87171;">*</span>
                </label>
                <select name="shiftId" required style="width: 100%;">
                    <c:forEach var="s" items="${shifts}">
                        <option value="${s.id}">${s.name} (${s.startTime} &ndash; ${s.endTime})</option>
                    </c:forEach>
                </select>
            </div>
            <div>
                <label style="display:block; font-weight:600; margin-bottom:4px; font-size:12px; color: #334155;">
                    <span class="step-badge">3</span> From Date <span style="color:#f87171;">*</span>
                </label>
                <input type="date" name="startDate" value="${monday}" required style="width: 100%;">
            </div>
            <div>
                <label style="display:block; font-weight:600; margin-bottom:4px; font-size:12px; color: #334155;">
                    <span class="step-badge">4</span> To Date <span style="color:#f87171;">*</span>
                </label>
                <input type="date" name="endDate" value="${sunday}" required style="width: 100%;">
            </div>
        </div>

        <!-- Step 5: Days of week -->
        <div style="margin-bottom: 22px;">
            <label style="display:block; font-weight:600; margin-bottom:8px; font-size:12px; color: #334155;">
                <span class="step-badge">5</span> Apply to Working Days:
                <span class="muted small font-normal" style="font-weight: normal;">(Leave empty to apply to every day)</span>
            </label>
            <div style="display: flex; gap: 8px; flex-wrap: wrap;">
                <label class="day-pill-check"><input type="checkbox" name="daysOfWeek" value="1" checked> Mon</label>
                <label class="day-pill-check"><input type="checkbox" name="daysOfWeek" value="2" checked> Tue</label>
                <label class="day-pill-check"><input type="checkbox" name="daysOfWeek" value="3" checked> Wed</label>
                <label class="day-pill-check"><input type="checkbox" name="daysOfWeek" value="4" checked> Thu</label>
                <label class="day-pill-check"><input type="checkbox" name="daysOfWeek" value="5" checked> Fri</label>
                <label class="day-pill-check"><input type="checkbox" name="daysOfWeek" value="6"> Sat</label>
                <label class="day-pill-check"><input type="checkbox" name="daysOfWeek" value="7"> Sun</label>
            </div>
        </div>

        <button type="submit" class="btn btn-primary" style="padding: 10px 24px;">
            Assign Shift Schedule
        </button>
    </form>
</div>

<script>
    function toggleAllEmployees(state) {
        document.querySelectorAll('.emp-cb').forEach(cb => cb.checked = state);
    }
</script>

<%@ include file="../../common/footer.jspf" %>
