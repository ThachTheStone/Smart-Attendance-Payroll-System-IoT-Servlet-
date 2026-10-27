<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="pageTitle" value="Attendance & Timesheets"/>
<c:set var="activeNav" value="attendance"/>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<%@ include file="/WEB-INF/views/common/header.jspf" %>

<style>
    .att-hero {
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
    .att-hero-title {
        font-size: 22px;
        font-weight: 700;
        letter-spacing: -0.02em;
        margin: 0;
        display: flex;
        align-items: center;
        gap: 10px;
        color: #0f172a;
    }
    .att-hero-desc {
        color: var(--muted);
        font-size: 13px;
        margin-top: 4px;
    }
    .att-live-pill {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        background: #ecfdf5;
        color: #059669;
        border: 1px solid #a7f3d0;
        border-radius: var(--radius-full);
        padding: 3px 10px;
        font-size: 11px;
        font-weight: 600;
    }
    .att-live-dot {
        width: 7px;
        height: 7px;
        border-radius: 50%;
        background: #059669;
    }

    /* KPI Stat Grid */
    .att-kpi-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(130px, 1fr));
        gap: 12px;
        margin-bottom: 20px;
    }
    .att-kpi-card {
        background: #ffffff;
        border: 1px solid var(--border);
        border-radius: var(--radius);
        padding: 14px 16px;
        display: flex;
        flex-direction: column;
        gap: 4px;
        box-shadow: var(--shadow-xs);
        transition: border-color var(--transition-fast), box-shadow var(--transition-fast);
    }
    .att-kpi-card:hover {
        border-color: var(--border-hover);
        box-shadow: var(--shadow-sm);
    }
    .att-kpi-label {
        font-size: 11px;
        font-weight: 600;
        text-transform: uppercase;
        letter-spacing: 0.04em;
        color: #64748b;
    }
    .att-kpi-val {
        font-size: 22px;
        font-weight: 700;
        font-family: var(--font-ui); font-variant-numeric: tabular-nums;
        color: #0f172a;
        line-height: 1.1;
    }

    /* Filter Card */
    .att-filter-card {
        background: #ffffff;
        border: 1px solid var(--border);
        border-radius: var(--radius);
        padding: 16px 18px;
        margin-bottom: 20px;
        box-shadow: var(--shadow-xs);
    }
    .att-filter-form {
        display: flex;
        flex-wrap: wrap;
        gap: 14px;
        align-items: flex-end;
    }
    .att-filter-group {
        display: flex;
        flex-direction: column;
        gap: 5px;
        flex: 1 1 160px;
    }
    .att-filter-label {
        font-size: 11px;
        font-weight: 600;
        text-transform: uppercase;
        letter-spacing: 0.04em;
        color: #334155;
    }
    .att-filter-input {
        height: 38px;
        padding: 0 12px;
        border: 1px solid #cbd5e1 !important;
        border-radius: 7px;
        font-family: inherit;
        font-size: 13px;
        background: #ffffff !important;
        color: #0f172a !important;
        outline: none;
    }
    .att-filter-input:focus {
        border-color: #1d4ed8 !important;
        box-shadow: 0 0 0 3px rgba(29, 78, 216, 0.12) !important;
    }
    .att-filter-select {
        height: 38px;
        padding: 0 34px 0 12px !important;
        border: 1px solid #cbd5e1 !important;
        border-radius: 7px;
        font-family: inherit;
        font-size: 13px;
        background-color: #ffffff !important;
        background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='16' height='16' viewBox='0 0 24 24' fill='none' stroke='%2364748b' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpolyline points='6 9 12 15 18 9'%3E%3C/polyline%3E%3C/svg%3E") !important;
        background-repeat: no-repeat !important;
        background-position: right 10px center !important;
        background-size: 14px 14px !important;
        color: #0f172a !important;
        appearance: none !important;
        -webkit-appearance: none !important;
        -moz-appearance: none !important;
        cursor: pointer;
        outline: none !important;
    }
    .att-filter-select::-ms-expand {
        display: none !important;
    }
    .att-filter-select:focus {
        border-color: #1d4ed8 !important;
        box-shadow: 0 0 0 3px rgba(29, 78, 216, 0.12) !important;
        outline: none !important;
    }
    .att-filter-actions {
        display: flex;
        gap: 8px;
        flex-wrap: nowrap;
        flex: 0 0 auto;
    }
    .att-filter-actions .btn {
        height: 38px;
        white-space: nowrap;
    }

    /* Missing Checkout Action Banner */
    .missing-banner {
        display: flex;
        align-items: center;
        justify-content: space-between;
        flex-wrap: wrap;
        gap: 14px;
        background: #fef2f2;
        border: 1px solid #fecaca;
        border-left: 4px solid #dc2626;
        border-radius: var(--radius);
        padding: 14px 18px;
        margin-bottom: 20px;
    }
    .missing-banner-text {
        display: flex;
        align-items: center;
        gap: 10px;
        color: #991b1b;
        font-size: 13px;
    }

    /* Attendance Table Card */
    .att-table-card {
        background: #ffffff;
        border: 1px solid var(--border);
        border-radius: var(--radius-lg);
        overflow-x: auto;
        -webkit-overflow-scrolling: touch;
        margin-bottom: 28px;
        box-shadow: var(--shadow-xs);
    }
    .att-table-card .table {
        margin: 0;
        width: 100%;
        min-width: 960px; /* keep columns readable; the card scrolls sideways on narrow screens */
        border-collapse: collapse;
    }
    .att-table-card .table th,
    .att-table-card .table .nowrap {
        white-space: nowrap;
    }
    @media (max-width: 720px) {
        .att-filter-actions { flex: 1 1 100%; }
        .att-filter-actions .btn { flex: 1; }
    }
    .att-table-card .table th {
        background: #f8fafc;
        padding: 11px 16px;
        font-size: 11px;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 0.05em;
        color: #475569;
        border-bottom: 1px solid var(--border);
    }
    .att-table-card .table td {
        padding: 12px 16px;
        border-bottom: 1px solid #f1f5f9;
        vertical-align: middle;
        font-size: 13px;
        color: #334155;
    }
    .att-table-card .table tr:last-child td {
        border-bottom: none;
    }
    .att-table-card .table tr:hover td {
        background: #f8fafc;
    }

    /* Status Badges */
    .status-pill {
        display: inline-flex;
        align-items: center;
        gap: 4px;
        padding: 3px 8px;
        border-radius: var(--radius-full);
        font-size: 11px;
        font-weight: 600;
        letter-spacing: 0.02em;
    }
    .status-pill.ON_TIME { background: #ecfdf5; color: #059669; border: 1px solid #a7f3d0; }
    .status-pill.LATE { background: #fffbeb; color: #b45309; border: 1px solid #fde68a; }
    .status-pill.EARLY_LEAVE { background: #fffbeb; color: #b45309; border: 1px solid #fde68a; }
    .status-pill.MISSING_CHECKOUT { background: #fef2f2; color: #dc2626; border: 1px solid #fecaca; }
    .status-pill.OVERTIME { background: #eff6ff; color: #1d4ed8; border: 1px solid #bfdbfe; }
    .status-pill.ABSENT { background: #f1f5f9; color: #64748b; border: 1px solid #e2e8f0; }

    /* Modal Overlay & Card */
    .modal-overlay {
        display: none;
        position: fixed;
        inset: 0;
        background: rgba(15, 23, 42, 0.6);
        backdrop-filter: blur(4px);
        -webkit-backdrop-filter: blur(4px);
        z-index: 9999;
        justify-content: center;
        align-items: center;
        padding: 20px;
    }
    .modal-overlay.active {
        display: flex;
    }
    .modal-card {
        background: #ffffff;
        border: 1px solid var(--border);
        border-radius: var(--radius-lg);
        width: 100%;
        max-width: 560px;
        box-shadow: var(--shadow-lg);
        overflow: hidden;
        color: #0f172a;
    }
    .modal-header {
        padding: 16px 20px;
        border-bottom: 1px solid var(--border);
        display: flex;
        justify-content: space-between;
        align-items: center;
        background: #f8fafc;
    }
    .modal-title {
        font-size: 15px;
        font-weight: 700;
        color: #0f172a;
        margin: 0;
    }
    .modal-close-btn {
        background: none;
        border: none;
        font-size: 18px;
        cursor: pointer;
        color: #64748b;
        line-height: 1;
        padding: 4px;
        border-radius: 4px;
    }
    .modal-close-btn:hover {
        color: #dc2626;
    }
    .modal-body {
        padding: 20px;
    }
    .modal-footer {
        padding: 14px 20px;
        border-top: 1px solid var(--border);
        background: #f8fafc;
        display: flex;
        justify-content: flex-end;
        gap: 8px;
    }
    @keyframes spin { to { transform: rotate(360deg); } }
</style>

<!-- Hero Section -->
<div class="att-hero">
    <div>
        <h1 class="att-hero-title">
            Attendance &amp; Timesheets
            <span class="att-live-pill">
                <span class="att-live-dot"></span> IoT Sync Active
            </span>
        </h1>
        <p class="att-hero-desc">
            Biometric logs, automated shift detection, late/early flags, and checkout adjustments
        </p>
    </div>
</div>

<!-- KPI Stats Row -->
<div class="att-kpi-grid">
    <div class="att-kpi-card">
        <div class="att-kpi-label">Total Logs</div>
        <div class="att-kpi-val">${totalRecords}</div>
    </div>
    <div class="att-kpi-card">
        <div class="att-kpi-label" style="color:#059669;">On Time</div>
        <div class="att-kpi-val" style="color:#059669;">${onTimeCount}</div>
    </div>
    <div class="att-kpi-card">
        <div class="att-kpi-label" style="color:#d97706;">Late</div>
        <div class="att-kpi-val" style="color:#d97706;">${lateCount}</div>
    </div>
    <div class="att-kpi-card">
        <div class="att-kpi-label" style="color:#d97706;">Early Leave</div>
        <div class="att-kpi-val" style="color:#d97706;">${earlyLeaveCount}</div>
    </div>
    <div class="att-kpi-card">
        <div class="att-kpi-label" style="color:#dc2626;">Missing Out</div>
        <div class="att-kpi-val" style="color:#dc2626;">${missingCheckoutCount}</div>
    </div>
    <div class="att-kpi-card">
        <div class="att-kpi-label" style="color:#1d4ed8;">Overtime</div>
        <div class="att-kpi-val" style="color:#1d4ed8;">${overtimeCount}</div>
    </div>
    <div class="att-kpi-card">
        <div class="att-kpi-label" style="color:#64748b;">Absent</div>
        <div class="att-kpi-val" style="color:#64748b;">${absentCount}</div>
    </div>
</div>

<!-- Missing Checkout Alert Banner -->
<c:if test="${missingCheckoutCount > 0}">
    <div class="missing-banner">
        <div class="missing-banner-text">
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="8" x2="12" y2="12"></line><line x1="12" y1="16" x2="12.01" y2="16"></line></svg>
            <div>
                <strong>Action Required:</strong> Found <strong>${missingCheckoutCount}</strong> attendance record(s) without scan-out. Click <strong>Edit</strong> to record valid check-out times with audit trails before running payroll.
            </div>
        </div>
        <button type="button" class="btn btn-secondary btn-sm" onclick="filterMissingOnly()">
            Filter Missing Records
        </button>
    </div>
</c:if>

<!-- Filter Controls Card -->
<div class="att-filter-card">
    <form action="${ctx}/admin/attendance" method="get" id="filterForm" class="att-filter-form">
        <div class="att-filter-group">
            <label class="att-filter-label">From Date</label>
            <input type="date" name="from" value="${from}" class="att-filter-input">
        </div>
        <div class="att-filter-group">
            <label class="att-filter-label">To Date</label>
            <input type="date" name="to" value="${to}" class="att-filter-input">
        </div>
        <div class="att-filter-group" style="min-width: 220px;">
            <label class="att-filter-label">Employee</label>
            <select name="employeeId" class="att-filter-select">
                <option value="">All Employees</option>
                <c:forEach var="e" items="${employees}">
                    <option value="${e.id}" ${selectedEmployeeId == e.id ? 'selected' : ''}>
                        <c:out value="${e.code}"/> - <c:out value="${e.fullName}"/>
                    </option>
                </c:forEach>
            </select>
        </div>
        <div class="att-filter-group" style="min-width: 180px;">
            <label class="att-filter-label">Status</label>
            <select name="status" id="statusFilterSelect" class="att-filter-select">
                <option value="ALL">All Statuses</option>
                <option value="ON_TIME" ${selectedStatus == 'ON_TIME' ? 'selected' : ''}>On Time</option>
                <option value="LATE" ${selectedStatus == 'LATE' ? 'selected' : ''}>Late</option>
                <option value="EARLY_LEAVE" ${selectedStatus == 'EARLY_LEAVE' ? 'selected' : ''}>Early Leave</option>
                <option value="MISSING_CHECKOUT" ${selectedStatus == 'MISSING_CHECKOUT' ? 'selected' : ''}>Missing Checkout</option>
                <option value="OVERTIME" ${selectedStatus == 'OVERTIME' ? 'selected' : ''}>Overtime</option>
                <option value="ABSENT" ${selectedStatus == 'ABSENT' ? 'selected' : ''}>Absent</option>
            </select>
        </div>
        <div class="att-filter-actions">
            <button type="submit" class="btn btn-primary">Apply filter</button>
            <button type="button" class="btn btn-secondary" onclick="setToday()">Today</button>
            <button type="button" class="btn btn-secondary" onclick="setThisMonth()">This month</button>
        </div>
    </form>
</div>

<!-- Attendance Records Table -->
<div class="att-table-card">
    <table class="table">
        <thead>
            <tr>
                <th style="width: 110px;">Date</th>
                <th>Employee</th>
                <th>Assigned Shift</th>
                <th style="width: 100px;">Check-In</th>
                <th style="width: 100px;">Check-Out</th>
                <th style="width: 110px;">Duration</th>
                <th style="width: 130px;">Status</th>
                <th style="text-align: right; width: 140px;">Actions</th>
            </tr>
        </thead>
        <tbody>
            <c:choose>
                <c:when test="${empty attendances}">
                    <tr>
                        <td colspan="8" style="text-align: center; padding: 40px 20px; color: var(--muted);">
                            <div style="font-weight: 600; font-size: 14px; color: #0f172a;">No attendance records found</div>
                            <div style="font-size: 12px; margin-top: 4px;">Try broadening your date range or selecting another status filter.</div>
                        </td>
                    </tr>
                </c:when>
                <c:otherwise>
                    <c:forEach var="a" items="${attendances}">
                        <tr>
                            <td class="mono font-bold nowrap" style="color: var(--text);">
                                <c:out value="${a.workDate}"/>
                            </td>
                            <td>
                                <div style="font-weight: 600; color: #0f172a;">
                                    <c:out value="${a.employeeName}"/>
                                </div>
                                <div class="muted small" style="margin-top: 2px;">
                                    <span class="mono font-bold" style="color: #2563eb;"><c:out value="${a.employeeCode}"/></span>
                                    <span> &bull; <c:out value="${a.department}"/></span>
                                </div>
                            </td>
                            <td>
                                <div style="font-weight: 500; color: #0f172a;"><c:out value="${a.shiftName}"/></div>
                                <div class="muted small mono nowrap" style="margin-top: 2px;"><c:out value="${a.shiftStartTime}"/> &ndash; <c:out value="${a.shiftEndTime}"/></div>
                            </td>
                            <td class="mono font-bold nowrap">
                                <c:choose>
                                    <c:when test="${not empty a.checkIn}">
                                        <span style="color:#059669;"><c:out value="${a.formattedCheckInTime}"/></span>
                                    </c:when>
                                    <c:otherwise><span class="muted">&ndash;&ndash;:&ndash;&ndash;</span></c:otherwise>
                                </c:choose>
                            </td>
                            <td class="mono font-bold nowrap">
                                <c:choose>
                                    <c:when test="${not empty a.checkOut}">
                                        <span style="color:#2563eb;"><c:out value="${a.formattedCheckOutTime}"/></span>
                                    </c:when>
                                    <c:otherwise>
                                        <c:if test="${a.status == 'MISSING_CHECKOUT'}">
                                            <span style="color:#b91c1c;">Missing</span>
                                        </c:if>
                                        <c:if test="${a.status != 'MISSING_CHECKOUT'}">
                                            <span class="muted">&ndash;&ndash;:&ndash;&ndash;</span>
                                        </c:if>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td class="nowrap">
                                <span style="font-weight: 600;"><c:out value="${a.formattedWorkedHours}"/></span>
                                <c:if test="${a.workedMinutes > 0}">
                                    <span class="muted small mono">(${a.workedMinutes}m)</span>
                                </c:if>
                            </td>
                            <td class="nowrap">
                                <span class="status-pill ${a.status}">
                                    <c:out value="${a.statusLabel}"/>
                                </span>
                            </td>
                            <td style="text-align: right; white-space: nowrap;">
                                <button type="button" class="btn btn-secondary btn-sm" 
                                        onclick="openEditModal(${a.id}, '<c:out value="${a.employeeName}"/>', '<c:out value="${a.employeeCode}"/>', '<c:out value="${a.shiftName}"/>', '<c:out value="${a.workDate}"/>', '<c:out value="${a.formattedCheckInDateTime}"/>', '<c:out value="${a.formattedCheckOutDateTime}"/>', '${a.status}', ${a.workedMinutes})">
                                    Edit
                                </button>
                                <button type="button" class="btn btn-ghost btn-sm" onclick="viewAuditLog(${a.id})">
                                    Audit
                                </button>
                            </td>
                        </tr>
                    </c:forEach>
                </c:otherwise>
            </c:choose>
        </tbody>
    </table>
</div>

<!-- Edit Attendance Modal -->
<div id="editModal" class="modal-overlay" onclick="handleEditBackdropClick(event)">
    <div class="modal-card" onclick="event.stopPropagation()">
        <div class="modal-header">
            <h3 class="modal-title">
                Adjust Attendance Record
            </h3>
            <button type="button" class="modal-close-btn" onclick="closeEditModal()" title="Close dialog">&times;</button>
        </div>

        <form action="${ctx}/admin/attendance" method="post">
            <input type="hidden" name="id" id="modalId">
            <input type="hidden" name="from" value="${from}">
            <input type="hidden" name="to" value="${to}">

            <div class="modal-body">
                <!-- Info Summary Box -->
                <div style="background: #eff6ff; padding: 12px 16px; border-radius: 8px; margin-bottom: 16px; font-size: 13px; border: 1px solid #bfdbfe; color: #0f172a;">
                    <div><strong>Employee:</strong> <span id="modalEmpDisplay" style="color: #1d4ed8; font-weight: 700;"></span></div>
                    <div style="margin-top: 4px; color: #334155;"><strong>Shift:</strong> <span id="modalShiftDisplay" style="font-weight:600;"></span> &bull; <strong>Date:</strong> <span id="modalDateDisplay" class="mono font-bold" style="color: #0f172a;"></span></div>
                </div>

                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 12px; margin-bottom: 14px;">
                    <div>
                        <label style="display: block; font-size: 11px; font-weight: 600; text-transform: uppercase; margin-bottom: 4px; color: #64748b;">
                            Check-In Time
                        </label>
                        <input type="datetime-local" name="checkIn" id="modalCheckIn" class="att-filter-input" style="width: 100%;">
                    </div>
                    <div>
                        <label style="display: block; font-size: 11px; font-weight: 600; text-transform: uppercase; margin-bottom: 4px; color: #64748b;">
                            Check-Out Time
                        </label>
                        <input type="datetime-local" name="checkOut" id="modalCheckOut" class="att-filter-input" style="width: 100%;">
                    </div>
                </div>

                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 12px; margin-bottom: 14px;">
                    <div>
                        <label style="display: block; font-size: 11px; font-weight: 600; text-transform: uppercase; margin-bottom: 4px; color: #64748b;">
                            Status
                        </label>
                        <select name="status" id="modalStatus" class="att-filter-select" style="width: 100%;">
                            <option value="ON_TIME">On Time</option>
                            <option value="LATE">Late</option>
                            <option value="EARLY_LEAVE">Early Leave</option>
                            <option value="MISSING_CHECKOUT">Missing Checkout</option>
                            <option value="OVERTIME">Overtime</option>
                            <option value="ABSENT">Absent</option>
                        </select>
                    </div>
                    <div>
                        <label style="display: block; font-size: 11px; font-weight: 600; text-transform: uppercase; margin-bottom: 4px; color: #64748b;">
                            Worked Minutes
                        </label>
                        <input type="number" name="workedMinutes" id="modalWorkedMinutes" placeholder="Auto-calculated if blank" min="0" class="att-filter-input" style="width: 100%;">
                    </div>
                </div>

                <div style="margin-bottom: 4px;">
                    <label style="display: block; font-size: 11px; font-weight: 600; text-transform: uppercase; margin-bottom: 4px; color: #dc2626;">
                        Reason for Manual Adjustment <span style="color: #dc2626;">*</span>
                    </label>
                    <textarea name="reason" id="modalReason" required rows="3" class="att-filter-input"
                              style="width: 100%; height: auto; padding: 8px 12px; resize: vertical;"
                              placeholder="e.g. Employee offsite client meeting, verified with manager at 18:00..."></textarea>
                    <div class="muted small" style="margin-top: 4px; font-size: 11px;">
                        This reason and your username will be permanently recorded in the audit trail.
                    </div>
                </div>
            </div>

            <div class="modal-footer">
                <button type="button" class="btn btn-ghost" onclick="closeEditModal()">Cancel</button>
                <button type="submit" class="btn btn-primary">Save Adjustment</button>
            </div>
        </form>
    </div>
</div>

<!-- Audit Trail History Modal -->
<div id="auditModal" class="modal-overlay" onclick="handleAuditBackdropClick(event)">
    <div class="modal-card" style="max-width: 680px;" onclick="event.stopPropagation()">
        <div class="modal-header">
            <h3 class="modal-title">
                Audit Trail History
            </h3>
            <button type="button" class="modal-close-btn" onclick="closeAuditModal()" title="Close dialog">&times;</button>
        </div>

        <div class="modal-body" style="padding: 0;">
            <div id="auditLoading" style="text-align: center; padding: 32px; color: var(--muted);">
                <div style="display: inline-block; width: 24px; height: 24px; border: 2px solid var(--border); border-top-color: var(--primary); border-radius: 50%; animation: spin 0.8s linear infinite;"></div>
                <div style="margin-top: 10px; font-size: 12px;">Retrieving audit log entries...</div>
            </div>

            <div id="auditContent" style="display: none; max-height: 400px; overflow-y: auto;">
                <table class="table" style="width: 100%; margin: 0; font-size: 12px;">
                    <thead>
                        <tr>
                            <th style="padding: 10px 14px;">Timestamp</th>
                            <th style="padding: 10px 14px;">Admin</th>
                            <th style="padding: 10px 14px;">Reason</th>
                            <th style="padding: 10px 14px;">Field Changes</th>
                        </tr>
                    </thead>
                    <tbody id="auditTableBody"></tbody>
                </table>
            </div>
        </div>

        <div class="modal-footer">
            <button type="button" class="btn btn-ghost" onclick="closeAuditModal()">Close</button>
        </div>
    </div>
</div>

<script>
function setToday() {
    const today = new Date().toISOString().split('T')[0];
    document.querySelector('input[name="from"]').value = today;
    document.querySelector('input[name="to"]').value = today;
    document.getElementById('filterForm').submit();
}

function setThisMonth() {
    const now = new Date();
    const firstDay = new Date(now.getFullYear(), now.getMonth(), 1).toISOString().split('T')[0];
    const today = now.toISOString().split('T')[0];
    document.querySelector('input[name="from"]').value = firstDay;
    document.querySelector('input[name="to"]').value = today;
    document.getElementById('filterForm').submit();
}

function filterMissingOnly() {
    document.getElementById('statusFilterSelect').value = 'MISSING_CHECKOUT';
    document.getElementById('filterForm').submit();
}

function openEditModal(id, empName, empCode, shiftName, workDate, checkIn, checkOut, status, workedMinutes) {
    document.getElementById('modalId').value = id;
    document.getElementById('modalEmpDisplay').innerText = empName + ' (' + empCode + ')';
    document.getElementById('modalShiftDisplay').innerText = shiftName;
    document.getElementById('modalDateDisplay').innerText = workDate;
    document.getElementById('modalCheckIn').value = checkIn || '';
    document.getElementById('modalCheckOut').value = checkOut || '';
    document.getElementById('modalStatus').value = status || 'ON_TIME';
    document.getElementById('modalWorkedMinutes').value = workedMinutes || '';
    document.getElementById('modalReason').value = '';

    const modal = document.getElementById('editModal');
    modal.classList.add('active');
}

function closeEditModal() {
    const modal = document.getElementById('editModal');
    modal.classList.remove('active');
}

function handleEditBackdropClick(e) {
    if (e.target.id === 'editModal') {
        closeEditModal();
    }
}

function viewAuditLog(recordId) {
    const modal = document.getElementById('auditModal');
    modal.classList.add('active');
    document.getElementById('auditLoading').style.display = 'block';
    document.getElementById('auditContent').style.display = 'none';

    fetch('${ctx}/admin/attendance?action=audit&recordId=' + recordId)
        .then(res => res.json())
        .then(logs => {
            document.getElementById('auditLoading').style.display = 'none';
            document.getElementById('auditContent').style.display = 'block';
            const tbody = document.getElementById('auditTableBody');
            tbody.innerHTML = '';

            if (!logs || logs.length === 0) {
                tbody.innerHTML = '<tr><td colspan="4" style="text-align:center; padding:24px; color:var(--muted);">No adjustments have been recorded for this attendance record yet.</td></tr>';
                return;
            }

            logs.forEach(l => {
                const tr = document.createElement('tr');
                tr.innerHTML = 
                    '<td style="padding:10px 14px; white-space:nowrap;" class="mono">' + (l.time || '-') + '</td>' +
                    '<td style="padding:10px 14px; font-weight:600; color:#60a5fa;">' + (l.admin || '-') + '</td>' +
                    '<td style="padding:10px 14px; color:#fbbf24;">' + (l.reason || '-') + '</td>' +
                    '<td style="padding:10px 14px; font-family:\'JetBrains Mono\', monospace; font-size:11px;">' +
                        '<div style="color:#f87171;">- ' + (l.oldValue || '') + '</div>' +
                        '<div style="color:#34d399;">+ ' + (l.newValue || '') + '</div>' +
                    '</td>';
                tbody.appendChild(tr);
            });
        })
        .catch(err => {
            document.getElementById('auditLoading').innerHTML = '<div style="color:var(--danger); padding:20px;">Error loading audit log: ' + err + '</div>';
        });
}

function closeAuditModal() {
    const modal = document.getElementById('auditModal');
    modal.classList.remove('active');
}

function handleAuditBackdropClick(e) {
    if (e.target.id === 'auditModal') {
        closeAuditModal();
    }
}

document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape') {
        closeEditModal();
        closeAuditModal();
    }
});
</script>

<%@ include file="/WEB-INF/views/common/footer.jspf" %>
