<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="pageTitle" value="Your Payslips"/>
<c:set var="activeNav" value="payslips"/>
<%@ include file="../common/header.jspf" %>

<style>
    /* ================= Staff Payslips View (Swiss Light SaaS) ================= */
    .payslip-hero {
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
    .payslip-hero h1 {
        font-size: 22px;
        font-weight: 700;
        letter-spacing: -0.02em;
        margin: 0;
        display: flex;
        align-items: center;
        gap: 10px;
        color: #0f172a !important;
    }

    /* Payslip Card */
    .payslip-card {
        background: #ffffff !important;
        border: 1px solid var(--border) !important;
        border-radius: var(--radius-lg);
        overflow: hidden;
        margin-bottom: 20px;
        box-shadow: var(--shadow-xs);
    }
    .payslip-card-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 20px 24px;
        border-bottom: 1px solid var(--border);
        background: #f8fafc;
        flex-wrap: wrap;
        gap: 14px;
    }
    .payslip-period-info {
        display: flex;
        flex-direction: column;
        gap: 6px;
    }
    .payslip-locked-badge {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        padding: 3px 10px;
        border-radius: 999px;
        background: #ecfdf5;
        color: #059669;
        font-size: 11px;
        font-weight: 600;
        letter-spacing: 0.03em;
        border: 1px solid #a7f3d0;
    }
    .payslip-period-title {
        font-size: 17px;
        font-weight: 700;
        color: #0f172a;
    }
    .payslip-net-section {
        display: flex;
        align-items: center;
        gap: 18px;
    }
    .payslip-net-label {
        font-size: 11px;
        color: #64748b;
        text-align: right;
        text-transform: uppercase;
        font-weight: 600;
    }
    .payslip-net-amount {
        font-family: var(--font-ui); font-variant-numeric: tabular-nums;
        font-size: 26px;
        font-weight: 700;
        color: #059669;
        letter-spacing: -0.02em;
    }
    .payslip-download-btn {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        padding: 8px 16px;
        background: #1d4ed8;
        color: #ffffff;
        border: 1px solid #1e40af;
        border-radius: 6px;
        font-size: 13px;
        font-weight: 600;
        text-decoration: none;
        transition: background-color 0.15s ease;
        box-shadow: 0 1px 2px rgba(29, 78, 216, 0.2);
    }
    .payslip-download-btn:hover {
        background: #1e40af;
        color: #ffffff;
    }

    /* Breakdown Grid */
    .payslip-breakdown {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
        gap: 0;
        padding: 0;
        background: #ffffff;
    }
    .breakdown-item {
        padding: 16px 24px;
        border-right: 1px solid #f1f5f9;
        border-bottom: 1px solid #f1f5f9;
    }
    .breakdown-item:last-child { border-right: 0; }
    .breakdown-label {
        font-size: 11px;
        color: #64748b;
        font-weight: 600;
        text-transform: uppercase;
        letter-spacing: 0.04em;
        margin-bottom: 6px;
    }
    .breakdown-value {
        font-family: var(--font-ui); font-variant-numeric: tabular-nums;
        font-size: 14px;
        font-weight: 600;
        color: #0f172a;
    }
    .breakdown-value.deduction {
        color: #dc2626;
    }
    .breakdown-value.bonus {
        color: #059669;
    }

    /* Empty State */
    .payslip-empty {
        background: #ffffff !important;
        border: 1px solid var(--border) !important;
        border-radius: var(--radius-lg);
        padding: 64px 32px;
        text-align: center;
        color: #0f172a;
        box-shadow: var(--shadow-xs);
    }
    .empty-icon-wrap {
        width: 60px;
        height: 60px;
        border-radius: 12px;
        background: #eff6ff;
        border: 1px solid #bfdbfe;
        display: grid;
        place-items: center;
        margin: 0 auto 16px;
        color: #1d4ed8;
    }
</style>

<!-- Page Hero -->
<div class="payslip-hero">
    <div>
        <h1>
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/></svg>
            <span>Your Payslips</span>
        </h1>
        <p class="muted" style="margin: 4px 0 0; font-size: 13px;">Official payslips from payroll periods finalized and locked by HR</p>
    </div>
</div>

<c:choose>
    <c:when test="${empty payslips}">
        <div class="payslip-empty">
            <div class="empty-icon-wrap">
                <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/>
                    <polyline points="14 2 14 8 20 8"/>
                    <line x1="16" y1="13" x2="8" y2="13"/>
                    <line x1="16" y1="17" x2="8" y2="17"/>
                </svg>
            </div>
            <h3 style="font-size: 17px; margin: 0 0 6px 0; color: #0f172a; font-weight: 600;">No Finalized Payslips Yet</h3>
            <p class="muted" style="margin: 0; max-width: 420px; margin: 0 auto; line-height: 1.5; font-size: 13px;">
                Once management approves and locks the official monthly payroll, your payslip will appear here with full salary breakdown details.
            </p>
        </div>
    </c:when>
    <c:otherwise>
        <c:forEach var="p" items="${payslips}">
            <div class="payslip-card">
                <div class="payslip-card-header">
                    <div class="payslip-period-info">
                        <span class="payslip-locked-badge">
                            <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
                            <span>Finalized &amp; Locked</span>
                        </span>
                        <span class="payslip-period-title">
                            Payslip for Month ${p.month > 0 ? p.month : ''}${p.year > 0 ? '/' : ''}${p.year > 0 ? p.year : p.payrollId}
                        </span>
                    </div>
                    <div class="payslip-net-section">
                        <div>
                            <div class="payslip-net-label">Net Salary (Take-home)</div>
                            <div class="payslip-net-amount">
                                <fmt:formatNumber value="${p.netSalary}" pattern="#,##0"/> <span style="font-size:13px; font-weight:500;">VND</span>
                            </div>
                        </div>
                        <a href="${pageContext.request.contextPath}/staff/payslips/download?payrollId=${p.payrollId}" class="payslip-download-btn" title="Download official PDF payslip">
                            <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>
                            <span>Download PDF</span>
                        </a>
                    </div>
                </div>

                <div class="payslip-breakdown">
                    <div class="breakdown-item">
                        <div class="breakdown-label">Base Salary</div>
                        <div class="breakdown-value"><fmt:formatNumber value="${p.baseSalary}" pattern="#,##0"/> VND</div>
                    </div>
                    <div class="breakdown-item">
                        <div class="breakdown-label">Standard Hours</div>
                        <div class="breakdown-value">${p.regularHours} hrs</div>
                    </div>
                    <div class="breakdown-item">
                        <div class="breakdown-label">Overtime (OT)</div>
                        <div class="breakdown-value bonus">${p.totalOvertimeHours} hrs (+<fmt:formatNumber value="${p.totalOvertimePay}" pattern="#,##0"/> VND)</div>
                    </div>
                    <div class="breakdown-item">
                        <div class="breakdown-label">Night Shift Allowance</div>
                        <div class="breakdown-value bonus">${p.nightHours} hrs (+<fmt:formatNumber value="${p.nightAllowance}" pattern="#,##0"/> VND)</div>
                    </div>
                    <div class="breakdown-item">
                        <div class="breakdown-label">Late Deductions</div>
                        <div class="breakdown-value deduction">-<fmt:formatNumber value="${p.penalty}" pattern="#,##0"/> VND (${p.lateMinutes}m)</div>
                    </div>
                </div>
            </div>
        </c:forEach>
    </c:otherwise>
</c:choose>

<%@ include file="../common/footer.jspf" %>
