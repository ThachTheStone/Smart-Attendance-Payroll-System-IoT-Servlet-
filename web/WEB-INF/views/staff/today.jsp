<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="pageTitle" value="Today's Attendance"/>
<c:set var="activeNav" value="today"/>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<%@ include file="../common/header.jspf" %>

<style>
    /* ================= Staff Today Dashboard (Swiss Light SaaS) ================= */
    .today-hero {
        background: #ffffff;
        color: #0f172a;
        border: 1px solid var(--border);
        border-radius: var(--radius-lg);
        padding: 24px 28px;
        margin-bottom: 24px;
        display: flex;
        justify-content: space-between;
        align-items: center;
        flex-wrap: wrap;
        gap: 20px;
        box-shadow: var(--shadow-sm);
    }
    .today-hero-left h1 {
        font-size: 22px;
        font-weight: 700;
        letter-spacing: -0.02em;
        color: #0f172a;
        margin: 0 0 6px 0;
    }
    .emp-meta-pills {
        display: flex;
        align-items: center;
        gap: 8px;
        flex-wrap: wrap;
        margin-top: 6px;
    }
    .emp-pill {
        background: #f1f5f9;
        border: 1px solid #e2e8f0;
        padding: 3px 10px;
        border-radius: 6px;
        font-size: 12px;
        color: #334155;
    }

    /* Live Clock Widget */
    .today-live-clock-card {
        background: #f8fafc;
        border: 1px solid #e2e8f0;
        border-radius: 12px;
        padding: 16px 24px;
        text-align: center;
        min-width: 220px;
    }
    .live-timer-val {
        font-family: 'JetBrains Mono', monospace;
        font-size: 32px;
        font-weight: 700;
        color: #1d4ed8;
        letter-spacing: -0.5px;
        line-height: 1.1;
    }
    .live-timer-label {
        font-size: 11px;
        font-weight: 600;
        text-transform: uppercase;
        letter-spacing: 0.05em;
        color: #64748b;
        margin-top: 4px;
    }

    /* Shift Details & Stepper Card */
    .shift-card {
        background: #ffffff !important;
        border: 1px solid var(--border) !important;
        border-radius: var(--radius-lg);
        padding: 24px 28px;
        margin-bottom: 24px;
        color: #0f172a;
        box-shadow: var(--shadow-xs);
    }
    .shift-grid {
        display: grid;
        grid-template-columns: repeat(4, 1fr);
        gap: 16px;
        margin-top: 18px;
        margin-bottom: 24px;
    }
    .shift-metric {
        background: #f8fafc !important;
        border: 1px solid #e2e8f0;
        border-radius: 8px;
        padding: 14px 18px;
    }
    .shift-metric-label {
        font-size: 11px;
        font-weight: 600;
        color: #64748b;
        text-transform: uppercase;
        letter-spacing: 0.04em;
        margin-bottom: 4px;
    }
    .shift-metric-val {
        font-size: 16px;
        font-weight: 700;
        color: #0f172a;
    }

    /* Progress Stepper Timeline */
    .timeline-wrap {
        display: flex;
        align-items: center;
        justify-content: space-between;
        position: relative;
        padding: 10px 20px;
        margin-top: 16px;
    }
    .timeline-line {
        position: absolute;
        top: 24px;
        left: 45px;
        right: 45px;
        height: 3px;
        background: #e2e8f0;
        z-index: 1;
        border-radius: 2px;
    }
    .timeline-progress {
        position: absolute;
        top: 24px;
        left: 45px;
        height: 3px;
        background: #1d4ed8;
        z-index: 2;
        border-radius: 2px;
        transition: width 0.3s ease;
    }
    .timeline-step {
        position: relative;
        z-index: 3;
        display: flex;
        flex-direction: column;
        align-items: center;
        text-align: center;
    }
    .timeline-node {
        width: 32px;
        height: 32px;
        border-radius: 50%;
        background: #ffffff;
        border: 2px solid #cbd5e1;
        display: grid;
        place-items: center;
        font-weight: 700;
        font-size: 12px;
        color: #64748b;
        margin-bottom: 8px;
    }
    .timeline-step.active .timeline-node {
        border-color: #1d4ed8;
        color: #1d4ed8;
        background: #eff6ff;
    }
    .timeline-step.completed .timeline-node {
        border-color: #059669;
        background: #059669;
        color: #ffffff;
    }
    .timeline-step-title {
        font-size: 13px;
        font-weight: 600;
        color: #0f172a;
    }
    .timeline-step-time {
        font-size: 11px;
        color: #64748b;
        font-family: 'JetBrains Mono', monospace;
        margin-top: 2px;
    }

    /* Monthly KPI Cards */
    .month-kpi-grid {
        display: grid;
        grid-template-columns: repeat(4, 1fr);
        gap: 16px;
        margin-bottom: 24px;
    }
    .month-kpi-card {
        background: #ffffff !important;
        border: 1px solid var(--border);
        border-radius: var(--radius);
        padding: 18px 20px;
        box-shadow: var(--shadow-xs);
    }
    .month-kpi-val {
        font-size: 24px;
        font-weight: 700;
        margin-top: 6px;
        color: #0f172a;
        font-family: 'JetBrains Mono', monospace;
    }

    /* History Table Card */
    .history-card {
        background: #ffffff !important;
        border: 1px solid var(--border) !important;
        border-radius: var(--radius-lg);
        overflow: hidden;
        margin-bottom: 30px;
        box-shadow: var(--shadow-xs);
    }
    .history-card-header {
        padding: 16px 24px;
        border-bottom: 1px solid var(--border);
        background: #f8fafc;
        display: flex;
        justify-content: space-between;
        align-items: center;
        flex-wrap: wrap;
        gap: 14px;
        color: #0f172a;
    }
    .history-card .table {
        margin: 0;
        width: 100%;
        border-collapse: collapse;
    }
    .history-card .table th {
        background: #f8fafc;
        padding: 12px 18px;
        font-size: 11px;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 0.04em;
        color: #475569;
        border-bottom: 1px solid var(--border);
    }
    .history-card .table td {
        padding: 13px 18px;
        border-bottom: 1px solid #f1f5f9;
        vertical-align: middle;
        font-size: 13px;
        color: #334155;
    }
    .history-card .table tr:hover td {
        background: #f8fafc;
    }

    @media (max-width: 860px) {
        .shift-grid { grid-template-columns: 1fr 1fr; }
        .month-kpi-grid { grid-template-columns: 1fr 1fr; }
        .timeline-wrap { flex-direction: column; gap: 20px; align-items: flex-start; }
        .timeline-line, .timeline-progress { display: none; }
    }
