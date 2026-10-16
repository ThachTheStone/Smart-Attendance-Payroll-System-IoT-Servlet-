<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Sign In · SmartAttend</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app.css">
</head>
<body class="auth-body">
<div class="auth-card">
    <div class="auth-brand"><span class="brand-mark">SA</span></div>
    <h1>Smart Attendance</h1>
    <p class="muted">Biometric Attendance &amp; Automated Payroll</p>

    <c:if test="${param.logout == '1'}"><div class="alert alert-success">You have been logged out.</div></c:if>
    <c:if test="${param.disabled == '1'}"><div class="alert alert-error">Account has been deactivated.</div></c:if>
    <c:if test="${not empty error}"><div class="alert alert-error"><c:out value="${error}"/></div></c:if>

    <form method="post" action="${pageContext.request.contextPath}/login" class="form" novalidate>
        <label>Username
            <input type="text" name="username" value="<c:out value='${username}'/>" autofocus autocomplete="username" required>
        </label>
        <label>Password
            <input type="password" name="password" autocomplete="current-password" required>
        </label>
        <button type="submit" class="btn btn-block">Sign In</button>
    </form>


</div>
</body>
</html>
