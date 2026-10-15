<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<c:set var="pageTitle" value="Live Dashboard"/>
<c:set var="activeNav" value="dashboard"/>
<%@include file="/WEB-INF/views/common/header.jspf"%>

<style>
    /* Dashboard Modern Aesthetics */
    .dash-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        flex-wrap: wrap;
        gap: 16px;
        margin-bottom: 24px;
    }
    
    .live-badge {
        display: inline-flex;
        align-items: center;
        gap: 8px;
        padding: 6px 14px;
        border-radius: 999px;
        font-size: 13px;
        font-weight: 600;
        background: #ecfdf5;
        color: #065f46;
        border: 1px solid #a7f3d0;
    }
    .live-dot {
        width: 8px;
        height: 8px;
        border-radius: 50%;
        background: #10b981;
        box-shadow: 0 0 8px #10b981;
        animation: pulseLive 2s infinite;
    }
    .live-dot.offline {
        background: #ef4444;
        box-shadow: 0 0 8px #ef4444;
        animation: none;
    }
    @keyframes pulseLive {
        0%, 100% { transform: scale(1); opacity: 1; }
        50% { transform: scale(1.3); opacity: 0.5; }
    }

    /* Security Alert Banner (FR-DASH-04) */
    .security-alert-box {
        display: none;
        background: #fef2f2;
        border: 1px solid #fecaca;
        border-left: 5px solid #dc2626;
        padding: 16px 20px;
        border-radius: 10px;
        margin-bottom: 24px;
        box-shadow: 0 4px 15px rgba(220, 38, 38, 0.1);
        animation: shake 0.5s ease-in-out;
    }
    .security-alert-content {
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 16px;
    }
    .security-alert-title {
        color: #991b1b;
        font-weight: 700;
        font-size: 15px;
        display: flex;
        align-items: center;
        gap: 8px;
    }
    .security-alert-desc {
        color: #b91c1c;
        font-size: 13px;
        margin-top: 4px;
    }

    /* 5 KPI Stat Cards (FR-DASH-02) */
    .kpi-grid {
        display: grid;
        grid-template-columns: repeat(5, 1fr);
        gap: 16px;
        margin-bottom: 24px;
    }
    .kpi-card {
        background: var(--surface);
        border: 1px solid var(--line);
        border-radius: var(--radius);
        padding: 18px 20px;
        position: relative;
        overflow: hidden;
        transition: transform 0.2s, box-shadow 0.2s;
    }
    .kpi-card:hover {
        transform: translateY(-2px);
        box-shadow: 0 8px 20px rgba(0,0,0,0.04);
    }
    .kpi-label {
        font-size: 13px;
        color: var(--muted);
        font-weight: 600;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        margin-bottom: 8px;
    }
    .kpi-value {
        font-size: 32px;
        font-weight: 800;
        line-height: 1;
        font-family: ui-monospace, "Cascadia Code", monospace;
    }
    .kpi-sub {
        font-size: 12px;
        color: var(--muted);
        margin-top: 8px;
    }

    .kpi-present { border-top: 4px solid #10b981; }
    .kpi-present .kpi-value { color: #059669; }

    .kpi-late { border-top: 4px solid #f59e0b; }
    .kpi-late .kpi-value { color: #d97706; }

    .kpi-absent { border-top: 4px solid #ef4444; }
    .kpi-absent .kpi-value { color: #dc2626; }

    .kpi-ot { border-top: 4px solid #8b5cf6; }
    .kpi-ot .kpi-value { color: #7c3aed; }

    .kpi-devices { border-top: 4px solid #3b82f6; }
    .kpi-devices .kpi-value { color: #2563eb; }

    /* Dashboard Layout: 2 Columns */
    .dash-columns {
        display: grid;
        grid-template-columns: 1fr 400px;
        gap: 24px;
        align-items: start;
    }

    /* Live Feed Sidebar (FR-DASH-03) */
    .feed-card {
        background: var(--surface);
        border: 1px solid var(--line);
        border-radius: var(--radius);
        padding: 20px;
    }
    .feed-title {
        font-size: 16px;
        font-weight: 700;
        margin-bottom: 16px;
        display: flex;
        justify-content: space-between;
        align-items: center;
    }
    .feed-list {
        display: flex;
        flex-direction: column;
        gap: 12px;
        max-height: 520px;
        overflow-y: auto;
        padding-right: 4px;
    }
    .feed-item {
        display: flex;
        align-items: flex-start;
        gap: 12px;
        padding: 12px;
        border-radius: 8px;
        background: #f9fafb;
        border: 1px solid #f3f4f6;
        transition: all 0.3s ease;
    }
    .feed-item.new-arrival {
        animation: flashHighlight 1.5s ease-out;
    }
    @keyframes flashHighlight {
        0% { background: #dbeafe; transform: scale(1.02); }
        100% { background: #f9fafb; transform: scale(1); }
    }
    .feed-avatar {
        width: 38px;
        height: 38px;
        border-radius: 8px;
        background: #e0e7ff;
        color: #4338ca;
        font-weight: 700;
        display: grid;
        place-items: center;
        font-size: 13px;
        flex-shrink: 0;
    }
    .feed-info { flex: 1; min-width: 0; }
    .feed-name {
        font-weight: 600;
        font-size: 13px;
        color: var(--text);
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
    }
    .feed-time {
        font-size: 11px;
        color: var(--muted);
        font-family: ui-monospace, monospace;
    }
    .feed-badge {
        font-size: 11px;
        font-weight: 700;
        padding: 2px 6px;
        border-radius: 4px;
        white-space: nowrap;
    }

    /* Currently Working Table (FR-DASH-01) */
    .table-card {
        background: var(--surface);
        border: 1px solid var(--line);
        border-radius: var(--radius);
        padding: 20px;
        margin-bottom: 24px;
    }
    .table-card-head {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 16px;
    }

    /* Device Status Widgets (FR-DASH-05) */
    .device-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
        gap: 16px;
    }
    .device-box {
        background: #f9fafb;
        border: 1px solid var(--line);
        border-radius: 8px;
        padding: 16px;
        display: flex;
        align-items: center;
        justify-content: space-between;
    }
    .device-status-badge {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        font-size: 12px;
        font-weight: 700;
        padding: 4px 10px;
        border-radius: 999px;
    }
    .dev-online { background: #dcfce7; color: #15803d; }
    .dev-offline { background: #fee2e2; color: #b91c1c; }

    @media (max-width: 1024px) {
        .kpi-grid { grid-template-columns: repeat(2, 1fr); }
        .dash-columns { grid-template-columns: 1fr; }
    }
</style>

<div class="dash-header">
    <div>
        <div style="display:flex; align-items:center; gap:12px;">
            <h1 style="margin:0;">Live Dashboard</h1>
            <div class="live-badge" id="liveStatusBadge">
                <span class="live-dot" id="liveDot"></span>
                <span id="liveStatusText">Real-time (SSE)</span>
            </div>
        </div>
        <p class="muted" style="margin-top:4px;">Live biometric attendance monitoring and IoT sensor terminal overview for today (<fmt:formatDate value="<%= new java.util.Date() %>" pattern="EEEE, MMMM dd, yyyy" />).</p>
    </div>
    <div style="display:flex; gap:10px;">
        <a href="${pageContext.request.contextPath}/kiosk" target="_blank" class="btn btn-secondary btn-sm">
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="margin-right:4px;"><rect x="2" y="3" width="20" height="14" rx="2" ry="2"></rect><line x1="8" y1="21" x2="16" y2="21"></line><line x1="12" y1="17" x2="12" y2="21"></line></svg>
            Launch Kiosk
        </a>
        <a href="${pageContext.request.contextPath}/dev/simulator" class="btn btn-secondary btn-sm">
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="margin-right:4px;"><polyline points="4 17 10 11 4 5"></polyline><line x1="12" y1="19" x2="20" y2="19"></line></svg>
            Simulator
        </a>
        <a href="${pageContext.request.contextPath}/admin/attendance" class="btn btn-sm">Attendance Records</a>
    </div>
</div>

<!-- Security Alert Banner (FR-DASH-04) -->
<div class="security-alert-box" id="secAlertBox">
    <div class="security-alert-content">
        <div>
            <div class="security-alert-title">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"></path><line x1="12" y1="9" x2="12" y2="13"></line><line x1="12" y1="17" x2="12.01" y2="17"></line></svg>
                <span id="secAlertTitle">System Security Alert</span>
            </div>
            <div class="security-alert-desc" id="secAlertDesc">Anomalous fingerprint scan activity detected.</div>
        </div>
        <button type="button" class="btn btn-ghost btn-sm" onclick="dismissSecAlert()" style="color:#991b1b; border-color:#fca5a5;">Dismiss</button>
    </div>
</div>

<!-- 5 KPI Stat Cards (FR-DASH-02) -->
<div class="kpi-grid">
    <div class="kpi-card kpi-present">
        <div class="kpi-label">Present Today</div>
        <div class="kpi-value" id="kpiPresent">${presentCount}</div>
        <div class="kpi-sub">Out of <strong>${totalEmployees}</strong> total personnel</div>
    </div>
    <div class="kpi-card kpi-late">
        <div class="kpi-label">Late Arrivals</div>
        <div class="kpi-value" id="kpiLate">${lateCount}</div>
        <div class="kpi-sub">Exceeded grace period</div>
    </div>
    <div class="kpi-card kpi-absent">
        <div class="kpi-label">Absents</div>
        <div class="kpi-value" id="kpiAbsent">${absentCount}</div>
        <div class="kpi-sub">No scan recorded for shift</div>
    </div>
    <div class="kpi-card kpi-ot">
        <div class="kpi-label">Overtime (OT)</div>
        <div class="kpi-value" id="kpiOvertime">${overtimeCount}</div>
        <div class="kpi-sub">Exceeded standard shift hours</div>
    </div>
    <div class="kpi-card kpipi-devices">
        <div class="kpi-label">Biometric Terminals</div>
        <div class="kpi-value" id="kpiDevices">
            <c:set var="onlineCount" value="0"/>
            <c:forEach var="d" items="${devices}">
                <c:if test="${d.online}"><c:set var="onlineCount" value="${onlineCount + 1}"/></c:if>
            </c:forEach>
            ${onlineCount}/${devices.size()}
        </div>
        <div class="kpi-sub">Terminals currently online</div>
    </div>
</div>

<!-- 2-Column Dashboard Layout -->
<div class="dash-columns">

    <!-- Left Column: Currently Working + Devices -->
    <div>
        <!-- Currently Checked In (FR-DASH-01) -->
        <div class="table-card">
            <div class="table-card-head">
                <div>
                    <h2 style="font-size:16px; margin:0;">Currently Working Personnel</h2>
                    <p class="muted small" style="margin:2px 0 0;">Personnel who checked in and have not yet checked out today.</p>
                </div>
                <span class="role-badge role-STAFF" id="workingBadge">${currentlyWorking.size()} active</span>
            </div>

            <div class="table-wrap">
                <table class="table" id="workingTable">
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
                                    <td colspan="6" class="empty">No personnel currently clocked in.</td>
                                </tr>
                            </c:when>
                            <c:otherwise>
                                <c:forEach var="a" items="${currentlyWorking}">
                                    <tr id="workRow-${a.employeeId}">
                                        <td class="mono font-bold">${a.employeeCode}</td>
                                        <td><strong><c:out value="${a.employeeName}"/></strong></td>
                                        <td><c:out value="${a.department}"/></td>
                                        <td><span class="status-pill" style="background:#eef2ff; color:#3730a3;"><c:out value="${a.shiftName}"/></span></td>
                                        <td class="mono">${a.formattedCheckIn}</td>
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

        <!-- Devices Status (FR-DASH-05) -->
        <div class="table-card">
            <h2 style="font-size:16px; margin:0 0 16px 0;">IoT Terminals (ESP32 + AS608)</h2>
            <div class="device-grid">
                <c:forEach var="d" items="${devices}">
                    <div class="device-box" id="deviceBox-${d.id}">
                        <div>
                            <div style="font-weight:700; font-size:14px;"><c:out value="${d.name}"/></div>
                            <div class="muted small"><c:out value="${d.location}"/></div>
                            <div class="mono small muted" style="margin-top:4px;">Heartbeat: ${d.formattedHeartbeat}</div>
                        </div>
                        <div>
                            <span class="device-status-badge ${d.online ? 'dev-online' : 'dev-offline'}" id="devBadge-${d.id}">
                                ${d.online ? '● Online' : '○ Offline'}
                            </span>
                        </div>
                    </div>
                </c:forEach>
            </div>
        </div>
    </div>

    <!-- Right Column: Live Event Feed (FR-DASH-03) -->
    <div>
        <div class="feed-card">
            <div class="feed-title">
                <span>Live Event Stream</span>
                <span class="badge-status status-online" style="font-size:11px;">Live</span>
            </div>

            <div class="feed-list" id="feedList">
                <c:choose>
                    <c:when test="${empty recentLogs}">
                        <div class="empty small" id="emptyFeedMsg">No recent scans recorded.</div>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="log" items="${recentLogs}">
                            <div class="feed-item">
                                <div class="feed-avatar">
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
                                    <div class="feed-time">
                                        ${log.formattedTime} · <c:out value="${log.deviceName != null ? log.deviceName : 'Terminal'}"/>
                                        <c:if test="${log.confidenceScore != null}">
                                            · Confidence: ${log.confidenceScore}%
                                        </c:if>
                                    </div>
                                    <div style="font-size:11px; color:#4b5563; margin-top:2px;">
                                        <c:out value="${log.reason}"/>
                                    </div>
                                </div>
                                <div>
                                    <span class="feed-badge" style="${log.result == 'CHECK_IN' ? 'background:#dcfce7; color:#15803d;' : log.result == 'CHECK_OUT' ? 'background:#dbeafe; color:#1e40af;' : 'background:#fee2e2; color:#b91c1c;'}">
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
        item.className = 'feed-item new-arrival';

        let badgeBg = '#fee2e2; color:#b91c1c;';
        let avatarText = '?';
        if (data.result === 'CHECK_IN') {
            badgeBg = '#dcfce7; color:#15803d;';
            avatarText = 'IN';
        } else if (data.result === 'CHECK_OUT') {
            badgeBg = '#dbeafe; color:#1e40af;';
            avatarText = 'OUT';
        }

        item.innerHTML = 
            '<div class="feed-avatar">' + avatarText + '</div>' +
            '<div class="feed-info">' +
                '<div class="feed-name">' + (data.employeeName || 'Unknown') + '</div>' +
                '<div class="feed-time">' + (data.time || '') + ' · ' + (data.deviceName || 'Scanner') + 
                    (data.confidence ? ' · Confidence: ' + data.confidence + '%' : '') + '</div>' +
                '<div style="font-size:11px; color:#4b5563; margin-top:2px;">' + (data.message || '') + '</div>' +
            '</div>' +
            '<div>' +
                '<span class="feed-badge" style="background:' + badgeBg + '">' + data.result + '</span>' +
            '</div>';

        list.insertBefore(item, list.firstChild);

        // Keep maximum 30 items
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
            tr.className = 'new-arrival';
            tr.innerHTML = 
                '<td class="mono font-bold">' + (emp.code || '') + '</td>' +
                '<td><strong>' + (emp.name || '') + '</strong></td>' +
                '<td>' + (emp.department || '') + '</td>' +
                '<td><span class="status-pill" style="background:#eef2ff; color:#3730a3;">Current</span></td>' +
                '<td class="mono">' + (timeStr || '') + '</td>' +
                '<td><span class="role-badge role-STAFF">' + (statusLabel || 'On Time') + '</span></td>';
            tbody.insertBefore(tr, tbody.firstChild);
        } else if (action === 'CHECK_OUT') {
            if (existingRow) {
                existingRow.parentNode.removeChild(existingRow);
            }
        }

        // Count rows
        const currentCount = tbody.querySelectorAll('tr:not(#emptyWorkingRow)').length;
        badge.textContent = currentCount + ' active';
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
            dot.className = 'live-dot';
            text.textContent = 'Real-time (SSE)';
            badge.style.background = '#ecfdf5';
            badge.style.color = '#065f46';
        });

        es.addEventListener('scan_event', (e) => {
            try {
                const data = JSON.parse(e.data);
                prependFeedItem(data);

                // Update KPI counters
                if (data.result === 'CHECK_IN') {
                    const pres = document.getElementById('kpiPresent');
                    pres.textContent = parseInt(pres.textContent || '0') + 1;
                    if (data.status === 'LATE') {
                        const late = document.getElementById('kpiLate');
                        late.textContent = parseInt(late.textContent || '0') + 1;
                    }
                    updateWorkingTable({ id: 1, name: data.employeeName, code: data.employeeCode, department: data.department }, 
                                       'CHECK_IN', data.time, data.statusLabel);
                } else if (data.result === 'CHECK_OUT') {
                    if (data.status === 'OVERTIME') {
                        const ot = document.getElementById('kpiOvertime');
                        ot.textContent = parseInt(ot.textContent || '0') + 1;
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
            dot.className = 'live-dot offline';
            text.textContent = 'Reconnecting (Polling fallback)...';
            badge.style.background = '#fef2f2';
            badge.style.color = '#991b1b';
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
                    document.getElementById('kpiPresent').textContent = data.stats.present;
                    document.getElementById('kpiLate').textContent = data.stats.late;
                    document.getElementById('kpiAbsent').textContent = data.stats.absent;
                    document.getElementById('kpiOvertime').textContent = data.stats.overtime;
                }
            }
        } catch (err) {
            // Quiet fallback
        }
    }, 5000);

    window.addEventListener('DOMContentLoaded', () => {
        initDashboardSse();
    });
</script>

<%@include file="/WEB-INF/views/common/footer.jspf"%>
