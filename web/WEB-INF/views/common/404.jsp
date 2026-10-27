<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>404 · Page Not Found · SmartAttend</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/fonts.css?v=5">
    <link rel="icon" type="image/svg+xml" href="${pageContext.request.contextPath}/assets/img/logo.svg">
    <style>
        body.error-page-body {
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            background: #f8fafc;
            padding: 20px;
            margin: 0;
            font-family: var(--font-body);
            color: #0f172a;
        }
        .error-card {
            max-width: 480px;
            width: 100%;
            background: #ffffff;
            border: 1px solid #e2e8f0;
            border-radius: var(--radius-lg, 12px);
            padding: 44px 36px;
            text-align: center;
            box-shadow: 0 10px 25px rgba(0, 0, 0, 0.04);
            position: relative;
        }
        .error-icon {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 60px;
            height: 60px;
            border-radius: 12px;
            background: #eff6ff;
            color: #1d4ed8;
            margin-bottom: 16px;
            border: 1px solid #bfdbfe;
        }
        .error-code {
            font-family: 'JetBrains Mono', monospace;
            font-size: 56px;
            font-weight: 700;
            line-height: 1;
            color: #1d4ed8;
            letter-spacing: -1.5px;
            margin-bottom: 12px;
        }
        .error-title {
            font-size: 20px;
            font-weight: 700;
            color: #0f172a;
            margin: 0 0 10px 0;
        }
        .error-desc {
            color: #64748b;
            font-size: 14px;
            line-height: 1.6;
            margin-bottom: 28px;
        }
    </style>
</head>
<body class="error-page-body">
    <div class="error-card">
        <div class="error-icon">
            <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <circle cx="12" cy="12" r="10"></circle>
                <polygon points="16.24 7.76 14.12 14.12 7.76 16.24 9.88 9.88 16.24 7.76"></polygon>
            </svg>
        </div>
        <div class="error-code">404</div>
        <h1 class="error-title">Page Not Found</h1>
        <p class="error-desc">
            The page or endpoint you are looking for does not exist, has been moved, or is temporarily unavailable in the portal.
        </p>
        <div style="display: flex; gap: 10px; justify-content: center;">
            <a class="btn btn-primary" href="${pageContext.request.contextPath}/" style="padding: 10px 24px;">
                Return to Home
            </a>
            <a class="btn btn-secondary" href="javascript:history.back()" style="padding: 10px 18px;">
                Go Back
            </a>
        </div>
    </div>
</body>
</html>
