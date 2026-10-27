<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>SmartAttend · Fingerprint Attendance &amp; Payroll</title>
    <meta name="description" content="SmartAttend connects an ESP32 fingerprint terminal to a web portal: employees scan in, the kiosk confirms within seconds, and payroll is calculated from the rules you configure.">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${ctx}/assets/css/fonts.css?v=5">
    <link rel="icon" type="image/svg+xml" href="${ctx}/assets/img/logo.svg">

    <style>
        :root {
            --navy: #14213d;
            --navy-2: #1c2c4f;
            --blue: #1d4ed8;
            --blue-dark: #1e40af;
            --blue-soft: #eef3ff;
            --green: #15803d;
            --green-soft: #ecfdf3;
            --amber: #b45309;
            --amber-soft: #fff7e6;
            --red: #b91c1c;
            --ink: #111827;
            --body: #374151;
            --muted: #6b7280;
            --line: #e5e7eb;
            --canvas: #f4f5f7;
            --white: #ffffff;
            --font-sans: var(--font-body);
        }

        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
        html { scroll-behavior: smooth; -webkit-text-size-adjust: 100%; }
        body {
            font-family: var(--font-ui);
            background: var(--canvas);
            color: var(--body);
            line-height: 1.6;
            -webkit-font-smoothing: antialiased;
            overflow-x: hidden;
        }
        a { color: inherit; }
        h1, h2, h3, h4 { color: var(--ink); line-height: 1.2; }

        .container { width: 100%; max-width: 1180px; margin: 0 auto; padding: 0 24px; }

        /* ---------- Buttons ---------- */
        .btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            padding: 11px 20px;
            border-radius: 6px;
            font-size: 14px;
            font-weight: 600;
            text-decoration: none;
            border: 1px solid transparent;
            cursor: pointer;
            white-space: nowrap;
            transition: background-color .15s ease, border-color .15s ease, color .15s ease;
        }
        .btn-primary { background: var(--blue); color: #fff; }
        .btn-primary:hover { background: var(--blue-dark); }
        .btn-light { background: #fff; color: var(--ink); border-color: #d1d5db; }
        .btn-light:hover { border-color: #9ca3af; }
        .btn-onDark { background: transparent; color: #fff; border-color: rgba(255,255,255,.35); }
        .btn-onDark:hover { border-color: #fff; }
        .btn-text { background: none; color: var(--body); padding-left: 8px; padding-right: 8px; }
        .btn-text:hover { color: var(--blue); }

        /* ---------- Navigation ---------- */
        .site-header {
            position: sticky;
            top: 0;
            z-index: 100;
            background: rgba(255, 255, 255, .96);
            border-bottom: 1px solid var(--line);
            backdrop-filter: saturate(140%) blur(8px);
        }
        .nav-inner { display: flex; align-items: center; justify-content: space-between; height: 64px; gap: 24px; }
        .brand-link { display: flex; align-items: center; gap: 10px; text-decoration: none; color: var(--ink); font-size: 17px; }
        .brand-mark { width: 34px; height: 34px; border-radius: 8px; background: var(--blue); display: grid; place-items: center; }
        .brand-mark img { width: 78%; height: 78%; display: block; }
        .nav-links { display: flex; gap: 4px; list-style: none; }
        .nav-links a {
            display: block;
            padding: 6px 12px;
            border-radius: 5px;
            font-size: 14px;
            text-decoration: none;
            color: var(--body);
            transition: color .15s ease, background-color .15s ease;
        }
        .nav-links a:hover { color: var(--ink); background: var(--canvas); }
        .nav-links a.is-active { color: var(--blue); background: var(--blue-soft); }
        .nav-cta { display: flex; gap: 8px; align-items: center; }
        .nav-cta .btn { padding: 8px 16px; }

        /* ---------- Hero ---------- */
        .hero {
            background: var(--navy);
            color: #d6deec;
            padding: 72px 0 80px;
            position: relative;
            overflow: hidden;
        }
        .hero::after {
            /* fingerprint ridges as a quiet background texture */
            content: "";
            position: absolute;
            right: -160px;
            top: -120px;
            width: 640px;
            height: 640px;
            border-radius: 50%;
            background: repeating-radial-gradient(circle at center, transparent 0 22px, rgba(255,255,255,.035) 22px 24px);
            pointer-events: none;
        }
        .hero-grid {
            position: relative;
            z-index: 1;
            display: grid;
            grid-template-columns: minmax(0, 1.05fr) minmax(0, .95fr);
            gap: 56px;
            align-items: center;
        }
        .hero-eyebrow { font-size: 14px; color: #93a4c3; margin-bottom: 18px; }
        .hero-eyebrow strong { color: #fff; font-weight: 600; }
        .hero h1 { color: #fff; font-size: clamp(34px, 4.6vw, 54px); letter-spacing: -0.02em; margin-bottom: 20px; }
        .hero h1 .accent { color: #7fa6ff; }
        .hero-lead { font-family: var(--font-serif); font-size: 18px; line-height: 1.65; color: #c3cde0; max-width: 540px; margin-bottom: 30px; }
        .hero-actions { display: flex; gap: 12px; flex-wrap: wrap; margin-bottom: 44px; }

        .facts { display: grid; grid-template-columns: repeat(4, auto); gap: 28px; justify-content: start; border-top: 1px solid rgba(255,255,255,.12); padding-top: 22px; }
        .fact-num { font-size: 26px; font-weight: 700; color: #fff; font-variant-numeric: tabular-nums; line-height: 1.1; }
        .fact-label { font-size: 12.5px; color: #93a4c3; margin-top: 4px; max-width: 130px; line-height: 1.4; }

        /* Live kiosk demo */
        .demo {
            background: #fff;
            color: var(--body);
            border-radius: 12px;
            box-shadow: 0 30px 60px -20px rgba(0,0,0,.45);
            overflow: hidden;
        }
        .demo-bar {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 12px 18px;
            border-bottom: 1px solid var(--line);
            font-size: 13px;
            color: var(--muted);
        }
        .demo-bar strong { color: var(--ink); font-weight: 600; }
        .demo-live { display: inline-flex; align-items: center; gap: 6px; color: var(--green); font-weight: 600; }
        .demo-live::before { content: ""; width: 7px; height: 7px; border-radius: 50%; background: currentColor; animation: blink 1.6s ease-in-out infinite; }
        @keyframes blink { 50% { opacity: .25; } }

        .demo-main { display: grid; grid-template-columns: 132px 1fr; gap: 20px; padding: 22px 18px 18px; align-items: center; }
        .scanner {
            position: relative;
            width: 132px;
            height: 132px;
            border-radius: 50%;
            background: var(--canvas);
            border: 1px solid var(--line);
            display: grid;
            place-items: center;
            overflow: hidden;
        }
        .scanner svg { width: 84px; height: 84px; color: #9aa6bd; transition: color .3s ease; }
        .scanner.is-match svg { color: var(--green); }
        .scanner.is-late svg { color: var(--amber); }
        .scanner-beam {
            position: absolute;
            left: 0;
            right: 0;
            height: 34px;
            top: -34px;
            background: linear-gradient(180deg, rgba(29,78,216,0) 0%, rgba(29,78,216,.22) 70%, rgba(29,78,216,.55) 100%);
            border-bottom: 2px solid var(--blue);
        }
        .scanner.is-scanning .scanner-beam { animation: beam 1.1s ease-in-out; }
        @keyframes beam { from { top: -34px; } to { top: 132px; } }

        .result { min-height: 104px; }
        .result-state { font-size: 12.5px; font-weight: 600; color: var(--muted); margin-bottom: 6px; }
        .result-name { font-size: 20px; font-weight: 700; color: var(--ink); line-height: 1.25; }
        .result-dept { font-size: 13px; color: var(--muted); }
        .result-meta { display: flex; gap: 10px; align-items: center; margin-top: 10px; font-size: 13px; }
        .result-time { font-variant-numeric: tabular-nums; font-weight: 600; color: var(--ink); }
        .chip { display: inline-block; padding: 2px 8px; border-radius: 4px; font-size: 12px; font-weight: 600; }
        .chip-ok { background: var(--green-soft); color: var(--green); }
        .chip-late { background: var(--amber-soft); color: var(--amber); }
        .result.is-entering { animation: rise .45s ease both; }
        @keyframes rise { from { opacity: 0; transform: translateY(8px); } to { opacity: 1; transform: none; } }

        .demo-progress { padding: 0 18px 16px; }
        .demo-progress-row { display: flex; justify-content: space-between; font-size: 12.5px; color: var(--muted); margin-bottom: 6px; }
        .demo-progress-row strong { color: var(--ink); font-variant-numeric: tabular-nums; }
        .bar { height: 6px; background: #e8ebf0; border-radius: 3px; overflow: hidden; }
        .bar > span { display: block; height: 100%; width: 0; background: var(--blue); transition: width .6s ease; }

        .demo-log { border-top: 1px solid var(--line); list-style: none; }
        .demo-log li {
            display: grid;
            grid-template-columns: 52px 1fr auto;
            gap: 10px;
            padding: 9px 18px;
            font-size: 13px;
            border-bottom: 1px solid #f0f2f5;
        }
        .demo-log li:last-child { border-bottom: none; }
        .demo-log .t { color: var(--muted); font-variant-numeric: tabular-nums; }
        .demo-log .n { color: var(--ink); font-weight: 500; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
        .demo-log li.is-new { animation: slideIn .4s ease both; background: #fafbff; }
        @keyframes slideIn { from { opacity: 0; transform: translateX(-10px); } to { opacity: 1; transform: none; } }

        /* ---------- Sections ---------- */
        .section { padding: 96px 0; }
        .section-white { background: #fff; border-top: 1px solid var(--line); border-bottom: 1px solid var(--line); }
        section[id] { scroll-margin-top: 64px; }
        .section-head { display: grid; grid-template-columns: 180px minmax(0, 1fr); gap: 32px; margin-bottom: 48px; }
        .section-index { font-size: 13px; color: var(--muted); padding-top: 10px; border-top: 2px solid var(--ink); font-weight: 600; }
        .section-index span { color: var(--blue); margin-right: 8px; font-variant-numeric: tabular-nums; }
        .section-head h2 { font-size: clamp(28px, 3.2vw, 38px); letter-spacing: -0.015em; margin-bottom: 12px; }
        .section-head p { font-family: var(--font-serif); font-size: 17px; color: var(--muted); max-width: 640px; }

        /* Capabilities by role */
        .roles { display: grid; grid-template-columns: repeat(3, 1fr); gap: 0; border: 1px solid var(--line); border-radius: 10px; overflow: hidden; background: #fff; }
        .role-col { padding: 28px 26px 30px; }
        .role-col + .role-col { border-left: 1px solid var(--line); }
        .role-tag { display: flex; align-items: center; gap: 10px; margin-bottom: 6px; }
        .role-tag svg { width: 22px; height: 22px; color: var(--blue); flex-shrink: 0; }
        .role-col h3 { font-size: 19px; }
        .role-col > p { font-size: 13.5px; color: var(--muted); margin-bottom: 18px; }
        .feature-list { list-style: none; }
        .feature-list li { padding: 12px 0; border-top: 1px solid #f0f2f5; }
        .feature-list strong { display: block; color: var(--ink); font-size: 14.5px; font-weight: 600; margin-bottom: 2px; }
        .feature-list span { font-size: 13.5px; color: var(--muted); line-height: 1.55; display: block; }

        /* How it works: pipeline */
        .pipeline { display: grid; grid-template-columns: repeat(3, 1fr); gap: 16px; position: relative; margin-bottom: 28px; }
        .pipeline-track { position: absolute; left: 16.6%; right: 16.6%; top: 27px; height: 2px; background: var(--line); z-index: 0; }
        .pipeline-pulse {
            position: absolute;
            top: -4px;
            width: 10px;
            height: 10px;
            border-radius: 50%;
            background: var(--blue);
            box-shadow: 0 0 0 4px rgba(29,78,216,.15);
            animation: travel 3.2s linear infinite;
        }
        @keyframes travel { from { left: 0; } to { left: calc(100% - 10px); } }
        .step {
            position: relative;
            z-index: 1;
            background: none;
            border: none;
            text-align: center;
            cursor: pointer;
            font: inherit;
            color: inherit;
            padding: 0 8px;
        }
        .step-dot {
            width: 56px;
            height: 56px;
            margin: 0 auto 12px;
            border-radius: 50%;
            background: #fff;
            border: 2px solid var(--line);
            display: grid;
            place-items: center;
            color: var(--muted);
            transition: border-color .2s ease, color .2s ease, background-color .2s ease;
        }
        .step-dot svg { width: 24px; height: 24px; }
        .step-title { display: block; font-weight: 600; color: var(--ink); font-size: 15px; }
        .step-sub { display: block; font-size: 13px; color: var(--muted); }
        .step-timer { display: block; height: 3px; width: 120px; margin: 12px auto 0; background: var(--line); border-radius: 2px; overflow: hidden; }
        .step-timer span { display: block; height: 100%; width: 0; background: var(--blue); }
        .step.is-active .step-dot { border-color: var(--blue); color: #fff; background: var(--blue); }
        .step.is-active .step-timer span { animation: fill 6s linear forwards; }
        .pipeline:hover .step.is-active .step-timer span { animation-play-state: paused; }
        @keyframes fill { to { width: 100%; } }

        .step-panel {
            display: grid;
            grid-template-columns: minmax(0, 1fr) minmax(0, 1fr);
            gap: 36px;
            align-items: center;
            background: #fff;
            border: 1px solid var(--line);
            border-radius: 10px;
            padding: 32px;
        }
        .step-panel h3 { font-size: 22px; margin-bottom: 10px; }
        .step-panel p { color: var(--body); margin-bottom: 16px; }
        .step-panel ul { list-style: none; display: grid; gap: 8px; font-size: 14px; }
        .step-panel li { padding-left: 20px; position: relative; }
        .step-panel li::before { content: ""; position: absolute; left: 0; top: 9px; width: 8px; height: 8px; border-radius: 2px; background: var(--blue); }
        .step-panel.is-switching .step-copy, .step-panel.is-switching .code { animation: rise .35s ease both; }
        .code {
            background: var(--navy);
            color: #dbe4f5;
            border-radius: 8px;
            padding: 20px 22px;
            font-family: var(--font-mono);
            font-size: 12.5px;
            line-height: 1.7;
            overflow-x: auto;
            white-space: pre;
        }

        /* Payroll calculator */
        .calc { display: grid; grid-template-columns: minmax(0, 1.1fr) minmax(0, .9fr); gap: 40px; }
        .calc-inputs { display: grid; gap: 22px; }
        .calc-row label { display: flex; justify-content: space-between; font-size: 14px; color: var(--ink); font-weight: 500; margin-bottom: 8px; }
        .calc-row output { font-variant-numeric: tabular-nums; font-weight: 600; color: var(--blue); }
        .calc-row input[type=range] { width: 100%; accent-color: var(--blue); cursor: pointer; }
        .calc-note { font-size: 13px; color: var(--muted); }
        .slip { background: var(--canvas); border: 1px solid var(--line); border-radius: 10px; padding: 26px; align-self: start; }
        .slip h3 { font-size: 16px; margin-bottom: 14px; }
        .slip-row { display: flex; justify-content: space-between; gap: 12px; padding: 9px 0; border-bottom: 1px dashed #d8dce3; font-size: 14px; }
        .slip-row span:last-child { font-variant-numeric: tabular-nums; color: var(--ink); font-weight: 500; }
        .slip-row.plus span:last-child { color: var(--blue); }
        .slip-row.minus span:last-child { color: var(--red); }
        .slip-total { display: flex; justify-content: space-between; align-items: baseline; padding-top: 16px; margin-top: 6px; border-top: 2px solid var(--ink); }
        .slip-total span:first-child { font-weight: 600; color: var(--ink); }
        .slip-total strong { font-size: 26px; color: var(--green); font-variant-numeric: tabular-nums; }

        /* Compare */
        .compare { width: 100%; border-collapse: collapse; background: #fff; border: 1px solid var(--line); border-radius: 10px; overflow: hidden; }
        .compare th, .compare td { padding: 16px 22px; text-align: left; vertical-align: top; font-size: 14px; border-bottom: 1px solid var(--line); }
        .compare tr:last-child td { border-bottom: none; }
        .compare th { font-size: 13px; color: var(--muted); font-weight: 600; background: #fafbfc; }
        .compare th:last-child { color: var(--blue); }
        .compare td:first-child { color: var(--ink); font-weight: 600; width: 26%; }
        .compare td:nth-child(2) { color: var(--muted); }
        .compare td:last-child { color: var(--ink); }
        .mark-no, .mark-yes { display: inline-block; width: 18px; font-weight: 700; }
        .mark-no { color: var(--red); }
        .mark-yes { color: var(--green); }

        /* FAQ */
        .faq { max-width: 860px; }
        .faq-item { border-bottom: 1px solid var(--line); }
        .faq-q {
            width: 100%;
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 16px;
            padding: 20px 0;
            background: none;
            border: none;
            text-align: left;
            font: inherit;
            font-size: 16px;
            font-weight: 600;
            color: var(--ink);
            cursor: pointer;
        }
        .faq-icon { width: 22px; height: 22px; flex-shrink: 0; transition: transform .25s ease; color: var(--muted); }
        .faq-item.open .faq-icon { transform: rotate(45deg); color: var(--blue); }
        .faq-a { overflow: hidden; height: 0; transition: height .3s ease; }
        .faq-a p { padding: 0 0 20px; color: var(--body); font-size: 15px; max-width: 760px; }

        /* Closing call to action */
        .cta { background: var(--navy); color: #c3cde0; padding: 72px 0; }
        .cta-inner { display: flex; justify-content: space-between; align-items: center; gap: 32px; flex-wrap: wrap; }
        .cta h2 { color: #fff; font-size: clamp(26px, 3vw, 34px); margin-bottom: 8px; }
        .cta p { font-family: var(--font-serif); font-size: 17px; }
        .cta-actions { display: flex; gap: 12px; flex-wrap: wrap; }

        .site-footer { background: var(--navy-2); color: #93a4c3; font-size: 13px; padding: 22px 0; }
        .footer-inner { display: flex; justify-content: space-between; gap: 16px; flex-wrap: wrap; }

        /* Reveal on scroll */
        .reveal { opacity: 0; transform: translateY(18px); transition: opacity .6s ease, transform .6s ease; }
        .reveal.is-visible { opacity: 1; transform: none; }
        .reveal-delay-1 { transition-delay: .08s; }
        .reveal-delay-2 { transition-delay: .16s; }

        @media (prefers-reduced-motion: reduce) {
            html { scroll-behavior: auto; }
            .reveal { opacity: 1; transform: none; transition: none; }
            .pipeline-pulse, .demo-live::before { animation: none; }
            .scanner.is-scanning .scanner-beam, .result.is-entering, .demo-log li.is-new { animation: none; }
            .step.is-active .step-timer span { animation: none; width: 100%; }
        }

        @media (max-width: 980px) {
            .nav-links { display: none; }
            .hero-grid, .calc, .step-panel { grid-template-columns: 1fr; }
            .facts { grid-template-columns: repeat(2, auto); }
            .roles { grid-template-columns: 1fr; }
            .role-col + .role-col { border-left: none; border-top: 1px solid var(--line); }
            .section-head { grid-template-columns: 1fr; gap: 16px; }
            .section-index { max-width: 180px; }
        }
        @media (max-width: 600px) {
            .nav-cta .btn-text { display: none; }
            .hero { padding: 48px 0 56px; }
            .section { padding: 64px 0; }
            .demo-main { grid-template-columns: 1fr; justify-items: center; text-align: center; }
            .result-meta { justify-content: center; }
            .pipeline { grid-template-columns: 1fr; }
            .pipeline-track { display: none; }
            .compare th:nth-child(2), .compare td:nth-child(2) { display: none; }
            .step-panel { padding: 22px; }
        }
    </style>
</head>
<body>

    <!-- Navigation: links follow the section order and highlight the section in view -->
    <header class="site-header">
        <div class="container nav-inner">
            <a href="${ctx}/" class="brand-link">
                <span class="brand-mark"><img src="${ctx}/assets/img/logo-mark.svg" alt="" aria-hidden="true"></span>
                <span>SmartAttend</span>
            </a>
            <ul class="nav-links">
                <li><a href="#features">Capabilities</a></li>
                <li><a href="#architecture">How it works</a></li>
                <li><a href="#calculator">Payroll calculator</a></li>
                <li><a href="#comparison">Compare</a></li>
                <li><a href="#faq">FAQ</a></li>
            </ul>
            <div class="nav-cta">
                <a href="${ctx}/kiosk" class="btn btn-text">Kiosk</a>
                <a href="${ctx}/login" class="btn btn-primary">Sign in</a>
            </div>
        </div>
    </header>

    <main>
        <!-- Hero with a live kiosk demo -->
        <section class="hero">
            <div class="container hero-grid">
                <div>
                    <p class="hero-eyebrow"><strong>Fingerprint attendance &amp; payroll</strong> &middot; ESP32 + AS608 terminal &middot; web portal</p>
                    <h1>Every check-in counted.<br><span class="accent">Every payslip right.</span></h1>
                    <p class="hero-lead">
                        Employees scan a finger at the door. The kiosk confirms who they are within two seconds,
                        and at the end of the month payroll is calculated from the attendance and the salary rules you set.
                    </p>
                    <div class="hero-actions">
                        <a href="${ctx}/login" class="btn btn-primary">Sign in to the portal</a>
                        <a href="${ctx}/dev/simulator" class="btn btn-onDark">Try the device simulator</a>
                    </div>
                    <div class="facts">
                        <div>
                            <div class="fact-num"><span data-count="2">2</span> s</div>
                            <div class="fact-label">from finger to name on the kiosk screen</div>
                        </div>
                        <div>
                            <div class="fact-num" data-count="9">9</div>
                            <div class="fact-label">salary rules you can change without code</div>
                        </div>
                        <div>
                            <div class="fact-num" data-count="3">3</div>
                            <div class="fact-label">roles: admin, staff and kiosk</div>
                        </div>
                        <div>
                            <div class="fact-num"><span data-count="60">60</span> s</div>
                            <div class="fact-label">guard against accidental double scans</div>
                        </div>
                    </div>
                </div>

                <div class="demo" aria-label="Animated example of the kiosk screen">
                    <div class="demo-bar">
                        <span><strong>Kiosk</strong> &middot; Main gate</span>
                        <span class="demo-live">Live demo</span>
                    </div>
                    <div class="demo-main">
                        <div class="scanner" id="demoScanner">
                            <svg viewBox="0 0 48 48" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" aria-hidden="true">
                                <path d="M24 26.5v6.5"/>
                                <path d="M18.5 35V26.5a5.5 5.5 0 0 1 11 0v4"/>
                                <path d="M13 32V26.5a11 11 0 0 1 22 0v2"/>
                                <path d="M8.5 29v-2.5a15.5 15.5 0 0 1 31 0V29"/>
                                <path d="M10.5 15a17 17 0 0 1 27 0"/>
                                <path d="M15 8.6a18 18 0 0 1 18 0"/>
                                <path d="M34 34.5c.4-1.6.6-3.2.7-4.8"/>
                            </svg>
                            <span class="scanner-beam"></span>
                        </div>
                        <div class="result" id="demoResult">
                            <div class="result-state" id="demoState">Waiting for a finger&hellip;</div>
                            <div class="result-name" id="demoName">&nbsp;</div>
                            <div class="result-dept" id="demoDept">&nbsp;</div>
                            <div class="result-meta">
                                <span class="result-time" id="demoTime"></span>
                                <span id="demoChip"></span>
                            </div>
                        </div>
                    </div>
                    <div class="demo-progress">
                        <div class="demo-progress-row">
                            <span>Checked in today</span>
                            <strong><span id="demoCount">11</span> of 24</strong>
                        </div>
                        <div class="bar"><span id="demoBar"></span></div>
                    </div>
                    <ul class="demo-log" id="demoLog">
                        <li><span class="t">07:49</span><span class="n">Trần Thị Lan &middot; HR</span><span class="chip chip-ok">On time</span></li>
                        <li><span class="t">07:46</span><span class="n">Võ Thị Mai &middot; Warehouse</span><span class="chip chip-ok">On time</span></li>
                        <li><span class="t">07:41</span><span class="n">Ngô Thị Thu &middot; Production</span><span class="chip chip-ok">On time</span></li>
                    </ul>
                </div>
            </div>
        </section>

        <!-- 01 Capabilities, grouped by who uses them -->
        <section id="features" class="section section-white">
            <div class="container">
                <div class="section-head reveal">
                    <div class="section-index"><span>01</span>Capabilities</div>
                    <div>
                        <h2>One system, three kinds of users</h2>
                        <p>Admins run the month, staff check their own records, and the terminal and kiosk handle the door. Each gets only what they need.</p>
                    </div>
                </div>

                <div class="roles">
                    <div class="role-col reveal">
                        <div class="role-tag">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect x="3" y="3" width="7" height="9"/><rect x="14" y="3" width="7" height="5"/><rect x="14" y="12" width="7" height="9"/><rect x="3" y="16" width="7" height="5"/></svg>
                            <h3>For admins</h3>
                        </div>
                        <p>HR and managers who run attendance and payroll.</p>
                        <ul class="feature-list">
                            <li><strong>Live dashboard</strong><span>Who is at work, late or absent, with an alert after 5 unrecognized scans in a minute.</span></li>
                            <li><strong>Shifts &amp; holidays</strong><span>Weekly schedules, overnight shifts recorded on their start date, public holiday calendar.</span></li>
                            <li><strong>Attendance corrections</strong><span>Fix a missing check-out; every change needs a reason and goes to the audit log.</span></li>
                            <li><strong>Payroll &amp; payslips</strong><span>Generate, lock, export PDF and email payslips. Blocked while a check-out is missing.</span></li>
                        </ul>
                    </div>
                    <div class="role-col reveal reveal-delay-1">
                        <div class="role-tag">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                            <h3>For staff</h3>
                        </div>
                        <p>Every employee, from their own login.</p>
                        <ul class="feature-list">
                            <li><strong>Today at a glance</strong><span>Check-in time, status and hours worked so far.</span></li>
                            <li><strong>My schedule</strong><span>Upcoming shifts for the week, including night shifts.</span></li>
                            <li><strong>My payslips</strong><span>Download each month's PDF payslip; nobody else's data is visible.</span></li>
                        </ul>
                    </div>
                    <div class="role-col reveal reveal-delay-2">
                        <div class="role-tag">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect x="2" y="3" width="20" height="14" rx="2"/><line x1="8" y1="21" x2="16" y2="21"/><line x1="12" y1="17" x2="12" y2="21"/></svg>
                            <h3>At the door</h3>
                        </div>
                        <p>The ESP32 terminal and the kiosk screen beside it.</p>
                        <ul class="feature-list">
                            <li><strong>Fingerprint check-in</strong><span>The AS608 sensor finds the employee; the server clock is the official time.</span></li>
                            <li><strong>Kiosk confirmation</strong><span>Name, time and status appear on screen within 2 seconds of the scan.</span></li>
                            <li><strong>Guided enrollment</strong><span>Two captures, guided on the kiosk; the employee can scan in right away.</span></li>
                            <li><strong>Offline warning</strong><span>A "device offline" banner appears when the terminal stops sending heartbeats.</span></li>
                        </ul>
                    </div>
                </div>
            </div>
        </section>

        <!-- 02 How it works -->
        <section id="architecture" class="section">
            <div class="container">
                <div class="section-head reveal">
                    <div class="section-index"><span>02</span>How it works</div>
                    <div>
                        <h2>From a fingertip to a payslip</h2>
                        <p>Three parts work together. Select a step, or let it play.</p>
                    </div>
                </div>

                <div class="pipeline reveal" id="pipeline">
                    <div class="pipeline-track" aria-hidden="true"><span class="pipeline-pulse"></span></div>
                    <button type="button" class="step is-active" data-step="0">
                        <span class="step-dot"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" aria-hidden="true"><path d="M12 11c0 3.5-1 6.5-3 9"/><path d="M8 4.8A8 8 0 0 1 20 12c0 2.5-.4 5-1.2 7"/><path d="M4 12a8 8 0 0 1 1.5-4.7"/><path d="M16 12a4 4 0 0 0-8 0c0 2.6-.6 5-1.8 7"/></svg></span>
                        <span class="step-title">1. Scan</span>
                        <span class="step-sub">ESP32 + AS608 terminal</span>
                        <span class="step-timer"><span></span></span>
                    </button>
                    <button type="button" class="step" data-step="1">
                        <span class="step-dot"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" aria-hidden="true"><rect x="2" y="3" width="20" height="14" rx="2"/><line x1="8" y1="21" x2="16" y2="21"/><line x1="12" y1="17" x2="12" y2="21"/></svg></span>
                        <span class="step-title">2. Confirm</span>
                        <span class="step-sub">Server + live kiosk</span>
                        <span class="step-timer"><span></span></span>
                    </button>
                    <button type="button" class="step" data-step="2">
                        <span class="step-dot"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" aria-hidden="true"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/></svg></span>
                        <span class="step-title">3. Pay</span>
                        <span class="step-sub">Rules + payroll</span>
                        <span class="step-timer"><span></span></span>
                    </button>
                </div>

                <div class="step-panel reveal" id="stepPanel">
                    <div class="step-copy">
                        <h3 id="stepTitle">The terminal reads the finger</h3>
                        <p id="stepDesc">The AS608 sensor captures the fingerprint and searches the templates stored on the sensor. The ESP32 sends the matching template ID and a confidence score to the server over Wi-Fi.</p>
                        <ul id="stepList">
                            <li>Templates stay on the sensor; the server keeps only the template ID</li>
                            <li>Each request carries the device's API key</li>
                            <li>A heartbeat tells the server the terminal is online</li>
                        </ul>
                    </div>
                    <div class="code" id="stepCode">// ESP32 firmware: match a finger, report it
uint8_t p = finger.getImage();
if (p != FINGERPRINT_OK) return;
finger.image2Tz();
if (finger.fingerFastSearch() == FINGERPRINT_OK) {
  postScan(finger.fingerID, finger.confidence);
}</div>
                </div>
            </div>
        </section>

        <!-- 03 Payroll calculator -->
        <section id="calculator" class="section section-white">
            <div class="container">
                <div class="section-head reveal">
                    <div class="section-index"><span>03</span>Payroll calculator</div>
                    <div>
                        <h2>See how a month's pay is worked out</h2>
                        <p>Move the sliders. The figures use the system's default rules; admins can change every rate on the Salary rules page.</p>
                    </div>
                </div>

                <div class="calc reveal">
                    <div class="calc-inputs">
                        <div class="calc-row">
                            <label for="sldBase">Monthly base salary <output id="lblBase">15,000,000 VND</output></label>
                            <input type="range" id="sldBase" min="5000000" max="50000000" step="500000" value="15000000">
                        </div>
                        <div class="calc-row">
                            <label for="sldRegH">Regular hours worked <output id="lblRegH">200 h</output></label>
                            <input type="range" id="sldRegH" min="80" max="208" step="1" value="200">
                        </div>
                        <div class="calc-row">
                            <label for="sldOtWd">Weekday overtime (150%) <output id="lblOtWd">10 h</output></label>
                            <input type="range" id="sldOtWd" min="0" max="40" step="1" value="10">
                        </div>
                        <div class="calc-row">
                            <label for="sldOtWe">Weekend overtime (200%) <output id="lblOtWe">4 h</output></label>
                            <input type="range" id="sldOtWe" min="0" max="32" step="1" value="4">
                        </div>
                        <div class="calc-row">
                            <label for="sldNightH">Night hours, 22:00&ndash;06:00 (+30%) <output id="lblNightH">8 h</output></label>
                            <input type="range" id="sldNightH" min="0" max="40" step="1" value="8">
                        </div>
                        <div class="calc-row">
                            <label for="sldLateM">Late minutes after the grace period <output id="lblLateM">20 min</output></label>
                            <input type="range" id="sldLateM" min="0" max="180" step="5" value="20">
                        </div>
                        <p class="calc-note">Hourly rate = base salary &divide; 208 standard hours. Late penalty = 1,000 VND per minute past the 5-minute grace period.</p>
                    </div>

                    <div class="slip">
                        <h3>Payslip preview</h3>
                        <div class="slip-row"><span>Hourly rate</span><span id="resRate">72,115 VND</span></div>
                        <div class="slip-row"><span>Regular pay</span><span id="resRegPay">14,423,077 VND</span></div>
                        <div class="slip-row plus"><span>Weekday overtime</span><span id="resOtWdPay">+1,081,731 VND</span></div>
                        <div class="slip-row plus"><span>Weekend overtime</span><span id="resOtWePay">+576,923 VND</span></div>
                        <div class="slip-row plus"><span>Night allowance</span><span id="resNightPay">+173,077 VND</span></div>
                        <div class="slip-row minus"><span>Late penalty</span><span id="resPenalty">&minus;20,000 VND</span></div>
                        <div class="slip-total"><span>Net salary</span><strong id="resNetTotal">16,234,808 VND</strong></div>
                    </div>
                </div>
            </div>
        </section>

        <!-- 04 Compare -->
        <section id="comparison" class="section">
            <div class="container">
                <div class="section-head reveal">
                    <div class="section-index"><span>04</span>Compare</div>
                    <div>
                        <h2>Why not a time clock and a spreadsheet?</h2>
                        <p>Standalone USB time clocks record scans. The work of turning them into pay is still done by hand.</p>
                    </div>
                </div>

                <table class="compare reveal">
                    <thead>
                        <tr>
                            <th>Task</th>
                            <th>Time clock + Excel</th>
                            <th>SmartAttend</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td>Getting the data</td>
                            <td><span class="mark-no">&times;</span>Export from the device by USB, monthly</td>
                            <td><span class="mark-yes">&check;</span>Each scan reaches the server and the dashboard as it happens</td>
                        </tr>
                        <tr>
                            <td>Buddy punching</td>
                            <td><span class="mark-no">&times;</span>PIN codes and cards can be shared</td>
                            <td><span class="mark-yes">&check;</span>Only a fingerprint checks you in</td>
                        </tr>
                        <tr>
                            <td>Overtime</td>
                            <td><span class="mark-no">&times;</span>Spreadsheet formulas, easy to get wrong</td>
                            <td><span class="mark-yes">&check;</span>150% / 200% / 300% applied by rule, per day type</td>
                        </tr>
                        <tr>
                            <td>Night shifts</td>
                            <td><span class="mark-no">&times;</span>Night hours estimated by hand</td>
                            <td><span class="mark-yes">&check;</span>Minutes between 22:00 and 06:00 counted automatically</td>
                        </tr>
                        <tr>
                            <td>Missing check-out</td>
                            <td><span class="mark-no">&times;</span>Found at month end, during disputes</td>
                            <td><span class="mark-yes">&check;</span>Payroll stays blocked until an admin fixes it, with a reason</td>
                        </tr>
                        <tr>
                            <td>Payslips</td>
                            <td><span class="mark-no">&times;</span>Printed or emailed one by one</td>
                            <td><span class="mark-yes">&check;</span>PDF for everyone, emailed in one batch after the payroll is locked</td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </section>

        <!-- 05 FAQ -->
        <section id="faq" class="section section-white">
            <div class="container">
                <div class="section-head reveal">
                    <div class="section-index"><span>05</span>FAQ</div>
                    <div>
                        <h2>Questions people ask</h2>
                        <p>About the terminal, scans and pay.</p>
                    </div>
                </div>

                <div class="faq reveal">
                    <div class="faq-item">
                        <button type="button" class="faq-q" aria-expanded="false">
                            What happens if the terminal loses Wi-Fi?
                            <svg class="faq-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" aria-hidden="true"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                        </button>
                        <div class="faq-a"><p>Scans made while the terminal is offline are not recorded. The kiosk shows a "device offline" banner once the terminal stops sending heartbeats, so people know to report it, and an admin can add the missed check-in on the Attendance page with a reason.</p></div>
                    </div>
                    <div class="faq-item">
                        <button type="button" class="faq-q" aria-expanded="false">
                            What if someone scans twice by accident?
                            <svg class="faq-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" aria-hidden="true"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                        </button>
                        <div class="faq-a"><p>A second scan from the same employee within 60 seconds is ignored and logged, so it can't create a false check-out.</p></div>
                    </div>
                    <div class="faq-item">
                        <button type="button" class="faq-q" aria-expanded="false">
                            How are overtime and late penalties calculated?
                            <svg class="faq-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" aria-hidden="true"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                        </button>
                        <div class="faq-a"><p>Hours beyond 8 in a day are overtime: 150% on weekdays, 200% at weekends and 300% on public holidays. Arriving within the grace period (5 minutes by default) counts as on time; after that, each late minute is deducted at the penalty rate. Every one of these numbers can be changed on the Salary rules page.</p></div>
                    </div>
                    <div class="faq-item">
                        <button type="button" class="faq-q" aria-expanded="false">
                            Why is payroll blocked when someone forgets to check out?
                            <svg class="faq-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" aria-hidden="true"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                        </button>
                        <div class="faq-a"><p>Without a check-out, the hours worked that day are unknown, so the pay would be wrong. The payroll page lists the missing check-outs; once an admin records the correct time with a reason, payroll can run.</p></div>
                    </div>
                    <div class="faq-item">
                        <button type="button" class="faq-q" aria-expanded="false">
                            Are fingerprint images stored on the server?
                            <svg class="faq-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" aria-hidden="true"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                        </button>
                        <div class="faq-a"><p>No. Fingerprint templates are stored on the AS608 sensor itself. The server only stores which template ID belongs to which employee, and which finger was enrolled.</p></div>
                    </div>
                </div>
            </div>
        </section>

        <!-- Closing call to action -->
        <section class="cta">
            <div class="container cta-inner">
                <div>
                    <h2>Ready to see it with your own team?</h2>
                    <p>Sign in as an admin, or open the kiosk and simulate a few scans.</p>
                </div>
                <div class="cta-actions">
                    <a href="${ctx}/login" class="btn btn-primary">Sign in</a>
                    <a href="${ctx}/kiosk" class="btn btn-onDark">Open the kiosk</a>
                </div>
            </div>
        </section>
    </main>

    <footer class="site-footer">
        <div class="container footer-inner">
            <span>SmartAttend &middot; Fingerprint attendance &amp; payroll</span>
            <span>ESP32 + AS608 &middot; Java Servlet/JSP &middot; SQL Server</span>
        </div>
    </footer>

    <script>
    (function () {
        var reduceMotion = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;
        var fmt = function (n) { return Math.round(n).toLocaleString('en-US'); };

        /* ---------- Reveal on scroll + count-up figures ---------- */
        var revealTargets = document.querySelectorAll('.reveal');
        var counters = document.querySelectorAll('[data-count]');

        function countUp(node) {
            var target = parseInt(node.getAttribute('data-count'), 10);
            if (reduceMotion || !target) { node.textContent = target; return; }
            var start = null, duration = 900;
            function tick(ts) {
                if (start === null) start = ts;
                var p = Math.min(1, (ts - start) / duration);
                node.textContent = Math.round(target * (1 - Math.pow(1 - p, 3)));
                if (p < 1) requestAnimationFrame(tick);
            }
            node.textContent = '0';
            requestAnimationFrame(tick);
            // Guarantee the final value even if animation frames are throttled (background tab, slow device).
            setTimeout(function () { node.textContent = target; }, duration + 100);
        }

        if ('IntersectionObserver' in window && !reduceMotion) {
            var io = new IntersectionObserver(function (entries) {
                entries.forEach(function (entry) {
                    if (!entry.isIntersecting) return;
                    entry.target.classList.add('is-visible');
                    io.unobserve(entry.target);
                });
            }, { threshold: 0.12 });
            revealTargets.forEach(function (n) { io.observe(n); });

            var countIo = new IntersectionObserver(function (entries) {
                entries.forEach(function (entry) {
                    if (!entry.isIntersecting) return;
                    countUp(entry.target);
                    countIo.unobserve(entry.target);
                });
            }, { threshold: 0.6 });
            counters.forEach(function (n) { countIo.observe(n); });
        } else {
            revealTargets.forEach(function (n) { n.classList.add('is-visible'); });
        }

        /* ---------- Menu highlights the section in view ---------- */
        var navLinks = Array.prototype.slice.call(document.querySelectorAll('.nav-links a'));
        var sections = navLinks.map(function (a) { return document.querySelector(a.getAttribute('href')); });
        function updateActiveLink() {
            var y = window.scrollY + 120, current = -1;
            sections.forEach(function (s, i) { if (s && s.offsetTop <= y) current = i; });
            navLinks.forEach(function (a, i) { a.classList.toggle('is-active', i === current); });
        }
        window.addEventListener('scroll', updateActiveLink, { passive: true });
        updateActiveLink();

        /* ---------- Live kiosk demo ---------- */
        var people = [
            ['Lê Minh Tuấn', 'Production'], ['Phạm Thị Hoa', 'Warehouse'], ['Đỗ Văn Hùng', 'Security'],
            ['Bùi Thanh Hương', 'Accounting'], ['Nguyễn Ngọc Thạch', 'Executive board'], ['Hoàng Đức Minh', 'Production'],
            ['Trương Văn Khoa', 'Production'], ['Đặng Quốc Bảo', 'Warehouse'], ['Lý Thị Ngọc', 'Accounting'],
            ['Phan Quốc Lâm', 'Production'], ['Nguyễn Quang Thanh', 'Security'], ['Võ Hữu Trí', 'Warehouse']
        ];
        var TOTAL = 24, START_COUNT = 11, SHIFT_START = 8 * 60, GRACE = 5;
        var scanner = document.getElementById('demoScanner');
        var result = document.getElementById('demoResult');
        var log = document.getElementById('demoLog');
        var countEl = document.getElementById('demoCount');
        var barEl = document.getElementById('demoBar');
        var idx = 0, count = START_COUNT, minute = 7 * 60 + 51;

        function hhmm(m) { return String(Math.floor(m / 60)).padStart(2, '0') + ':' + String(m % 60).padStart(2, '0'); }
        function setProgress() { countEl.textContent = count; barEl.style.width = (count * 100 / TOTAL) + '%'; }

        function showResult(person, time, late) {
            document.getElementById('demoState').textContent = late ? 'Checked in · late' : 'Checked in';
            document.getElementById('demoName').textContent = person[0];
            document.getElementById('demoDept').textContent = person[1];
            document.getElementById('demoTime').textContent = time;
            var chip = document.getElementById('demoChip');
            chip.className = 'chip ' + (late ? 'chip-late' : 'chip-ok');
            chip.textContent = late ? 'Late ' + late + ' min' : 'On time';
            scanner.classList.remove('is-match', 'is-late');
            scanner.classList.add(late ? 'is-late' : 'is-match');
            result.classList.remove('is-entering'); void result.offsetWidth; result.classList.add('is-entering');
        }

        function addLog(person, time, late) {
            var li = document.createElement('li');
            li.className = 'is-new';
            var t = document.createElement('span'); t.className = 't'; t.textContent = time;
            var n = document.createElement('span'); n.className = 'n'; n.textContent = person[0] + ' · ' + person[1];
            var c = document.createElement('span'); c.className = 'chip ' + (late ? 'chip-late' : 'chip-ok'); c.textContent = late ? 'Late' : 'On time';
            li.appendChild(t); li.appendChild(n); li.appendChild(c);
            log.insertBefore(li, log.firstChild);
            while (log.children.length > 3) log.removeChild(log.lastChild);
        }

        function nextScan() {
            if (document.hidden) return;
            if (count >= TOTAL) { count = START_COUNT; minute = 7 * 60 + 51; }
            var person = people[idx % people.length];
            idx++;
            minute += 1 + Math.floor(Math.random() * 3);
            var late = Math.max(0, minute - SHIFT_START - GRACE);
            var time = hhmm(minute);

            document.getElementById('demoState').textContent = 'Reading fingerprint…';
            scanner.classList.remove('is-match', 'is-late', 'is-scanning'); void scanner.offsetWidth;
            scanner.classList.add('is-scanning');
            setTimeout(function () {
                count++;
                showResult(person, time, late);
                addLog(person, time, late);
                setProgress();
            }, reduceMotion ? 0 : 1100);
        }

        setProgress();
        showResult(['Trần Thị Lan', 'Human resources'], '07:49', 0);
        if (!reduceMotion) setInterval(nextScan, 3200);

        /* ---------- How it works: auto-advancing steps ---------- */
        var steps = [
            {
                title: 'The terminal reads the finger',
                desc: 'The AS608 sensor captures the fingerprint and searches the templates stored on the sensor. The ESP32 sends the matching template ID and a confidence score to the server over Wi-Fi.',
                list: ['Templates stay on the sensor; the server keeps only the template ID', "Each request carries the device's API key", 'A heartbeat tells the server the terminal is online'],
                code: '// ESP32 firmware: match a finger, report it\nuint8_t p = finger.getImage();\nif (p != FINGERPRINT_OK) return;\nfinger.image2Tz();\nif (finger.fingerFastSearch() == FINGERPRINT_OK) {\n  postScan(finger.fingerID, finger.confidence);\n}'
            },
            {
                title: 'The server decides and the kiosk confirms',
                desc: 'The server looks up the employee, checks the confidence threshold and the 60-second double-scan guard, then records a check-in or check-out against the right shift. The result is pushed to the kiosk and the admin dashboard straight away.',
                list: ['Late or on time is decided from the shift start and the grace period', 'Low-confidence and unknown fingers are rejected and logged', 'Five unknown scans in a minute raise a dashboard alert'],
                code: '// Server-Sent Events: push the result to every open screen\nhub.broadcast("kiosk", "scan_result", payload);\nhub.broadcast("dashboard", "scan_event", dashPayload);'
            },
            {
                title: 'Payroll uses the attendance and your rules',
                desc: 'At month end the payroll page adds up regular hours, overtime by day type, night hours and late minutes, then applies the salary rules. Once locked, PDF payslips are generated and emailed.',
                list: ['Blocked while any check-out is missing', 'Every rate is a setting on the Salary rules page', 'Locked payroll cannot be changed by accident'],
                code: '// PayrollCalculator: net salary from the rules\nhourlyRate = baseSalary / standardHours;\novertime   = otWeekday * hourlyRate * 1.5\n           + otWeekend * hourlyRate * 2.0\n           + otHoliday * hourlyRate * 3.0;\nnight      = nightHours * hourlyRate * 0.3;\nnet        = regular + overtime + night - lateMinutes * penaltyRate;'
            }
        ];
        var stepButtons = document.querySelectorAll('.step');
        var panel = document.getElementById('stepPanel');
        var pipeline = document.getElementById('pipeline');
        var current = 0, stepTimer = null;

        function showStep(i) {
            current = i;
            stepButtons.forEach(function (b, k) { b.classList.toggle('is-active', k === i); });
            var s = steps[i];
            document.getElementById('stepTitle').textContent = s.title;
            document.getElementById('stepDesc').textContent = s.desc;
            var ul = document.getElementById('stepList');
            ul.innerHTML = '';
            s.list.forEach(function (t) { var li = document.createElement('li'); li.textContent = t; ul.appendChild(li); });
            document.getElementById('stepCode').textContent = s.code;
            panel.classList.remove('is-switching'); void panel.offsetWidth; panel.classList.add('is-switching');
            restartStepTimer();
        }
        function restartStepTimer() {
            clearTimeout(stepTimer);
            if (reduceMotion) return;
            stepTimer = setTimeout(function () {
                if (pipeline.matches(':hover')) { restartStepTimer(); return; }
                showStep((current + 1) % steps.length);
            }, 6000);
        }
        stepButtons.forEach(function (b, k) { b.addEventListener('click', function () { showStep(k); }); });
        restartStepTimer();

        /* ---------- Payroll calculator (default rules) ---------- */
        var RULES = { standardHours: 208, otWeekday: 1.5, otWeekend: 2.0, night: 0.3, penaltyPerMinute: 1000 };
        var shown = {};
        function tween(id, value, prefix) {
            var node = document.getElementById(id);
            var from = shown[id] === undefined ? value : shown[id];
            shown[id] = value;
            if (reduceMotion || from === value) { node.textContent = prefix + fmt(value) + ' VND'; return; }
            var start = null;
            function tick(ts) {
                if (start === null) start = ts;
                var p = Math.min(1, (ts - start) / 350);
                if (shown[id] !== value) return; // a newer value took over
                node.textContent = prefix + fmt(from + (value - from) * p) + ' VND';
                if (p < 1) requestAnimationFrame(tick);
            }
            requestAnimationFrame(tick);
            setTimeout(function () { if (shown[id] === value) node.textContent = prefix + fmt(value) + ' VND'; }, 450);
        }
        function val(id) { return parseFloat(document.getElementById(id).value) || 0; }
        function calcPayroll() {
            var base = val('sldBase'), regH = val('sldRegH'), otWd = val('sldOtWd'), otWe = val('sldOtWe'),
                nightH = val('sldNightH'), lateM = val('sldLateM');
            var rate = base / RULES.standardHours;
            var reg = rate * regH, wd = rate * RULES.otWeekday * otWd, we = rate * RULES.otWeekend * otWe,
                night = rate * RULES.night * nightH, penalty = lateM * RULES.penaltyPerMinute;
            var net = Math.max(0, reg + wd + we + night - penalty);

            document.getElementById('lblBase').textContent = fmt(base) + ' VND';
            document.getElementById('lblRegH').textContent = regH + ' h';
            document.getElementById('lblOtWd').textContent = otWd + ' h';
            document.getElementById('lblOtWe').textContent = otWe + ' h';
            document.getElementById('lblNightH').textContent = nightH + ' h';
            document.getElementById('lblLateM').textContent = lateM + ' min';

            tween('resRate', rate, '');
            tween('resRegPay', reg, '');
            tween('resOtWdPay', wd, '+');
            tween('resOtWePay', we, '+');
            tween('resNightPay', night, '+');
            tween('resPenalty', penalty, '−');
            tween('resNetTotal', net, '');
        }
        document.querySelectorAll('.calc input[type=range]').forEach(function (r) { r.addEventListener('input', calcPayroll); });
        calcPayroll();

        /* ---------- FAQ: smooth open/close ---------- */
        document.querySelectorAll('.faq-item').forEach(function (item) {
            var q = item.querySelector('.faq-q'), a = item.querySelector('.faq-a');
            q.addEventListener('click', function () {
                var open = !item.classList.contains('open');
                item.classList.toggle('open', open);
                q.setAttribute('aria-expanded', open);
                a.style.height = open ? a.scrollHeight + 'px' : '0px';
            });
        });
        var first = document.querySelector('.faq-item');
        if (first) first.querySelector('.faq-q').click();
    })();
    </script>
</body>
</html>
