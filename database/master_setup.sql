/* ==============================================================================
   Smart Attendance & Payroll System - MASTER SETUP SCRIPT (SQL Server)
   ==============================================================================
   HUONG DAN DUNG:
   - Mo file nay bang SQL Server Management Studio (SSMS) hoac Azure Data Studio.
   - Nhan [Execute] hoac an phim F5 de chay toan bo.
   - Script nay se:
       1. Xoa CSDL cu (neu da ton tai) va tao lai CSDL SmartAttendanceDB sach.
       2. Tao day du 14 bang (User, Device, Shift, Attendance, Payroll, v.v.).
       3. Nap du lieu goc (12 Nhan vien, 13 Tai khoan, Ca lam viec, Ngay le, Thiet bi, Van tay).
       4. Nap du lieu cham cong & bang luong demo thang 10/2026 theo chuan SRS.
   ============================================================================== */

USE master;
GO

PRINT N'======================================================================';
PRINT N'   KHOI TAO HE THONG SMART ATTENDANCE & PAYROLL SYSTEM (SQL SERVER)   ';
PRINT N'======================================================================';

IF DB_ID('SmartAttendanceDB') IS NOT NULL
BEGIN
    PRINT N'[1/4] Phat hien CSDL cu, dang dong ket noi va xoa CSDL SmartAttendanceDB...';
    ALTER DATABASE SmartAttendanceDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE SmartAttendanceDB;
END
GO

PRINT N'[2/4] Dang tao moi CSDL SmartAttendanceDB...';
CREATE DATABASE SmartAttendanceDB;
GO

USE SmartAttendanceDB;
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
SET DATEFIRST 7; -- Chu nhat = 1, Thu bay = 7
GO

PRINT N'[3/4] Dang tao 14 bang CSDL theo Schema...';

/* ---------- 1. NHAN VIEN (Employee) ---------- */
CREATE TABLE Employee (
    id           INT IDENTITY(1,1) PRIMARY KEY,
    code         VARCHAR(10)    NOT NULL UNIQUE,
    full_name    NVARCHAR(100)  NOT NULL,
    email        VARCHAR(100)   NOT NULL UNIQUE,
    phone        VARCHAR(15)    NOT NULL UNIQUE,
    department   NVARCHAR(50)   NOT NULL,
    position     NVARCHAR(50)   NOT NULL,
    photo        VARCHAR(255)   NULL,
    salary_type  VARCHAR(10)    NOT NULL DEFAULT 'MONTHLY'
                 CHECK (salary_type IN ('MONTHLY','HOURLY')),
    base_salary  DECIMAL(15,2)  NOT NULL CHECK (base_salary > 0),
    status       VARCHAR(10)    NOT NULL DEFAULT 'ACTIVE'
                 CHECK (status IN ('ACTIVE','INACTIVE')),
    created_at   DATETIME2      NOT NULL DEFAULT SYSDATETIME()
);

/* ---------- 2. TAI KHOAN NGUOI DUNG (Account) ---------- */
CREATE TABLE Account (
    id            INT IDENTITY(1,1) PRIMARY KEY,
    employee_id   INT           NULL REFERENCES Employee(id),
    username      VARCHAR(30)   NOT NULL UNIQUE,
    password_hash VARCHAR(100)  NOT NULL,
    role          VARCHAR(10)   NOT NULL CHECK (role IN ('ADMIN','STAFF','KIOSK')),
    status        VARCHAR(10)   NOT NULL DEFAULT 'ACTIVE'
                  CHECK (status IN ('ACTIVE','INACTIVE')),
    last_login    DATETIME2     NULL,
    created_at    DATETIME2     NOT NULL DEFAULT SYSDATETIME()
);
GO

CREATE UNIQUE INDEX UX_Account_Employee ON Account(employee_id) WHERE employee_id IS NOT NULL;
GO

/* ---------- 3. THIET BI IOT (Device) ---------- */
CREATE TABLE Device (
    id             INT IDENTITY(1,1) PRIMARY KEY,
    name           NVARCHAR(50)  NOT NULL,
    location       NVARCHAR(100) NULL,
    api_key        VARCHAR(64)   NOT NULL UNIQUE,
    last_heartbeat DATETIME2     NULL
);

