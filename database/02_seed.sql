/* =====================================================================
   Smart Attendance & Payroll System - SEED DATA (SQL Server)
   Execute this script AFTER running 01_schema.sql
   ===================================================================== */
USE SmartAttendanceDB;
GO
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

PRINT 'Populating seed data into SmartAttendanceDB...';

/* ---------- 1. SALARY RULES (SalaryRule) ---------- */
IF NOT EXISTS (SELECT 1 FROM SalaryRule WHERE rule_key = 'standard_hours_per_month')
    INSERT INTO SalaryRule (rule_key, value, description) VALUES ('standard_hours_per_month', 208.0, 'Standard working hours per month (26 days x 8h)');

IF NOT EXISTS (SELECT 1 FROM SalaryRule WHERE rule_key = 'ot_weekday_multiplier')
    INSERT INTO SalaryRule (rule_key, value, description) VALUES ('ot_weekday_multiplier', 1.5, 'Weekday overtime multiplier (150%)');

IF NOT EXISTS (SELECT 1 FROM SalaryRule WHERE rule_key = 'ot_weekend_multiplier')
    INSERT INTO SalaryRule (rule_key, value, description) VALUES ('ot_weekend_multiplier', 2.0, 'Weekend overtime multiplier (200%)');

IF NOT EXISTS (SELECT 1 FROM SalaryRule WHERE rule_key = 'ot_holiday_multiplier')
    INSERT INTO SalaryRule (rule_key, value, description) VALUES ('ot_holiday_multiplier', 3.0, 'Public holiday overtime multiplier (300%)');

IF NOT EXISTS (SELECT 1 FROM SalaryRule WHERE rule_key = 'night_allowance_multiplier')
    INSERT INTO SalaryRule (rule_key, value, description) VALUES ('night_allowance_multiplier', 0.3, 'Night shift allowance 22:00 - 06:00 (+30%)');

IF NOT EXISTS (SELECT 1 FROM SalaryRule WHERE rule_key = 'night_ot_multiplier')
    INSERT INTO SalaryRule (rule_key, value, description) VALUES ('night_ot_multiplier', 0.2, 'Night overtime bonus multiplier (+20%)');

IF NOT EXISTS (SELECT 1 FROM SalaryRule WHERE rule_key = 'grace_period_minutes')
    INSERT INTO SalaryRule (rule_key, value, description) VALUES ('grace_period_minutes', 5.0, 'Grace period for late arrival without penalty (minutes)');

IF NOT EXISTS (SELECT 1 FROM SalaryRule WHERE rule_key = 'penalty_rate_per_minute')
    INSERT INTO SalaryRule (rule_key, value, description) VALUES ('penalty_rate_per_minute', 1000.0, 'Penalty rate per minute after grace period (VND/min)');

IF NOT EXISTS (SELECT 1 FROM SalaryRule WHERE rule_key = 'min_confidence')
    INSERT INTO SalaryRule (rule_key, value, description) VALUES ('min_confidence', 50.0, 'Minimum fingerprint recognition confidence threshold (%)');

/* ---------- 2. HOLIDAYS (Holiday: 2026) ---------- */
INSERT INTO Holiday (date, name)
SELECT '2026-01-01', 'New Year''s Day' WHERE NOT EXISTS (SELECT 1 FROM Holiday WHERE date = '2026-01-01') UNION ALL
SELECT '2026-02-16', 'Lunar New Year Eve' WHERE NOT EXISTS (SELECT 1 FROM Holiday WHERE date = '2026-02-16') UNION ALL
SELECT '2026-02-17', 'Lunar New Year (Day 1)' WHERE NOT EXISTS (SELECT 1 FROM Holiday WHERE date = '2026-02-17') UNION ALL
SELECT '2026-02-18', 'Lunar New Year (Day 2)' WHERE NOT EXISTS (SELECT 1 FROM Holiday WHERE date = '2026-02-18') UNION ALL
SELECT '2026-02-19', 'Lunar New Year (Day 3)' WHERE NOT EXISTS (SELECT 1 FROM Holiday WHERE date = '2026-02-19') UNION ALL
SELECT '2026-02-20', 'Lunar New Year (Day 4)' WHERE NOT EXISTS (SELECT 1 FROM Holiday WHERE date = '2026-02-20') UNION ALL
SELECT '2026-04-26', 'Hung Kings Commemoration Day' WHERE NOT EXISTS (SELECT 1 FROM Holiday WHERE date = '2026-04-26') UNION ALL
SELECT '2026-04-30', 'Reunification Day' WHERE NOT EXISTS (SELECT 1 FROM Holiday WHERE date = '2026-04-30') UNION ALL
SELECT '2026-05-01', 'International Labor Day' WHERE NOT EXISTS (SELECT 1 FROM Holiday WHERE date = '2026-05-01') UNION ALL
SELECT '2026-09-02', 'National Day' WHERE NOT EXISTS (SELECT 1 FROM Holiday WHERE date = '2026-09-02') UNION ALL
SELECT '2026-10-20', 'Vietnamese Women''s Day' WHERE NOT EXISTS (SELECT 1 FROM Holiday WHERE date = '2026-10-20');

