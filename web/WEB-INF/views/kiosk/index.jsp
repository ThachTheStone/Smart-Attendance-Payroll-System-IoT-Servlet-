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

        /* Device Offline / System Alert Floating Banner (FR-KIOSK-06) */
        #offlineBanner {
            display: none;
            position: fixed;
            top: 86px;
            left: 50%;
            transform: translateX(-50%);
            z-index: 100;
            background: linear-gradient(135deg, rgba(185, 28, 28, 0.96), rgba(220, 38, 38, 0.94));
            color: #ffffff;
            padding: 16px 28px;
            border-radius: 18px;
            border: 1px solid rgba(254, 202, 202, 0.4);
            box-shadow: 0 20px 40px -8px rgba(220, 38, 38, 0.55), 0 0 30px rgba(239, 68, 68, 0.35);
            backdrop-filter: blur(16px);
            align-items: center;
            gap: 16px;
            width: max-content;
            max-width: min(92vw, 880px);
            box-sizing: border-box;
            animation: slideDown 0.35s cubic-bezier(0.16, 1, 0.3, 1);
        }

        .offline-icon-wrap {
            width: 44px;
            height: 44px;
            border-radius: 12px;
            background: rgba(0, 0, 0, 0.25);
            border: 1px solid rgba(255, 255, 255, 0.2);
            display: grid;
            place-items: center;
            flex-shrink: 0;
            color: #fef08a;
            animation: pulseWarning 2s infinite ease-in-out;
        }

        @keyframes pulseWarning {
            0%, 100% { transform: scale(1); filter: drop-shadow(0 0 4px rgba(254, 240, 138, 0.4)); }
            50% { transform: scale(1.08); filter: drop-shadow(0 0 10px rgba(254, 240, 138, 0.8)); }
        }

        .offline-banner-body {
            display: flex;
            flex-direction: column;
            gap: 4px;
            text-align: left;
        }

        .offline-badge-tag {
            font-size: 11px;
            font-weight: 800;
            letter-spacing: 1.2px;
            text-transform: uppercase;
            color: #fef08a;
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }

        .offline-badge-dot {
            width: 7px;
            height: 7px;
            border-radius: 50%;
            background: #fef08a;
            box-shadow: 0 0 8px #fef08a;
        }

        #offlineBannerText {
            font-size: 17px;
            font-weight: 700;
            line-height: 1.45;
            color: #ffffff;
            text-shadow: 0 1px 3px rgba(0, 0, 0, 0.35);
            word-break: break-word;
        }

        @keyframes slideDown {
            from { transform: translate(-50%, -24px); opacity: 0; }
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
            overflow-y: auto;
        }

        /* 1. IDLE STATE VIEW (FR-KIOSK-02) */
        .view-idle {
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            text-align: center;
            animation: fadeIn 0.4s ease-out;
            width: 100%;
            max-width: 900px;
        }

        /* Idle Live Announcement Ribbon */
        .idle-announcement-ribbon {
            display: inline-flex;
            align-items: center;
            gap: 14px;
            background: rgba(255, 255, 255, 0.05);
            border: 1px solid rgba(255, 255, 255, 0.12);
            backdrop-filter: blur(14px);
            padding: 10px 24px;
            border-radius: 999px;
            margin-bottom: 24px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
            max-width: min(92vw, 780px);
            box-sizing: border-box;
        }

        .idle-announcement-badge {
            display: inline-flex;
            align-items: center;
            gap: 7px;
            background: rgba(59, 130, 246, 0.22);
            border: 1px solid rgba(59, 130, 246, 0.45);
            color: #93c5fd;
            font-size: 12px;
            font-weight: 800;
            letter-spacing: 1px;
            text-transform: uppercase;
            padding: 5px 12px;
            border-radius: 999px;
            flex-shrink: 0;
        }

        .idle-announcement-badge .ping-dot {
            width: 7px;
            height: 7px;
            border-radius: 50%;
            background: #60a5fa;
            box-shadow: 0 0 8px #3b82f6;
            animation: blink 2s infinite;
        }

        .idle-announcement-text {
            font-size: 15px;
            font-weight: 600;
            color: #e2e8f0;
            white-space: normal;
            line-height: 1.45;
            letter-spacing: 0.2px;
        }

        .clock-display {
            font-family: 'JetBrains Mono', monospace;
            font-size: 112px;
            font-weight: 700;
            letter-spacing: -2px;
            background: linear-gradient(180deg, #ffffff 30%, #94a3b8 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            text-shadow: 0 10px 30px rgba(0,0,0,0.5);
            line-height: 1;
        }

        .date-display {
            font-size: 24px;
            font-weight: 600;
            color: #cbd5e1;
            margin-top: 14px;
            text-transform: capitalize;
        }

        .scanner-halo {
            position: relative;
            margin: 36px 0 24px;
            width: 176px;
            height: 176px;
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
            width: 84px;
            height: 84px;
            z-index: 2;
            filter: drop-shadow(0 0 20px var(--primary-glow));
        }

        .prompt-title {
            font-size: 32px;
            font-weight: 800;
            letter-spacing: 0.4px;
            color: #f8fafc;
        }

        .prompt-subtitle {
            font-size: 18px;
            font-weight: 500;
            color: var(--text-muted);
            margin-top: 10px;
            max-width: 680px;
            line-height: 1.5;
        }

        /* 2. SUCCESS STATE VIEW (FR-KIOSK-03) */
        .view-success {
            display: none;
            width: 95%;
            max-width: 1060px;
            background: rgba(15, 23, 42, 0.96);
            backdrop-filter: blur(28px);
            border: 2px solid var(--success);
            border-radius: 28px;
            padding: 34px 40px;
            box-shadow: 0 25px 70px -10px var(--success-glow), 0 0 50px rgba(16, 185, 129, 0.15);
            animation: popIn 0.35s cubic-bezier(0.175, 0.885, 0.32, 1.275);
            position: relative;
            box-sizing: border-box;
            flex-direction: column;
        }

        .view-success.theme-checkout {
            border-color: var(--primary);
            box-shadow: 0 25px 70px -10px var(--primary-glow), 0 0 50px rgba(59, 130, 246, 0.15);
        }

        /* Modal Top Bar */
        .modal-top-bar {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 22px;
            padding-bottom: 18px;
            border-bottom: 1px solid rgba(255, 255, 255, 0.08);
            gap: 16px;
            width: 100%;
            box-sizing: border-box;
        }

        .action-banner {
            display: inline-flex;
            align-items: center;
            gap: 12px;
            padding: 12px 36px;
            border-radius: 999px;
            font-size: 20px;
            font-weight: 800;
            letter-spacing: 1.5px;
            text-transform: uppercase;
            box-shadow: 0 8px 25px rgba(0, 0, 0, 0.35);
        }

        .banner-checkin {
            background: linear-gradient(135deg, #059669, #10b981);
            color: #ffffff;
            border: 1px solid #34d399;
            box-shadow: 0 0 25px var(--success-glow);
        }

        .banner-checkout {
            background: linear-gradient(135deg, #1d4ed8, #3b82f6);
            color: #ffffff;
            border: 1px solid #60a5fa;
            box-shadow: 0 0 25px var(--primary-glow);
        }

        .auto-dismiss-badge {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            background: rgba(255, 255, 255, 0.06);
            border: 1px solid rgba(255, 255, 255, 0.12);
            padding: 8px 18px;
            border-radius: 999px;
            font-size: 14px;
            font-weight: 600;
            color: #cbd5e1;
            font-family: 'JetBrains Mono', monospace;
        }

        .dismiss-dot {
            width: 8px;
            height: 8px;
            border-radius: 50%;
            background: #10b981;
            box-shadow: 0 0 8px #10b981;
            animation: blink 1.5s infinite;
        }

        /* Two-Column Widescreen Layout */
        .kiosk-modal-grid {
            display: grid;
            grid-template-columns: 320px 1fr;
            gap: 30px;
            align-items: stretch;
            width: 100%;
            text-align: left;
            box-sizing: border-box;
        }

        /* Left Column: Biometric Profile Card */
        .emp-profile-card {
            background: rgba(255, 255, 255, 0.03);
            border: 1px solid rgba(255, 255, 255, 0.08);
            border-radius: 22px;
            padding: 26px 20px;
            display: flex;
            flex-direction: column;
            align-items: center;
            text-align: center;
            justify-content: center;
            box-sizing: border-box;
        }

        .avatar-wrap {
            position: relative;
            margin-bottom: 16px;
        }

        .avatar-circle {
            width: 120px;
            height: 120px;
            border-radius: 50%;
            background: #1e293b;
            border: 4px solid #334155;
            display: grid;
            place-items: center;
            font-size: 42px;
            font-weight: 800;
            color: #94a3b8;
            overflow: hidden;
            box-shadow: 0 10px 30px rgba(0,0,0,0.5), 0 0 25px rgba(16, 185, 129, 0.25);
        }

        .theme-checkout .avatar-circle {
            box-shadow: 0 10px 30px rgba(0,0,0,0.5), 0 0 25px rgba(59, 130, 246, 0.25);
        }

        .avatar-circle img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        .verified-badge {
            position: absolute;
            bottom: 4px;
            right: 4px;
            width: 32px;
            height: 32px;
            border-radius: 50%;
            background: #10b981;
            color: white;
            display: grid;
            place-items: center;
            border: 3px solid #0f172a;
            box-shadow: 0 0 12px #10b981;
        }

        .emp-name {
            font-size: 28px;
            font-weight: 800;
            margin-bottom: 10px;
            color: #ffffff;
            line-height: 1.25;
            word-break: break-word;
        }

        .emp-meta-badges {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            flex-wrap: wrap;
            margin-bottom: 16px;
            width: 100%;
        }

        .meta-chip {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 5px 12px;
            border-radius: 8px;
            font-size: 13px;
            font-weight: 700;
            letter-spacing: 0.3px;
            max-width: 100%;
            word-break: break-word;
        }

        .code-chip {
            background: rgba(59, 130, 246, 0.15);
            border: 1px solid rgba(59, 130, 246, 0.35);
            color: #93c5fd;
        }

        .dept-chip {
            background: rgba(255, 255, 255, 0.07);
            border: 1px solid rgba(255, 255, 255, 0.14);
            color: #e2e8f0;
        }

        .verification-status-tag {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            font-size: 12px;
            font-weight: 600;
            color: #34d399;
            background: rgba(16, 185, 129, 0.1);
            border: 1px solid rgba(16, 185, 129, 0.25);
            padding: 5px 14px;
            border-radius: 999px;
        }

        .v-dot {
            width: 6px;
            height: 6px;
            border-radius: 50%;
            background: #34d399;
            box-shadow: 0 0 6px #34d399;
        }

        /* Right Column: Announcement & Telemetry Details */
        .announcement-details-col {
            display: flex;
            flex-direction: column;
            gap: 18px;
            justify-content: center;
            min-width: 0;
        }

        /* The Hero Announcement Card */
        .transaction-announcement-card {
            background: linear-gradient(135deg, rgba(6, 78, 59, 0.65), rgba(16, 185, 129, 0.15));
            border: 1.5px solid rgba(52, 211, 153, 0.4);
            border-radius: 20px;
            padding: 20px 26px;
            box-shadow: inset 0 1px 1px rgba(255, 255, 255, 0.15), 0 12px 30px rgba(0, 0, 0, 0.25);
            box-sizing: border-box;
            width: 100%;
        }

        .theme-checkout .transaction-announcement-card {
            background: linear-gradient(135deg, rgba(30, 58, 138, 0.65), rgba(59, 130, 246, 0.15));
            border-color: rgba(96, 165, 250, 0.4);
        }

        .announcement-head-row {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 8px;
            gap: 12px;
        }

        .announcement-pill-tag {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            font-size: 12px;
            font-weight: 800;
            letter-spacing: 1.2px;
            text-transform: uppercase;
            color: #6ee7b7;
        }

        .theme-checkout .announcement-pill-tag {
            color: #93c5fd;
        }

        .announcement-live-indicator {
            font-size: 11px;
            font-weight: 800;
            letter-spacing: 1px;
            color: #a7f3d0;
            background: rgba(16, 185, 129, 0.2);
            padding: 3px 10px;
            border-radius: 6px;
            border: 1px solid rgba(52, 211, 153, 0.3);
        }

        .theme-checkout .announcement-live-indicator {
            color: #bfdbfe;
            background: rgba(59, 130, 246, 0.2);
            border-color: rgba(96, 165, 250, 0.3);
        }

        .transaction-announcement-msg {
            font-size: 21px;
            font-weight: 700;
            line-height: 1.45;
            color: #ffffff;
            word-break: break-word;
            text-shadow: 0 1px 3px rgba(0,0,0,0.4);
        }

        /* Telemetry Cards Grid */
        .telemetry-cards-grid {
            display: grid;
            grid-template-columns: repeat(3, minmax(0, 1fr));
            gap: 16px;
            width: 100%;
            box-sizing: border-box;
        }

        .telemetry-card {
            background: rgba(255, 255, 255, 0.04);
            border: 1px solid rgba(255, 255, 255, 0.09);
            border-radius: 18px;
            padding: 18px 20px;
            display: flex;
            flex-direction: column;
            align-items: flex-start;
            min-width: 0;
            box-sizing: border-box;
        }

        .telemetry-header {
            display: flex;
            align-items: center;
            gap: 6px;
            font-size: 12px;
            font-weight: 700;
            color: #94a3b8;
            text-transform: uppercase;
            letter-spacing: 0.8px;
            margin-bottom: 8px;
        }

        .telemetry-val {
            font-size: 26px;
            font-weight: 700;
            font-family: 'JetBrains Mono', monospace;
            color: #ffffff;
            line-height: 1.25;
            margin-bottom: 6px;
            width: 100%;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .telemetry-val.time-val { color: #60a5fa; }
        .telemetry-val.hours-val { color: #34d399; }

        .telemetry-sub {
            font-size: 12px;
            color: #94a3b8;
        }

        .status-pill {
            display: inline-block;
            padding: 6px 16px;
            border-radius: 999px;
            font-size: 15px;
            font-weight: 800;
            white-space: nowrap;
            line-height: 1.3;
            max-width: 100%;
            text-align: center;
        }
        .pill-ON_TIME { background: #064e3b; color: #6ee7b7; border: 1px solid #059669; }
        .pill-LATE { background: #78350f; color: #fde68a; border: 1px solid #d97706; }
        .pill-EARLY_LEAVE { background: #7c2d12; color: #fed7aa; border: 1px solid #ea580c; }
        .pill-OVERTIME { background: #4c1d95; color: #ddd6fe; border: 1px solid #7c3aed; }

        /* 3. FAIL / NOT RECOGNIZED VIEW (FR-KIOSK-04) */
        .view-fail {
            display: none;
            width: 95%;
            max-width: 980px;
            background: rgba(15, 23, 42, 0.96);
            backdrop-filter: blur(28px);
            border: 2px solid var(--danger);
            border-radius: 28px;
            padding: 34px 40px;
            box-shadow: 0 25px 70px -10px var(--danger-glow), 0 0 50px rgba(239, 68, 68, 0.15);
            animation: popIn 0.35s cubic-bezier(0.175, 0.885, 0.32, 1.275);
            position: relative;
            box-sizing: border-box;
            flex-direction: column;
        }

        .fail-modal-grid {
            display: grid;
            grid-template-columns: 260px 1fr;
            gap: 30px;
            align-items: center;
            width: 100%;
            text-align: left;
            box-sizing: border-box;
        }

        .fail-hero-col {
            display: flex;
            flex-direction: column;
            align-items: center;
            text-align: center;
            padding: 24px 20px;
            background: rgba(239, 68, 68, 0.04);
            border: 1px solid rgba(239, 68, 68, 0.15);
            border-radius: 22px;
            box-sizing: border-box;
        }

        .fail-icon-halo {
            width: 100px;
            height: 100px;
            border-radius: 50%;
            background: rgba(239, 68, 68, 0.15);
            border: 3px solid var(--danger);
            display: grid;
            place-items: center;
            color: var(--danger);
            box-shadow: 0 0 35px var(--danger-glow);
            margin-bottom: 14px;
        }

        .fail-hero-tag {
            font-size: 13px;
            font-weight: 800;
            letter-spacing: 1px;
            color: #f87171;
            text-transform: uppercase;
        }

        .fail-content-col {
            display: flex;
            flex-direction: column;
            gap: 16px;
            min-width: 0;
        }

        .fail-title {
            font-size: 32px;
            font-weight: 800;
            color: #f87171;
            line-height: 1.25;
            word-break: break-word;
        }

        .fail-announcement-card {
            background: linear-gradient(135deg, rgba(127, 29, 29, 0.65), rgba(239, 68, 68, 0.18));
            border: 1.5px solid rgba(248, 113, 113, 0.4);
            border-radius: 20px;
            padding: 20px 26px;
            box-shadow: inset 0 1px 1px rgba(255, 255, 255, 0.12), 0 12px 30px rgba(0, 0, 0, 0.25);
            box-sizing: border-box;
        }

        .fail-announcement-tag {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            font-size: 12px;
            font-weight: 800;
            letter-spacing: 1.2px;
            text-transform: uppercase;
            color: #fca5a5;
            margin-bottom: 6px;
        }

        .fail-announcement-msg {
            font-size: 21px;
            font-weight: 700;
            line-height: 1.45;
            color: #ffffff;
            word-break: break-word;
        }

        .fail-tips-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 12px;
            width: 100%;
        }

        .fail-tip-item {
            background: rgba(255, 255, 255, 0.04);
            border: 1px solid rgba(255, 255, 255, 0.08);
            border-radius: 14px;
            padding: 12px 14px;
            font-size: 13px;
            color: #cbd5e1;
            display: flex;
            align-items: center;
            gap: 8px;
            font-weight: 500;
        }

        /* 4. ENROLLMENT GUIDANCE VIEW (FR-KIOSK-05) */
        .view-enroll {
            display: none;
            width: 95%;
            max-width: 1000px;
            background: rgba(15, 23, 42, 0.96);
            backdrop-filter: blur(28px);
            border: 2px solid var(--primary);
            border-radius: 28px;
            padding: 34px 40px;
            box-shadow: 0 25px 70px -10px var(--primary-glow), 0 0 50px rgba(59, 130, 246, 0.15);
            animation: popIn 0.35s cubic-bezier(0.175, 0.885, 0.32, 1.275);
            position: relative;
            box-sizing: border-box;
            flex-direction: column;
        }

        .enroll-modal-grid {
            display: grid;
            grid-template-columns: 280px 1fr;
            gap: 30px;
            align-items: center;
            width: 100%;
            text-align: left;
            box-sizing: border-box;
        }

        .enroll-hero-col {
            background: rgba(59, 130, 246, 0.04);
            border: 1px solid rgba(59, 130, 246, 0.15);
            border-radius: 22px;
            padding: 24px 20px;
            text-align: center;
            display: flex;
            flex-direction: column;
            align-items: center;
            box-sizing: border-box;
        }

        .enroll-badge-title {
            display: inline-block;
            font-size: 13px;
            font-weight: 800;
            color: #93c5fd;
            text-transform: uppercase;
            letter-spacing: 1.5px;
            padding: 5px 16px;
            border-radius: 999px;
            background: rgba(59, 130, 246, 0.15);
            border: 1px solid rgba(59, 130, 246, 0.35);
            margin-bottom: 12px;
        }

        .enroll-details-col {
            display: flex;
            flex-direction: column;
            gap: 18px;
            min-width: 0;
        }

        .step-indicators {
            display: flex;
            justify-content: flex-start;
            gap: 20px;
            margin: 6px 0 10px;
        }

        .step-dot {
            width: 48px;
            height: 48px;
            border-radius: 50%;
            background: rgba(255,255,255,0.08);
            border: 2px solid rgba(255,255,255,0.15);
            color: var(--text-muted);
            display: grid;
            place-items: center;
            font-weight: 800;
            font-size: 17px;
            transition: all 0.3s ease;
        }

        .step-dot.active {
            background: var(--primary);
            border-color: #93c5fd;
            color: white;
            box-shadow: 0 0 20px var(--primary-glow);
            transform: scale(1.08);
        }

        .step-dot.completed {
            background: var(--success);
            border-color: #6ee7b7;
            color: white;
            box-shadow: 0 0 15px var(--success-glow);
        }

        .enroll-step-headline {
            font-size: 28px;
            font-weight: 800;
            color: #f8fafc;
            line-height: 1.3;
        }

        .enroll-announcement-card {
            background: linear-gradient(135deg, rgba(30, 58, 138, 0.65), rgba(59, 130, 246, 0.15));
            border: 1.5px solid rgba(96, 165, 250, 0.4);
            border-radius: 20px;
            padding: 20px 26px;
            box-sizing: border-box;
        }

        .enroll-announcement-msg {
            font-size: 20px;
            font-weight: 700;
            line-height: 1.45;
            color: #ffffff;
            word-break: break-word;
        }

        /* Countdown Progress Bar */
        .countdown-wrap {
            height: 7px;
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

        @keyframes popIn {
            0% { transform: scale(0.92); opacity: 0; }
            100% { transform: scale(1); opacity: 1; }
        }

        @keyframes fadeIn {
            from { opacity: 0; }
            to { opacity: 1; }
        }

        @media (max-width: 900px) {
            .kiosk-modal-grid, .fail-modal-grid, .enroll-modal-grid {
                grid-template-columns: 1fr;
                gap: 20px;
            }
            .telemetry-cards-grid {
                grid-template-columns: 1fr;
            }
            .fail-tips-grid {
                grid-template-columns: 1fr;
            }
            .modal-top-bar {
                flex-direction: column;
                align-items: flex-start;
            }
        }

        /* Footer Info */
        .kiosk-footer {
            padding: 14px 32px;
            text-align: center;
            font-size: 13px;
            color: rgba(255, 255, 255, 0.4);
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

    <!-- Floating Device Offline & System Alert Banner (FR-KIOSK-06) -->
    <div id="offlineBanner">
        <div class="offline-icon-wrap">
            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.3" stroke-linecap="round">
                <line x1="1" y1="1" x2="23" y2="23"></line>
                <path d="M16.72 11.06A10.94 10.94 0 0 1 19 12.55"></path>
                <path d="M5 12.55a10.94 10.94 0 0 1 5.17-2.39"></path>
                <path d="M10.71 5.05A16 16 0 0 1 22.58 9"></path>
                <path d="M1.42 9a15.91 15.91 0 0 1 4.7-2.88"></path>
                <path d="M8.53 16.11a6 6 0 0 1 6.95 0"></path>
                <line x1="12" y1="20" x2="12.01" y2="20"></line>
            </svg>
        </div>
        <div class="offline-banner-body">
            <div class="offline-badge-tag">
                <span class="offline-badge-dot"></span>
                <span>SYSTEM ALERT · HARDWARE WARNING</span>
            </div>
            <div id="offlineBannerText">WARNING: Biometric fingerprint sensor is offline (Connection lost)!</div>
        </div>
    </div>

    <!-- Main Dynamic Workspace -->
    <main class="stage">

        <!-- VIEW 1: IDLE STATE (FR-KIOSK-02) -->
        <section class="view-idle" id="viewIdle">
            <!-- Idle Announcement Ribbon -->
            <div class="idle-announcement-ribbon" id="idleAnnouncement">
                <div class="idle-announcement-badge">
                    <span class="ping-dot"></span>
                    <span>TERMINAL NOTICE</span>
                </div>
                <div class="idle-announcement-text" id="idleAnnouncementText">
                    Terminal Ready · Place finger flat and steady on the sensor to record attendance
                </div>
            </div>

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
        <section class="view-success theme-checkin" id="viewSuccess">
            <!-- Modal Top Bar -->
            <div class="modal-top-bar">
                <div class="action-banner banner-checkin" id="succActionBanner">
                    <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                        <polyline points="20 6 9 17 4 12"></polyline>
                    </svg>
                    <span id="succActionText">CHECK-IN SUCCESSFUL</span>
                </div>
                <div class="auto-dismiss-badge">
                    <span class="dismiss-dot" id="succDismissDot"></span>
                    <span id="succDismissTimer">Auto-closing in 5s</span>
                </div>
            </div>

            <!-- Two-Column Kiosk Command Center Grid -->
            <div class="kiosk-modal-grid">
                <!-- Left Column: Biometric Profile Card -->
                <div class="emp-profile-card">
                    <div class="avatar-wrap">
                        <div class="avatar-circle" id="succAvatar">LT</div>
                        <div class="verified-badge" title="Identity Verified">
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round">
                                <polyline points="20 6 9 17 4 12"></polyline>
                            </svg>
                        </div>
                    </div>
                    <h2 class="emp-name" id="succEmpName">Employee</h2>
                    <div class="emp-meta-badges" id="succEmpMeta">
                        <span class="meta-chip code-chip" id="succEmpCode">Code: EMP001</span>
                        <span class="meta-chip dept-chip" id="succEmpDept">Engineering</span>
                    </div>
                    <div class="verification-status-tag">
                        <span class="v-dot"></span>
                        <span>Biometrics Verified</span>
                    </div>
                </div>

                <!-- Right Column: Announcement & Telemetry Details -->
                <div class="announcement-details-col">
                    <!-- Hero Transaction Announcement Card (Wide, spacious, zero clipping) -->
                    <div class="transaction-announcement-card">
                        <div class="announcement-head-row">
                            <div class="announcement-pill-tag">
                                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.3" stroke-linecap="round" stroke-linejoin="round">
                                    <circle cx="12" cy="12" r="10"></circle>
                                    <line x1="12" y1="16" x2="12" y2="12"></line>
                                    <line x1="12" y1="8" x2="12.01" y2="8"></line>
                                </svg>
                                <span>Attendance Announcement</span>
                            </div>
                            <span class="announcement-live-indicator">LOGGED IN REAL-TIME</span>
                        </div>
                        <div class="transaction-announcement-msg" id="succMsg">Check-in recorded successfully</div>
                    </div>

                    <!-- Telemetry Cards Grid -->
                    <div class="telemetry-cards-grid">
                        <div class="telemetry-card">
                            <div class="telemetry-header">
                                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round">
                                    <circle cx="12" cy="12" r="10"></circle>
                                    <polyline points="12 6 12 12 16 14"></polyline>
                                </svg>
                                <span>Recorded Time</span>
                            </div>
                            <div class="telemetry-val time-val" id="succTime">07:58:12</div>
                            <div class="telemetry-sub">Official Log Time</div>
                        </div>

                        <div class="telemetry-card">
                            <div class="telemetry-header">
                                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round">
                                    <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path>
                                    <polyline points="22 4 12 14.01 9 11.01"></polyline>
                                </svg>
                                <span>Shift Status</span>
                            </div>
                            <div class="telemetry-val" style="margin-bottom: 2px;">
                                <span class="status-pill pill-ON_TIME" id="succStatusPill">On Time</span>
                            </div>
                            <div class="telemetry-sub">Schedule Evaluation</div>
                        </div>

                        <div class="telemetry-card">
                            <div class="telemetry-header">
                                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round">
                                    <path d="M12 2v20M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"></path>
                                </svg>
                                <span>Worked Today</span>
                            </div>
                            <div class="telemetry-val hours-val" id="succHours">--</div>
                            <div class="telemetry-sub">Accumulated Hours</div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="countdown-wrap">
                <div class="countdown-bar" id="succCountdown"></div>
            </div>
        </section>

        <!-- VIEW 3: FAIL / NOT RECOGNIZED (FR-KIOSK-04) -->
        <section class="view-fail" id="viewFail">
            <div class="modal-top-bar" style="margin-bottom: 24px;">
                <div class="auto-dismiss-badge" style="border-color: rgba(239, 68, 68, 0.3);">
                    <span class="dismiss-dot" style="background:#ef4444; box-shadow:0 0 8px #ef4444;"></span>
                    <span id="failDismissTimer">Auto-closing in 4s</span>
                </div>
            </div>

            <div class="fail-modal-grid">
                <div class="fail-hero-col">
                    <div class="fail-icon-halo">
                        <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round">
                            <circle cx="12" cy="12" r="10"></circle>
                            <line x1="15" y1="9" x2="9" y2="15"></line>
                            <line x1="9" y1="9" x2="15" y2="15"></line>
                        </svg>
                    </div>
                    <div class="fail-hero-tag">Scan Unsuccessful</div>
                </div>

                <div class="fail-content-col">
                    <h2 id="failTitle" class="fail-title">Fingerprint Not Recognized</h2>
                    
                    <div class="fail-announcement-card">
                        <div class="fail-announcement-tag">
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.3" stroke-linecap="round">
                                <circle cx="12" cy="12" r="10"></circle>
                                <line x1="12" y1="8" x2="12" y2="12"></line>
                                <line x1="12" y1="16" x2="12.01" y2="16"></line>
                            </svg>
                            <span>Biometric Sensor Alert</span>
                        </div>
                        <div class="fail-announcement-msg" id="failMsg">Please try again or ensure your finger is clean and flat on the sensor.</div>
                    </div>

                    <div class="fail-tips-grid">
                        <div class="fail-tip-item">
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#f87171" stroke-width="2"><path d="M12 2v4M12 18v4M4.93 4.93l2.83 2.83M16.24 16.24l2.83 2.83M2 12h4M18 12h4M4.93 19.07l2.83-2.83M16.24 7.76l2.83-2.83"/></svg>
                            <span>Press firmly and flat</span>
                        </div>
                        <div class="fail-tip-item">
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#f87171" stroke-width="2"><circle cx="12" cy="12" r="10"/><path d="M12 6v6l4 2"/></svg>
                            <span>Keep finger steady 1s</span>
                        </div>
                        <div class="fail-tip-item">
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#f87171" stroke-width="2"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                            <span>Contact HR if unregistered</span>
                        </div>
                    </div>
                </div>
            </div>

            <div class="countdown-wrap">
                <div class="countdown-bar danger" id="failCountdown"></div>
            </div>
        </section>

        <!-- VIEW 4: ENROLLMENT GUIDANCE (FR-KIOSK-05) -->
        <section class="view-enroll" id="viewEnroll">
            <div class="modal-top-bar" style="margin-bottom: 20px;">
                <div class="enroll-badge-title" style="margin-bottom: 0;">Fingerprint Enrollment Mode</div>
                <div class="auto-dismiss-badge" style="border-color: rgba(59, 130, 246, 0.3);">
                    <span class="dismiss-dot" style="background:#3b82f6; box-shadow:0 0 8px #3b82f6;"></span>
                    <span id="enrollDismissTimer">Enrolling Active</span>
                </div>
            </div>

            <div class="enroll-modal-grid">
                <div class="enroll-hero-col">
                    <div class="scanner-halo" style="margin: 10px 0 16px;">
                        <div class="scanner-ring" style="border-color: var(--primary);"></div>
                        <div class="scanner-glow" style="background: radial-gradient(circle, rgba(59, 130, 246, 0.4) 0%, transparent 70%);"></div>
                        <svg class="fingerprint-icon" style="color: #60a5fa;" viewBox="0 0 64 64" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round">
                            <path d="M20 50c-3-6-4-12-4-18a16 16 0 0 1 32 0c0 4-1 8-2 11"/>
                            <path d="M26 54c-3-6-4-14-4-22a10 10 0 0 1 20 0c0 7-1 13-3 18"/>
                            <path d="M32 32c0 9-1 16-4 24"/><path d="M38 34c0 6-1 11-2 15"/>
                            <path d="M14 22a20 20 0 0 1 36 0"/>
                        </svg>
                    </div>
                    <h3 class="emp-name" id="enrollEmpName" style="font-size: 22px; margin-bottom: 4px;">Enrolling employee...</h3>
                    <div style="font-size: 13px; color: #94a3b8;">Biometric Registration</div>
                </div>

                <div class="enroll-details-col">
                    <div class="step-indicators">
                        <div class="step-dot active" id="dotStep1">1</div>
                        <div class="step-dot" id="dotStep2">2</div>
                        <div class="step-dot" id="dotStep3">✓</div>
                    </div>

                    <div class="enroll-step-headline" id="enrollStepText">Step 1/2: Place finger on sensor</div>

                    <div class="enroll-announcement-card">
                        <div class="announcement-pill-tag" style="color: #93c5fd; margin-bottom: 8px;">
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.3" stroke-linecap="round">
                                <circle cx="12" cy="12" r="10"></circle>
                                <line x1="12" y1="16" x2="12" y2="12"></line>
                                <line x1="12" y1="8" x2="12.01" y2="8"></line>
                            </svg>
                            <span>Live Guidance</span>
                        </div>
                        <div class="enroll-announcement-msg" id="enrollSubText">Place finger flat and keep steady on optical scanner.</div>
                    </div>
                </div>
            </div>

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
                const el = document.getElementById(id);
                if (el) el.style.display = (id === viewId) ? 'flex' : 'none';
            });
        }

        function scheduleReturnToIdle(durationMs, barElementId, timerElementId) {
            clearTimeout(returnTimer);
            clearInterval(countdownInterval);

            const bar = document.getElementById(barElementId);
            const timerEl = timerElementId ? document.getElementById(timerElementId) : null;

            if (bar) {
                bar.style.width = '100%';
                const startTime = Date.now();
                const totalSeconds = Math.ceil(durationMs / 1000);
                if (timerEl) {
                    timerEl.textContent = 'Auto-closing in ' + totalSeconds + 's';
                }

                countdownInterval = setInterval(() => {
                    const elapsed = Date.now() - startTime;
                    const remainingPercent = Math.max(0, 100 - (elapsed / durationMs) * 100);
                    bar.style.width = remainingPercent + '%';

                    if (timerEl) {
                        const remainingSec = Math.max(0, Math.ceil((durationMs - elapsed) / 1000));
                        timerEl.textContent = 'Auto-closing in ' + remainingSec + 's';
                    }

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
            
            // Meta chips
            const codeEl = document.getElementById('succEmpCode');
            const deptEl = document.getElementById('succEmpDept');
            if (codeEl) codeEl.textContent = 'Code: ' + (emp.code || '--');
            if (deptEl) deptEl.textContent = emp.department || 'Company';

            // Avatar / Initials
            const avatarBox = document.getElementById('succAvatar');
            if (emp.photo && emp.photo.trim() !== '') {
                avatarBox.innerHTML = '<img src="' + emp.photo + '" alt="Avatar">';
            } else {
                const initials = (emp.name || 'NV').split(' ').filter(Boolean).map(p => p[0]).join('').slice(-2).toUpperCase();
                avatarBox.textContent = initials || 'EM';
            }

            // Theme & Action Banner
            const viewSec = document.getElementById('viewSuccess');
            const banner = document.getElementById('succActionBanner');

            if (data.result === 'CHECK_IN') {
                viewSec.className = 'view-success theme-checkin';
                banner.className = 'action-banner banner-checkin';
                banner.innerHTML = '<svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"></polyline></svg><span id="succActionText">CHECK-IN SUCCESSFUL</span>';
            } else {
                viewSec.className = 'view-success theme-checkout';
                banner.className = 'action-banner banner-checkout';
                banner.innerHTML = '<svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"></path><polyline points="16 17 21 12 16 7"></polyline><line x1="21" y1="12" x2="9" y2="12"></line></svg><span id="succActionText">CHECK-OUT SUCCESSFUL</span>';
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

            document.getElementById('succMsg').textContent = data.message || (data.result === 'CHECK_IN' ? 'Check-in recorded successfully' : 'Check-out recorded successfully');

            showView('viewSuccess');
            scheduleReturnToIdle(5000, 'succCountdown', 'succDismissTimer'); // Return after 5 seconds (FR-KIOSK-03)
        }

        function handleScanFail(data, title) {
            document.getElementById('failTitle').textContent = title || 'Fingerprint Not Recognized';
            document.getElementById('failMsg').textContent = data.message || 'Fingerprint not recognized, please try again.';
            showView('viewFail');
            scheduleReturnToIdle(4000, 'failCountdown', 'failDismissTimer'); // Return after 4 seconds (FR-KIOSK-04)
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
                scheduleReturnToIdle(15000, 'enrollCountdown', 'enrollDismissTimer');
            } else if (step === 'REMOVE_FINGER') {
                d1.className = 'step-dot completed';
                d2.className = 'step-dot active';
                text.textContent = 'Lift your finger';
                sub.textContent = 'Lift your finger from the sensor to prepare for second scan.';
                scheduleReturnToIdle(10000, 'enrollCountdown', 'enrollDismissTimer');
            } else if (step === 'PLACE_AGAIN') {
                d1.className = 'step-dot completed';
                d2.className = 'step-dot active';
                text.textContent = 'Step 2/2: Place the same finger again';
                sub.textContent = 'Place the same finger again for template verification.';
                scheduleReturnToIdle(15000, 'enrollCountdown', 'enrollDismissTimer');
            } else if (step === 'SUCCESS') {
                d1.className = 'step-dot completed';
                d2.className = 'step-dot completed';
                d3.className = 'step-dot completed';
                text.textContent = '✅ Fingerprint Enrolled Successfully!';
                sub.textContent = 'Employee can now use fingerprint for attendance.';
                scheduleReturnToIdle(5000, 'enrollCountdown', 'enrollDismissTimer');
            } else if (step === 'FAILED') {
                text.textContent = '❌ Fingerprint Enrollment Failed!';
                sub.textContent = 'Fingerprint scans did not match or template quality was low. Please retry.';
                scheduleReturnToIdle(5000, 'enrollCountdown', 'enrollDismissTimer');
            }
        }

        // 5. Device Offline Banner (FR-KIOSK-06)
        function handleDeviceStatus(data) {
            const banner = document.getElementById('offlineBanner');
            if (data.online === false) {
                banner.style.display = 'flex';
                document.getElementById('offlineBannerText').textContent = 
                    'WARNING: Device ' + (data.deviceName || 'Sensor') + ' is offline (Connection lost)!';
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
                        handleScanFail(data, 'Fingerprint Not Recognized');
                    } else {
                        // IGNORED (Cooldown / Spam protection)
                        handleScanFail({ message: data.message || 'Please wait 1 minute between scans.' }, 'Scan Cooldown (Please Wait)');
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

            es.addEventListener('announcement', (e) => {
                try {
                    const data = JSON.parse(e.data);
                    if (data && data.message) {
                        const noticeEl = document.getElementById('idleAnnouncementText');
                        if (noticeEl) {
                            noticeEl.textContent = data.message;
                        }
                    }
                } catch (err) {
                    console.error('Announcement parse error', err);
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
