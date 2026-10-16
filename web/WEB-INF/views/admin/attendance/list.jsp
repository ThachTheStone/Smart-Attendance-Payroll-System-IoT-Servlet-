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
<div class="card" style="margin-bottom: 20px; padding: 18px 20px;">
    <form action="${ctx}/admin/attendance" method="get" id="filterForm" style="display: flex; flex-wrap: wrap; gap: 14px; align-items: flex-end;">
        <div>
            <label style="display:block; font-size:12px; font-weight:600; margin-bottom:4px; color:var(--text-muted);">FROM DATE</label>
            <input type="date" name="from" value="${from}" style="padding: 8px 12px; border: 1px solid var(--line); border-radius: 8px; font-size: 13px;">
        </div>
        <div>
            <label style="display:block; font-size:12px; font-weight:600; margin-bottom:4px; color:var(--text-muted);">TO DATE</label>
            <input type="date" name="to" value="${to}" style="padding: 8px 12px; border: 1px solid var(--line); border-radius: 8px; font-size: 13px;">
        </div>
        <div style="min-width: 200px; flex: 1;">
            <label style="display:block; font-size:12px; font-weight:600; margin-bottom:4px; color:var(--text-muted);">EMPLOYEE</label>
            <select name="employeeId" style="width: 100%; padding: 8px 12px; border: 1px solid var(--line); border-radius: 8px; font-size: 13px;">
                <option value="">-- All Employees --</option>
                <c:forEach var="e" items="${employees}">
                    <option value="${e.id}" ${selectedEmployeeId == e.id ? 'selected' : ''}>
                        <c:out value="${e.code}"/> - <c:out value="${e.fullName}"/>
                    </option>
                </c:forEach>
            </select>
        </div>
        <div style="min-width: 180px;">
            <label style="display:block; font-size:12px; font-weight:600; margin-bottom:4px; color:var(--text-muted);">STATUS</label>
            <select name="status" style="width: 100%; padding: 8px 12px; border: 1px solid var(--line); border-radius: 8px; font-size: 13px;">
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
            <button type="submit" class="btn btn-primary" style="padding: 8px 18px; font-size: 13px;">🔍 Filter</button>
            <button type="button" class="btn btn-ghost" style="padding: 8px 14px; font-size: 13px;" onclick="setToday()">Today</button>
            <button type="button" class="btn btn-ghost" style="padding: 8px 14px; font-size: 13px;" onclick="setThisMonth()">This Month</button>
        </div>
    </form>
</div>

<!-- KPI Stats Cards -->
<div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(130px, 1fr)); gap: 12px; margin-bottom: 24px;">
    <div class="card" style="padding: 14px 16px; text-align: center; border-left: 4px solid #64748b;">
        <div class="muted small" style="font-weight: 600; text-transform: uppercase;">Total Records</div>
        <div style="font-size: 24px; font-weight: 800; margin-top: 4px; font-family: var(--font-mono, monospace);">${totalRecords}</div>
    </div>
    <div class="card" style="padding: 14px 16px; text-align: center; border-left: 4px solid #10b981;">
        <div class="muted small" style="color:#059669; font-weight: 600; text-transform: uppercase;">On Time</div>
        <div style="font-size: 24px; font-weight: 800; margin-top: 4px; color:#059669; font-family: var(--font-mono, monospace);">${onTimeCount}</div>
    </div>
    <div class="card" style="padding: 14px 16px; text-align: center; border-left: 4px solid #f59e0b;">
        <div class="muted small" style="color:#d97706; font-weight: 600; text-transform: uppercase;">Late</div>
        <div style="font-size: 24px; font-weight: 800; margin-top: 4px; color:#d97706; font-family: var(--font-mono, monospace);">${lateCount}</div>
    </div>
    <div class="card" style="padding: 14px 16px; text-align: center; border-left: 4px solid #f97316;">
        <div class="muted small" style="color:#ea580c; font-weight: 600; text-transform: uppercase;">Early Leave</div>
        <div style="font-size: 24px; font-weight: 800; margin-top: 4px; color:#ea580c; font-family: var(--font-mono, monospace);">${earlyLeaveCount}</div>
    </div>
    <div class="card" style="padding: 14px 16px; text-align: center; border-left: 4px solid #ef4444; background: ${missingCheckoutCount > 0 ? 'var(--danger-bg)' : 'inherit'};">
        <div class="muted small" style="color:#dc2626; font-weight: ${missingCheckoutCount > 0 ? '700' : '600'}; text-transform: uppercase;">Missing Out</div>
        <div style="font-size: 24px; font-weight: 800; margin-top: 4px; color:#dc2626; font-family: var(--font-mono, monospace);">${missingCheckoutCount}</div>
    </div>
    <div class="card" style="padding: 14px 16px; text-align: center; border-left: 4px solid #8b5cf6;">
        <div class="muted small" style="color:#7c3aed; font-weight: 600; text-transform: uppercase;">Overtime</div>
        <div style="font-size: 24px; font-weight: 800; margin-top: 4px; color:#7c3aed; font-family: var(--font-mono, monospace);">${overtimeCount}</div>
    </div>
    <div class="card" style="padding: 14px 16px; text-align: center; border-left: 4px solid #94a3b8;">
        <div class="muted small" style="color:#64748b; font-weight: 600; text-transform: uppercase;">Absent</div>
        <div style="font-size: 24px; font-weight: 800; margin-top: 4px; color:#64748b; font-family: var(--font-mono, monospace);">${absentCount}</div>
    </div>
