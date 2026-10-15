<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="pageTitle" value="Attendance & Timesheet"/>
<c:set var="activeNav" value="attendance"/>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<%@ include file="/WEB-INF/views/common/header.jspf" %>

<div style="margin-bottom: 24px;">
    <div style="display: flex; justify-content: space-between; align-items: flex-start; flex-wrap: wrap; gap: 12px;">
        <div>
            <h1 style="margin: 0; font-size: 22px;">📋 Attendance &amp; Timesheet Management</h1>
            <p class="muted" style="margin: 4px 0 0 0;">
                Live biometric scan logs, automated shift detection, late/early penalties, and missing checkout handling (FR-ATT-01..06)
            </p>
        </div>
    </div>
</div>

<!-- Filter Bar -->
<div class="card" style="margin-bottom: 20px; padding: 16px;">
    <form action="${ctx}/admin/attendance" method="get" id="filterForm" style="display: flex; flex-wrap: wrap; gap: 14px; align-items: flex-end;">
        <div>
            <label style="display:block; font-size:12px; font-weight:600; margin-bottom:4px; color:var(--text-muted);">FROM DATE</label>
            <input type="date" name="from" value="${from}" style="padding: 7px 10px; border: 1px solid var(--line); border-radius: 6px; font-size: 13px;">
        </div>
        <div>
            <label style="display:block; font-size:12px; font-weight:600; margin-bottom:4px; color:var(--text-muted);">TO DATE</label>
            <input type="date" name="to" value="${to}" style="padding: 7px 10px; border: 1px solid var(--line); border-radius: 6px; font-size: 13px;">
        </div>
        <div style="min-width: 180px;">
            <label style="display:block; font-size:12px; font-weight:600; margin-bottom:4px; color:var(--text-muted);">EMPLOYEE</label>
            <select name="employeeId" style="width: 100%; padding: 7px 10px; border: 1px solid var(--line); border-radius: 6px; font-size: 13px;">
                <option value="">-- All Employees --</option>
                <c:forEach var="e" items="${employees}">
                    <option value="${e.id}" ${selectedEmployeeId == e.id ? 'selected' : ''}>
                        <c:out value="${e.code}"/> - <c:out value="${e.fullName}"/>
                    </option>
                </c:forEach>
            </select>
        </div>
        <div style="min-width: 160px;">
            <label style="display:block; font-size:12px; font-weight:600; margin-bottom:4px; color:var(--text-muted);">STATUS</label>
            <select name="status" style="width: 100%; padding: 7px 10px; border: 1px solid var(--line); border-radius: 6px; font-size: 13px;">
                <option value="ALL">-- All Statuses --</option>
                <option value="ON_TIME" ${selectedStatus == 'ON_TIME' ? 'selected' : ''}>🟢 On Time (ON_TIME)</option>
                <option value="LATE" ${selectedStatus == 'LATE' ? 'selected' : ''}>🟡 Late (LATE)</option>
                <option value="EARLY_LEAVE" ${selectedStatus == 'EARLY_LEAVE' ? 'selected' : ''}>🟠 Early Leave (EARLY_LEAVE)</option>
                <option value="MISSING_CHECKOUT" ${selectedStatus == 'MISSING_CHECKOUT' ? 'selected' : ''}>🔴 Missing Checkout (MISSING_CHECKOUT)</option>
                <option value="ABSENT" ${selectedStatus == 'ABSENT' ? 'selected' : ''}>⚪ Absent (ABSENT)</option>
                <option value="OVERTIME" ${selectedStatus == 'OVERTIME' ? 'selected' : ''}>🟣 Overtime (OVERTIME)</option>
            </select>
        </div>
        <div style="display:flex; gap: 8px;">
            <button type="submit" class="btn btn-primary" style="padding: 7px 16px; font-size: 13px;">🔍 Filter</button>
            <button type="button" class="btn btn-ghost" style="padding: 7px 12px; font-size: 13px;" onclick="setToday()">Today</button>
            <button type="button" class="btn btn-ghost" style="padding: 7px 12px; font-size: 13px;" onclick="setThisMonth()">This Month</button>
        </div>
    </form>
</div>

