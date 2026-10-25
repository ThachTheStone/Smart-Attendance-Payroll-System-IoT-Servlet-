<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="pageTitle" value="Salary & Calculation Rules"/>
<c:set var="activeNav" value="rules"/>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<%@ include file="/WEB-INF/views/common/header.jspf" %>

<style>
    .rules-hero {
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
    .rules-hero-title {
        font-size: 22px;
        font-weight: 700;
        letter-spacing: -0.02em;
        margin: 0;
        display: flex;
        align-items: center;
        gap: 10px;
        color: #0f172a;
    }
    .rules-hero-desc {
        color: var(--muted);
        font-size: 13px;
        margin-top: 4px;
    }

    /* Rules Table Card */
    .rules-card {
        background: #ffffff;
        border: 1px solid var(--border);
        border-radius: var(--radius-lg);
        overflow: hidden;
        margin-bottom: 24px;
        box-shadow: var(--shadow-xs);
    }
    .rules-card-header {
        padding: 16px 20px;
        border-bottom: 1px solid var(--border);
        background: #f8fafc;
        display: flex;
        justify-content: space-between;
        align-items: center;
    }
    .rules-table {
        width: 100%;
        margin: 0;
        border-collapse: collapse;
    }
    .rules-table th {
        background: #f8fafc;
        padding: 11px 18px;
        font-size: 11px;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 0.05em;
        color: #475569;
        border-bottom: 1px solid var(--border);
    }
    .rules-table td {
        padding: 14px 18px;
        border-bottom: 1px solid #f1f5f9;
        vertical-align: middle;
        font-size: 13px;
        color: #334155;
    }
    .rules-table tr:last-child td {
        border-bottom: none;
    }
    .rules-table tr:hover td {
        background: #f8fafc;
    }

    /* Rule Input Container */
    .rule-input-group {
        display: flex;
        align-items: center;
        gap: 8px;
        justify-content: flex-end;
    }
    .rule-input {
        width: 110px;
        height: 36px;
        padding: 0 10px;
        border: 1px solid #cbd5e1 !important;
        border-radius: 7px;
        text-align: right;
        font-family: 'JetBrains Mono', monospace;
        font-weight: 600;
        font-size: 13px;
        background: #ffffff !important;
        color: #0f172a !important;
        transition: border-color var(--transition-fast), box-shadow var(--transition-fast);
    }
    .rule-input:focus {
        border-color: #1d4ed8 !important;
        box-shadow: 0 0 0 3px rgba(29, 78, 216, 0.12) !important;
        outline: none;
    }
    .rule-unit-pill {
        min-width: 60px;
        display: inline-block;
        font-size: 11px;
        font-weight: 600;
        color: var(--muted);
    }

    /* Formula Banner Card */
    .formula-card {
        background: #ffffff;
        color: #0f172a;
        border: 1px solid var(--border);
        border-radius: var(--radius-lg);
        padding: 20px 24px;
        margin-bottom: 28px;
        box-shadow: var(--shadow-xs);
    }
</style>

<!-- Hero Section -->
<div class="rules-hero">
    <div>
        <h1 class="rules-hero-title">
            Salary Rules &amp; Calculation Engine
        </h1>
        <p class="rules-hero-desc">
            Configure payroll formulas, statutory overtime multipliers, late penalties, and biometric matching thresholds
        </p>
    </div>
    <div style="display:flex; gap:8px; flex-wrap:wrap;">
        <a href="${ctx}/admin/holidays" class="btn btn-secondary">Holidays Calendar</a>
        <a href="${ctx}/admin/payroll" class="btn btn-secondary">Payroll Sheets</a>
    </div>
</div>

<form method="post" action="${ctx}/admin/rules">
    <div class="rules-card">
        <div class="rules-card-header">
            <div>
                <h2 style="font-size: 15px; font-weight: 700; margin: 0; color: #0f172a;">
                    Statutory Multipliers &amp; Working Parameters
                </h2>
                <div class="muted small" style="margin-top: 2px;">
                    Changes immediately apply to upcoming unlocked and draft payroll recalculations.
                </div>
            </div>
            <span class="role-badge role-ADMIN">
                Rule Engine v2.0
            </span>
        </div>

        <table class="rules-table">
            <thead>
                <tr>
                    <th style="width: 260px;">Rule Key Identifier</th>
                    <th>Specification &amp; Purpose</th>
                    <th style="width: 220px; text-align: right;">Configured Value</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="r" items="${rules}">
                    <tr>
                        <td>
                            <div class="mono font-bold" style="color: #2563eb; font-size: 13px;">
                                ${r.ruleKey}
                            </div>
                        </td>
                        <td>
                            <div style="font-weight: 600; color: #0f172a;"><c:out value="${r.description}"/></div>
                            <div class="muted small" style="margin-top: 3px; line-height: 1.4;">
                                <c:choose>
                                    <c:when test="${r.ruleKey == 'standard_hours_per_month'}">Standard monthly denominator used for hourly wage basis (Base Salary &divide; 208h).</c:when>
                                    <c:when test="${r.ruleKey == 'ot_weekday_multiplier'}">Overtime pay multiplier for standard workdays (150% standard rate).</c:when>
                                    <c:when test="${r.ruleKey == 'ot_weekend_multiplier'}">Overtime pay multiplier for designated rest days (200% standard rate).</c:when>
                                    <c:when test="${r.ruleKey == 'ot_holiday_multiplier'}">Overtime pay multiplier for official paid public holidays (300% standard rate).</c:when>
                                    <c:when test="${r.ruleKey == 'night_allowance_multiplier'}">Night differential shift supplement from 22:00 to 06:00 (+30% rate).</c:when>
                                    <c:when test="${r.ruleKey == 'night_ot_multiplier'}">Overtime supplemental bonus for night shift hours (+20% rate).</c:when>
                                    <c:when test="${r.ruleKey == 'grace_period_minutes'}">Grace window allowed for check-in before late deductions initiate.</c:when>
                                    <c:when test="${r.ruleKey == 'penalty_rate_per_minute'}">Financial penalty rate per minute deducted past the allowed grace period.</c:when>
                                    <c:when test="${r.ruleKey == 'min_confidence'}">ESP32 optical biometric sensor matching confidence threshold.</c:when>
                                    <c:otherwise>System configured parameter definition.</c:otherwise>
                                </c:choose>
                            </div>
                        </td>
                        <td>
                            <div class="rule-input-group">
                                <input type="number" step="any" name="rule_${r.ruleKey}" value="${r.value}" class="rule-input">
                                <span class="rule-unit-pill">
                                    <c:choose>
                                        <c:when test="${r.ruleKey.contains('multiplier')}">&times; factor</c:when>
                                        <c:when test="${r.ruleKey.contains('minutes')}">mins</c:when>
                                        <c:when test="${r.ruleKey.contains('rate')}">VND/min</c:when>
                                        <c:when test="${r.ruleKey.contains('hours')}">hours</c:when>
                                        <c:when test="${r.ruleKey.contains('confidence')}">% match</c:when>
                                        <c:otherwise></c:otherwise>
                                    </c:choose>
                                </span>
                            </div>
                        </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>

        <div style="padding: 16px 20px; background: #f8fafc; border-top: 1px solid var(--border); display: flex; justify-content: flex-end;">
            <button type="submit" class="btn btn-primary">
                Save Salary Rules
            </button>
        </div>
    </div>
</form>

<!-- Sample calculation formula referenced according to SRS Section 5 -->
<div class="formula-card">
    <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:12px;">
        <h3 style="font-size: 14px; margin: 0; color: #1d4ed8; font-weight: 700; display:flex; align-items:center; gap:8px;">
            Net Salary Calculation Formula (SRS Section 5 Specification)
        </h3>
        <span class="mono" style="font-size:11px; background:#f1f5f9; padding:2px 8px; border-radius:4px; color:#475569;">
            Labor Code Compliance
        </span>
    </div>
    <div class="mono small" style="line-height: 1.8; color: #334155; font-size: 12px;">
        Hourly Rate       = Base Salary / Standard Hours (208h)<br>
        Standard Salary   = Standard Hours Worked &times; Hourly Rate<br>
        Overtime Pay      = &Sigma; (OT Hours &times; Hourly Rate &times; OT Multiplier [150%, 200%, 300%])<br>
        Night Differential= Night Hours &times; Hourly Rate &times; 30%<br>
        Night OT Bonus    = Night OT Hours &times; Hourly Rate &times; 20%<br>
        Late Deduction    = Late Minutes after Grace Period &times; Penalty Rate (1,000 VND/min)<br>
        <span style="display:block; border-top:1px dashed #e2e8f0; margin:8px 0;"></span>
        <strong style="color: #059669; font-size:13px;">NET SALARY        = Standard Salary + Overtime Pay + Night Diff + Night OT Bonus &minus; Late Deduction</strong>
    </div>
</div>

<%@ include file="/WEB-INF/views/common/footer.jspf" %>
