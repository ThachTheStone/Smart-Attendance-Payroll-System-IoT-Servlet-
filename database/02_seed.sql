/* =====================================================================
   Smart Attendance & Payroll System - SEED DATA (SQL Server)
   Chay file nay SAU khi da chay 01_schema.sql
   ===================================================================== */
USE SmartAttendanceDB;
GO
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

PRINT N'Dang them du lieu mau vao SmartAttendanceDB...';

/* ---------- 1. CAU HINH QUY TAC TINH LUONG (SalaryRule) ---------- */
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

/* ---------- 2. DANH MUC NGAY NGHI LE NAM 2026 (Holiday) ---------- */
INSERT INTO Holiday (date, name)
SELECT '2026-01-01', N'Tết Dương lịch' WHERE NOT EXISTS (SELECT 1 FROM Holiday WHERE date = '2026-01-01') UNION ALL
SELECT '2026-02-16', N'Tết Nguyên đán (29 Tết)' WHERE NOT EXISTS (SELECT 1 FROM Holiday WHERE date = '2026-02-16') UNION ALL
SELECT '2026-02-17', N'Tết Nguyên đán (Mùng 1)' WHERE NOT EXISTS (SELECT 1 FROM Holiday WHERE date = '2026-02-17') UNION ALL
SELECT '2026-02-18', N'Tết Nguyên đán (Mùng 2)' WHERE NOT EXISTS (SELECT 1 FROM Holiday WHERE date = '2026-02-18') UNION ALL
SELECT '2026-02-19', N'Tết Nguyên đán (Mùng 3)' WHERE NOT EXISTS (SELECT 1 FROM Holiday WHERE date = '2026-02-19') UNION ALL
SELECT '2026-02-20', N'Tết Nguyên đán (Mùng 4)' WHERE NOT EXISTS (SELECT 1 FROM Holiday WHERE date = '2026-02-20') UNION ALL
SELECT '2026-04-26', N'Giỗ Tổ Hùng Vương' WHERE NOT EXISTS (SELECT 1 FROM Holiday WHERE date = '2026-04-26') UNION ALL
SELECT '2026-04-30', N'Ngày Giải phóng miền Nam' WHERE NOT EXISTS (SELECT 1 FROM Holiday WHERE date = '2026-04-30') UNION ALL
SELECT '2026-05-01', N'Quốc tế Lao động' WHERE NOT EXISTS (SELECT 1 FROM Holiday WHERE date = '2026-05-01') UNION ALL
SELECT '2026-09-02', N'Quốc khánh' WHERE NOT EXISTS (SELECT 1 FROM Holiday WHERE date = '2026-09-02') UNION ALL
SELECT '2026-10-20', N'Ngày Phụ nữ Việt Nam' WHERE NOT EXISTS (SELECT 1 FROM Holiday WHERE date = '2026-10-20');

/* ---------- 3. CA LAM VIEC (Shift) ---------- */
IF NOT EXISTS (SELECT 1 FROM Shift WHERE name = N'Ca Sáng')
    INSERT INTO Shift (name, start_time, end_time, break_minutes) VALUES (N'Ca Sáng', '06:00', '14:00', 0);

IF NOT EXISTS (SELECT 1 FROM Shift WHERE name = N'Ca Hành Chính')
    INSERT INTO Shift (name, start_time, end_time, break_minutes) VALUES (N'Ca Hành Chính', '08:00', '17:00', 60);

IF NOT EXISTS (SELECT 1 FROM Shift WHERE name = N'Ca Chiều')
    INSERT INTO Shift (name, start_time, end_time, break_minutes) VALUES (N'Ca Chiều', '14:00', '22:00', 0);

IF NOT EXISTS (SELECT 1 FROM Shift WHERE name = N'Ca Đêm')
    INSERT INTO Shift (name, start_time, end_time, break_minutes) VALUES (N'Ca Đêm', '22:00', '06:00', 0);

/* ---------- 4. THIET BI CHAM CONG IOT (Device) ---------- */
IF NOT EXISTS (SELECT 1 FROM Device WHERE api_key = 'DEVICE_SECRET_KEY_2026')
    INSERT INTO Device (name, location, api_key, last_heartbeat)
    VALUES (N'Cổng chính ESP32', N'Tầng 1 - Cửa ra vào', 'DEVICE_SECRET_KEY_2026', SYSDATETIME());

