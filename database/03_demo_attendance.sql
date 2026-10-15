/* ==============================================================================
   Smart Attendance & Payroll System - DEMO ATTENDANCE & PAYROLL (SQL Server)
   Execute this script AFTER running 01_schema.sql and 02_seed.sql
   Purpose: Generate attendance records and calculate payroll for October 2026 for
            Le Minh Tuan (NV003) matching 100% with the SRS Section 5 formula benchmark
            (Net Salary: 8,676,000 VND).
   ============================================================================== */

USE SmartAttendanceDB;
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
SET DATEFIRST 7; -- Sunday = 1, Saturday = 7 (Consistent behavior across SQL Server instances)
GO

PRINT 'Initializing demo attendance records & payroll for October 2026...';

/* ---------- 1. ENSURE WORK SHIFTS EXIST ---------- */
IF NOT EXISTS (SELECT 1 FROM Shift WHERE name = 'Morning Shift')
    INSERT INTO Shift (name, start_time, end_time, break_minutes) VALUES ('Morning Shift', '06:00', '14:00', 0);

IF NOT EXISTS (SELECT 1 FROM Shift WHERE name = 'Office Shift')
    INSERT INTO Shift (name, start_time, end_time, break_minutes) VALUES ('Office Shift', '08:00', '17:00', 60);

IF NOT EXISTS (SELECT 1 FROM Shift WHERE name = 'Evening Shift')
    INSERT INTO Shift (name, start_time, end_time, break_minutes) VALUES ('Evening Shift', '14:00', '22:00', 0);

IF NOT EXISTS (SELECT 1 FROM Shift WHERE name = 'Night Shift')
    INSERT INTO Shift (name, start_time, end_time, break_minutes) VALUES ('Night Shift', '22:00', '06:00', 0);

/* ---------- 2. CLEAN UP OLD OCT 2026 DEMO DATA (FOR SAFE IDEMPOTENT RUNS) ---------- */
DELETE FROM PayrollDetail WHERE payroll_id IN (SELECT id FROM Payroll WHERE month = 10 AND year = 2026);
DELETE FROM Payroll WHERE month = 10 AND year = 2026;
DELETE FROM Attendance WHERE MONTH(work_date) = 10 AND YEAR(work_date) = 2026;
DELETE FROM ShiftAssignment WHERE MONTH(work_date) = 10 AND YEAR(work_date) = 2026;

DECLARE @EmpTuanId INT = (SELECT id FROM Employee WHERE code = 'NV003');
DECLARE @ShiftAdminId INT = (SELECT TOP 1 id FROM Shift WHERE name = 'Office Shift');
DECLARE @ShiftNightId INT = (SELECT TOP 1 id FROM Shift WHERE name = 'Night Shift');
DECLARE @DeviceId INT = (SELECT TOP 1 id FROM Device WHERE api_key = 'DEVICE_SECRET_KEY_2026');

IF @ShiftAdminId IS NULL SET @ShiftAdminId = 2;
IF @ShiftNightId IS NULL SET @ShiftNightId = 4;
IF @DeviceId IS NULL SET @DeviceId = 1;

/* ---------- 3. SHIFT SCHEDULE ASSIGNMENTS FOR NV003 (OCT 2026) ---------- */
-- Assign Office Shift for weekdays from Oct 1 to Oct 27 (excluding Sat & Sun)
DECLARE @curDay INT = 1;
WHILE @curDay <= 27
BEGIN
    DECLARE @curDate DATE = DATEFROMPARTS(2026, 10, @curDay);
    IF DATEPART(dw, @curDate) NOT IN (1, 7)
    BEGIN
        INSERT INTO ShiftAssignment (employee_id, shift_id, work_date)
        VALUES (@EmpTuanId, @ShiftAdminId, @curDate);
    END
    SET @curDay = @curDay + 1;
END

-- Oct 28: Assign Night Shift to NV003
INSERT INTO ShiftAssignment (employee_id, shift_id, work_date)
VALUES (@EmpTuanId, @ShiftNightId, '2026-10-28');

/* ---------- 4. GENERATE ATTENDANCE LOGS FOR NV003 ----------
   Hours breakdown according to SRS:
   - 25 days x 8h = 200 standard regular hours
   - 10 weekday overtime hours (150%)
   - 8 night shift hours (22h - 06h)
   - 20 minutes late beyond 5-minute grace period -> 20,000 VND penalty
----------------------------------------------------------------------- */

-- Oct 1 to 20: 20 regular working days (08:00 - 17:00, 1h lunch break -> 480 worked mins)
DECLARE @d INT = 1;
WHILE @d <= 20
BEGIN
    DECLARE @wDate DATE = DATEFROMPARTS(2026, 10, @d);
    IF DATEPART(dw, @wDate) NOT IN (1, 7)
    BEGIN
        INSERT INTO Attendance (employee_id, work_date, shift_id, check_in, check_out, worked_minutes, status)
        VALUES (@EmpTuanId, @wDate, @ShiftAdminId, 
                DATETIMEFROMPARTS(2026, 10, @d, 8, 0, 0, 0), 
                DATETIMEFROMPARTS(2026, 10, @d, 17, 0, 0, 0), 
                480, 'ON_TIME');
    END
    SET @d = @d + 1;