/* ---------- 4. VAN TAY NHAN VIEN (Fingerprint) ---------- */
CREATE TABLE Fingerprint (
    id           INT IDENTITY(1,1) PRIMARY KEY,
    employee_id  INT          NOT NULL REFERENCES Employee(id),
    template_id  INT          NOT NULL UNIQUE, -- vi tri template trong AS608 (1..162)
    finger_name  NVARCHAR(30) NULL,
    enrolled_at  DATETIME2    NOT NULL DEFAULT SYSDATETIME()
);

/* ---------- 5. LENH GUI DEN THIET BI IOT (DeviceCommand) ---------- */
CREATE TABLE DeviceCommand (
    id           INT IDENTITY(1,1) PRIMARY KEY,
    device_id    INT          NOT NULL REFERENCES Device(id),
    type         VARCHAR(10)  NOT NULL CHECK (type IN ('ENROLL','DELETE')),
    template_id  INT          NOT NULL,
    employee_id  INT          NULL REFERENCES Employee(id),
    finger_name  NVARCHAR(30) NULL,
    status       VARCHAR(10)  NOT NULL DEFAULT 'PENDING' CHECK (status IN ('PENDING','DONE','FAILED')),
    created_at   DATETIME2    NOT NULL DEFAULT SYSDATETIME()
);

/* ---------- 6. CA LAM VIEC (Shift) ---------- */
CREATE TABLE Shift (
    id            INT IDENTITY(1,1) PRIMARY KEY,
    name          NVARCHAR(30) NOT NULL UNIQUE,
    start_time    TIME         NOT NULL,
    end_time      TIME         NOT NULL,
    break_minutes INT          NOT NULL DEFAULT 0
);

/* ---------- 7. PHAN CA LAM VIEC (ShiftAssignment) ---------- */
CREATE TABLE ShiftAssignment (
    id          INT IDENTITY(1,1) PRIMARY KEY,
    employee_id INT  NOT NULL REFERENCES Employee(id),
    shift_id    INT  NOT NULL REFERENCES Shift(id),
    work_date   DATE NOT NULL,
    CONSTRAINT UQ_ShiftAssignment UNIQUE (employee_id, shift_id, work_date)
);

/* ---------- 8. LOG QUET VAN TAY THO (AttendanceLog) ---------- */
CREATE TABLE AttendanceLog (
    id               BIGINT IDENTITY(1,1) PRIMARY KEY,
    employee_id      INT          NULL REFERENCES Employee(id),
    device_id        INT          NOT NULL REFERENCES Device(id),
    event_time       DATETIME2    NOT NULL DEFAULT SYSDATETIME(),
    confidence_score INT          NULL,
    result           VARCHAR(20)  NOT NULL,
    reason           NVARCHAR(200) NULL
);

/* ---------- 9. BANG CHAM CONG TONG HOP (Attendance) ---------- */
CREATE TABLE Attendance (
    id             INT IDENTITY(1,1) PRIMARY KEY,
    employee_id    INT         NOT NULL REFERENCES Employee(id),
    work_date      DATE        NOT NULL,
    shift_id       INT         NOT NULL REFERENCES Shift(id),
    check_in       DATETIME2   NULL,
    check_out      DATETIME2   NULL,
    worked_minutes INT         NOT NULL DEFAULT 0,
    status         VARCHAR(20) NOT NULL,
    CONSTRAINT UQ_Attendance UNIQUE (employee_id, work_date, shift_id)
);

/* ---------- 10. QUY TAC TINH LUONG (SalaryRule) ---------- */
CREATE TABLE SalaryRule (
    rule_key    VARCHAR(50)   PRIMARY KEY,
    value       DECIMAL(15,2) NOT NULL,
    description NVARCHAR(200) NULL
);

/* ---------- 11. NGAY NGHI LE (Holiday) ---------- */
CREATE TABLE Holiday (
    date DATE          PRIMARY KEY,
    name NVARCHAR(100) NOT NULL
);

/* ---------- 12. KY TINH LUONG (Payroll) ---------- */
CREATE TABLE Payroll (
    id     INT IDENTITY(1,1) PRIMARY KEY,
    month  INT         NOT NULL CHECK (month BETWEEN 1 AND 12),
    year   INT         NOT NULL,
    status VARCHAR(10) NOT NULL DEFAULT 'DRAFT' CHECK (status IN ('DRAFT','LOCKED')),
    CONSTRAINT UQ_Payroll UNIQUE (month, year)
);

