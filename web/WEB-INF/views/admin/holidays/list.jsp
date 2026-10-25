<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="pageTitle" value="Public Holidays"/>
<c:set var="activeNav" value="holidays"/>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<%@ include file="../../common/header.jspf" %>

<style>
    .holiday-hero {
        display: flex;
        justify-content: space-between;
        align-items: center;
        flex-wrap: wrap;
        gap: 16px;
        margin-bottom: 24px;
        padding: 20px 24px;
        background: #ffffff;
        border: 1px solid var(--border);
        border-radius: var(--radius-lg);
        box-shadow: var(--shadow-sm);
    }
    .holiday-hero-title {
        font-size: 22px;
        font-weight: 700;
        letter-spacing: -0.02em;
        margin: 0;
        display: flex;
        align-items: center;
        gap: 10px;
        color: #0f172a;
    }
    .holiday-hero-desc {
        color: var(--muted);
        font-size: 13px;
        margin-top: 4px;
    }

    /* Layout Grid */
    .holiday-layout {
        display: grid;
        grid-template-columns: 2fr 1fr;
        gap: 20px;
        align-items: start;
    }
    @media (max-width: 900px) {
        .holiday-layout {
            grid-template-columns: 1fr;
        }
    }

    /* Holiday Table Card */
    .holiday-table-card {
        background: #ffffff;
        border: 1px solid var(--border);
        border-radius: var(--radius-lg);
        overflow: hidden;
        box-shadow: var(--shadow-xs);
    }
    .holiday-table-header {
        padding: 14px 18px;
        border-bottom: 1px solid var(--border);
        display: flex;
        justify-content: space-between;
        align-items: center;
        background: #f8fafc;
        color: #0f172a;
        font-weight: 600;
    }
    .holiday-table-card .table {
        margin: 0;
        width: 100%;
        border-collapse: collapse;
    }
    .holiday-table-card .table th {
        background: #f8fafc;
        padding: 10px 14px;
        font-size: 11px;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 0.05em;
        color: #475569;
        border-bottom: 1px solid var(--border);
    }
    .holiday-table-card .table td {
        padding: 12px 14px;
        border-bottom: 1px solid #f1f5f9;
        vertical-align: middle;
        font-size: 13px;
        color: #334155;
    }
    .holiday-table-card .table tr:last-child td { border-bottom: 0; }
    .holiday-table-card .table tr:hover td {
        background: #f8fafc;
    }

    /* Form Card */
    .holiday-form-card {
        background: #ffffff;
        border: 1px solid var(--border);
        border-radius: var(--radius-lg);
        padding: 20px;
        color: #0f172a;
        box-shadow: var(--shadow-sm);
    }
</style>

<!-- Hero Section -->
<div class="holiday-hero">
    <div>
        <h1 class="holiday-hero-title">
            Public Holidays
        </h1>
        <p class="holiday-hero-desc">
            Statutory calendar configured with automated 300% overtime pay multipliers
        </p>
    </div>
    <div style="display:flex; gap:8px; flex-wrap:wrap;">
        <a class="btn btn-secondary" href="${ctx}/admin/shifts">Shifts</a>
        <a class="btn btn-secondary" href="${ctx}/admin/shifts/schedule">Shift Schedule</a>
    </div>
</div>

<div class="holiday-layout">
    <!-- Left: Holiday Table -->
    <div class="holiday-table-card">
        <div class="holiday-table-header">
            <span style="font-weight: 600; font-size: 14px; color: #0f172a;">Calendar of Public Holidays</span>
            <span class="role-badge" style="background: rgba(244, 63, 94, 0.12); color: #fb7185; border: 1px solid rgba(244, 63, 94, 0.28);">300% OT Pay Rate</span>
        </div>
        <div class="table-wrap" style="border:none; border-radius:0;">
            <table class="table">
                <thead>
                    <tr>
                        <th style="width: 150px;">Date</th>
                        <th>Holiday Name</th>
                        <th style="text-align: right; width: 100px;">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="h" items="${holidays}">
                        <tr>
                            <td>
                                <span class="mono font-bold" style="color:#2563eb;">
                                    <c:out value="${h.date}"/>
                                </span>
                            </td>
                            <td>
                                <strong style="color: #0f172a; font-size: 13px;"><c:out value="${h.name}"/></strong>
                            </td>
                            <td style="text-align: right;">
                                <form action="${ctx}/admin/holidays" method="post" style="display: inline; margin: 0;" onsubmit="return confirm('Remove holiday ${h.name} (${h.date})?');">
                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="date" value="${h.date}">
                                    <button type="submit" class="btn btn-ghost btn-sm" style="color: var(--danger);">
                                        Delete
                                    </button>
                                </form>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty holidays}">
                        <tr>
                            <td colspan="3" style="text-align:center; padding: 32px; color: var(--muted);">
                                No public holidays configured yet. Use the form on the right to add holiday dates.
                            </td>
                        </tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </div>

    <!-- Right: Add Holiday Form -->
    <div class="holiday-form-card">
        <div style="margin-bottom: 16px;">
            <h3 style="margin: 0; font-size: 15px; font-weight: 600; color: #0f172a;">
                Add New Holiday
            </h3>
            <p class="muted small" style="margin-top: 3px;">
                Employees working on this date will automatically earn 300% overtime.
            </p>
        </div>

        <form action="${ctx}/admin/holidays" method="post">
            <input type="hidden" name="action" value="add">

            <div style="margin-bottom: 14px;">
                <label style="display:block; font-weight:600; font-size:12px; color:#cbd5e1; margin-bottom:4px;">
                    Holiday Date <span style="color:#f87171;">*</span>
                </label>
                <input type="date" name="date" required style="width:100%;">
            </div>

            <div style="margin-bottom: 18px;">
                <label style="display:block; font-weight:600; font-size:12px; color:#cbd5e1; margin-bottom:4px;">
                    Holiday Name <span style="color:#f87171;">*</span>
                </label>
                <input type="text" name="name" required style="width:100%;"
                       placeholder="e.g. National Day">
            </div>

            <button type="submit" class="btn btn-primary" style="width: 100%; justify-content: center;">
                Save Public Holiday
            </button>
        </form>
    </div>
</div>

<%@ include file="../../common/footer.jspf" %>
