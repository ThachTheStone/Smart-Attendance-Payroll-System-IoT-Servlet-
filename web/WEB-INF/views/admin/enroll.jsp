<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="pageTitle" value="Biometric Enrollment"/>
<c:set var="activeNav" value="users"/>
<%@ include file="../common/header.jspf" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<div class="page-head">
    <div>
        <a class="muted small back" href="${ctx}/admin/users">← Back to Users</a>
        <h1 style="margin-top: 6px;">Biometric Enrollment · <c:out value="${emp.fullName}"/></h1>
        <p class="muted"><span class="mono">${emp.code}</span> · ${emp.department} · ${emp.position}</p>
    </div>
    <div style="display: flex; gap: 10px;">
        <a class="btn btn-secondary" href="${ctx}/dev/simulator" target="_blank">Open Simulator ↗</a>
    </div>
</div>

<!-- Storage Warning (FR-ENROLL-05) -->
<c:if test="${totalEnrolled >= 150}">
    <div class="alert alert-danger" style="margin-bottom: 20px;">
        <strong>⚠️ Sensor Capacity Warning (FR-ENROLL-05):</strong>
        AS608 sensor memory is nearing full capacity (${totalEnrolled} / 162 slots used). Please purge templates of inactive employees!
    </div>
</c:if>

<div class="stats" style="margin-bottom: 24px;">
    <div class="stat">
        <span class="stat-num">${fingerprints.size()} / 2</span>
        <span class="stat-label">Employee Fingerprints (max 2)</span>
    </div>
    <div class="stat">
        <span class="stat-num">${totalEnrolled} / 162</span>
        <span class="stat-label">Total Templates in AS608 Module</span>
    </div>
</div>

<!-- Pending Command Alert -->
<c:if test="${not empty pendingCmd}">
    <div class="alert alert-info" style="margin-bottom: 20px; background: #eff6ff; border: 1px solid #bfdbfe; color: #1e40af;">
        <strong>🔔 Pending Command on Terminal:</strong> 
        Command #${pendingCmd.id} (${pendingCmd.type}) for Slot #${pendingCmd.templateId} - "${pendingCmd.fingerName}".
        Please instruct employee to place their finger on the sensor (or use the <strong>Simulator</strong> to confirm).
    </div>
</c:if>

<div style="display: grid; grid-template-columns: 3fr 2fr; gap: 24px; align-items: start;">
    <!-- Left: Registered Fingerprints Table -->
    <div class="card" style="padding: 0; overflow: hidden;">
        <div style="padding: 16px 20px; border-bottom: 1px solid var(--line); font-weight: 600; font-size: 15px;">
            Enrolled Fingerprints
        </div>
        <div class="table-wrap">
            <table class="table">
                <thead>
                    <tr>
                        <th>Slot (Template ID)</th>
                        <th>Finger Name</th>
                        <th>Enrolled Date</th>
                        <th style="text-align: right;">Action</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="fp" items="${fingerprints}">
                        <tr>
                            <td><span class="role-badge role-ADMIN" style="background:#e0f2fe; color:#0369a1;">Slot #${fp.templateId}</span></td>
                            <td><strong><c:out value="${fp.fingerName}"/></strong></td>
                            <td class="muted small">${fp.errollAt}</td>
                            <td style="text-align: right;">
                                <form action="${ctx}/admin/employees/enroll" method="post" style="display: inline;" 
                                      onsubmit="return confirm('Are you sure you want to delete this fingerprint template from the database and sensor?');">
                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="employeeId" value="${emp.id}">
                                    <input type="hidden" name="templateId" value="${fp.templateId}">
                                    <button type="submit" class="btn btn-ghost btn-sm" style="color: var(--danger);">Delete Template</button>
                                </form>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty fingerprints}">
                        <tr>
                            <td colspan="4" style="text-align:center; padding: 24px;" class="muted">
                                No fingerprints enrolled for this employee yet.
                            </td>
                        </tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </div>

    <!-- Right: Enroll Form -->
    <div class="card">
        <h3 style="margin-top: 0; font-size: 16px;">➕ Enroll New Fingerprint</h3>
        
        <c:choose>
            <c:when test="${fingerprints.size() >= 2}">
                <div class="muted small" style="padding: 12px 0;">
                    This employee has reached the maximum limit of <strong>2 fingerprints</strong> (FR-ENROLL-03). Delete an existing template to enroll another finger.
                </div>
            </c:when>
            <c:otherwise>
                <form action="${ctx}/admin/employees/enroll" method="post">
                    <input type="hidden" name="action" value="enroll">
                    <input type="hidden" name="employeeId" value="${emp.id}">

                    <div style="margin-bottom: 14px;">
                        <label style="display:block; font-weight:500; margin-bottom:4px; font-size:13px;">Target Terminal: <span style="color:red;">*</span></label>
                        <select name="deviceId" required style="width: 100%; padding: 8px 12px; border: 1px solid var(--line); border-radius: 6px; font-size: 14px;">
                            <c:forEach var="d" items="${devices}">
                                <option value="${d.id}">${d.name} (${d.location})</option>
                            </c:forEach>
                        </select>
                    </div>

                    <div style="margin-bottom: 20px;">
                        <label style="display:block; font-weight:500; margin-bottom:4px; font-size:13px;">Finger Description: <span style="color:red;">*</span></label>
                        <input type="text" name="fingerName" id="fingerNameInput" required style="width: 100%; padding: 8px 12px; border: 1px solid var(--line); border-radius: 6px; font-size: 14px;"
                               placeholder="e.g. Right Index Finger" value="${fingerprints.size() == 0 ? 'Right Index Finger' : 'Right Thumb'}">
                        <div style="display: flex; gap: 6px; margin-top: 6px;">
                            <button type="button" class="btn btn-ghost btn-sm" onclick="setFingerName('Right Index Finger')">Right Index</button>
                            <button type="button" class="btn btn-ghost btn-sm" onclick="setFingerName('Right Thumb')">Right Thumb</button>
                            <button type="button" class="btn btn-ghost btn-sm" onclick="setFingerName('Left Index Finger')">Left Index</button>
                        </div>
                    </div>

                    <button type="submit" class="btn" style="width: 100%; justify-content: center;" ${not empty pendingCmd ? 'disabled' : ''}>
                        🚀 Send Enrollment Command to Device
                    </button>
                </form>
            </c:otherwise>
        </c:choose>
    </div>
</div>

<script>
    function setFingerName(name) {
        document.getElementById('fingerNameInput').value = name;
    }
</script>

<%@ include file="../common/footer.jspf" %>
