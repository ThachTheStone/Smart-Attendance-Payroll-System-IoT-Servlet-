# Page Override Specification: Biometric Attendance Kiosk (`/kiosk`)
*Parent Design System: `../MASTER.md`*

## 1. Role & Intent
The Kiosk page runs full-screen in Chromium/Edge on a tablet or laptop placed next to the AS608 optical fingerprint reader.
It communicates with `/kiosk/stream` (Server-Sent Events) to display real-time scan feedback to workers in under 150ms.

## 2. Visual Theme & Dark Mode Tokens
Unlike administrative screens, the Kiosk uses **Dark Mode (OLED)** to maximize contrast, eliminate glare, and deliver a futuristic biometric feel.

```css
:root {
    --bg-kiosk: #090d16;
    --surface-kiosk: rgba(17, 24, 39, 0.88);
    --border-kiosk: rgba(255, 255, 255, 0.12);
    --biometric-glow-idle: rgba(56, 189, 248, 0.35);
    --biometric-glow-success: rgba(16, 185, 129, 0.45);
    --biometric-glow-danger: rgba(239, 68, 68, 0.45);
}
```

## 3. Interaction States
1. **IDLE State**:
   - Digital Clock (64px `JetBrains Mono` or `Plus Jakarta Sans`) with current date in Vietnamese/English.
   - Sensor Ring: Pulsing blue concentric rings with fingerprint SVG icon.
   - Instruction: "Place your enrolled finger on the sensor".
   - Heartbeat status: "Device Online · ESP32-01" with pulsing green LED indicator.

2. **SCANNING State**:
   - Glowing laser beam sweeps down across the fingerprint glyph (duration 600ms, ease-in-out).
   - "Reading fingerprint... Keep finger steady".

3. **SUCCESS State (Check In / Check Out)**:
   - Green biometric aura rings expanding outwards.
   - Employee Card slide-in:
     - Avatar with green verified checkmark badge.
     - Full name (24px bold) & Employee Code (`EMP001`).
     - Action Badge: `CHECK-IN: 07:55 AM (On Time)` or `CHECK-OUT: 17:05 PM (8h 10m worked)`.
     - Smooth circular timer progress bar (5s countdown).

4. **FAILURE State**:
   - Red warning ring with shake micro-animation (400ms).
   - "Fingerprint Not Recognized · Please re-center your finger and try again".

5. **ENROLLMENT GUIDANCE State (FR-KIOSK-05)**:
   - Interactive 4-step wizard synchronized with admin enrollment commands:
     - Step 1: "Place finger on sensor"
     - Step 2: "Lift your finger"
     - Step 3: "Place the SAME finger again"
     - Step 4: "Fingerprint enrolled successfully! (Slot #X)"
