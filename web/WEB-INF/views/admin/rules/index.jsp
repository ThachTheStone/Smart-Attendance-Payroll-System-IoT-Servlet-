<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<c:set var="pageTitle" value="Quy tắc tính lương"/>
<c:set var="activeNav" value="rules"/>
<%@include file="/WEB-INF/views/common/header.jspf"%>

<div class="page-head">
    <div>
        <h1>Quy tắc tính lương (Salary Rules Engine)</h1>
        <p class="muted">Cấu hình các tham số và hệ số tính lương theo Luật Lao động Việt Nam (FR-RULE-01..07). Các thay đổi chỉ áp dụng cho bảng lương chưa khóa.</p>
    </div>
    <div style="display:flex; gap:10px;">
        <a href="${pageContext.request.contextPath}/admin/holidays" class="btn btn-secondary btn-sm">Lịch nghỉ lễ/Tết</a>
        <a href="${pageContext.request.contextPath}/admin/payroll" class="btn btn-sm">Bảng lương</a>
    </div>
</div>

<form method="post" action="${pageContext.request.contextPath}/admin/rules">
    <div class="card" style="margin-bottom:24px;">
        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:16px;">
            <h2 style="font-size:16px; margin:0;">Thông số tính công &amp; Lương chuẩn</h2>
            <span class="role-badge role-ADMIN">FR-RULE-01</span>
        </div>

        <table class="table">
            <thead>
                <tr>
                    <th style="width:240px;">Mã quy tắc (Rule Key)</th>
                    <th>Mô tả / Ý nghĩa</th>
                    <th style="width:200px;">Giá trị thiết lập</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="r" items="${rules}">
                    <tr>
                        <td class="mono font-bold" style="color:#2563eb;">
                            ${r.ruleKey}
                        </td>
                        <td>
                            <strong><c:out value="${r.description}"/></strong>
                            <div class="muted small" style="margin-top:2px;">
                                <c:choose>
                                    <c:when test="${r.ruleKey == 'standard_hours_per_month'}">Số giờ công định mức làm căn cứ chia lương theo giờ (Base / 208).</c:when>
                                    <c:when test="${r.ruleKey == 'ot_weekday_multiplier'}">Hệ số tính thêm giờ vào các ngày làm việc tiêu chuẩn trong tuần.</c:when>
                                    <c:when test="${r.ruleKey == 'ot_weekend_multiplier'}">Hệ số tính thêm giờ vào ngày nghỉ hàng tuần (Thứ 7, Chủ Nhật).</c:when>
                                    <c:when test="${r.ruleKey == 'ot_holiday_multiplier'}">Hệ số tính thêm giờ vào ngày nghỉ lễ, Tết hưởng nguyên lương.</c:when>
                                    <c:when test="${r.ruleKey == 'night_allowance_multiplier'}">Phụ cấp làm việc trong khung giờ ban đêm (từ 22:00 đến 06:00 sáng hôm sau).</c:when>
                                    <c:when test="${r.ruleKey == 'night_ot_multiplier'}">Thưởng bổ sung khi làm thêm giờ vào ban đêm (Night Overtime Bonus).</c:when>
                                    <c:when test="${r.ruleKey == 'grace_period_minutes'}">Thời gian đến trễ tối đa không bị áp dụng trừ phạt đi muộn.</c:when>
                                    <c:when test="${r.ruleKey == 'penalty_rate_per_minute'}">Mức tiền khấu trừ cho mỗi phút đi muộn vượt quá thời gian ân hạn.</c:when>
                                    <c:when test="${r.ruleKey == 'min_confidence'}">Ngưỡng điểm tin cậy cảm biến vân tay AS608 để hợp lệ hóa lượt chấm công.</c:when>
                                    <c:otherwise>Quy tắc mở rộng trong hệ thống.</c:otherwise>
                                </c:choose>
                            </div>
                        </td>
                        <td>
                            <div style="display:flex; align-items:center; gap:8px;">
                                <input type="number" step="any" name="rule_${r.ruleKey}" value="${r.value}" class="mono font-bold" style="max-width:140px; text-align:right;">
                                <span class="muted small">
                                    <c:choose>
                                        <c:when test="${r.ruleKey.contains('multiplier')}">hệ số</c:when>
                                        <c:when test="${r.ruleKey.contains('minutes')}">phút</c:when>
                                        <c:when test="${r.ruleKey.contains('rate')}">VNĐ/m</c:when>
                                        <c:when test="${r.ruleKey.contains('hours')}">giờ</c:when>
                                        <c:when test="${r.ruleKey.contains('confidence')}">%</c:when>
                                        <c:otherwise></c:otherwise>
                                    </c:choose>
                                </span>
                            </div>
                        </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>

        <div style="display:flex; justify-content:flex-end; gap:12px; margin-top:20px;">
            <button type="submit" class="btn">Lưu cấu hình quy tắc</button>
        </div>
    </div>
</form>

<!-- Công thức mẫu tham chiếu theo SRS Section 5 -->
<div class="card" style="background:#f8fafc;">
    <h3 style="font-size:15px; margin:0 0 10px 0; color:#1e293b;">📐 Công thức tính lương thực nhận (Net Salary Formula - SRS Section 5)</h3>
    <div class="mono small" style="background:#0f172a; color:#38bdf8; padding:16px; border-radius:8px; line-height:1.6;">
        Lương 1 giờ     = Lương cơ bản / Số giờ chuẩn (208h)<br>
        Lương cơ bản    = Giờ làm chuẩn × Lương 1 giờ<br>
        Lương làm thêm  = Σ (Giờ OT × Lương 1 giờ × Hệ số OT [150%, 200%, 300%])<br>
        Phụ cấp ca đêm  = Giờ đêm × Lương 1 giờ × 30%<br>
        Thưởng đêm OT   = Giờ đêm OT × Lương 1 giờ × 20%<br>
        Tiền phạt muộn  = Phút đi muộn sau ân hạn × Mức phạt (1.000 VNĐ)<br>
        ───────────────────────────────────────────────────────────────────────<br>
        <strong>LƯƠNG THỰC NHẬN = Lương chuẩn + Lương OT + Phụ cấp đêm + Thưởng đêm OT − Phạt muộn</strong>
    </div>
</div>

<%@include file="/WEB-INF/views/common/footer.jspf"%>
