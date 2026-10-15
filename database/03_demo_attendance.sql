/* ==============================================================================
   Smart Attendance & Payroll System - DEMO ATTENDANCE & PAYROLL (SQL Server)
   Chay file nay SAU KHI chay 01_schema.sql va 02_seed.sql
   Muc dich: Tao du lieu cham cong va tinh luong thang 10/2026 cho Le Minh Tuan (NV003)
             khop 100% voi vi du tinh toan trong dac ta SRS (Muc 5, Luong Net: 8.676.000 VND).
   ============================================================================== */

USE SmartAttendanceDB;
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
SET DATEFIRST 7; -- Chu nhat = 1, Thu bay = 7 (Dam bao nhat quan tren moi may chu SQL Server)
GO

PRINT N'Dang khoi tao du lieu cham cong & bang luong demo thang 10/2026...';

/* ---------- 1. DAM BAO CAC CA LAM VIEC TON TAI ---------- */
IF NOT EXISTS (SELECT 1 FROM Shift WHERE name = N'Ca Sáng')
    INSERT INTO Shift (name, start_time, end_time, break_minutes) VALUES (N'Ca Sáng', '06:00', '14:00', 0);

IF NOT EXISTS (SELECT 1 FROM Shift WHERE name = N'Ca Hành Chính')
    INSERT INTO Shift (name, start_time, end_time, break_minutes) VALUES (N'Ca Hành Chính', '08:00', '17:00', 60);

IF NOT EXISTS (SELECT 1 FROM Shift WHERE name = N'Ca Chiều')
    INSERT INTO Shift (name, start_time, end_time, break_minutes) VALUES (N'Ca Chiều', '14:00', '22:00', 0);

IF NOT EXISTS (SELECT 1 FROM Shift WHERE name = N'Ca Đêm')
    INSERT INTO Shift (name, start_time, end_time, break_minutes) VALUES (N'Ca Đêm', '22:00', '06:00', 0);

/* ---------- 2. XOA DU LIEU DEMO CU CUA THANG 10/2026 (DE CHAY LAI AN TOAN) ---------- */
DELETE FROM PayrollDetail WHERE payroll_id IN (SELECT id FROM Payroll WHERE month = 10 AND year = 2026);
DELETE FROM Payroll WHERE month = 10 AND year = 2026;
DELETE FROM Attendance WHERE MONTH(work_date) = 10 AND YEAR(work_date) = 2026;
DELETE FROM ShiftAssignment WHERE MONTH(work_date) = 10 AND YEAR(work_date) = 2026;

DECLARE @EmpTuanId INT = (SELECT id FROM Employee WHERE code = 'NV003');
DECLARE @ShiftAdminId INT = (SELECT TOP 1 id FROM Shift WHERE name = N'Ca Hành Chính');
DECLARE @ShiftNightId INT = (SELECT TOP 1 id FROM Shift WHERE name = N'Ca Đêm');
DECLARE @DeviceId INT = (SELECT TOP 1 id FROM Device WHERE api_key = 'DEVICE_SECRET_KEY_2026');

IF @ShiftAdminId IS NULL SET @ShiftAdminId = 1;
IF @ShiftNightId IS NULL SET @ShiftNightId = 4;
IF @DeviceId IS NULL SET @DeviceId = 1;

/* ---------- 3. TAO LICH PHAN CA (ShiftAssignment) CHO NV003 THANG 10/2026 ---------- */
-- Phan ca Hanh Chinh cho cac ngay lam viec tu 1 den 27/10 (tru T7, CN)
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

-- Ngay 28/10: Phan Ca Dem cho NV003
INSERT INTO ShiftAssignment (employee_id, shift_id, work_date)
VALUES (@EmpTuanId, @ShiftNightId, '2026-10-28');

/* ---------- 4. TAO DU LIEU CHAM CONG (Attendance) CHO NV003 ----------
   Tong hop gio theo SRS:
   - 25 ngay x 8h = 200 gio thuong (regular hours)
   - 10 gio lam them ngay thuong (weekday OT)
   - 8 gio lam ca dem (night hours)
   - 20 phut di muon ngoai an han (5 phut) -> Phat 20.000 VND
----------------------------------------------------------------------- */

