<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="pageTitle" value="My Schedule"/>
<c:set var="activeNav" value="schedule"/>
<%@ include file="../common/header.jspf" %>

<style>
    /* ================= Staff Schedule Dashboard (Swiss Light SaaS) ================= */
    .schedule-hero {
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
        color: #0f172a;
        box-shadow: var(--shadow-sm);
    }
    .schedule-hero h1 {
        font-size: 22px;
        font-weight: 700;
        letter-spacing: -0.02em;
        margin: 0;
        display: flex;
        align-items: center;
        gap: 10px;
        color: #0f172a !important;
    }
    .schedule-hero .today-badge {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        padding: 6px 14px;
        background: #eff6ff;
        color: #1d4ed8;
        border: 1px solid #bfdbfe;
        border-radius: 999px;
        font-size: 12px;
        font-weight: 600;
        font-family: var(--font-ui); font-variant-numeric: tabular-nums;
    }

    /* Week Section Card */
    .week-section {
        background: #ffffff !important;
        border: 1px solid var(--border) !important;
        border-radius: var(--radius-lg);
        padding: 24px;
        margin-bottom: 24px;
        color: #0f172a;
        box-shadow: var(--shadow-xs);
    }
    .week-section-head {
        display: flex;
        align-items: center;
        justify-content: space-between;
        margin-bottom: 18px;
    }
    .week-section-title {
        font-size: 15px;
        font-weight: 700;
        color: #0f172a;
        margin: 0;
        display: flex;
        align-items: center;
        gap: 8px;
    }

    .schedule-week-grid {
        display: grid;
        grid-template-columns: repeat(7, 1fr);
        gap: 12px;
    }
    .day-card {
        background: #f8fafc;
        border: 1px solid #e2e8f0;
        border-radius: var(--radius);
        padding: 16px;
        display: flex;
        flex-direction: column;
        min-height: 140px;
        transition: border-color 0.15s ease, box-shadow 0.15s ease;
        position: relative;
    }
    .day-card:hover {
        border-color: #cbd5e1;
        box-shadow: var(--shadow-xs);
    }
    .day-card.is-today {
        border-color: #1d4ed8;
        background: #eff6ff;
    }
    .day-card.is-today::after {
        content: "TODAY";
        position: absolute;
        top: 8px;
        right: 8px;
        font-size: 9px;
        font-weight: 700;
        letter-spacing: 0.08em;
        padding: 2px 6px;
        border-radius: 4px;
        background: #1d4ed8;
        color: #ffffff;
    }
    .day-title {
        font-weight: 600;
        font-size: 13px;
        margin-bottom: 2px;
        color: #0f172a;
    }
    .day-date {
        color: #64748b;
        font-size: 12px;
        margin-bottom: 14px;
        font-family: var(--font-ui); font-variant-numeric: tabular-nums;
    }

    /* Shift block */
    .shift-block {
        background: #ffffff;
        color: #1d4ed8;
        border-radius: 6px;
        padding: 10px 12px;
        font-size: 12px;
        font-weight: 600;
        margin-top: auto;
        border: 1px solid #bfdbfe;
        box-shadow: 0 1px 2px rgba(0, 0, 0, 0.03);
    }
    .shift-block.overnight {
        background: #ffffff;
        color: #b45309;
        border-color: #fde68a;
    }
    .shift-time {
        font-family: var(--font-ui); font-variant-numeric: tabular-nums;
        font-size: 11px;
        margin-top: 3px;
        color: #334155;
    }
    .shift-break {
        font-size: 11px;
        color: #64748b;
        margin-top: 2px;
    }
    .off-block {
        color: #94a3b8;
        font-size: 12px;
        margin-top: auto;
        padding: 10px 0;
        font-style: italic;
        display: flex;
        align-items: center;
        gap: 6px;
    }

    @media (max-width: 1100px) {
        .schedule-week-grid { grid-template-columns: repeat(4, 1fr); }
    }
    @media (max-width: 700px) {
        .schedule-week-grid { grid-template-columns: repeat(2, 1fr); }
    }
    @media (max-width: 480px) {
        .schedule-week-grid { grid-template-columns: 1fr; }
    }
</style>

<div class="schedule-hero">
    <div>
        <h1>
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
            <span>My Shift Schedule</span>
        </h1>
        <p class="muted" style="margin: 4px 0 0; font-size: 13px;">View your assigned shifts for this week and next week</p>
    </div>
    <span class="today-badge">
        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
        ${today}
    </span>
