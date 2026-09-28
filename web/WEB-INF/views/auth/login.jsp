<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Đăng nhập · SmartAttend</title>
    <link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app.css">
</head>
<body class="auth-body">
<div class="auth-card">
    <div class="auth-brand"><span class="brand-mark">SA</span></div>
    <h1>Smart Attendance</h1>
    <p class="muted">Hệ thống chấm công vân tay &amp; tính lương</p>

    <c:if test="${param.logout == '1'}"><div class="alert alert-success">Bạn đã đăng xuất.</div></c:if>
    <c:if test="${param.disabled == '1'}"><div class="alert alert-error">Tài khoản đã bị vô hiệu hóa.</div></c:if>
    <c:if test="${not empty error}"><div class="alert alert-error"><c:out value="${error}"/></div></c:if>

    <form method="post" action="${pageContext.request.contextPath}/login" class="form" novalidate>
        <label>Tên đăng nhập
            <input type="text" name="username" value="<c:out value='${username}'/>" autofocus autocomplete="username" required>
        </label>
        <label>Mật khẩu
            <input type="password" name="password" autocomplete="current-password" required>
        </label>
        <button type="submit" class="btn btn-block">Đăng nhập</button>
    </form>

    <details class="demo-accounts">
        <summary>Tài khoản demo</summary>
        <table>
            <tr><td>ADMIN</td><td>admin</td><td>Admin@123</td></tr>
            <tr><td>STAFF</td><td>tuan.le</td><td>Staff@123</td></tr>
            <tr><td>KIOSK</td><td>kiosk01</td><td>Kiosk@123</td></tr>
            <tr><td>Bị khóa</td><td>ngoc.ly</td><td>Staff@123</td></tr>
        </table>
    </details>
</div>
</body>
</html>
