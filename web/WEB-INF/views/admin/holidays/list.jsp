<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="pageTitle" value="Quản lý ngày lễ"/>
<c:set var="activeNav" value="holidays"/>
<%@ include file="../../common/header.jspf" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<div class="page-head">
    <div>
        <h1>🎉 Quản lý ngày lễ</h1>
        <p class="muted">Danh mục ngày nghỉ lễ công cộng áp dụng hệ số làm thêm 300% (FR-RULE-02, FR-RULE-06)</p>
    </div>
    <div style="display:flex; gap:10px;">
        <a class="btn btn-secondary" href="${ctx}/admin/shifts">⚙️ Ca làm việc</a>
        <a class="btn btn-secondary" href="${ctx}/admin/shifts/schedule">📅 Lịch xếp ca</a>
    </div>
</div>

<div style="display: grid; grid-template-columns: 2fr 1fr; gap: 24px; align-items: start;">
    <!-- Left: Holiday Table -->
    <div class="card" style="padding: 0; overflow: hidden;">
        <div style="padding: 16px 20px; border-bottom: 1px solid var(--line); font-weight: 600; font-size: 15px;">
            Danh sách ngày lễ chính thức
        </div>
        <div class="table-wrap">
            <table class="table">
                <thead>
                    <tr>
                        <th>Ngày</th>
                        <th>Tên ngày lễ</th>
                        <th style="text-align: right;">Thao tác</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="h" items="${holidays}">
                        <tr>
                            <td class="mono"><strong><c:out value="${h.date}"/></strong></td>
                            <td><c:out value="${h.name}"/></td>
                            <td style="text-align: right;">
                                <form action="${ctx}/admin/holidays" method="post" style="display: inline;" onsubmit="return confirm('Bạn có chắc muốn xóa ngày lễ này?');">
                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="date" value="${h.date}">
                                    <button type="submit" class="btn btn-ghost btn-sm" style="color: var(--danger);">Xóa</button>
                                </form>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty holidays}">
                        <tr><td colspan="3" style="text-align:center; padding: 24px;" class="muted">Chưa có ngày lễ nào trong hệ thống.</td></tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </div>

    <!-- Right: Add Holiday Form -->
    <div class="card">
        <h3 style="margin-top: 0; font-size: 16px;">➕ Thêm ngày lễ mới</h3>
        <form action="${ctx}/admin/holidays" method="post">
            <input type="hidden" name="action" value="add">

            <div style="margin-bottom: 14px;">
                <label style="display:block; font-weight:500; margin-bottom:4px; font-size:13px;">Ngày nghỉ <span style="color:red;">*</span></label>
                <input type="date" name="date" required style="width:100%; padding:8px 12px; border:1px solid var(--line); border-radius:6px; font-size:14px;">
            </div>

            <div style="margin-bottom: 20px;">
                <label style="display:block; font-weight:500; margin-bottom:4px; font-size:13px;">Tên ngày lễ <span style="color:red;">*</span></label>
                <input type="text" name="name" required style="width:100%; padding:8px 12px; border:1px solid var(--line); border-radius:6px; font-size:14px;"
                       placeholder="VD: Ngày Quốc tế Lao động">
            </div>

            <button type="submit" class="btn" style="width: 100%; justify-content: center;">Thêm ngày lễ</button>
        </form>
    </div>
</div>

<%@ include file="../../common/footer.jspf" %>
