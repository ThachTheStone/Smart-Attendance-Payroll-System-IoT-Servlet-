package util;

import dal.AccountDAO;
import dal.EmployeeDAO;
import java.math.BigDecimal;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.regex.Pattern;
import model.Account;
import model.Role;
import model.UserForm;

/**
 * Kiem tra dieu kien khi THEM MOI / CAP NHAT user.
 * Tra ve Map<ten field, thong bao loi>. Map rong = hop le.
 *
 * Danh sach dieu kien (dung de demo cho co):
 *  - Vai tro: bat buoc, thuoc ADMIN / STAFF / KIOSK
 *  - Username: 4-30 ky tu, chi a-z 0-9 . _ , khong bat dau/ket thuc bang dau cham, KHONG TRUNG
 *  - Mat khau: 8-50 ky tu, co chu hoa, chu thuong, so, ky tu dac biet, khong khoang trang,
 *              khong chua username; nhap lai phai khop
 *  - (ADMIN/STAFF) Ma NV: dang NV + 3-6 chu so, KHONG TRUNG
 *  - Ho ten: 2-100 ky tu, chi chu cai + khoang trang, it nhat 2 tu
 *  - Email: dung dinh dang, <= 100 ky tu, KHONG TRUNG
 *  - SDT: di dong VN 10 so (03/05/07/08/09), KHONG TRUNG
 *  - Phong ban: thuoc danh sach; Chuc vu: 2-50 ky tu
 *  - Loai luong MONTHLY/HOURLY; muc luong la so nguyen duong trong khoang hop ly
 *  - Khi sua: khong tu ha quyen chinh minh, khong ha quyen admin cuoi cung,
 *             khong doi qua lai giua KIOSK va ADMIN/STAFF
 */
public class UserValidator {

    private static final Pattern USERNAME = Pattern.compile("^(?![.])[a-z0-9._]{4,30}(?<![.])$");
    private static final Pattern CODE = Pattern.compile("^NV\\d{3,6}$");
    private static final Pattern FULL_NAME = Pattern.compile("^[\\p{L}]+( [\\p{L}]+)+$");
    private static final Pattern EMAIL = Pattern.compile("^[a-z0-9._%+-]+@[a-z0-9.-]+\\.[a-z]{2,}$");
    private static final Pattern PHONE = Pattern.compile("^0(3|5|7|8|9)\\d{8}$");

    private static final BigDecimal MONTHLY_MIN = new BigDecimal("1000000");
    private static final BigDecimal MONTHLY_MAX = new BigDecimal("500000000");
    private static final BigDecimal HOURLY_MIN = new BigDecimal("10000");
    private static final BigDecimal HOURLY_MAX = new BigDecimal("2000000");

    private final AccountDAO accountDAO = new AccountDAO();
    private final EmployeeDAO employeeDAO = new EmployeeDAO();

    /**
     * @param f         du lieu form
     * @param existing  tai khoan dang sua (null khi them moi)
     * @param currentUser admin dang thao tac
     */
    public Map<String, String> validate(UserForm f, Account existing, Account currentUser) {
        Map<String, String> err = new LinkedHashMap<>();
        boolean create = existing == null;

        // ---- Vai tro ----
        Role role = Role.parse(f.getRole());
        if (role == null) {
            err.put("role", "Vui lòng chọn vai trò hợp lệ.");
        }

        if (create) {
            validateUsername(f, err);
            validatePassword(f.getPassword(), f.getConfirmPassword(), f.getUsername(), err);
        } else if (role != null) {
            validateRoleChange(existing, role, currentUser, err);
        }

        // ---- Thong tin nhan vien (khong ap dung cho KIOSK) ----
        if (role != null && role != Role.KIOSK && !err.containsKey("role")) {
            int empId = (create || existing.getEmployeeId() == null) ? 0 : existing.getEmployeeId();
            if (create) {
                if (isBlank(f.getCode())) {
                    err.put("code", "Mã nhân viên không được để trống.");
                } else if (!CODE.matcher(f.getCode()).matches()) {
                    err.put("code", "Mã nhân viên phải có dạng NV + 3-6 chữ số (vd: NV013).");
                } else if (employeeDAO.existsCode(f.getCode())) {
                    err.put("code", "Mã nhân viên đã tồn tại.");
                }
            }

            if (isBlank(f.getFullName())) {
                err.put("fullName", "Họ tên không được để trống.");
            } else if (f.getFullName().length() < 2 || f.getFullName().length() > 100) {
                err.put("fullName", "Họ tên dài 2-100 ký tự.");
            } else if (!FULL_NAME.matcher(f.getFullName()).matches()) {
                err.put("fullName", "Họ tên chỉ gồm chữ cái, tối thiểu 2 từ (vd: Nguyễn Văn A).");
            }

            if (isBlank(f.getEmail())) {
                err.put("email", "Email không được để trống.");
            } else if (f.getEmail().length() > 100 || !EMAIL.matcher(f.getEmail()).matches()) {
                err.put("email", "Email không đúng định dạng.");
            } else if (employeeDAO.existsEmail(f.getEmail(), empId)) {
                err.put("email", "Email đã được sử dụng.");
            }

            if (isBlank(f.getPhone())) {
                err.put("phone", "Số điện thoại không được để trống.");
            } else if (!PHONE.matcher(f.getPhone()).matches()) {
                err.put("phone", "SĐT phải là số di động VN 10 số, bắt đầu 03/05/07/08/09.");
            } else if (employeeDAO.existsPhone(f.getPhone(), empId)) {
                err.put("phone", "Số điện thoại đã được sử dụng.");
            }

            if (isBlank(f.getDepartment()) || !Constants.DEPARTMENTS.contains(f.getDepartment())) {
                err.put("department", "Vui lòng chọn phòng ban.");
            }

            if (isBlank(f.getPosition())) {
                err.put("position", "Chức vụ không được để trống.");
            } else if (f.getPosition().length() < 2 || f.getPosition().length() > 50) {
                err.put("position", "Chức vụ dài 2-50 ký tự.");
            }

            if (!Constants.SALARY_TYPES.contains(f.getSalaryType())) {
                err.put("salaryType", "Vui lòng chọn loại lương.");
            }
            validateSalary(f, err);
        }
        return err;
    }