IF NOT EXISTS (SELECT 1 FROM Device WHERE api_key = 'DEV-7f3a9c2e-esp32-main')
    INSERT INTO Device (name, location, api_key, last_heartbeat)
    VALUES (N'Cổng xưởng sản xuất', N'Khu sản xuất - Tầng trệt', 'DEV-7f3a9c2e-esp32-main', SYSDATETIME());

/* ---------- 5. DANH SACH NHAN VIEN (Employee) ---------- */
IF NOT EXISTS (SELECT 1 FROM Employee WHERE code = 'NV001')
    INSERT INTO Employee (code, full_name, email, phone, department, position, salary_type, base_salary, status) VALUES
    ('NV001', N'Nguyễn Văn An',    'an.nguyen@sap.vn',   '0901000001', N'Ban Giám đốc', N'Quản lý',         'MONTHLY', 20000000, 'ACTIVE');

IF NOT EXISTS (SELECT 1 FROM Employee WHERE code = 'NV002')
    INSERT INTO Employee (code, full_name, email, phone, department, position, salary_type, base_salary, status) VALUES
    ('NV002', N'Trần Thị Lan',     'lan.tran@sap.vn',    '0901000002', N'Nhân sự',     N'Trưởng phòng HR', 'MONTHLY', 15000000, 'ACTIVE');

IF NOT EXISTS (SELECT 1 FROM Employee WHERE code = 'NV003')
    INSERT INTO Employee (code, full_name, email, phone, department, position, salary_type, base_salary, status) VALUES
    ('NV003', N'Lê Minh Tuấn',     'tuan.le@sap.vn',     '0901000003', N'Sản xuất',    N'Công nhân',       'MONTHLY',  8320000, 'ACTIVE');

IF NOT EXISTS (SELECT 1 FROM Employee WHERE code = 'NV004')
    INSERT INTO Employee (code, full_name, email, phone, department, position, salary_type, base_salary, status) VALUES
    ('NV004', N'Phạm Thị Hoa',     'hoa.pham@sap.vn',    '0901000004', N'Sản xuất',    N'Công nhân',       'MONTHLY',  8320000, 'ACTIVE');

IF NOT EXISTS (SELECT 1 FROM Employee WHERE code = 'NV005')
    INSERT INTO Employee (code, full_name, email, phone, department, position, salary_type, base_salary, status) VALUES
    ('NV005', N'Hoàng Đức Minh',   'minh.hoang@sap.vn',  '0901000005', N'Sản xuất',    N'Tổ trưởng',       'MONTHLY', 10400000, 'ACTIVE');

IF NOT EXISTS (SELECT 1 FROM Employee WHERE code = 'NV006')
    INSERT INTO Employee (code, full_name, email, phone, department, position, salary_type, base_salary, status) VALUES
    ('NV006', N'Võ Thị Mai',       'mai.vo@sap.vn',      '0901000006', N'Kho',         N'Thủ kho',         'MONTHLY',  9000000, 'ACTIVE');

IF NOT EXISTS (SELECT 1 FROM Employee WHERE code = 'NV007')
    INSERT INTO Employee (code, full_name, email, phone, department, position, salary_type, base_salary, status) VALUES
    ('NV007', N'Đặng Quốc Bảo',    'bao.dang@sap.vn',    '0901000007', N'Kho',         N'Nhân viên kho',   'HOURLY',     35000, 'ACTIVE');

IF NOT EXISTS (SELECT 1 FROM Employee WHERE code = 'NV008')
    INSERT INTO Employee (code, full_name, email, phone, department, position, salary_type, base_salary, status) VALUES
    ('NV008', N'Bùi Thanh Hương',  'huong.bui@sap.vn',   '0901000008', N'Kế toán',     N'Kế toán viên',    'MONTHLY', 11000000, 'ACTIVE');

IF NOT EXISTS (SELECT 1 FROM Employee WHERE code = 'NV009')
    INSERT INTO Employee (code, full_name, email, phone, department, position, salary_type, base_salary, status) VALUES
    ('NV009', N'Đỗ Văn Hùng',      'hung.do@sap.vn',     '0901000009', N'Bảo vệ',      N'Bảo vệ ca đêm',   'MONTHLY',  7500000, 'ACTIVE');

