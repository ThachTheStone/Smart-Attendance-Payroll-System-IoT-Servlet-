<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="pageTitle" value="Lịch xếp ca làm việc"/>
<c:set var="activeNav" value="shifts"/>
<%@ include file="../../common/header.jspf" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<style>
    .schedule-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; }
    .week-nav { display: flex; align-items: center; gap: 12px; }
    .shift-tag {
        display: inline-flex; align-items: center; gap: 6px; background: #e0f2fe; color: #0369a1;
        padding: 4px 8px; border-radius: 6px; font-size: 12px; font-weight: 500; margin-bottom: 4px;
    }
    .shift-tag-overnight { background: #fef3c7; color: #92400e; }
    .shift-del-btn {
        background: none; border: none; cursor: pointer; color: #9ca3af; font-size: 13px; padding: 0; line-height: 1;
    }
    .shift-del-btn:hover { color: var(--danger); }
    .emp-checkbox-list {
        max-height: 180px; overflow-y: auto; border: 1px solid var(--line); border-radius: 6px; padding: 10px;
        display: grid; grid-template-columns: repeat(auto-fill, minmax(200px, 1fr)); gap: 8px;
    }
</style>

<div class="page-head">
    <div>
        <h1>📅 Lịch xếp ca làm việc</h1>
        <p class="muted">Phân công ca làm việc theo tuần hoặc theo mẫu định kỳ (FR-SHIFT-02)</p>
    </div>
    <div style="display:flex; gap:10px;">
        <a class="btn btn-secondary" href="${ctx}/admin/shifts">⚙️ Danh sách ca làm</a>
        <a class="btn btn-secondary" href="${ctx}/admin/holidays">🎉 Ngày lễ</a>
    </div>
</div>

<div class="schedule-header">
    <div class="week-nav">
        <a class="btn btn-secondary btn-sm" href="${ctx}/admin/shifts/schedule?offset=${offset - 1}">← Tuần trước</a>
        <c:if test="${offset != 0}">
            <a class="btn btn-ghost btn-sm" href="${ctx}/admin/shifts/schedule?offset=0">Về tuần này</a>
        </c:if>
        <span style="font-weight: 600; font-size: 15px;">
            Từ ${monday} đến ${sunday}
        </span>
        <a class="btn btn-secondary btn-sm" href="${ctx}/admin/shifts/schedule?offset=${offset + 1}">Tuần sau →</a>
    </div>
    <div>
        <a class="btn btn-sm" href="#assignBox">+ Phân ca hàng loạt</a>
    </div>
</div>

<!-- Schedule Matrix Table -->
<div class="card" style="padding: 0; overflow-x: auto; margin-bottom: 30px;">
    <table class="table" style="min-width: 900px;">
        <thead>
            <tr>
                <th style="width: 220px;">Nhân viên</th>
                <c:forEach var="day" items="${weekDays}" varStatus="status">
                    <th style="text-align: center; width: 140px;">
                        <div>
                            <c:choose>
                                <c:when test="${day.dayOfWeek.value == 1}">Thứ 2</c:when>
                                <c:when test="${day.dayOfWeek.value == 2}">Thứ 3</c:when>
                                <c:when test="${day.dayOfWeek.value == 3}">Thứ 4</c:when>
                                <c:when test="${day.dayOfWeek.value == 4}">Thứ 5</c:when>
                                <c:when test="${day.dayOfWeek.value == 5}">Thứ 6</c:when>
                                <c:when test="${day.dayOfWeek.value == 6}">Thứ 7</c:when>
                                <c:when test="${day.dayOfWeek.value == 7}">Chủ nhật</c:when>
                            </c:choose>
                        </div>
                        <div class="muted small">${day.dayOfMonth}/${day.monthValue}</div>
                    </th>
                </c:forEach>
            </tr>
        </thead>
        <tbody>
            <c:forEach var="emp" items="${employees}">
                <tr>
                    <td>
                        <strong><c:out value="${emp.fullName}"/></strong>
                        <div class="muted small"><span class="mono">${emp.code}</span> · ${emp.department}</div>
                    </td>
                    <c:forEach var="day" items="${weekDays}">
                        <c:set var="cellKey" value="${emp.id}_${day}"/>
                        <c:set var="cellShifts" value="${grid[cellKey]}"/>
                        <td style="text-align: center; vertical-align: top; padding: 8px 4px;">
                            <c:choose>
                                <c:when test="${not empty cellShifts}">
                                    <c:forEach var="asgn" items="${cellShifts}">
                                        <div class="shift-tag ${asgn.startTime > asgn.endTime ? 'shift-tag-overnight' : ''}">
                                            <span>${asgn.shiftName} (${asgn.startTime})</span>
                                            <form action="${ctx}/admin/shifts/schedule" method="post" style="display:inline;" onsubmit="return confirm('Hủy ca làm này?');">
                                                <input type="hidden" name="action" value="delete">
                                                <input type="hidden" name="id" value="${asgn.id}">
                                                <input type="hidden" name="offset" value="${offset}">
                                                <button type="submit" class="shift-del-btn" title="Hủy ca">×</button>
                                            </form>
                                        </div>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <span class="muted" style="font-size: 12px;">—</span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                    </c:forEach>
                </tr>
            </c:forEach>
            <c:if test="${empty employees}">
                <tr><td colspan="8" style="text-align:center; padding: 24px;" class="muted">Không có nhân viên hoạt động nào.</td></tr>
            </c:if>
        </tbody>
    </table>
</div>

<!-- Bulk Shift Assignment Section -->
<div class="card" id="assignBox">
    <h2 style="font-size: 16px; margin-top: 0;">⚡ Phân công ca làm việc hàng loạt (Bulk Assignment)</h2>
    <p class="muted small">Chọn nhân viên, ca làm việc, khoảng ngày và ngày trong tuần để tự động tạo lịch phân công.</p>
    
    <form action="${ctx}/admin/shifts/schedule" method="post">
        <input type="hidden" name="action" value="assign">
        <input type="hidden" name="offset" value="${offset}">

        <div style="margin-bottom: 16px;">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 6px;">
                <label style="font-weight: 500; font-size: 13px;">1. Chọn nhân viên: <span style="color:red;">*</span></label>
                <button type="button" class="btn btn-ghost btn-sm" onclick="toggleAllEmployees(true)">Chọn tất cả</button>
            </div>
            <div class="emp-checkbox-list">
                <c:forEach var="emp" items="${employees}">
                    <label style="display: flex; align-items: center; gap: 6px; font-size: 13px; cursor: pointer;">
                        <input type="checkbox" name="employeeIds" value="${emp.id}" class="emp-cb" checked>
                        <span><strong>${emp.code}</strong> - ${emp.fullName}</span>
                    </label>
                </c:forEach>
            </div>
        </div>

        <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 16px; margin-bottom: 16px;">
            <div>
                <label style="display:block; font-weight:500; margin-bottom:4px; font-size:13px;">2. Ca làm việc: <span style="color:red;">*</span></label>
                <select name="shiftId" required style="width: 100%; padding: 8px 12px; border: 1px solid var(--line); border-radius: 6px; font-size: 14px;">
                    <c:forEach var="s" items="${shifts}">
                        <option value="${s.id}">${s.name} (${s.startTime} - ${s.endTime})</option>
                    </c:forEach>
                </select>
            </div>
            <div>
                <label style="display:block; font-weight:500; margin-bottom:4px; font-size:13px;">3. Từ ngày: <span style="color:red;">*</span></label>
                <input type="date" name="startDate" value="${monday}" required style="width: 100%; padding: 8px 12px; border: 1px solid var(--line); border-radius: 6px; font-size: 14px;">
            </div>
            <div>
                <label style="display:block; font-weight:500; margin-bottom:4px; font-size:13px;">4. Đến ngày: <span style="color:red;">*</span></label>
                <input type="date" name="endDate" value="${sunday}" required style="width: 100%; padding: 8px 12px; border: 1px solid var(--line); border-radius: 6px; font-size: 14px;">
            </div>
        </div>

        <div style="margin-bottom: 20px;">
            <label style="display:block; font-weight:500; margin-bottom:6px; font-size:13px;">5. Áp dụng cho các ngày trong tuần (để trống nếu áp dụng tất cả các ngày trong khoảng):</label>
            <div style="display: flex; gap: 16px; flex-wrap: wrap;">
                <label style="display:flex; align-items:center; gap:4px; font-size:13px; cursor:pointer;"><input type="checkbox" name="daysOfWeek" value="1" checked> Thứ 2</label>
                <label style="display:flex; align-items:center; gap:4px; font-size:13px; cursor:pointer;"><input type="checkbox" name="daysOfWeek" value="2" checked> Thứ 3</label>
                <label style="display:flex; align-items:center; gap:4px; font-size:13px; cursor:pointer;"><input type="checkbox" name="daysOfWeek" value="3" checked> Thứ 4</label>
                <label style="display:flex; align-items:center; gap:4px; font-size:13px; cursor:pointer;"><input type="checkbox" name="daysOfWeek" value="4" checked> Thứ 5</label>
                <label style="display:flex; align-items:center; gap:4px; font-size:13px; cursor:pointer;"><input type="checkbox" name="daysOfWeek" value="5" checked> Thứ 6</label>
                <label style="display:flex; align-items:center; gap:4px; font-size:13px; cursor:pointer;"><input type="checkbox" name="daysOfWeek" value="6"> Thứ 7</label>
                <label style="display:flex; align-items:center; gap:4px; font-size:13px; cursor:pointer;"><input type="checkbox" name="daysOfWeek" value="7"> Chủ nhật</label>
            </div>
        </div>

        <button type="submit" class="btn" style="padding: 10px 24px;">Phân ca làm việc</button>
    </form>
</div>

<script>
    function toggleAllEmployees(state) {
        document.querySelectorAll('.emp-cb').forEach(cb => cb.checked = state);
    }
</script>

<%@ include file="../../common/footer.jspf" %>
