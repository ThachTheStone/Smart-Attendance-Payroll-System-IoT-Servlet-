<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>SmartAttend · Biometric IoT Attendance & Automated Payroll Platform</title>
    <meta name="description" content="Enterprise biometric IoT attendance terminal and automated statutory payroll engine. Direct ESP32 optical sensor integration with real-time labor law compliance.">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=JetBrains+Mono:wght@500;600;700&display=swap" rel="stylesheet">
    
    <style>
        /* ================= Design Tokens (Modern Swiss Light / B2B SaaS) ================= */
        :root {
            --bg-canvas: #f8fafc;
            --bg-card: #ffffff;
            --bg-subtle: #f1f5f9;
            --border-light: #e2e8f0;
            --border-strong: #cbd5e1;
            
            --text-heading: #0f172a;
            --text-body: #334155;
            --text-muted: #64748b;
            --text-light: #94a3b8;
            
            --brand-primary: #1d4ed8;
            --brand-hover: #1e40af;
            --brand-subtle: #eff6ff;
            --brand-border: #bfdbfe;
            
            --accent-emerald: #059669;
            --emerald-bg: #ecfdf5;
            --emerald-border: #a7f3d0;
            
            --accent-amber: #d97706;
            --amber-bg: #fffbeb;
            --amber-border: #fde68a;

            --shadow-sm: 0 1px 2px 0 rgba(0, 0, 0, 0.05);
            --shadow-md: 0 4px 6px -1px rgba(0, 0, 0, 0.06), 0 2px 4px -2px rgba(0, 0, 0, 0.04);
            --shadow-lg: 0 10px 15px -3px rgba(0, 0, 0, 0.06), 0 4px 6px -4px rgba(0, 0, 0, 0.04);
            --shadow-xl: 0 20px 25px -5px rgba(0, 0, 0, 0.08), 0 8px 10px -6px rgba(0, 0, 0, 0.04);
            
            --radius-sm: 6px;
            --radius-md: 10px;
            --radius-lg: 16px;
            --radius-xl: 24px;
            --radius-full: 9999px;
            
            --font-sans: 'Plus Jakarta Sans', system-ui, -apple-system, sans-serif;
            --font-mono: 'JetBrains Mono', ui-monospace, monospace;
        }

        *, *::before, *::after {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        html {
            scroll-behavior: smooth;
            -webkit-text-size-adjust: 100%;
        }

        body {
            font-family: var(--font-sans);
            background-color: var(--bg-canvas);
            color: var(--text-body);
            line-height: 1.6;
            -webkit-font-smoothing: antialiased;
            -moz-osx-font-smoothing: grayscale;
            overflow-x: hidden;
        }

        /* Typography Utilities */
        h1, h2, h3, h4, h5 {
            color: var(--text-heading);
            font-weight: 700;
            letter-spacing: -0.025em;
            line-height: 1.25;
        }

        .mono {
            font-family: var(--font-mono);
        }

        .container {
            width: 100%;
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 24px;
        }

        /* Buttons & Pills */
        .btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            padding: 10px 20px;
            border-radius: var(--radius-md);
            font-size: 14px;
            font-weight: 600;
            text-decoration: none;
            cursor: pointer;
            transition: all 0.15s ease-in-out;
            border: 1px solid transparent;
            white-space: nowrap;
        }

        .btn-primary {
            background-color: var(--brand-primary);
            color: #ffffff;
            box-shadow: 0 1px 2px rgba(29, 78, 216, 0.2);
        }
        .btn-primary:hover {
            background-color: var(--brand-hover);
            transform: translateY(-1px);
            box-shadow: var(--shadow-md);
            color: #ffffff;
        }

        .btn-secondary {
            background-color: var(--bg-card);
            color: var(--text-heading);
            border-color: var(--border-strong);
            box-shadow: var(--shadow-sm);
        }
        .btn-secondary:hover {
            background-color: var(--bg-subtle);
            border-color: #94a3b8;
            color: var(--text-heading);
        }

        .btn-ghost {
            background: transparent;
            color: var(--text-body);
        }
        .btn-ghost:hover {
            background-color: var(--bg-subtle);
            color: var(--text-heading);
        }

        .kicker-tag {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 5px 14px;
            border-radius: var(--radius-full);
            background: var(--brand-subtle);
            border: 1px solid var(--brand-border);
            color: var(--brand-primary);
            font-size: 12px;
            font-weight: 700;
            letter-spacing: 0.05em;
            text-transform: uppercase;
        }

        .pulse-dot {
            width: 7px;
            height: 7px;
            border-radius: 50%;
            background-color: var(--accent-emerald);
        }

        /* Navigation Header */
        .site-header {
            position: sticky;
            top: 0;
            z-index: 100;
            background: rgba(255, 255, 255, 0.92);
            backdrop-filter: blur(12px);
            -webkit-backdrop-filter: blur(12px);
            border-bottom: 1px solid var(--border-light);
        }

        .nav-inner {
            display: flex;
            align-items: center;
            justify-content: space-between;
            height: 72px;
        }

        .brand-link {
            display: flex;
            align-items: center;
            gap: 12px;
            text-decoration: none;
            color: var(--text-heading);
            font-weight: 800;
            font-size: 18px;
            letter-spacing: -0.02em;
        }

        .brand-mark {
            width: 38px;
            height: 38px;
            background: var(--brand-primary);
            color: #ffffff;
            border-radius: 10px;
            display: grid;
            place-items: center;
            font-weight: 800;
            font-size: 15px;
            letter-spacing: 0.5px;
        }

        .nav-links {
            display: flex;
            align-items: center;
            gap: 32px;
            list-style: none;
        }

        .nav-links a {
            text-decoration: none;
            color: var(--text-body);
            font-size: 14px;
            font-weight: 600;
            transition: color 0.15s ease;
        }

        .nav-links a:hover {
            color: var(--brand-primary);
        }

        .nav-cta-group {
            display: flex;
            align-items: center;
            gap: 12px;
        }

        /* Hero Section */
        .hero-section {
            padding: 84px 0 64px;
            text-align: center;
            position: relative;
        }

        .hero-title {
            font-size: clamp(36px, 5.2vw, 60px);
            font-weight: 800;
            letter-spacing: -0.035em;
            line-height: 1.1;
            max-width: 920px;
            margin: 20px auto 20px;
            color: var(--text-heading);
        }

        .hero-subtitle {
            font-size: clamp(16px, 1.8vw, 20px);
            color: var(--text-muted);
            max-width: 720px;
            margin: 0 auto 36px;
            line-height: 1.6;
            font-weight: 400;
        }

        .hero-cta-bar {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 14px;
            flex-wrap: wrap;
            margin-bottom: 48px;
        }

        .trust-metrics-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 20px;
            max-width: 1040px;
            margin: 0 auto;
            padding-top: 24px;
            border-top: 1px solid var(--border-light);
        }

        .trust-metric-item {
            text-align: center;
        }

        .trust-metric-number {
            font-size: 28px;
            font-weight: 800;
            color: var(--text-heading);
            font-family: var(--font-mono);
            letter-spacing: -0.02em;
        }

        .trust-metric-label {
            font-size: 13px;
            color: var(--text-muted);
            margin-top: 4px;
            font-weight: 500;
        }

        /* Live Product Showcase Mockup */
        .showcase-wrapper {
            margin: 48px auto 0;
            max-width: 1100px;
            background: #ffffff;
            border: 1px solid var(--border-light);
            border-radius: var(--radius-xl);
            box-shadow: var(--shadow-xl);
            overflow: hidden;
            text-align: left;
        }

        .showcase-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 14px 20px;
            background: #f8fafc;
            border-bottom: 1px solid var(--border-light);
        }

        .window-dots {
            display: flex;
            gap: 6px;
        }

        .window-dot {
            width: 10px;
            height: 10px;
            border-radius: 50%;
            background: #cbd5e1;
        }

        .showcase-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 0;
        }

        .showcase-panel {
            padding: 32px;
        }

        .showcase-panel:first-child {
            border-right: 1px solid var(--border-light);
            background: #ffffff;
        }

        .showcase-panel:last-child {
            background: #fafafc;
        }

        .panel-badge {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            font-size: 11px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.05em;
            margin-bottom: 14px;
            color: var(--brand-primary);
        }

        .mock-punch-box {
            background: #f8fafc;
            border: 1px solid var(--border-light);
            border-radius: var(--radius-md);
            padding: 18px 20px;
            margin-top: 16px;
        }

        .mock-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 8px 0;
            font-size: 13px;
            border-bottom: 1px solid #f1f5f9;
        }
        .mock-row:last-child { border-bottom: none; }

        /* Section Styling */
        .section-padding {
            padding: 96px 0;
        }

        .section-header {
            text-align: center;
            max-width: 680px;
            margin: 0 auto 56px;
        }

        .section-title {
            font-size: clamp(28px, 3.2vw, 40px);
            margin: 12px 0 16px;
        }

        .section-subtitle {
            font-size: 16px;
            color: var(--text-muted);
            line-height: 1.6;
        }

        /* 3-Layer Architecture Tabs */
        .arch-card {
            background: #ffffff;
            border: 1px solid var(--border-light);
            border-radius: var(--radius-lg);
            padding: 40px;
            box-shadow: var(--shadow-md);
        }

        .arch-tab-nav {
            display: flex;
            gap: 12px;
            border-bottom: 1px solid var(--border-light);
            padding-bottom: 16px;
            margin-bottom: 32px;
            overflow-x: auto;
        }

        .arch-tab-btn {
            background: transparent;
            border: none;
            padding: 10px 18px;
            border-radius: var(--radius-md);
            font-size: 14px;
            font-weight: 700;
            color: var(--text-muted);
            cursor: pointer;
            transition: all 0.15s ease;
        }

        .arch-tab-btn.active {
            background: var(--brand-subtle);
            color: var(--brand-primary);
        }

        .arch-content-grid {
            display: grid;
            grid-template-columns: 1.2fr 1fr;
            gap: 40px;
            align-items: center;
        }

        .code-snippet-box {
            background: #0f172a;
            color: #e2e8f0;
            border-radius: var(--radius-md);
            padding: 22px;
            font-family: var(--font-mono);
            font-size: 12px;
            line-height: 1.7;
            overflow-x: auto;
            border: 1px solid #1e293b;
        }

        /* Interactive Payroll Calculator */
        .calc-wrapper {
            background: #ffffff;
            border: 1px solid var(--border-light);
            border-radius: var(--radius-xl);
            box-shadow: var(--shadow-lg);
            padding: 44px;
            display: grid;
            grid-template-columns: 1.1fr 1fr;
            gap: 48px;
        }

        .calc-input-group {
            margin-bottom: 22px;
        }

        .calc-label-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 8px;
            font-size: 13px;
            font-weight: 600;
            color: var(--text-heading);
        }

        .calc-slider {
            width: 100%;
            height: 6px;
            background: #e2e8f0;
            border-radius: 999px;
            outline: none;
            accent-color: var(--brand-primary);
            cursor: pointer;
        }

        .calc-receipt {
            background: #f8fafc;
            border: 1px solid var(--border-light);
            border-radius: var(--radius-lg);
            padding: 28px;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
        }

        .calc-receipt-title {
            font-size: 16px;
            font-weight: 700;
            margin-bottom: 16px;
            padding-bottom: 12px;
            border-bottom: 1px solid #e2e8f0;
        }

        .receipt-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 9px 0;
            font-size: 13px;
            border-bottom: 1px dashed #e2e8f0;
        }

        .receipt-total-box {
            margin-top: 20px;
            padding-top: 16px;
            border-top: 2px solid #cbd5e1;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .receipt-total-amount {
            font-size: 26px;
            font-weight: 800;
            color: var(--accent-emerald);
            font-family: var(--font-mono);
        }

        /* Comparison Table */
        .comparison-table-card {
            background: #ffffff;
            border: 1px solid var(--border-light);
            border-radius: var(--radius-lg);
            overflow: hidden;
            box-shadow: var(--shadow-md);
        }

        .comparison-table {
            width: 100%;
            border-collapse: collapse;
            text-align: left;
        }

        .comparison-table th {
            padding: 18px 24px;
            background: #f8fafc;
            font-size: 13px;
            font-weight: 700;
            color: var(--text-heading);
            border-bottom: 1px solid var(--border-light);
        }

        .comparison-table td {
            padding: 18px 24px;
            border-bottom: 1px solid #f1f5f9;
            font-size: 14px;
        }

        .comparison-table tr:hover td {
            background: #fafafa;
        }

        .check-pill {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            color: var(--accent-emerald);
            font-weight: 600;
        }

        .cross-pill {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            color: #dc2626;
            font-weight: 600;
        }


        /* FAQ Accordion */
        .faq-accordion {
            max-width: 820px;
            margin: 0 auto;
            display: flex;
            flex-direction: column;
            gap: 12px;
        }

        .faq-item {
            background: #ffffff;
            border: 1px solid var(--border-light);
            border-radius: var(--radius-md);
            overflow: hidden;
            box-shadow: var(--shadow-sm);
        }

        .faq-trigger {
            width: 100%;
            padding: 20px 24px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            background: transparent;
            border: none;
            cursor: pointer;
            text-align: left;
            font-size: 16px;
            font-weight: 700;
            color: var(--text-heading);
        }

        .faq-content {
            padding: 0 24px 20px;
            color: var(--text-muted);
            font-size: 14px;
            line-height: 1.6;
            display: none;
        }

        .faq-item.open .faq-content {
            display: block;
        }

        .faq-item.open .faq-icon {
            transform: rotate(180deg);
        }

        .faq-icon {
            transition: transform 0.2s ease;
        }

        /* Pre-Footer Banner */
        .pre-footer-cta {
            background: #0f172a;
            color: #ffffff;
            border-radius: var(--radius-xl);
            padding: 64px 48px;
            text-align: center;
            margin-bottom: 80px;
        }

        .pre-footer-cta h2 {
            color: #ffffff;
            font-size: clamp(28px, 3.5vw, 42px);
            margin-bottom: 16px;
        }

        .pre-footer-cta p {
            color: #94a3b8;
            max-width: 620px;
            margin: 0 auto 36px;
            font-size: 16px;
        }

        /* Site Footer */
        .site-footer {
            border-top: 1px solid var(--border-light);
            background: #ffffff;
            padding: 48px 0 36px;
            color: var(--text-muted);
            font-size: 13px;
        }

        .footer-grid {
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 20px;
        }

        /* Mobile Breakpoints */
        @media (max-width: 900px) {
            .nav-links { display: none; }
            .showcase-grid { grid-template-columns: 1fr; }
            .showcase-panel:first-child { border-right: none; border-bottom: 1px solid var(--border-light); }
            .arch-content-grid { grid-template-columns: 1fr; }
            .calc-wrapper { grid-template-columns: 1fr; padding: 24px; }
            .trust-metrics-grid { grid-template-columns: repeat(2, 1fr); gap: 24px; }
        }
    </style>