</div>

<c:if test="${missingCheckoutCount > 0}">
    <div class="alert alert-warning" style="margin-bottom: 24px; font-size: 13px;">
        ⚠️ <strong>Action Required:</strong> Found <strong>${missingCheckoutCount}</strong> record(s) without checkout 2 hours after shift ended (FR-ATT-04). Click <strong>✏️ Edit</strong> to adjust checkout time with valid reason.
    </div>
</c:if>

<!-- Attendance Table -->
<div class="table-wrap" style="margin-bottom: 32px;">
    <table class="table">
        <thead>
            <tr>
                <th>Date</th>
                <th>Employee</th>
                <th>Shift</th>
                <th>Check-In</th>
                <th>Check-Out</th>
                <th>Duration</th>
                <th>Status</th>
                <th style="text-align: right;">Actions</th>
            </tr>
        </thead>
        <tbody>
            <c:choose>
                <c:when test="${empty attendances}">
                    <tr>
                        <td colspan="8" class="empty">
                            No attendance records match the current filter.
                        </td>
                    </tr>
                </c:when>
                <c:otherwise>
                    <c:forEach var="a" items="${attendances}">
                        <tr>
                            <td style="font-weight: 600; white-space: nowrap;" class="mono">
                                <c:out value="${a.workDate}"/>
                            </td>
                            <td>
                                <div style="font-weight: 600;"><c:out value="${a.employeeName}"/></div>
                                <div class="muted small"><c:out value="${a.employeeCode}"/> · <c:out value="${a.department}"/></div>
                            </td>
                            <td>
                                <div style="font-weight: 500;"><c:out value="${a.shiftName}"/></div>
                                <div class="muted small mono"><c:out value="${a.shiftStartTime}"/> - <c:out value="${a.shiftEndTime}"/></div>
                            </td>
                            <td class="mono">
                                <c:choose>
                                    <c:when test="${not empty a.checkIn}">
                                        <span style="color:#059669; font-weight:600;"><c:out value="${a.formattedCheckInTime}"/></span>
                                    </c:when>
                                    <c:otherwise><span class="muted">--:--</span></c:otherwise>
                                </c:choose>
                            </td>
                            <td class="mono">
                                <c:choose>
                                    <c:when test="${not empty a.checkOut}">
                                        <span style="color:#2563eb; font-weight:600;"><c:out value="${a.formattedCheckOutTime}"/></span>
                                    </c:when>
                                    <c:otherwise>
                                        <c:if test="${a.status == 'MISSING_CHECKOUT'}">
                                            <span style="color:#dc2626; font-weight:700;">Missing Out ⚠️</span>
                                        </c:if>
                                        <c:if test="${a.status != 'MISSING_CHECKOUT'}">
                                            <span class="muted">--:--</span>
                                        </c:if>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td style="font-weight: 600;">
                                <c:out value="${a.formattedWorkedHours}"/>
                                <c:if test="${a.workedMinutes > 0}">
                                    <span class="muted small mono">(${a.workedMinutes}m)</span>
                                </c:if>
                            </td>
                            <td>
                                <span class="badge badge-${a.statusBadgeClass}">
                                    <c:out value="${a.statusLabel}"/>
                                </span>
                            </td>
                            <td style="text-align: right; white-space: nowrap;">
                                <button type="button" class="btn btn-sm btn-secondary" 
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