/* ---------- 13. CHI TIET LUONG NHAN VIEN (PayrollDetail) ---------- */
CREATE TABLE PayrollDetail (
    payroll_id       INT           NOT NULL REFERENCES Payroll(id),
    employee_id      INT           NOT NULL REFERENCES Employee(id),
    regular_hours    DECIMAL(6,2)  NOT NULL DEFAULT 0,
    ot_weekday_hours DECIMAL(6,2)  NOT NULL DEFAULT 0,
    ot_weekend_hours DECIMAL(6,2)  NOT NULL DEFAULT 0,
    ot_holiday_hours DECIMAL(6,2)  NOT NULL DEFAULT 0,
    night_hours      DECIMAL(6,2)  NOT NULL DEFAULT 0,
    night_ot_hours   DECIMAL(6,2)  NOT NULL DEFAULT 0,
    late_minutes     INT           NOT NULL DEFAULT 0,
    penalty          DECIMAL(15,2) NOT NULL DEFAULT 0,
    net_salary       DECIMAL(15,2) NOT NULL DEFAULT 0,
    email_status     VARCHAR(10)   NULL,
    PRIMARY KEY (payroll_id, employee_id)
);

/* ---------- 14. NHAT KY THAY DOI HE THONG (AuditLog) ---------- */
CREATE TABLE AuditLog (
    id          BIGINT IDENTITY(1,1) PRIMARY KEY,
    admin_id    INT           NOT NULL REFERENCES Account(id),
    table_name  VARCHAR(50)   NOT NULL,
    record_id   INT           NOT NULL,
    old_value   NVARCHAR(MAX) NULL,
    new_value   NVARCHAR(MAX) NULL,
    reason      NVARCHAR(200) NULL,
    time        DATETIME2     NOT NULL DEFAULT SYSDATETIME()
);
GO

PRINT '[4/4] Loading seed and demo data...';

/* ---------- SEED 1: SALARY RULES ---------- */
INSERT INTO SalaryRule (rule_key, value, description) VALUES 
('standard_hours_per_month', 208.0, 'Standard working hours per month (26 days x 8h)'),
('ot_weekday_multiplier', 1.5, 'Weekday overtime multiplier (150%)'),
('ot_weekend_multiplier', 2.0, 'Weekend overtime multiplier (200%)'),
('ot_holiday_multiplier', 3.0, 'Public holiday overtime multiplier (300%)'),
('night_allowance_multiplier', 0.3, 'Night shift allowance 22:00 - 06:00 (+30%)'),
('night_ot_multiplier', 0.2, 'Night overtime bonus multiplier (+20%)'),
('grace_period_minutes', 5.0, 'Grace period for late arrival without penalty (minutes)'),
('penalty_rate_per_minute', 1000.0, 'Penalty rate per minute after grace period (VND/min)'),
('min_confidence', 50.0, 'Minimum fingerprint recognition confidence threshold (%)');

/* ---------- SEED 2: HOLIDAYS (2026) ---------- */
INSERT INTO Holiday (date, name) VALUES
('2026-01-01', 'New Year''s Day'),
('2026-02-16', 'Lunar New Year Eve'),
('2026-02-17', 'Lunar New Year (Day 1)'),
('2026-02-18', 'Lunar New Year (Day 2)'),
('2026-02-19', 'Lunar New Year (Day 3)'),
('2026-02-20', 'Lunar New Year (Day 4)'),
('2026-04-26', 'Hung Kings Commemoration Day'),
('2026-04-30', 'Reunification Day'),
('2026-05-01', 'International Labor Day'),
('2026-09-02', 'National Day'),
('2026-10-20', 'Vietnamese Women''s Day');

/* ---------- SEED 3: SHIFTS ---------- */
INSERT INTO Shift (name, start_time, end_time, break_minutes) VALUES 
('Morning Shift', '06:00', '14:00', 0),
('Office Shift',  '08:00', '17:00', 60),
('Evening Shift', '14:00', '22:00', 0),
('Night Shift',   '22:00', '06:00', 0);

