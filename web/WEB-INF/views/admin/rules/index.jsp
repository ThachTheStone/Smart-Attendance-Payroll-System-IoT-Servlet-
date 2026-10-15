<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<c:set var="pageTitle" value="Salary Rules"/>
<c:set var="activeNav" value="rules"/>
<%@include file="/WEB-INF/views/common/header.jspf"%>

<div class="page-head">
    <div>
        <h1>Salary Rules Engine</h1>
        <p class="muted">Configure payroll parameters and multipliers compliant with statutory labor rules (FR-RULE-01..07). Changes affect unlocked draft payrolls.</p>
    </div>
    <div style="display:flex; gap:10px;">
        <a href="${pageContext.request.contextPath}/admin/holidays" class="btn btn-secondary btn-sm">Holidays Calendar</a>
        <a href="${pageContext.request.contextPath}/admin/payroll" class="btn btn-sm">Payroll Sheets</a>
    </div>
</div>

<form method="post" action="${pageContext.request.contextPath}/admin/rules">
    <div class="card" style="margin-bottom:24px;">
        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:16px;">
            <h2 style="font-size:16px; margin:0;">Standard Working Hours &amp; Pay Parameters</h2>
            <span class="role-badge role-ADMIN">FR-RULE-01</span>
        </div>

        <table class="table">
            <thead>
                <tr>
                    <th style="width:240px;">Rule Key</th>
                    <th>Description &amp; Purpose</th>
                    <th style="width:200px;">Configured Value</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="r" items="${rules}">
                    <tr>
                        <td class="mono font-bold" style="color:#2563eb;">
                            ${r.ruleKey}
                        </td>
                        <td>
                            <strong><c:out value="${r.description}"/></strong>
                            <div class="muted small" style="margin-top:2px;">
                                <c:choose>
                                    <c:when test="${r.ruleKey == 'standard_hours_per_month'}">Standard working hours per month for hourly rate calculation (Base Salary / 208).</c:when>
                                    <c:when test="${r.ruleKey == 'ot_weekday_multiplier'}">Overtime multiplier for standard working weekdays (150%).</c:when>
                                    <c:when test="${r.ruleKey == 'ot_weekend_multiplier'}">Overtime multiplier for weekly rest days (Saturdays, Sundays - 200%).</c:when>
                                    <c:when test="${r.ruleKey == 'ot_holiday_multiplier'}">Overtime multiplier for paid public holidays (300%).</c:when>
                                    <c:when test="${r.ruleKey == 'night_allowance_multiplier'}">Night shift differential allowance (22:00 to 06:00 - +30%).</c:when>
                                    <c:when test="${r.ruleKey == 'night_ot_multiplier'}">Night overtime supplemental bonus (+20%).</c:when>
                                    <c:when test="${r.ruleKey == 'grace_period_minutes'}">Grace period allowed for late check-in without penalty deduction.</c:when>
                                    <c:when test="${r.ruleKey == 'penalty_rate_per_minute'}">Penalty deduction amount per late minute exceeding grace period.</c:when>
                                    <c:when test="${r.ruleKey == 'min_confidence'}">AS608 optical fingerprint sensor confidence score threshold.</c:when>
                                    <c:otherwise>Extended system rule parameter.</c:otherwise>
                                </c:choose>
                            </div>
                        </td>
                        <td>
                            <div style="display:flex; align-items:center; gap:8px;">
                                <input type="number" step="any" name="rule_${r.ruleKey}" value="${r.value}" class="mono font-bold" style="max-width:140px; text-align:right;">
                                <span class="muted small">
                                    <c:choose>
                                        <c:when test="${r.ruleKey.contains('multiplier')}">multiplier</c:when>
                                        <c:when test="${r.ruleKey.contains('minutes')}">mins</c:when>
                                        <c:when test="${r.ruleKey.contains('rate')}">VND/min</c:when>
                                        <c:when test="${r.ruleKey.contains('hours')}">hrs</c:when>
                                        <c:when test="${r.ruleKey.contains('confidence')}">%</c:when>
                                        <c:otherwise></c:otherwise>
                                    </c:choose>
                                </span>
                            </div>
                        </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>

        <div style="display:flex; justify-content:flex-end; gap:12px; margin-top:20px;">
            <button type="submit" class="btn">Save Salary Rules</button>
        </div>
    </div>
</form>

<!-- Sample calculation formula referenced according to SRS Section 5 -->
<div class="card" style="background:#f8fafc;">
    <h3 style="font-size:15px; margin:0 0 10px 0; color:#1e293b;">📐 Net Salary Calculation Formula (SRS Section 5)</h3>
    <div class="mono small" style="background:#0f172a; color:#38bdf8; padding:16px; border-radius:8px; line-height:1.6;">
        Hourly Rate       = Base Salary / Standard Hours (208h)<br>
        Standard Salary   = Standard Hours Worked &times; Hourly Rate<br>
        Overtime Pay      = &Sigma; (OT Hours &times; Hourly Rate &times; OT Multiplier [150%, 200%, 300%])<br>
        Night Differential= Night Hours &times; Hourly Rate &times; 30%<br>
        Night OT Bonus    = Night OT Hours &times; Hourly Rate &times; 20%<br>
        Late Deduction    = Late Minutes after Grace Period &times; Penalty Rate (1,000 VND)<br>
        ───────────────────────────────────────────────────────────────────────<br>
        <strong>NET SALARY        = Standard Salary + Overtime Pay + Night Diff + Night OT Bonus &minus; Late Deduction</strong>
    </div>
</div>

<%@include file="/WEB-INF/views/common/footer.jspf"%>
