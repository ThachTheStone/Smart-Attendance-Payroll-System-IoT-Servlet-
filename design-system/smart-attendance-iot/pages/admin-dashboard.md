# Page Override Specification: Admin Live Operations Dashboard (`/admin/dashboard`)
*Parent Design System: `../MASTER.md`*

## 1. Role & Intent
The central command center for HR and Operations Managers. Provides live attendance telemetry, device status monitoring, and immediate exception handling (such as missing check-outs or biometric sensor full capacity warnings).

## 2. Layout Structure (Bento Grid)
1. **Header HUD**:
   - Page title with live time indicator and active shift badge (e.g. `Morning Shift: 06:00 - 14:00`).
   - Quick Action buttons: `+ Add User`, `Generate Payroll`, `Open Simulator`.
2. **Top 5 KPI Metrics**:
   - `Present Today`: Ratio of present employees vs scheduled (e.g. `42 / 48`, +3.2% vs yesterday).
   - `On Time`: Green metric with punctuality percentage (`95.2%`).
   - `Late Arrivals`: Amber metric showing workers arriving past grace period.
   - `Missing Check-outs`: Red alert badge highlighting unclosed shifts (> 2h after shift end).
   - `IoT Hardware Status`: ESP32 connection heartbeat + AS608 memory meter (`84 / 162 slots used`).
3. **Live SSE Event Stream**:
   - Infinite feed of incoming scan events from `/admin/stream`.
   - Each row displays: Time badge, Employee Avatar, Full Name, Department, Event Type (`CHECK_IN` / `CHECK_OUT`), Confidence score (`Score: 89`), and Device Name.
4. **Shift Schedule Today Timeline**:
   - Visual distribution of workers across Morning, Afternoon, and Night shifts.