<!-- ================= Edit Attendance Modal (Solid Background, Backdrop Blur, Click & ESC dismissal) ================= -->
<div id="editModal" class="modal-overlay" onclick="handleEditBackdropClick(event)">
    <div class="modal-card" style="max-width: 540px;" onclick="event.stopPropagation()">
        <div class="modal-header">
            <h3 class="modal-title">✏️ Adjust Attendance Record (FR-ATT-05)</h3>
            <button type="button" class="modal-close-btn" onclick="closeEditModal()" title="Close dialog">&times;</button>
        </div>

        <form action="${ctx}/admin/attendance" method="post">
            <input type="hidden" name="id" id="modalId">
            <input type="hidden" name="from" value="${from}">
            <input type="hidden" name="to" value="${to}">

            <!-- Info Bar -->
            <div style="background: #f1f5f9; padding:12px 16px; border-radius:8px; margin-bottom:18px; font-size:13px; border: 1px solid var(--line);">
                <div><strong>Employee:</strong> <span id="modalEmpDisplay"></span></div>
                <div style="margin-top:4px;"><strong>Shift:</strong> <span id="modalShiftDisplay"></span> · <strong>Date:</strong> <span id="modalDateDisplay"></span></div>
            </div>

            <div style="display:grid; grid-template-columns: 1fr 1fr; gap:14px; margin-bottom:14px;">
                <div>
                    <label style="display:block; font-size:12px; font-weight:600; margin-bottom:4px;">CHECK-IN TIME</label>
                    <input type="datetime-local" name="checkIn" id="modalCheckIn" style="width:100%; font-size:13px;">
                </div>
                <div>
                    <label style="display:block; font-size:12px; font-weight:600; margin-bottom:4px;">CHECK-OUT TIME</label>
                    <input type="datetime-local" name="checkOut" id="modalCheckOut" style="width:100%; font-size:13px;">
                </div>
            </div>

            <div style="display:grid; grid-template-columns: 1fr 1fr; gap:14px; margin-bottom:14px;">
                <div>
                    <label style="display:block; font-size:12px; font-weight:600; margin-bottom:4px;">STATUS</label>
                    <select name="status" id="modalStatus" style="width:100%; font-size:13px;">
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
                    <input type="number" name="workedMinutes" id="modalWorkedMinutes" placeholder="Auto-calculated if blank" min="0" style="width:100%; font-size:13px;">
                </div>
            </div>

            <div style="margin-bottom:20px;">
                <label style="display:block; font-size:12px; font-weight:600; margin-bottom:4px; color:#dc2626;">
                    ADJUSTMENT REASON <span style="color:red;">* (Required by FR-ATT-05)</span>
                </label>
                <textarea name="reason" id="modalReason" required rows="3" style="width:100%; font-size:13px;"
                          placeholder="E.g., Employee forgot to scan out due to emergency client meeting, manager verified check-out at 18:00..."></textarea>
                <span class="muted small" style="display:block; margin-top:4px;">
                    ⚠️ This reason and the administrator identity will be recorded permanently in the Audit Log.
                </span>
            </div>

            <div style="display:flex; justify-content:flex-end; gap:10px; border-top:1px solid var(--line); padding-top:16px;">
                <button type="button" class="btn btn-ghost" onclick="closeEditModal()">Cancel</button>
                <button type="submit" class="btn btn-primary">💾 Save Adjustment</button>
            </div>
        </form>
    </div>