</head>
<body>

    <!-- 1. Top Navigation Bar -->
    <header class="site-header">
        <div class="container nav-inner">
            <a href="${ctx}/" class="brand-link">
                <span class="brand-mark">SA</span>
                <span>SmartAttend</span>
            </a>

            <ul class="nav-links">
                <li><a href="#features">Capabilities</a></li>
                <li><a href="#architecture">Hardware Architecture</a></li>
                <li><a href="#calculator">Payroll Calculator</a></li>
                <li><a href="#comparison">Compare</a></li>
                <li><a href="#faq">FAQ</a></li>
            </ul>

            <div class="nav-cta-group">
                <a href="${ctx}/kiosk" class="btn btn-ghost" title="Open Attendance Kiosk Terminal">Kiosk Mode</a>
                <a href="${ctx}/dev/simulator" class="btn btn-secondary" title="Hardware simulator for testing">Simulator</a>
                <a href="${ctx}/login" class="btn btn-primary">Sign In</a>
            </div>
        </div>
    </header>

    <main>
        <!-- 2. Hero Section -->
        <section class="hero-section container">
            <div class="kicker-tag">
                <span class="pulse-dot"></span>
                <span>AS608 Optical IoT &bull; Statutory Labor Law Compliance</span>
            </div>

            <h1 class="hero-title">
                Zero-Tamper Attendance.<br>Flawless Automated Payroll in Seconds.
            </h1>

            <p class="hero-subtitle">
                The unified biometric IoT terminal and automated payroll engine built for modern factories, enterprises, and distributed offices. Connects optical fingerprint hardware directly to labor law calculations without manual timesheets.
            </p>

            <div class="hero-cta-bar">
                <a href="${ctx}/login" class="btn btn-primary" style="padding: 13px 28px; font-size: 15px;">
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round"><path d="M15 3h4a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2h-4M10 17l5-5-5-5M13.8 12H3"/></svg>
                    <span>Launch Portal Console</span>
                </a>
                <a href="${ctx}/dev/simulator" class="btn btn-secondary" style="padding: 13px 24px; font-size: 15px;">
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round"><polygon points="5 3 19 12 5 21 5 3"/></svg>
                    <span>Run Hardware Simulator</span>
                </a>
                <a href="${ctx}/kiosk" class="btn btn-ghost" style="padding: 13px 20px; font-size: 15px;">
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round"><rect x="2" y="3" width="20" height="14" rx="2" ry="2"/><line x1="8" y1="21" x2="16" y2="21"/><line x1="12" y1="17" x2="12" y2="21"/></svg>
                    <span>Open Kiosk Station</span>
                </a>
            </div>

            <!-- Trust Metrics -->
            <div class="trust-metrics-grid">
                <div class="trust-metric-item">
                    <div class="trust-metric-number">&lt; 0.2s</div>
                    <div class="trust-metric-label">Fingerprint Recognition Latency</div>
                </div>
                <div class="trust-metric-item">
                    <div class="trust-metric-number">100%</div>
                    <div class="trust-metric-label">Labor Code Overtime Compliance</div>
                </div>
                <div class="trust-metric-item">
                    <div class="trust-metric-number">0%</div>
                    <div class="trust-metric-label">Buddy Punching &amp; Time Theft</div>
                </div>
                <div class="trust-metric-item">
                    <div class="trust-metric-number">1-Click</div>
                    <div class="trust-metric-label">PDF Payslip Generation &amp; Dispatch</div>
                </div>
            </div>

            <!-- 3. Live Product Architecture Showcase Mockup -->
            <div class="showcase-wrapper">
                <div class="showcase-header">
                    <div class="window-dots">
                        <span class="window-dot" style="background:#ef4444;"></span>
                        <span class="window-dot" style="background:#f59e0b;"></span>
                        <span class="window-dot" style="background:#10b981;"></span>
                    </div>
                    <span class="mono" style="font-size: 12px; color: var(--text-muted);">SmartAttend Engine &bull; Biometric Edge to Automated Ledger</span>
                    <span class="pulse-dot"></span>
                </div>

                <div class="showcase-grid">
                    <!-- Edge Device Stream -->
                    <div class="showcase-panel">
                        <span class="panel-badge">
                            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
                            Edge Biometric Stream (AS608 + ESP32)
                        </span>
                        <h3 style="font-size: 18px; margin-bottom: 6px;">Live Fingerprint Verification</h3>
                        <p style="font-size: 13px; color: var(--text-muted);">Biometric capture matches stored templates onboard with SHA-256 integrity check.</p>

                        <div class="mock-punch-box">
                            <div class="mock-row">
                                <span style="color:var(--text-muted);">Sensor Model:</span>
                                <span class="mono font-bold" style="color:var(--text-heading);">AS608 Optical 500 DPI</span>
                            </div>
                            <div class="mock-row">
                                <span style="color:var(--text-muted);">Template ID Matched:</span>
                                <span class="mono font-bold" style="color:var(--brand-primary);">#014 &bull; Le Van Tuan (EMP001)</span>
                            </div>
                            <div class="mock-row">
                                <span style="color:var(--text-muted);">Match Confidence:</span>
                                <span class="mono" style="color:var(--accent-emerald); font-weight:700;">96.4% (Pass)</span>
                            </div>
                            <div class="mock-row">
                                <span style="color:var(--text-muted);">Punch Timestamp:</span>
                                <span class="mono">07:58:12 &bull; On Time</span>
                            </div>
                            <div class="mock-row">
                                <span style="color:var(--text-muted);">Terminal Handshake:</span>
                                <span class="mono" style="font-size:11px; color:#2563eb;">200 OK &bull; SSE Broadcasted</span>
                            </div>
                        </div>
                    </div>

                    <!-- Cloud Ledger Engine -->
                    <div class="showcase-panel">
                        <span class="panel-badge" style="color: var(--accent-emerald);">
                            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>
                            Automated Payroll Calculation
                        </span>
                        <h3 style="font-size: 18px; margin-bottom: 6px;">Statutory Formula Audit</h3>
                        <p style="font-size: 13px; color: var(--text-muted);">Calculates overtime tiers, night allowances, and statutory penalty deductions.</p>

                        <div class="mock-punch-box">
                            <div class="mock-row">
                                <span style="color:var(--text-muted);">Base Contract Rate:</span>
                                <span class="mono">15,000,000 VND</span>
                            </div>
                            <div class="mock-row">
                                <span style="color:var(--text-muted);">Standard Worked Hours:</span>
                                <span class="mono">160h &bull; 100% Base Disbursed</span>
                            </div>
                            <div class="mock-row">
                                <span style="color:var(--text-muted);">Weekday Overtime (150%):</span>
                                <span class="mono" style="color:var(--brand-primary); font-weight:700;">14h &bull; +1,514,423 VND</span>
                            </div>
                            <div class="mock-row">
                                <span style="color:var(--text-muted);">Night Shift Allowance (+30%):</span>
                                <span class="mono" style="color:var(--brand-primary); font-weight:700;">8h &bull; +173,077 VND</span>
                            </div>
                            <div class="mock-row" style="background:var(--emerald-bg); margin:-4px -10px -10px; padding:10px; border-radius:6px; border:1px solid var(--emerald-border);">
                                <span style="font-weight:700; color:var(--accent-emerald);">Take-Home Net Salary:</span>
                                <span class="mono font-bold" style="color:var(--accent-emerald); font-size:15px;">16,687,500 VND</span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <!-- 4. Interactive Live Payroll Calculator Section -->
        <section id="calculator" class="section-padding" style="background:#ffffff; border-top:1px solid var(--border-light); border-bottom:1px solid var(--border-light);">
            <div class="container">
                <div class="section-header">
                    <div class="kicker-tag">Live Demonstration</div>
                    <h2 class="section-title">Test the Real-Time Payroll Calculator</h2>
                    <p class="section-subtitle">
                        Adjust work hours, overtime tiers, and penalties below to watch how our statutory calculation engine calculates net take-home salary in real time.
                    </p>
                </div>

                <div class="calc-wrapper">
                    <!-- Calculator Inputs -->
                    <div>
                        <h3 style="font-size: 18px; margin-bottom: 24px;">Shift &amp; Attendance Variables</h3>

                        <div class="calc-input-group">
                            <div class="calc-label-row">
                                <span>Monthly Base Salary</span>
                                <span class="mono font-bold" id="lblBase">15,000,000 VND</span>
                            </div>
                            <input type="range" class="calc-slider" id="sldBase" min="5000000" max="50000000" step="500000" value="15000000" oninput="calcPayroll()">
                        </div>

                        <div class="calc-input-group">
                            <div class="calc-label-row">
                                <span>Standard Worked Hours (Target: 208 hrs/mo)</span>
                                <span class="mono font-bold" id="lblRegH">160 hrs</span>
                            </div>
                            <input type="range" class="calc-slider" id="sldRegH" min="80" max="208" step="1" value="160" oninput="calcPayroll()">
                        </div>

                        <div class="calc-input-group">
                            <div class="calc-label-row">
                                <span>Weekday Overtime (150% Multiplier)</span>
                                <span class="mono font-bold" id="lblOtWd">12 hrs</span>
                            </div>
                            <input type="range" class="calc-slider" id="sldOtWd" min="0" max="40" step="1" value="12" oninput="calcPayroll()">
                        </div>

                        <div class="calc-input-group">
                            <div class="calc-label-row">
                                <span>Weekend Overtime (200% Multiplier)</span>
                                <span class="mono font-bold" id="lblOtWe">6 hrs</span>
                            </div>
                            <input type="range" class="calc-slider" id="sldOtWe" min="0" max="32" step="1" value="6" oninput="calcPayroll()">
                        </div>

                        <div class="calc-input-group">
                            <div class="calc-label-row">
                                <span>Night Shift Hours (+30% Differential)</span>
                                <span class="mono font-bold" id="lblNightH">8 hrs</span>
                            </div>
                            <input type="range" class="calc-slider" id="sldNightH" min="0" max="40" step="1" value="8" oninput="calcPayroll()">
                        </div>

                        <div class="calc-input-group">
                            <div class="calc-label-row">
                                <span>Late Arrival Penalty (Mins past grace period)</span>
                                <span class="mono font-bold" id="lblLateM">15 mins</span>
                            </div>
                            <input type="range" class="calc-slider" id="sldLateM" min="0" max="180" step="5" value="15" oninput="calcPayroll()">
                        </div>
                    </div>

                    <!-- Calculated Payslip Statement -->
                    <div class="calc-receipt">
                        <div>
                            <div class="calc-receipt-title">Verified Monthly Statement Preview</div>

                            <div class="receipt-row">
                                <span style="color:var(--text-muted);">Hourly Base Rate:</span>
                                <span class="mono font-bold" id="resRate">72,115 VND/h</span>
                            </div>
                            <div class="receipt-row">
                                <span style="color:var(--text-muted);">Standard Worked Pay:</span>
                                <span class="mono" id="resRegPay">11,538,462 VND</span>
                            </div>
                            <div class="receipt-row">
                                <span style="color:var(--text-muted);">Weekday Overtime (150%):</span>
                                <span class="mono" style="color:var(--brand-primary); font-weight:600;" id="resOtWdPay">+1,298,077 VND</span>
                            </div>
                            <div class="receipt-row">
                                <span style="color:var(--text-muted);">Weekend Overtime (200%):</span>
                                <span class="mono" style="color:var(--brand-primary); font-weight:600;" id="resOtWePay">+865,385 VND</span>
                            </div>
                            <div class="receipt-row">
                                <span style="color:var(--text-muted);">Night Differential (+30%):</span>
                                <span class="mono" style="color:var(--brand-primary); font-weight:600;" id="resNightPay">+173,077 VND</span>
                            </div>
                            <div class="receipt-row" style="color:#dc2626;">
                                <span>Late Penalty Deduction:</span>
                                <span class="mono font-bold" id="resPenalty">-36,058 VND</span>
                            </div>
                        </div>

                        <div class="receipt-total-box">
                            <div>
                                <div style="font-size:12px; font-weight:700; text-transform:uppercase; color:var(--text-muted);">Net Take-Home Salary</div>
                                <div style="font-size:11px; color:var(--text-light);">Formula: (Earnings) - (Penalties)</div>
                            </div>
                            <div class="receipt-total-amount" id="resNetTotal">
                                13,838,943 VND
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <!-- 5. 3-Layer Hardware Architecture Pipeline -->
        <section id="architecture" class="section-padding container">
            <div class="section-header">
                <div class="kicker-tag">System Architecture</div>
                <h2 class="section-title">From Optical Glass to Banking Ledger</h2>
                <p class="section-subtitle">
                    A three-tiered stack connecting hardware firmware, real-time message brokers, and enterprise accounting databases.
                </p>
            </div>

            <div class="arch-card">
                <div class="arch-tab-nav">
                    <button class="arch-tab-btn active" onclick="switchArchTab('edge', this)">Layer 1: Edge Terminal</button>
                    <button class="arch-tab-btn" onclick="switchArchTab('stream', this)">Layer 2: Real-Time Broker</button>
                    <button class="arch-tab-btn" onclick="switchArchTab('payroll', this)">Layer 3: Payroll Ledger</button>
                </div>

                <div id="archTabContent" class="arch-content-grid">
                    <div>
                        <h3 id="archTitle" style="font-size:22px; margin-bottom:12px;">AS608 Optical Sensor &amp; ESP32 Controller</h3>
                        <p id="archDesc" style="color:var(--text-muted); font-size:15px; margin-bottom:20px; line-height:1.6;">
                            The biometric terminal operates as an autonomous edge node. Fingerprint characteristics are digitized and verified against 162 onboard templates using UART protocol, transmitting authenticated payload packets over TLS.
                        </p>
                        <ul id="archList" style="list-style:none; display:flex; flex-direction:column; gap:10px; font-size:14px;">
                            <li class="check-pill">
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>
                                500 DPI high-resolution optical sensing with live finger detection
                            </li>
                            <li class="check-pill">
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>
                                Hardware API security keys via X-API-Key HTTP header
                            </li>
                            <li class="check-pill">
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>
                                Resilient offline buffering when local network connection drops
                            </li>
                        </ul>
                    </div>

                    <div class="code-snippet-box" id="archCode">
