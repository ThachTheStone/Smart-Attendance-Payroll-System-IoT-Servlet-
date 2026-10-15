<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="pageTitle" value="Holiday Management"/>
<c:set var="activeNav" value="holidays"/>
<%@ include file="../../common/header.jspf" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<div class="page-head">
    <div>
        <h1>🎉 Holiday Management</h1>
        <p class="muted">Public holiday calendar applied with 300% overtime rate (FR-RULE-02, FR-RULE-06)</p>
    </div>
    <div style="display:flex; gap:10px;">
        <a class="btn btn-secondary" href="${ctx}/admin/shifts">⚙️ Shifts</a>
        <a class="btn btn-secondary" href="${ctx}/admin/shifts/schedule">📅 Shift Schedule</a>
    </div>
</div>

<div style="display: grid; grid-template-columns: 2fr 1fr; gap: 24px; align-items: start;">
    <!-- Left: Holiday Table -->
    <div class="card" style="padding: 0; overflow: hidden;">
        <div style="padding: 16px 20px; border-bottom: 1px solid var(--line); font-weight: 600; font-size: 15px;">
            Official Public Holidays
        </div>
        <div class="table-wrap">
            <table class="table">
                <thead>
                    <tr>
                        <th>Date</th>
                        <th>Holiday Name</th>
                        <th style="text-align: right;">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="h" items="${holidays}">
                        <tr>
                            <td class="mono"><strong><c:out value="${h.date}"/></strong></td>
                            <td><c:out value="${h.name}"/></td>
                            <td style="text-align: right;">
                                <form action="${ctx}/admin/holidays" method="post" style="display: inline;" onsubmit="return confirm('Are you sure you want to delete this holiday?');">
                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="date" value="${h.date}">
                                    <button type="submit" class="btn btn-ghost btn-sm" style="color: var(--danger);">Delete</button>
                                </form>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty holidays}">
                        <tr><td colspan="3" style="text-align:center; padding: 24px;" class="muted">No holidays recorded.</td></tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </div>

    <!-- Right: Add Holiday Form -->
    <div class="card">
        <h3 style="margin-top: 0; font-size: 16px;">➕ Add New Holiday</h3>
        <form action="${ctx}/admin/holidays" method="post">
            <input type="hidden" name="action" value="add">

            <div style="margin-bottom: 14px;">
                <label style="display:block; font-weight:500; margin-bottom:4px; font-size:13px;">Holiday Date <span style="color:red;">*</span></label>
                <input type="date" name="date" required style="width:100%; padding:8px 12px; border:1px solid var(--line); border-radius:6px; font-size:14px;">
            </div>

            <div style="margin-bottom: 20px;">
                <label style="display:block; font-weight:500; margin-bottom:4px; font-size:13px;">Holiday Name <span style="color:red;">*</span></label>
                <input type="text" name="name" required style="width:100%; padding:8px 12px; border:1px solid var(--line); border-radius:6px; font-size:14px;"
                       placeholder="E.g., International Labor Day">
            </div>

            <button type="submit" class="btn" style="width: 100%; justify-content: center;">Add Holiday</button>
        </form>
    </div>
</div>

<%@ include file="../../common/footer.jspf" %>
