<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<c:set var="pageTitle" value="ESP32 Device Simulator"/>
<c:set var="activeNav" value="simulator"/>
<%@include file="/WEB-INF/views/common/header.jspf"%>

<style>
    .sim-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; }
    .sim-card { background: var(--surface); border: 1px solid var(--line); border-radius: var(--radius); padding: 20px; }
    .sim-card h2 { font-size: 16px; margin: 0 0 16px 0; display: flex; align-items: center; justify-content: space-between; }
    .badge-status { padding: 4px 8px; border-radius: 6px; font-size: 12px; font-weight: 600; }
    .status-online { background: #dcfce7; color: #15803d; }
    .status-offline { background: #fee2e2; color: #b91c1c; }
    .field { margin-bottom: 14px; }
    .field label { display: block; font-weight: 500; font-size: 13px; margin-bottom: 4px; }
    .field select, .field input[type="text"], .field input[type="number"] {
        width: 100%; padding: 8px 12px; border: 1px solid var(--line); border-radius: 6px; font-size: 14px;
    }
    .field input[type="range"] { width: 100%; }
    .btn-row { display: flex; gap: 10px; margin-top: 14px; }
    .btn-row .btn { flex: 1; text-align: center; justify-content: center; }
    .btn-primary { background: #1f5eff; color: white; border: none; padding: 10px; border-radius: 6px; cursor: pointer; font-weight: 600; }
    .btn-primary:hover { background: #1848c7; }
    .btn-warning { background: #f59e0b; color: white; border: none; padding: 10px; border-radius: 6px; cursor: pointer; font-weight: 600; }
    .btn-warning:hover { background: #d97706; }
    .btn-danger { background: #ef4444; color: white; border: none; padding: 10px; border-radius: 6px; cursor: pointer; font-weight: 600; }
    .btn-danger:hover { background: #dc2626; }
    .btn-secondary { background: #f3f4f6; color: #374151; border: 1px solid var(--line); padding: 10px; border-radius: 6px; cursor: pointer; }
    .btn-secondary:hover { background: #e5e7eb; }
    
    .console-box {
        background: #111827; color: #10b981; font-family: ui-monospace, monospace;
        font-size: 12px; padding: 16px; border-radius: 8px; height: 350px; overflow-y: auto;
        white-space: pre-wrap; line-height: 1.5;
    }
    .command-banner {
        background: #eff6ff; border: 1px solid #bfdbfe; border-radius: 8px; padding: 14px; margin-top: 10px;
    }
</style>

<div class="page-head">
    <div>
        <h1>ESP32 Device Simulator</h1>
        <p class="muted">Simulate biometric attendance scans, heartbeats, and device commands without physical hardware.</p>
    </div>
</div>

<div class="sim-grid">
    <!-- Left Column: Controls -->
    <div>
        <!-- Device Info & Heartbeat -->
        <div class="sim-card field">
            <h2>
                1. Virtual Device
                <span id="heartbeatStatus" class="badge-status status-offline">Heartbeat OFF</span>
            </h2>
            <div class="field">
                <label>Active Device:</label>
                <select id="deviceSelect" onchange="onDeviceChange()">
                    <c:forEach var="d" items="${devices}">
                        <option value="${d.id}" data-key="${d.apiKey}">${d.name} (${d.location})</option>
                    </c:forEach>
                </select>
            </div>
            <div class="field">
                <label>Header <code>X-API-Key</code>:</label>
                <input type="text" id="apiKeyInput" readonly class="mono" style="background:#f9fafb;">
            </div>
            <div class="btn-row">
                <button type="button" class="btn btn-secondary" onclick="toggleHeartbeat()" id="btnHeartbeat">Start Auto Heartbeat (10s)</button>
                <button type="button" class="btn btn-secondary" onclick="sendHeartbeat()">Ping Now</button>
            </div>
        </div>

        <!-- Attendance Scanner Simulation -->
        <div class="sim-card field">
            <h2>2. AS608 Fingerprint Scanner</h2>
            <div class="field">
                <label>Select Enrolled Finger:</label>
                <select id="templateSelect" onchange="onTemplateChange()">
                    <option value="">-- Choose enrolled fingerprint or type custom --</option>
                    <c:forEach var="fp" items="${fingerprints}">
                        <option value="${fp.templateId}">Template #${fp.templateId} - Employee ID #${fp.employeeId} (${fp.fingerName})</option>
                    </c:forEach>
                </select>
            </div>
            <div class="field">
                <label>Template ID (1 - 162):</label>
                <input type="number" id="templateIdInput" value="1" min="1" max="162">
            </div>
            <div class="field">
                <label>Confidence Score: <span id="confDisplay" style="font-weight:700;">85</span>%</label>
                <input type="range" id="confidenceInput" min="1" max="100" value="85" oninput="document.getElementById('confDisplay').innerText = this.value">
            </div>
            <div class="btn-row">
                <button type="button" class="btn btn-primary" onclick="simulateScan()">Scan Finger</button>
                <button type="button" class="btn btn-warning" onclick="simulateUnknown()">Unknown Finger</button>
                <button type="button" class="btn btn-danger" onclick="simulateBurst()" title="Sends 5 scans rapidly to test anti-spam">Burst x5</button>
            </div>
        </div>

        <!-- Command Listener -->
        <div class="sim-card">
            <h2>
                3. Device Commands Poller
                <span id="pollerStatus" class="badge-status status-online">Polling (3s)</span>
            </h2>
            <div id="noCommandMsg" class="muted" style="font-size: 13px;">Waiting for server commands (e.g. ENROLL from Admin)...</div>
            <div id="commandBox" class="command-banner" style="display:none;">
                <div style="font-weight:600; color:#1e40af; margin-bottom: 6px;" id="cmdText">Incoming command...</div>
                <div class="btn-row">
                    <button type="button" class="btn btn-primary" onclick="respondCommand('DONE')">Simulate Success (DONE)</button>
                    <button type="button" class="btn btn-danger" onclick="respondCommand('FAILED')">Simulate Fail (FAILED)</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Right Column: Live Terminal Log -->
    <div>
        <div class="sim-card" style="height: 100%;">
            <h2>
                HTTP Traffic Log
                <button type="button" class="btn btn-secondary btn-sm" onclick="clearConsole()" style="font-size:11px; padding:4px 8px;">Clear</button>
            </h2>
            <div id="console" class="console-box">Simulator initialized. Ready for traffic...</div>
        </div>
    </div>
</div>

<script>
    const contextPath = '${pageContext.request.contextPath}';
    let heartbeatTimer = null;
    let pollTimer = null;
    let currentCommand = null;

    function getApiKey() {
        return document.getElementById('apiKeyInput').value;
    }

    function onDeviceChange() {
        const sel = document.getElementById('deviceSelect');
        const opt = sel.options[sel.selectedIndex];
        document.getElementById('apiKeyInput').value = opt ? opt.getAttribute('data-key') : '';
    }

    function onTemplateChange() {
        const val = document.getElementById('templateSelect').value;
        if (val) {
            document.getElementById('templateIdInput').value = val;
        }
    }

    function log(text) {
        const box = document.getElementById('console');
        const time = new Date().toLocaleTimeString();
        box.textContent += "\n[" + time + "] " + text;
        box.scrollTop = box.scrollHeight;
    }

    function clearConsole() {
        document.getElementById('console').textContent = "Console cleared.";
    }

    // 1. Heartbeat
    async function sendHeartbeat() {
        log("--> POST /api/device/heartbeat");
        try {
            const res = await fetch(contextPath + '/api/device/heartbeat', {
                method: 'POST',
                headers: { 'X-API-Key': getApiKey() }
            });
            const data = await res.json();
            log("<-- HTTP " + res.status + " " + JSON.stringify(data));
        } catch (err) {
            log("<-- Error: " + err.message);
        }
    }

    function toggleHeartbeat() {
        const btn = document.getElementById('btnHeartbeat');
        const badge = document.getElementById('heartbeatStatus');
        if (heartbeatTimer) {
            clearInterval(heartbeatTimer);
            heartbeatTimer = null;
            btn.textContent = "Start Auto Heartbeat (10s)";
            badge.textContent = "Heartbeat OFF";
            badge.className = "badge-status status-offline";
            log("Heartbeat stopped.");
        } else {
            sendHeartbeat();
            heartbeatTimer = setInterval(sendHeartbeat, 10000);
            btn.textContent = "Stop Auto Heartbeat";
            badge.textContent = "Heartbeat ON";
            badge.className = "badge-status status-online";
            log("Heartbeat started every 10s.");
        }
    }

    // 2. Scan Fingerprint
    async function doScan(templateId, confidence) {
        const payload = { templateId: templateId, confidence: confidence };
        log("--> POST /api/device/scan " + JSON.stringify(payload));
        try {
            const res = await fetch(contextPath + '/api/device/scan', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'X-API-Key': getApiKey()
                },
                body: JSON.stringify(payload)
            });
            const data = await res.json();
            log("<-- HTTP " + res.status + " " + JSON.stringify(data));
        } catch (err) {
            log("<-- Error: " + err.message);
        }
    }

    function simulateScan() {
        const tid = parseInt(document.getElementById('templateIdInput').value) || 1;
        const conf = parseInt(document.getElementById('confidenceInput').value) || 85;
        doScan(tid, conf);
    }

    function simulateUnknown() {
        const conf = parseInt(document.getElementById('confidenceInput').value) || 20;
        doScan(null, conf);
    }

    function simulateBurst() {
        log("⚡ Sending Burst x5 scans (interval 200ms)...");
        const tid = parseInt(document.getElementById('templateIdInput').value) || 1;
        const conf = parseInt(document.getElementById('confidenceInput').value) || 90;
        let count = 0;
        const interval = setInterval(() => {
            doScan(tid, conf);
            count++;
            if (count >= 5) clearInterval(interval);
        }, 200);
    }

    // 3. Command Poller
    async function pollCommands() {
        try {
            const res = await fetch(contextPath + '/api/device/command', {
                headers: { 'X-API-Key': getApiKey() }
            });
            const data = await res.json();
            if (data && data.id) {
                currentCommand = data;
                document.getElementById('noCommandMsg').style.display = 'none';
                document.getElementById('commandBox').style.display = 'block';
                document.getElementById('cmdText').innerHTML = 
                    "🔔 <strong>Command #" + data.id + "</strong>: " + data.type + " (Template #" + data.templateId + ")";
                log("--> Received command: " + JSON.stringify(data));
            } else {
                currentCommand = null;
                document.getElementById('noCommandMsg').style.display = 'block';
                document.getElementById('commandBox').style.display = 'none';
            }
        } catch (err) {
            // Ignore polling network glitches
        }
    }

    async function respondCommand(status) {
        if (!currentCommand) return;
        const payload = { id: currentCommand.id, status: status };
        log("--> POST /api/device/command/result " + JSON.stringify(payload));
        try {
            const res = await fetch(contextPath + '/api/device/command/result', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'X-API-Key': getApiKey()
                },
                body: JSON.stringify(payload)
            });
            const data = await res.json();
            log("<-- HTTP " + res.status + " " + JSON.stringify(data));
            currentCommand = null;
            document.getElementById('noCommandMsg').style.display = 'block';
            document.getElementById('commandBox').style.display = 'none';
        } catch (err) {
            log("<-- Error: " + err.message);
        }
    }

    // Init
    window.addEventListener('DOMContentLoaded', () => {
        onDeviceChange();
        pollTimer = setInterval(pollCommands, 3000);
    });
</script>

<%@include file="/WEB-INF/views/common/footer.jspf"%>
