<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="pageTitle" value="Quản lý ca làm việc"/>
<c:set var="activeNav" value="shifts"/>
<%@ include file="../../common/header.jspf" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<div class="page-head">
    <div>
        <h1>Quản lý ca làm việc</h1>
        <p class="muted">Định nghĩa ca sáng, chiều, đêm và giờ nghỉ giải lao (FR-SHIFT-01)</p>
    </div>
    <div style="display:flex; gap:10px;">
        <a class="btn" href="${ctx}/admin/shifts/schedule">📅 Xếp ca làm việc (Lịch tuần)</a>
        <a class="btn btn-secondary" href="${ctx}/admin/holidays">🎉 Quản lý ngày lễ</a>
    </div>
</div>

<div style="display: grid; grid-template-columns: 2fr 1fr; gap: 24px; align-items: start;">
    <!-- Left: Shifts Table -->
    <div class="card" style="padding: 0; overflow: hidden;">
        <div style="padding: 16px 20px; border-bottom: 1px solid var(--line); font-weight: 600; font-size: 15px;">
            Danh sách ca làm việc
        </div>
        <div class="table-wrap">
            <table class="table">
                <thead>
                    <tr>
                        <th>Tên ca</th>
                        <th>Giờ bắt đầu</th>
                        <th>Giờ kết thúc</th>
                        <th>Nghỉ giải lao</th>
                        <th>Loại ca</th>
                        <th style="text-align: right;">Thao tác</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="s" items="${shifts}">
                        <tr>
                            <td><strong><c:out value="${s.name}"/></strong></td>
                            <td class="mono"><c:out value="${s.startTime}"/></td>
                            <td class="mono"><c:out value="${s.endTime}"/></td>
                            <td><c:out value="${s.breakMinutes}"/> phút</td>
                            <td>
                                <c:choose>
                                    <c:when test="${s.overnight}">
                                        <span class="role-badge role-STAFF" style="background:#fef3c7; color:#92400e;">Ca qua đêm (22h-06h)</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="role-badge role-ADMIN" style="background:#e0f2fe; color:#0369a1;">Ca trong ngày</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td style="text-align: right;">
                                <a class="btn btn-ghost btn-sm" href="${ctx}/admin/shifts?action=edit&id=${s.id}">Sửa</a>
                                <form action="${ctx}/admin/shifts" method="post" style="display: inline;" onsubmit="return confirm('Bạn có chắc muốn xóa ca làm này?');">
                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="id" value="${s.id}">
                                    <button type="submit" class="btn btn-ghost btn-sm" style="color: var(--danger);">Xóa</button>
                                </form>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty shifts}">
                        <tr><td colspan="6" style="text-align:center; padding: 24px;" class="muted">Chưa có ca làm việc nào.</td></tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </div>

    <!-- Right: Add / Edit Form -->
    <div class="card">
        <h3 style="margin-top: 0; font-size: 16px;">
            <c:choose>
                <c:when test="${not empty shift}">✏️ Chỉnh sửa ca làm việc</c:when>
                <c:otherwise>➕ Thêm ca làm việc mới</c:otherwise>
            </c:choose>
        </h3>
        <form action="${ctx}/admin/shifts" method="post">
            <input type="hidden" name="action" value="save">
            <input type="hidden" name="id" value="${not empty shift ? shift.id : ''}">

            <div style="margin-bottom: 14px;">
                <label style="display:block; font-weight:500; margin-bottom:4px; font-size:13px;">Tên ca làm <span style="color:red;">*</span></label>
                <input type="text" name="name" required style="width:100%; padding:8px 12px; border:1px solid var(--line); border-radius:6px; font-size:14px;"
                       value="<c:out value='${shift.name}'/>" placeholder="VD: Ca sáng (06:00 - 14:00)">
            </div>

            <div style="margin-bottom: 14px;">
                <label style="display:block; font-weight:500; margin-bottom:4px; font-size:13px;">Giờ bắt đầu <span style="color:red;">*</span></label>
                <input type="time" name="startTime" required style="width:100%; padding:8px 12px; border:1px solid var(--line); border-radius:6px; font-size:14px;"
                       value="${not empty shift ? shift.formattedStartTime : '06:00'}">
            </div>

            <div style="margin-bottom: 14px;">
                <label style="display:block; font-weight:500; margin-bottom:4px; font-size:13px;">Giờ kết thúc <span style="color:red;">*</span></label>
                <input type="time" name="endTime" required style="width:100%; padding:8px 12px; border:1px solid var(--line); border-radius:6px; font-size:14px;"
                       value="${not empty shift ? shift.formattedEndTime : '14:00'}">
                <span class="muted small" style="display:block; margin-top:4px;">Nếu giờ kết thúc nhỏ hơn giờ bắt đầu (vd: 22:00 đến 06:00), hệ thống sẽ tính là ca qua đêm (thuộc ngày bắt đầu - FR-SHIFT-03).</span>
            </div>

            <div style="margin-bottom: 20px;">
                <label style="display:block; font-weight:500; margin-bottom:4px; font-size:13px;">Nghỉ giải lao (phút)</label>
                <input type="number" name="breakMinutes" min="0" max="180" style="width:100%; padding:8px 12px; border:1px solid var(--line); border-radius:6px; font-size:14px;"
                       value="${not empty shift ? shift.breakMinutes : 30}">
            </div>

            <div style="display:flex; gap:10px;">
                <button type="submit" class="btn" style="flex:1; justify-content:center;">
                    <c:choose>
                        <c:when test="${not empty shift}">Lưu thay đổi</c:when>
                        <c:otherwise>Thêm ca</c:otherwise>
                    </c:choose>
                </button>
                <c:if test="${not empty shift}">
                    <a href="${ctx}/admin/shifts" class="btn btn-secondary">Hủy</a>
                </c:if>
            </div>
        </form>
    </div>
</div>

<%@ include file="../../common/footer.jspf" %>
