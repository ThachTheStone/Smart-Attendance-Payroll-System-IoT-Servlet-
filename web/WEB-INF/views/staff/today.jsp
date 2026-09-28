<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="pageTitle" value="Hôm nay"/>
<c:set var="activeNav" value="today"/>
<%@ include file="../common/header.jspf" %>
<c:set var="e" value="${sessionScope.account.employee}"/>

<div class="page-head">
    <div>
        <h1>Xin chào, <c:out value="${e.fullName}"/> 👋</h1>
        <p class="muted">Trang nhân viên — bảng chấm công hôm nay sẽ có ở sprint sau.</p>
    </div>
</div>

<div class="card profile">
    <h2 class="section-title">Thông tin của bạn</h2>
    <dl>
        <dt>Mã nhân viên</dt><dd class="mono"><c:out value="${e.code}"/></dd>
        <dt>Phòng ban</dt><dd><c:out value="${e.department}"/></dd>
        <dt>Chức vụ</dt><dd><c:out value="${e.position}"/></dd>
        <dt>Email</dt><dd><c:out value="${e.email}"/></dd>
        <dt>Điện thoại</dt><dd><c:out value="${e.phone}"/></dd>
        <dt>Loại lương</dt><dd>${e.salaryType == 'HOURLY' ? 'Theo giờ' : 'Theo tháng'}</dd>
        <dt>Mức lương</dt><dd><fmt:formatNumber value="${e.baseSalary}" pattern="#,##0"/> VND</dd>
    </dl>
</div>

<%@ include file="../common/footer.jspf" %>
