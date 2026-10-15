# Smart Attendance & Payroll System (IoT + Servlet)

Hệ thống chấm công vân tay (ESP32 + AS608) và tính lương tự động — Java Servlet/JSP (NetBeans **Ant** Web Application), SQL Server.

## Sprint 1 (nộp 30/9): User Management
- Đăng nhập / đăng xuất cho 3 vai trò **ADMIN / STAFF / KIOSK**, mỗi vai trò vào trang riêng
- Phân quyền bằng `AuthFilter`: staff mở `/admin/*` → trang 403
- Admin: xem danh sách, tìm kiếm, lọc; thêm, sửa, khóa/mở khóa user; đặt lại mật khẩu
- Kiểm tra điều kiện khi thêm user (`util/UserValidator.java`)
- Mật khẩu hash bằng BCrypt; mọi query dùng PreparedStatement

## Yêu cầu cài đặt
| Công cụ | Phiên bản |
|---|---|
| JDK | 8 trở lên |
| NetBeans | 8.2 trở lên (project kiểu Java with Ant → Web Application) |
| Apache Tomcat | **9.x** (hoặc 8.5) — dùng `javax.servlet` |
| SQL Server | 2017 / 2019 / 2022 + SSMS |

## Chạy dự án lần đầu
1. **Database**: Mở SSMS hoặc Azure Data Studio:
   - Cách 1 (Nhanh nhất): Mở và chạy file `database/master_setup.sql` (bấm F5 để tạo toàn bộ DB và nạp đầy đủ dữ liệu demo).
   - Cách 2: Chạy lần lượt `database/01_schema.sql` → `database/02_seed.sql` → `database/03_demo_attendance.sql`.
   - Xem hướng dẫn chi tiết tại [database/README.md](database/README.md).
2. **Cấu hình DB**: copy `src/java/db.properties.example` → `src/java/db.properties`, sửa `db.user` / `db.password`. File này bị `.gitignore`, không push lên.
3. SQL Server bật **TCP/IP port 1433** và **SQL Server Authentication**.
4. NetBeans: File → Open Project → chọn thư mục project. Nếu báo *missing server*: chuột phải project → **Resolve Missing Server Problem** → chọn Tomcat 9.
5. Chuột phải project → **Clean and Build** → **Run** → `http://localhost:8080/SmartAttendance/`

## Tài khoản mẫu
| Vai trò | Username | Mật khẩu |
|---|---|---|
| ADMIN | `admin`, `hr.lan` | `Admin@123` |
| STAFF | `tuan.le`, `hoa.pham`, … | `Staff@123` |
| KIOSK | `kiosk01` | `Kiosk@123` |
| STAFF (đã khóa) | `ngoc.ly` | `Staff@123` → bị chặn đăng nhập |

## Cấu trúc
```
src/java
├── model/        Account, Employee, Role, UserForm
├── dal/          DBContext, AccountDAO, EmployeeDAO     (truy cập DB)
├── controller/   auth/ admin/ staff/ kiosk/ account/    (Servlet)
├── filter/       EncodingFilter, AuthFilter             (UTF-8, phân quyền)
├── util/         PasswordUtil, UserValidator, Flash, Constants
└── org/mindrot/jbcrypt/BCrypt.java                     (thư viện BCrypt dạng source)
web
├── WEB-INF/views/  JSP theo vai trò
├── WEB-INF/web.xml
└── assets/css/app.css
lib/              jstl-1.2.jar, mssql-jdbc-12.8.1.jre8.jar
database/         master_setup.sql, 01_schema.sql, 02_seed.sql, 03_demo_attendance.sql
nbproject/        project.xml, project.properties (build-impl.xml NetBeans tự sinh)
```

## Quy tắc làm việc nhóm
- Không code trực tiếp trên `main`. Mỗi việc 1 nhánh: `feature/<ten-viec>`.
- Trước khi code: Pull `main`. Xong việc: commit → push nhánh → Pull Request → leader review → merge.
- Commit message: `feat: ...`, `fix: ...`, `docs: ...`, `db: ...`.
- Thêm thư viện → bỏ jar vào `lib/` và add bằng **Add JAR/Folder** (chọn *Relative Path*), không trỏ tới jar ngoài project.