/* ---------- SEED 4: IOT DEVICES ---------- */
INSERT INTO Device (name, location, api_key, last_heartbeat) VALUES
('ESP32 Main Gate',     'Floor 1 - Main Entrance',      'DEVICE_SECRET_KEY_2026', SYSDATETIME()),
('ESP32 Workshop Gate', 'Workshop Area - Ground Floor', 'DEV-7f3a9c2e-esp32-main', SYSDATETIME()),
('ESP32 USB Scanner',   'Main Gate - USB Port',         'DEV-ESP32-ATTENDANCE-KEY-001', SYSDATETIME());

/* ---------- SEED 5: EMPLOYEES ---------- */
INSERT INTO Employee (code, full_name, email, phone, department, position, salary_type, base_salary, status) VALUES
('NV001', 'Nguyen Van An',    'an.nguyen@sap.vn',   '0901000001', 'Executive Board', 'General Manager',    'MONTHLY', 20000000, 'ACTIVE'),
('NV002', 'Tran Thi Lan',     'lan.tran@sap.vn',    '0901000002', 'Human Resources', 'HR Manager',        'MONTHLY', 15000000, 'ACTIVE'),
('NV003', 'Le Minh Tuan',     'tuan.le@sap.vn',     '0901000003', 'Production',      'Factory Worker',    'MONTHLY',  8320000, 'ACTIVE'),
('NV004', 'Pham Thi Hoa',     'hoa.pham@sap.vn',    '0901000004', 'Production',      'Factory Worker',    'MONTHLY',  8320000, 'ACTIVE'),
('NV005', 'Hoang Duc Minh',   'minh.hoang@sap.vn',  '0901000005', 'Production',      'Team Leader',       'MONTHLY', 10400000, 'ACTIVE'),
('NV006', 'Vo Thi Mai',       'mai.vo@sap.vn',      '0901000006', 'Warehouse',       'Head Warehouseman', 'MONTHLY',  9000000, 'ACTIVE'),
('NV007', 'Dang Quoc Bao',    'bao.dang@sap.vn',    '0901000007', 'Warehouse',       'Warehouse Staff',   'HOURLY',     35000, 'ACTIVE'),
('NV008', 'Bui Thanh Huong',  'huong.bui@sap.vn',   '0901000008', 'Accounting',      'Accountant',        'MONTHLY', 11000000, 'ACTIVE'),
('NV009', 'Do Van Hung',      'hung.do@sap.vn',     '0901000009', 'Security',        'Night Guard',       'MONTHLY',  7500000, 'ACTIVE'),
('NV010', 'Ngo Thi Thu',      'thu.ngo@sap.vn',     '0901000010', 'Production',      'Factory Worker',    'HOURLY',     32000, 'ACTIVE'),
('NV011', 'Truong Van Khoa',  'khoa.truong@sap.vn', '0901000011', 'Production',      'Factory Worker',    'MONTHLY',  8320000, 'ACTIVE'),
('NV012', 'Ly Thi Ngoc',      'ngoc.ly@sap.vn',     '0901000012', 'Warehouse',       'Warehouse Staff',   'MONTHLY',  8000000, 'INACTIVE');