<!-- KPI Stats Cards -->
<div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(130px, 1fr)); gap: 12px; margin-bottom: 20px;">
    <div class="card" style="padding: 12px 14px; text-align: center; border-left: 4px solid var(--line);">
        <div class="muted small">Total Records</div>
        <div style="font-size: 20px; font-weight: 700; margin-top: 2px;">${totalRecords}</div>
    </div>
    <div class="card" style="padding: 12px 14px; text-align: center; border-left: 4px solid #10b981;">
        <div class="muted small" style="color:#059669;">On Time</div>
        <div style="font-size: 20px; font-weight: 700; margin-top: 2px; color:#059669;">${onTimeCount}</div>
    </div>
    <div class="card" style="padding: 12px 14px; text-align: center; border-left: 4px solid #f59e0b;">
        <div class="muted small" style="color:#d97706;">Late</div>
        <div style="font-size: 20px; font-weight: 700; margin-top: 2px; color:#d97706;">${lateCount}</div>
    </div>
    <div class="card" style="padding: 12px 14px; text-align: center; border-left: 4px solid #f97316;">
        <div class="muted small" style="color:#ea580c;">Early Leave</div>
        <div style="font-size: 20px; font-weight: 700; margin-top: 2px; color:#ea580c;">${earlyLeaveCount}</div>
    </div>
    <div class="card" style="padding: 12px 14px; text-align: center; border-left: 4px solid #ef4444; background: ${missingCheckoutCount > 0 ? '#fef2f2' : 'inherit'};">
        <div class="muted small" style="color:#dc2626; font-weight: ${missingCheckoutCount > 0 ? '600' : 'normal'};">Missing Checkout</div>
        <div style="font-size: 20px; font-weight: 700; margin-top: 2px; color:#dc2626;">${missingCheckoutCount}</div>
    </div>
    <div class="card" style="padding: 12px 14px; text-align: center; border-left: 4px solid #8b5cf6;">
        <div class="muted small" style="color:#7c3aed;">Overtime</div>
        <div style="font-size: 20px; font-weight: 700; margin-top: 2px; color:#7c3aed;">${overtimeCount}</div>
    </div>
    <div class="card" style="padding: 12px 14px; text-align: center; border-left: 4px solid #94a3b8;">
        <div class="muted small">Absent</div>
        <div style="font-size: 20px; font-weight: 700; margin-top: 2px; color:#64748b;">${absentCount}</div>
    </div>
</div>

<c:if test="${missingCheckoutCount > 0}">
    <div class="alert alert-warning" style="margin-bottom: 20px; font-size: 13px;">
        ⚠️ <strong>Warning:</strong> There are <strong>${missingCheckoutCount}</strong> record(s) without checkout 2 hours after shift ended (FR-ATT-04). Administrators can click <strong>✏️ Edit</strong> to provide checkout time with reason.
    </div>
</c:if>

