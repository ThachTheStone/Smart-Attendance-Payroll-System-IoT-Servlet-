<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="pageTitle" value="Shift Management"/>
<c:set var="activeNav" value="shifts"/>
<%@ include file="../../common/header.jspf" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<div class="page-head">
    <div>
        <h1>Shift Management</h1>
        <p class="muted">Configure morning, evening, night shifts and break durations (FR-SHIFT-01)</p>
    </div>
    <div style="display:flex; gap:10px;">
        <a class="btn" href="${ctx}/admin/shifts/schedule">📅 Weekly Shift Schedule</a>
        <a class="btn btn-secondary" href="${ctx}/admin/holidays">🎉 Holiday Management</a>
    </div>
</div>

<div style="display: grid; grid-template-columns: 2fr 1fr; gap: 24px; align-items: start;">
    <!-- Left: Shifts Table -->
    <div class="card" style="padding: 0; overflow: hidden;">
        <div style="padding: 16px 20px; border-bottom: 1px solid var(--line); font-weight: 600; font-size: 15px;">
            Shift List
        </div>
        <div class="table-wrap">
            <table class="table">
                <thead>
                    <tr>
                        <th>Shift Name</th>
                        <th>Start Time</th>
                        <th>End Time</th>
                        <th>Break Time</th>
                        <th>Shift Type</th>
                        <th style="text-align: right;">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="s" items="${shifts}">
                        <tr>
                            <td><strong><c:out value="${s.name}"/></strong></td>
                            <td class="mono"><c:out value="${s.startTime}"/></td>
                            <td class="mono"><c:out value="${s.endTime}"/></td>
                            <td><c:out value="${s.breakMinutes}"/> mins</td>
                            <td>
                                <c:choose>
                                    <c:when test="${s.overnight}">
                                        <span class="role-badge role-STAFF" style="background:#fef3c7; color:#92400e;">Overnight Shift</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="role-badge role-ADMIN" style="background:#e0f2fe; color:#0369a1;">Daytime Shift</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td style="text-align: right;">
                                <a class="btn btn-ghost btn-sm" href="${ctx}/admin/shifts?action=edit&id=${s.id}">Edit</a>
                                <form action="${ctx}/admin/shifts" method="post" style="display: inline;" onsubmit="return confirm('Are you sure you want to delete this shift?');">
                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="id" value="${s.id}">
                                    <button type="submit" class="btn btn-ghost btn-sm" style="color: var(--danger);">Delete</button>
                                </form>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty shifts}">
                        <tr><td colspan="6" style="text-align:center; padding: 24px;" class="muted">No shifts found.</td></tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </div>

    <!-- Right: Add / Edit Form -->
    <div class="card">
        <h3 style="margin-top: 0; font-size: 16px;">
            <c:choose>
                <c:when test="${not empty shift}">✏️ Edit Shift</c:when>
                <c:otherwise>➕ Add New Shift</c:otherwise>
            </c:choose>
        </h3>
        <form action="${ctx}/admin/shifts" method="post">
            <input type="hidden" name="action" value="save">
            <input type="hidden" name="id" value="${not empty shift ? shift.id : ''}">

            <div style="margin-bottom: 14px;">
                <label style="display:block; font-weight:500; margin-bottom:4px; font-size:13px;">Shift Name <span style="color:red;">*</span></label>
                <input type="text" name="name" required style="width:100%; padding:8px 12px; border:1px solid var(--line); border-radius:6px; font-size:14px;"
                       value="<c:out value='${shift.name}'/>" placeholder="E.g., Morning Shift (06:00 - 14:00)">
            </div>

            <div style="margin-bottom: 14px;">
                <label style="display:block; font-weight:500; margin-bottom:4px; font-size:13px;">Start Time <span style="color:red;">*</span></label>
                <input type="time" name="startTime" required style="width:100%; padding:8px 12px; border:1px solid var(--line); border-radius:6px; font-size:14px;"
                       value="${not empty shift ? shift.formattedStartTime : '06:00'}">
            </div>

            <div style="margin-bottom: 14px;">
                <label style="display:block; font-weight:500; margin-bottom:4px; font-size:13px;">End Time <span style="color:red;">*</span></label>
                <input type="time" name="endTime" required style="width:100%; padding:8px 12px; border:1px solid var(--line); border-radius:6px; font-size:14px;"
                       value="${not empty shift ? shift.formattedEndTime : '14:00'}">
                <span class="muted small" style="display:block; margin-top:4px;">If end time is earlier than start time (e.g., 22:00 to 06:00), it will be handled as an overnight shift (counted on start date - FR-SHIFT-03).</span>
            </div>

            <div style="margin-bottom: 20px;">
                <label style="display:block; font-weight:500; margin-bottom:4px; font-size:13px;">Break Duration (minutes)</label>
                <input type="number" name="breakMinutes" min="0" max="180" style="width:100%; padding:8px 12px; border:1px solid var(--line); border-radius:6px; font-size:14px;"
                       value="${not empty shift ? shift.breakMinutes : 30}">
            </div>

            <div style="display:flex; gap:10px;">
                <button type="submit" class="btn" style="flex:1; justify-content:center;">
                    <c:choose>
                        <c:when test="${not empty shift}">Save Changes</c:when>
                        <c:otherwise>Add Shift</c:otherwise>
                    </c:choose>
                </button>
                <c:if test="${not empty shift}">
                    <a href="${ctx}/admin/shifts" class="btn btn-secondary">Cancel</a>
                </c:if>
            </div>
        </form>
    </div>
</div>

<%@ include file="../../common/footer.jspf" %>