</style>

<!-- 1. Hero / Live Work Clock (FR-STAFF-01) -->
<div class="today-hero">
    <div class="today-hero-left">
        <h1>Welcome, <c:out value="${emp.fullName}"/></h1>
        <div class="emp-meta-pills">
            <span class="emp-pill font-bold mono">ID: ${emp.code}</span>
            <span class="emp-pill"><c:out value="${emp.department}"/></span>
            <span class="emp-pill"><c:out value="${emp.position}"/></span>
        </div>

        <div style="margin-top: 14px; display:flex; gap:10px; align-items:center; flex-wrap:wrap;">
            <c:choose>
                <c:when test="${not empty todayAtt && not empty todayAtt.checkIn && empty todayAtt.checkOut}">
                    <span class="role-badge" style="background:rgba(16, 185, 129, 0.12); color:#34d399; padding:5px 12px; font-size:12px; font-weight:600; border:1px solid rgba(16, 185, 129, 0.3);">
                        Shift in Progress (${todayAtt.statusLabel})
                    </span>
                    <span style="font-size:13px; color:#cbd5e1;">Clocked in at <strong class="mono" style="color:#ffffff;">${todayAtt.formattedCheckIn}</strong></span>
                </c:when>
                <c:when test="${not empty todayAtt && not empty todayAtt.checkOut}">
                    <span class="role-badge" style="background:rgba(37, 99, 235, 0.12); color:#60a5fa; padding:5px 12px; font-size:12px; font-weight:600; border:1px solid rgba(37, 99, 235, 0.3);">
                        Shift Completed (${todayAtt.statusLabel})
                    </span>
                    <span style="font-size:13px; color:#cbd5e1;">Logged: <strong class="mono" style="color:#ffffff;">${todayAtt.workedMinutes / 60}h ${todayAtt.workedMinutes % 60}m</strong></span>
                </c:when>
                <c:otherwise>
                    <span class="role-badge" style="background:rgba(148, 163, 184, 0.12); color:#cbd5e1; padding:5px 12px; font-size:12px; font-weight:600; border:1px solid rgba(148, 163, 184, 0.2);">
                        Not Clocked In Today
                    </span>
                    <span style="font-size:13px; color:#94a3b8;">Scan your fingerprint at any kiosk terminal to start work.</span>
                </c:otherwise>
            </c:choose>
        </div>
    </div>

    <!-- Live Timer Card (FR-STAFF-01) -->
    <div class="today-live-clock-card">
        <div class="live-timer-val" id="liveWorkClock">--:--:--</div>
        <div class="live-timer-label" id="liveWorkLabel">Live Worked Duration</div>
    </div>