END

-- Oct 21: 1 day arriving late by 25 mins (20 mins beyond 5m grace period: 08:25 - 17:25) -> 480 mins worked, LATE
INSERT INTO Attendance (employee_id, work_date, shift_id, check_in, check_out, worked_minutes, status)
VALUES (@EmpTuanId, '2026-10-21', @ShiftAdminId, 
        '2026-10-21 08:25:00', '2026-10-21 17:25:00', 480, 'LATE');

-- Oct 22 & 23: 2 regular days (08:00 - 17:00)
INSERT INTO Attendance (employee_id, work_date, shift_id, check_in, check_out, worked_minutes, status)
VALUES (@EmpTuanId, '2026-10-22', @ShiftAdminId, '2026-10-22 08:00:00', '2026-10-22 17:00:00', 480, 'ON_TIME'),
       (@EmpTuanId, '2026-10-23', @ShiftAdminId, '2026-10-23 08:00:00', '2026-10-23 17:00:00', 480, 'ON_TIME');

-- Oct 26 & 27: 2 days with 5h overtime each (08:00 - 22:00 -> 13h - 1h break = 12h = 8h regular + 5h OT)
-- Total OT = 10 weekday OT hours!
INSERT INTO Attendance (employee_id, work_date, shift_id, check_in, check_out, worked_minutes, status)
VALUES (@EmpTuanId, '2026-10-26', @ShiftAdminId, '2026-10-26 08:00:00', '2026-10-26 22:00:00', 780, 'OVERTIME'),
       (@EmpTuanId, '2026-10-27', @ShiftAdminId, '2026-10-27 08:00:00', '2026-10-27 22:00:00', 780, 'OVERTIME');

-- Oct 28: 1 night shift (22:00 Oct 28 to 06:00 Oct 29 = 8 night hours)
INSERT INTO Attendance (employee_id, work_date, shift_id, check_in, check_out, worked_minutes, status)
VALUES (@EmpTuanId, '2026-10-28', @ShiftNightId, '2026-10-28 22:00:00', '2026-10-29 06:00:00', 480, 'ON_TIME');

/* ---------- 5. BIOMETRIC SCAN LOGS (AttendanceLog) ---------- */
INSERT INTO AttendanceLog (employee_id, device_id, event_time, confidence_score, result, reason) VALUES
(@EmpTuanId, @DeviceId, '2026-10-28 21:55:12', 92, 'CHECK_IN',  'Check-in successful: On Time (Night Shift)'),
(@EmpTuanId, @DeviceId, '2026-10-29 06:05:08', 95, 'CHECK_OUT', 'Check-out successful (On Time, 8h0m)'),
(NULL,       @DeviceId, DATEADD(minute, -15, SYSDATETIME()), 35, 'NOT_RECOGNIZED', 'Low recognition confidence: 35 < 50');

/* ---------- 6. DEMO PAYROLL FOR OCT 2026 (Payroll & PayrollDetail) ----------
   NV003 Base Salary: 8,320,000 VND / 208h = 40,000 VND/h
   - Regular pay: 200h x 40,000       = 8,000,000 VND
   - Overtime:    10h x 40,000 x 1.5   =   600,000 VND
   - Night shift:  8h x 40,000 x 0.3   =    96,000 VND
   - Late penalty: 20m x 1,000         =   -20,000 VND
   -> Total Net Salary:                = 8,676,000 VND (Matches SRS Section 5)
------------------------------------------------------------------------------------- */
INSERT INTO Payroll (month, year, status) VALUES (10, 2026, 'DRAFT');
DECLARE @PayrollId INT = SCOPE_IDENTITY();

INSERT INTO PayrollDetail (
    payroll_id, employee_id, regular_hours, ot_weekday_hours, ot_weekend_hours, 
    ot_holiday_hours, night_hours, night_ot_hours, late_minutes, penalty, net_salary, email_status
) VALUES (
    @PayrollId, @EmpTuanId, 200.00, 10.00, 0.00,
    0.00, 8.00, 0.00, 20, 20000.00, 8676000.00, NULL
);

DECLARE @cAtt INT = (SELECT COUNT(*) FROM Attendance WHERE MONTH(work_date) = 10 AND YEAR(work_date) = 2026);
DECLARE @netSal DECIMAL(15,2) = (SELECT net_salary FROM PayrollDetail WHERE payroll_id = @PayrollId AND employee_id = @EmpTuanId);

PRINT '==> [03_demo_attendance.sql] Demo attendance & payroll for Oct 2026 generated successfully!';
PRINT '    - Attendance records: ' + CAST(@cAtt AS VARCHAR);
PRINT '    - NV003 Net Salary:   ' + CAST(@netSal AS VARCHAR) + ' VND';
GO