    /** Dung chung cho doi mat khau / reset mat khau. */
    public void validatePassword(String pw, String confirm, String username, Map<String, String> err) {
        if (pw == null || pw.isEmpty()) {
            err.put("password", "Mật khẩu không được để trống.");
            return;
        }
        if (pw.length() < 8 || pw.length() > 50) {
            err.put("password", "Mật khẩu dài 8-50 ký tự.");
        } else if (pw.chars().anyMatch(Character::isWhitespace)) {
            err.put("password", "Mật khẩu không được chứa khoảng trắng.");
        } else if (!pw.matches(".*[A-Z].*") || !pw.matches(".*[a-z].*")
                || !pw.matches(".*\\d.*") || !pw.matches(".*[^A-Za-z0-9].*")) {
            err.put("password", "Mật khẩu phải có chữ hoa, chữ thường, chữ số và ký tự đặc biệt.");
        } else if (username != null && !username.isEmpty() && pw.toLowerCase().contains(username)) {
            err.put("password", "Mật khẩu không được chứa tên đăng nhập.");
        }
        if (confirm == null || !confirm.equals(pw)) {
            err.put("confirmPassword", "Mật khẩu nhập lại không khớp.");
        }
    }

    private void validateUsername(UserForm f, Map<String, String> err) {
        String u = f.getUsername();
        if (isBlank(u)) {
            err.put("username", "Tên đăng nhập không được để trống.");
        } else if (!USERNAME.matcher(u).matches()) {
            err.put("username", "Tên đăng nhập 4-30 ký tự, chỉ gồm a-z, 0-9, dấu . và _ (không bắt đầu/kết thúc bằng dấu .).");
        } else if (accountDAO.existsUsername(u)) {
            err.put("username", "Tên đăng nhập đã tồn tại.");
        }
    }

    private void validateRoleChange(Account existing, Role newRole, Account currentUser, Map<String, String> err) {
        Role oldRole = existing.getRole();
        if (oldRole == newRole) {
            return;
        }
        if ((oldRole == Role.KIOSK) != (newRole == Role.KIOSK)) {
            err.put("role", "Không thể đổi giữa tài khoản KIOSK và tài khoản nhân viên. Hãy tạo tài khoản mới.");
        } else if (existing.getId() == currentUser.getId()) {
            err.put("role", "Bạn không thể tự đổi vai trò của chính mình.");
        } else if (oldRole == Role.ADMIN && existing.isActive() && accountDAO.countActiveAdmins() <= 1) {
            err.put("role", "Đây là admin cuối cùng đang hoạt động, không thể hạ quyền.");
        }
    }

    private void validateSalary(UserForm f, Map<String, String> err) {
        if (isBlank(f.getBaseSalary())) {
            err.put("baseSalary", "Mức lương không được để trống.");
            return;
        }
        BigDecimal v;
        try {
            v = new BigDecimal(f.getBaseSalary());
        } catch (NumberFormatException e) {
            err.put("baseSalary", "Mức lương phải là số.");
            return;
        }
        if ("HOURLY".equals(f.getSalaryType())) {
            if (v.compareTo(HOURLY_MIN) < 0 || v.compareTo(HOURLY_MAX) > 0) {
                err.put("baseSalary", "Lương theo giờ phải từ 10.000 đến 2.000.000 VND.");
            }
        } else if (v.compareTo(MONTHLY_MIN) < 0 || v.compareTo(MONTHLY_MAX) > 0) {
            err.put("baseSalary", "Lương tháng phải từ 1.000.000 đến 500.000.000 VND.");
        }
    }

    private static boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }
}