</div>

<!-- 2. Today's Shift & Timeline (FR-STAFF-01, FR-STAFF-02) -->
<div class="shift-card">
    <div style="display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:10px;">
        <div>
            <h2 style="font-size:16px; font-weight:700; margin:0; color:#f8fafc;">Today's Shift Roster</h2>
            <p class="muted small" style="margin:2px 0 0;"><fmt:formatDate value="<%= new java.util.Date() %>" pattern="EEEE, MMMM dd, yyyy" /></p>
        </div>
        <c:if test="${not empty todayShift}">
            <span class="role-badge" style="background:rgba(37, 99, 235, 0.12); color:#60a5fa; font-size:12px; font-weight:600; border:1px solid rgba(37, 99, 235, 0.25);">
                <c:out value="${todayShift.name}"/>
            </span>
        </c:if>
    </div>

    <c:choose>
        <c:when test="${not empty todayShift}">
            <div class="shift-grid">
                <div class="shift-metric">
                    <div class="shift-metric-label">Start Time</div>
                    <div class="shift-metric-val mono" style="color:#34d399;">${todayShift.startTime}</div>
                </div>
                <div class="shift-metric">
                    <div class="shift-metric-label">End Time</div>
                    <div class="shift-metric-val mono" style="color:#60a5fa;">${todayShift.endTime}</div>
                </div>
                <div class="shift-metric">
                    <div class="shift-metric-label">Break Duration</div>
                    <div class="shift-metric-val">${todayShift.breakMinutes} mins</div>
                </div>
                <div class="shift-metric">
                    <div class="shift-metric-label">Standard Duration</div>
                    <div class="shift-metric-val">${todayShift.durationMinutes / 60} hrs</div>
                </div>
            </div>

            <!-- Progress Stepper Timeline (FR-STAFF-02) -->
            <div class="timeline-wrap">
                <div class="timeline-line"></div>
                <div class="timeline-progress" id="timelineBar" style="width: 0%;"></div>

                <!-- Step 1: Check-in -->
                <div class="timeline-step ${not empty todayAtt && not empty todayAtt.checkIn ? 'completed' : 'active'}">
                    <div class="timeline-node">1</div>
                    <div class="timeline-step-title">Check-in</div>
                    <div class="timeline-step-time">${not empty todayAtt && not empty todayAtt.checkIn ? todayAtt.formattedCheckIn : todayShift.startTime}</div>
                </div>

                <!-- Step 2: Break -->
                <div class="timeline-step ${not empty todayAtt && not empty todayAtt.checkIn ? 'active' : ''}">
                    <div class="timeline-node">2</div>
                    <div class="timeline-step-title">Break</div>
                    <div class="timeline-step-time">${todayShift.breakMinutes}m meal break</div>
                </div>

                <!-- Step 3: Shift End / Checkout -->
                <div class="timeline-step ${not empty todayAtt && not empty todayAtt.checkOut ? 'completed' : ''}">
                    <div class="timeline-node">3</div>
                    <div class="timeline-step-title">Check-out</div>
                    <div class="timeline-step-time">${not empty todayAtt && not empty todayAtt.checkOut ? todayAtt.formattedCheckOut : todayShift.endTime}</div>
                </div>

                <!-- Step 4: Overtime -->
                <div class="timeline-step ${not empty todayAtt && todayAtt.status == 'OVERTIME' ? 'completed' : ''}">
                    <div class="timeline-node">4</div>
                    <div class="timeline-step-title">Overtime</div>
                    <div class="timeline-step-time">${todayAtt.status == 'OVERTIME' ? 'OT Recorded' : 'Optional'}</div>
                </div>
            </div>
        </c:when>
        <c:otherwise>
            <div style="text-align:center; padding:36px; color:var(--muted);">
                <div style="font-weight:600; font-size:15px; color:#f8fafc;">No shift scheduled for today</div>
                <div style="font-size:13px; margin-top:4px; color:#94a3b8;">Enjoy your day off or review your weekly schedule tab.</div>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<!-- 3. Monthly Summary Cards (FR-STAFF-03) -->