-- Ngay 1 den 20: 20 ngay lam binh thuong (8:00 - 17:00, nghi trua 1h -> 480 phut lam)
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

-- Ngay 21: 1 ngay di muon 20 phut vuot qua an han 5 phut (Vao 08:25, Ra 17:25) -> 480 phut lam, LATE
INSERT INTO Attendance (employee_id, work_date, shift_id, check_in, check_out, worked_minutes, status)
VALUES (@EmpTuanId, '2026-10-21', @ShiftAdminId, 
        '2026-10-21 08:25:00', '2026-10-21 17:25:00', 480, 'LATE');

-- Ngay 22 & 23: 2 ngay binh thuong (8:00 - 17:00)
INSERT INTO Attendance (employee_id, work_date, shift_id, check_in, check_out, worked_minutes, status)
VALUES (@EmpTuanId, '2026-10-22', @ShiftAdminId, '2026-10-22 08:00:00', '2026-10-22 17:00:00', 480, 'ON_TIME'),
       (@EmpTuanId, '2026-10-23', @ShiftAdminId, '2026-10-23 08:00:00', '2026-10-23 17:00:00', 480, 'ON_TIME');

-- Ngay 26 & 27: 2 ngay tang ca 5 gio moi ngay (08:00 - 22:00 -> 13h - 1h nghi = 12h = 8h thuong + 5h tang ca)
-- Tong OT = 10h ngay thuong!
INSERT INTO Attendance (employee_id, work_date, shift_id, check_in, check_out, worked_minutes, status)
VALUES (@EmpTuanId, '2026-10-26', @ShiftAdminId, '2026-10-26 08:00:00', '2026-10-26 22:00:00', 780, 'OVERTIME'),
       (@EmpTuanId, '2026-10-27', @ShiftAdminId, '2026-10-27 08:00:00', '2026-10-27 22:00:00', 780, 'OVERTIME');

-- Ngay 28: 1 ca dem (22:00 ngay 28 den 06:00 sang ngay 29 = 8 gio dem)
INSERT INTO Attendance (employee_id, work_date, shift_id, check_in, check_out, worked_minutes, status)
VALUES (@EmpTuanId, '2026-10-28', @ShiftNightId, '2026-10-28 22:00:00', '2026-10-29 06:00:00', 480, 'ON_TIME');

/* ---------- 5. LOG QUET VAN TAY DEMO (AttendanceLog) ---------- */
INSERT INTO AttendanceLog (employee_id, device_id, event_time, confidence_score, result, reason) VALUES
(@EmpTuanId, @DeviceId, '2026-10-28 21:55:12', 92, 'CHECK_IN',  N'Check-in thành công: Đúng giờ (Ca Đêm)'),
(@EmpTuanId, @DeviceId, '2026-10-29 06:05:08', 95, 'CHECK_OUT', N'Check-out thành công (Đúng giờ, 8h0m)'),
(NULL,       @DeviceId, DATEADD(minute, -15, SYSDATETIME()), 35, 'NOT_RECOGNIZED', N'Độ tin cậy nhận diện thấp: 35 < 50');

/* ---------- 6. TAO BANG LUONG MAU THANG 10/2026 (Payroll & PayrollDetail) ----------
   Luong co ban NV003: 8.320.000 VND / 208h = 40.000 VND/h
   - Luong gio thuong: 200h x 40.000       = 8.000.000 VND
   - Luong tang ca:   10h x 40.000 x 1.5   =   600.000 VND
   - Phu cap dem:      8h x 40.000 x 0.3   =    96.000 VND
   - Phat di muon:    20m x 1.000          =   -20.000 VND
   -> Luong thuc nhan (Net):               = 8.676.000 VND (Dung SRS muc 5)
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

PRINT N'==> [03_demo_attendance.sql] Da tao thanh cong du lieu cham cong & bang luong demo thang 10/2026!';
PRINT N'    - Ban ghi cham cong: ' + CAST(@cAtt AS VARCHAR);
PRINT N'    - Bang luong NV003:  ' + CAST(@netSal AS VARCHAR) + N' VND';
GO
