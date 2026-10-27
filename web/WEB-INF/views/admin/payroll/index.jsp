<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="pageTitle" value="Payroll & payslips"/>
<c:set var="activeNav" value="payroll"/>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<%@ include file="/WEB-INF/views/common/header.jspf" %>

<style>
    /* Payroll run for one month (FR-PAY-01..06). Shared look comes from app.css (pg-header, panel, data-table, summary, steps). */
    .period-picker {
        display: flex;
        align-items: center;
        gap: 8px;
    }
    .period-picker select { height: 36px; padding: 0 30px 0 12px; font-size: 13px; }
    .period-picker .period-month { width: 140px; }
    .period-picker .period-year { width: 96px; }

    .run-status { display: flex; align-items: center; gap: 12px; flex-wrap: wrap; }
    .run-actions { display: flex; gap: 8px; flex-wrap: wrap; }
    .run-actions form { margin: 0; }

    .missing-panel { border-color: #fcd9a8; }
    .missing-panel .panel-head { background: #fff8eb; border-bottom-color: #fcd9a8; border-radius: 8px 8px 0 0; }
    .missing-panel .panel-head h2 { color: #92400e; }
    .missing-panel .panel-head p { color: #92400e; }

    .row-actions { display: inline-flex; gap: 6px; }
    .row-actions form { margin: 0; display: inline-flex; }
    .muted-zero { color: #9ca3af; }

    /* Payslip popup */
    .modal-overlay {
        display: none;
        position: fixed;
        inset: 0;
        background: rgba(17, 24, 39, 0.55);
        z-index: 9999;
        justify-content: center;
        align-items: center;
        padding: 20px;
    }
    .modal-overlay.active { display: flex; }
    .slip-modal {
        background: #ffffff;
        border-radius: 8px;
        width: 100%;
        max-width: 560px;
        max-height: calc(100vh - 40px);
        display: flex;
        flex-direction: column;
        box-shadow: 0 20px 40px rgba(0, 0, 0, 0.2);
    }
    .slip-head {
        display: flex;
        justify-content: space-between;
        align-items: flex-start;
        padding: 16px 20px;
        border-bottom: 1px solid var(--border);
    }
    .slip-head h3 { font-size: 16px; margin: 0; }
    .slip-close { background: none; border: none; font-size: 22px; line-height: 1; cursor: pointer; color: var(--muted); padding: 2px 6px; }
    .slip-close:hover { color: var(--text); }
    .slip-body { padding: 16px 20px; overflow-y: auto; }
    .slip-who { display: flex; justify-content: space-between; gap: 16px; padding-bottom: 14px; margin-bottom: 6px; border-bottom: 1px solid var(--border); }
    .slip-who-name { font-size: 15px; font-weight: 600; color: var(--text); }
    .slip-section { font-size: 12px; font-weight: 600; color: var(--muted); margin: 14px 0 4px; }
    .slip-line { display: flex; justify-content: space-between; gap: 16px; padding: 7px 0; border-bottom: 1px dashed #e5e7eb; font-size: 13px; }
    .slip-line span:last-child { font-variant-numeric: tabular-nums; color: var(--text); font-weight: 500; white-space: nowrap; }
    .slip-line .hrs { color: var(--muted); }
    .slip-line.minus span:last-child { color: #b91c1c; }
    .slip-net { display: flex; justify-content: space-between; align-items: baseline; margin-top: 14px; padding-top: 12px; border-top: 2px solid var(--text); }
    .slip-net span:first-child { font-weight: 600; color: var(--text); }
    .slip-net strong { font-size: 20px; color: #15803d; font-variant-numeric: tabular-nums; }
    .slip-foot { display: flex; justify-content: flex-end; gap: 8px; padding: 12px 20px; border-top: 1px solid var(--border); background: #fafbfc; border-radius: 0 0 8px 8px; }
</style>

<%-- ---------- Derived state for this month's run ---------- --%>
<c:set var="hasMissing" value="${not empty missingCheckouts}"/>
<c:set var="generated" value="${not empty payroll}"/>
<c:set var="locked" value="${generated && payroll.locked}"/>
<c:set var="detailCount" value="${empty details ? 0 : details.size()}"/>
<c:set var="sentCount" value="0"/>
<c:set var="sumOtPay" value="0"/>
<c:set var="sumPenalty" value="0"/>
<c:set var="sumBase" value="0"/>
<c:forEach var="d" items="${details}">
    <c:if test="${d.emailStatus == 'SENT'}"><c:set var="sentCount" value="${sentCount + 1}"/></c:if>
    <c:set var="sumOtPay" value="${sumOtPay + d.totalOvertimePay}"/>
    <c:set var="sumPenalty" value="${sumPenalty + d.penalty}"/>
    <c:set var="sumBase" value="${sumBase + d.baseSalary}"/>
</c:forEach>
<c:set var="monthNames" value="January,February,March,April,May,June,July,August,September,October,November,December"/>
<c:forTokens var="mn" items="${monthNames}" delims="," varStatus="st">
    <c:if test="${st.count == month}"><c:set var="monthName" value="${mn}"/></c:if>
</c:forTokens>

<!-- Page header + period picker -->
<div class="pg-header">
    <div class="pg-header-text">
        <h1>Payroll &amp; payslips</h1>
        <p>Calculate the month's salaries from attendance, check them, lock the payroll, and send PDF payslips.</p>
    </div>
    <form method="get" action="${ctx}/admin/payroll" class="period-picker" aria-label="Payroll period">
        <select name="month" class="period-month" aria-label="Month">
            <c:forTokens var="mn" items="${monthNames}" delims="," varStatus="st">
                <option value="${st.count}" ${st.count == month ? 'selected' : ''}>${mn}</option>
            </c:forTokens>
        </select>
        <select name="year" class="period-year" aria-label="Year">
            <c:forEach var="y" begin="${year - 3}" end="${year + 1}">
                <option value="${y}" ${y == year ? 'selected' : ''}>${y}</option>
            </c:forEach>
        </select>
        <button type="submit" class="btn btn-secondary">Show</button>
    </form>
</div>

<!-- Run status: where this month's payroll stands, and what to do next -->
<section class="panel">
    <div class="panel-head">
        <div class="run-status">
            <h2>${monthName} ${year} payroll</h2>
            <c:choose>
                <c:when test="${locked}"><span class="status-text status-ok">Locked</span></c:when>
                <c:when test="${generated}"><span class="status-text status-warn">Draft &ndash; not locked yet</span></c:when>
                <c:otherwise><span class="status-text status-neutral">Not calculated</span></c:otherwise>
            </c:choose>
        </div>
        <div class="run-actions">
            <c:if test="${not locked}">
                <form method="post" action="${ctx}/admin/payroll">
                    <input type="hidden" name="action" value="generate">
                    <input type="hidden" name="month" value="${month}">
                    <input type="hidden" name="year" value="${year}">
                    <button type="submit" class="btn ${generated ? 'btn-secondary' : 'btn-primary'}"
                            ${hasMissing ? 'disabled title="Fix the missing check-outs first"' : ''}>
                        ${generated ? 'Recalculate' : 'Calculate payroll'}
                    </button>
                </form>
            </c:if>
            <c:if test="${generated && not locked}">
                <form method="post" action="${ctx}/admin/payroll" onsubmit="return confirm('Lock the ${monthName} ${year} payroll? Salary figures cannot be changed after locking.');">
                    <input type="hidden" name="action" value="lock">
                    <input type="hidden" name="payrollId" value="${payroll.id}">
                    <input type="hidden" name="month" value="${month}">
                    <input type="hidden" name="year" value="${year}">
                    <button type="submit" class="btn btn-primary">Lock payroll</button>
                </form>
            </c:if>
            <c:if test="${generated && detailCount > 0}">
                <a href="${ctx}/admin/payroll/export-pdf?payrollId=${payroll.id}" class="btn btn-secondary">Export all PDFs</a>
                <form method="post" action="${ctx}/admin/payroll/send-email" onsubmit="return confirm('Email PDF payslips to all ${payroll.totalEmployees} employees for ${monthName} ${year}?');">
                    <input type="hidden" name="payrollId" value="${payroll.id}">
                    <input type="hidden" name="sendAll" value="true">
                    <button type="submit" class="btn ${locked ? 'btn-primary' : 'btn-secondary'}">Email all payslips</button>
                </form>
            </c:if>
        </div>
    </div>

    <div class="steps">
        <div class="step-item ${hasMissing ? 'is-blocked' : 'is-done'}">
            <span class="step-num">1</span>
            <div>
                <div class="step-name">Fix missing check-outs</div>
                <div class="step-state"><c:choose><c:when test="${hasMissing}">${missingCheckouts.size()} to fix before calculating</c:when><c:otherwise>All check-outs recorded</c:otherwise></c:choose></div>
            </div>
        </div>
        <div class="step-item ${generated ? 'is-done' : (hasMissing ? 'is-todo' : 'is-current')}">
            <span class="step-num">2</span>
            <div>
                <div class="step-name">Calculate payroll</div>
                <div class="step-state"><c:choose><c:when test="${generated}">Calculated for ${payroll.totalEmployees} employees</c:when><c:otherwise>Not calculated yet</c:otherwise></c:choose></div>
            </div>
        </div>
        <div class="step-item ${locked ? 'is-done' : (generated ? 'is-current' : 'is-todo')}">
            <span class="step-num">3</span>
            <div>
                <div class="step-name">Review &amp; lock</div>
                <div class="step-state">${locked ? 'Locked; figures are final' : (generated ? 'Check the register below, then lock' : 'After calculating')}</div>
            </div>
        </div>
        <div class="step-item ${detailCount > 0 && sentCount == detailCount ? 'is-done' : (locked ? 'is-current' : 'is-todo')}">
            <span class="step-num">4</span>
            <div>
                <div class="step-name">Send payslips</div>
                <div class="step-state"><c:choose><c:when test="${detailCount > 0}">${sentCount} of ${detailCount} emailed</c:when><c:otherwise>After locking</c:otherwise></c:choose></div>
            </div>
        </div>
    </div>
</section>

<!-- Missing check-outs block the run (FR-PAY-03) -->
<c:if test="${hasMissing}">
    <section class="panel missing-panel">
        <div class="panel-head">
            <div>
                <h2>Missing check-outs <span class="count">(${missingCheckouts.size()})</span></h2>
                <p>Payroll can't be calculated until each of these has a check-out time. Fix them on the Attendance page; every change needs a reason.</p>
            </div>
        </div>
        <div class="panel-scroll">
            <table class="data-table">
                <thead>
                    <tr>
                        <th>Employee</th>
                        <th>Department</th>
                        <th>Work date</th>
                        <th>Shift</th>
                        <th>Checked in</th>
                        <th></th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="mc" items="${missingCheckouts}">
                        <tr>
                            <td>
                                <div class="cell-title"><c:out value="${mc.employeeName}"/></div>
                                <div class="cell-sub"><c:out value="${mc.employeeCode}"/></div>
                            </td>
                            <td><c:out value="${mc.department}"/></td>
                            <td class="nowrap">${mc.workDate}</td>
                            <td><c:out value="${mc.shiftName}"/></td>
                            <td class="nowrap">${mc.formattedCheckIn}</td>
                            <td class="num">
                                <a href="${ctx}/admin/attendance?employeeId=${mc.employeeId}&from=${mc.workDate}&to=${mc.workDate}" class="btn btn-secondary btn-xs">Fix check-out</a>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>
    </section>
</c:if>

<c:if test="${generated}">
    <!-- Totals for the month -->
    <section class="summary" aria-label="Payroll totals">
        <div class="figure">
            <div class="figure-label">Employees</div>
            <div class="figure-value">${payroll.totalEmployees}</div>
            <div class="figure-note">on this payroll</div>
        </div>
        <div class="figure">
            <div class="figure-label">Total net pay</div>
            <div class="figure-value"><fmt:formatNumber value="${payroll.totalNetSalary}" pattern="#,##0"/> <small>VND</small></div>
            <div class="figure-note">to be paid out</div>
        </div>
        <div class="figure">
            <div class="figure-label">Overtime pay</div>
            <div class="figure-value"><fmt:formatNumber value="${sumOtPay}" pattern="#,##0"/> <small>VND</small></div>
            <div class="figure-note">weekday, weekend and holiday</div>
        </div>
        <div class="figure">
            <div class="figure-label">Late penalties</div>
            <div class="figure-value"><fmt:formatNumber value="${sumPenalty}" pattern="#,##0"/> <small>VND</small></div>
            <div class="figure-note">deducted this month</div>
        </div>
        <div class="figure">
            <div class="figure-label">Payslips emailed</div>
            <div class="figure-value">${sentCount} <small>of ${detailCount}</small></div>
            <div class="figure-note">${sentCount == detailCount && detailCount > 0 ? 'all delivered' : 'remaining to send'}</div>
        </div>
    </section>

    <!-- Payroll register (FR-PAY-02) -->
    <section class="panel">
        <div class="panel-head">
            <div>
                <h2>Payroll register <span class="count">(${detailCount})</span></h2>
                <p>Hover over overtime hours for the weekday / weekend / holiday split. Open a row to see the full payslip.</p>
            </div>
        </div>
        <div class="panel-scroll">
            <table class="data-table" style="min-width: 1040px;">
                <thead>
                    <tr>
                        <th>Employee</th>
                        <th class="num">Base salary</th>
                        <th class="num">Regular</th>
                        <th class="num">Overtime</th>
                        <th class="num">Night</th>
                        <th class="num">Late penalty</th>
                        <th class="num">Net pay (VND)</th>
                        <th>Payslip email</th>
                        <th class="num">Payslip</th>
                    </tr>
                </thead>
                <tbody>
                    <c:if test="${detailCount == 0}">
                        <tr><td colspan="9" style="text-align:center; padding:32px; color:var(--muted);">No employees on this payroll.</td></tr>
                    </c:if>
                    <c:forEach var="d" items="${details}">
                        <tr>
                            <td>
                                <div class="cell-title"><c:out value="${d.employeeName}"/></div>
                                <div class="cell-sub"><c:out value="${d.employeeCode}"/> &middot; <c:out value="${d.department}"/></div>
                            </td>
                            <td class="num"><fmt:formatNumber value="${d.baseSalary}" pattern="#,##0"/></td>
                            <td class="num"><fmt:formatNumber value="${d.regularHours}" maxFractionDigits="1"/> h</td>
                            <td class="num">
                                <span class="${d.totalOvertimeHours > 0 ? 'strong' : 'muted-zero'}"
                                      title="Weekday ${d.otWeekdayHours} h, weekend ${d.otWeekendHours} h, holiday ${d.otHolidayHours} h">
                                    <fmt:formatNumber value="${d.totalOvertimeHours}" maxFractionDigits="1"/> h
                                </span>
                            </td>
                            <td class="num ${d.nightHours > 0 ? '' : 'muted-zero'}"><fmt:formatNumber value="${d.nightHours}" maxFractionDigits="1"/> h</td>
                            <td class="num">
                                <c:choose>
                                    <c:when test="${d.lateMinutes > 0}">
                                        <span style="color:#b91c1c;">&minus;<fmt:formatNumber value="${d.penalty}" pattern="#,##0"/></span>
                                        <div class="cell-sub">${d.lateMinutes} min late</div>
                                    </c:when>
                                    <c:otherwise><span class="muted-zero">0</span></c:otherwise>
                                </c:choose>
                            </td>
                            <td class="num strong"><fmt:formatNumber value="${d.netSalary}" pattern="#,##0"/></td>
                            <td>
                                <c:choose>
                                    <c:when test="${d.emailStatus == 'SENT'}"><span class="status-text status-ok">Sent</span></c:when>
                                    <c:when test="${d.emailStatus == 'FAILED'}"><span class="status-text status-bad">Failed</span></c:when>
                                    <c:otherwise><span class="status-text status-neutral">Not sent</span></c:otherwise>
                                </c:choose>
                            </td>
                            <td class="num">
                                <div class="row-actions">
                                    <button type="button" class="btn btn-secondary btn-xs"
                                            data-id="${d.employeeId}"
                                            data-code="<c:out value='${d.employeeCode}'/>"
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
                                            title="View the payslip breakdown">View</button>
                                    <a href="${ctx}/admin/payroll/export-pdf?payrollId=${payroll.id}&employeeId=${d.employeeId}" class="btn btn-secondary btn-xs" title="Download PDF payslip">PDF</a>
                                    <form method="post" action="${ctx}/admin/payroll/send-email" data-who="<c:out value='${d.employeeName} (${d.employeeEmail})'/>" onsubmit="return confirm('Email the payslip to ' + this.dataset.who + '?');">
                                        <input type="hidden" name="payrollId" value="${payroll.id}">
                                        <input type="hidden" name="employeeId" value="${d.employeeId}">
                                        <button type="submit" class="btn btn-secondary btn-xs" title="Email PDF payslip">Email</button>
                                    </form>
                                </div>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
                <c:if test="${detailCount > 0}">
                    <tfoot>
                        <tr>
                            <td>Total &middot; ${detailCount} employees</td>
                            <td class="num"><fmt:formatNumber value="${sumBase}" pattern="#,##0"/></td>
                            <td></td>
                            <td></td>
                            <td></td>
                            <td class="num" style="color:#b91c1c;">&minus;<fmt:formatNumber value="${sumPenalty}" pattern="#,##0"/></td>
                            <td class="num"><fmt:formatNumber value="${payroll.totalNetSalary}" pattern="#,##0"/></td>
                            <td>${sentCount} of ${detailCount} sent</td>
                            <td></td>
                        </tr>
                    </tfoot>
                </c:if>
            </table>
        </div>
    </section>
</c:if>

<c:if test="${not generated && not hasMissing}">
    <section class="panel">
        <div class="panel-body" style="text-align:center; padding:40px 20px;">
            <div class="cell-title" style="font-size:15px;">No payroll for ${monthName} ${year} yet</div>
            <p class="muted" style="margin:6px 0 16px;">Calculate it from this month's attendance. You can recalculate as often as needed until you lock it.</p>
        </div>
    </section>
</c:if>

<!-- Previous runs -->
<c:if test="${not empty history}">
    <section class="panel">
        <div class="panel-head">
            <h2>Payroll history <span class="count">(${history.size()})</span></h2>
        </div>
        <div class="panel-scroll">
            <table class="data-table">
                <thead>
                    <tr>
                        <th>Period</th>
                        <th>Status</th>
                        <th class="num">Employees</th>
                        <th class="num">Net pay (VND)</th>
                        <th class="num"></th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="h" items="${history}">
                        <tr>
                            <td class="cell-title nowrap">
                                <c:forTokens var="mn" items="${monthNames}" delims="," varStatus="st"><c:if test="${st.count == h.month}">${mn}</c:if></c:forTokens> ${h.year}
                                <c:if test="${h.month == month && h.year == year}"><span class="cell-sub">&nbsp;(shown above)</span></c:if>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${h.status == 'LOCKED'}"><span class="status-text status-ok">Locked</span></c:when>
                                    <c:otherwise><span class="status-text status-warn">Draft</span></c:otherwise>
                                </c:choose>
                            </td>
                            <td class="num">${h.totalEmployees}</td>
                            <td class="num"><fmt:formatNumber value="${h.totalNetSalary}" pattern="#,##0"/></td>
                            <td class="num"><a href="${ctx}/admin/payroll?month=${h.month}&year=${h.year}">Open &rarr;</a></td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>
    </section>
</c:if>

<!-- Payslip breakdown popup -->
<div class="modal-overlay" id="payslipModal" onclick="closePayslipModal(event)">
    <div class="slip-modal" role="dialog" aria-modal="true" aria-labelledby="slipTitle" onclick="event.stopPropagation()">
        <div class="slip-head">
            <div>
                <h3 id="slipTitle">Payslip</h3>
                <span class="muted small">${monthName} ${year}</span>
            </div>
            <button type="button" class="slip-close" onclick="closePayslipModal()" aria-label="Close">&times;</button>
        </div>
        <div class="slip-body">
            <div class="slip-who">
                <div>
                    <div class="slip-who-name" id="mName">--</div>
                    <div class="muted small" id="mMeta">--</div>
                </div>
                <div style="text-align:right;">
                    <div class="muted small">Hourly rate</div>
                    <div class="font-bold" id="mRate">--</div>
                </div>
            </div>

            <div class="slip-section">Earnings</div>
            <div class="slip-line"><span>Base salary (monthly)</span><span id="mBase">--</span></div>
            <div class="slip-line"><span>Regular hours <span class="hrs">(<span id="mRegH"></span> h)</span></span><span id="mRegPay">--</span></div>
            <div class="slip-line"><span>Weekday overtime <span class="hrs">(<span id="mOtWdH"></span> h)</span></span><span id="mOtWdPay">--</span></div>
            <div class="slip-line"><span>Weekend overtime <span class="hrs">(<span id="mOtWeH"></span> h)</span></span><span id="mOtWePay">--</span></div>
            <div class="slip-line"><span>Public holiday overtime <span class="hrs">(<span id="mOtHolH"></span> h)</span></span><span id="mOtHolPay">--</span></div>
            <div class="slip-line"><span>Night allowance <span class="hrs">(<span id="mNightH"></span> h)</span></span><span id="mNightPay">--</span></div>
            <div class="slip-line"><span>Night overtime bonus <span class="hrs">(<span id="mNightOtH"></span> h)</span></span><span id="mNightOtPay">--</span></div>

            <div class="slip-section">Deductions</div>
            <div class="slip-line minus"><span>Late penalty <span class="hrs">(<span id="mLateM"></span> min after the grace period)</span></span><span id="mPenalty">--</span></div>

            <div class="slip-net"><span>Net pay</span><strong id="mNet">--</strong></div>
            <p class="muted small" style="margin-top:10px;">Rates are those in the Salary rules when this payroll was calculated.</p>
        </div>
        <div class="slip-foot">
            <button type="button" class="btn btn-secondary" onclick="closePayslipModal()">Close</button>
            <a id="mPdfBtn" href="#" class="btn btn-primary">Download PDF</a>
        </div>
    </div>
</div>

<script>
    function fmtNum(n) {
        if (n === null || n === undefined || n === '') return '0';
        return Math.round(Number(n)).toLocaleString('en-US');
    }
    function fmtHours(n) {
        const v = Number(n) || 0;
        return (Math.round(v * 10) / 10).toLocaleString('en-US');
    }
    function setTxt(id, val) {
        const el = document.getElementById(id);
        if (el) el.textContent = val;
    }

    function openPayslipFromBtn(btn) {
        if (!btn || !btn.dataset) return;
        const d = btn.dataset;
        setTxt('mName', d.name || '--');
        setTxt('mMeta', [d.code, d.dept].filter(Boolean).join(' · '));
        setTxt('mRate', fmtNum(d.rate) + ' VND/h');
        setTxt('mBase', fmtNum(d.base) + ' VND');
        setTxt('mRegH', fmtHours(d.regh));       setTxt('mRegPay', fmtNum(d.regp) + ' VND');
        setTxt('mOtWdH', fmtHours(d.otwdh));     setTxt('mOtWdPay', fmtNum(d.otwdp) + ' VND');
        setTxt('mOtWeH', fmtHours(d.otweh));     setTxt('mOtWePay', fmtNum(d.otwep) + ' VND');
        setTxt('mOtHolH', fmtHours(d.otholh));   setTxt('mOtHolPay', fmtNum(d.otholp) + ' VND');
        setTxt('mNightH', fmtHours(d.nighth));   setTxt('mNightPay', fmtNum(d.nightp) + ' VND');
        setTxt('mNightOtH', fmtHours(d.nightoth)); setTxt('mNightOtPay', fmtNum(d.nightotp) + ' VND');
        setTxt('mLateM', d.latem || '0');
        setTxt('mPenalty', '−' + fmtNum(d.penalty) + ' VND');
        setTxt('mNet', fmtNum(d.net) + ' VND');

        const pdfBtn = document.getElementById('mPdfBtn');
        if (pdfBtn) pdfBtn.href = '${ctx}/admin/payroll/export-pdf?payrollId=${payroll.id}&employeeId=' + encodeURIComponent(d.id);
        document.getElementById('payslipModal').classList.add('active');
    }

    function closePayslipModal(e) {
        if (!e || e.target.id === 'payslipModal') {
            document.getElementById('payslipModal').classList.remove('active');
        }
    }

    document.addEventListener('keydown', function (e) {
        if (e.key === 'Escape') document.getElementById('payslipModal').classList.remove('active');
    });
</script>

<%@ include file="/WEB-INF/views/common/footer.jspf" %>
