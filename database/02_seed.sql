USE master;
GO
IF DB_ID('SmartAttendanceDB') IS NOT NULL
BEGIN
    ALTER DATABASE SmartAttendanceDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE SmartAttendanceDB;
END
GO
CREATE DATABASE SmartAttendanceDB;
GO
USE SmartAttendanceDB;
GO

CREATE TABLE Employee (
    id           INT IDENTITY(1,1) PRIMARY KEY,
    code         VARCHAR(10)    NOT NULL UNIQUE,
    full_name    NVARCHAR(100)  NOT NULL,
    email        VARCHAR(100)   NOT NULL UNIQUE,
    phone        VARCHAR(15)    NOT NULL UNIQUE,
    department   NVARCHAR(50)   NOT NULL,
    position     NVARCHAR(50)   NOT NULL,
    photo        VARCHAR(255)   NULL,
    salary_type  VARCHAR(10)    NOT NULL DEFAULT 'MONTHLY' CHECK (salary_type IN ('MONTHLY','HOURLY')),
    base_salary  DECIMAL(15,2)  NOT NULL CHECK (base_salary > 0),
    status       VARCHAR(10)    NOT NULL DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE','INACTIVE')),
    created_at   DATETIME2      NOT NULL DEFAULT SYSDATETIME()
);

CREATE TABLE Account (
    id            INT IDENTITY(1,1) PRIMARY KEY,
    employee_id   INT           NULL REFERENCES Employee(id),
    username      VARCHAR(30)   NOT NULL UNIQUE,
    password_hash VARCHAR(100)  NOT NULL,
    role          VARCHAR(10)   NOT NULL CHECK (role IN ('ADMIN','STAFF','KIOSK')),
    status        VARCHAR(10)   NOT NULL DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE','INACTIVE')),
    last_login    DATETIME2     NULL,
    created_at    DATETIME2     NOT NULL DEFAULT SYSDATETIME()
);
GO
CREATE UNIQUE INDEX UX_Account_Employee ON Account(employee_id) WHERE employee_id IS NOT NULL;
GO

INSERT INTO Employee (code, full_name, email, phone, department, position, salary_type, base_salary, status) VALUES
('NV001', N'Nguyễn Văn An',    'an.nguyen@sap.vn',   '0901000001', N'Ban Giám đốc', N'Quản lý',         'MONTHLY', 20000000, 'ACTIVE'),
('NV002', N'Trần Thị Lan',     'lan.tran@sap.vn',    '0901000002', N'Nhân sự',     N'Trưởng phòng HR', 'MONTHLY', 15000000, 'ACTIVE'),
('NV003', N'Lê Minh Tuấn',     'tuan.le@sap.vn',     '0901000003', N'Sản xuất',    N'Công nhân',       'MONTHLY',  8320000, 'ACTIVE'),
('NV004', N'Phạm Thị Hoa',     'hoa.pham@sap.vn',    '0901000004', N'Sản xuất',    N'Công nhân',       'MONTHLY',  8320000, 'ACTIVE'),
('NV005', N'Hoàng Đức Minh',   'minh.hoang@sap.vn',  '0901000005', N'Sản xuất',    N'Tổ trưởng',       'MONTHLY', 10400000, 'ACTIVE'),
('NV006', N'Võ Thị Mai',       'mai.vo@sap.vn',      '0901000006', N'Kho',         N'Thủ kho',         'MONTHLY',  9000000, 'ACTIVE'),
('NV007', N'Đặng Quốc Bảo',    'bao.dang@sap.vn',    '0901000007', N'Kho',         N'Nhân viên kho',   'HOURLY',     35000, 'ACTIVE'),
('NV008', N'Bùi Thanh Hương',  'huong.bui@sap.vn',   '0901000008', N'Kế toán',     N'Kế toán viên',    'MONTHLY', 11000000, 'ACTIVE'),
('NV009', N'Đỗ Văn Hùng',      'hung.do@sap.vn',     '0901000009', N'Bảo vệ',      N'Bảo vệ ca đêm',   'MONTHLY',  7500000, 'ACTIVE'),
('NV010', N'Ngô Thị Thu',      'thu.ngo@sap.vn',     '0901000010', N'Sản xuất',    N'Công nhân',       'HOURLY',     32000, 'ACTIVE'),
('NV011', N'Trương Văn Khoa',  'khoa.truong@sap.vn', '0901000011', N'Sản xuất',    N'Công nhân',       'MONTHLY',  8320000, 'ACTIVE'),
('NV012', N'Lý Thị Ngọc',      'ngoc.ly@sap.vn',     '0901000012', N'Kho',         N'Nhân viên kho',   'MONTHLY',  8000000, 'INACTIVE');