/* ---------- SEED 6: ACCOUNTS ---------- */
INSERT INTO Account (employee_id, username, password_hash, role, status)
SELECT id, 'admin',       '$2a$10$puWJwO0BC6Ox2s/S.PoNmOBsBJ0lsc.UZYbMVdj/kUruJlRhBb0ui', 'ADMIN', 'ACTIVE'   FROM Employee WHERE code='NV001' UNION ALL
SELECT id, 'hr.lan',      '$2a$10$puWJwO0BC6Ox2s/S.PoNmOBsBJ0lsc.UZYbMVdj/kUruJlRhBb0ui', 'ADMIN', 'ACTIVE'   FROM Employee WHERE code='NV002' UNION ALL
SELECT id, 'tuan.le',     '$2a$10$PtdSFIqYeEP.fRrMAX.hf.8jdYnIsoRDnwv22zn8H69U6xyohexCK', 'STAFF', 'ACTIVE'   FROM Employee WHERE code='NV003' UNION ALL
SELECT id, 'hoa.pham',    '$2a$10$PtdSFIqYeEP.fRrMAX.hf.8jdYnIsoRDnwv22zn8H69U6xyohexCK', 'STAFF', 'ACTIVE'   FROM Employee WHERE code='NV004' UNION ALL
SELECT id, 'minh.hoang',  '$2a$10$PtdSFIqYeEP.fRrMAX.hf.8jdYnIsoRDnwv22zn8H69U6xyohexCK', 'STAFF', 'ACTIVE'   FROM Employee WHERE code='NV005' UNION ALL
SELECT id, 'mai.vo',      '$2a$10$PtdSFIqYeEP.fRrMAX.hf.8jdYnIsoRDnwv22zn8H69U6xyohexCK', 'STAFF', 'ACTIVE'   FROM Employee WHERE code='NV006' UNION ALL
SELECT id, 'bao.dang',    '$2a$10$PtdSFIqYeEP.fRrMAX.hf.8jdYnIsoRDnwv22zn8H69U6xyohexCK', 'STAFF', 'ACTIVE'   FROM Employee WHERE code='NV007' UNION ALL
SELECT id, 'huong.bui',   '$2a$10$PtdSFIqYeEP.fRrMAX.hf.8jdYnIsoRDnwv22zn8H69U6xyohexCK', 'STAFF', 'ACTIVE'   FROM Employee WHERE code='NV008' UNION ALL
SELECT id, 'hung.do',     '$2a$10$PtdSFIqYeEP.fRrMAX.hf.8jdYnIsoRDnwv22zn8H69U6xyohexCK', 'STAFF', 'ACTIVE'   FROM Employee WHERE code='NV009' UNION ALL
SELECT id, 'thu.ngo',     '$2a$10$PtdSFIqYeEP.fRrMAX.hf.8jdYnIsoRDnwv22zn8H69U6xyohexCK', 'STAFF', 'ACTIVE'   FROM Employee WHERE code='NV010' UNION ALL
SELECT id, 'khoa.truong', '$2a$10$PtdSFIqYeEP.fRrMAX.hf.8jdYnIsoRDnwv22zn8H69U6xyohexCK', 'STAFF', 'ACTIVE'   FROM Employee WHERE code='NV011' UNION ALL
SELECT id, 'ngoc.ly',     '$2a$10$PtdSFIqYeEP.fRrMAX.hf.8jdYnIsoRDnwv22zn8H69U6xyohexCK', 'STAFF', 'INACTIVE' FROM Employee WHERE code='NV012' UNION ALL
SELECT NULL,'kiosk01',    '$2a$10$tzZNxRcSFfK.r/UWHped5.mXMr3gme3X72/0NiueIXX7NwzLIpzmO', 'KIOSK', 'ACTIVE';

/* ---------- SEED 7: FINGERPRINTS ---------- */
INSERT INTO Fingerprint (employee_id, template_id, finger_name)
SELECT id, 1, 'Right index finger' FROM Employee WHERE code = 'NV001' UNION ALL
SELECT id, 2, 'Right thumb'        FROM Employee WHERE code = 'NV002' UNION ALL
SELECT id, 3, 'Right index finger' FROM Employee WHERE code = 'NV003' UNION ALL
SELECT id, 4, 'Right index finger' FROM Employee WHERE code = 'NV004' UNION ALL
SELECT id, 5, 'Right index finger' FROM Employee WHERE code = 'NV005';

/* ---------- SEED 8: DEMO ATTENDANCE & PAYROLL FOR OCT 2026 ---------- */
DECLARE @EmpTuanId INT = (SELECT id FROM Employee WHERE code = 'NV003');
DECLARE @ShiftAdminId INT = (SELECT TOP 1 id FROM Shift WHERE name = 'Office Shift');
DECLARE @ShiftNightId INT = (SELECT TOP 1 id FROM Shift WHERE name = 'Night Shift');
DECLARE @DeviceId INT = (SELECT TOP 1 id FROM Device WHERE api_key = 'DEVICE_SECRET_KEY_2026');

IF @ShiftAdminId IS NULL SET @ShiftAdminId = 2;
IF @ShiftNightId IS NULL SET @ShiftNightId = 4;
IF @DeviceId IS NULL SET @DeviceId = 1;

-- Schedule assignments for NV003
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

INSERT INTO ShiftAssignment (employee_id, shift_id, work_date)
VALUES (@EmpTuanId, @ShiftNightId, '2026-10-28');

-- Attendance for NV003 (SRS 8,676,000 VND example)
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

