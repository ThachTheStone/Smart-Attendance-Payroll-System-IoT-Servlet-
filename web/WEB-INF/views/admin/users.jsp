<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="pageTitle" value="Quản lý người dùng"/>
<c:set var="activeNav" value="users"/>
<%@ include file="../common/header.jspf" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<div class="page-head">
    <div>
        <h1>Quản lý người dùng</h1>
        <p class="muted">Tài khoản, vai trò và thông tin nhân viên</p>
    </div>
    <a class="btn" href="${ctx}/admin/users/create">+ Thêm người dùng</a>
</div>

<div class="stats">
    <div class="stat"><span class="stat-num">${totalCount}</span><span class="stat-label">Tổng tài khoản</span></div>
    <div class="stat"><span class="stat-num">${adminCount}</span><span class="stat-label">Admin</span></div>
    <div class="stat"><span class="stat-num">${staffCount}</span><span class="stat-label">Nhân viên</span></div>
    <div class="stat"><span class="stat-num">${inactiveCount}</span><span class="stat-label">Đã vô hiệu hóa</span></div>
</div>

<form class="filters" method="get" action="${ctx}/admin/users">
    <input type="search" name="q" value="<c:out value='${q}'/>" placeholder="Tìm username, họ tên, mã NV, email…">
    <select name="role">
        <option value="">Tất cả vai trò</option>
        <c:forEach var="r" items="${roles}">
            <option value="${r}" ${roleFilter == r.name() ? 'selected' : ''}>${r.label}</option>
        </c:forEach>
    </select>
    <select name="status">
        <option value="">Tất cả trạng thái</option>
        <option value="ACTIVE" ${statusFilter == 'ACTIVE' ? 'selected' : ''}>Đang hoạt động</option>
        <option value="INACTIVE" ${statusFilter == 'INACTIVE' ? 'selected' : ''}>Đã vô hiệu hóa</option>
    </select>
    <button class="btn btn-secondary" type="submit">Lọc</button>
    <c:if test="${not empty q or not empty roleFilter or not empty statusFilter}">
        <a class="btn btn-ghost" href="${ctx}/admin/users">Xóa lọc</a>
    </c:if>
</form>

<div class="table-wrap">
<table class="table">
    <thead>
    <tr>
        <th>Mã NV</th><th>Họ tên</th><th>Tên đăng nhập</th><th>Vai trò</th>
        <th>Phòng ban</th><th>Liên hệ</th><th>Đăng nhập gần nhất</th><th>Trạng thái</th><th></th>
    </tr>
    </thead>
    <tbody>
    <c:forEach var="u" items="${users}">
        <tr class="${u.active ? '' : 'row-inactive'}">
            <td class="mono"><c:out value="${u.employee.code}" default="—"/></td>
            <td>
                <b><c:out value="${u.employee.fullName}" default="(Máy kiosk)"/></b>
                <div class="muted small"><c:out value="${u.employee.position}"/></div>
            </td>
            <td class="mono"><c:out value="${u.username}"/></td>
            <td><span class="role-badge role-${u.role}">${u.role.label}</span></td>
            <td><c:out value="${u.employee.department}" default="—"/></td>
            <td class="small">
                <c:out value="${u.employee.email}"/><br><c:out value="${u.employee.phone}"/>
            </td>
            <td class="small">
                <c:choose>
                    <c:when test="${not empty u.lastLogin}">${u.lastLogin.toString().replace('T', ' ').substring(0, 16)}</c:when>
                    <c:otherwise><span class="muted">Chưa đăng nhập</span></c:otherwise>
                </c:choose>
            </td>
            <td>
                <span class="status status-${u.status}">${u.active ? 'Hoạt động' : 'Vô hiệu'}</span>
            </td>
            <td class="actions">
                <a href="${ctx}/admin/users/edit?id=${u.id}">Sửa</a>
                <a href="${ctx}/admin/users/reset-password?id=${u.id}">Đặt lại MK</a>
                <c:if test="${u.id != me.id}">
                    <form method="post" action="${ctx}/admin/users/status" class="inline"
                          onsubmit="return confirm('${u.active ? 'Vô hiệu hóa' : 'Kích hoạt'} tài khoản ${u.username}?')">
                        <input type="hidden" name="id" value="${u.id}">
                        <input type="hidden" name="status" value="${u.active ? 'INACTIVE' : 'ACTIVE'}">
                        <button type="submit" class="link ${u.active ? 'danger' : ''}">${u.active ? 'Khóa' : 'Mở khóa'}</button>
                    </form>
                </c:if>
            </td>
        </tr>
    </c:forEach>
    <c:if test="${empty users}">
        <tr><td colspan="9" class="empty">Không có người dùng nào phù hợp.</td></tr>
    </c:if>
    </tbody>
</table>
</div>
<p class="muted small">Hiển thị ${users.size()} / ${totalCount} tài khoản.</p>

<%@ include file="../common/footer.jspf" %>
