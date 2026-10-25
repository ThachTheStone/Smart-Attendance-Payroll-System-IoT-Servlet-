<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="pageTitle" value="Payroll & Payslips"/>
<c:set var="activeNav" value="payroll"/>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<%@ include file="/WEB-INF/views/common/header.jspf" %>

<style>
    /* ================= Executive Payroll Dashboard (Swiss Light SaaS) ================= */
    .payroll-hero {
        display: flex;
        justify-content: space-between;
        align-items: center;
        flex-wrap: wrap;
        gap: 16px;
        margin-bottom: 24px;
        padding: 24px 28px;
        background: #ffffff !important;
        border: 1px solid var(--border) !important;
        border-radius: var(--radius-lg);
        box-shadow: var(--shadow-sm);
    }
    .payroll-hero-title {
        font-size: 22px;
        font-weight: 700;
        letter-spacing: -0.02em;
        margin: 0;
        display: flex;
        align-items: center;
        gap: 12px;
        color: #0f172a !important;
    }
    .payroll-hero-icon {
        width: 38px;
        height: 38px;
        border-radius: 8px;
        background: #ecfdf5;
        color: #059669;
        border: 1px solid #a7f3d0;
        display: flex;
        align-items: center;
        justify-content: center;
        flex-shrink: 0;
    }
    .payroll-hero-desc {
        color: var(--muted);
        font-size: 13px;
        margin-top: 6px;
        line-height: 1.5;
    }

    /* Period Filter Control */
    .period-filter-bar {
        display: flex;
        align-items: center;
        gap: 10px;
        background: #f8fafc !important;
        border: 1px solid var(--border);
        padding: 8px 14px;
        border-radius: var(--radius);
    }
    .period-filter-bar input {
        padding: 6px 12px;
        border: 1px solid #cbd5e1 !important;
        border-radius: 6px;
        font-size: 13px;
        font-family: inherit;
        background: #ffffff !important;
        color: #0f172a !important;
        outline: none;
    }
    .period-filter-bar select {
        padding: 6px 30px 6px 12px;
        border: 1px solid #cbd5e1 !important;
        border-radius: 6px;
        font-size: 13px;
        font-family: inherit;
        background-color: #ffffff !important;
        background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='16' height='16' viewBox='0 0 24 24' fill='none' stroke='%2364748b' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpolyline points='6 9 12 15 18 9'%3E%3C/polyline%3E%3C/svg%3E") !important;
        background-repeat: no-repeat !important;
        background-position: right 8px center !important;
        background-size: 14px 14px !important;
        color: #0f172a !important;
        appearance: none !important;
        -webkit-appearance: none !important;
        cursor: pointer;
        outline: none;
    }
    .period-filter-bar select::-ms-expand {
        display: none !important;
    }
    .period-filter-bar select:focus, .period-filter-bar input:focus {
        border-color: #1d4ed8 !important;
        outline: none;
        box-shadow: 0 0 0 2px rgba(29, 78, 216, 0.15) !important;
    }

    /* Missing Checkout Block Alert (FR-PAY-03) */
    .missing-alert-box {
        background: #fffbeb;
        border: 1px solid #fde68a;
        border-left: 4px solid #d97706;
        border-radius: var(--radius-lg);
        padding: 20px 24px;
        margin-bottom: 24px;
    }
    .missing-alert-title {
        display: flex;
        align-items: center;
        gap: 10px;
        color: #b45309;
        font-weight: 700;
        font-size: 15px;
    }
    .missing-alert-desc {
        color: #78350f;
        font-size: 13px;
        margin: 8px 0 16px 0;
        line-height: 1.5;
    }

    /* Batch Card & Status */
    .batch-card {
        background: #ffffff !important;
        border: 1px solid var(--border) !important;
        border-radius: var(--radius-lg);
        padding: 20px 24px;
        margin-bottom: 24px;
        display: flex;
        justify-content: space-between;
        align-items: center;
        flex-wrap: wrap;
        gap: 16px;
        color: #0f172a;
        box-shadow: var(--shadow-xs);
    }
    .batch-title-row {
        display: flex;
        align-items: center;
        gap: 12px;
    }
    .batch-status-badge {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        padding: 4px 12px;
        border-radius: var(--radius-full);
        font-size: 11px;
        font-weight: 600;
        letter-spacing: 0.03em;
    }
    .batch-status-badge.DRAFT {
        background: #fffbeb;
        color: #b45309;
        border: 1px solid #fde68a;
    }
    .batch-status-badge.LOCKED {
        background: #ecfdf5;
        color: #059669;
        border: 1px solid #a7f3d0;
    }
    .batch-status-badge.NONE {
        background: #f1f5f9;
        color: #64748b;
        border: 1px solid #e2e8f0;
    }

    /* Action Buttons */
    .payroll-actions {
        display: flex;
        gap: 10px;
        flex-wrap: wrap;
        align-items: center;
    }
    .payroll-btn {
        display: inline-flex;
        align-items: center;
        gap: 8px;
        padding: 8px 16px;
        border-radius: 6px;
        font-size: 13px;
        font-weight: 600;
        text-decoration: none;
        cursor: pointer;
        transition: background-color 0.15s ease, border-color 0.15s ease;
        border: 1px solid transparent;
        font-family: inherit;
    }
    .payroll-btn-primary {
        background: #059669;
        color: #ffffff;
        border: 1px solid #047857;
        box-shadow: 0 1px 2px rgba(5, 150, 105, 0.2);
    }
    .payroll-btn-primary:hover:not(:disabled) {
        background: #047857;
        color: #ffffff;
    }
    .payroll-btn-primary:disabled {
        opacity: 0.5;
        cursor: not-allowed;
    }
    .payroll-btn-secondary {
        background: #ffffff;
        color: #334155;
        border: 1px solid #cbd5e1;
        box-shadow: 0 1px 2px rgba(0, 0, 0, 0.04);
    }
    .payroll-btn-secondary:hover {
        background: #f8fafc;
        border-color: #94a3b8;
        color: #0f172a;
    }
    .payroll-btn-lock {
        background: #ecfdf5;
        color: #059669;
        border: 1px solid #a7f3d0;
    }
    .payroll-btn-lock:hover {
        background: #d1fae5;
        color: #047857;
    }

    /* KPI Stats */
    .payroll-kpi-bar {
        display: grid;
        grid-template-columns: repeat(3, 1fr);
        gap: 16px;
        margin-bottom: 24px;
    }
    .payroll-kpi {
        background: #ffffff !important;
        border: 1px solid var(--border);
        border-radius: var(--radius);
        padding: 20px 24px;
        box-shadow: var(--shadow-xs);
        transition: border-color 0.15s ease, box-shadow 0.15s ease;
    }
    .payroll-kpi:hover {
        border-color: var(--border-hover);
        box-shadow: var(--shadow-sm);
    }
    .payroll-kpi-val {
        font-size: 24px;
        font-weight: 700;
        color: #0f172a;
        margin-top: 8px;
        font-family: 'JetBrains Mono', monospace;
    }

    /* Payroll Details Table */
    .payroll-table-card {
        background: #ffffff !important;
        border: 1px solid var(--border) !important;
        border-radius: var(--radius-lg);
        overflow: hidden;
        margin-bottom: 32px;
        box-shadow: var(--shadow-xs);
    }
    .payroll-table-card .table {
        width: 100%;
        margin: 0;
        border-collapse: collapse;
    }
    .payroll-table-card .table th {
        background: #f8fafc !important;
        padding: 12px 16px;
        font-size: 11px;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 0.05em;
        color: #475569;
        border-bottom: 1px solid var(--border);
    }
    .payroll-table-card .table td {
        padding: 13px 16px;
        border-bottom: 1px solid #f1f5f9;
        vertical-align: middle;
        font-size: 13px;
        color: #334155;
    }
    .payroll-table-card .table tr:hover td {
        background: #f8fafc;
    }

    /* Email Status Badge */
    .email-pill {
        display: inline-flex;
        align-items: center;
        gap: 4px;
        padding: 3px 8px;
        border-radius: var(--radius-full);
        font-size: 11px;
        font-weight: 600;
    }
    .email-pill.SENT { background: #ecfdf5; color: #059669; border: 1px solid #a7f3d0; }
    .email-pill.FAILED { background: #fef2f2; color: #dc2626; border: 1px solid #fecaca; }
    .email-pill.UNSENT { background: #f1f5f9; color: #64748b; border: 1px solid #e2e8f0; }

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
        background: #ffffff !important;
        border: 1px solid var(--border);
        border-radius: var(--radius-lg);
        width: 100%;
        max-width: 620px;
        box-shadow: var(--shadow-lg);
        overflow: hidden;
        max-height: 90vh;
        display: flex;
        flex-direction: column;
        color: #0f172a;
    }
    .modal-body-scroll {
        padding: 24px;
        overflow-y: auto;
    }

    /* Payslip Slip Styling */
    .payslip-summary-box {
        background: #f8fafc;
        border: 1px solid #e2e8f0;
        border-radius: 8px;
        padding: 16px 20px;
        margin-bottom: 20px;
        display: flex;
        justify-content: space-between;
        align-items: center;
        color: #0f172a;
    }
    .payslip-item-row {
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 9px 0;
        border-bottom: 1px solid #f1f5f9;
        font-size: 13px;
        color: #334155;
    }
    .payslip-item-row:last-child {
        border-bottom: none;
    }
    .payslip-net-banner {
        background: #ecfdf5;
        border: 1px solid #a7f3d0;
        border-radius: 8px;
        padding: 16px 20px;
        margin-top: 18px;
        display: flex;
        justify-content: space-between;
        align-items: center;
        color: #065f46;
    }
</style>

<!-- Hero Section -->
<div class="payroll-hero">
    <div>
        <h1 class="payroll-hero-title">
            <span class="payroll-hero-icon">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <line x1="12" y1="1" x2="12" y2="23"></line>
                    <path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"></path>
                </svg>
            </span>
            <span>Payroll &amp; Payslips</span>
        </h1>
        <p class="payroll-hero-desc">
            Automated monthly salary calculation, timesheet verification, audit lock, and PDF delivery
        </p>
    </div>

    <!-- Period Selector Form -->
    <form method="get" action="${ctx}/admin/payroll" class="period-filter-bar">
        <label style="display:flex; align-items:center; gap:6px; font-weight:600; font-size:12px; text-transform:uppercase; color:var(--text-muted); margin:0;">
            Month:
            <select name="month">
                <c:forEach var="m" begin="1" end="12">
                    <option value="${m}" ${m == month ? 'selected' : ''}>Month ${m}</option>
                </c:forEach>
            </select>
        </label>
        <label style="display:flex; align-items:center; gap:6px; font-weight:600; font-size:12px; text-transform:uppercase; color:var(--text-muted); margin:0;">
            Year:
            <input type="number" name="year" value="${year}" min="2020" max="2030" style="width:75px;" class="mono font-bold">
        </label>
        <button type="submit" class="btn btn-secondary btn-sm" style="padding: 6px 14px;">View</button>
    </form>
</div>

<!-- 1. MISSING CHECKOUT ALERT (FR-PAY-03) -->
<c:if test="${not empty missingCheckouts}">
    <div class="missing-alert-box">
        <div class="missing-alert-title">
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"></path><line x1="12" y1="9" x2="12" y2="13"></line><line x1="12" y1="17" x2="12.01" y2="17"></line></svg>
            <span>Payroll Calculation Blocked: ${missingCheckouts.size()} missing checkout(s) for Month ${month}/${year}</span>
        </div>
        <p class="missing-alert-desc">
            Under strict payroll integrity rules, payroll cannot be calculated or generated while unverified missing checkouts exist. Administrators must adjust check-out times in Attendance management with valid reasons first.
        </p>

        <div class="table-wrap" style="background:#ffffff; border-radius:8px; border:1px solid #fed7aa; overflow:hidden;">
            <table class="table" style="margin:0; width:100%;">
                <thead>
                    <tr style="background:#fff7ed;">
                        <th style="padding:10px 14px; font-size:11px; text-transform:uppercase; color:#c2410c;">Emp Code</th>
                        <th style="padding:10px 14px; font-size:11px; text-transform:uppercase; color:#c2410c;">Full Name</th>
                        <th style="padding:10px 14px; font-size:11px; text-transform:uppercase; color:#c2410c;">Department</th>
                        <th style="padding:10px 14px; font-size:11px; text-transform:uppercase; color:#c2410c;">Work Date</th>
                        <th style="padding:10px 14px; font-size:11px; text-transform:uppercase; color:#c2410c;">Shift</th>
                        <th style="padding:10px 14px; font-size:11px; text-transform:uppercase; color:#c2410c;">Check-in</th>
                        <th style="padding:10px 14px; font-size:11px; text-transform:uppercase; color:#c2410c; text-align:right;">Action</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="mc" items="${missingCheckouts}">
                        <tr>
                            <td class="mono font-bold" style="color:var(--primary); padding:10px 14px;">${mc.employeeCode}</td>
                            <td style="font-weight:600; padding:10px 14px; color:#0f172a;"><c:out value="${mc.employeeName}"/></td>
                            <td style="padding:10px 14px; color:#64748b;"><c:out value="${mc.department}"/></td>
                            <td class="mono font-bold" style="padding:10px 14px; color:#0f172a;">${mc.workDate}</td>
                            <td style="padding:10px 14px; color:#334155;"><c:out value="${mc.shiftName}"/></td>
                            <td class="mono" style="padding:10px 14px; color:#059669; font-weight:600;">${mc.formattedCheckIn}</td>
                            <td style="text-align:right; padding:10px 14px;">
                                <a href="${ctx}/admin/attendance?employeeId=${mc.employeeId}&from=${mc.workDate}&to=${mc.workDate}" class="btn btn-secondary btn-sm" style="font-size:11px;">
                                    Adjust Checkout
                                </a>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>
    </div>
</c:if>

<!-- 2. PAYROLL BATCH STATUS & ACTIONS -->
<div class="batch-card">
    <div class="batch-title-row">
        <h2 style="font-size: 16px; font-weight: 700; margin: 0;">Payroll Sheet &bull; Month ${month}/${year}</h2>
        <c:choose>
            <c:when test="${empty payroll}">
                <span class="batch-status-badge NONE">&bull; Not Generated</span>
            </c:when>
            <c:when test="${payroll.status == 'DRAFT'}">
                <span class="batch-status-badge DRAFT">&bull; Draft Review</span>
            </c:when>
            <c:when test="${payroll.status == 'LOCKED'}">
                <span class="batch-status-badge LOCKED">&bull; Finalized &amp; Locked</span>
            </c:when>
        </c:choose>
    </div>

    <div class="payroll-actions">
        <!-- Button Generate / Recalculate -->
        <c:if test="${empty payroll || !payroll.isLocked()}">
            <form method="post" action="${ctx}/admin/payroll" style="margin:0;">
                <input type="hidden" name="action" value="generate">
                <input type="hidden" name="month" value="${month}">
                <input type="hidden" name="year" value="${year}">
                <button type="submit" class="payroll-btn payroll-btn-primary" 
                        ${not empty missingCheckouts ? 'disabled title="Resolve missing checkouts above first"' : ''}>
                    <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="23 4 23 10 17 10"></polyline><polyline points="1 20 1 14 7 14"></polyline><path d="M3.51 9a9 9 0 0 1 14.85-3.36L23 10M1 14l4.64 4.36A9 9 0 0 0 20.49 15"></path></svg>
                    <span>${empty payroll ? 'Calculate Payroll' : 'Recalculate'}</span>
                </button>
            </form>
        </c:if>

        <!-- Button Lock -->
        <c:if test="${not empty payroll && !payroll.isLocked()}">
            <form method="post" action="${ctx}/admin/payroll" onsubmit="return confirm('Are you sure you want to LOCK this payroll? Once locked, salary figures cannot be modified.');" style="margin:0;">
                <input type="hidden" name="action" value="lock">
                <input type="hidden" name="payrollId" value="${payroll.id}">
                <input type="hidden" name="month" value="${month}">
                <input type="hidden" name="year" value="${year}">
                <button type="submit" class="payroll-btn payroll-btn-lock">
                    <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"></rect><path d="M7 11V7a5 5 0 0 1 10 0v4"></path></svg>
                    <span>Lock Payroll</span>
                </button>
            </form>
        </c:if>

        <!-- Batch Export PDF & Send Email (FR-PAY-05, FR-PAY-06) -->
        <c:if test="${not empty payroll && not empty details}">
            <a href="${ctx}/admin/payroll/export-pdf?payrollId=${payroll.id}" class="payroll-btn payroll-btn-secondary" title="Export company payslips to PDF">
                <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><line x1="16" y1="13" x2="8" y2="13"></line><line x1="16" y1="17" x2="8" y2="17"></line><polyline points="10 9 9 9 8 9"></polyline></svg>
                <span>Export All PDFs</span>
            </a>

            <form method="post" action="${ctx}/admin/payroll/send-email" onsubmit="return confirm('Email payslip PDFs to all ${payroll.totalEmployees} employees for Month ${month}/${year}?');" style="margin:0;">
                <input type="hidden" name="payrollId" value="${payroll.id}">
                <input type="hidden" name="sendAll" value="true">
                <button type="submit" class="payroll-btn payroll-btn-secondary" title="Send PDF payslips via email to all employees">
                    <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"></path><polyline points="22,6 12,13 2,6"></polyline></svg>
                    <span>Email All Payslips</span>
                </button>
            </form>
        </c:if>
    </div>
</div>

<!-- 3. KPI STATS (When payroll exists) -->
<c:if test="${not empty payroll}">
    <div class="payroll-kpi-bar">
        <div class="payroll-kpi">
            <div class="muted small font-bold" style="text-transform: uppercase;">Active Employees on Payroll</div>
            <div class="payroll-kpi-val" style="color: #60a5fa;">
                ${payroll.totalEmployees} <span style="font-size: 13px; color: var(--muted); font-weight: 500;">staff</span>
            </div>
        </div>
        <div class="payroll-kpi">
            <div class="muted small font-bold" style="text-transform: uppercase;">Total Net Salary Disbursed</div>
            <div class="payroll-kpi-val" style="color: #34d399;">
                <fmt:formatNumber value="${payroll.totalNetSalary}" pattern="#,##0"/> <span style="font-size: 13px; color: var(--muted); font-weight: 500;">VND</span>
            </div>
        </div>
        <div class="payroll-kpi">
            <div class="muted small font-bold" style="text-transform: uppercase;">Batch Integrity Status</div>
            <div class="payroll-kpi-val" style="font-size: 18px; margin-top: 10px; color: ${payroll.status == 'LOCKED' ? '#34d399' : '#fbbf24'};">
                ${payroll.status == 'LOCKED' ? 'Locked &amp; Audited' : 'Draft Review'}
            </div>
        </div>
    </div>

    <!-- 4. PAYROLL DETAILS TABLE (FR-PAY-02) -->
    <div class="payroll-table-card">
        <table class="table">
            <thead>
                <tr>
                    <th style="width: 100px;">Code</th>
                    <th>Employee Name</th>
                    <th>Department</th>
                    <th style="text-align: right;">Base Salary</th>
                    <th style="text-align: center;">Reg Hrs</th>
                    <th style="text-align: center;">OT Hrs</th>
                    <th style="text-align: center;">Night</th>
                    <th style="text-align: right;">Late Pen.</th>
                    <th style="text-align: right;">Net Salary (VND)</th>
                    <th style="text-align: center;">Email</th>
                    <th style="text-align: right; width: 150px;">Actions</th>
                </tr>
            </thead>
            <tbody>
                <c:choose>
                    <c:when test="${empty details}">
                        <tr><td colspan="11" class="empty" style="text-align: center; padding: 36px; color: #94a3b8;">No payroll breakdown records available.</td></tr>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="d" items="${details}">
                            <tr>
                                <td class="mono font-bold" style="color: var(--primary);">${d.employeeCode}</td>
                                <td><strong style="color: var(--text);"><c:out value="${d.employeeName}"/></strong></td>
                                <td class="muted"><c:out value="${d.department}"/></td>
                                <td class="mono font-bold" style="text-align: right;">
                                    <fmt:formatNumber value="${d.baseSalary}" pattern="#,##0"/>
                                </td>
                                <td class="mono" style="text-align: center;">${d.regularHours}h</td>
                                <td class="mono" style="text-align: center;">
                                    <span title="Weekday: ${d.otWeekdayHours}h, Weekend: ${d.otWeekendHours}h, Holiday: ${d.otHolidayHours}h" style="font-weight: 600; color: ${d.totalOvertimeHours > 0 ? '#a78bfa' : 'inherit'};">
                                        ${d.totalOvertimeHours}h
                                    </span>
                                </td>
                                <td class="mono" style="text-align: center;">${d.nightHours}h</td>
                                <td class="mono" style="text-align: right; color: ${d.penalty > 0 ? '#f87171' : 'var(--muted)'}; font-weight: ${d.penalty > 0 ? '700' : 'normal'};">
                                    <c:choose>
                                        <c:when test="${d.lateMinutes > 0}">
                                            -${d.penalty} <span style="font-size:10px;">(${d.lateMinutes}m)</span>
                                        </c:when>
                                        <c:otherwise>0</c:otherwise>
                                    </c:choose>
                                </td>
                                <td class="mono font-bold" style="text-align: right; color: #34d399; font-size: 14px;">
                                    <fmt:formatNumber value="${d.netSalary}" pattern="#,##0"/>
                                </td>
                                <td style="text-align: center;">
                                    <c:choose>
                                        <c:when test="${d.emailStatus == 'SENT'}">
                                            <span class="email-pill SENT" title="Email delivered successfully">Sent</span>
                                        </c:when>
                                        <c:when test="${d.emailStatus == 'FAILED'}">
                                            <span class="email-pill FAILED" title="Failed to deliver email">Failed</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="email-pill UNSENT">Unsent</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td style="text-align: right; white-space: nowrap;">
                                    <div style="display: inline-flex; gap: 4px; align-items: center;">
                                        <button type="button" class="btn btn-secondary btn-sm"
                                                data-id="${d.employeeId}"
                                                data-code="${d.employeeCode}"
                                                data-name="<c:out value='${d.employeeName}'/>"
                                                data-dept="<c:out value='${d.department}'/>"
                                                data-base="${d.baseSalary}"
                                                data-rate="${d.hourlyRate}"
                                                data-regh="${d.regularHours}"
                                                data-regp="${d.regularPay}"
                                                data-otwdh="${d.otWeekdayHours}"
                                                data-otwdp="${d.otWeekdayPay}"
                                                data-otweh="${d.otWeekendHours}"
                                                data-otwep="${d.otWeekendPay}"
                                                data-otholh="${d.otHolidayHours}"
                                                data-otholp="${d.otHolidayPay}"
                                                data-nighth="${d.nightHours}"
                                                data-nightp="${d.nightAllowance}"
                                                data-nightoth="${d.nightOtHours}"
                                                data-nightotp="${d.nightOtBonus}"
                                                data-latem="${d.lateMinutes}"
                                                data-penalty="${d.penalty}"
                                                data-net="${d.netSalary}"
                                                onclick="openPayslipFromBtn(this)"
                                                title="View detailed payslip statement"
                                                style="padding: 5px 9px;">
                                            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path><circle cx="12" cy="12" r="3"></circle></svg>
                                        </button>
                                        <a href="${ctx}/admin/payroll/export-pdf?payrollId=${payroll.id}&employeeId=${d.employeeId}" class="btn btn-secondary btn-sm" title="Download PDF payslip" style="padding: 5px 9px;">
                                            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><line x1="16" y1="13" x2="8" y2="13"></line><line x1="16" y1="17" x2="8" y2="17"></line></svg>
                                        </a>
                                        <form method="post" action="${ctx}/admin/payroll/send-email" style="display:inline; margin:0;" onsubmit="return confirm('Send payslip email to employee ${d.employeeName} (${d.employeeEmail})?');">
                                            <input type="hidden" name="payrollId" value="${payroll.id}">
                                            <input type="hidden" name="employeeId" value="${d.employeeId}">
                                            <button type="submit" class="btn btn-secondary btn-sm" title="Email PDF payslip" style="padding: 5px 9px;">
                                                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"></path><polyline points="22,6 12,13 2,6"></polyline></svg>
                                            </button>
                                        </form>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
            </tbody>
        </table>
    </div>
</c:if>

<!-- ================= Payslip Statement Breakdown Modal ================= -->
<div class="modal-overlay" id="payslipModal" onclick="closePayslipModal(event)">
    <div class="modal-card" onclick="event.stopPropagation()">
        <div class="modal-header" style="background:#f8fafc; padding:18px 24px; border-bottom:1px solid #e2e8f0; display:flex; justify-content:space-between; align-items:center;">
            <div>
                <h3 style="margin:0; font-size:16px; font-weight:700; color:#0f172a;">Payslip Statement Breakdown</h3>
                <span class="muted small" id="mPeriod" style="font-weight:500; color:#64748b;">Month ${month}/${year}</span>
            </div>
            <button type="button" class="modal-close-btn" onclick="closePayslipModal()" title="Close">&times;</button>
        </div>

        <div class="modal-body-scroll">
            <div class="payslip-summary-box">
                <div>
                    <div style="font-size:16px; font-weight:700; color:#0f172a;" id="mName">--</div>
                    <div class="muted small" style="margin-top:2px; color:#64748b;" id="mMeta">--</div>
                </div>
                <div style="text-align:right;">
                    <div class="muted small" style="font-weight:600; text-transform:uppercase; color:#64748b;">Hourly Rate</div>
                    <div class="mono font-bold" style="font-size:15px; color:#1d4ed8;" id="mRate">--</div>
                </div>
            </div>

            <!-- Earnings Breakdown -->
            <div style="font-size:11px; font-weight:700; text-transform:uppercase; color:#64748b; margin-bottom:8px; letter-spacing:0.04em;">
                Earnings &amp; Allowances
            </div>
            <div style="background:#f8fafc; border:1px solid #e2e8f0; border-radius:8px; padding:6px 16px; margin-bottom:16px;">
                <div class="payslip-item-row">
                    <span style="color:#334155;">Base Salary (Monthly contracted)</span>
                    <span class="mono font-bold" id="mBase" style="color:#0f172a;">--</span>
                </div>
                <div class="payslip-item-row">
                    <span style="color:#334155;">Standard Worked Hours (<span id="mRegH"></span> hrs)</span>
                    <span class="mono font-bold" id="mRegPay" style="color:#0f172a;">--</span>
                </div>
                <div class="payslip-item-row">
                    <span style="color:#334155;">Weekday Overtime 150% (<span id="mOtWdH"></span> hrs)</span>
                    <span class="mono font-bold" style="color:#7c3aed;" id="mOtWdPay">--</span>
                </div>
                <div class="payslip-item-row">
                    <span style="color:#334155;">Weekend Overtime 200% (<span id="mOtWeH"></span> hrs)</span>
                    <span class="mono font-bold" style="color:#7c3aed;" id="mOtWePay">--</span>
                </div>
                <div class="payslip-item-row">
                    <span style="color:#334155;">Public Holiday Overtime 300% (<span id="mOtHolH"></span> hrs)</span>
                    <span class="mono font-bold" style="color:#7c3aed;" id="mOtHolPay">--</span>
                </div>
                <div class="payslip-item-row">
                    <span style="color:#334155;">Night Shift Differential +30% (<span id="mNightH"></span> hrs)</span>
                    <span class="mono font-bold" style="color:#1d4ed8;" id="mNightPay">--</span>
                </div>
                <div class="payslip-item-row">
                    <span style="color:#334155;">Night Overtime Bonus +20% (<span id="mNightOtH"></span> hrs)</span>
                    <span class="mono font-bold" style="color:#1d4ed8;" id="mNightOtPay">--</span>
                </div>
            </div>

            <!-- Deductions Breakdown -->
            <div style="font-size:11px; font-weight:700; text-transform:uppercase; color:#64748b; margin-bottom:8px; letter-spacing:0.04em;">
                Deductions &amp; Penalties
            </div>
            <div style="background:#fef2f2; border:1px solid #fee2e2; border-radius:8px; padding:6px 16px; margin-bottom:16px;">
                <div class="payslip-item-row" style="color:#dc2626;">
                    <span>Late Arrival Penalty (<span id="mLateM"></span> mins past grace period)</span>
                    <span class="mono font-bold" id="mPenalty">--</span>
                </div>
            </div>

            <!-- Net Salary Summary Banner -->
            <div class="payslip-net-banner" style="background:#ecfdf5; border:1px solid #a7f3d0; border-radius:8px; padding:14px 18px; display:flex; justify-content:space-between; align-items:center;">
                <div>
                    <div style="font-size:11px; font-weight:700; text-transform:uppercase; color:#059669; letter-spacing:0.04em;">Net Salary Disbursed (Take-Home)</div>
                    <div style="font-size:12px; color:#047857; margin-top:2px;">Earnings minus statutory late penalty</div>
                </div>
                <div class="mono font-bold" style="font-size:20px; color:#059669;" id="mNet">
                    --
                </div>
            </div>
        </div>

        <div class="modal-footer" style="padding:16px 24px; border-top:1px solid #e2e8f0; background:#f8fafc; display:flex; justify-content:flex-end; gap:10px;">
            <a id="mPdfBtn" href="#" class="btn btn-primary" style="display:inline-flex; align-items:center; gap:6px;">
                <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><line x1="16" y1="13" x2="8" y2="13"></line><line x1="16" y1="17" x2="8" y2="17"></line></svg>
                <span>Download PDF</span>
            </a>
            <button type="button" class="btn btn-secondary" onclick="closePayslipModal()">Close</button>
        </div>
    </div>
</div>

<script>
    function fmtNum(n) {
        if (n === null || n === undefined || n === '') return '0';
        return Number(n).toLocaleString('en-US');
    }

    function setTxt(id, val) {
        const el = document.getElementById(id);
        if (el) el.textContent = val;
    }

    function openPayslipFromBtn(btn) {
        if (!btn || !btn.dataset) return;
        const d = btn.dataset;
        showPayslipModal(
            d.id, d.code, d.name, d.dept,
            d.base, d.rate,
            d.regh, d.regp,
            d.otwdh, d.otwdp,
            d.otweh, d.otwep,
            d.otholh, d.otholp,
            d.nighth, d.nightp,
            d.nightoth, d.nightotp,
            d.latem, d.penalty, d.net
        );
    }

    function showPayslipModal(id, code, name, dept, base, rate, regH, regP, otWdH, otWdP, otWeH, otWeP, otHolH, otHolP, nightH, nightP, nightOtH, nightOtP, lateM, penalty, net) {
        setTxt('mName', name || '--');
        setTxt('mMeta', (code || '') + (dept ? ' &bull; ' + dept : ''));

        setTxt('mBase', fmtNum(base) + ' VND');
        setTxt('mRate', fmtNum(rate) + ' VND/h');

        setTxt('mRegH', regH || '0');
        setTxt('mRegPay', fmtNum(regP) + ' VND');

        setTxt('mOtWdH', otWdH || '0');
        setTxt('mOtWdPay', fmtNum(otWdP) + ' VND');

        setTxt('mOtWeH', otWeH || '0');
        setTxt('mOtWePay', fmtNum(otWeP) + ' VND');

        setTxt('mOtHolH', otHolH || '0');
        setTxt('mOtHolPay', fmtNum(otHolP) + ' VND');

        setTxt('mNightH', nightH || '0');
        setTxt('mNightPay', fmtNum(nightP) + ' VND');

        setTxt('mNightOtH', nightOtH || '0');
        setTxt('mNightOtPay', fmtNum(nightOtP) + ' VND');

        setTxt('mLateM', lateM || '0');
        setTxt('mPenalty', '-' + fmtNum(penalty) + ' VND');

        setTxt('mNet', fmtNum(net) + ' VND');

        const pdfBtn = document.getElementById('mPdfBtn');
        if (pdfBtn) {
            pdfBtn.href = '${ctx}/admin/payroll/export-pdf?payrollId=${payroll.id}&employeeId=' + id;
        }

        const modal = document.getElementById('payslipModal');
        if (modal) {
            modal.classList.add('active');
        }
    }

    function closePayslipModal(e) {
        if (!e || e.target.id === 'payslipModal' || !e.target) {
            const modal = document.getElementById('payslipModal');
            if (modal) {
                modal.classList.remove('active');
            }
        }
    }

    // Global ESC listener
    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape') {
            const modal = document.getElementById('payslipModal');
            if (modal) modal.classList.remove('active');
        }
    });
</script>

<%@ include file="/WEB-INF/views/common/footer.jspf" %>
