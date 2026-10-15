# Hướng Dẫn Cài Đặt CSDL SQL Server (Database Setup Guide)

Thư mục này chứa toàn bộ các script SQL để khởi tạo CSDL **`SmartAttendanceDB`** cho hệ thống Smart Attendance & Payroll System trên **Microsoft SQL Server** (2017 / 2019 / 2022 / Express).

---

## 1. Cách Chạy Script Nhanh Nhất (Khuyên Dùng)

Bạn có thể chạy toàn bộ hệ thống bằng **1 file duy nhất**:

1. Mở **SQL Server Management Studio (SSMS)** hoặc **Azure Data Studio**.
2. Kết nối tới SQL Server của bạn (ví dụ: `localhost` hoặc `.\SQLEXPRESS`).
3. Mở file: **`database/master_setup.sql`**.
4. Bấm nút **Execute** (hoặc nhấn phím **F5**).
5. Kiểm tra tab **Messages**, khi thấy thông báo:
   ```
   ======================================================================
      KHOI TAO CSDL HOAN TAT 100%!
   ======================================================================
   ```
   thì cơ sở dữ liệu đã sẵn sàng.

---

## 2. Hoặc Chạy Từng Bước Theo Thứ Tự

Nếu bạn muốn chạy thủ công từng phần, hãy mở và chạy theo đúng thứ tự 3 file sau:

| STT | File Script | Mô tả |
| :---: | :--- | :--- |
| **1** | [`01_schema.sql`](01_schema.sql) | Tạo mới CSDL `SmartAttendanceDB`, thiết lập 14 bảng, khoá chính, khoá ngoại và index. |
| **2** | [`02_seed.sql`](02_seed.sql) | Nạp dữ liệu nền (12 nhân viên, 13 tài khoản, 4 ca làm, quy tắc tính lương, ngày lễ, thiết bị IoT, 5 mẫu vân tay). |
| **3** | [`03_demo_attendance.sql`](03_demo_attendance.sql) | Nạp dữ liệu chấm công & bảng lương demo tháng 10/2026 cho nhân viên **Lê Minh Tuấn (NV003)** đúng chuẩn ví dụ đặc tả SRS. |

---

## 3. Cấu Hình Kết Nối Java Web (`db.properties`)

Sau khi chạy xong script SQL, bạn cấu hình kết nối trong dự án NetBeans:

1. Copy file: `src/java/db.properties.example` thành `src/java/db.properties` (file này nằm trong `.gitignore` nên bạn có thể giữ mật khẩu riêng không sợ bị ghi đè khi pull/push).
2. Mở file `src/java/db.properties` và sửa lại thông tin tài khoản SQL Server của bạn:

### Trường hợp 1: Dùng SQL Server mặc định (Default Instance - cổng 1433)
```properties
db.url=jdbc:sqlserver://localhost:1433;databaseName=SmartAttendanceDB;encrypt=true;trustServerCertificate=true
db.user=sa
db.password=MatKhauCuaBan123
```

### Trường hợp 2: Dùng SQL Server Express (Named Instance)
```properties
db.url=jdbc:sqlserver://localhost;instanceName=SQLEXPRESS;databaseName=SmartAttendanceDB;encrypt=true;trustServerCertificate=true
db.user=sa
db.password=MatKhauCuaBan123
```

---

## 4. Danh Sách Tài Khoản Mẫu Để Đăng Nhập

Mọi mật khẩu đều đã được mã hoá bằng thuật toán BCrypt chuẩn:

| Vai Trò | Tên Đăng Nhập (Username) | Mật Khẩu (Password) | Ghi Chú |
| :--- | :--- | :--- | :--- |
| **ADMIN** | `admin` | `Admin@123` | Quản trị viên hệ thống (Ban Giám đốc) |
| **ADMIN** | `hr.lan` | `Admin@123` | Quản trị viên HR (Trưởng phòng Nhân sự) |
| **STAFF** | `tuan.le` | `Staff@123` | Nhân viên sản xuất (Đã có dữ liệu chấm công demo) |
| **STAFF** | `hoa.pham`, `minh.hoang`, `mai.vo`... | `Staff@123` | Các nhân viên khác |
| **KIOSK** | `kiosk01` | `Kiosk@123` | Màn hình Kiosk hiển thị chấm công thời gian thực |
| **LOCKED** | `ngoc.ly` | `Staff@123` | Tài khoản trạng thái `INACTIVE` (dùng để test chặn đăng nhập) |

---

## 5. Thông Tin Thiết Bị IoT & Giả Lập Quẹt Vân Tay

- **Tên thiết bị**: Cổng chính ESP32 (`id = 1`)
- **API Key**: `DEVICE_SECRET_KEY_2026`
- **Mẫu vân tay đã đăng ký mẫu (Template ID)**:
  - `Template ID = 3`: Nhân viên **Lê Minh Tuấn (NV003)**
  - `Template ID = 1`: Nguyễn Văn An (NV001)
  - `Template ID = 2`: Trần Thị Lan (NV002)
  - `Template ID = 4`: Phạm Thị Hoa (NV004)
  - `Template ID = 5`: Hoàng Đức Minh (NV005)
- Khi test API chấm công qua Postman hoặc curl:
  ```http
  POST /SmartAttendance/api/device/scan
  X-API-Key: DEVICE_SECRET_KEY_2026
  Content-Type: application/json

  {
    "templateId": 3,
    "confidence": 85
  }
  ```

---

## 6. Xử Lý Các Lỗi Thường Gặp (Troubleshooting)

### Lỗi 1: `The TCP/IP connection to the host localhost, port 1433 has failed`
- **Nguyên nhân**: Dịch vụ SQL Server chưa bật giao thức TCP/IP hoặc chưa mở cổng 1433.
- **Cách sửa**:
  1. Mở **SQL Server Configuration Manager**.
  2. Chọn **SQL Server Network Configuration** -> **Protocols for MSSQLSERVER** (hoặc `Protocols for SQLEXPRESS`).
  3. Chuột phải vào **TCP/IP** -> chọn **Enable**.
  4. Chuột phải vào **TCP/IP** -> chọn **Properties** -> tab **IP Addresses** -> cuộn xuống mục **IPAll** -> đặt **TCP Port** là `1433`.
  5. Chọn mục **SQL Server Services** -> Chuột phải vào dịch vụ **SQL Server** -> chọn **Restart**.

### Lỗi 2: `Login failed for user 'sa'`
- **Nguyên nhân**: SQL Server đang ở chế độ chỉ cho phép Windows Authentication, hoặc tài khoản `sa` bị Disable.
- **Cách sửa**:
  1. Mở SSMS, đăng nhập bằng **Windows Authentication**.
  2. Chuột phải vào Server (ở dòng trên cùng của Object Explorer) -> chọn **Properties**.
  3. Chọn mục **Security** -> tích chọn **SQL Server and Windows Authentication mode** -> bấm **OK**.
  4. Mở thư mục **Security** -> **Logins** -> chuột phải vào tài khoản `sa` -> chọn **Properties**.
  5. Tab **General**: Đặt lại mật khẩu (ví dụ: `123456`).
  6. Tab **Status**: Chọn **Grant** (Permission to connect to database engine) và **Enabled** (Login).
  7. Chuột phải vào Server -> chọn **Restart**.
