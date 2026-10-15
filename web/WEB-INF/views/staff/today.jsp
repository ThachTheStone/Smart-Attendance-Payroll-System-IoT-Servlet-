<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="pageTitle" value="Hôm nay"/>
<c:set var="activeNav" value="today"/>
<%@ include file="../common/header.jspf" %>

<style>
    /* Staff Portal Today Styling */
    .today-hero {
        background: linear-gradient(135deg, #1e293b, #0f172a);
        color: white;
        border-radius: var(--radius);
        padding: 28px 32px;
        margin-bottom: 24px;
        box-shadow: 0 10px 25px rgba(0,0,0,0.1);
        display: flex;
        justify-content: space-between;
        align-items: center;
        flex-wrap: wrap;
        gap: 20px;
    }

    .today-hero-left h1 {
        font-size: 26px;
        color: #ffffff;
        margin: 0 0 6px 0;
    }

    .today-live-clock-card {
        background: rgba(255, 255, 255, 0.08);
        border: 1px solid rgba(255, 255, 255, 0.15);
        border-radius: 14px;
        padding: 16px 24px;
        text-align: center;
        min-width: 260px;
    }

    .live-timer-val {
        font-family: ui-monospace, "Cascadia Code", monospace;
        font-size: 38px;
        font-weight: 800;
        color: #38bdf8;
        letter-spacing: -1px;
        line-height: 1.1;
    }

    .live-timer-label {
        font-size: 12px;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        color: #94a3b8;
        margin-top: 4px;
    }

    /* Shift Details & Timeline Card (FR-STAFF-02) */
    .shift-card {
        background: var(--surface);
        border: 1px solid var(--line);
        border-radius: var(--radius);
        padding: 24px;
        margin-bottom: 24px;
    }

    .shift-grid {
        display: grid;
        grid-template-columns: repeat(4, 1fr);
        gap: 16px;
        margin-top: 16px;
        margin-bottom: 24px;
    }

    .shift-metric {
        background: #f8fafc;
        border: 1px solid var(--line);
        border-radius: 8px;
        padding: 14px 16px;
    }
    .shift-metric-label { font-size: 12px; color: var(--muted); text-transform: uppercase; margin-bottom: 4px; }
    .shift-metric-val { font-size: 16px; font-weight: 700; color: var(--text); }

    /* Timeline Stepper (FR-STAFF-02) */
    .timeline-wrap {
        display: flex;
        align-items: center;
        justify-content: space-between;
        position: relative;
        padding: 20px 10px 10px;
        margin-top: 10px;
    }
    .timeline-line {
        position: absolute;
        top: 36px;
        left: 30px;
        right: 30px;
        height: 4px;
        background: #e2e8f0;
        z-index: 1;
    }
    .timeline-progress {
        position: absolute;
        top: 36px;
        left: 30px;
        height: 4px;
        background: var(--primary);
        z-index: 2;
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
        background: #fff;
        border: 3px solid #cbd5e1;
        display: grid;
        place-items: center;
        font-weight: 700;
        font-size: 13px;
        color: var(--muted);
        margin-bottom: 8px;
    }
    .timeline-step.active .timeline-node {
        border-color: var(--primary);
        color: var(--primary);
        background: #eff6ff;
        box-shadow: 0 0 10px rgba(59, 130, 246, 0.4);
    }
    .timeline-step.completed .timeline-node {
        border-color: #10b981;
        background: #10b981;
        color: white;
    }
    .timeline-step-title { font-size: 13px; font-weight: 700; color: var(--text); }
    .timeline-step-time { font-size: 12px; color: var(--muted); font-family: ui-monospace, monospace; margin-top: 2px; }

    /* 4 Monthly Summary Cards (FR-STAFF-03) */
    .month-kpi-grid {
        display: grid;
        grid-template-columns: repeat(4, 1fr);
        gap: 16px;
        margin-bottom: 24px;
    }
    .month-kpi-card {
        background: var(--surface);
        border: 1px solid var(--line);
        border-radius: var(--radius);
        padding: 18px 20px;
    }
    .month-kpi-val {
        font-size: 26px;
        font-weight: 800;
        margin-top: 6px;
        color: var(--text);
    }

    /* Filter Form */
    .filter-bar {
        display: flex;
        gap: 12px;
        align-items: center;
        margin-bottom: 16px;
        flex-wrap: wrap;
    }
    .filter-bar input[type="date"] {
        padding: 7px 12px;
        border-radius: 6px;
        border: 1px solid var(--line);
        font: inherit;
        font-size: 13px;
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
        <h1>Xin chào, <c:out value="${emp.fullName}"/> 👋</h1>
        <p style="color:#94a3b8; margin:0; font-size:14px;">
            Mã NV: <strong>${emp.code}</strong> · Phòng ban: <strong><c:out value="${emp.department}"/></strong> · Chức vụ: <strong><c:out value="${emp.position}"/></strong>
        </p>
        <div style="margin-top: 14px; display:flex; gap:10px; align-items:center;">
            <c:choose>
                <c:when test="${not empty todayAtt && not empty todayAtt.checkIn && empty todayAtt.checkOut}">
                    <span class="role-badge" style="background:#065f46; color:#6ee7b7; padding:5px 12px; font-size:13px;">
                        ● Đang làm việc (${todayAtt.statusLabel})
                    </span>
                    <span style="font-size:13px; color:#cbd5e1;">Bắt đầu check-in lúc: <strong>${todayAtt.formattedCheckIn}</strong></span>
                </c:when>
                <c:when test="${not empty todayAtt && not empty todayAtt.checkOut}">
                    <span class="role-badge" style="background:#1e3a8a; color:#93c5fd; padding:5px 12px; font-size:13px;">
                        ✓ Đã kết thúc ca (${todayAtt.statusLabel})
                    </span>
                    <span style="font-size:13px; color:#cbd5e1;">Tổng thời gian: <strong>${todayAtt.workedMinutes / 60}h ${todayAtt.workedMinutes % 60}m</strong></span>
                </c:when>
                <c:otherwise>
                    <span class="role-badge" style="background:#475569; color:#e2e8f0; padding:5px 12px; font-size:13px;">
                        ○ Chưa check-in hôm nay
                    </span>
                    <span style="font-size:13px; color:#cbd5e1;">Hãy đặt ngón tay lên máy chấm công để bắt đầu ca làm.</span>
                </c:otherwise>
            </c:choose>
        </div>
    </div>

    <!-- Live Timer Card (FR-STAFF-01) -->
    <div class="today-live-clock-card">
        <div class="live-timer-val" id="liveWorkClock">--:--:--</div>
        <div class="live-timer-label" id="liveWorkLabel">Thời gian làm việc hôm nay</div>
    </div>
</div>

<!-- 2. Today's Shift & Timeline (FR-STAFF-01, FR-STAFF-02) -->
<div class="shift-card">
    <div style="display:flex; justify-content:space-between; align-items:center;">
        <div>
            <h2 style="font-size:17px; margin:0;">Ca làm việc hôm nay</h2>
            <p class="muted small" style="margin:2px 0 0;"><fmt:formatDate value="<%= new java.util.Date() %>" pattern="EEEE, dd/MM/yyyy" /></p>
        </div>
        <c:if test="${not empty todayShift}">
            <span class="role-badge role-STAFF" style="font-size:13px;"><c:out value="${todayShift.name}"/></span>
        </c:if>
    </div>

    <c:choose>
        <c:when test="${not empty todayShift}">
            <div class="shift-grid">
                <div class="shift-metric">
                    <div class="shift-metric-label">Giờ bắt đầu ca</div>
                    <div class="shift-metric-val mono">${todayShift.startTime}</div>
                </div>
                <div class="shift-metric">
                    <div class="shift-metric-label">Giờ kết thúc ca</div>
                    <div class="shift-metric-val mono">${todayShift.endTime}</div>
                </div>
                <div class="shift-metric">
                    <div class="shift-metric-label">Nghỉ giữa ca</div>
                    <div class="shift-metric-val">${todayShift.breakMinutes} phút</div>
                </div>
                <div class="shift-metric">
                    <div class="shift-metric-label">Thời lượng chuẩn</div>
                    <div class="shift-metric-val">${todayShift.durationMinutes / 60} giờ</div>
                </div>
            </div>

            <!-- Progress Timeline (FR-STAFF-02) -->
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
                    <div class="timeline-step-title">Nghỉ giữa ca</div>
                    <div class="timeline-step-time">${todayShift.breakMinutes}m giải lao</div>
                </div>

                <!-- Step 3: Shift End / Checkout -->
                <div class="timeline-step ${not empty todayAtt && not empty todayAtt.checkOut ? 'completed' : ''}">
                    <div class="timeline-node">3</div>
                    <div class="timeline-step-title">Tan ca</div>
                    <div class="timeline-step-time">${not empty todayAtt && not empty todayAtt.checkOut ? todayAtt.formattedCheckOut : todayShift.endTime}</div>
                </div>

                <!-- Step 4: Overtime -->
                <div class="timeline-step ${not empty todayAtt && todayAtt.status == 'OVERTIME' ? 'completed' : ''}">
                    <div class="timeline-node">4</div>
                    <div class="timeline-step-title">Tăng ca</div>
                    <div class="timeline-step-time">${todayAtt.status == 'OVERTIME' ? 'Đã ghi nhận OT' : 'Tùy chọn'}</div>
                </div>
            </div>
        </c:when>
        <c:otherwise>
            <div class="empty" style="padding:24px 0;">Hôm nay bạn không có lịch ca làm việc được phân công.</div>
        </c:otherwise>
    </c:choose>
</div>

<!-- 3. Monthly Summary Cards (FR-STAFF-03) -->
<h2 style="font-size:18px; margin:0 0 14px 0;">Tổng hợp tháng này (Tháng <%= java.time.LocalDate.now().getMonthValue() %>)</h2>
<div class="month-kpi-grid">
    <div class="month-kpi-card">
        <div class="muted small font-bold" style="text-transform:uppercase;">Tổng giờ làm việc</div>
        <div class="month-kpi-val" style="color:#2563eb;">${totalHoursMonth} <span style="font-size:15px; font-weight:500;">giờ</span></div>
        <div class="muted small" style="margin-top:4px;">Chuẩn: 208 giờ/tháng</div>
    </div>
    <div class="month-kpi-card">
        <div class="muted small font-bold" style="text-transform:uppercase;">Số lần đi muộn</div>
        <div class="month-kpi-val" style="color:#d97706;">${lateCountMonth} <span style="font-size:15px; font-weight:500;">lần</span></div>
        <div class="muted small" style="margin-top:4px;">${onTimeCountMonth} ca đúng giờ</div>
    </div>
    <div class="month-kpi-card">
        <div class="muted small font-bold" style="text-transform:uppercase;">Ca tăng ca (OT)</div>
        <div class="month-kpi-val" style="color:#7c3aed;">${overtimeCountMonth} <span style="font-size:15px; font-weight:500;">ca</span></div>
        <div class="muted small" style="margin-top:4px;">Hệ số 150% - 300%</div>
    </div>
    <div class="month-kpi-card">
        <div class="muted small font-bold" style="text-transform:uppercase;">Lương ước tính tích lũy</div>
        <div class="month-kpi-val" style="color:#059669;"><fmt:formatNumber value="${estimatedSalary}" pattern="#,##0"/> <span style="font-size:14px; font-weight:500;">VND</span></div>
        <div class="muted small" style="margin-top:4px;">Chưa trừ bảo hiểm &amp; phạt</div>
    </div>
</div>

<!-- 4. Attendance History Table with Filter (FR-STAFF-04) -->
<div class="card" style="margin-top:24px;">
    <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:16px; flex-wrap:wrap; gap:12px;">
        <h2 style="font-size:17px; margin:0;">Lịch sử chấm công</h2>

        <form method="get" action="${pageContext.request.contextPath}/staff/today" class="filter-bar" style="margin:0;">
            <label style="flex-direction:row; align-items:center; gap:6px; font-size:13px; margin:0;">
                Từ: <input type="date" name="from" value="${fromDate}">
            </label>
            <label style="flex-direction:row; align-items:center; gap:6px; font-size:13px; margin:0;">
                Đến: <input type="date" name="to" value="${toDate}">
            </label>
            <button type="submit" class="btn btn-secondary btn-sm">Lọc</button>
        </form>
    </div>

    <div class="table-wrap">
        <table class="table">
            <thead>
                <tr>
                    <th>Ngày</th>
                    <th>Ca làm việc</th>
                    <th>Giờ check-in</th>
                    <th>Giờ check-out</th>
                    <th>Thời gian làm</th>
                    <th>Trạng thái</th>
                </tr>
            </thead>
            <tbody>
                <c:choose>
                    <c:when test="${empty historyList}">
                        <tr>
                            <td colspan="6" class="empty">Không tìm thấy bản ghi chấm công nào trong khoảng thời gian này.</td>
                        </tr>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="h" items="${historyList}">
                            <tr>
                                <td class="mono font-bold">${h.workDate}</td>
                                <td><c:out value="${h.shiftName}"/></td>
                                <td class="mono">${not empty h.checkIn ? h.formattedCheckIn : '--'}</td>
                                <td class="mono">${not empty h.checkOut ? h.formattedCheckOut : '--'}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${h.workedMinutes > 0}">
                                            <strong>${h.workedMinutes / 60}h ${h.workedMinutes % 60}m</strong>
                                        </c:when>
                                        <c:otherwise>--</c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <span class="role-badge ${h.status == 'ON_TIME' ? 'role-STAFF' : h.status == 'LATE' ? 'role-KIOSK' : h.status == 'OVERTIME' ? 'role-ADMIN' : ''}">
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
            // Checked in and currently working
            const checkInEpoch = new Date("${todayAtt.checkIn}").getTime();

            function tickWorkClock() {
                const now = Date.now();
                const diffMs = Math.max(0, now - checkInEpoch);
                const totalSec = Math.floor(diffMs / 1000);
                const hrs = Math.floor(totalSec / 3600);
                const mins = Math.floor((totalSec % 3600) / 60);
                const secs = totalSec % 60;

                const pad = (n) => String(n).padStart(2, '0');
                document.getElementById('liveWorkClock').textContent = 
                    pad(hrs) + ':' + pad(mins) + ':' + pad(secs);
            }
            tickWorkClock();
            setInterval(tickWorkClock, 1000);

            // Progress bar
            document.getElementById('timelineBar').style.width = '55%';
        </c:when>
        <c:when test="${not empty todayAtt && not empty todayAtt.checkOut}">
            // Checked out
            const totalM = ${todayAtt.workedMinutes};
            const h = Math.floor(totalM / 60);
            const m = totalM % 60;
            document.getElementById('liveWorkClock').textContent = h + 'h ' + m + 'm';
            document.getElementById('liveWorkLabel').textContent = 'Tổng thời gian đã làm hôm nay';
            document.getElementById('timelineBar').style.width = '100%';
        </c:when>
        <c:otherwise>
            // Not checked in yet
            document.getElementById('liveWorkClock').textContent = '00:00:00';
            document.getElementById('liveWorkLabel').textContent = 'Chưa bắt đầu ca';
            document.getElementById('timelineBar').style.width = '0%';
        </c:otherwise>
    </c:choose>
</script>

<%@ include file="../common/footer.jspf" %>
