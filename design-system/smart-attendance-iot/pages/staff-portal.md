# Page Override Specification: Staff Self-Service Portal (`/staff/today`, `/staff/schedule`, `/staff/payslips`)
*Parent Design System: `../MASTER.md`*

## 1. Role & Intent
The daily workspace for general employees. Staff can review their live daily attendance, check upcoming shift schedules for current and next week, and download verified monthly PDF payslips.

## 2. Key Components
1. **Live Work Hours Ticker**:
   - High-contrast digital clock counting hours, minutes, and seconds worked in real time since check-in.
   - Status badge indicating on-track status or overtime status.
2. **Shift Timeline Stepper**:
   - 4-step responsive visual stepper:
     - Step 1: Shift Start (Scheduled)
     - Step 2: Biometric Check-In (Recorded timestamp)
     - Step 3: Break Time Window
     - Step 4: Biometric Check-Out
3. **Personal Payslip History**:
   - Grid cards of past locked months.
   - Instant "Download PDF Payslip" button with file size and issuance timestamp.