INSERT INTO Attendance (employee_id, work_date, shift_id, check_in, check_out, worked_minutes, status)
VALUES (@EmpTuanId, '2026-10-21', @ShiftAdminId, '2026-10-21 08:25:00', '2026-10-21 17:25:00', 480, 'LATE'),
       (@EmpTuanId, '2026-10-22', @ShiftAdminId, '2026-10-22 08:00:00', '2026-10-22 17:00:00', 480, 'ON_TIME'),
       (@EmpTuanId, '2026-10-23', @ShiftAdminId, '2026-10-23 08:00:00', '2026-10-23 17:00:00', 480, 'ON_TIME'),
       (@EmpTuanId, '2026-10-26', @ShiftAdminId, '2026-10-26 08:00:00', '2026-10-26 22:00:00', 780, 'OVERTIME'),
       (@EmpTuanId, '2026-10-27', @ShiftAdminId, '2026-10-27 08:00:00', '2026-10-27 22:00:00', 780, 'OVERTIME'),
       (@EmpTuanId, '2026-10-28', @ShiftNightId, '2026-10-28 22:00:00', '2026-10-29 06:00:00', 480, 'ON_TIME');

-- Attendance Logs
INSERT INTO AttendanceLog (employee_id, device_id, event_time, confidence_score, result, reason) VALUES
(@EmpTuanId, @DeviceId, '2026-10-28 21:55:12', 92, 'CHECK_IN',  'Check-in successful: On Time (Night Shift)'),
(@EmpTuanId, @DeviceId, '2026-10-29 06:05:08', 95, 'CHECK_OUT', 'Check-out successful (On Time, 8h0m)'),
(NULL,       @DeviceId, DATEADD(minute, -15, SYSDATETIME()), 35, 'NOT_RECOGNIZED', 'Low recognition confidence: 35 < 50');

-- Payroll & PayrollDetail
INSERT INTO Payroll (month, year, status) VALUES (10, 2026, 'DRAFT');
DECLARE @PayrollId INT = SCOPE_IDENTITY();

INSERT INTO PayrollDetail (
    payroll_id, employee_id, regular_hours, ot_weekday_hours, ot_weekend_hours, 
    ot_holiday_hours, night_hours, night_ot_hours, late_minutes, penalty, net_salary, email_status
) VALUES (
    @PayrollId, @EmpTuanId, 200.00, 10.00, 0.00,
    0.00, 8.00, 0.00, 20, 20000.00, 8676000.00, NULL
);

DECLARE @mEmp INT = (SELECT COUNT(*) FROM Employee);
DECLARE @mAcc INT = (SELECT COUNT(*) FROM Account);
DECLARE @mDev INT = (SELECT COUNT(*) FROM Device);
DECLARE @mShift INT = (SELECT COUNT(*) FROM Shift);
DECLARE @mSa INT = (SELECT COUNT(*) FROM ShiftAssignment);
DECLARE @mAtt INT = (SELECT COUNT(*) FROM Attendance);
DECLARE @mLog INT = (SELECT COUNT(*) FROM AttendanceLog);
DECLARE @mPd INT = (SELECT COUNT(*) FROM PayrollDetail);

PRINT '======================================================================';
PRINT '   DATABASE INITIALIZATION COMPLETED SUCCESSFULLY!                   ';
PRINT '======================================================================';
PRINT 'Database Statistics:';
PRINT '  - Employees:        ' + CAST(@mEmp AS VARCHAR);
PRINT '  - Accounts:         ' + CAST(@mAcc AS VARCHAR);
PRINT '  - Devices:          ' + CAST(@mDev AS VARCHAR);
PRINT '  - Shifts:           ' + CAST(@mShift AS VARCHAR);
PRINT '  - ShiftAssignments: ' + CAST(@mSa AS VARCHAR);
PRINT '  - Attendances:      ' + CAST(@mAtt AS VARCHAR);
PRINT '  - AttendanceLogs:   ' + CAST(@mLog AS VARCHAR);
PRINT '  - PayrollDetails:   ' + CAST(@mPd AS VARCHAR);
PRINT '----------------------------------------------------------------------';
PRINT 'Sample Accounts:';
PRINT '  * ADMIN: username: admin    | password: Admin@123';
PRINT '  * ADMIN: username: hr.lan   | password: Admin@123';
PRINT '  * STAFF: username: tuan.le  | password: Staff@123';
PRINT '  * KIOSK: username: kiosk01  | password: Kiosk@123';
PRINT '======================================================================';
GO
