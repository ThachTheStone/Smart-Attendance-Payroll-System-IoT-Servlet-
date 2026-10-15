<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="pageTitle" value="Your Payslips"/>
<c:set var="activeNav" value="payslips"/>
<%@ include file="../common/header.jspf" %>

<div class="page-head">
    <div>
        <h1>Your Payslips</h1>
        <p class="muted">Official payslips from payroll periods finalized and locked by HR (FR-PAY-07).</p>
    </div>
</div>

<c:choose>
    <c:when test="${empty payslips}">
        <div class="card empty" style="padding:48px 24px;">
            <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" style="color:var(--muted); margin-bottom:12px;">
                <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path>
                <polyline points="14 2 14 8 20 8"></polyline>
                <line x1="16" y1="13" x2="8" y2="13"></line>
                <line x1="16" y1="17" x2="8" y2="17"></line>
                <polyline points="10 9 9 9 8 9"></polyline>
            </svg>
            <h3 style="margin:0 0 6px 0; color:var(--text);">No Finalized Payslips Yet</h3>
            <p class="muted small" style="margin:0;">Once management approves and locks the official monthly payroll, your payslip will appear here.</p>
        </div>
    </c:when>
    <c:otherwise>
        <div style="display:flex; flex-direction:column; gap:20px;">
            <c:forEach var="p" items="${payslips}">
                <div class="card" style="border-left: 4px solid #10b981;">
                    <div style="display:flex; justify-content:space-between; align-items:center; border-bottom:1px solid var(--line); padding-bottom:14px; margin-bottom:16px; flex-wrap:wrap; gap:12px;">
                        <div>
                            <span class="role-badge" style="background:#dcfce7; color:#15803d; font-size:12px; margin-bottom:4px; display:inline-block;">🔒 FINALIZED &amp; LOCKED</span>
                            <h2 style="font-size:18px; margin:0;">
                                Payslip for Month ${p.month > 0 ? p.month : ''}${p.year > 0 ? '/' : ''}${p.year > 0 ? p.year : p.payrollId}
                            </h2>
                        </div>
                        <div style="display:flex; align-items:center; gap:20px; flex-wrap:wrap;">
                            <div style="text-align:right;">
                                <div class="muted small">Net Salary (Take-home)</div>
                                <div class="mono font-bold" style="font-size:24px; color:#059669;">
                                    <fmt:formatNumber value="${p.netSalary}" pattern="#,##0"/> VND
                                </div>
                            </div>
                            <a href="${pageContext.request.contextPath}/staff/payslips/download?payrollId=${p.payrollId}" class="btn btn-secondary btn-sm" style="display:inline-flex; align-items:center; gap:6px; color:#2563eb; border-color:#2563eb;" title="Download official PDF payslip">
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path><polyline points="7 10 12 15 17 10"></polyline><line x1="12" y1="15" x2="12" y2="3"></line></svg>
                                Download PDF
                            </a>
                        </div>
                    </div>

                    <div style="display:grid; grid-template-columns:repeat(auto-fit, minmax(180px, 1fr)); gap:16px; background:#f8fafc; padding:16px; border-radius:8px; margin-bottom:16px;">
                        <div>
                            <div class="muted small">Base Salary</div>
                            <div class="mono font-bold"><fmt:formatNumber value="${p.baseSalary}" pattern="#,##0"/> VND</div>
                        </div>
                        <div>
                            <div class="muted small">Standard Hours</div>
                            <div class="mono font-bold">${p.regularHours} hrs</div>
                        </div>
                        <div>
                            <div class="muted small">Overtime (OT)</div>
                            <div class="mono font-bold">${p.totalOvertimeHours} hrs (+<fmt:formatNumber value="${p.totalOvertimePay}" pattern="#,##0"/> VND)</div>
                        </div>
                        <div>
                            <div class="muted small">Night Shift</div>
                            <div class="mono font-bold">${p.nightHours} hrs (+<fmt:formatNumber value="${p.nightAllowance}" pattern="#,##0"/> VND)</div>
                        </div>
                        <div>
                            <div class="muted small">Late Deductions</div>
                            <div class="mono font-bold" style="color:#dc2626;">-<fmt:formatNumber value="${p.penalty}" pattern="#,##0"/> VND (${p.lateMinutes}m)</div>
                        </div>
                    </div>
                </div>
            </c:forEach>
        </div>
    </c:otherwise>
</c:choose>

<%@ include file="../common/footer.jspf" %>
