<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="pageTitle" value="${form.create ? 'Thêm người dùng' : 'Sửa người dùng'}"/>
<c:set var="activeNav" value="users"/>
<%@ include file="../common/header.jspf" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<div class="page-head">
    <div>
        <a class="back" href="${ctx}/admin/users">← Danh sách người dùng</a>
        <h1>${pageTitle}</h1>
    </div>
</div>

<c:if test="${not empty errors}">
    <div class="alert alert-error">Có ${errors.size()} lỗi, vui lòng kiểm tra lại các ô được đánh dấu.</div>
</c:if>

<form method="post" class="card form-grid" novalidate
      action="${ctx}/admin/users/${form.create ? 'create' : 'edit'}">
    <c:if test="${not form.create}"><input type="hidden" name="id" value="${form.accountId}"></c:if>

    <h2 class="section-title">Tài khoản</h2>

    <label class="${not empty errors.role ? 'has-error' : ''}">Vai trò *
        <select name="role" id="role">
            <c:forEach var="r" items="${roles}">
                <option value="${r}" ${form.role == r.name() ? 'selected' : ''}>${r.label} (${r})</option>
            </c:forEach>
        </select>
        <span class="err"><c:out value="${errors.role}"/></span>
    </label>

    <label class="${not empty errors.username ? 'has-error' : ''}">Tên đăng nhập *
        <input type="text" name="username" value="<c:out value='${form.username}'/>"
               ${form.create ? '' : 'readonly'} maxlength="30" placeholder="vd: an.nguyen">
        <span class="hint">4-30 ký tự: a-z, 0-9, dấu . và _</span>
        <span class="err"><c:out value="${errors.username}"/></span>
    </label>

    <c:if test="${form.create}">
        <label class="${not empty errors.password ? 'has-error' : ''}">Mật khẩu *
            <input type="password" name="password" maxlength="50" autocomplete="new-password">
            <span class="hint">≥ 8 ký tự, có chữ hoa, chữ thường, số, ký tự đặc biệt</span>
            <span class="err"><c:out value="${errors.password}"/></span>
        </label>
        <label class="${not empty errors.confirmPassword ? 'has-error' : ''}">Nhập lại mật khẩu *
            <input type="password" name="confirmPassword" maxlength="50" autocomplete="new-password">
            <span class="err"><c:out value="${errors.confirmPassword}"/></span>
        </label>
    </c:if>

    <div id="employee-fields" class="form-grid-inner">
        <h2 class="section-title">Thông tin nhân viên</h2>

        <label class="${not empty errors.code ? 'has-error' : ''}">Mã nhân viên *
            <input type="text" name="code" value="<c:out value='${form.code}'/>" ${form.create ? '' : 'readonly'} maxlength="8">
            <span class="err"><c:out value="${errors.code}"/></span>
        </label>

        <label class="${not empty errors.fullName ? 'has-error' : ''}">Họ và tên *
            <input type="text" name="fullName" value="<c:out value='${form.fullName}'/>" maxlength="100">
            <span class="err"><c:out value="${errors.fullName}"/></span>
        </label>

        <label class="${not empty errors.email ? 'has-error' : ''}">Email *
            <input type="email" name="email" value="<c:out value='${form.email}'/>" maxlength="100">
            <span class="err"><c:out value="${errors.email}"/></span>
        </label>

        <label class="${not empty errors.phone ? 'has-error' : ''}">Số điện thoại *
            <input type="tel" name="phone" value="<c:out value='${form.phone}'/>" maxlength="10" placeholder="09xxxxxxxx">
            <span class="err"><c:out value="${errors.phone}"/></span>
        </label>

        <label class="${not empty errors.department ? 'has-error' : ''}">Phòng ban *
            <select name="department">
                <option value="">-- Chọn phòng ban --</option>
                <c:forEach var="d" items="${departments}">
                    <option ${form.department == d ? 'selected' : ''}><c:out value="${d}"/></option>
                </c:forEach>
            </select>
            <span class="err"><c:out value="${errors.department}"/></span>
        </label>

        <label class="${not empty errors.position ? 'has-error' : ''}">Chức vụ *
            <input type="text" name="position" value="<c:out value='${form.position}'/>" maxlength="50">
            <span class="err"><c:out value="${errors.position}"/></span>
        </label>

        <label class="${not empty errors.salaryType ? 'has-error' : ''}">Loại lương *
            <select name="salaryType">
                <option value="MONTHLY" ${form.salaryType == 'MONTHLY' ? 'selected' : ''}>Theo tháng</option>
                <option value="HOURLY" ${form.salaryType == 'HOURLY' ? 'selected' : ''}>Theo giờ</option>
            </select>
            <span class="err"><c:out value="${errors.salaryType}"/></span>
        </label>

        <label class="${not empty errors.baseSalary ? 'has-error' : ''}">Mức lương (VND) *
            <input type="text" name="baseSalary" value="<c:out value='${form.baseSalary}'/>" inputmode="numeric" placeholder="8320000">
            <span class="err"><c:out value="${errors.baseSalary}"/></span>
        </label>
    </div>

    <div class="form-actions">
        <a class="btn btn-ghost" href="${ctx}/admin/users">Hủy</a>
        <button class="btn" type="submit">${form.create ? 'Tạo người dùng' : 'Lưu thay đổi'}</button>
    </div>
</form>

<script>
    // Tai khoan KIOSK khong gan voi nhan vien -> an phan thong tin nhan vien
    (function () {
        var role = document.getElementById('role');
        var box = document.getElementById('employee-fields');
        function sync() { box.style.display = role.value === 'KIOSK' ? 'none' : ''; }
        role.addEventListener('change', sync);
        sync();
    })();
</script>

<%@ include file="../common/footer.jspf" %>
