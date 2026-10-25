<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<c:set var="pageTitle" value="Operations Dashboard"/>
<c:set var="activeNav" value="dashboard"/>
<%@include file="/WEB-INF/views/common/header.jspf"%>

<style>
    /* ==========================================================================
       SmartAttend Operations & Attendance Dashboard (Enterprise Edition)
       Modern Swiss Light & B2B SaaS Clean Editorial Style
       ========================================================================== */

    /* Top Command Header */
    .dash-hero-hud {
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
    .dash-title-group {
        display: flex;
        flex-direction: column;
        gap: 6px;
    }
    .dash-title-row {
        display: flex;
        align-items: center;
        gap: 12px;
        flex-wrap: wrap;
    }
    .dash-heading {
        font-size: 22px;
        font-weight: 700;
        letter-spacing: -0.02em;
        color: #0f172a;
        margin: 0;
    }
    .live-telemetry-badge {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        padding: 4px 10px;
        border-radius: var(--radius-full);
        font-size: 11px;
        font-weight: 600;
        background: #ecfdf5;
        color: #059669;
        border: 1px solid #a7f3d0;
    }
    .telemetry-radar-dot {
        width: 7px;
        height: 7px;
        border-radius: 50%;
        background: #059669;
    }
    .telemetry-radar-dot.offline {
        background: #dc2626;
    }
    .dash-time-indicator {
        font-family: 'JetBrains Mono', monospace;
        font-size: 12px;
        font-weight: 600;
        color: #334155;
        background: #f1f5f9;
        border: 1px solid #e2e8f0;
        padding: 4px 10px;
        border-radius: 6px;
    }

    /* Action Buttons in Header */
    .hud-actions {
        display: flex;
        align-items: center;
        gap: 8px;
        flex-wrap: wrap;
    }
    .hud-btn {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        padding: 8px 14px;
        border-radius: 7px;
        font-size: 12px;
        font-weight: 600;
        text-decoration: none;
        transition: all var(--transition-fast);
        cursor: pointer;
        border: 1px solid transparent;
    }
    .hud-btn-primary {
        background: #1d4ed8;
        color: #ffffff;
        border-color: #1e40af;
        box-shadow: 0 1px 2px rgba(29, 78, 216, 0.2);
    }
    .hud-btn-primary:hover {
        background: #1e40af;
        color: #ffffff;
    }
    .hud-btn-secondary {
        background: #ffffff;
        color: #334155;
        border: 1px solid #cbd5e1;
        box-shadow: 0 1px 2px rgba(0, 0, 0, 0.04);
    }
    .hud-btn-secondary:hover {
        background: #f8fafc;
        border-color: #94a3b8;
        color: #0f172a;
    }

    /* Security Alert Banner (FR-DASH-04) */
    .security-alert-box {
        display: none;
        background: #fef2f2;
        border: 1px solid #fecaca;
        border-left: 4px solid #dc2626;
        padding: 14px 18px;
        border-radius: var(--radius);
        margin-bottom: 24px;
    }
    .security-alert-content {
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 16px;
    }
    .security-alert-title {
        color: #dc2626;
        font-weight: 700;
        font-size: 13px;
        display: flex;
        align-items: center;
        gap: 8px;
    }
    .security-alert-desc {
        color: #991b1b;
        font-size: 12px;
        margin-top: 2px;
    }

    /* 5 KPI Metric Bento Grid (FR-DASH-02) */
    .kpi-grid {
        display: grid;
        grid-template-columns: repeat(5, 1fr);
        gap: 16px;
        margin-bottom: 24px;
    }
    .kpi-card {
        background: #ffffff;
        border: 1px solid var(--border);
        border-radius: var(--radius);
        padding: 18px 20px;
        position: relative;
        overflow: hidden;
        transition: border-color var(--transition-fast), box-shadow var(--transition-fast);
        display: flex;
        flex-direction: column;
        justify-content: space-between;
        box-shadow: var(--shadow-xs);
    }
    .kpi-card:hover {
        border-color: var(--border-hover);
        box-shadow: var(--shadow-sm);
    }
    .kpi-card-top {
        display: flex;
        justify-content: space-between;
        align-items: flex-start;
        margin-bottom: 10px;
    }
    .kpi-label {
        font-size: 11px;
        color: #64748b;
        font-weight: 600;
        text-transform: uppercase;
        letter-spacing: 0.04em;
    }
    .kpi-icon-wrap {
        width: 32px;
        height: 32px;
        border-radius: 8px;
        display: grid;
        place-items: center;
        flex-shrink: 0;
    }
    .kpi-value {
        font-size: 28px;
        font-weight: 700;
        line-height: 1.1;
        letter-spacing: -0.02em;
        font-family: 'JetBrains Mono', monospace;
        margin-bottom: 6px;
        color: #0f172a;
    }
    .kpi-sub {
        font-size: 12px;
        color: #64748b;
        display: flex;
        align-items: center;
        gap: 4px;
    }

    /* KPI Colors (Clean & Semantic) */
    .kpi-present .kpi-icon-wrap { background: #ecfdf5; color: #059669; }
    .kpi-present .kpi-value { color: #059669; }

    .kpi-late .kpi-icon-wrap { background: #fffbeb; color: #d97706; }
    .kpi-late .kpi-value { color: #d97706; }

    .kpi-absent .kpi-icon-wrap { background: #fef2f2; color: #dc2626; }
    .kpi-absent .kpi-value { color: #dc2626; }

    .kpi-ot .kpi-icon-wrap { background: #eff6ff; color: #1d4ed8; }
    .kpi-ot .kpi-value { color: #1d4ed8; }

    .kpi-devices .kpi-icon-wrap { background: #f0f9ff; color: #0284c7; }
    .kpi-devices .kpi-value { color: #0284c7; }

    /* 2-Column Responsive Dashboard Layout */
    .dash-columns {
        display: grid;
        grid-template-columns: 1fr 400px;
        gap: 24px;
        align-items: start;
    }

    /* Section Cards */
    .section-card {
        background: #ffffff;
        border: 1px solid var(--border);
        border-radius: var(--radius);
        padding: 20px;
        margin-bottom: 24px;
        box-shadow: var(--shadow-xs);
    }
    .section-card-head {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 16px;
        flex-wrap: wrap;
        gap: 12px;
    }
    .section-card-title {
        font-size: 15px;
        font-weight: 700;
        color: #0f172a;
        display: flex;
        align-items: center;
        gap: 8px;
        margin: 0;
    }

    /* Table Modern */
    .table-modern-wrap {
        overflow-x: auto;
        border: 1px solid var(--border);
        border-radius: 8px;
        background: #ffffff;
    }
    .table-modern {
        width: 100%;
        border-collapse: collapse;
        text-align: left;
    }
    .table-modern th {
        font-size: 11px;
        font-weight: 700;
        color: #475569;
        background: #f8fafc;
        padding: 10px 14px;
        border-bottom: 1px solid var(--border);
        text-transform: uppercase;
        letter-spacing: 0.05em;
        white-space: nowrap;
    }
    .table-modern td {
        padding: 12px 14px;
        border-bottom: 1px solid #f1f5f9;
        font-size: 13px;
        vertical-align: middle;
        color: #334155;
    }
    .table-modern tr:last-child td {
        border-bottom: 0;
    }
    .table-modern tr:hover td {
        background: #f8fafc;
    }
    .table-modern td strong {
        color: #0f172a;
    }

    /* Gateway Status Box */
    .biometric-scanner-box {
        background: #f8fafc;
        border: 1px solid #e2e8f0;
        border-radius: var(--radius);
        padding: 20px;
        text-align: center;
        margin-bottom: 24px;
    }
    .scanner-icon-wrap {
        width: 52px;
        height: 52px;
        border-radius: 12px;
        background: #eff6ff;
        color: #1d4ed8;
        display: grid;
        place-items: center;
        margin: 0 auto 12px;
    }

    /* IoT Hardware Stations */
    .device-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
        gap: 14px;
    }
    .device-card-box {
        background: #f8fafc;
        border: 1px solid #e2e8f0;
        border-radius: 8px;
        padding: 14px 16px;
        display: flex;
        flex-direction: column;
        gap: 10px;
    }
    .device-box-top {
        display: flex;
        justify-content: space-between;
        align-items: flex-start;
    }
    .device-name-row {
        display: flex;
        align-items: center;
        gap: 10px;
    }
    .device-chip-icon {
        width: 32px;
        height: 32px;
        border-radius: 7px;
        background: #eff6ff;
        color: #1d4ed8;
        display: grid;
        place-items: center;
        flex-shrink: 0;
    }
    .device-status-badge {
        display: inline-flex;
        align-items: center;
        gap: 5px;
        font-size: 11px;
        font-weight: 600;
        padding: 2px 8px;
        border-radius: 999px;
    }
    .dev-online {
        background: #ecfdf5;
        color: #059669;
        border: 1px solid #a7f3d0;
    }
    .dev-offline {
        background: #fef2f2;
        color: #dc2626;
        border: 1px solid #fecaca;
    }

    /* Memory Bar */
    .mem-bar-wrap {
        display: flex;
        flex-direction: column;
        gap: 4px;
    }
    .mem-bar-track {
        height: 5px;
        background: #e2e8f0;
        border-radius: 999px;
        overflow: hidden;
    }
    .mem-bar-fill {
        height: 100%;
        border-radius: 999px;
        background: #1d4ed8;
        transition: width 0.3s ease;
    }

    /* Live Feed Sidebar */
    .feed-card {
        background: #ffffff;
        border: 1px solid var(--border);
        border-radius: var(--radius);
        padding: 20px;
        box-shadow: var(--shadow-xs);
    }
    .feed-header-row {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 14px;
        padding-bottom: 12px;
        border-bottom: 1px solid var(--border);
    }
    .feed-list {
        display: flex;
        flex-direction: column;
        gap: 10px;
        max-height: 520px;
        overflow-y: auto;
        padding-right: 2px;
    }
    .feed-item {
        display: flex;
        align-items: flex-start;
        gap: 10px;
        padding: 10px 12px;
        border-radius: 7px;
        background: #f8fafc;
        border: 1px solid #e2e8f0;
        transition: border-color var(--transition-fast), background var(--transition-fast);
    }
    .feed-item:hover {
        border-color: #cbd5e1;
        background: #f1f5f9;
    }
    .feed-avatar {
        width: 34px;
        height: 34px;
        border-radius: 7px;
        font-weight: 700;
        display: grid;
        place-items: center;
        font-size: 11px;
        flex-shrink: 0;
    }
    .feed-avatar.in {
        background: #ecfdf5;
        color: #059669;
        border: 1px solid #a7f3d0;
    }
    .feed-avatar.out {
        background: #eff6ff;
        color: #1d4ed8;
        border: 1px solid #bfdbfe;
    }
    .feed-avatar.fail {
        background: #fef2f2;
        color: #dc2626;
        border: 1px solid #fecaca;
    }
    .feed-info { flex: 1; min-width: 0; }
    .feed-name {
        font-weight: 600;
        font-size: 13px;
        color: #0f172a;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
    }
    .feed-meta {
        font-size: 11px;
        color: #64748b;
        font-family: 'JetBrains Mono', monospace;
        margin-top: 2px;
    }
    .feed-reason {
        font-size: 12px;
        color: #475569;
        margin-top: 3px;
        line-height: 1.35;
    }
    .feed-badge {
        font-size: 10px;
        font-weight: 700;
        padding: 2px 7px;
        border-radius: 4px;
        white-space: nowrap;
        text-transform: uppercase;
        letter-spacing: 0.03em;
    }

    @media (max-width: 1200px) {
        .kpi-grid { grid-template-columns: repeat(3, 1fr); }
    }
    @media (max-width: 1024px) {
        .dash-columns { grid-template-columns: 1fr; }
        .kpi-grid { grid-template-columns: repeat(2, 1fr); }
    }
    @media (max-width: 640px) {
        .kpi-grid { grid-template-columns: 1fr; }
        .dash-hero-hud { padding: 16px; }
    }
</style>

<!-- Top Command HUD -->
<div class="dash-hero-hud">
    <div class="dash-title-group">
        <div class="dash-title-row">
            <h1 class="dash-heading">Operations Dashboard</h1>
            <div class="live-telemetry-badge" id="liveStatusBadge">
                <span class="telemetry-radar-dot" id="liveDot"></span>
                <span id="liveStatusText">Live Feed Active</span>
            </div>
            <span class="dash-time-indicator" id="liveClockTicking">--:--:--</span>
        </div>
        <p class="muted small" style="margin: 0;">
            Biometric scan logs, sensor telemetry &amp; daily personnel status (<fmt:formatDate value="<%= new java.util.Date() %>" pattern="EEEE, MMMM dd, yyyy" />).
        </p>
    </div>
    <div class="hud-actions">
        <a href="${pageContext.request.contextPath}/kiosk" target="_blank" class="hud-btn hud-btn-secondary" title="Launch biometric kiosk display in full screen">
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="3" width="20" height="14" rx="2" ry="2"></rect><line x1="8" y1="21" x2="16" y2="21"></line><line x1="12" y1="17" x2="12" y2="21"></line></svg>
            Kiosk View
        </a>
        <a href="${pageContext.request.contextPath}/dev/simulator" class="hud-btn hud-btn-secondary" title="Simulate biometric scan events">
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="4 17 10 11 4 5"></polyline><line x1="12" y1="19" x2="20" y2="19"></line></svg>
            Simulator
        </a>
        <a href="${pageContext.request.contextPath}/admin/attendance" class="hud-btn hud-btn-primary" title="View all attendance records">
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><line x1="16" y1="13" x2="8" y2="13"></line><line x1="16" y1="17" x2="8" y2="17"></line></svg>
            Attendance Logs
        </a>
    </div>
</div>

<!-- Security Alert Banner (FR-DASH-04) -->
<div class="security-alert-box" id="secAlertBox">
    <div class="security-alert-content">
        <div>
            <div class="security-alert-title">
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"></path><line x1="12" y1="9" x2="12" y2="13"></line><line x1="12" y1="17" x2="12.01" y2="17"></line></svg>
                <span id="secAlertTitle">Biometric Security Alert</span>
            </div>
            <div class="security-alert-desc" id="secAlertDesc">Anomalous fingerprint scan activity detected.</div>
        </div>
        <button type="button" class="btn btn-ghost btn-sm" onclick="dismissSecAlert()" style="color:#fca5a5; border-color:rgba(239,68,68,0.3);">Dismiss</button>
    </div>
</div>

<!-- 5 KPI Stat Cards (FR-DASH-02) -->
<div class="kpi-grid">
    <!-- Present Today -->
    <div class="kpi-card kpi-present">
        <div class="kpi-card-top">
            <span class="kpi-label">Present Today</span>
            <div class="kpi-icon-wrap">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle><polyline points="16 11 18 13 22 9"></polyline></svg>
            </div>
        </div>
        <div class="kpi-value" id="kpiPresent">${presentCount}</div>
        <div class="kpi-sub">
            <span>Out of <strong style="color:#fff;">${totalEmployees}</strong> total personnel</span>
        </div>
    </div>

    <!-- Late Arrivals -->
    <div class="kpi-card kpi-late">
        <div class="kpi-card-top">
            <span class="kpi-label">Late Arrivals</span>
            <div class="kpi-icon-wrap">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><polyline points="12 6 12 12 16 14"></polyline><line x1="12" y1="2" x2="12" y2="4"></line></svg>
            </div>
        </div>
        <div class="kpi-value" id="kpiLate">${lateCount}</div>
        <div class="kpi-sub">
            <span>Exceeded 5-min grace window</span>
        </div>
    </div>

    <!-- Absents -->
    <div class="kpi-card kpi-absent">
        <div class="kpi-card-top">
            <span class="kpi-label">Absents</span>
            <div class="kpi-icon-wrap">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><path d="M16 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="8.5" cy="7" r="4"></circle><line x1="18" y1="8" x2="23" y2="13"></line><line x1="23" y1="8" x2="18" y2="13"></line></svg>
            </div>
        </div>
        <div class="kpi-value" id="kpiAbsent">${absentCount}</div>
        <div class="kpi-sub">
            <span>No check-in record for shift</span>
        </div>
    </div>

    <!-- Overtime -->
    <div class="kpi-card kpi-ot">
        <div class="kpi-card-top">
            <span class="kpi-label">Overtime (OT)</span>
            <div class="kpi-icon-wrap">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><polygon points="13 2 3 14 12 14 11 22 21 10 12 10 13 2"></polygon></svg>
            </div>
        </div>
        <div class="kpi-value" id="kpiOvertime">${overtimeCount}</div>
        <div class="kpi-sub">
            <span>Exceeded scheduled shift hours</span>
        </div>
    </div>

    <!-- Biometric Terminals -->
    <div class="kpi-card kpi-devices">
        <div class="kpi-card-top">
            <span class="kpi-label">Terminals</span>
            <div class="kpi-icon-wrap">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><rect x="4" y="4" width="16" height="16" rx="2" ry="2"></rect><rect x="9" y="9" width="6" height="6"></rect><line x1="9" y1="1" x2="9" y2="4"></line><line x1="15" y1="1" x2="15" y2="4"></line><line x1="9" y1="20" x2="9" y2="23"></line><line x1="15" y1="20" x2="15" y2="23"></line><line x1="20" y1="9" x2="23" y2="9"></line><line x1="20" y1="14" x2="23" y2="14"></line><line x1="1" y1="9" x2="4" y2="9"></line><line x1="1" y1="14" x2="4" y2="14"></line></svg>
            </div>
        </div>
        <div class="kpi-value" id="kpiDevices">
            <c:set var="onlineCount" value="0"/>
            <c:forEach var="d" items="${devices}">
                <c:if test="${d.online}"><c:set var="onlineCount" value="${onlineCount + 1}"/></c:if>
            </c:forEach>
            ${onlineCount} / ${devices.size()}
        </div>
        <div class="kpi-sub">
            <span>ESP32 + AS608 devices online</span>
        </div>
    </div>
</div>

<!-- 2-Column Dashboard Layout -->
<div class="dash-columns">

    <!-- Left Column: Currently Working + IoT Devices -->
    <div>
        <!-- Currently Checked In (FR-DASH-01) -->
        <div class="section-card">
            <div class="section-card-head">
                <div>
                    <h2 class="section-card-title">
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#3b82f6" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle><path d="M23 21v-2a4 4 0 0 0-3-3.87"></path><path d="M16 3.13a4 4 0 0 1 0 7.75"></path></svg>
                        Currently Working Personnel
                    </h2>
                    <p class="muted small" style="margin: 2px 0 0;">Staff members with active check-in timestamp and pending check-out.</p>
                </div>
                <span class="role-badge role-STAFF" id="workingBadge">${currentlyWorking.size()} active</span>
            </div>

            <div class="table-modern-wrap">
                <table class="table-modern" id="workingTable">
                    <thead>
                        <tr>
                            <th>Code</th>
                            <th>Full Name</th>
                            <th>Department</th>
                            <th>Shift</th>
                            <th>Check-in Time</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody id="workingTbody">
                        <c:choose>
                            <c:when test="${empty currentlyWorking}">
                                <tr id="emptyWorkingRow">
                                    <td colspan="6" style="padding: 0;">
                                        <div style="text-align: center; padding: 40px 20px;">
                                            <div style="width: 48px; height: 48px; border-radius: 12px; background: rgba(59, 130, 246, 0.12); color: #3b82f6; display: grid; place-items: center; margin: 0 auto 12px;">
                                                <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><polyline points="12 6 12 12 16 14"></polyline></svg>
                                            </div>
                                            <h3 style="font-size: 14px; margin: 0 0 4px 0; color: #0f172a;">No Personnel Currently Clocked In</h3>
                                            <p class="muted small" style="max-width: 400px; margin: 0 auto 16px;">
                                                When staff place their enrolled finger on the AS608 biometric terminal, their check-in record will appear here instantaneously.
                                            </p>
                                            <div style="display: flex; justify-content: center; gap: 8px;">
                                                <a href="${pageContext.request.contextPath}/dev/simulator" class="btn btn-secondary btn-sm">
                                                    Open Simulator &rarr;
                                                </a>
                                                <a href="${pageContext.request.contextPath}/kiosk" target="_blank" class="btn btn-primary btn-sm">
                                                    Launch Kiosk View &rarr;
                                                </a>
                                            </div>
                                        </div>
                                    </td>
                                </tr>
                            </c:when>
                            <c:otherwise>
                                <c:forEach var="a" items="${currentlyWorking}">
                                    <tr id="workRow-${a.employeeId}">
                                        <td class="mono font-bold" style="color: #60a5fa;">${a.employeeCode}</td>
                                        <td><strong><c:out value="${a.employeeName}"/></strong></td>
                                        <td><c:out value="${a.department}"/></td>
                                        <td><span class="role-badge" style="background:rgba(99,102,241,0.12); color:#a5b4fc; border:1px solid rgba(99,102,241,0.28);"><c:out value="${a.shiftName}"/></span></td>
                                        <td class="mono" style="color:#34d399; font-weight:600;">${a.formattedCheckIn}</td>
                                        <td>
                                            <span class="role-badge ${a.status == 'LATE' ? 'role-KIOSK' : 'role-STAFF'}">
                                                <c:out value="${a.statusLabel}"/>
                                            </span>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>
        </div>

        <!-- IoT Device Telemetry Stations (FR-DASH-05) -->
        <div class="section-card">
            <div class="section-card-head">
                <div>
                    <h2 class="section-card-title">
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#3b82f6" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="4" y="4" width="16" height="16" rx="2" ry="2"></rect><rect x="9" y="9" width="6" height="6"></rect><line x1="9" y1="1" x2="9" y2="4"></line><line x1="15" y1="1" x2="15" y2="4"></line><line x1="9" y1="20" x2="9" y2="23"></line><line x1="15" y1="20" x2="15" y2="23"></line></svg>
                        IoT Biometric Terminals (ESP32 + AS608)
                    </h2>
                    <p class="muted small" style="margin: 2px 0 0;">Hardware terminal telemetry (60s poll) and optical sensor readiness.</p>
                </div>
            </div>
            <div class="device-grid">
                <c:forEach var="d" items="${devices}">
                    <div class="device-card-box" id="deviceBox-${d.id}">
                        <div class="device-box-top">
                            <div class="device-name-row">
                                <div class="device-chip-icon">
                                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M5 12.55a11 11 0 0 1 14.08 0"></path><path d="M1.42 9a16 16 0 0 1 21.16 0"></path><path d="M8.53 16.11a6 6 0 0 1 6.95 0"></path><line x1="12" y1="20" x2="12.01" y2="20"></line></svg>
                                </div>
                                <div>
                                    <div style="font-weight:600; font-size:13px; color:#ffffff;"><c:out value="${d.name}"/></div>
                                    <div class="muted small"><c:out value="${d.location}"/></div>
                                </div>
                            </div>
                            <span class="device-status-badge ${d.online ? 'dev-online' : 'dev-offline'}" id="devBadge-${d.id}">
                                ${d.online ? '● Online' : '○ Offline'}
                            </span>
                        </div>
                        <div class="mem-bar-wrap">
                            <div style="display:flex; justify-content:space-between; font-size:11px;" class="muted">
                                <span>Sensor Memory</span>
                                <span class="mono" style="color:#60a5fa;">AS608 Optical</span>
                            </div>
                            <div class="mem-bar-track">
                                <div class="mem-bar-fill" style="width: ${d.online ? '68%' : '0%'};"></div>
                            </div>
                        </div>
                        <div style="display:flex; justify-content:space-between; align-items:center; border-top:1px solid rgba(255,255,255,0.06); padding-top:8px;">
                            <span class="mono small muted">Ping: ${d.formattedHeartbeat}</span>
                            <a href="${pageContext.request.contextPath}/dev/simulator" class="small font-bold" style="color:var(--primary);">Test Device &rarr;</a>
                        </div>
                    </div>
                </c:forEach>
            </div>
        </div>
    </div>

    <!-- Right Column: Gateway Status & Live Feed (FR-DASH-03) -->
    <div>
        <!-- Biometric Gateway Status Widget -->
        <div class="biometric-scanner-box">
            <div class="scanner-icon-wrap">
                <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M2 12C2 6.5 6.5 2 12 2a10 10 0 0 1 8 4"/>
                    <path d="M5 19.5C5.5 18 6 15 6 12c0-3.5 2.5-6 6-6"/>
                    <path d="M12 10c-1.1 0-2 .9-2 2 0 3-1.5 5.5-3 7"/>
                    <path d="M22 12c0 3-1 5.5-2 7.5"/>
                    <path d="M14 12c0 3.5-1 6.5-2 9"/>
                    <path d="M18 12a6 6 0 0 0-6-6"/>
                    <path d="M18 12c0 2.5-.5 5-1 7"/>
                </svg>
            </div>
            <div style="font-weight: 700; font-size: 14px; color: #0f172a;">
                Biometric Gateway Active
            </div>
            <div class="muted small mono" style="margin-top: 4px;">
                Optical AS608 &bull; 500 DPI &bull; Min Conf: 50%
            </div>
            <div style="margin-top: 14px;">
                <a href="${pageContext.request.contextPath}/dev/simulator" class="btn btn-secondary btn-sm" style="width: 100%; justify-content: center;">
                    Open Hardware Simulator
                </a>
            </div>
        </div>

        <!-- Live Activity Stream Card -->
        <div class="feed-card">
            <div class="feed-header-row">
                <div style="display:flex; align-items:center; gap:8px;">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#3b82f6" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 12h-4l-3 9L9 3l-3 9H2"></path></svg>
                    <span style="font-size:14px; font-weight:700; color:#ffffff;">Live Activity Feed</span>
                </div>
                <span class="live-telemetry-badge">
                    <span class="telemetry-radar-dot"></span> Live
                </span>
            </div>

            <div class="feed-list" id="feedList">
                <c:choose>
                    <c:when test="${empty recentLogs}">
                        <div class="empty small" id="emptyFeedMsg" style="text-align:center; padding:32px; color:var(--muted);">No recent scans recorded.</div>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="log" items="${recentLogs}">
                            <div class="feed-item">
                                <div class="feed-avatar ${log.result == 'CHECK_IN' ? 'in' : log.result == 'CHECK_OUT' ? 'out' : 'fail'}">
                                    <c:choose>
                                        <c:when test="${log.result == 'CHECK_IN'}">IN</c:when>
                                        <c:when test="${log.result == 'CHECK_OUT'}">OUT</c:when>
                                        <c:otherwise>?</c:otherwise>
                                    </c:choose>
                                </div>
                                <div class="feed-info">
                                    <div class="feed-name">
                                        <c:out value="${not empty log.employeeName ? log.employeeName : 'Unrecognized Fingerprint'}"/>
                                    </div>
                                    <div class="feed-meta">
                                        ${log.formattedTime} &bull; <c:out value="${log.deviceName != null ? log.deviceName : 'Terminal'}"/>
                                        <c:if test="${log.confidenceScore != null}">
                                            &bull; Conf: <strong style="color:#60a5fa;">${log.confidenceScore}%</strong>
                                        </c:if>
                                    </div>
                                    <div class="feed-reason">
                                        <c:out value="${log.reason}"/>
                                    </div>
                                </div>
                                <div>
                                    <span class="feed-badge" style="${log.result == 'CHECK_IN' ? 'background:rgba(16,185,129,0.12); color:#34d399; border:1px solid rgba(16,185,129,0.28);' : log.result == 'CHECK_OUT' ? 'background:rgba(59,130,246,0.12); color:#60a5fa; border:1px solid rgba(59,130,246,0.28);' : 'background:rgba(239,68,68,0.12); color:#f87171; border:1px solid rgba(239,68,68,0.28);'}">
                                        <c:out value="${log.result}"/>
                                    </span>
                                </div>
                            </div>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>

</div>

<script>
    const contextPath = '${pageContext.request.contextPath}';
    let alertHideTimer = null;

    // Real-time ticking digital clock
    function updateClock() {
        const now = new Date();
        const timeStr = now.toLocaleTimeString('en-US', { hour12: false });
        const el = document.getElementById('liveClockTicking');
        if (el) el.textContent = timeStr;
    }
    setInterval(updateClock, 1000);
    updateClock();

    function dismissSecAlert() {
        document.getElementById('secAlertBox').style.display = 'none';
    }

    function showSecAlert(title, desc) {
        const box = document.getElementById('secAlertBox');
        document.getElementById('secAlertTitle').textContent = title;
        document.getElementById('secAlertDesc').textContent = desc;
        box.style.display = 'block';

        clearTimeout(alertHideTimer);
        alertHideTimer = setTimeout(() => {
            box.style.display = 'none';
        }, 12000);
    }

    // Add event item to live feed (FR-DASH-03)
    function prependFeedItem(data) {
        const list = document.getElementById('feedList');
        const empty = document.getElementById('emptyFeedMsg');
        if (empty) empty.style.display = 'none';

        const item = document.createElement('div');
        item.className = 'feed-item';

        let badgeStyle = 'background:rgba(239,68,68,0.12); color:#f87171; border:1px solid rgba(239,68,68,0.28);';
        let avatarClass = 'fail';
        let avatarText = '?';

        if (data.result === 'CHECK_IN') {
            badgeStyle = 'background:rgba(16,185,129,0.12); color:#34d399; border:1px solid rgba(16,185,129,0.28);';
            avatarClass = 'in';
            avatarText = 'IN';
        } else if (data.result === 'CHECK_OUT') {
            badgeStyle = 'background:rgba(59,130,246,0.12); color:#60a5fa; border:1px solid rgba(59,130,246,0.28);';
            avatarClass = 'out';
            avatarText = 'OUT';
        }

        item.innerHTML = 
            '<div class="feed-avatar ' + avatarClass + '">' + avatarText + '</div>' +
            '<div class="feed-info">' +
                '<div class="feed-name">' + (data.employeeName || 'Unknown') + '</div>' +
                '<div class="feed-meta">' + (data.time || '') + ' &bull; ' + (data.deviceName || 'Scanner') + 
                    (data.confidence ? ' &bull; Conf: <strong>' + data.confidence + '%</strong>' : '') + '</div>' +
                '<div class="feed-reason">' + (data.message || '') + '</div>' +
            '</div>' +
            '<div>' +
                '<span class="feed-badge" style="' + badgeStyle + '">' + data.result + '</span>' +
            '</div>';

        list.insertBefore(item, list.firstChild);

        if (list.children.length > 30) {
            list.removeChild(list.lastChild);
        }
    }

    // Refresh currently working table (FR-DASH-01)
    function updateWorkingTable(emp, action, timeStr, statusLabel) {
        const tbody = document.getElementById('workingTbody');
        const emptyRow = document.getElementById('emptyWorkingRow');
        const badge = document.getElementById('workingBadge');

        if (!emp || !emp.id) return;

        const rowId = 'workRow-' + emp.id;
        const existingRow = document.getElementById(rowId);

        if (action === 'CHECK_IN') {
            if (emptyRow) emptyRow.style.display = 'none';
            if (existingRow) {
                existingRow.parentNode.removeChild(existingRow);
            }
            const tr = document.createElement('tr');
            tr.id = rowId;
            tr.innerHTML = 
                '<td class="mono font-bold" style="color:#60a5fa;">' + (emp.code || '') + '</td>' +
                '<td><strong>' + (emp.name || '') + '</strong></td>' +
                '<td>' + (emp.department || '') + '</td>' +
                '<td><span class="role-badge" style="background:rgba(99,102,241,0.12); color:#a5b4fc; border:1px solid rgba(99,102,241,0.28);">Current</span></td>' +
                '<td class="mono" style="color:#34d399; font-weight:600;">' + (timeStr || '') + '</td>' +
                '<td><span class="role-badge role-STAFF">' + (statusLabel || 'On Time') + '</span></td>';
            tbody.insertBefore(tr, tbody.firstChild);
        } else if (action === 'CHECK_OUT') {
            if (existingRow) {
                existingRow.parentNode.removeChild(existingRow);
            }
        }

        const currentCount = tbody.querySelectorAll('tr:not(#emptyWorkingRow)').length;
        if (badge) badge.textContent = currentCount + ' active';
        if (currentCount === 0 && emptyRow) {
            emptyRow.style.display = '';
        }
    }

    // Setup Server-Sent Events (SSE) (FR-DASH-06)
    function initDashboardSse() {
        const badge = document.getElementById('liveStatusBadge');
        const dot = document.getElementById('liveDot');
        const text = document.getElementById('liveStatusText');

        const es = new EventSource(contextPath + '/admin/dashboard/stream');

        es.addEventListener('open', () => {
            if (dot) dot.className = 'telemetry-radar-dot';
            if (text) text.textContent = 'Live Feed Active';
            if (badge) {
                badge.style.background = 'rgba(16, 185, 129, 0.12)';
                badge.style.color = '#34d399';
            }
        });

        es.addEventListener('scan_event', (e) => {
            try {
                const data = JSON.parse(e.data);
                prependFeedItem(data);

                if (data.result === 'CHECK_IN') {
                    const pres = document.getElementById('kpiPresent');
                    if (pres) pres.textContent = parseInt(pres.textContent || '0') + 1;
                    if (data.status === 'LATE') {
                        const late = document.getElementById('kpiLate');
                        if (late) late.textContent = parseInt(late.textContent || '0') + 1;
                    }
                    updateWorkingTable({ id: 1, name: data.employeeName, code: data.employeeCode, department: data.department }, 
                                       'CHECK_IN', data.time, data.statusLabel);
                } else if (data.result === 'CHECK_OUT') {
                    if (data.status === 'OVERTIME') {
                        const ot = document.getElementById('kpiOvertime');
                        if (ot) ot.textContent = parseInt(ot.textContent || '0') + 1;
                    }
                    updateWorkingTable({ id: 1, name: data.employeeName, code: data.employeeCode, department: data.department }, 
                                       'CHECK_OUT', data.time, data.statusLabel);
                }
            } catch (err) {
                console.error('Scan event parse error', err);
            }
        });

        es.addEventListener('security_alert', (e) => {
            try {
                const data = JSON.parse(e.data);
                showSecAlert('SECURITY ALERT', data.message || 'Anomalous fingerprint scan attempt detected!');
            } catch (err) {
                console.error('Security alert parse error', err);
            }
        });

        es.addEventListener('device_status', (e) => {
            try {
                const data = JSON.parse(e.data);
                const badge = document.getElementById('devBadge-' + data.deviceId);
                if (badge) {
                    badge.className = 'device-status-badge ' + (data.online ? 'dev-online' : 'dev-offline');
                    badge.textContent = data.online ? '● Online' : '○ Offline';
                }
            } catch (err) {
                console.error('Device status parse error', err);
            }
        });

        es.onerror = () => {
            if (dot) dot.className = 'telemetry-radar-dot offline';
            if (text) text.textContent = 'Reconnecting...';
            if (badge) {
                badge.style.background = 'rgba(239, 68, 68, 0.12)';
                badge.style.color = '#f87171';
            }
        };
    }

    // AJAX Polling fallback every 5s if needed (FR-DASH-06)
    setInterval(async () => {
        try {
            const res = await fetch(contextPath + '/admin/dashboard?action=poll', {
                headers: { 'Accept': 'application/json' }
            });
            if (res.ok) {
                const data = await res.json();
                if (data.stats) {
                    const elP = document.getElementById('kpiPresent');
                    if (elP) elP.textContent = data.stats.present;
                    const elL = document.getElementById('kpiLate');
                    if (elL) elL.textContent = data.stats.late;
                    const elA = document.getElementById('kpiAbsent');
                    if (elA) elA.textContent = data.stats.absent;
                    const elO = document.getElementById('kpiOvertime');
                    if (elO) elO.textContent = data.stats.overtime;
                }
            }
        } catch (err) {}
    }, 5000);

    window.addEventListener('DOMContentLoaded', () => {
        initDashboardSse();
    });
</script>

<%@include file="/WEB-INF/views/common/footer.jspf"%>
