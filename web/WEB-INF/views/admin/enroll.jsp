<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="pageTitle" value="Biometric Enrollment"/>
<c:set var="activeNav" value="users"/>
<%@ include file="../common/header.jspf" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<div class="page-head">
    <div>
        <a class="muted small" href="${ctx}/admin/users" style="display:inline-flex; align-items:center; gap:4px; margin-bottom:6px;">
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="19" y1="12" x2="5" y2="12"></line><polyline points="12 19 5 12 12 5"></polyline></svg>
            Back to Users
        </a>
        <h1>Biometric Enrollment &bull; <c:out value="${emp.fullName}"/></h1>
        <p class="muted"><span class="mono">${emp.code}</span> &bull; ${emp.department} &bull; ${emp.position}</p>
    </div>
    <div style="display: flex; gap: 8px;">
        <a class="btn btn-secondary btn-sm" href="${ctx}/dev/simulator" target="_blank">
            Open Simulator &rarr;
        </a>
    </div>
</div>

<!-- Storage Warning (FR-ENROLL-05) -->
<c:if test="${totalEnrolled >= 150}">
    <div class="alert alert-danger" style="margin-bottom: 20px;">
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" style="flex-shrink:0;"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"></path><line x1="12" y1="9" x2="12" y2="13"></line><line x1="12" y1="17" x2="12.01" y2="17"></line></svg>
        <div>
            <strong>Sensor Capacity Warning:</strong>
            AS608 sensor memory is nearing full capacity (${totalEnrolled} / 162 slots used). Please purge templates of inactive employees!
        </div>
    </div>
</c:if>

<div class="stats" style="margin-bottom: 20px;">
    <div class="stat">
        <span class="stat-num">${fingerprints.size()} / 2</span>
        <span class="stat-label">Employee Fingerprints (max 2)</span>
    </div>
    <div class="stat">
        <span class="stat-num">${totalEnrolled} / 162</span>
        <span class="stat-label">Templates in AS608 Hardware</span>
    </div>
</div>

<!-- Pending Command Alert -->
<c:if test="${not empty pendingCmd}">
    <div class="alert alert-info" style="margin-bottom: 20px;">
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" style="flex-shrink:0;"><path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"></path><path d="M13.73 21a2 2 0 0 1-3.46 0"></path></svg>
        <div>
            <strong>Pending Terminal Command:</strong> 
            Command #${pendingCmd.id} (${pendingCmd.type}) for Slot #${pendingCmd.templateId} - "${pendingCmd.fingerName}".
            Please instruct employee to place their finger on the sensor (or use the <strong>Simulator</strong> to confirm).
        </div>
    </div>
</c:if>

<div style="display: grid; grid-template-columns: 3fr 2fr; gap: 20px; align-items: start;">
    <!-- Left: Registered Fingerprints Table -->
    <div class="card" style="padding: 0; overflow: hidden;">
        <div style="padding: 14px 18px; border-bottom: 1px solid var(--border); font-weight: 700; font-size: 14px; background: #f8fafc; color: #0f172a;">
            Enrolled Fingerprints
        </div>
        <div class="table-wrap" style="border: none; border-radius: 0;">
            <table class="table">
                <thead>
                    <tr>
                        <th>Slot (ID)</th>
                        <th>Finger Name</th>
                        <th>Enrolled Date</th>
                        <th style="text-align: right;">Action</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="fp" items="${fingerprints}">
                        <tr>
                            <td><span class="role-badge role-KIOSK">Slot #${fp.templateId}</span></td>
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
                            <td colspan="4" style="text-align:center; padding: 24px; color: var(--muted);">
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
        <h3 style="margin-top: 0; font-size: 15px; font-weight: 600; display: flex; align-items: center; gap: 6px;">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#3b82f6" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"></line><line x1="5" y1="12" x2="19" y2="12"></line></svg>
            Enroll New Fingerprint
        </h3>
        
        <c:choose>
            <c:when test="${fingerprints.size() >= 2}">
                <div class="muted small" style="padding: 12px 0;">
                    This employee has reached the maximum limit of <strong>2 fingerprints</strong> (FR-ENROLL-03). Delete an existing template to enroll another finger.
                </div>
            </c:when>
            <c:otherwise>
                <form action="${ctx}/admin/employees/enroll" method="post" style="margin-top: 14px;">
                    <input type="hidden" name="action" value="enroll">
                    <input type="hidden" name="employeeId" value="${emp.id}">

                    <div style="margin-bottom: 14px;">
                        <label style="display:block; font-weight:600; margin-bottom:4px; font-size:12px; color: #334155;">Target Terminal: <span style="color:#f87171;">*</span></label>
                        <select name="deviceId" required style="width: 100%;">
                            <c:forEach var="d" items="${devices}">
                                <option value="${d.id}" ${d.apiKey == 'DEV-ESP32-ATTENDANCE-KEY-001' ? 'selected' : ''}>${d.name} (${d.location})</option>
                            </c:forEach>
                        </select>
                    </div>

                    <div style="margin-bottom: 20px;">
                        <label style="display:block; font-weight:600; margin-bottom:4px; font-size:12px; color: #334155;">Finger Description: <span style="color:#f87171;">*</span></label>
                        <input type="text" name="fingerName" id="fingerNameInput" required style="width: 100%;"
                               placeholder="e.g. Right Index Finger" value="${fingerprints.size() == 0 ? 'Right Index Finger' : 'Right Thumb'}">
                        <div style="display: flex; gap: 6px; margin-top: 8px;">
                            <button type="button" class="btn btn-secondary btn-sm" onclick="setFingerName('Right Index Finger')">Right Index</button>
                            <button type="button" class="btn btn-secondary btn-sm" onclick="setFingerName('Right Thumb')">Right Thumb</button>
                            <button type="button" class="btn btn-secondary btn-sm" onclick="setFingerName('Left Index Finger')">Left Index</button>
                        </div>
                    </div>

                    <button type="submit" class="btn btn-primary" style="width: 100%; justify-content: center;" ${not empty pendingCmd ? 'disabled' : ''}>
                        Send Enrollment Command to Terminal
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

    // Auto-reload when fingerprint enrollment finishes
    if (window.EventSource) {
        const es = new EventSource('${ctx}/kiosk/stream');
        es.addEventListener('enroll_step', (e) => {
            try {
                const data = JSON.parse(e.data);
                if (data.step === 'SUCCESS') {
                    setTimeout(() => window.location.reload(), 1500);
                }
            } catch(err){}
        });
    }
</script>

<%@ include file="../common/footer.jspf" %>
