/* =====================================================================
   Smart Attendance & Payroll System - DATABASE SCHEMA (SQL Server)
   Chay file nay TRUOC, sau do chay 02_seed.sql
   Chay lai bao nhieu lan cung duoc (se xoa DB cu va tao lai).
   ===================================================================== */
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

/* ---------- 1. USER MANAGEMENT (lam trong sprint 30/9) ---------- */

CREATE TABLE Employee (
    id           INT IDENTITY(1,1) PRIMARY KEY,
    code         VARCHAR(10)    NOT NULL UNIQUE,          -- NV001
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

CREATE TABLE Account (
    id            INT IDENTITY(1,1) PRIMARY KEY,
    employee_id   INT           NULL REFERENCES Employee(id),  -- NULL voi tai khoan KIOSK
    username      VARCHAR(30)   NOT NULL UNIQUE,
    password_hash VARCHAR(100)  NOT NULL,                             -- BCrypt
    role          VARCHAR(10)   NOT NULL CHECK (role IN ('ADMIN','STAFF','KIOSK')),
    status        VARCHAR(10)   NOT NULL DEFAULT 'ACTIVE'
                  CHECK (status IN ('ACTIVE','INACTIVE')),
    last_login    DATETIME2     NULL,
    created_at    DATETIME2     NOT NULL DEFAULT SYSDATETIME()
);
GO
/* Moi nhan vien toi da 1 tai khoan; nhieu tai khoan KIOSK duoc phep co employee_id = NULL */
CREATE UNIQUE INDEX UX_Account_Employee ON Account(employee_id) WHERE employee_id IS NOT NULL;
GO

/* ---------- 2. CAC BANG CHO SPRINT SAU (tao san cho du ERD) ---------- */

CREATE TABLE Device (
    id             INT IDENTITY(1,1) PRIMARY KEY,
    name           NVARCHAR(50)  NOT NULL,
    location       NVARCHAR(100) NULL,
    api_key        VARCHAR(64)   NOT NULL UNIQUE,
    last_heartbeat DATETIME2     NULL
);

CREATE TABLE Fingerprint (
    id           INT IDENTITY(1,1) PRIMARY KEY,
    employee_id  INT          NOT NULL REFERENCES Employee(id),
    template_id  INT          NOT NULL UNIQUE,     -- vi tri luu trong AS608 (1..162)
    finger_name  NVARCHAR(30) NULL,
    enrolled_at  DATETIME2    NOT NULL DEFAULT SYSDATETIME()
);

CREATE TABLE DeviceCommand (
    id           INT IDENTITY(1,1) PRIMARY KEY,
    device_id    INT         NOT NULL REFERENCES Device(id),
    type         VARCHAR(10) NOT NULL CHECK (type IN ('ENROLL','DELETE')),
    template_id  INT         NOT NULL,
    status       VARCHAR(10) NOT NULL DEFAULT 'PENDING' CHECK (status IN ('PENDING','DONE','FAILED')),
    created_at   DATETIME2   NOT NULL DEFAULT SYSDATETIME()
);

CREATE TABLE Shift (
    id            INT IDENTITY(1,1) PRIMARY KEY,
    name          NVARCHAR(30) NOT NULL UNIQUE,
    start_time    TIME         NOT NULL,
    end_time      TIME         NOT NULL,
    break_minutes INT          NOT NULL DEFAULT 0
);

CREATE TABLE ShiftAssignment (
    id          INT IDENTITY(1,1) PRIMARY KEY,
    employee_id INT  NOT NULL REFERENCES Employee(id),
    shift_id    INT  NOT NULL REFERENCES Shift(id),
    work_date   DATE NOT NULL,
    CONSTRAINT UQ_ShiftAssignment UNIQUE (employee_id, shift_id, work_date)
);

CREATE TABLE AttendanceLog (
    id               BIGINT IDENTITY(1,1) PRIMARY KEY,
    employee_id      INT          NULL REFERENCES Employee(id),  -- NULL neu khong nhan dien duoc
    device_id        INT          NOT NULL REFERENCES Device(id),
    event_time       DATETIME2    NOT NULL DEFAULT SYSDATETIME(),
    confidence_score INT          NULL,
    result           VARCHAR(20)  NOT NULL,   -- CHECK_IN / CHECK_OUT / NOT_RECOGNIZED / IGNORED
    reason           NVARCHAR(200) NULL
);

CREATE TABLE Attendance (
    id             INT IDENTITY(1,1) PRIMARY KEY,
    employee_id    INT         NOT NULL REFERENCES Employee(id),
    work_date      DATE        NOT NULL,
    shift_id       INT         NOT NULL REFERENCES Shift(id),
    check_in       DATETIME2   NULL,
    check_out      DATETIME2   NULL,
    worked_minutes INT         NOT NULL DEFAULT 0,
    status         VARCHAR(20) NOT NULL,       -- ON_TIME, LATE, EARLY_LEAVE, MISSING_CHECKOUT, ABSENT, OVERTIME
    CONSTRAINT UQ_Attendance UNIQUE (employee_id, work_date, shift_id)
);

CREATE TABLE SalaryRule (
    rule_key    VARCHAR(50)   PRIMARY KEY,
    value       DECIMAL(15,2) NOT NULL,
    description NVARCHAR(200) NULL
);

CREATE TABLE Holiday (
    date DATE          PRIMARY KEY,
    name NVARCHAR(100) NOT NULL
);

CREATE TABLE Payroll (
    id     INT IDENTITY(1,1) PRIMARY KEY,
    month  INT         NOT NULL CHECK (month BETWEEN 1 AND 12),
    year   INT         NOT NULL,
    status VARCHAR(10) NOT NULL DEFAULT 'DRAFT' CHECK (status IN ('DRAFT','LOCKED')),
    CONSTRAINT UQ_Payroll UNIQUE (month, year)
);

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
    email_status     VARCHAR(10)   NULL,  -- SENT / FAILED
    PRIMARY KEY (payroll_id, employee_id)
);

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