<!-- Attendance Table -->
<div class="card" style="overflow-x: auto; padding: 0;">
    <table class="table" style="width: 100%; border-collapse: collapse; margin: 0;">
        <thead>
            <tr style="background: var(--bg-hover); text-align: left; font-size: 12px; color: var(--text-muted); border-bottom: 1px solid var(--line);">
                <th style="padding: 12px 14px;">DATE</th>
                <th style="padding: 12px 14px;">EMPLOYEE</th>
                <th style="padding: 12px 14px;">SHIFT</th>
                <th style="padding: 12px 14px;">CHECK-IN</th>
                <th style="padding: 12px 14px;">CHECK-OUT</th>
                <th style="padding: 12px 14px;">DURATION</th>
                <th style="padding: 12px 14px;">STATUS</th>
                <th style="padding: 12px 14px; text-align: right;">ACTIONS</th>
            </tr>
        </thead>
        <tbody>
            <c:choose>
                <c:when test="${empty attendances}">
                    <tr>
                        <td colspan="8" style="text-align: center; padding: 40px; color: var(--text-muted);">
                            No attendance records match the current filter.
                        </td>
                    </tr>
                </c:when>
                <c:otherwise>
                    <c:forEach var="a" items="${attendances}">
                        <tr style="border-bottom: 1px solid var(--line); font-size: 13px;">
                            <td style="padding: 12px 14px; font-weight: 500; white-space: nowrap;">
                                <c:out value="${a.workDate}"/>
                            </td>
                            <td style="padding: 12px 14px;">
                                <div style="font-weight: 600;"><c:out value="${a.employeeName}"/></div>
                                <div class="muted small"><c:out value="${a.employeeCode}"/> · <c:out value="${a.department}"/></div>
                            </td>
                            <td style="padding: 12px 14px;">
                                <div style="font-weight: 500;"><c:out value="${a.shiftName}"/></div>
                                <div class="muted small"><c:out value="${a.shiftStartTime}"/> - <c:out value="${a.shiftEndTime}"/></div>
                            </td>
                            <td style="padding: 12px 14px; font-family: monospace; font-size: 13px;">
                                <c:choose>
                                    <c:when test="${not empty a.checkIn}">
                                        <span style="color:#059669; font-weight:600;"><c:out value="${a.formattedCheckInTime}"/></span>
                                    </c:when>
                                    <c:otherwise><span class="muted">--:--</span></c:otherwise>
                                </c:choose>
                            </td>
                            <td style="padding: 12px 14px; font-family: monospace; font-size: 13px;">
                                <c:choose>
                                    <c:when test="${not empty a.checkOut}">
                                        <span style="color:#2563eb; font-weight:600;"><c:out value="${a.formattedCheckOutTime}"/></span>
                                    </c:when>
                                    <c:otherwise>
                                        <c:if test="${a.status == 'MISSING_CHECKOUT'}">
                                            <span style="color:#dc2626; font-weight:600;">Missing Out ⚠️</span>
                                        </c:if>
                                        <c:if test="${a.status != 'MISSING_CHECKOUT'}">
                                            <span class="muted">--:--</span>
                                        </c:if>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td style="padding: 12px 14px; font-weight: 500;">
                                <c:out value="${a.formattedWorkedHours}"/>
                                <c:if test="${a.workedMinutes > 0}">
                                    <span class="muted small">(${a.workedMinutes}m)</span>
                                </c:if>
                            </td>
                            <td style="padding: 12px 14px;">
                                <span class="badge badge-${a.statusBadgeClass}" style="padding: 4px 8px; border-radius: 4px; font-size: 11px; font-weight: 600;">
                                    <c:out value="${a.statusLabel}"/>
                                </span>
                            </td>
                            <td style="padding: 12px 14px; text-align: right; white-space: nowrap;">
                                <button type="button" class="btn btn-sm btn-ghost" 
                                        onclick="openEditModal(${a.id}, '<c:out value="${a.employeeName}"/>', '<c:out value="${a.employeeCode}"/>', '<c:out value="${a.shiftName}"/>', '<c:out value="${a.workDate}"/>', '<c:out value="${a.formattedCheckInDateTime}"/>', '<c:out value="${a.formattedCheckOutDateTime}"/>', '${a.status}', ${a.workedMinutes})"
                                        style="margin-right: 4px;" title="Adjust record with audit trail">
                                    ✏️ Edit
                                </button>
                                <button type="button" class="btn btn-sm btn-ghost" onclick="viewAuditLog(${a.id})" title="View audit trail history">
                                    📜 History
                                </button>
                            </td>
                        </tr>
                    </c:forEach>
                </c:otherwise>
            </c:choose>
        </tbody>
    </table>
</div>