/* ---------- 3. WORK SHIFTS (Shift) ---------- */
IF NOT EXISTS (SELECT 1 FROM Shift WHERE name = 'Morning Shift')
    INSERT INTO Shift (name, start_time, end_time, break_minutes) VALUES ('Morning Shift', '06:00', '14:00', 0);

IF NOT EXISTS (SELECT 1 FROM Shift WHERE name = 'Office Shift')
    INSERT INTO Shift (name, start_time, end_time, break_minutes) VALUES ('Office Shift', '08:00', '17:00', 60);

IF NOT EXISTS (SELECT 1 FROM Shift WHERE name = 'Evening Shift')
    INSERT INTO Shift (name, start_time, end_time, break_minutes) VALUES ('Evening Shift', '14:00', '22:00', 0);

IF NOT EXISTS (SELECT 1 FROM Shift WHERE name = 'Night Shift')
    INSERT INTO Shift (name, start_time, end_time, break_minutes) VALUES ('Night Shift', '22:00', '06:00', 0);

/* ---------- 4. IOT BIOMETRIC DEVICES (Device) ---------- */
IF NOT EXISTS (SELECT 1 FROM Device WHERE api_key = 'DEVICE_SECRET_KEY_2026')
    INSERT INTO Device (name, location, api_key, last_heartbeat)
    VALUES ('ESP32 Main Gate', 'Floor 1 - Main Entrance', 'DEVICE_SECRET_KEY_2026', SYSDATETIME());

IF NOT EXISTS (SELECT 1 FROM Device WHERE api_key = 'DEV-7f3a9c2e-esp32-main')
    INSERT INTO Device (name, location, api_key, last_heartbeat)
    VALUES ('ESP32 Workshop Gate', 'Workshop Area - Ground Floor', 'DEV-7f3a9c2e-esp32-main', SYSDATETIME());

/* ---------- 5. EMPLOYEES (Employee) ---------- */
IF NOT EXISTS (SELECT 1 FROM Employee WHERE code = 'NV001')
    INSERT INTO Employee (code, full_name, email, phone, department, position, salary_type, base_salary, status) VALUES
    ('NV001', 'Nguyen Van An',    'an.nguyen@sap.vn',   '0901000001', 'Executive Board', 'General Manager',   'MONTHLY', 20000000, 'ACTIVE');

IF NOT EXISTS (SELECT 1 FROM Employee WHERE code = 'NV002')
    INSERT INTO Employee (code, full_name, email, phone, department, position, salary_type, base_salary, status) VALUES
    ('NV002', 'Tran Thi Lan',     'lan.tran@sap.vn',    '0901000002', 'Human Resources', 'HR Manager',       'MONTHLY', 15000000, 'ACTIVE');

IF NOT EXISTS (SELECT 1 FROM Employee WHERE code = 'NV003')
    INSERT INTO Employee (code, full_name, email, phone, department, position, salary_type, base_salary, status) VALUES
    ('NV003', 'Le Minh Tuan',     'tuan.le@sap.vn',     '0901000003', 'Production',      'Factory Worker',   'MONTHLY',  8320000, 'ACTIVE');