</div>

<c:if test="${not empty errorMessage}">
    <div class="alert alert-danger">${errorMessage}</div>
</c:if>

<!-- THIS WEEK -->
<div class="week-section">
    <div class="week-section-head">
        <h2 class="week-section-title">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="13 17 18 12 13 7"/><polyline points="6 17 11 12 6 7"/></svg>
            <span>This Week</span>
        </h2>
        <span class="muted small">Current period</span>
    </div>
    <div class="schedule-week-grid">
        <c:forEach var="day" items="${thisWeek}">
            <c:set var="isToday" value="${day == today}"/>
            <c:set var="asgn" value="${scheduleMap[day.toString()]}"/>
            <div class="day-card ${isToday ? 'is-today' : ''}">
                <div class="day-title">
                    <c:choose>
                        <c:when test="${day.dayOfWeek.value == 1}">Monday</c:when>
                        <c:when test="${day.dayOfWeek.value == 2}">Tuesday</c:when>
                        <c:when test="${day.dayOfWeek.value == 3}">Wednesday</c:when>
                        <c:when test="${day.dayOfWeek.value == 4}">Thursday</c:when>
                        <c:when test="${day.dayOfWeek.value == 5}">Friday</c:when>
                        <c:when test="${day.dayOfWeek.value == 6}">Saturday</c:when>
                        <c:when test="${day.dayOfWeek.value == 7}">Sunday</c:when>
                    </c:choose>
                </div>
                <div class="day-date">${day.dayOfMonth}/${day.monthValue}</div>
                <c:choose>
                    <c:when test="${not empty asgn}">
                        <div class="shift-block ${asgn.startTime > asgn.endTime ? 'overnight' : ''}">
                            <div style="font-weight: 600;">${asgn.shiftName}</div>
                            <div class="shift-time">${asgn.startTime} - ${asgn.endTime}</div>
                            <div class="shift-break">Break: ${asgn.breakMinutes}m</div>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="off-block">
                            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M17 18a5 5 0 0 0-10 0"/><line x1="12" y1="2" x2="12" y2="9"/><line x1="4.22" y1="10.22" x2="5.64" y2="11.64"/><line x1="1" y1="18" x2="3" y2="18"/><line x1="21" y1="18" x2="23" y2="18"/><line x1="18.36" y1="11.64" x2="19.78" y2="10.22"/></svg>
                            <span>Day Off</span>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </c:forEach>
    </div>
</div>

<!-- NEXT WEEK -->
<div class="week-section">
    <div class="week-section-head">
        <h2 class="week-section-title">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="13 17 18 12 13 7"/><polyline points="6 17 11 12 6 7"/></svg>
            <span>Next Week</span>
        </h2>
        <span class="muted small">Upcoming period</span>
    </div>
    <div class="schedule-week-grid">
        <c:forEach var="day" items="${nextWeek}">
            <c:set var="asgn" value="${scheduleMap[day.toString()]}"/>
            <div class="day-card">
                <div class="day-title">
                    <c:choose>
                        <c:when test="${day.dayOfWeek.value == 1}">Monday</c:when>
                        <c:when test="${day.dayOfWeek.value == 2}">Tuesday</c:when>
                        <c:when test="${day.dayOfWeek.value == 3}">Wednesday</c:when>
                        <c:when test="${day.dayOfWeek.value == 4}">Thursday</c:when>
                        <c:when test="${day.dayOfWeek.value == 5}">Friday</c:when>
                        <c:when test="${day.dayOfWeek.value == 6}">Saturday</c:when>
                        <c:when test="${day.dayOfWeek.value == 7}">Sunday</c:when>
                    </c:choose>
                </div>
                <div class="day-date">${day.dayOfMonth}/${day.monthValue}</div>
                <c:choose>
                    <c:when test="${not empty asgn}">
                        <div class="shift-block ${asgn.startTime > asgn.endTime ? 'overnight' : ''}">
                            <div style="font-weight: 600;">${asgn.shiftName}</div>
                            <div class="shift-time">${asgn.startTime} - ${asgn.endTime}</div>
                            <div class="shift-break">Break: ${asgn.breakMinutes}m</div>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="off-block">
                            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M17 18a5 5 0 0 0-10 0"/><line x1="12" y1="2" x2="12" y2="9"/></svg>
                            <span>Day Off</span>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </c:forEach>
    </div>
</div>

<%@ include file="../common/footer.jspf" %>