<!-- ================= Edit Attendance Modal ================= -->
<div id="editModal" style="display:none; position:fixed; z-index:9999; inset:0; background:rgba(0,0,0,0.5); align-items:center; justify-content:center;">
    <div class="card" style="width: 520px; max-width: 95vw; background:var(--bg-card); border-radius:10px; padding:24px; box-shadow: 0 20px 25px -5px rgba(0,0,0,0.2);">
        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:16px;">
            <h3 style="margin:0; font-size:17px;">✏️ Adjust Attendance Record (FR-ATT-05)</h3>
            <button type="button" onclick="closeEditModal()" style="background:none; border:none; font-size:20px; cursor:pointer; color:var(--text-muted);">&times;</button>
        </div>

        <form action="${ctx}/admin/attendance" method="post">
            <input type="hidden" name="id" id="modalId">
            <input type="hidden" name="from" value="${from}">
            <input type="hidden" name="to" value="${to}">

            <!-- Info Bar -->
            <div style="background:var(--bg-hover); padding:10px 14px; border-radius:6px; margin-bottom:16px; font-size:13px;">
                <div><strong>Employee:</strong> <span id="modalEmpDisplay"></span></div>
                <div style="margin-top:2px;"><strong>Shift:</strong> <span id="modalShiftDisplay"></span> · <strong>Date:</strong> <span id="modalDateDisplay"></span></div>
            </div>

            <div style="display:grid; grid-template-columns: 1fr 1fr; gap:12px; margin-bottom:12px;">
                <div>
                    <label style="display:block; font-size:12px; font-weight:600; margin-bottom:4px;">CHECK-IN TIME</label>
                    <input type="datetime-local" name="checkIn" id="modalCheckIn" style="width:100%; padding:8px 10px; border:1px solid var(--line); border-radius:6px; font-size:13px;">
                </div>
                <div>
                    <label style="display:block; font-size:12px; font-weight:600; margin-bottom:4px;">CHECK-OUT TIME</label>
                    <input type="datetime-local" name="checkOut" id="modalCheckOut" style="width:100%; padding:8px 10px; border:1px solid var(--line); border-radius:6px; font-size:13px;">
                </div>
            </div>

            <div style="display:grid; grid-template-columns: 1fr 1fr; gap:12px; margin-bottom:12px;">
                <div>
                    <label style="display:block; font-size:12px; font-weight:600; margin-bottom:4px;">STATUS</label>
                    <select name="status" id="modalStatus" style="width:100%; padding:8px 10px; border:1px solid var(--line); border-radius:6px; font-size:13px;">
                        <option value="ON_TIME">On Time (ON_TIME)</option>
                        <option value="LATE">Late (LATE)</option>
                        <option value="EARLY_LEAVE">Early Leave (EARLY_LEAVE)</option>
                        <option value="MISSING_CHECKOUT">Missing Checkout (MISSING_CHECKOUT)</option>
                        <option value="OVERTIME">Overtime (OVERTIME)</option>
                        <option value="ABSENT">Absent (ABSENT)</option>
                    </select>
                </div>
                <div>
                    <label style="display:block; font-size:12px; font-weight:600; margin-bottom:4px;">WORKED MINUTES</label>
                    <input type="number" name="workedMinutes" id="modalWorkedMinutes" placeholder="Calculated automatically if left blank" min="0" style="width:100%; padding:8px 10px; border:1px solid var(--line); border-radius:6px; font-size:13px;">
                </div>
            </div>

            <div style="margin-bottom:16px;">
                <label style="display:block; font-size:12px; font-weight:600; margin-bottom:4px; color:#dc2626;">
                    ADJUSTMENT REASON <span style="color:red;">* (Required by FR-ATT-05)</span>
                </label>
                <textarea name="reason" id="modalReason" required rows="3" style="width:100%; padding:8px 10px; border:1px solid var(--line); border-radius:6px; font-size:13px;"
                          placeholder="E.g., Employee forgot to scan out due to emergency meeting, manager confirmed worked until 18:00..."></textarea>
                <span class="muted small" style="display:block; margin-top:4px;">
                    ⚠️ This reason and the administrator identity will be recorded in the Audit Log.
                </span>
            </div>

            <div style="display:flex; justify-content:flex-end; gap:8px;">
                <button type="button" class="btn btn-ghost" onclick="closeEditModal()">Cancel</button>
                <button type="submit" class="btn btn-primary">💾 Save Adjustment</button>
            </div>
        </form>
    </div>
</div>

<!-- ================= Audit Log Modal ================= -->
<div id="auditModal" style="display:none; position:fixed; z-index:9999; inset:0; background:rgba(0,0,0,0.5); align-items:center; justify-content:center;">
    <div class="card" style="width: 650px; max-width: 95vw; background:var(--bg-card); border-radius:10px; padding:24px; box-shadow: 0 20px 25px -5px rgba(0,0,0,0.2);">
        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:16px;">
            <h3 style="margin:0; font-size:17px;">📜 Audit Trail History (Audit Log)</h3>
            <button type="button" onclick="closeAuditModal()" style="background:none; border:none; font-size:20px; cursor:pointer; color:var(--text-muted);">&times;</button>
        </div>

        <div id="auditLoading" style="text-align:center; padding:20px; color:var(--text-muted);">Loading audit trail records...</div>
        <div id="auditContent" style="display:none; max-height: 400px; overflow-y:auto;">
            <table class="table" style="width:100%; font-size:12px;">
                <thead>
                    <tr style="background:var(--bg-hover); text-align:left;">
                        <th style="padding:8px 10px;">TIMESTAMP</th>
                        <th style="padding:8px 10px;">MODIFIED BY</th>
                        <th style="padding:8px 10px;">REASON</th>
                        <th style="padding:8px 10px;">CHANGES</th>
                    </tr>
                </thead>
                <tbody id="auditTableBody"></tbody>
            </table>
        </div>

        <div style="margin-top:16px; text-align:right;">
            <button type="button" class="btn btn-ghost" onclick="closeAuditModal()">Close</button>
        </div>
    </div>
