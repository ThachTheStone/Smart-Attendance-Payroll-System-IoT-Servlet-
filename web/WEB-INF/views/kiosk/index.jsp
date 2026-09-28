<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Kiosk · SmartAttend</title>
    <link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app.css">
</head>
<body class="kiosk-body">
<div class="kiosk-top">
    <span><span class="brand-mark">SA</span> Kiosk · <c:out value="${sessionScope.account.username}"/></span>
    <a href="${pageContext.request.contextPath}/logout">Đăng xuất</a>
</div>
<div class="kiosk-idle">
    <div id="clock" class="kiosk-clock">--:--:--</div>
    <div id="date" class="kiosk-date"></div>
    <div class="kiosk-finger" aria-hidden="true">
        <svg viewBox="0 0 64 64" width="120" height="120" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round">
            <path d="M20 50c-3-6-4-12-4-18a16 16 0 0 1 32 0c0 4-1 8-2 11"/>
            <path d="M26 54c-3-6-4-14-4-22a10 10 0 0 1 20 0c0 7-1 13-3 18"/>
            <path d="M32 32c0 9-1 16-4 24"/><path d="M38 34c0 6-1 11-2 15"/>
            <path d="M14 22a20 20 0 0 1 36 0"/>
        </svg>
    </div>
    <div class="kiosk-msg">Đặt ngón tay lên cảm biến</div>
    <div class="muted">(Nhận sự kiện vân tay qua SSE sẽ làm ở sprint sau)</div>
</div>
<script>
    function tick() {
        var d = new Date();
        document.getElementById('clock').textContent = d.toLocaleTimeString('vi-VN', {hour12: false});
        document.getElementById('date').textContent = d.toLocaleDateString('vi-VN',
            {weekday: 'long', day: '2-digit', month: '2-digit', year: 'numeric'});
    }
    tick(); setInterval(tick, 1000);
</script>
</body>
</html>
