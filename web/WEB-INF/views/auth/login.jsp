<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Sign In &bull; SmartAttend Enterprise</title>
    <meta name="description" content="SmartAttend - Biometric IoT Attendance & Automated Payroll System. Sign in to manage your workforce.">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/fonts.css?v=5">
    <link rel="icon" type="image/svg+xml" href="${pageContext.request.contextPath}/assets/img/logo.svg">
    <style>
        body {
            margin: 0;
            min-height: 100vh;
            background: #f8fafc;
            color: #0f172a;
            display: flex;
            align-items: center;
            justify-content: center;
            font-family: var(--font-body);
        }

        .login-layout {
            display: grid;
            grid-template-columns: 1fr 1fr;
            min-height: 100vh;
            width: 100%;
        }

        /* Left: Brand Showcase Panel (Executive & Trustworthy Light Style) */
        .login-brand-panel {
            position: relative;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            padding: 60px 48px;
            background: #f1f5f9;
            border-right: 1px solid #e2e8f0;
        }

        .brand-container {
            max-width: 440px;
            width: 100%;
        }

        .brand-badge-box {
            display: inline-flex;
            align-items: center;
            gap: 10px;
            padding: 6px 14px;
            background: #eff6ff;
            border: 1px solid #bfdbfe;
            border-radius: 999px;
            color: #1d4ed8;
            font-size: 12px;
            font-weight: 600;
            margin-bottom: 24px;
        }
        .brand-badge-dot {
            width: 7px;
            height: 7px;
            border-radius: 50%;
            background: #059669;
        }

        .brand-title {
            font-size: 32px;
            font-weight: 800;
            color: #0f172a;
            letter-spacing: -0.03em;
            margin-bottom: 12px;
            line-height: 1.25;
        }
        .brand-desc {
            font-size: 14px;
            color: #475569;
            line-height: 1.6;
            margin-bottom: 36px;
        }

        /* Feature List (Clean & Credible) */
        .feature-list {
            display: flex;
            flex-direction: column;
            gap: 18px;
            margin-bottom: 40px;
        }
        .feature-item {
            display: flex;
            align-items: flex-start;
            gap: 14px;
        }
        .feature-icon {
            width: 36px;
            height: 36px;
            border-radius: 8px;
            background: #ffffff;
            border: 1px solid #e2e8f0;
            color: #1d4ed8;
            display: grid;
            place-items: center;
            flex-shrink: 0;
            box-shadow: 0 1px 2px rgba(0, 0, 0, 0.04);
        }
        .feature-title {
            font-size: 13px;
            font-weight: 600;
            color: #0f172a;
            margin-bottom: 2px;
        }
        .feature-text {
            font-size: 12px;
            color: #64748b;
            line-height: 1.45;
        }

        /* Hardware Spec Pills */
        .spec-pills {
            display: flex;
            flex-wrap: wrap;
            gap: 8px;
            border-top: 1px solid #e2e8f0;
            padding-top: 24px;
        }
        .spec-pill {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 5px 12px;
            border-radius: 6px;
            background: #ffffff;
            border: 1px solid #e2e8f0;
            color: #475569;
            font-size: 11px;
            font-weight: 600;
            font-family: 'JetBrains Mono', monospace;
            box-shadow: 0 1px 2px rgba(0, 0, 0, 0.03);
        }

        /* Right: Login Form Panel */
        .login-form-panel {
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            padding: 48px;
            background: #ffffff;
        }

        .login-card {
            width: 100%;
            max-width: 420px;
        }

        .login-back-link {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            font-size: 12px;
            font-weight: 600;
            color: #64748b;
            margin-bottom: 20px;
            text-decoration: none;
            transition: color 150ms ease;
        }
        .login-back-link:hover {
            color: #1d4ed8;
            text-decoration: none;
        }

        .login-header {
            margin-bottom: 28px;
        }
        .login-header .brand-mark {
            width: 44px;
            height: 44px;
            font-size: 16px;
            border-radius: 10px;
            margin-bottom: 18px;
            background: linear-gradient(135deg, #1d4ed8 0%, #2563eb 100%);
            box-shadow: 0 2px 6px rgba(29, 78, 216, 0.25);
        }
        .login-welcome {
            font-size: 22px;
            font-weight: 700;
            color: #0f172a;
            letter-spacing: -0.02em;
            margin-bottom: 6px;
        }
        .login-desc {
            color: #64748b;
            font-size: 13px;
        }

        .login-form {
            display: flex;
            flex-direction: column;
            gap: 18px;
        }

        .input-group {
            display: flex;
            flex-direction: column;
            gap: 6px;
        }
        .input-group-label {
            font-size: 12px;
            font-weight: 600;
            color: #334155;
        }
        .input-group input {
            width: 100%;
            padding: 10px 14px;
            border: 1px solid #cbd5e1 !important;
            border-radius: 8px;
            font-size: 13px;
            background: #ffffff !important;
            color: #0f172a !important;
            transition: border-color 150ms ease, box-shadow 150ms ease;
        }
        .input-group input:focus {
            border-color: #1d4ed8 !important;
            box-shadow: 0 0 0 3px rgba(29, 78, 216, 0.12) !important;
        }

        .login-submit {
            padding: 11px 20px;
            background: #1d4ed8;
            color: #ffffff;
            border: 1px solid #1e40af;
            border-radius: 8px;
            font-family: inherit;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            transition: background-color 150ms ease, transform 150ms ease;
            box-shadow: 0 1px 3px rgba(29, 78, 216, 0.2);
            margin-top: 4px;
        }
        .login-submit:hover {
            background: #1e40af;
            transform: translateY(-1px);
        }
        .login-submit:active {
            transform: translateY(0);
        }

        /* Demo Quick-fill Section */
        .demo-section {
            margin-top: 24px;
            background: #f8fafc;
            border: 1px solid #e2e8f0;
            border-radius: 10px;
            padding: 16px;
        }
        .demo-section-head {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 12px;
        }
        .demo-section-title {
            font-size: 12px;
            font-weight: 600;
            color: #334155;
        }
        .demo-section-hint {
            font-size: 11px;
            color: #64748b;
        }
        .demo-role-btn {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 10px 12px;
            border-radius: 7px;
            border: 1px solid #e2e8f0;
            background: #ffffff;
            cursor: pointer;
            transition: all 150ms ease;
            width: 100%;
            text-align: left;
            margin-bottom: 8px;
            font-family: inherit;
            box-shadow: 0 1px 2px rgba(0, 0, 0, 0.02);
        }
        .demo-role-btn:last-child { margin-bottom: 0; }
        .demo-role-btn:hover {
            border-color: #bfdbfe;
            background: #eff6ff;
            transform: translateY(-1px);
        }
        .demo-role-left {
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .demo-role-icon {
            width: 32px;
            height: 32px;
            border-radius: 6px;
            display: grid;
            place-items: center;
            flex-shrink: 0;
            font-size: 12px;
        }
        .demo-role-icon.admin { background: #eff6ff; color: #1d4ed8; }
        .demo-role-icon.staff { background: #ecfdf5; color: #059669; }
        .demo-role-icon.kiosk { background: #f5f3ff; color: #7c3aed; }
        .demo-role-name {
            font-weight: 600;
            font-size: 12px;
            color: #0f172a;
        }
        .demo-role-desc {
            font-size: 11px;
            color: #64748b;
        }
        .demo-role-creds {
            font-family: 'JetBrains Mono', monospace;
            font-size: 11px;
            color: #64748b;
            text-align: right;
            background: #f1f5f9;
            padding: 2px 6px;
            border-radius: 4px;
        }

        @media (max-width: 900px) {
            .login-layout { grid-template-columns: 1fr; }
            .login-brand-panel { display: none; }
            .login-form-panel { padding: 32px 20px; }
        }
    </style>
</head>
<body>
<div class="login-layout">
    <!-- Left: Brand Showcase -->
    <div class="login-brand-panel">
        <div class="brand-container">
            <div class="brand-badge-box">
                <span class="brand-badge-dot"></span>
                <span>AS608 Optical Sensor &bull; Terminal Online</span>
            </div>

            <h1 class="brand-title">
                Smart Attendance &amp;<br>Automated Payroll
            </h1>
            <p class="brand-desc">
                High-precision biometric attendance verification with IoT terminals 
                and automated rule-based payroll calculations.
            </p>

            <div class="feature-list">
                <div class="feature-item">
                    <div class="feature-icon">
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <path d="M2 12C2 6.5 6.5 2 12 2a10 10 0 0 1 8 4"/>
                            <path d="M5 19.5C5.5 18 6 15 6 12c0-3.5 2.5-6 6-6"/>
                            <path d="M12 10c-1.1 0-2 .9-2 2 0 3-1.5 5.5-3 7"/>
                        </svg>
                    </div>
                    <div>
                        <div class="feature-title">Fast Biometric Verification</div>
                        <div class="feature-text">Under 1.0s optical fingerprint matching with template storage in AS608 hardware.</div>
                    </div>
                </div>

                <div class="feature-item">
                    <div class="feature-icon">
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <rect x="3" y="4" width="18" height="18" rx="2" ry="2"/>
                            <line x1="16" y1="2" x2="16" y2="6"/>
                            <line x1="8" y1="2" x2="8" y2="6"/>
                            <line x1="3" y1="10" x2="21" y2="10"/>
                        </svg>
                    </div>
                    <div>
                        <div class="feature-title">Automated Shift &amp; Timesheets</div>
                        <div class="feature-text">Real-time attendance logs, late penalty grace periods, and overtime multiplier rules.</div>
                    </div>
                </div>

                <div class="feature-item">
                    <div class="feature-icon">
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <line x1="12" y1="1" x2="12" y2="23"/>
                            <path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"/>
                        </svg>
                    </div>
                    <div>
                        <div class="feature-title">One-Click Payroll Engine</div>
                        <div class="feature-text">Instant monthly salary calculation with tax, insurance deductions, and PDF payslips.</div>
                    </div>
                </div>
            </div>

            <div class="spec-pills">
                <span class="spec-pill">ESP32 MCU</span>
                <span class="spec-pill">AS608 Optical</span>
                <span class="spec-pill">Java Servlet 4.0</span>
                <span class="spec-pill">SQL Server</span>
            </div>
        </div>
    </div>

    <!-- Right: Login Form -->
    <div class="login-form-panel">
        <div class="login-card">
            <a href="${pageContext.request.contextPath}/" class="login-back-link">
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M19 12H5M12 19l-7-7 7-7"/></svg>
                Back to Home / Product Overview
            </a>

            <div class="login-header">
                <span class="brand-mark"><img src="${pageContext.request.contextPath}/assets/img/logo-mark.svg" alt="" aria-hidden="true"></span>
                <h2 class="login-welcome">Sign in to your account</h2>
                <p class="login-desc">Enter your credentials to access the SmartAttend portal</p>
            </div>

            <c:if test="${param.logout == '1'}">
                <div class="alert alert-success">You have been logged out successfully.</div>
            </c:if>
            <c:if test="${param.disabled == '1'}">
                <div class="alert alert-error">Account has been deactivated. Please contact HR.</div>
            </c:if>
            <c:if test="${not empty error}">
                <div class="alert alert-error"><c:out value="${error}"/></div>
            </c:if>

            <form method="post" action="${pageContext.request.contextPath}/login" class="login-form" id="loginForm" novalidate>
                <div class="input-group">
                    <span class="input-group-label">Username</span>
                    <input type="text" name="username" id="usernameInput" value="<c:out value='${username}'/>" 
                           autofocus autocomplete="username" required placeholder="Enter username (e.g. admin)">
                </div>
                <div class="input-group">
                    <span class="input-group-label">Password</span>
                    <input type="password" name="password" id="passwordInput" 
                           autocomplete="current-password" required placeholder="Enter password">
                </div>
                <button type="submit" class="login-submit" id="loginSubmitBtn">
                    Sign In
                </button>
            </form>

            <!-- Quick-Fill Demo Section -->
            <div class="demo-section">
                <div class="demo-section-head">
                    <span class="demo-section-title">Quick-Fill Demo Roles</span>
                    <span class="demo-section-hint">Click to auto-fill</span>
                </div>
                <button type="button" class="demo-role-btn" onclick="fillCreds('admin', 'Admin@123')">
                    <div class="demo-role-left">
                        <div class="demo-role-icon admin">
                            <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 15a3 3 0 1 0 0-6 3 3 0 0 0 0 6z"/><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-2 2 2 2 0 0 1-2-2v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83 0 2 2 0 0 1 0-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1-2-2 2 2 0 0 1 2-2h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 0-2.83 2 2 0 0 1 2.83 0l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 2-2 2 2 0 0 1 2 2v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 0 2 2 0 0 1 0 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 2 2 2 2 0 0 1-2 2h-.09a1.65 1.65 0 0 0-1.51 1z"/></svg>
                        </div>
                        <div>
                            <div class="demo-role-name">HR Administrator</div>
                            <div class="demo-role-desc">Full administrative privileges</div>
                        </div>
                    </div>
                    <span class="demo-role-creds">admin</span>
                </button>
                <button type="button" class="demo-role-btn" onclick="fillCreds('tuan.le', 'Staff@123')">
                    <div class="demo-role-left">
                        <div class="demo-role-icon staff">
                            <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                        </div>
                        <div>
                            <div class="demo-role-name">Employee (Staff)</div>
                            <div class="demo-role-desc">Personal schedule &amp; payslips</div>
                        </div>
                    </div>
                    <span class="demo-role-creds">tuan.le</span>
                </button>
                <button type="button" class="demo-role-btn" onclick="fillCreds('kiosk01', 'Kiosk@123')">
                    <div class="demo-role-left">
                        <div class="demo-role-icon kiosk">
                            <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="2" y="3" width="20" height="14" rx="2" ry="2"/><line x1="8" y1="21" x2="16" y2="21"/><line x1="12" y1="17" x2="12" y2="21"/></svg>
                        </div>
                        <div>
                            <div class="demo-role-name">Biometric Terminal</div>
                            <div class="demo-role-desc">Wall-mounted kiosk mode</div>
                        </div>
                    </div>
                    <span class="demo-role-creds">kiosk01</span>
                </button>
            </div>
        </div>
    </div>
</div>

<script>
    function fillCreds(u, p) {
        document.getElementById('usernameInput').value = u;
        document.getElementById('passwordInput').value = p;
        document.getElementById('passwordInput').focus();
    }
</script>
</body>
</html>