</div>

<script>
function setToday() {
    const today = new Date().toISOString().split('T')[0];
    document.querySelector('input[name="from"]').value = today;
    document.querySelector('input[name="to"]').value = today;
    document.getElementById('filterForm').submit();
}

function setThisMonth() {
    const now = new Date();
    const firstDay = new Date(now.getFullYear(), now.getMonth(), 1).toISOString().split('T')[0];
    const today = now.toISOString().split('T')[0];
    document.querySelector('input[name="from"]').value = firstDay;
    document.querySelector('input[name="to"]').value = today;
    document.getElementById('filterForm').submit();
}

function openEditModal(id, empName, empCode, shiftName, workDate, checkIn, checkOut, status, workedMinutes) {
    document.getElementById('modalId').value = id;
    document.getElementById('modalEmpDisplay').innerText = empName + ' (' + empCode + ')';
    document.getElementById('modalShiftDisplay').innerText = shiftName;
    document.getElementById('modalDateDisplay').innerText = workDate;
    document.getElementById('modalCheckIn').value = checkIn || '';
    document.getElementById('modalCheckOut').value = checkOut || '';
    document.getElementById('modalStatus').value = status || 'ON_TIME';
    document.getElementById('modalWorkedMinutes').value = workedMinutes || '';
    document.getElementById('modalReason').value = '';

    const modal = document.getElementById('editModal');
    modal.style.display = 'flex';
}

function closeEditModal() {
    document.getElementById('editModal').style.display = 'none';
}

function viewAuditLog(recordId) {
    const modal = document.getElementById('auditModal');
    modal.style.display = 'flex';
    document.getElementById('auditLoading').style.display = 'block';
    document.getElementById('auditContent').style.display = 'none';

    fetch('${ctx}/admin/attendance?action=audit&recordId=' + recordId)
        .then(res => res.json())
        .then(logs => {
            document.getElementById('auditLoading').style.display = 'none';
            document.getElementById('auditContent').style.display = 'block';
            const tbody = document.getElementById('auditTableBody');
            tbody.innerHTML = '';

            if (!logs || logs.length === 0) {
                tbody.innerHTML = '<tr><td colspan="4" style="text-align:center; padding:20px; color:var(--text-muted);">No adjustments recorded for this entry (no audit logs).</td></tr>';
                return;
            }

            logs.forEach(l => {
                const tr = document.createElement('tr');
                tr.style.borderBottom = '1px solid var(--line)';
                tr.innerHTML = 
                    '<td style="padding:8px 10px; font-weight:500; white-space:nowrap;">' + l.time + '</td>' +
                    '<td style="padding:8px 10px; font-weight:600; color:var(--primary);">' + l.admin + '</td>' +
                    '<td style="padding:8px 10px; color:#b45309;">' + (l.reason || '-') + '</td>' +
                    '<td style="padding:8px 10px; font-family:monospace; font-size:11px;">' +
                        '<div style="color:#dc2626;">- ' + (l.oldValue || '') + '</div>' +
                        '<div style="color:#059669; margin-top:2px;">+ ' + (l.newValue || '') + '</div>' +
                    '</td>';
                tbody.appendChild(tr);
            });
        })
        .catch(err => {
            document.getElementById('auditLoading').innerText = 'Error loading audit log: ' + err;
        });
}

function closeAuditModal() {
    document.getElementById('auditModal').style.display = 'none';
}
</script>

<%@ include file="/WEB-INF/views/common/footer.jspf" %>
