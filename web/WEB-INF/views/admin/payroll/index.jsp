<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<c:set var="pageTitle" value="Payroll Management"/>
<c:set var="activeNav" value="payroll"/>
<%@include file="/WEB-INF/views/common/header.jspf"%>

<style>
    .payroll-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        flex-wrap: wrap;
        gap: 16px;
        margin-bottom: 24px;
    }

    .period-filter-bar {
        display: flex;
        align-items: center;
        gap: 10px;
        background: var(--surface);
        border: 1px solid var(--line);
        padding: 10px 16px;
        border-radius: var(--radius);
    }
    .period-filter-bar select, .period-filter-bar input {
        width: auto;
        padding: 6px 12px;
        font: inherit;
        border: 1px solid var(--line);
        border-radius: 6px;
        font-size: 13px;
    }

    .status-badge-draft {
        background: #fef3c7;
        color: #92400e;
        border: 1px solid #fde68a;
        padding: 4px 12px;
        border-radius: 999px;
        font-weight: 700;
        font-size: 13px;
    }
    .status-badge-locked {
        background: #dcfce7;
        color: #15803d;
        border: 1px solid #bbf7d0;
        padding: 4px 12px;
        border-radius: 999px;
        font-weight: 700;
        font-size: 13px;
    }

    .payroll-kpi-bar {
        display: grid;
        grid-template-columns: repeat(3, 1fr);
        gap: 16px;
        margin-bottom: 24px;
    }
    .payroll-kpi {
        background: var(--surface);
        border: 1px solid var(--line);
        border-radius: var(--radius);
        padding: 20px;
        box-shadow: var(--shadow-xs);
        transition: transform var(--transition-fast), box-shadow var(--transition-fast);
    }
    .payroll-kpi:hover {
        transform: translateY(-2px);
        box-shadow: var(--shadow-sm);
    }
    .payroll-kpi:nth-child(1) { border-left: 4px solid #2563eb; }
    .payroll-kpi:nth-child(2) { border-left: 4px solid #10b981; }
    .payroll-kpi:nth-child(3) { border-left: 4px solid #8b5cf6; }

    .payroll-kpi-val {
        font-size: 28px;
        font-weight: 800;
        color: var(--text);
        margin-top: 6px;
        font-family: 'JetBrains Mono', ui-monospace, monospace;
    }

    /* Missing Checkout Block Alert (FR-PAY-03) */
    .missing-alert-box {
        background: #fffbeb;
        border: 1px solid #fde68a;
        border-left: 5px solid #d97706;
        border-radius: var(--radius);
        padding: 20px;
        margin-bottom: 24px;
        box-shadow: var(--shadow-xs);
    }

    /* Modal Payslip Breakdown */
    .modal-overlay {
        display: none;
        position: fixed;
        inset: 0;
        background: rgba(15, 23, 42, 0.65);
        backdrop-filter: blur(8px);
        -webkit-backdrop-filter: blur(8px);
        z-index: 10000;
        place-items: center;
        padding: 20px;
    }
    .modal-card {
        background: #ffffff !important;
        border: 1px solid var(--line);
        border-radius: var(--radius-lg);
        max-width: 640px;
        width: 100%;
        padding: 28px;
        box-shadow: var(--shadow-xl);
        max-height: 90vh;
        overflow-y: auto;
        animation: modalScaleIn 0.2s cubic-bezier(0.16, 1, 0.3, 1);
    }
</style>

<div class="payroll-header">
    <div>
        <h1>Payroll &amp; Payslip Management</h1>
        <p class="muted">Automated monthly payroll calculation, timesheet verification, and payroll locking (FR-PAY-01..04).</p>
    </div>

    <!-- Period Selector Form -->
    <form method="get" action="${pageContext.request.contextPath}/admin/payroll" class="period-filter-bar">
        <label style="flex-direction:row; align-items:center; gap:6px; font-weight:600; font-size:13px; margin:0;">
            Month:
            <select name="month">
                <c:forEach var="m" begin="1" end="12">
                    <option value="${m}" ${m == month ? 'selected' : ''}>Month ${m}</option>
                </c:forEach>
            </select>
        </label>
        <label style="flex-direction:row; align-items:center; gap:6px; font-weight:600; font-size:13px; margin:0;">
            Year:
            <input type="number" name="year" value="${year}" min="2020" max="2030" style="width:80px;">
        </label>
        <button type="submit" class="btn btn-secondary btn-sm">View</button>
    </form>
</div>

<!-- 1. MISSING CHECKOUT ALERT (FR-PAY-03) -->
<c:if test="${not empty missingCheckouts}">
    <div class="missing-alert-box">
        <div style="display:flex; align-items:center; gap:10px; color:#b45309; font-weight:700; font-size:16px;">
            <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"></path><line x1="12" y1="9" x2="12" y2="13"></line><line x1="12" y1="17" x2="12.01" y2="17"></line></svg>
            <span>PAYROLL CALCULATION BLOCKED: Found ${missingCheckouts.size()} missing checkout(s) in Month ${month}/${year} (FR-PAY-03)</span>
        </div>
        <p style="color:#78350f; font-size:13px; margin:8px 0 14px 0;">
            Under payroll integrity policies, payroll cannot be calculated or generated while unverified missing checkouts exist. Administrators must adjust check-out times in Attendance management with valid reasons first.
        </p>

        <div class="table-wrap">
            <table class="table" style="background:white;">
                <thead>
                    <tr>
                        <th>Emp Code</th>
                        <th>Full Name</th>
                        <th>Department</th>
                        <th>Work Date</th>
                        <th>Shift</th>
                        <th>Check-in</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="mc" items="${missingCheckouts}">
                        <tr>
                            <td class="mono font-bold">${mc.employeeCode}</td>
                            <td><c:out value="${mc.employeeName}"/></td>
                            <td><c:out value="${mc.department}"/></td>
                            <td class="mono">${mc.workDate}</td>
                            <td><c:out value="${mc.shiftName}"/></td>
                            <td class="mono">${mc.formattedCheckIn}</td>
                            <td>
                                <a href="${pageContext.request.contextPath}/admin/attendance?employeeId=${mc.employeeId}&from=${mc.workDate}&to=${mc.workDate}" class="btn btn-secondary btn-sm" style="font-size:11px;">
                                    Adjust Checkout
                                </a>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>
    </div>
</c:if>

<!-- 2. PAYROLL BATCH STATUS & ACTIONS -->
<div class="card" style="margin-bottom:24px;">
    <div style="display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:16px;">
        <div style="display:flex; align-items:center; gap:12px;">
            <h2 style="font-size:18px; margin:0;">Payroll Sheet Month ${month}/${year}</h2>
            <c:choose>
                <c:when test="${empty payroll}">
                    <span class="role-badge" style="background:#f1f5f9; color:#475569;">NOT GENERATED</span>
                </c:when>
                <c:when test="${payroll.status == 'DRAFT'}">
                    <span class="status-badge-draft">● DRAFT</span>
                </c:when>
                <c:when test="${payroll.status == 'LOCKED'}">
                    <span class="status-badge-locked">🔒 LOCKED</span>
                </c:when>
            </c:choose>
        </div>

        <div style="display:flex; gap:10px; flex-wrap:wrap; align-items:center;">
            <!-- Button Generate / Recalculate -->
            <c:if test="${empty payroll || !payroll.isLocked()}">
                <form method="post" action="${pageContext.request.contextPath}/admin/payroll" style="margin:0;">
                    <input type="hidden" name="action" value="generate">
                    <input type="hidden" name="month" value="${month}">
                    <input type="hidden" name="year" value="${year}">
                    <button type="submit" class="btn ${not empty missingCheckouts ? 'btn-secondary' : ''}" 
                            ${not empty missingCheckouts ? 'disabled title="Missing checkouts must be resolved first"' : ''}>
                        ${empty payroll ? '⚡ Calculate Payroll' : '🔄 Recalculate'}
                    </button>
                </form>
            </c:if>

            <!-- Button Lock -->
            <c:if test="${not empty payroll && !payroll.isLocked()}">
                <form method="post" action="${pageContext.request.contextPath}/admin/payroll" onsubmit="return confirm('Are you sure you want to LOCK this payroll? Once locked, calculations cannot be undone.');" style="margin:0;">
                    <input type="hidden" name="action" value="lock">
                    <input type="hidden" name="payrollId" value="${payroll.id}">
                    <input type="hidden" name="month" value="${month}">
                    <input type="hidden" name="year" value="${year}">
                    <button type="submit" class="btn btn-secondary" style="color:#059669; border-color:#059669;">
                        🔒 Lock Payroll (LOCK)
                    </button>
                </form>
            </c:if>

            <!-- Batch Export PDF & Send Email (FR-PAY-05, FR-PAY-06) -->
            <c:if test="${not empty payroll && not empty details}">
                <a href="${pageContext.request.contextPath}/admin/payroll/export-pdf?payrollId=${payroll.id}" class="btn btn-secondary" title="Export all company payslips into a single multi-page PDF">
                    📄 Export All PDFs
                </a>

                <form method="post" action="${pageContext.request.contextPath}/admin/payroll/send-email" onsubmit="return confirm('Are you sure you want to email payslip PDFs to ALL ${payroll.totalEmployees} employees for Month ${month}/${year}?');" style="margin:0;">
                    <input type="hidden" name="payrollId" value="${payroll.id}">
                    <input type="hidden" name="sendAll" value="true">
                    <button type="submit" class="btn btn-secondary" style="color:#2563eb; border-color:#2563eb;" title="Send PDF payslips via email to all employees">
                        📧 Send All Emails
                    </button>
                </form>
            </c:if>
        </div>
    </div>
</div>

<!-- 3. KPI STATS (When payroll exists) -->
<c:if test="${not empty payroll}">
    <div class="payroll-kpi-bar">
        <div class="payroll-kpi">
            <div class="muted small font-bold" style="text-transform:uppercase;">Employees on Payroll</div>
            <div class="payroll-kpi-val" style="color:#2563eb;">${payroll.totalEmployees} <span style="font-size:14px; color:var(--muted); font-weight:500;">employees</span></div>
        </div>
        <div class="payroll-kpi">
            <div class="muted small font-bold" style="text-transform:uppercase;">Total Net Salary Disbursed</div>
            <div class="payroll-kpi-val" style="color:#059669;">
                <fmt:formatNumber value="${payroll.totalNetSalary}" pattern="#,##0"/> <span style="font-size:14px; color:var(--muted); font-weight:500;">VND</span>
            </div>
        </div>
        <div class="payroll-kpi">
            <div class="muted small font-bold" style="text-transform:uppercase;">Closing Status</div>
            <div class="payroll-kpi-val" style="font-size:20px; margin-top:10px;">
                ${payroll.status == 'LOCKED' ? 'Finalized &amp; Locked' : 'Draft Review'}
            </div>
        </div>
    </div>

    <!-- 4. PAYROLL DETAILS TABLE (FR-PAY-02) -->
    <div class="table-wrap" style="margin-bottom:24px;">
        <table class="table">
            <thead>
                <tr>
                    <th>Emp Code</th>
                    <th>Full Name</th>
                    <th>Department</th>
                    <th>Base Salary</th>
                    <th>Regular Hours</th>
                    <th>OT Hours</th>
                    <th>Night Hours</th>
                    <th>Late Penalty</th>
                    <th>Net Salary</th>
                    <th>Email Status</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <c:choose>
                    <c:when test="${empty details}">
                        <tr><td colspan="11" class="empty">No payroll breakdown data available.</td></tr>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="d" items="${details}">
                            <tr>
                                <td class="mono font-bold">${d.employeeCode}</td>
                                <td><strong><c:out value="${d.employeeName}"/></strong></td>
                                <td><c:out value="${d.department}"/></td>
                                <td class="mono"><fmt:formatNumber value="${d.baseSalary}" pattern="#,##0"/></td>
                                <td class="mono">${d.regularHours}h</td>
                                <td class="mono">
                                    <span title="Weekday: ${d.otWeekdayHours}h, Weekend: ${d.otWeekendHours}h, Holiday: ${d.otHolidayHours}h">
                                        ${d.totalOvertimeHours}h
                                    </span>
                                </td>
                                <td class="mono">${d.nightHours}h</td>
                                <td class="mono" style="color:#dc2626;">
                                    <c:choose>
                                        <c:when test="${d.lateMinutes > 0}">
                                            -${d.penalty} (${d.lateMinutes}m)
                                        </c:when>
                                        <c:otherwise>0</c:otherwise>
                                    </c:choose>
                                </td>
                                <td class="mono font-bold" style="color:#059669; font-size:15px;">
                                    <fmt:formatNumber value="${d.netSalary}" pattern="#,##0"/> VND
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${d.emailStatus == 'SENT'}">
                                            <span class="role-badge" style="background:#dcfce7; color:#15803d; font-size:11px; font-weight:700;" title="Email sent successfully">✔ SENT</span>
                                        </c:when>
                                        <c:when test="${d.emailStatus == 'FAILED'}">
                                            <span class="role-badge" style="background:#fee2e2; color:#b91c1c; font-size:11px; font-weight:700;" title="Failed to deliver or missing email">⚠ FAILED</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="role-badge" style="background:#f1f5f9; color:#64748b; font-size:11px;">Not Sent</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <div style="display:inline-flex; gap:6px; align-items:center;">
                                        <button type="button" class="btn btn-secondary btn-sm"
                                                data-id="${d.employeeId}"
                                                data-code="${d.employeeCode}"
                                                data-name="<c:out value='${d.employeeName}'/>"
                                                data-dept="<c:out value='${d.department}'/>"
                                                data-base="${d.baseSalary}"
                                                data-rate="${d.hourlyRate}"
                                                data-regh="${d.regularHours}"
                                                data-regp="${d.regularPay}"
                                                data-otwdh="${d.otWeekdayHours}"
                                                data-otwdp="${d.otWeekdayPay}"
                                                data-otweh="${d.otWeekendHours}"
                                                data-otwep="${d.otWeekendPay}"
                                                data-otholh="${d.otHolidayHours}"
                                                data-otholp="${d.otHolidayPay}"
                                                data-nighth="${d.nightHours}"
                                                data-nightp="${d.nightAllowance}"
                                                data-nightoth="${d.nightOtHours}"
                                                data-nightotp="${d.nightOtBonus}"
                                                data-latem="${d.lateMinutes}"
                                                data-penalty="${d.penalty}"
                                                data-net="${d.netSalary}"
                                                onclick="openPayslipFromBtn(this)"
                                                title="View payslip breakdown">
                                            👁 View
                                        </button>
                                        <a href="${pageContext.request.contextPath}/admin/payroll/export-pdf?payrollId=${payroll.id}&employeeId=${d.employeeId}" class="btn btn-secondary btn-sm" title="Download PDF payslip">
                                            📄 PDF
                                        </a>
                                        <form method="post" action="${pageContext.request.contextPath}/admin/payroll/send-email" style="display:inline; margin:0;" onsubmit="return confirm('Send payslip email with PDF to employee ${d.employeeName} (${d.employeeEmail})?');">
                                            <input type="hidden" name="payrollId" value="${payroll.id}">
                                            <input type="hidden" name="employeeId" value="${d.employeeId}">
                                            <button type="submit" class="btn btn-secondary btn-sm" title="Email payslip">
                                                📧
                                            </button>
                                        </form>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
            </tbody>
        </table>
    </div>
</c:if>

<!-- Payslip Breakdown Modal -->
<div class="modal-overlay" id="payslipModal" onclick="closePayslipModal(event)">
    <div class="modal-card" onclick="event.stopPropagation()">
        <div style="display:flex; justify-content:space-between; align-items:center; border-bottom:1px solid var(--line); padding-bottom:14px; margin-bottom:16px;">
            <div>
                <h3 style="margin:0; font-size:18px;">Detailed Payslip Breakdown</h3>
                <span class="muted small" id="mPeriod">Month ${month}/${year}</span>
            </div>
            <button type="button" class="btn-ghost btn-sm" onclick="closePayslipModal()">✕ Close</button>
        </div>

        <div style="background:#f8fafc; border-radius:8px; padding:12px 16px; margin-bottom:16px;">
            <div style="font-size:16px; font-weight:700;" id="mName">--</div>
            <div class="muted small" id="mMeta">--</div>
        </div>

        <table class="table" style="font-size:13px; margin-bottom:16px;">
            <tbody>
                <tr>
                    <td>Base Salary</td>
                    <td class="mono font-bold" style="text-align:right;" id="mBase">--</td>
                </tr>
                <tr>
                    <td>Hourly Rate</td>
                    <td class="mono font-bold" style="text-align:right;" id="mRate">--</td>
                </tr>
                <tr>
                    <td>Standard Hours Pay (<span id="mRegH"></span> hrs)</td>
                    <td class="mono font-bold" style="text-align:right;" id="mRegPay">--</td>
                </tr>
                <tr>
                    <td>Weekday Overtime 150% (<span id="mOtWdH"></span> hrs)</td>
                    <td class="mono font-bold" style="text-align:right;" id="mOtWdPay">--</td>
                </tr>
                <tr>
                    <td>Weekend Overtime 200% (<span id="mOtWeH"></span> hrs)</td>
                    <td class="mono font-bold" style="text-align:right;" id="mOtWePay">--</td>
                </tr>
                <tr>
                    <td>Holiday Overtime 300% (<span id="mOtHolH"></span> hrs)</td>
                    <td class="mono font-bold" style="text-align:right;" id="mOtHolPay">--</td>
                </tr>
                <tr>
                    <td>Night Shift Differential +30% (<span id="mNightH"></span> hrs)</td>
                    <td class="mono font-bold" style="text-align:right;" id="mNightPay">--</td>
                </tr>
                <tr>
                    <td>Night Overtime Bonus +20% (<span id="mNightOtH"></span> hrs)</td>
                    <td class="mono font-bold" style="text-align:right;" id="mNightOtPay">--</td>
                </tr>
                <tr style="color:#dc2626;">
                    <td>Late Penalty Deduction (<span id="mLateM"></span> mins)</td>
                    <td class="mono font-bold" style="text-align:right;" id="mPenalty">--</td>
                </tr>
                <tr style="background:#ecfdf5; font-size:16px; font-weight:800; color:#065f46;">
                    <td>NET SALARY (TAKE-HOME)</td>
                    <td class="mono" style="text-align:right;" id="mNet">--</td>
                </tr>
            </tbody>
        </table>

        <div style="display:flex; justify-content:flex-end; gap:10px; margin-top:20px;">
            <a id="mPdfBtn" href="#" class="btn btn-primary btn-sm" style="display:inline-flex; align-items:center; gap:6px;">
                📄 Download Payslip PDF
            </a>
            <button type="button" class="btn btn-secondary btn-sm" onclick="closePayslipModal()">Close</button>
        </div>
    </div>
</div>

<script>
    function fmtNum(n) {
        if (n === null || n === undefined || n === '') return '0';
        return Number(n).toLocaleString('en-US');
    }

    function setTxt(id, val) {
        const el = document.getElementById(id);
        if (el) el.textContent = val;
    }

    function openPayslipFromBtn(btn) {
        if (!btn || !btn.dataset) return;
        const d = btn.dataset;
        showPayslipModal(
            d.id, d.code, d.name, d.dept,
            d.base, d.rate,
            d.regh, d.regp,
            d.otwdh, d.otwdp,
            d.otweh, d.otwep,
            d.otholh, d.otholp,
            d.nighth, d.nightp,
            d.nightoth, d.nightotp,
            d.latem, d.penalty, d.net
        );
    }

    function showPayslipModal(id, code, name, dept, base, rate, regH, regP, otWdH, otWdP, otWeH, otWeP, otHolH, otHolP, nightH, nightP, nightOtH, nightOtP, lateM, penalty, net) {
        setTxt('mName', name || '--');
        setTxt('mMeta', (code || '') + (dept ? ' · ' + dept : ''));

        setTxt('mBase', fmtNum(base) + ' VND');
        setTxt('mRate', fmtNum(rate) + ' VND/h');

        setTxt('mRegH', regH || '0');
        setTxt('mRegPay', fmtNum(regP) + ' VND');

        setTxt('mOtWdH', otWdH || '0');
        setTxt('mOtWdPay', fmtNum(otWdP) + ' VND');

        setTxt('mOtWeH', otWeH || '0');
        setTxt('mOtWePay', fmtNum(otWeP) + ' VND');
        setTxt('mOtWeP', fmtNum(otWeP) + ' VND'); // Fallback alias

        setTxt('mOtHolH', otHolH || '0');
        setTxt('mOtHolPay', fmtNum(otHolP) + ' VND');

        setTxt('mNightH', nightH || '0');
        setTxt('mNightPay', fmtNum(nightP) + ' VND');

        setTxt('mNightOtH', nightOtH || '0');
        setTxt('mNightOtPay', fmtNum(nightOtP) + ' VND');

        setTxt('mLateM', lateM || '0');
        setTxt('mPenalty', '-' + fmtNum(penalty) + ' VND');

        setTxt('mNet', fmtNum(net) + ' VND');

        const pdfBtn = document.getElementById('mPdfBtn');
        if (pdfBtn) {
            pdfBtn.href = '${pageContext.request.contextPath}/admin/payroll/export-pdf?payrollId=${payroll.id}&employeeId=' + id;
        }

        const modal = document.getElementById('payslipModal');
        if (modal) {
            modal.classList.add('active');
            modal.style.display = 'flex';
        }
    }

    function closePayslipModal(e) {
        const modal = document.getElementById('payslipModal');
        if (modal) {
            modal.classList.remove('active');
            modal.style.display = 'none';
        }
    }

    // Global ESC listener to close payslip modal
    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape') {
            closePayslipModal();
        }
    });
</script>

<%@include file="/WEB-INF/views/common/footer.jspf"%>
