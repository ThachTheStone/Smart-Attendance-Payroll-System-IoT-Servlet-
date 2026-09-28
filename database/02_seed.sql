/* =====================================================================
   DU LIEU MAU - chay sau 01_schema.sql
   Mat khau mau (da hash BCrypt):
     ADMIN : admin / Admin@123     (va hr.lan / Admin@123)
     STAFF : moi tai khoan staff   / Staff@123
     KIOSK : kiosk01 / Kiosk@123
   ===================================================================== */
USE SmartAttendanceDB;
GO
SET NOCOUNT ON;

DECLARE @ADMIN VARCHAR(100) = '$2a$10$puWJwO0BC6Ox2s/S.PoNmOBsBJ0lsc.UZYbMVdj/kUruJlRhBb0ui'; -- Admin@123
DECLARE @STAFF VARCHAR(100) = '$2a$10$PtdSFIqYeEP.fRrMAX.hf.8jdYnIsoRDnwv22zn8H69U6xyohexCK'; -- Staff@123
DECLARE @KIOSK VARCHAR(100) = '$2a$10$tzZNxRcSFfK.r/UWHped5.mXMr3gme3X72/0NiueIXX7NwzLIpzmO'; -- Kiosk@123

/* ---------- Employee ---------- */
INSERT INTO Employee (code, full_name, email, phone, department, position, salary_type, base_salary, status) VALUES
('NV001', N'Nguyễn Văn An',     'an.nguyen@sap.vn',    '0901000001', N'Ban Giám đốc', N'Quản lý',          'MONTHLY', 20000000, 'ACTIVE'),
('NV002', N'Trần Thị Lan',      'lan.tran@sap.vn',     '0901000002', N'Nhân sự',      N'Trưởng phòng HR',  'MONTHLY', 15000000, 'ACTIVE'),
('NV003', N'Lê Minh Tuấn',      'tuan.le@sap.vn',      '0901000003', N'Sản xuất',     N'Công nhân',        'MONTHLY',  8320000, 'ACTIVE'),
('NV004', N'Phạm Thị Hoa',      'hoa.pham@sap.vn',     '0901000004', N'Sản xuất',     N'Công nhân',        'MONTHLY',  8320000, 'ACTIVE'),
('NV005', N'Hoàng Đức Minh',    'minh.hoang@sap.vn',   '0901000005', N'Sản xuất',     N'Tổ trưởng',        'MONTHLY', 10400000, 'ACTIVE'),
('NV006', N'Võ Thị Mai',        'mai.vo@sap.vn',       '0901000006', N'Kho',          N'Thủ kho',          'MONTHLY',  9000000, 'ACTIVE'),
('NV007', N'Đặng Quốc Bảo',     'bao.dang@sap.vn',     '0901000007', N'Kho',          N'Nhân viên kho',    'HOURLY',     35000, 'ACTIVE'),
('NV008', N'Bùi Thanh Hương',   'huong.bui@sap.vn',    '0901000008', N'Kế toán',      N'Kế toán viên',     'MONTHLY', 11000000, 'ACTIVE'),
('NV009', N'Đỗ Văn Hùng',       'hung.do@sap.vn',      '0901000009', N'Bảo vệ',       N'Bảo vệ ca đêm',    'MONTHLY',  7500000, 'ACTIVE'),
('NV010', N'Ngô Thị Thu',       'thu.ngo@sap.vn',      '0901000010', N'Sản xuất',     N'Công nhân',        'HOURLY',     32000, 'ACTIVE'),
('NV011', N'Trương Văn Khoa',   'khoa.truong@sap.vn',  '0901000011', N'Sản xuất',     N'Công nhân',        'MONTHLY',  8320000, 'ACTIVE'),
('NV012', N'Lý Thị Ngọc',       'ngoc.ly@sap.vn',      '0901000012', N'Kho',          N'Nhân viên kho',    'MONTHLY',  8000000, 'INACTIVE');

/* ---------- Account ---------- */
INSERT INTO Account (employee_id, username, password_hash, role, status) VALUES
((SELECT id FROM Employee WHERE code='NV001'), 'admin',      @ADMIN, 'ADMIN', 'ACTIVE'),
((SELECT id FROM Employee WHERE code='NV002'), 'hr.lan',     @ADMIN, 'ADMIN', 'ACTIVE'),
((SELECT id FROM Employee WHERE code='NV003'), 'tuan.le',    @STAFF, 'STAFF', 'ACTIVE'),
((SELECT id FROM Employee WHERE code='NV004'), 'hoa.pham',   @STAFF, 'STAFF', 'ACTIVE'),
((SELECT id FROM Employee WHERE code='NV005'), 'minh.hoang', @STAFF, 'STAFF', 'ACTIVE'),
((SELECT id FROM Employee WHERE code='NV006'), 'mai.vo',     @STAFF, 'STAFF', 'ACTIVE'),
((SELECT id FROM Employee WHERE code='NV007'), 'bao.dang',   @STAFF, 'STAFF', 'ACTIVE'),
((SELECT id FROM Employee WHERE code='NV008'), 'huong.bui',  @STAFF, 'STAFF', 'ACTIVE'),
((SELECT id FROM Employee WHERE code='NV009'), 'hung.do',    @STAFF, 'STAFF', 'ACTIVE'),
((SELECT id FROM Employee WHERE code='NV010'), 'thu.ngo',    @STAFF, 'STAFF', 'ACTIVE'),
((SELECT id FROM Employee WHERE code='NV011'), 'khoa.truong',@STAFF, 'STAFF', 'ACTIVE'),
((SELECT id FROM Employee WHERE code='NV012'), 'ngoc.ly',    @STAFF, 'STAFF', 'INACTIVE'),
(NULL,                                         'kiosk01',    @KIOSK, 'KIOSK', 'ACTIVE');