IF NOT EXISTS (SELECT 1 FROM Employee WHERE code = 'NV004')
    INSERT INTO Employee (code, full_name, email, phone, department, position, salary_type, base_salary, status) VALUES
    ('NV004', 'Pham Thi Hoa',     'hoa.pham@sap.vn',    '0901000004', 'Production',      'Factory Worker',   'MONTHLY',  8320000, 'ACTIVE');

IF NOT EXISTS (SELECT 1 FROM Employee WHERE code = 'NV005')
    INSERT INTO Employee (code, full_name, email, phone, department, position, salary_type, base_salary, status) VALUES
    ('NV005', 'Hoang Duc Minh',   'minh.hoang@sap.vn',  '0901000005', 'Production',      'Team Leader',      'MONTHLY', 10400000, 'ACTIVE');

IF NOT EXISTS (SELECT 1 FROM Employee WHERE code = 'NV006')
    INSERT INTO Employee (code, full_name, email, phone, department, position, salary_type, base_salary, status) VALUES
    ('NV006', 'Vo Thi Mai',       'mai.vo@sap.vn',      '0901000006', 'Warehouse',       'Head Warehouseman','MONTHLY',  9000000, 'ACTIVE');

IF NOT EXISTS (SELECT 1 FROM Employee WHERE code = 'NV007')
    INSERT INTO Employee (code, full_name, email, phone, department, position, salary_type, base_salary, status) VALUES
    ('NV007', 'Dang Quoc Bao',    'bao.dang@sap.vn',    '0901000007', 'Warehouse',       'Warehouse Staff',  'HOURLY',     35000, 'ACTIVE');

IF NOT EXISTS (SELECT 1 FROM Employee WHERE code = 'NV008')
    INSERT INTO Employee (code, full_name, email, phone, department, position, salary_type, base_salary, status) VALUES
    ('NV008', 'Bui Thanh Huong',  'huong.bui@sap.vn',   '0901000008', 'Accounting',      'Accountant',       'MONTHLY', 11000000, 'ACTIVE');

IF NOT EXISTS (SELECT 1 FROM Employee WHERE code = 'NV009')
    INSERT INTO Employee (code, full_name, email, phone, department, position, salary_type, base_salary, status) VALUES
    ('NV009', 'Do Van Hung',      'hung.do@sap.vn',     '0901000009', 'Security',        'Night Guard',      'MONTHLY',  7500000, 'ACTIVE');

IF NOT EXISTS (SELECT 1 FROM Employee WHERE code = 'NV010')
    INSERT INTO Employee (code, full_name, email, phone, department, position, salary_type, base_salary, status) VALUES
    ('NV010', 'Ngo Thi Thu',      'thu.ngo@sap.vn',     '0901000010', 'Production',      'Factory Worker',   'HOURLY',     32000, 'ACTIVE');

IF NOT EXISTS (SELECT 1 FROM Employee WHERE code = 'NV011')
    INSERT INTO Employee (code, full_name, email, phone, department, position, salary_type, base_salary, status) VALUES
    ('NV011', 'Truong Van Khoa',  'khoa.truong@sap.vn', '0901000011', 'Production',      'Factory Worker',   'MONTHLY',  8320000, 'ACTIVE');

IF NOT EXISTS (SELECT 1 FROM Employee WHERE code = 'NV012')
    INSERT INTO Employee (code, full_name, email, phone, department, position, salary_type, base_salary, status) VALUES
    ('NV012', 'Ly Thi Ngoc',      'ngoc.ly@sap.vn',     '0901000012', 'Warehouse',       'Warehouse Staff',  'MONTHLY',  8000000, 'INACTIVE');

/* ---------- 6. LOGIN ACCOUNTS (Account) ----------
   BCrypt hashes:
   - Admin@123  -> $2a$10$puWJwO0BC6Ox2s/S.PoNmOBsBJ0lsc.UZYbMVdj/kUruJlRhBb0ui
   - Staff@123  -> $2a$10$PtdSFIqYeEP.fRrMAX.hf.8jdYnIsoRDnwv22zn8H69U6xyohexCK
   - Kiosk@123  -> $2a$10$tzZNxRcSFfK.r/UWHped5.mXMr3gme3X72/0NiueIXX7NwzLIpzmO
--------------------------------------------------------- */
IF NOT EXISTS (SELECT 1 FROM Account WHERE username = 'admin')
    INSERT INTO Account (employee_id, username, password_hash, role, status)
    SELECT id, 'admin', '$2a$10$puWJwO0BC6Ox2s/S.PoNmOBsBJ0lsc.UZYbMVdj/kUruJlRhBb0ui', 'ADMIN', 'ACTIVE'
    FROM Employee WHERE code = 'NV001';