IF NOT EXISTS (SELECT 1 FROM Employee WHERE code = 'NV010')
    INSERT INTO Employee (code, full_name, email, phone, department, position, salary_type, base_salary, status) VALUES
    ('NV010', N'Ngô Thị Thu',      'thu.ngo@sap.vn',     '0901000010', N'Sản xuất',    N'Công nhân',       'HOURLY',     32000, 'ACTIVE');

IF NOT EXISTS (SELECT 1 FROM Employee WHERE code = 'NV011')
    INSERT INTO Employee (code, full_name, email, phone, department, position, salary_type, base_salary, status) VALUES
    ('NV011', N'Trương Văn Khoa',  'khoa.truong@sap.vn', '0901000011', N'Sản xuất',    N'Công nhân',       'MONTHLY',  8320000, 'ACTIVE');

IF NOT EXISTS (SELECT 1 FROM Employee WHERE code = 'NV012')
    INSERT INTO Employee (code, full_name, email, phone, department, position, salary_type, base_salary, status) VALUES
    ('NV012', N'Lý Thị Ngọc',      'ngoc.ly@sap.vn',     '0901000012', N'Kho',         N'Nhân viên kho',   'MONTHLY',  8000000, 'INACTIVE');

/* ---------- 6. TAI KHOAN DANG NHAP (Account) ----------
   Mat khau da ma hoa BCrypt:
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

/* ---------- 7. MAU VAN TAY DANG KY TRUOC (Fingerprint: template 1..5) ---------- */
IF NOT EXISTS (SELECT 1 FROM Fingerprint WHERE template_id = 1)
    INSERT INTO Fingerprint (employee_id, template_id, finger_name)
    SELECT id, 1, N'Ngón trỏ phải' FROM Employee WHERE code = 'NV001';

IF NOT EXISTS (SELECT 1 FROM Fingerprint WHERE template_id = 2)
    INSERT INTO Fingerprint (employee_id, template_id, finger_name)
    SELECT id, 2, N'Ngón cái phải' FROM Employee WHERE code = 'NV002';

IF NOT EXISTS (SELECT 1 FROM Fingerprint WHERE template_id = 3)
    INSERT INTO Fingerprint (employee_id, template_id, finger_name)
    SELECT id, 3, N'Ngón trỏ phải' FROM Employee WHERE code = 'NV003';

IF NOT EXISTS (SELECT 1 FROM Fingerprint WHERE template_id = 4)
    INSERT INTO Fingerprint (employee_id, template_id, finger_name)
    SELECT id, 4, N'Ngón trỏ phải' FROM Employee WHERE code = 'NV004';

IF NOT EXISTS (SELECT 1 FROM Fingerprint WHERE template_id = 5)
    INSERT INTO Fingerprint (employee_id, template_id, finger_name)
    SELECT id, 5, N'Ngón trỏ phải' FROM Employee WHERE code = 'NV005';

DECLARE @cEmp INT = (SELECT COUNT(*) FROM Employee);
DECLARE @cAcc INT = (SELECT COUNT(*) FROM Account);
DECLARE @cDev INT = (SELECT COUNT(*) FROM Device);
DECLARE @cShift INT = (SELECT COUNT(*) FROM Shift);
DECLARE @cHol INT = (SELECT COUNT(*) FROM Holiday);
DECLARE @cRule INT = (SELECT COUNT(*) FROM SalaryRule);
DECLARE @cFp INT = (SELECT COUNT(*) FROM Fingerprint);

PRINT N'==> [02_seed.sql] Da nap du lieu mau thanh cong!';
PRINT N'    - Employees:   ' + CAST(@cEmp AS VARCHAR);
PRINT N'    - Accounts:    ' + CAST(@cAcc AS VARCHAR);
PRINT N'    - Devices:     ' + CAST(@cDev AS VARCHAR);
PRINT N'    - Shifts:      ' + CAST(@cShift AS VARCHAR);
PRINT N'    - Holidays:    ' + CAST(@cHol AS VARCHAR);
PRINT N'    - Rules:       ' + CAST(@cRule AS VARCHAR);
PRINT N'    - Fingerprints:' + CAST(@cFp AS VARCHAR);
GO