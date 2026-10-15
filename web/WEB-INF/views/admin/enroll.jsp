<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="pageTitle" value="Đăng ký vân tay"/>
<c:set var="activeNav" value="users"/>
<%@ include file="../common/header.jspf" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<div class="page-head">
    <div>
        <a class="muted small back" href="${ctx}/admin/users">← Quay lại danh sách người dùng</a>
        <h1 style="margin-top: 6px;">Đăng ký vân tay · <c:out value="${emp.fullName}"/></h1>
        <p class="muted"><span class="mono">${emp.code}</span> · ${emp.department} · ${emp.position}</p>
    </div>
    <div style="display: flex; gap: 10px;">
        <a class="btn btn-secondary" href="${ctx}/dev/simulator" target="_blank">Mở Simulator ↗</a>
    </div>
</div>

<!-- Storage Warning (FR-ENROLL-05) -->
<c:if test="${totalEnrolled >= 150}">
    <div class="alert alert-danger" style="margin-bottom: 20px;">
        <strong>⚠️ Cảnh báo dung lượng cảm biến (FR-ENROLL-05):</strong>
        Bộ nhớ cảm biến AS608 sắp đầy (${totalEnrolled} / 162 slots đã dùng). Vui lòng xóa bớt vân tay của nhân viên đã nghỉ việc!
    </div>
</c:if>

<div class="stats" style="margin-bottom: 24px;">
    <div class="stat">
        <span class="stat-num">${fingerprints.size()} / 2</span>
        <span class="stat-label">Vân tay của nhân viên (tối đa 2)</span>
    </div>
    <div class="stat">
        <span class="stat-num">${totalEnrolled} / 162</span>
        <span class="stat-label">Tổng vân tay trong cảm biến AS608</span>
    </div>
</div>

<!-- Pending Command Alert -->
<c:if test="${not empty pendingCmd}">
    <div class="alert alert-info" style="margin-bottom: 20px; background: #eff6ff; border: 1px solid #bfdbfe; color: #1e40af;">
        <strong>🔔 Đang có lệnh chờ trên thiết bị:</strong> 
        Lệnh #${pendingCmd.id} (${pendingCmd.type}) cho Slot #${pendingCmd.templateId} - "${pendingCmd.fingerName}".
        Vui lòng cho nhân viên đặt ngón tay lên cảm biến (hoặc dùng trang <strong>Simulator</strong> để xác nhận).
    </div>
</c:if>

<div style="display: grid; grid-template-columns: 3fr 2fr; gap: 24px; align-items: start;">
    <!-- Left: Registered Fingerprints Table -->
    <div class="card" style="padding: 0; overflow: hidden;">
        <div style="padding: 16px 20px; border-bottom: 1px solid var(--line); font-weight: 600; font-size: 15px;">
            Vân tay đã đăng ký
        </div>
        <div class="table-wrap">
            <table class="table">
                <thead>
                    <tr>
                        <th>Slot (Template ID)</th>
                        <th>Tên ngón tay</th>
                        <th>Ngày đăng ký</th>
                        <th style="text-align: right;">Thao tác</th>
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
                                      onsubmit="return confirm('Bạn có chắc muốn xóa vân tay này khỏi hệ thống và máy quét?');">
                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="employeeId" value="${emp.id}">
                                    <input type="hidden" name="templateId" value="${fp.templateId}">
                                    <button type="submit" class="btn btn-ghost btn-sm" style="color: var(--danger);">Xóa vân tay</button>
                                </form>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty fingerprints}">
                        <tr>
                            <td colspan="4" style="text-align:center; padding: 24px;" class="muted">
                                Nhân viên này chưa đăng ký ngón tay nào.
                            </td>
                        </tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </div>

    <!-- Right: Enroll Form -->
    <div class="card">
        <h3 style="margin-top: 0; font-size: 16px;">➕ Đăng ký vân tay mới</h3>
        
        <c:choose>
            <c:when test="${fingerprints.size() >= 2}">
                <div class="muted small" style="padding: 12px 0;">
                    Nhân viên này đã đạt giới hạn tối đa <strong>2 vân tay</strong> (FR-ENROLL-03). Hãy xóa một vân tay cũ nếu muốn đăng ký lại ngón khác.
                </div>
            </c:when>
            <c:otherwise>
                <form action="${ctx}/admin/employees/enroll" method="post">
                    <input type="hidden" name="action" value="enroll">
                    <input type="hidden" name="employeeId" value="${emp.id}">

                    <div style="margin-bottom: 14px;">
                        <label style="display:block; font-weight:500; margin-bottom:4px; font-size:13px;">Thiết bị ghi nhận: <span style="color:red;">*</span></label>
                        <select name="deviceId" required style="width: 100%; padding: 8px 12px; border: 1px solid var(--line); border-radius: 6px; font-size: 14px;">
                            <c:forEach var="d" items="${devices}">
                                <option value="${d.id}">${d.name} (${d.location})</option>
                            </c:forEach>
                        </select>
                    </div>

                    <div style="margin-bottom: 20px;">
                        <label style="display:block; font-weight:500; margin-bottom:4px; font-size:13px;">Tên ngón tay: <span style="color:red;">*</span></label>
                        <input type="text" name="fingerName" id="fingerNameInput" required style="width: 100%; padding: 8px 12px; border: 1px solid var(--line); border-radius: 6px; font-size: 14px;"
                               placeholder="VD: Ngón trỏ phải" value="${fingerprints.size() == 0 ? 'Ngón trỏ phải' : 'Ngón cái phải'}">
                        <div style="display: flex; gap: 6px; margin-top: 6px;">
                            <button type="button" class="btn btn-ghost btn-sm" onclick="setFingerName('Ngón trỏ phải')">Trỏ phải</button>
                            <button type="button" class="btn btn-ghost btn-sm" onclick="setFingerName('Ngón cái phải')">Cái phải</button>
                            <button type="button" class="btn btn-ghost btn-sm" onclick="setFingerName('Ngón trỏ trái')">Trỏ trái</button>
                        </div>
                    </div>

                    <button type="submit" class="btn" style="width: 100%; justify-content: center;" ${not empty pendingCmd ? 'disabled' : ''}>
                        🚀 Gửi lệnh đăng ký tới thiết bị
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