IF NOT EXISTS (SELECT 1 FROM Account WHERE username = 'hr.lan')
    INSERT INTO Account (employee_id, username, password_hash, role, status)
    SELECT id, 'hr.lan', '$2a$10$puWJwO0BC6Ox2s/S.PoNmOBsBJ0lsc.UZYbMVdj/kUruJlRhBb0ui', 'ADMIN', 'ACTIVE'
    FROM Employee WHERE code = 'NV002';

IF NOT EXISTS (SELECT 1 FROM Account WHERE username = 'tuan.le')
    INSERT INTO Account (employee_id, username, password_hash, role, status)
    SELECT id, 'tuan.le', '$2a$10$PtdSFIqYeEP.fRrMAX.hf.8jdYnIsoRDnwv22zn8H69U6xyohexCK', 'STAFF', 'ACTIVE'
    FROM Employee WHERE code = 'NV003';

IF NOT EXISTS (SELECT 1 FROM Account WHERE username = 'hoa.pham')
    INSERT INTO Account (employee_id, username, password_hash, role, status)
    SELECT id, 'hoa.pham', '$2a$10$PtdSFIqYeEP.fRrMAX.hf.8jdYnIsoRDnwv22zn8H69U6xyohexCK', 'STAFF', 'ACTIVE'
    FROM Employee WHERE code = 'NV004';

IF NOT EXISTS (SELECT 1 FROM Account WHERE username = 'minh.hoang')
    INSERT INTO Account (employee_id, username, password_hash, role, status)
    SELECT id, 'minh.hoang', '$2a$10$PtdSFIqYeEP.fRrMAX.hf.8jdYnIsoRDnwv22zn8H69U6xyohexCK', 'STAFF', 'ACTIVE'
    FROM Employee WHERE code = 'NV005';

IF NOT EXISTS (SELECT 1 FROM Account WHERE username = 'mai.vo')
    INSERT INTO Account (employee_id, username, password_hash, role, status)
    SELECT id, 'mai.vo', '$2a$10$PtdSFIqYeEP.fRrMAX.hf.8jdYnIsoRDnwv22zn8H69U6xyohexCK', 'STAFF', 'ACTIVE'
    FROM Employee WHERE code = 'NV006';

IF NOT EXISTS (SELECT 1 FROM Account WHERE username = 'bao.dang')
    INSERT INTO Account (employee_id, username, password_hash, role, status)
    SELECT id, 'bao.dang', '$2a$10$PtdSFIqYeEP.fRrMAX.hf.8jdYnIsoRDnwv22zn8H69U6xyohexCK', 'STAFF', 'ACTIVE'
    FROM Employee WHERE code = 'NV007';

IF NOT EXISTS (SELECT 1 FROM Account WHERE username = 'huong.bui')
    INSERT INTO Account (employee_id, username, password_hash, role, status)
    SELECT id, 'huong.bui', '$2a$10$PtdSFIqYeEP.fRrMAX.hf.8jdYnIsoRDnwv22zn8H69U6xyohexCK', 'STAFF', 'ACTIVE'
    FROM Employee WHERE code = 'NV008';

IF NOT EXISTS (SELECT 1 FROM Account WHERE username = 'hung.do')
    INSERT INTO Account (employee_id, username, password_hash, role, status)
    SELECT id, 'hung.do', '$2a$10$PtdSFIqYeEP.fRrMAX.hf.8jdYnIsoRDnwv22zn8H69U6xyohexCK', 'STAFF', 'ACTIVE'
    FROM Employee WHERE code = 'NV009';

IF NOT EXISTS (SELECT 1 FROM Account WHERE username = 'thu.ngo')
    INSERT INTO Account (employee_id, username, password_hash, role, status)
    SELECT id, 'thu.ngo', '$2a$10$PtdSFIqYeEP.fRrMAX.hf.8jdYnIsoRDnwv22zn8H69U6xyohexCK', 'STAFF', 'ACTIVE'
    FROM Employee WHERE code = 'NV010';

