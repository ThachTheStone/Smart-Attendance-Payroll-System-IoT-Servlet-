<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<c:set var="pageTitle" value="Dashboard"/>
<c:set var="activeNav" value="dashboard"/>
<%@include file="/WEB-INF/views/common/header.jspf"%>

<style>
    /* Dashboard - today's attendance at a glance (FR-DASH-01..06) */
    .db-header {
        display: flex;
        justify-content: space-between;
        align-items: flex-end;
        gap: 16px;
        flex-wrap: wrap;
        margin-bottom: 20px;
    }
    .db-header h1 { font-size: 22px; margin: 0 0 4px; }
    .db-header p { margin: 0; color: var(--muted); font-size: 13px; }
    .db-header-actions { display: flex; align-items: center; gap: 12px; }

    .conn-status {
        display: inline-flex;
        align-items: center;
        gap: 7px;
        font-size: 12px;
        color: var(--muted);
    }
    .conn-dot {
        width: 8px;
        height: 8px;
        border-radius: 50%;
        background: #94a3b8;
    }
    .conn-status.is-live .conn-dot { background: #16a34a; }
    .conn-status.is-down .conn-dot { background: #dc2626; }
    .conn-status.is-down { color: #b91c1c; }

    /* Security alert (FR-DASH-04): hidden until the server pushes one */
    .db-alert {
        display: none;
        margin-bottom: 20px;
        padding: 12px 16px;
        border: 1px solid #fecaca;
        border-left: 4px solid #dc2626;
        border-radius: 6px;
        background: #fef2f2;
        color: #7f1d1d;
    }
    .db-alert-row { display: flex; justify-content: space-between; align-items: center; gap: 16px; }
    .db-alert-title { font-weight: 700; font-size: 14px; }
    .db-alert-desc { font-size: 13px; margin-top: 2px; }

    /* Summary strip: one panel, five figures */
    .db-summary {
        display: grid;
        grid-template-columns: repeat(5, 1fr);
        background: #ffffff;
        border: 1px solid var(--border);
        border-radius: 8px;
        margin-bottom: 20px;
    }
    .db-figure { padding: 16px 20px; }
    .db-figure + .db-figure { border-left: 1px solid var(--border); }
    .db-figure-label { font-size: 13px; color: var(--muted); font-weight: 500; }
    .db-figure-value {
        font-size: 28px;
        font-weight: 600;
        color: var(--text);
        font-variant-numeric: tabular-nums;
        line-height: 1.2;
        margin: 6px 0 4px;
    }
    .db-figure-value.is-warn { color: #b45309; }
    .db-figure-value.is-bad { color: #b91c1c; }
    .db-figure-note { font-size: 12px; color: var(--muted); }
    .db-progress {
        height: 4px;
        background: #e5e7eb;
        border-radius: 2px;
        margin-top: 8px;
        overflow: hidden;
    }
    .db-progress > span { display: block; height: 100%; background: #1d4ed8; }

    /* Layout */
    .db-grid {
        display: grid;
        grid-template-columns: minmax(0, 2fr) minmax(0, 1fr);
        gap: 20px;
        align-items: start;
    }
    .db-panel {
        background: #ffffff;
        border: 1px solid var(--border);
        border-radius: 8px;
        margin-bottom: 20px;
    }
    .db-panel-head {
        display: flex;
        justify-content: space-between;
        align-items: center;
        gap: 12px;
        padding: 14px 18px;
        border-bottom: 1px solid var(--border);
    }
    .db-panel-head h2 { font-size: 15px; margin: 0; }
    .db-panel-head .count { color: var(--muted); font-weight: 400; margin-left: 4px; }
    .db-panel-head a { font-size: 13px; }

    .db-table { width: 100%; border-collapse: collapse; }
    .db-table th {
        text-align: left;
        font-size: 12px;
        font-weight: 600;
        color: var(--muted);
        padding: 9px 18px;
        background: #f8f9fb;
        border-bottom: 1px solid var(--border);
        white-space: nowrap;
    }
    .db-table td {
        padding: 11px 18px;
        border-bottom: 1px solid #eef0f3;
        font-size: 13px;
        color: var(--text-secondary);
        vertical-align: middle;
    }
    .db-table tr:last-child td { border-bottom: none; }
    .db-person-name { font-weight: 600; color: var(--text); }
    .db-person-code { font-size: 12px; color: var(--muted); }
    .db-time { font-variant-numeric: tabular-nums; color: var(--text); }

    .db-empty { padding: 32px 18px; text-align: center; color: var(--muted); font-size: 13px; }
    .db-empty strong { display: block; color: var(--text); font-size: 14px; margin-bottom: 4px; }

    /* Plain status text with a small colored marker */
    .status-text { display: inline-flex; align-items: center; gap: 6px; font-size: 13px; font-weight: 500; }
    .status-text::before { content: ""; width: 7px; height: 7px; border-radius: 50%; background: currentColor; }
    .status-ok { color: #15803d; }
    .status-warn { color: #b45309; }
    .status-bad { color: #b91c1c; }
    .status-info { color: #1d4ed8; }
    .status-neutral { color: #64748b; }

    /* Recent scans */
    .db-feed { max-height: 640px; overflow-y: auto; }
    .db-feed-item {
        display: grid;
        grid-template-columns: 66px minmax(0, 1fr) auto;
        gap: 10px;
        padding: 11px 18px;
        border-bottom: 1px solid #eef0f3;
        font-size: 13px;
    }
    .db-feed-item:last-child { border-bottom: none; }
    .db-feed-time { color: var(--muted); font-variant-numeric: tabular-nums; }
    .db-feed-name { font-weight: 600; color: var(--text); }
    .db-feed-detail { font-size: 12px; color: var(--muted); margin-top: 2px; }
    .db-feed-result { font-size: 12px; font-weight: 600; white-space: nowrap; }

    @media (max-width: 1200px) {
        .db-summary { grid-template-columns: repeat(3, 1fr); }
        .db-figure:nth-child(4) { border-left: none; }
        .db-figure:nth-child(n+4) { border-top: 1px solid var(--border); }
    }
    @media (max-width: 1024px) {
        .db-grid { grid-template-columns: 1fr; }
    }
    @media (max-width: 640px) {
        .db-summary { grid-template-columns: 1fr 1fr; }
        .db-figure { border-left: none !important; border-top: 1px solid var(--border); }
        .db-figure:nth-child(-n+2) { border-top: none; }
    }
</style>

<c:set var="onlineCount" value="0"/>
<c:forEach var="d" items="${devices}">
    <c:if test="${d.online}"><c:set var="onlineCount" value="${onlineCount + 1}"/></c:if>
</c:forEach>

<div class="db-header">
    <div>
        <h1>Today's attendance</h1>
        <p>Who is at work, who is late or absent, and the latest fingerprint scans. Figures update automatically.</p>
    </div>
    <div class="db-header-actions">
        <span class="conn-status" id="liveStatusBadge">
            <span class="conn-dot" id="liveDot"></span>
            <span id="liveStatusText">Connecting&hellip;</span>
        </span>
        <a href="${ctx}/admin/attendance" class="btn btn-secondary">Attendance records</a>
    </div>
</div>

<div class="db-alert" id="secAlertBox" role="alert">
    <div class="db-alert-row">
        <div>
            <div class="db-alert-title" id="secAlertTitle">Security alert</div>
            <div class="db-alert-desc" id="secAlertDesc">Repeated unrecognized fingerprint scans.</div>
        </div>
        <button type="button" class="btn btn-secondary btn-sm" onclick="dismissSecAlert()">Dismiss</button>
    </div>
</div>

<section class="db-summary" aria-label="Today's figures">
    <div class="db-figure">
        <div class="db-figure-label">Present</div>
        <div class="db-figure-value" id="kpiPresent">${presentCount}</div>
        <div class="db-figure-note">of <span id="kpiTotal">${totalEmployees}</span> active employees</div>
        <div class="db-progress"><span id="kpiPresentBar" style="width: ${totalEmployees > 0 ? presentCount * 100 / totalEmployees : 0}%;"></span></div>
    </div>
    <div class="db-figure">
        <div class="db-figure-label">Late</div>
        <div class="db-figure-value ${lateCount > 0 ? 'is-warn' : ''}" id="kpiLate">${lateCount}</div>
        <div class="db-figure-note">checked in after the grace period</div>
    </div>
    <div class="db-figure">
        <div class="db-figure-label">Absent</div>
        <div class="db-figure-value ${absentCount > 0 ? 'is-bad' : ''}" id="kpiAbsent">${absentCount}</div>
        <div class="db-figure-note">scheduled, no check-in</div>
    </div>
    <div class="db-figure">
        <div class="db-figure-label">Overtime</div>
        <div class="db-figure-value" id="kpiOvertime">${overtimeCount}</div>
        <div class="db-figure-note">worked past the end of their shift</div>
    </div>
    <div class="db-figure">
        <div class="db-figure-label">Terminals online</div>
        <div class="db-figure-value ${onlineCount < devices.size() ? 'is-bad' : ''}" id="kpiDevices">${onlineCount} / ${devices.size()}</div>
        <div class="db-figure-note">fingerprint devices reporting</div>
    </div>
</section>

<div class="db-grid">
    <div>
        <!-- Currently checked in (FR-DASH-01) -->
        <section class="db-panel">
            <div class="db-panel-head">
                <h2>At work now <span class="count" id="workingBadge">(${currentlyWorking.size()})</span></h2>
                <a href="${ctx}/admin/attendance">All attendance &rarr;</a>
            </div>
            <table class="db-table" id="workingTable">
                <thead>
                    <tr>
                        <th>Employee</th>
                        <th>Department</th>
                        <th>Shift</th>
                        <th>Checked in</th>
                        <th>Status</th>
                    </tr>
                </thead>
                <tbody id="workingTbody">
                    <tr id="emptyWorkingRow" style="${empty currentlyWorking ? '' : 'display:none;'}">
                        <td colspan="5" class="db-empty">
                            <strong>Nobody is checked in right now</strong>
                            Check-ins appear here as soon as an employee scans at a terminal.
                            You can try it with the <a href="${ctx}/dev/simulator">device simulator</a>.
                        </td>
                    </tr>
                    <c:forEach var="a" items="${currentlyWorking}">
                        <tr data-code="<c:out value='${a.employeeCode}'/>">
                            <td>
                                <div class="db-person-name"><c:out value="${a.employeeName}"/></div>
                                <div class="db-person-code"><c:out value="${a.employeeCode}"/></div>
                            </td>
                            <td><c:out value="${a.department}"/></td>
                            <td><c:out value="${a.shiftName}"/></td>
                            <td class="db-time">${a.formattedCheckIn}</td>
                            <td>
                                <span class="status-text ${a.status == 'LATE' ? 'status-warn' : 'status-ok'}"><c:out value="${a.statusLabel}"/></span>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </section>

        <!-- Terminals (FR-DASH-05) -->
        <section class="db-panel">
            <div class="db-panel-head">
                <h2>Fingerprint terminals <span class="count">(${devices.size()})</span></h2>
                <a href="${ctx}/dev/simulator">Test a terminal &rarr;</a>
            </div>
            <table class="db-table">
                <thead>
                    <tr>
                        <th>Terminal</th>
                        <th>Location</th>
                        <th>Status</th>
                        <th>Last heartbeat</th>
                    </tr>
                </thead>
                <tbody>
                    <c:if test="${empty devices}">
                        <tr><td colspan="4" class="db-empty">No terminals registered.</td></tr>
                    </c:if>
                    <c:forEach var="d" items="${devices}">
                        <tr>
                            <td class="db-person-name"><c:out value="${d.name}"/></td>
                            <td><c:out value="${d.location}"/></td>
                            <td>
                                <span class="status-text ${d.online ? 'status-ok' : 'status-bad'}" id="devBadge-${d.id}">${d.online ? 'Online' : 'Offline'}</span>
                            </td>
                            <td class="db-time">${d.formattedHeartbeat}</td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </section>
    </div>

    <!-- Recent scans (FR-DASH-03) -->
    <section class="db-panel">
        <div class="db-panel-head">
            <h2>Recent scans</h2>
        </div>
        <div class="db-feed" id="feedList">
            <div class="db-empty" id="emptyFeedMsg" style="${empty recentLogs ? '' : 'display:none;'}">No scans recorded yet today.</div>
            <c:forEach var="log" items="${recentLogs}">
                <div class="db-feed-item">
                    <div class="db-feed-time">${log.formattedTime}</div>
                    <div>
                        <div class="db-feed-name"><c:out value="${not empty log.employeeName ? log.employeeName : 'Unrecognized fingerprint'}"/></div>
                        <div class="db-feed-detail">
                            <c:out value="${log.deviceName != null ? log.deviceName : 'Terminal'}"/><c:if test="${log.confidenceScore != null}"> &middot; match score ${log.confidenceScore}</c:if><c:if test="${not empty log.reason}"> &middot; <c:out value="${log.reason}"/></c:if>
                        </div>
                    </div>
                    <c:choose>
                        <c:when test="${log.result == 'CHECK_IN'}"><span class="db-feed-result status-ok">Check-in</span></c:when>
                        <c:when test="${log.result == 'CHECK_OUT'}"><span class="db-feed-result status-info">Check-out</span></c:when>
                        <c:when test="${log.result == 'NOT_RECOGNIZED'}"><span class="db-feed-result status-bad">Not recognized</span></c:when>
                        <c:otherwise><span class="db-feed-result status-neutral"><c:out value="${log.result}"/></span></c:otherwise>
                    </c:choose>
                </div>
            </c:forEach>
        </div>
    </section>
</div>

<script>
    const contextPath = '${ctx}';
    let alertHideTimer = null;

    const RESULT_LABELS = {
        CHECK_IN: ['Check-in', 'status-ok'],
        CHECK_OUT: ['Check-out', 'status-info'],
        NOT_RECOGNIZED: ['Not recognized', 'status-bad']
    };

    function el(tag, className, text) {
        const node = document.createElement(tag);
        if (className) node.className = className;
        if (text !== undefined && text !== null) node.textContent = text;
        return node;
    }

    function setConnection(state, label) {
        const badge = document.getElementById('liveStatusBadge');
        badge.classList.remove('is-live', 'is-down');
        if (state) badge.classList.add(state);
        document.getElementById('liveStatusText').textContent = label;
    }

    function dismissSecAlert() {
        document.getElementById('secAlertBox').style.display = 'none';
    }

    function showSecAlert(title, desc) {
        const box = document.getElementById('secAlertBox');
        document.getElementById('secAlertTitle').textContent = title;
        document.getElementById('secAlertDesc').textContent = desc;
        box.style.display = 'block';
        clearTimeout(alertHideTimer);
        alertHideTimer = setTimeout(dismissSecAlert, 12000);
    }

    function bump(id, delta) {
        const node = document.getElementById(id);
        if (node) node.textContent = (parseInt(node.textContent, 10) || 0) + delta;
    }

    function refreshPresentBar() {
        const present = parseInt(document.getElementById('kpiPresent').textContent, 10) || 0;
        const total = parseInt(document.getElementById('kpiTotal').textContent, 10) || 0;
        document.getElementById('kpiPresentBar').style.width = (total > 0 ? Math.min(100, present * 100 / total) : 0) + '%';
    }

    // Recent scans (FR-DASH-03)
    function prependFeedItem(data) {
        const list = document.getElementById('feedList');
        document.getElementById('emptyFeedMsg').style.display = 'none';

        const label = RESULT_LABELS[data.result] || [data.result || 'Scan', 'status-neutral'];
        const detail = [data.deviceName || 'Terminal'];
        if (data.confidence) detail.push('match score ' + data.confidence);
        if (data.message) detail.push(data.message);

        const item = el('div', 'db-feed-item');
        item.appendChild(el('div', 'db-feed-time', data.time || ''));
        const body = el('div');
        body.appendChild(el('div', 'db-feed-name', data.employeeName || 'Unrecognized fingerprint'));
        body.appendChild(el('div', 'db-feed-detail', detail.join(' · ')));
        item.appendChild(body);
        item.appendChild(el('span', 'db-feed-result ' + label[1], label[0]));

        list.insertBefore(item, list.firstChild);
        const items = list.querySelectorAll('.db-feed-item');
        if (items.length > 30) items[items.length - 1].remove();
    }

    // At work now (FR-DASH-01). Rows are keyed by employee code, which every scan event carries.
    function updateWorkingTable(data) {
        const code = data.employeeCode;
        if (!code || code === '--') return;
        const tbody = document.getElementById('workingTbody');
        const existing = Array.prototype.find.call(tbody.querySelectorAll('tr[data-code]'), function (tr) {
            return tr.getAttribute('data-code') === code;
        });
        if (existing) existing.remove();

        if (data.result === 'CHECK_IN') {
            const tr = el('tr');
            tr.setAttribute('data-code', code);
            const who = el('td');
            who.appendChild(el('div', 'db-person-name', data.employeeName || ''));
            who.appendChild(el('div', 'db-person-code', code));
            tr.appendChild(who);
            tr.appendChild(el('td', '', data.department || ''));
            tr.appendChild(el('td', '', 'Current shift'));
            tr.appendChild(el('td', 'db-time', data.time || ''));
            const status = el('td');
            status.appendChild(el('span', 'status-text ' + (data.status === 'LATE' ? 'status-warn' : 'status-ok'), data.statusLabel || 'On time'));
            tr.appendChild(status);
            tbody.insertBefore(tr, tbody.querySelector('tr[data-code]'));
        }

        const count = tbody.querySelectorAll('tr[data-code]').length;
        document.getElementById('workingBadge').textContent = '(' + count + ')';
        document.getElementById('emptyWorkingRow').style.display = count === 0 ? '' : 'none';
    }

    // Server-Sent Events (FR-DASH-06)
    function initDashboardSse() {
        const es = new EventSource(contextPath + '/admin/dashboard/stream');

        es.addEventListener('open', function () { setConnection('is-live', 'Live updates on'); });

        es.addEventListener('scan_event', function (e) {
            try {
                const data = JSON.parse(e.data);
                prependFeedItem(data);
                if (data.result === 'CHECK_IN') {
                    bump('kpiPresent', 1);
                    if (data.status === 'LATE') bump('kpiLate', 1);
                    refreshPresentBar();
                } else if (data.result === 'CHECK_OUT' && data.status === 'OVERTIME') {
                    bump('kpiOvertime', 1);
                }
                if (data.result === 'CHECK_IN' || data.result === 'CHECK_OUT') updateWorkingTable(data);
            } catch (err) {
                console.error('Scan event parse error', err);
            }
        });

        es.addEventListener('security_alert', function (e) {
            try {
                const data = JSON.parse(e.data);
                showSecAlert('Security alert', data.message || 'Repeated unrecognized fingerprint scans.');
            } catch (err) {
                console.error('Security alert parse error', err);
            }
        });

        es.addEventListener('device_status', function (e) {
            try {
                const data = JSON.parse(e.data);
                const badge = document.getElementById('devBadge-' + data.deviceId);
                if (badge) {
                    badge.className = 'status-text ' + (data.online ? 'status-ok' : 'status-bad');
                    badge.textContent = data.online ? 'Online' : 'Offline';
                }
            } catch (err) {
                console.error('Device status parse error', err);
            }
        });

        es.onerror = function () { setConnection('is-down', 'Reconnecting…'); };
    }

    // Polling fallback every 5 s keeps the figures right even if the stream drops (FR-DASH-06)
    setInterval(async function () {
        try {
            const res = await fetch(contextPath + '/admin/dashboard?action=poll', { headers: { 'Accept': 'application/json' } });
            if (!res.ok) return;
            const data = await res.json();
            if (!data.stats) return;
            document.getElementById('kpiPresent').textContent = data.stats.present;
            document.getElementById('kpiLate').textContent = data.stats.late;
            document.getElementById('kpiAbsent').textContent = data.stats.absent;
            document.getElementById('kpiOvertime').textContent = data.stats.overtime;
            refreshPresentBar();
        } catch (err) {}
    }, 5000);

    window.addEventListener('DOMContentLoaded', initDashboardSse);
</script>

<%@include file="/WEB-INF/views/common/footer.jspf"%>
