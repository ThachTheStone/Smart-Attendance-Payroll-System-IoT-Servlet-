-- ==============================================================================
-- Script 03_demo_attendance.sql
-- Seed demo data for October 2026 attendance and payroll verification (SRS Section 5)
-- ==============================================================================

USE SmartAttendanceDB;
GO

-- 1. Ensure Default Salary Rules (FR-RULE-01..07)
IF NOT EXISTS (SELECT 1 FROM SalaryRule WHERE rule_key = 'standard_hours_per_month')
    INSERT INTO SalaryRule (rule_key, value, description) VALUES ('standard_hours_per_month', 208.0, N'Số giờ làm việc chuẩn mỗi tháng (26 ngày x 8h)');

IF NOT EXISTS (SELECT 1 FROM SalaryRule WHERE rule_key = 'ot_weekday_multiplier')
    INSERT INTO SalaryRule (rule_key, value, description) VALUES ('ot_weekday_multiplier', 1.5, N'Hệ số làm thêm giờ ngày thường (150%)');

IF NOT EXISTS (SELECT 1 FROM SalaryRule WHERE rule_key = 'ot_weekend_multiplier')
    INSERT INTO SalaryRule (rule_key, value, description) VALUES ('ot_weekend_multiplier', 2.0, N'Hệ số làm thêm giờ ngày nghỉ cuối tuần (200%)');

IF NOT EXISTS (SELECT 1 FROM SalaryRule WHERE rule_key = 'ot_holiday_multiplier')
    INSERT INTO SalaryRule (rule_key, value, description) VALUES ('ot_holiday_multiplier', 3.0, N'Hệ số làm thêm giờ ngày nghỉ lễ/Tết (300%)');

IF NOT EXISTS (SELECT 1 FROM SalaryRule WHERE rule_key = 'night_allowance_multiplier')
    INSERT INTO SalaryRule (rule_key, value, description) VALUES ('night_allowance_multiplier', 0.3, N'Phụ cấp làm việc ban đêm 22h-06h (+30%)');

IF NOT EXISTS (SELECT 1 FROM SalaryRule WHERE rule_key = 'night_ot_multiplier')
    INSERT INTO SalaryRule (rule_key, value, description) VALUES ('night_ot_multiplier', 0.2, N'Thưởng thêm làm thêm giờ vào ban đêm (+20%)');

IF NOT EXISTS (SELECT 1 FROM SalaryRule WHERE rule_key = 'grace_period_minutes')
    INSERT INTO SalaryRule (rule_key, value, description) VALUES ('grace_period_minutes', 5.0, N'Thời gian ân hạn đi muộn không bị phạt (phút)');

IF NOT EXISTS (SELECT 1 FROM SalaryRule WHERE rule_key = 'penalty_rate_per_minute')
    INSERT INTO SalaryRule (rule_key, value, description) VALUES ('penalty_rate_per_minute', 1000.0, N'Mức phạt đi muộn mỗi phút sau ân hạn (VNĐ/phút)');

IF NOT EXISTS (SELECT 1 FROM SalaryRule WHERE rule_key = 'min_confidence')
    INSERT INTO SalaryRule (rule_key, value, description) VALUES ('min_confidence', 50.0, N'Ngưỡng độ tin cậy nhận diện vân tay tối thiểu (%)');

-- 2. Ensure Holidays for 2026
IF NOT EXISTS (SELECT 1 FROM Holiday WHERE [date] = '2026-09-02')
    INSERT INTO Holiday ([date], name) VALUES ('2026-09-02', N'Quốc khánh');

IF NOT EXISTS (SELECT 1 FROM Holiday WHERE [date] = '2026-10-20')
    INSERT INTO Holiday ([date], name) VALUES ('2026-10-20', N'Ngày Phụ nữ Việt Nam');

-- 3. Ensure Shifts exist
IF NOT EXISTS (SELECT 1 FROM Shift WHERE name = N'Ca Sáng')
    INSERT INTO Shift (name, start_time, end_time, break_minutes) VALUES (N'Ca Sáng', '06:00', '14:00', 0);