</div>

<!-- ================= Audit Log Modal (Solid Background, Backdrop Blur, Click & ESC dismissal) ================= -->
<div id="auditModal" class="modal-overlay" onclick="handleAuditBackdropClick(event)">
    <div class="modal-card" style="max-width: 680px;" onclick="event.stopPropagation()">
        <div class="modal-header">
            <h3 class="modal-title">📜 Audit Trail History (FR-ATT-05)</h3>
            <button type="button" class="modal-close-btn" onclick="closeAuditModal()" title="Close dialog">&times;</button>
        </div>

        <div id="auditLoading" style="text-align:center; padding:32px; color:var(--muted);">
            <div style="display:inline-block; width:24px; height:24px; border:3px solid var(--line); border-top-color:var(--primary); border-radius:50%; animation:spin 0.8s linear infinite;"></div>
            <div style="margin-top:8px;">Loading audit trail records...</div>
        </div>
        <div id="auditContent" style="display:none; max-height: 420px; overflow-y:auto;">
            <table class="table" style="width:100%; font-size:12px;">
                <thead>
                    <tr style="background:#f8fafc; text-align:left;">
                        <th style="padding:10px 12px;">TIMESTAMP</th>
                        <th style="padding:10px 12px;">MODIFIED BY</th>
                        <th style="padding:10px 12px;">REASON</th>
                        <th style="padding:10px 12px;">CHANGES</th>
                    </tr>
                </thead>
                <tbody id="auditTableBody"></tbody>
            </table>
        </div>

        <div style="margin-top:20px; text-align:right; border-top:1px solid var(--line); padding-top:16px;">
            <button type="button" class="btn btn-ghost" onclick="closeAuditModal()">Close</button>
        </div>
    </div>
</div>

<style>
    @keyframes spin { to { transform: rotate(360deg); } }
</style>

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
    modal.classList.add('active');
    modal.style.display = 'flex';
}

function closeEditModal() {
    const modal = document.getElementById('editModal');
    modal.classList.remove('active');
    modal.style.display = 'none';
}

function handleEditBackdropClick(e) {
    if (e.target.id === 'editModal') {
        closeEditModal();
    }
}

function viewAuditLog(recordId) {
    const modal = document.getElementById('auditModal');
    modal.classList.add('active');
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
                tbody.innerHTML = '<tr><td colspan="4" style="text-align:center; padding:28px; color:var(--muted);">No adjustments recorded for this entry (no audit logs).</td></tr>';
                return;
            }

            logs.forEach(l => {
                const tr = document.createElement('tr');
                tr.style.borderBottom = '1px solid var(--line)';
                tr.innerHTML = 
                    '<td style="padding:10px 12px; font-weight:500; white-space:nowrap;" class="mono">' + l.time + '</td>' +
                    '<td style="padding:10px 12px; font-weight:600; color:var(--primary);">' + l.admin + '</td>' +
                    '<td style="padding:10px 12px; color:#b45309;">' + (l.reason || '-') + '</td>' +
                    '<td style="padding:10px 12px; font-family:monospace; font-size:11px;">' +
                        '<div style="color:#dc2626; background:#fef2f2; padding:2px 6px; border-radius:4px; margin-bottom:2px;">- ' + (l.oldValue || '') + '</div>' +
                        '<div style="color:#059669; background:#ecfdf5; padding:2px 6px; border-radius:4px;">+ ' + (l.newValue || '') + '</div>' +
                    '</td>';
                tbody.appendChild(tr);
            });
        })
        .catch(err => {
            document.getElementById('auditLoading').innerText = 'Error loading audit log: ' + err;
        });
}

function closeAuditModal() {
    const modal = document.getElementById('auditModal');
    modal.classList.remove('active');
    modal.style.display = 'none';
}

function handleAuditBackdropClick(e) {
    if (e.target.id === 'auditModal') {
        closeAuditModal();
    }
}

// Global ESC listener to close open modals
document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape') {
        closeEditModal();
        closeAuditModal();
    }
});
</script>

<%@ include file="/WEB-INF/views/common/footer.jspf" %>