<div style="margin-bottom:14px;">
    <h2 style="font-size:16px; font-weight:700; margin:0; color:#f8fafc;">
        Monthly Accrual Summary &bull; Month <%= java.time.LocalDate.now().getMonthValue() %>
    </h2>
</div>

<div class="month-kpi-grid">
    <div class="month-kpi-card">
        <div class="muted small font-bold" style="text-transform:uppercase;">Total Worked Hours</div>
        <div class="month-kpi-val" style="color:#60a5fa;">${totalHoursMonth} <span style="font-size:13px; font-weight:500; color:var(--muted);">hrs</span></div>
        <div class="muted small" style="margin-top:4px;">Target: 208 hrs/month</div>
    </div>
    <div class="month-kpi-card">
        <div class="muted small font-bold" style="text-transform:uppercase;">Late Check-ins</div>
        <div class="month-kpi-val" style="color:#fbbf24;">${lateCountMonth} <span style="font-size:13px; font-weight:500; color:var(--muted);">times</span></div>
        <div class="muted small" style="margin-top:4px;">${onTimeCountMonth} on-time shifts</div>
    </div>
    <div class="month-kpi-card">
        <div class="muted small font-bold" style="text-transform:uppercase;">Overtime Shifts (OT)</div>
        <div class="month-kpi-val" style="color:#a78bfa;">${overtimeCountMonth} <span style="font-size:13px; font-weight:500; color:var(--muted);">shifts</span></div>
        <div class="muted small" style="margin-top:4px;">150% &ndash; 300% Multipliers</div>
    </div>
    <div class="month-kpi-card">
        <div class="muted small font-bold" style="text-transform:uppercase;">Estimated Net Accrual</div>
        <div class="month-kpi-val" style="color:#34d399;"><fmt:formatNumber value="${estimatedSalary}" pattern="#,##0"/> <span style="font-size:13px; font-weight:500; color:var(--muted);">VND</span></div>
        <div class="muted small" style="margin-top:4px;">Before monthly tax deductions</div>
    </div>
</div>