IF NOT EXISTS (SELECT 1 FROM Shift WHERE name = N'Ca Hành Chính')
    INSERT INTO Shift (name, start_time, end_time, break_minutes) VALUES (N'Ca Hành Chính', '08:00', '17:00', 60);

IF NOT EXISTS (SELECT 1 FROM Shift WHERE name = N'Ca Đêm')
    INSERT INTO Shift (name, start_time, end_time, break_minutes) VALUES (N'Ca Đêm', '22:00', '06:00', 0);

-- Clear existing demo attendance for October 2026 to ensure clean run
DELETE FROM Attendance WHERE MONTH(work_date) = 10 AND YEAR(work_date) = 2026;

DECLARE @EmpTuanId INT = (SELECT id FROM Employee WHERE code = 'NV003');
DECLARE @ShiftAdminId INT = (SELECT TOP 1 id FROM Shift WHERE name = N'Ca Hành Chính');
IF @ShiftAdminId IS NULL SET @ShiftAdminId = 1;

-- Seed attendance for Lê Minh Tuấn (NV003) to reproduce SRS worked example (8,676,000 VND):
-- - 25 days x 8h = 200 regular hours
-- - 10 hours overtime (weekday)
-- - 8 hours night work
-- - 20 minutes late penalty beyond grace

-- Day 1 to 20: 20 normal 8-hour days (8:00 - 17:00 with 1h break)
DECLARE @d INT = 1;
WHILE @d <= 20
BEGIN
    DECLARE @wDate DATE = DATEFROMPARTS(2026, 10, @d);
    -- Skip weekends
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

-- Day 21: 1 day with 20 minutes late beyond 5 min grace (Check-in 08:25, Check-out 17:25) -> 480 mins worked, LATE
INSERT INTO Attendance (employee_id, work_date, shift_id, check_in, check_out, worked_minutes, status)
VALUES (@EmpTuanId, '2026-10-21', @ShiftAdminId, 
        '2026-10-21 08:25:00', '2026-10-21 17:25:00', 480, 'LATE');

-- Day 22 & 23: 2 normal days (8h each)
INSERT INTO Attendance (employee_id, work_date, shift_id, check_in, check_out, worked_minutes, status)
VALUES (@EmpTuanId, '2026-10-22', @ShiftAdminId, '2026-10-22 08:00:00', '2026-10-22 17:00:00', 480, 'ON_TIME'),
       (@EmpTuanId, '2026-10-23', @ShiftAdminId, '2026-10-23 08:00:00', '2026-10-23 17:00:00', 480, 'ON_TIME');

-- Day 26 & 27: 2 days with 5 hours of weekday overtime each (8:00 - 22:00, 13 hours total = 8h reg + 5h OT)
-- Total OT = 10h weekday overtime!
INSERT INTO Attendance (employee_id, work_date, shift_id, check_in, check_out, worked_minutes, status)
VALUES (@EmpTuanId, '2026-10-26', @ShiftAdminId, '2026-10-26 08:00:00', '2026-10-26 22:00:00', 780, 'OVERTIME'),
       (@EmpTuanId, '2026-10-27', @ShiftAdminId, '2026-10-27 08:00:00', '2026-10-27 22:00:00', 780, 'OVERTIME');

-- Day 28: 1 night shift (22:00 - 06:00 = 8 night hours)
DECLARE @ShiftNightId INT = (SELECT TOP 1 id FROM Shift WHERE name = N'Ca Đêm');
IF @ShiftNightId IS NULL SET @ShiftNightId = 3;

INSERT INTO Attendance (employee_id, work_date, shift_id, check_in, check_out, worked_minutes, status)
VALUES (@EmpTuanId, '2026-10-28', @ShiftNightId, '2026-10-28 22:00:00', '2026-10-29 06:00:00', 480, 'ON_TIME');

PRINT N'Seeded demo attendance for October 2026 successfully. NV003 has exactly the SRS worked example data.';
GO