INSERT INTO Account (employee_id, username, password_hash, role, status)
SELECT id, 'admin',       '$2a$10$puWJwO0BC6Ox2s/S.PoNmOBsBJ0lsc.UZYbMVdj/kUruJlRhBb0ui', 'ADMIN',  'ACTIVE'   FROM Employee WHERE code='NV001' UNION ALL
SELECT id, 'hr.lan',      '$2a$10$puWJwO0BC6Ox2s/S.PoNmOBsBJ0lsc.UZYbMVdj/kUruJlRhBb0ui', 'ADMIN',  'ACTIVE'   FROM Employee WHERE code='NV002' UNION ALL
SELECT id, 'tuan.le',     '$2a$10$PtdSFIqYeEP.fRrMAX.hf.8jdYnIsoRDnwv22zn8H69U6xyohexCK', 'STAFF',  'ACTIVE'   FROM Employee WHERE code='NV003' UNION ALL
SELECT id, 'hoa.pham',    '$2a$10$PtdSFIqYeEP.fRrMAX.hf.8jdYnIsoRDnwv22zn8H69U6xyohexCK', 'STAFF',  'ACTIVE'   FROM Employee WHERE code='NV004' UNION ALL
SELECT id, 'minh.hoang',  '$2a$10$PtdSFIqYeEP.fRrMAX.hf.8jdYnIsoRDnwv22zn8H69U6xyohexCK', 'STAFF',  'ACTIVE'   FROM Employee WHERE code='NV005' UNION ALL
SELECT id, 'mai.vo',      '$2a$10$PtdSFIqYeEP.fRrMAX.hf.8jdYnIsoRDnwv22zn8H69U6xyohexCK', 'STAFF',  'ACTIVE'   FROM Employee WHERE code='NV006' UNION ALL
SELECT id, 'bao.dang',    '$2a$10$PtdSFIqYeEP.fRrMAX.hf.8jdYnIsoRDnwv22zn8H69U6xyohexCK', 'STAFF',  'ACTIVE'   FROM Employee WHERE code='NV007' UNION ALL
SELECT id, 'huong.bui',   '$2a$10$PtdSFIqYeEP.fRrMAX.hf.8jdYnIsoRDnwv22zn8H69U6xyohexCK', 'STAFF',  'ACTIVE'   FROM Employee WHERE code='NV008' UNION ALL
SELECT id, 'hung.do',     '$2a$10$PtdSFIqYeEP.fRrMAX.hf.8jdYnIsoRDnwv22zn8H69U6xyohexCK', 'STAFF',  'ACTIVE'   FROM Employee WHERE code='NV009' UNION ALL
SELECT id, 'thu.ngo',     '$2a$10$PtdSFIqYeEP.fRrMAX.hf.8jdYnIsoRDnwv22zn8H69U6xyohexCK', 'STAFF',  'ACTIVE'   FROM Employee WHERE code='NV010' UNION ALL
SELECT id, 'khoa.truong', '$2a$10$PtdSFIqYeEP.fRrMAX.hf.8jdYnIsoRDnwv22zn8H69U6xyohexCK', 'STAFF',  'ACTIVE'   FROM Employee WHERE code='NV011' UNION ALL
SELECT id, 'ngoc.ly',     '$2a$10$PtdSFIqYeEP.fRrMAX.hf.8jdYnIsoRDnwv22zn8H69U6xyohexCK', 'STAFF',  'INACTIVE' FROM Employee WHERE code='NV012' UNION ALL
SELECT NULL,'kiosk01',    '$2a$10$tzZNxRcSFfK.r/UWHped5.mXMr3gme3X72/0NiueIXX7NwzLIpzmO', 'KIOSK',  'ACTIVE';

/*Add a device for attendance tracking */
INSERT INTO Device (name, location, api_key, last_heartbeat)
VALUES (N'Cổng chính ESP32', N'Tầng 1 - cừa ra vào', N'DEVICE_SECRET_KEY_2026',SYSDATETIME());


GO