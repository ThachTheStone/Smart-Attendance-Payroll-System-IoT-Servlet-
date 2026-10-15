<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Attendance Kiosk · SmartAttend</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=JetBrains+Mono:wght@500;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --bg: #090d16;
            --surface: #111827;
            --surface-glass: rgba(17, 24, 39, 0.85);
            --border: rgba(255, 255, 255, 0.1);
            --primary: #3b82f6;
            --primary-glow: rgba(59, 130, 246, 0.35);
            --success: #10b981;
            --success-glow: rgba(16, 185, 129, 0.35);
            --danger: #ef4444;
            --danger-glow: rgba(239, 68, 68, 0.35);
            --warning: #f59e0b;
            --text-main: #f9fafb;
            --text-muted: #9ca3af;
        }

        * { box-sizing: border-box; margin: 0; padding: 0; }

        body {
            font-family: 'Plus Jakarta Sans', system-ui, sans-serif;
            background: radial-gradient(circle at 50% 20%, #1e293b 0%, #090d16 80%);
            color: var(--text-main);
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            overflow: hidden;
            user-select: none;
        }

        /* Topbar Header */
        .kiosk-nav {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 16px 32px;
            background: var(--surface-glass);
            backdrop-filter: blur(12px);
            border-bottom: 1px solid var(--border);
            z-index: 10;
        }

        .brand-box {
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .brand-badge {
            width: 38px;
            height: 38px;
            border-radius: 10px;
            background: linear-gradient(135deg, #2563eb, #3b82f6);
            display: grid;
            place-items: center;
            font-weight: 800;
            font-size: 14px;
            letter-spacing: 0.5px;
            color: white;
            box-shadow: 0 0 15px var(--primary-glow);
        }

        .brand-title {
            font-weight: 700;
            font-size: 17px;
            letter-spacing: 0.3px;
        }

        .kiosk-account {
            font-size: 13px;
            color: var(--text-muted);
            margin-left: 8px;
            padding-left: 8px;
            border-left: 1px solid rgba(255,255,255,0.15);
        }

        .nav-actions {
            display: flex;
            align-items: center;
            gap: 16px;
        }

        .sse-indicator {
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 13px;
            font-weight: 500;
            padding: 6px 14px;
            border-radius: 999px;
            background: rgba(255,255,255,0.05);
            border: 1px solid var(--border);
        }

        .dot-pulse {
            width: 9px;
            height: 9px;
            border-radius: 50%;
            background: var(--success);
            box-shadow: 0 0 10px var(--success);
            animation: blink 2s infinite;
        }

        .dot-offline {
            background: var(--danger);
            box-shadow: 0 0 10px var(--danger);
            animation: none;
        }

        @keyframes blink {
            0%, 100% { opacity: 1; transform: scale(1); }
            50% { opacity: 0.4; transform: scale(0.85); }
        }

        .btn-fullscreen, .btn-exit {
            background: rgba(255,255,255,0.07);
            color: var(--text-main);
            border: 1px solid var(--border);
            padding: 8px 14px;
            border-radius: 8px;
            font-size: 13px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s ease;
            text-decoration: none;
        }

        .btn-fullscreen:hover, .btn-exit:hover {
            background: rgba(255,255,255,0.15);
        }

        /* Device Offline Floating Banner (FR-KIOSK-06) */
        #offlineBanner {
            display: none;
            position: fixed;
            top: 72px;
            left: 50%;
            transform: translateX(-50%);
            z-index: 100;
            background: linear-gradient(135deg, #b91c1c, #dc2626);
            color: white;
            padding: 12px 28px;
            border-radius: 999px;
            box-shadow: 0 10px 25px rgba(220, 38, 38, 0.4);
            font-size: 14px;
            font-weight: 600;
            align-items: center;
            gap: 10px;
            animation: slideDown 0.3s ease-out;
        }

        @keyframes slideDown {
            from { transform: translate(-50%, -20px); opacity: 0; }
            to { transform: translate(-50%, 0); opacity: 1; }
        }

        /* Main Workspace Stage */
        .stage {
            flex: 1;
            display: flex;
            align-items: center;
            justify-content: center;
            position: relative;
            padding: 24px;
        }

        /* 1. IDLE STATE VIEW (FR-KIOSK-02) */
        .view-idle {
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            text-align: center;
            animation: fadeIn 0.4s ease-out;
        }

        .clock-display {
            font-family: 'JetBrains Mono', monospace;
            font-size: 108px;
            font-weight: 700;
            letter-spacing: -2px;
            background: linear-gradient(180deg, #ffffff 30%, #94a3b8 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            text-shadow: 0 10px 30px rgba(0,0,0,0.5);
            line-height: 1;
        }

        .date-display {
            font-size: 22px;
            font-weight: 500;
            color: var(--text-muted);
            margin-top: 14px;
            text-transform: capitalize;
        }

        .scanner-halo {
            position: relative;
            margin: 40px 0 24px;
            width: 170px;
            height: 170px;
            display: grid;
            place-items: center;
        }

        .scanner-ring {
            position: absolute;
            inset: 0;
            border-radius: 50%;
            border: 2px dashed rgba(59, 130, 246, 0.4);
            animation: rotateRing 16s linear infinite;
        }

        .scanner-glow {
            position: absolute;
            inset: 15px;
            border-radius: 50%;
            background: radial-gradient(circle, var(--primary-glow) 0%, transparent 70%);
            animation: breathGlow 2.5s ease-in-out infinite;
        }

        @keyframes rotateRing {
            from { transform: rotate(0deg); }
            to { transform: rotate(360deg); }
        }

        @keyframes breathGlow {
            0%, 100% { opacity: 0.4; transform: scale(0.9); }
            50% { opacity: 1; transform: scale(1.1); }
        }

        .fingerprint-icon {
            color: var(--primary);
            width: 80px;
            height: 80px;
            z-index: 2;
            filter: drop-shadow(0 0 18px var(--primary-glow));
        }

        .prompt-title {
            font-size: 26px;
            font-weight: 700;
            letter-spacing: 0.3px;
            color: #e2e8f0;
        }

        .prompt-subtitle {
            font-size: 15px;
            color: var(--text-muted);
            margin-top: 8px;
        }

        /* 2. SUCCESS STATE VIEW (FR-KIOSK-03) */
        .view-success {
            display: none;
            width: 100%;
            max-width: 620px;
            background: rgba(17, 24, 39, 0.9);
            border: 2px solid var(--success);
            border-radius: 24px;
            padding: 40px;
            text-align: center;
            box-shadow: 0 20px 60px var(--success-glow);
            animation: popIn 0.35s cubic-bezier(0.175, 0.885, 0.32, 1.275);
            position: relative;
            overflow: hidden;
        }

        /* 3. FAIL / NOT RECOGNIZED VIEW (FR-KIOSK-04) */
        .view-fail {
            display: none;
            width: 100%;
            max-width: 580px;
            background: rgba(17, 24, 39, 0.9);
            border: 2px solid var(--danger);
            border-radius: 24px;
            padding: 40px;
            text-align: center;
            box-shadow: 0 20px 60px var(--danger-glow);
            animation: popIn 0.35s cubic-bezier(0.175, 0.885, 0.32, 1.275);
            position: relative;
        }

        /* 4. ENROLLMENT GUIDANCE VIEW (FR-KIOSK-05) */
        .view-enroll {
            display: none;
            width: 100%;
            max-width: 620px;
            background: rgba(17, 24, 39, 0.9);
            border: 2px solid var(--primary);
            border-radius: 24px;
            padding: 40px;
            text-align: center;
            box-shadow: 0 20px 60px var(--primary-glow);
            animation: popIn 0.35s cubic-bezier(0.175, 0.885, 0.32, 1.275);
            position: relative;
        }

        @keyframes popIn {
            0% { transform: scale(0.85); opacity: 0; }
            100% { transform: scale(1); opacity: 1; }
        }

        @keyframes fadeIn {
            from { opacity: 0; }
            to { opacity: 1; }
        }

        .avatar-circle {
            width: 100px;
            height: 100px;
            border-radius: 50%;
            background: #1e293b;
            border: 3px solid #334155;
            margin: 0 auto 16px;
            display: grid;
            place-items: center;
            font-size: 36px;
            font-weight: 700;
            color: #94a3b8;
            overflow: hidden;
            box-shadow: 0 8px 20px rgba(0,0,0,0.3);
        }

        .avatar-circle img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        .action-banner {
            display: inline-block;
            padding: 8px 24px;
            border-radius: 999px;
            font-size: 15px;
            font-weight: 800;
            letter-spacing: 1px;
            text-transform: uppercase;
            margin-bottom: 12px;
        }

        .banner-checkin { background: #065f46; color: #34d399; border: 1px solid #059669; }
        .banner-checkout { background: #1e3a8a; color: #60a5fa; border: 1px solid #2563eb; }

        .emp-name {
            font-size: 30px;
            font-weight: 800;
            margin-bottom: 6px;
        }

        .emp-meta {
            font-size: 15px;
            color: var(--text-muted);
            margin-bottom: 20px;
        }

        .scan-stats-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 12px;
            background: rgba(255, 255, 255, 0.04);
            border: 1px solid rgba(255, 255, 255, 0.08);
            border-radius: 16px;
            padding: 16px;
            margin-bottom: 24px;
        }

        .scan-stat-col .label {
            font-size: 12px;
            color: var(--text-muted);
            margin-bottom: 4px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .scan-stat-col .val {
            font-size: 17px;
            font-weight: 700;
            font-family: 'JetBrains Mono', monospace;
        }

        .status-pill {
            display: inline-block;
            padding: 3px 10px;
            border-radius: 6px;
            font-size: 13px;
            font-weight: 700;
        }
        .pill-ON_TIME { background: #064e3b; color: #6ee7b7; }
        .pill-LATE { background: #78350f; color: #fde68a; }
        .pill-EARLY_LEAVE { background: #7c2d12; color: #fed7aa; }
        .pill-OVERTIME { background: #4c1d95; color: #ddd6fe; }

        /* Countdown Progress Bar */
        .countdown-wrap {
            height: 6px;
            width: 100%;
            background: rgba(255, 255, 255, 0.1);
            border-radius: 999px;
            overflow: hidden;
            position: absolute;
            bottom: 0;
            left: 0;
        }

        .countdown-bar {
            height: 100%;
            width: 100%;
            background: var(--success);
            transition: width 0.1s linear;
        }

        .countdown-bar.danger {
            background: var(--danger);
        }

        .countdown-bar.primary {
            background: var(--primary);
        }

        /* Enrollment Steps UI */
        .step-indicators {
            display: flex;
            justify-content: center;
            gap: 16px;
            margin: 20px 0;
        }

        .step-dot {
            width: 32px;
            height: 32px;
            border-radius: 50%;
            background: rgba(255,255,255,0.1);
            color: var(--text-muted);
            display: grid;
            place-items: center;
            font-weight: 700;
            font-size: 13px;
        }

        .step-dot.active {
            background: var(--primary);
            color: white;
            box-shadow: 0 0 12px var(--primary-glow);
        }

        .step-dot.completed {
            background: var(--success);
            color: white;
        }

        /* Footer Info */
        .kiosk-footer {
            padding: 12px 32px;
            text-align: center;
            font-size: 13px;
            color: rgba(255, 255, 255, 0.35);
        }
    </style>
</head>
<body>

    <!-- Top Navigation -->
    <header class="kiosk-nav">
        <div class="brand-box">
            <div class="brand-badge">SA</div>
            <div class="brand-title">SmartAttend Kiosk</div>
            <div class="kiosk-account">ID: <c:out value="${sessionScope.account.username}"/></div>
        </div>
        <div class="nav-actions">
            <div class="sse-indicator" id="sseBadge">
                <span class="dot-pulse" id="sseDot"></span>
                <span id="sseStatusText">Server Connected</span>
            </div>
            <button type="button" class="btn-fullscreen" onclick="toggleFullscreen()" id="btnFullscreen">Fullscreen</button>
            <a href="${pageContext.request.contextPath}/logout" class="btn-exit">Sign Out</a>
        </div>
    </header>

    <!-- Floating Device Offline Banner (FR-KIOSK-06) -->
    <div id="offlineBanner">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round">
            <line x1="1" y1="1" x2="23" y2="23"></line>
            <path d="M16.72 11.06A10.94 10.94 0 0 1 19 12.55"></path>
            <path d="M5 12.55a10.94 10.94 0 0 1 5.17-2.39"></path>
            <path d="M10.71 5.05A16 16 0 0 1 22.58 9"></path>
            <path d="M1.42 9a15.91 15.91 0 0 1 4.7-2.88"></path>
            <path d="M8.53 16.11a6 6 0 0 1 6.95 0"></path>
            <line x1="12" y1="20" x2="12.01" y2="20"></line>
        </svg>
        <span id="offlineBannerText">WARNING: Biometric fingerprint sensor is offline (Connection lost)!</span>
    </div>

    <!-- Main Dynamic Workspace -->
    <main class="stage">

        <!-- VIEW 1: IDLE STATE (FR-KIOSK-02) -->
        <section class="view-idle" id="viewIdle">
            <div class="clock-display" id="clock">--:--:--</div>
            <div class="date-display" id="date">Loading date...</div>

            <div class="scanner-halo">
                <div class="scanner-ring"></div>
                <div class="scanner-glow"></div>
                <svg class="fingerprint-icon" viewBox="0 0 64 64" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round">
                    <path d="M20 50c-3-6-4-12-4-18a16 16 0 0 1 32 0c0 4-1 8-2 11"/>
                    <path d="M26 54c-3-6-4-14-4-22a10 10 0 0 1 20 0c0 7-1 13-3 18"/>
                    <path d="M32 32c0 9-1 16-4 24"/><path d="M38 34c0 6-1 11-2 15"/>
                    <path d="M14 22a20 20 0 0 1 36 0"/>
                </svg>
            </div>

            <div class="prompt-title">Place your finger on the sensor</div>
            <div class="prompt-subtitle">Hold your finger flat and steady to record attendance</div>
        </section>

        <!-- VIEW 2: SUCCESS CHECK-IN / CHECK-OUT (FR-KIOSK-03) -->
        <section class="view-success" id="viewSuccess">
            <div class="avatar-circle" id="succAvatar">LT</div>
            <div class="action-banner" id="succActionBanner">CHECK-IN SUCCESSFUL</div>
            <h2 class="emp-name" id="succEmpName">Employee</h2>
            <div class="emp-meta" id="succEmpMeta">Code: EMP001 · Engineering</div>

            <div class="scan-stats-grid">
                <div class="scan-stat-col">
                    <div class="label">Time</div>
                    <div class="val" id="succTime" style="color:#60a5fa;">07:58:12</div>
                </div>
                <div class="scan-stat-col">
                    <div class="label">Status</div>
                    <div class="val"><span class="status-pill pill-ON_TIME" id="succStatusPill">On Time</span></div>
                </div>
                <div class="scan-stat-col">
                    <div class="label">Worked Today</div>
                    <div class="val" id="succHours" style="color:#34d399;">--</div>
                </div>
            </div>

            <p style="font-size:14px; color:var(--text-muted);" id="succMsg">Check-in successful</p>

            <div class="countdown-wrap">
                <div class="countdown-bar" id="succCountdown"></div>
            </div>
        </section>

        <!-- VIEW 3: FAIL / NOT RECOGNIZED (FR-KIOSK-04) -->
        <section class="view-fail" id="viewFail">
            <div style="width: 80px; height: 80px; border-radius: 50%; background: rgba(239,68,68,0.15); border: 2px solid var(--danger); margin: 0 auto 16px; display: grid; place-items: center; color: var(--danger);">
                <svg width="42" height="42" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round">
                    <circle cx="12" cy="12" r="10"></circle>
                    <line x1="15" y1="9" x2="9" y2="15"></line>
                    <line x1="9" y1="9" x2="15" y2="15"></line>
                </svg>
            </div>

            <h2 style="font-size: 26px; font-weight: 800; color: #f87171; margin-bottom: 8px;">Fingerprint Not Recognized</h2>
            <p style="font-size: 15px; color: #cbd5e1; margin-bottom: 16px;" id="failMsg">Please try again or ensure your finger is clean and flat on the sensor.</p>

            <div class="countdown-wrap">
                <div class="countdown-bar danger" id="failCountdown"></div>
            </div>
        </section>

        <!-- VIEW 4: ENROLLMENT GUIDANCE (FR-KIOSK-05) -->
        <section class="view-enroll" id="viewEnroll">
            <div style="font-size: 14px; font-weight: 700; color: var(--primary); text-transform: uppercase; letter-spacing: 1px;">Fingerprint Enrollment Mode</div>
            <h2 class="emp-name" id="enrollEmpName" style="margin-top: 6px;">Enrolling employee...</h2>

            <div class="step-indicators">
                <div class="step-dot active" id="dotStep1">1</div>
                <div class="step-dot" id="dotStep2">2</div>
                <div class="step-dot" id="dotStep3">✓</div>
            </div>

            <div style="font-size: 22px; font-weight: 700; color: #f8fafc; margin: 20px 0 10px;" id="enrollStepText">Step 1/2: Place finger on sensor</div>
            <p style="font-size: 14px; color: var(--text-muted);" id="enrollSubText">Place finger flat and keep steady on optical scanner.</p>

            <div class="countdown-wrap">
                <div class="countdown-bar primary" id="enrollCountdown"></div>
            </div>
        </section>

    </main>

    <footer class="kiosk-footer">
        Smart Attendance &amp; Payroll System · Real-time Biometric Kiosk Terminal
    </footer>

    <script>
        const contextPath = '${pageContext.request.contextPath}';
        let returnTimer = null;
        let countdownInterval = null;

        // 1. Digital Clock (FR-KIOSK-02)
        function updateClock() {
            const now = new Date();
            document.getElementById('clock').textContent = now.toLocaleTimeString('en-US', {hour12: false});
            document.getElementById('date').textContent = now.toLocaleDateString('en-US', {
                weekday: 'long', month: 'short', day: '2-digit', year: 'numeric'
            });
        }
        updateClock();
        setInterval(updateClock, 1000);

        // 2. View Switching Helper
        function showView(viewId) {
            ['viewIdle', 'viewSuccess', 'viewFail', 'viewEnroll'].forEach(id => {
                document.getElementById(id).style.display = (id === viewId) ? 'flex' : 'none';
            });
        }

        function scheduleReturnToIdle(durationMs, barElementId) {
            clearTimeout(returnTimer);
            clearInterval(countdownInterval);

            const bar = document.getElementById(barElementId);
            if (bar) {
                bar.style.width = '100%';
                const startTime = Date.now();
                countdownInterval = setInterval(() => {
                    const elapsed = Date.now() - startTime;
                    const remainingPercent = Math.max(0, 100 - (elapsed / durationMs) * 100);
                    bar.style.width = remainingPercent + '%';
                    if (elapsed >= durationMs) {
                        clearInterval(countdownInterval);
                    }
                }, 50);
            }

            returnTimer = setTimeout(() => {
                showView('viewIdle');
            }, durationMs);
        }

        // 3. Scan Event Handling (FR-KIOSK-03, 04)
        function handleScanSuccess(data) {
            const emp = data.employee || {};
            document.getElementById('succEmpName').textContent = emp.name || 'Employee';
            document.getElementById('succEmpMeta').textContent = 
                'Code: ' + (emp.code || '--') + ' · ' + (emp.department || 'Company');

            // Avatar / Initials
            const avatarBox = document.getElementById('succAvatar');
            if (emp.photo && emp.photo.trim() !== '') {
                avatarBox.innerHTML = '<img src="' + emp.photo + '" alt="Avatar">';
            } else {
                const initials = (emp.name || 'NV').split(' ').map(p => p[0]).join('').slice(-2).toUpperCase();
                avatarBox.textContent = initials;
            }

            // Action Banner
            const banner = document.getElementById('succActionBanner');
            if (data.result === 'CHECK_IN') {
                banner.className = 'action-banner banner-checkin';
                banner.textContent = 'CHECK-IN SUCCESSFUL';
            } else {
                banner.className = 'action-banner banner-checkout';
                banner.textContent = 'CHECK-OUT SUCCESSFUL';
            }

            // Time & Status
            document.getElementById('succTime').textContent = data.time || '--:--:--';
            const pill = document.getElementById('succStatusPill');
            pill.className = 'status-pill pill-' + (data.status || 'ON_TIME');
            pill.textContent = data.statusLabel || data.status || 'On Time';

            // Hours
            const hoursBox = document.getElementById('succHours');
            if (data.workedMinutes && data.workedMinutes > 0) {
                const h = Math.floor(data.workedMinutes / 60);
                const m = data.workedMinutes % 60;
                hoursBox.textContent = h + 'h ' + m + 'm';
            } else {
                hoursBox.textContent = (data.result === 'CHECK_IN') ? 'Shift Started' : '--';
            }

            document.getElementById('succMsg').textContent = data.message || 'Attendance recorded';

            showView('viewSuccess');
            scheduleReturnToIdle(5000, 'succCountdown'); // Return after 5 seconds (FR-KIOSK-03)
        }

        function handleScanFail(data) {
            document.getElementById('failMsg').textContent = data.message || 'Fingerprint not recognized, please try again.';
            showView('viewFail');
            scheduleReturnToIdle(4000, 'failCountdown'); // Return after 4 seconds (FR-KIOSK-04)
        }

        // 4. Enrollment Guidance Handling (FR-KIOSK-05)
        function handleEnrollStep(data) {
            showView('viewEnroll');
            if (data.employeeName) {
                document.getElementById('enrollEmpName').textContent = data.employeeName;
            }

            const step = data.step || 'PLACE_FINGER';
            const text = document.getElementById('enrollStepText');
            const sub = document.getElementById('enrollSubText');
            const d1 = document.getElementById('dotStep1');
            const d2 = document.getElementById('dotStep2');
            const d3 = document.getElementById('dotStep3');

            d1.className = 'step-dot';
            d2.className = 'step-dot';
            d3.className = 'step-dot';

            if (step === 'PLACE_FINGER') {
                d1.className = 'step-dot active';
                text.textContent = 'Step 1/2: Place finger on sensor';
                sub.textContent = 'Place finger flat and keep steady on optical scanner.';
                scheduleReturnToIdle(15000, 'enrollCountdown');
            } else if (step === 'REMOVE_FINGER') {
                d1.className = 'step-dot completed';
                d2.className = 'step-dot active';
                text.textContent = 'Lift your finger';
                sub.textContent = 'Lift your finger from the sensor to prepare for second scan.';
                scheduleReturnToIdle(10000, 'enrollCountdown');
            } else if (step === 'PLACE_AGAIN') {
                d1.className = 'step-dot completed';
                d2.className = 'step-dot active';
                text.textContent = 'Step 2/2: Place the same finger again';
                sub.textContent = 'Place the same finger again for template verification.';
                scheduleReturnToIdle(15000, 'enrollCountdown');
            } else if (step === 'SUCCESS') {
                d1.className = 'step-dot completed';
                d2.className = 'step-dot completed';
                d3.className = 'step-dot completed';
                text.textContent = '✅ Fingerprint Enrolled Successfully!';
                sub.textContent = 'Employee can now use fingerprint for attendance.';
                scheduleReturnToIdle(5000, 'enrollCountdown');
            } else if (step === 'FAILED') {
                text.textContent = '❌ Fingerprint Enrollment Failed!';
                sub.textContent = 'Fingerprint scans did not match or template quality was low. Please retry.';
                scheduleReturnToIdle(5000, 'enrollCountdown');
            }
        }

        // 5. Device Offline Banner (FR-KIOSK-06)
        function handleDeviceStatus(data) {
            const banner = document.getElementById('offlineBanner');
            if (data.online === false) {
                banner.style.display = 'flex';
                document.getElementById('offlineBannerText').textContent = 
                    'WARNING: Device ' + (data.deviceName || 'Sensor') + ' is offline!';
            } else {
                banner.style.display = 'none';
            }
        }

        // 6. Server-Sent Events (SSE) Connection (FR-KIOSK-01)
        function initSse() {
            const dot = document.getElementById('sseDot');
            const text = document.getElementById('sseStatusText');

            const es = new EventSource(contextPath + '/kiosk/stream');

            es.addEventListener('open', () => {
                dot.className = 'dot-pulse';
                text.textContent = 'Online (SSE)';
            });

            es.addEventListener('scan', (e) => {
                try {
                    const data = JSON.parse(e.data);
                    if (data.type === 'SCAN_SUCCESS') {
                        handleScanSuccess(data);
                    } else if (data.type === 'SCAN_FAIL') {
                        handleScanFail(data);
                    } else {
                        // IGNORED
                        handleScanFail({ message: data.message || 'Scan ignored' });
                    }
                } catch (err) {
                    console.error('Scan parse error', err);
                }
            });

            es.addEventListener('enroll_step', (e) => {
                try {
                    const data = JSON.parse(e.data);
                    handleEnrollStep(data);
                } catch (err) {
                    console.error('Enroll parse error', err);
                }
            });

            es.addEventListener('device_status', (e) => {
                try {
                    const data = JSON.parse(e.data);
                    handleDeviceStatus(data);
                } catch (err) {
                    console.error('Device status parse error', err);
                }
            });

            es.onerror = () => {
                dot.className = 'dot-pulse dot-offline';
                text.textContent = 'Reconnecting...';
            };
        }

        // 7. Fullscreen Toggle
        function toggleFullscreen() {
            if (!document.fullscreenElement) {
                document.documentElement.requestFullscreen().catch(() => {});
                document.getElementById('btnFullscreen').textContent = 'Exit Fullscreen';
            } else {
                document.exitFullscreen().catch(() => {});
                document.getElementById('btnFullscreen').textContent = 'Fullscreen';
            }
        }

        window.addEventListener('DOMContentLoaded', () => {
            initSse();
        });
    </script>
</body>
</html>