<!-- 4. Attendance History Table with Filter (FR-STAFF-04) -->
<div class="history-card">
    <div class="history-card-header">
        <h2 style="font-size:16px; font-weight:700; margin:0; color:#0f172a;">Recent Attendance Activity</h2>

        <form method="get" action="${ctx}/staff/today" style="display:flex; align-items:center; gap:8px; margin:0; flex-wrap:wrap;">
            <label style="display:flex; align-items:center; gap:6px; font-size:11px; font-weight:600; text-transform:uppercase; color:var(--text-muted); margin:0;">
                From: <input type="date" name="from" value="${fromDate}" style="padding:5px 10px; border-radius:6px; border:1px solid #cbd5e1; font-size:13px; background:#ffffff; color:#0f172a;">
            </label>
            <label style="display:flex; align-items:center; gap:6px; font-size:11px; font-weight:600; text-transform:uppercase; color:var(--text-muted); margin:0;">
                To: <input type="date" name="to" value="${toDate}" style="padding:5px 10px; border-radius:6px; border:1px solid #cbd5e1; font-size:13px; background:#ffffff; color:#0f172a;">
            </label>
            <button type="submit" class="btn btn-secondary btn-sm" style="padding:5px 12px;">Filter</button>
        </form>
    </div>

    <div class="table-wrap">
        <table class="table">
            <thead>
                <tr>
                    <th style="width: 120px;">Work Date</th>
                    <th>Shift</th>
                    <th style="width: 130px;">Check-in</th>
                    <th style="width: 130px;">Check-out</th>
                    <th style="width: 130px;">Duration</th>
                    <th style="width: 140px;">Status</th>
                </tr>
            </thead>
            <tbody>
                <c:choose>
                    <c:when test="${empty historyList}">
                        <tr>
                            <td colspan="6" class="empty" style="text-align:center; padding:36px; color:var(--muted);">
                                No attendance records recorded for this filter window.
                            </td>
                        </tr>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="h" items="${historyList}">
                            <tr>
                                <td class="mono font-bold" style="color:var(--text);">${h.workDate}</td>
                                <td><strong><c:out value="${h.shiftName}"/></strong></td>
                                <td class="mono" style="color:#34d399; font-weight:600;">${not empty h.checkIn ? h.formattedCheckIn : '--:--'}</td>
                                <td class="mono" style="color:#60a5fa; font-weight:600;">${not empty h.checkOut ? h.formattedCheckOut : '--:--'}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${h.workedMinutes > 0}">
                                            <span class="mono font-bold">${h.workedMinutes / 60}h ${h.workedMinutes % 60}m</span>
                                        </c:when>
                                        <c:otherwise><span class="muted">&ndash;&ndash;</span></c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <span class="role-badge ${h.status == 'ON_TIME' ? 'role-STAFF' : h.status == 'LATE' ? 'role-KIOSK' : h.status == 'OVERTIME' ? 'role-ADMIN' : ''}" style="font-size:12px;">
                                        <c:out value="${h.statusLabel}"/>
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

<script>
    // Live Work Counter Logic (FR-STAFF-01)
    <c:choose>
        <c:when test="${not empty todayAtt && not empty todayAtt.checkIn && empty todayAtt.checkOut}">
            const checkInEpoch = new Date("${todayAtt.checkIn}").getTime();

            function tickWorkClock() {
                const now = Date.now();
                const diffMs = Math.max(0, now - checkInEpoch);
                const totalSec = Math.floor(diffMs / 1000);
                const hrs = Math.floor(totalSec / 3600);
                const mins = Math.floor((totalSec % 3600) / 60);
                const secs = totalSec % 60;

                const pad = (n) => String(n).padStart(2, '0');
                const el = document.getElementById('liveWorkClock');
                if (el) {
                    el.textContent = pad(hrs) + ':' + pad(mins) + ':' + pad(secs);
                }
            }
            tickWorkClock();
            setInterval(tickWorkClock, 1000);

            const bar = document.getElementById('timelineBar');
            if (bar) bar.style.width = '60%';
        </c:when>
        <c:when test="${not empty todayAtt && not empty todayAtt.checkOut}">
            const totalM = ${todayAtt.workedMinutes};
            const h = Math.floor(totalM / 60);
            const m = totalM % 60;
            const elClock = document.getElementById('liveWorkClock');
            if (elClock) elClock.textContent = h + 'h ' + m + 'm';
            const elLabel = document.getElementById('liveWorkLabel');
            if (elLabel) elLabel.textContent = 'Shift Logged';
            const bar = document.getElementById('timelineBar');
            if (bar) bar.style.width = '100%';
        </c:when>
        <c:otherwise>
            const elClock = document.getElementById('liveWorkClock');
            if (elClock) elClock.textContent = '00:00:00';
            const elLabel = document.getElementById('liveWorkLabel');
            if (elLabel) elLabel.textContent = 'Shift not started';
            const bar = document.getElementById('timelineBar');
            if (bar) bar.style.width = '0%';
        </c:otherwise>
    </c:choose>
</script>

<%@ include file="../common/footer.jspf" %>
