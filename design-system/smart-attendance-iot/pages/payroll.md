# Page Override Specification: Payroll & Salary Rules Engine (`/admin/payroll`)
*Parent Design System: `../MASTER.md`*

## 1. Role & Intent
The financial engine of the application. Calculates compliant payroll under the Vietnamese Labor Code (BLLĐ 2019), enforcing configurable overtime multipliers, night work premiums, unworked minutes penalties, and PDF payslip issuance.

## 2. Visual Hierarchy & Financial Design Rules
1. **Period Lifecycle Banner**:
   - `DRAFT`: Amber badge with "Editable. Rules recalculation active." Action: `Lock Payroll Period`.
   - `LOCKED`: Emerald badge with "Period Closed. Locked on [Date] by [Admin]". Actions: `Export All PDFs`, `Send Email Payslips`.
2. **Missing Check-out Blocker (FR-PAY-03)**:
   - System strictly prohibits payroll generation if unresolved missing check-outs exist.
   - Distinct red banner lists employee names with one-click "Resolve Attendance" links.
3. **Vietnamese Labor Code Overtime Table (FR-RULE)**:
   - Base pay display in `JetBrains Mono` tabular currency format (`15,000,000 ₫`).
   - Hourly breakdown table with color-coded tags:
     - Normal OT: `x1.5`
     - Weekend OT: `x2.0`
     - Holiday OT: `x3.0`
     - Night Shift Premium: `+30%`
   - Net Salary Summary with clear addition and deduction breakdown cards.