IF NOT EXISTS (SELECT 1 FROM Account WHERE username = 'khoa.truong')
    INSERT INTO Account (employee_id, username, password_hash, role, status)
    SELECT id, 'khoa.truong', '$2a$10$PtdSFIqYeEP.fRrMAX.hf.8jdYnIsoRDnwv22zn8H69U6xyohexCK', 'STAFF', 'ACTIVE'
    FROM Employee WHERE code = 'NV011';

IF NOT EXISTS (SELECT 1 FROM Account WHERE username = 'ngoc.ly')
    INSERT INTO Account (employee_id, username, password_hash, role, status)
    SELECT id, 'ngoc.ly', '$2a$10$PtdSFIqYeEP.fRrMAX.hf.8jdYnIsoRDnwv22zn8H69U6xyohexCK', 'STAFF', 'INACTIVE'
    FROM Employee WHERE code = 'NV012';

IF NOT EXISTS (SELECT 1 FROM Account WHERE username = 'kiosk01')
    INSERT INTO Account (employee_id, username, password_hash, role, status)
    VALUES (NULL, 'kiosk01', '$2a$10$tzZNxRcSFfK.r/UWHped5.mXMr3gme3X72/0NiueIXX7NwzLIpzmO', 'KIOSK', 'ACTIVE');

/* ---------- 7. BIOMETRIC FINGERPRINT SAMPLES (template 1..5) ---------- */
IF NOT EXISTS (SELECT 1 FROM Fingerprint WHERE template_id = 1)
    INSERT INTO Fingerprint (employee_id, template_id, finger_name)
    SELECT id, 1, 'Right index finger' FROM Employee WHERE code = 'NV001';

IF NOT EXISTS (SELECT 1 FROM Fingerprint WHERE template_id = 2)
    INSERT INTO Fingerprint (employee_id, template_id, finger_name)
    SELECT id, 2, 'Right thumb' FROM Employee WHERE code = 'NV002';

IF NOT EXISTS (SELECT 1 FROM Fingerprint WHERE template_id = 3)
    INSERT INTO Fingerprint (employee_id, template_id, finger_name)
    SELECT id, 3, 'Right index finger' FROM Employee WHERE code = 'NV003';

IF NOT EXISTS (SELECT 1 FROM Fingerprint WHERE template_id = 4)
    INSERT INTO Fingerprint (employee_id, template_id, finger_name)
    SELECT id, 4, 'Right index finger' FROM Employee WHERE code = 'NV004';

IF NOT EXISTS (SELECT 1 FROM Fingerprint WHERE template_id = 5)
    INSERT INTO Fingerprint (employee_id, template_id, finger_name)
    SELECT id, 5, 'Right index finger' FROM Employee WHERE code = 'NV005';

DECLARE @cEmp INT = (SELECT COUNT(*) FROM Employee);
DECLARE @cAcc INT = (SELECT COUNT(*) FROM Account);
DECLARE @cDev INT = (SELECT COUNT(*) FROM Device);
DECLARE @cShift INT = (SELECT COUNT(*) FROM Shift);
DECLARE @cHol INT = (SELECT COUNT(*) FROM Holiday);
DECLARE @cRule INT = (SELECT COUNT(*) FROM SalaryRule);
DECLARE @cFp INT = (SELECT COUNT(*) FROM Fingerprint);

PRINT '==> [02_seed.sql] Seed data loaded successfully!';
PRINT '    - Employees:   ' + CAST(@cEmp AS VARCHAR);
PRINT '    - Accounts:    ' + CAST(@cAcc AS VARCHAR);
PRINT '    - Devices:     ' + CAST(@cDev AS VARCHAR);
PRINT '    - Shifts:      ' + CAST(@cShift AS VARCHAR);
PRINT '    - Holidays:    ' + CAST(@cHol AS VARCHAR);
PRINT '    - Rules:       ' + CAST(@cRule AS VARCHAR);
PRINT '    - Fingerprints:' + CAST(@cFp AS VARCHAR);
GO