// ESP32 Microcontroller UART Telemetry
#include &lt;Adafruit_Fingerprint.h&gt;
HardwareSerial mySerial(2);
Adafruit_Fingerprint finger(&mySerial);

void verifyFingerprint() {
  uint8_t p = finger.getImage();
  if (p != FINGERPRINT_OK) return;
  p = finger.image2Tz();
  p = finger.fingerFastSearch();
  if (p == FINGERPRINT_OK) {
    postScan(finger.fingerID, finger.confidence);
  }
}
                    </div>
                </div>
            </div>
        </section>

        <!-- 6. Comparison Section: Old Way vs SmartAttend -->
        <section id="comparison" class="section-padding" style="background:#ffffff; border-top:1px solid var(--border-light); border-bottom:1px solid var(--border-light);">
            <div class="container">
                <div class="section-header">
                    <div class="kicker-tag">Operational Impact</div>
                    <h2 class="section-title">Why Legacy Time Clocks Fail Modern Companies</h2>
                    <p class="section-subtitle">
                        Compare traditional standalone USB fingerprint machines and Excel calculation against SmartAttend's automated cloud architecture.
                    </p>
                </div>

                <div class="comparison-table-card">
                    <table class="comparison-table">
                        <thead>
                            <tr>
                                <th style="width: 32%;">Capability &amp; Workflow</th>
                                <th style="width: 34%; background:#fef2f2; color:#991b1b;">Legacy Biometric Clocks + Excel</th>
                                <th style="width: 34%; background:#ecfdf5; color:#065f46;">SmartAttend IoT Integrated Platform</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td><strong>Data Synchronization</strong></td>
                                <td class="cross-pill">❌ Manual USB flash drive export monthly</td>
                                <td class="check-pill">✔ Real-time SSE streaming (< 150ms)</td>
                            </tr>
                            <tr>
                                <td><strong>Buddy Punching &amp; Time Theft</strong></td>
                                <td class="cross-pill">❌ Frequent buddy scans and PIN bypass</td>
                                <td class="check-pill">✔ Hardware optical template matching</td>
                            </tr>
                            <tr>
                                <td><strong>Overtime Calculations</strong></td>
                                <td class="cross-pill">❌ Manual Excel formula errors and disputes</td>
                                <td class="check-pill">✔ 150%, 200%, 300% statutory labor rules</td>
                            </tr>
                            <tr>
                                <td><strong>Night Shift Allowance</strong></td>
                                <td class="cross-pill">❌ Hours manually estimated and argued</td>
                                <td class="check-pill">✔ Automated +30% night differential formula</td>
                            </tr>
                            <tr>
                                <td><strong>Missing Checkout Resolution</strong></td>
                                <td class="cross-pill">❌ Unnoticed until end of month disputes</td>
                                <td class="check-pill">✔ Calculation blocked until manager verified</td>
                            </tr>
                            <tr>
                                <td><strong>Audit Trail &amp; Payslip Delivery</strong></td>
                                <td class="cross-pill">❌ Paper printouts or manual email attachments</td>
                                <td class="check-pill">✔ 1-Click batch PDF dispatch &amp; audit lock</td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </section>


        <!-- 8. FAQ Accordion Section -->
        <section id="faq" class="section-padding" style="background:#ffffff; border-top:1px solid var(--border-light);">
            <div class="container">
                <div class="section-header">
                    <div class="kicker-tag">Common Inquiries</div>
                    <h2 class="section-title">Frequently Asked Questions</h2>
                    <p class="section-subtitle">
                        Everything you need to know about hardware compatibility, labor compliance, and security.
                    </p>
                </div>

                <div class="faq-accordion">
                    <div class="faq-item open">
                        <button class="faq-trigger" onclick="toggleFaq(this)">
                            <span>What happens if the internet connection or Wi-Fi drops at the terminal?</span>
                            <span class="faq-icon">▼</span>
                        </button>
                        <div class="faq-content">
                            The ESP32 controller stores attendance timestamps locally in flash memory buffer. Once the local network connection or server gateway is restored, the buffered records automatically flush to the cloud database with exact hardware timestamps intact.
                        </div>
                    </div>

                    <div class="faq-item">
                        <button class="faq-trigger" onclick="toggleFaq(this)">
                            <span>Can an employee scan their finger twice by accident and get double-punched?</span>
                            <span class="faq-icon">▼</span>
                        </button>
                        <div class="faq-content">
                            No. SmartAttend enforces an anti-spam cooldown window (default 60 seconds) between scans from the same fingerprint template. Duplicate rapid taps are recognized and recorded as redundant events without distorting shift timesheets.
                        </div>
                    </div>

                    <div class="faq-item">
                        <button class="faq-trigger" onclick="toggleFaq(this)">
                            <span>How does the system calculate overtime and late penalties?</span>
                            <span class="faq-icon">▼</span>
                        </button>
                        <div class="faq-content">
                            The platform implements statutory labor law calculation algorithms: 150% for standard weekday overtime, 200% for scheduled weekend rest days, and 300% for recognized public holidays. Late arrival penalties apply past the configurable grace period (e.g., 15 minutes) and are deducted before finalizing the take-home salary.
                        </div>
                    </div>

                    <div class="faq-item">
                        <button class="faq-trigger" onclick="toggleFaq(this)">
                            <span>Why does payroll generation block when an employee forgets to checkout?</span>
                            <span class="faq-icon">▼</span>
                        </button>
                        <div class="faq-content">
                            To ensure total financial and audit integrity, payroll cannot be locked while unverified missing checkouts exist. Managers are immediately alerted to adjust the missing punch time with an audit reason before executing the payroll run.
                        </div>
                    </div>

                    <div class="faq-item">
                        <button class="faq-trigger" onclick="toggleFaq(this)">
                            <span>Is biometric fingerprint data stored as raw images?</span>
                            <span class="faq-icon">▼</span>
                        </button>
                        <div class="faq-content">
                            Never. Raw images are never stored or transmitted. The optical sensor extracts mathematical minutiae points (feature vectors) into an encrypted 512-byte template stored inside the AS608 hardware chip. It is cryptographically impossible to reverse-engineer a fingerprint image from the template.
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <!-- 9. Pre-Footer Call to Action -->
        <section class="container" style="padding-top: 80px;">
            <div class="pre-footer-cta">
                <h2>Ready to modernise your attendance and payroll?</h2>
                <p>Deploy SmartAttend to eliminate time theft, manual errors, and labor law disputes forever.</p>
                <div style="display:flex; justify-content:center; gap:14px; flex-wrap:wrap;">
                    <a href="${ctx}/login" class="btn btn-primary" style="background:#2563eb; padding:12px 28px; font-size:15px;">
                        Access Admin Console
                    </a>
                    <a href="${ctx}/kiosk" class="btn btn-secondary" style="padding:12px 24px; font-size:15px; background:rgba(255,255,255,0.1); color:#ffffff; border-color:rgba(255,255,255,0.2);">
                        Launch Attendance Kiosk
                    </a>
                </div>
            </div>
        </section>
    </main>

    <!-- 10. Site Footer -->
    <footer class="site-footer">
        <div class="container footer-grid">
            <div>
                <strong style="color:var(--text-heading);">SmartAttend</strong> &bull; Biometric IoT Attendance &amp; Automated Payroll Platform
            </div>
            <div>
                <span>ESP32 + AS608 Optical Sensor &bull; Java Servlet &bull; SQL Server 2022</span>
            </div>
            <div>
                &copy; 2026 SmartAttend Inc. All rights reserved.
            </div>
        </div>
    </footer>

    <!-- Interactive Scripts -->
    <script>
        // 1. Live Payroll Calculator Logic
        function calcPayroll() {
            const base = parseFloat(document.getElementById('sldBase').value) || 15000000;
            const regH = parseFloat(document.getElementById('sldRegH').value) || 160;
            const otWdH = parseFloat(document.getElementById('sldOtWd').value) || 0;
            const otWeH = parseFloat(document.getElementById('sldOtWe').value) || 0;
            const nightH = parseFloat(document.getElementById('sldNightH').value) || 0;
            const lateM = parseFloat(document.getElementById('sldLateM').value) || 0;

            const hourlyRate = base / 208.0;

            // Calculations
            const regPay = hourlyRate * regH;
            const otWdPay = hourlyRate * 1.5 * otWdH;
            const otWePay = hourlyRate * 2.0 * otWeH;
            const nightPay = hourlyRate * 0.3 * nightH;
            const penalty = (hourlyRate / 60.0) * lateM;

            const netTotal = Math.max(0, regPay + otWdPay + otWePay + nightPay - penalty);

            const fmt = (n) => Math.round(n).toLocaleString('en-US');

            // Update Labels
            document.getElementById('lblBase').textContent = fmt(base) + ' VND';
            document.getElementById('lblRegH').textContent = regH + ' hrs';
            document.getElementById('lblOtWd').textContent = otWdH + ' hrs';
            document.getElementById('lblOtWe').textContent = otWeH + ' hrs';
            document.getElementById('lblNightH').textContent = nightH + ' hrs';
            document.getElementById('lblLateM').textContent = lateM + ' mins';

            // Update Receipt
            document.getElementById('resRate').textContent = fmt(hourlyRate) + ' VND/h';
            document.getElementById('resRegPay').textContent = fmt(regPay) + ' VND';
            document.getElementById('resOtWdPay').textContent = '+' + fmt(otWdPay) + ' VND';
            document.getElementById('resOtWePay').textContent = '+' + fmt(otWePay) + ' VND';
            document.getElementById('resNightPay').textContent = '+' + fmt(nightPay) + ' VND';
            document.getElementById('resPenalty').textContent = '-' + fmt(penalty) + ' VND';
            document.getElementById('resNetTotal').textContent = fmt(netTotal) + ' VND';
        }

        // 2. Architecture Tab Switcher
        const archData = {
            edge: {
                title: "AS608 Optical Sensor & ESP32 Controller",
                desc: "The biometric terminal operates as an autonomous edge node. Fingerprint characteristics are digitized and verified against 162 onboard templates using UART protocol, transmitting authenticated payload packets over TLS.",
                code: `// ESP32 Microcontroller UART Telemetry
#include <Adafruit_Fingerprint.h>
HardwareSerial mySerial(2);
Adafruit_Fingerprint finger(&mySerial);

void verifyFingerprint() {
  uint8_t p = finger.getImage();
  if (p != FINGERPRINT_OK) return;
  p = finger.image2Tz();
  p = finger.fingerFastSearch();
  if (p == FINGERPRINT_OK) {
    postScan(finger.fingerID, finger.confidence);
  }
}`
            },
            stream: {
                title: "Server-Sent Events (SSE) Real-Time Broker",
                desc: "Every valid fingerprint punch triggers an immediate event on the '/kiosk/stream' channel. Wall-mounted monitors and employee tablets update in less than 150ms without database polling.",
                code: `// Java Servlet SSE EventSource Handler
@WebServlet(urlPatterns = {"/kiosk/stream"}, asyncSupported = true)
public class KioskStreamServlet extends HttpServlet {
    protected void doGet(HttpServletRequest req, HttpServletResponse res) {
        res.setContentType("text/event-stream");
        res.setCharacterEncoding("UTF-8");
        AsyncContext ac = req.startAsync();
        Broadcaster.register(ac);
    }
}`
            },
            payroll: {
                title: "Statutory Payroll & Compliance Ledger",
                desc: "Audits timesheet completeness, enforces labor multipliers (150%, 200%, 300%), calculates night differentials, and compiles locked PDF payslips ready for batch email distribution.",
                code: `// Automated Payroll Rule Engine
double regularPay = (baseSalary / 208.0) * regularHours;
double otPay = (hourlyRate * 1.5 * otWeekdayHours)
             + (hourlyRate * 2.0 * otWeekendHours)
             + (hourlyRate * 3.0 * otHolidayHours);
double nightAllowance = hourlyRate * 0.3 * nightHours;
double netSalary = regularPay + otPay + nightAllowance - penalties;`
            }
        };

        function switchArchTab(key, btn) {
            document.querySelectorAll('.arch-tab-btn').forEach(b => b.classList.remove('active'));
            btn.classList.add('active');

            const d = archData[key];
            if (d) {
                document.getElementById('archTitle').textContent = d.title;
                document.getElementById('archDesc').textContent = d.desc;
                document.getElementById('archCode').textContent = d.code;
            }
        }

        // 3. FAQ Accordion Toggle
        function toggleFaq(btn) {
            const item = btn.parentElement;
            item.classList.toggle('open');
        }


        // Initialize calculator
        window.addEventListener('DOMContentLoaded', () => {
            calcPayroll();
        });
    </script>
</body>
</html>