/* ---------- Du lieu nen cho sprint sau ---------- */
INSERT INTO Device (name, location, api_key) VALUES
(N'Máy chấm công cổng chính', N'Cổng chính - Tầng 1', 'DEV-7f3a9c2e-esp32-main');

INSERT INTO Shift (name, start_time, end_time, break_minutes) VALUES
(N'Ca sáng',  '06:00', '14:00', 30),
(N'Ca chiều', '14:00', '22:00', 30),
(N'Ca đêm',   '22:00', '06:00', 30);

/* ---------- Account ---------- */
INSERT INTO Account (employee_id, username, password_hash, role, status)
SELECT id, 'admin',       '$2a$10$puWJwO0BC6Ox2s/S.PoNmOBsBJ0lsc.UZYbMVdj/kUruJlRhBb0ui', 'ADMIN', 'ACTIVE' FROM Employee WHERE code='NV001'
UNION ALL
SELECT id, 'hr.lan',      '$2a$10$puWJwO0BC6Ox2s/S.PoNmOBsBJ0lsc.UZYbMVdj/kUruJlRhBb0ui', 'ADMIN', 'ACTIVE' FROM Employee WHERE code='NV002'
UNION ALL
SELECT id, 'tuan.le',     '$2a$10$PtdSFIqYeEP.fRrMAX.hf.8jdYnIsoRDnwv22zn8H69U6xyohexCK', 'STAFF', 'ACTIVE' FROM Employee WHERE code='NV003'
UNION ALL
SELECT id, 'hoa.pham',    '$2a$10$PtdSFIqYeEP.fRrMAX.hf.8jdYnIsoRDnwv22zn8H69U6xyohexCK', 'STAFF', 'ACTIVE' FROM Employee WHERE code='NV004'
UNION ALL
SELECT id, 'minh.hoang',  '$2a$10$PtdSFIqYeEP.fRrMAX.hf.8jdYnIsoRDnwv22zn8H69U6xyohexCK', 'STAFF', 'ACTIVE' FROM Employee WHERE code='NV005'
UNION ALL
SELECT id, 'mai.vo',      '$2a$10$PtdSFIqYeEP.fRrMAX.hf.8jdYnIsoRDnwv22zn8H69U6xyohexCK', 'STAFF', 'ACTIVE' FROM Employee WHERE code='NV006'
UNION ALL
SELECT id, 'bao.dang',    '$2a$10$PtdSFIqYeEP.fRrMAX.hf.8jdYnIsoRDnwv22zn8H69U6xyohexCK', 'STAFF', 'ACTIVE' FROM Employee WHERE code='NV007'
UNION ALL
SELECT id, 'huong.bui',   '$2a$10$PtdSFIqYeEP.fRrMAX.hf.8jdYnIsoRDnwv22zn8H69U6xyohexCK', 'STAFF', 'ACTIVE' FROM Employee WHERE code='NV008'
UNION ALL
SELECT id, 'hung.do',     '$2a$10$PtdSFIqYeEP.fRrMAX.hf.8jdYnIsoRDnwv22zn8H69U6xyohexCK', 'STAFF', 'ACTIVE' FROM Employee WHERE code='NV009'
UNION ALL
SELECT id, 'thu.ngo',     '$2a$10$PtdSFIqYeEP.fRrMAX.hf.8jdYnIsoRDnwv22zn8H69U6xyohexCK', 'STAFF', 'ACTIVE' FROM Employee WHERE code='NV010'
UNION ALL
SELECT id, 'khoa.truong', '$2a$10$PtdSFIqYeEP.fRrMAX.hf.8jdYnIsoRDnwv22zn8H69U6xyohexCK', 'STAFF', 'ACTIVE' FROM Employee WHERE code='NV011'
UNION ALL
SELECT id, 'ngoc.ly',     '$2a$10$PtdSFIqYeEP.fRrMAX.hf.8jdYnIsoRDnwv22zn8H69U6xyohexCK', 'STAFF', 'INACTIVE' FROM Employee WHERE code='NV012'
UNION ALL
SELECT NULL, 'kiosk01',   '$2a$10$tzZNxRcSFfK.r/UWHped5.mXMr3gme3X72/0NiueIXX7NwzLIpzmO', 'KIOSK', 'ACTIVE';

INSERT INTO Holiday (date, name) VALUES
('2026-01-01', N'Tết Dương lịch'),
('2026-02-16', N'Tết Nguyên đán (29 Tết)'),
('2026-02-17', N'Tết Nguyên đán (Mùng 1)'),
('2026-02-18', N'Tết Nguyên đán (Mùng 2)'),
('2026-02-19', N'Tết Nguyên đán (Mùng 3)'),
('2026-02-20', N'Tết Nguyên đán (Mùng 4)'),
('2026-04-26', N'Giỗ Tổ Hùng Vương'),
('2026-04-30', N'Ngày Giải phóng miền Nam'),
('2026-05-01', N'Quốc tế Lao động'),
('2026-09-02', N'Quốc khánh'),
('2026-09-01', N'Quốc khánh (nghỉ liền kề)');

PRINT N'Seed xong: ' + CAST((SELECT COUNT(*) FROM Account) AS VARCHAR) + N' tai khoan.';
GO
