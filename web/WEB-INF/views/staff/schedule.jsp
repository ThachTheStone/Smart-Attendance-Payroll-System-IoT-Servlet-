<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="pageTitle" value="My Schedule"/>
<c:set var="activeNav" value="schedule"/>
<%@ include file="../common/header.jspf" %>

<style>
    .schedule-week-grid {
        display: grid; grid-template-columns: repeat(7, 1fr); gap: 12px; margin-top: 14px;
    }
    @media (max-width: 900px) {
        .schedule-week-grid { grid-template-columns: repeat(2, 1fr); }
    }
    @media (max-width: 500px) {
        .schedule-week-grid { grid-template-columns: 1fr; }
    }
    .day-card {
        background: var(--surface); border: 1px solid var(--line); border-radius: var(--radius);
        padding: 14px; display: flex; flex-direction: column; min-height: 120px;
    }
    .day-card.is-today {
        border-color: var(--primary); background: #f0f7ff; box-shadow: 0 0 0 1px var(--primary);
    }
    .day-title { font-weight: 600; font-size: 14px; margin-bottom: 2px; }
    .day-date { color: var(--muted); font-size: 12px; margin-bottom: 12px; }
    .shift-box {
        background: #e0f2fe; color: #0369a1; border-radius: 6px; padding: 8px 10px; font-size: 13px; font-weight: 500;
        margin-top: auto;
    }
    .shift-box-overnight {
        background: #fef3c7; color: #92400e;
    }
    .off-box {
        color: var(--muted); font-size: 13px; margin-top: auto; padding: 8px 0; font-style: italic;
    }
</style>

<div class="page-head">
    <div>
        <h1>📅 My Shift Schedule</h1>
        <p class="muted">View your assigned shifts for this week and next week (FR-SHIFT-04)</p>
    </div>
</div>

<c:if test="${not empty errorMessage}">
    <div class="alert alert-danger">${errorMessage}</div>
</c:if>

<!-- THIS WEEK -->
<div class="card" style="margin-bottom: 24px;">
    <h2 style="margin: 0; font-size: 16px; display: flex; align-items: center; justify-content: space-between;">
        <span>This Week</span>
        <span class="muted small">Today is ${today}</span>
    </h2>
    <div class="schedule-week-grid">
        <c:forEach var="day" items="${thisWeek}">
            <c:set var="isToday" value="${day == today}"/>
            <c:set var="asgn" value="${scheduleMap[day.toString()]}"/>
            <div class="day-card ${isToday ? 'is-today' : ''}">
                <div class="day-title">
                    <c:choose>
                        <c:when test="${day.dayOfWeek.value == 1}">Mon</c:when>
                        <c:when test="${day.dayOfWeek.value == 2}">Tue</c:when>
                        <c:when test="${day.dayOfWeek.value == 3}">Wed</c:when>
                        <c:when test="${day.dayOfWeek.value == 4}">Thu</c:when>
                        <c:when test="${day.dayOfWeek.value == 5}">Fri</c:when>
                        <c:when test="${day.dayOfWeek.value == 6}">Sat</c:when>
                        <c:when test="${day.dayOfWeek.value == 7}">Sun</c:when>
                    </c:choose>
                    <c:if test="${isToday}"><span style="color:var(--primary); font-size:11px;">(Today)</span></c:if>
                </div>
                <div class="day-date">${day.dayOfMonth}/${day.monthValue}</div>

                <c:choose>
                    <c:when test="${not empty asgn}">
                        <div class="shift-box ${asgn.startTime > asgn.endTime ? 'shift-box-overnight' : ''}">
                            <div style="font-weight: 700;">${asgn.shiftName}</div>
                            <div class="mono" style="font-size: 12px; margin-top: 2px;">${asgn.startTime} - ${asgn.endTime}</div>
                            <div class="small" style="opacity: 0.8; margin-top: 2px;">Break: ${asgn.breakMinutes}m</div>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="off-box">Day Off</div>
                    </c:otherwise>
                </c:choose>
            </div>
        </c:forEach>
    </div>
</div>

<!-- NEXT WEEK -->
<div class="card">
    <h2 style="margin: 0; font-size: 16px;">Next Week</h2>
    <div class="schedule-week-grid">
        <c:forEach var="day" items="${nextWeek}">
            <c:set var="asgn" value="${scheduleMap[day.toString()]}"/>
            <div class="day-card">
                <div class="day-title">
                    <c:choose>
                        <c:when test="${day.dayOfWeek.value == 1}">Mon</c:when>
                        <c:when test="${day.dayOfWeek.value == 2}">Tue</c:when>
                        <c:when test="${day.dayOfWeek.value == 3}">Wed</c:when>
                        <c:when test="${day.dayOfWeek.value == 4}">Thu</c:when>
                        <c:when test="${day.dayOfWeek.value == 5}">Fri</c:when>
                        <c:when test="${day.dayOfWeek.value == 6}">Sat</c:when>
                        <c:when test="${day.dayOfWeek.value == 7}">Sun</c:when>
                    </c:choose>
                </div>
                <div class="day-date">${day.dayOfMonth}/${day.monthValue}</div>

                <c:choose>
                    <c:when test="${not empty asgn}">
                        <div class="shift-box ${asgn.startTime > asgn.endTime ? 'shift-box-overnight' : ''}">
                            <div style="font-weight: 700;">${asgn.shiftName}</div>
                            <div class="mono" style="font-size: 12px; margin-top: 2px;">${asgn.startTime} - ${asgn.endTime}</div>
                            <div class="small" style="opacity: 0.8; margin-top: 2px;">Break: ${asgn.breakMinutes}m</div>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="off-box">Day Off</div>
                    </c:otherwise>
                </c:choose>
            </div>
        </c:forEach>
    </div>
</div>

<%@ include file="../common/footer.jspf" %>
