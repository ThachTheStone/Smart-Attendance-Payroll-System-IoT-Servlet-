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
            err.put("role", "Please select a valid role.");
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
                    err.put("code", "Employee code cannot be empty.");
                } else if (!CODE.matcher(f.getCode()).matches()) {
                    err.put("code", "Employee code must be in the format NV + 3-6 digits (e.g. NV013).");
                } else if (employeeDAO.existsCode(f.getCode())) {
                    err.put("code", "Employee code already exists.");
                }
            }

            if (isBlank(f.getFullName())) {
                err.put("fullName", "Full name cannot be empty.");
            } else if (f.getFullName().length() < 2 || f.getFullName().length() > 100) {
                err.put("fullName", "Full name must be between 2 and 100 characters.");
            } else if (!FULL_NAME.matcher(f.getFullName()).matches()) {
                err.put("fullName", "Full name must contain letters only, with at least 2 words (e.g. John Doe).");
            }

            if (isBlank(f.getEmail())) {
                err.put("email", "Email cannot be empty.");
            } else if (f.getEmail().length() > 100 || !EMAIL.matcher(f.getEmail()).matches()) {
                err.put("email", "Invalid email format.");
            } else if (employeeDAO.existsEmail(f.getEmail(), empId)) {
                err.put("email", "Email is already in use.");
            }

            if (isBlank(f.getPhone())) {
                err.put("phone", "Phone number cannot be empty.");
            } else if (!PHONE.matcher(f.getPhone()).matches()) {
                err.put("phone", "Phone must be a valid 10-digit mobile number starting with 03/05/07/08/09.");
            } else if (employeeDAO.existsPhone(f.getPhone(), empId)) {
                err.put("phone", "Phone number is already in use.");
            }

            if (isBlank(f.getDepartment()) || !Constants.DEPARTMENTS.contains(f.getDepartment())) {
                err.put("department", "Please select a department.");
            }

            if (isBlank(f.getPosition())) {
                err.put("position", "Position cannot be empty.");
            } else if (f.getPosition().length() < 2 || f.getPosition().length() > 50) {
                err.put("position", "Position must be between 2 and 50 characters.");
            }

            if (!Constants.SALARY_TYPES.contains(f.getSalaryType())) {
                err.put("salaryType", "Please select a salary type.");
            }
            validateSalary(f, err);
        }
        return err;
    }

    /** Dung chung cho doi mat khau / reset mat khau. */
    public void validatePassword(String pw, String confirm, String username, Map<String, String> err) {
        if (pw == null || pw.isEmpty()) {
            err.put("password", "Password cannot be empty.");
            return;
        }
        if (pw.length() < 8 || pw.length() > 50) {
            err.put("password", "Password must be between 8 and 50 characters.");
        } else if (pw.chars().anyMatch(Character::isWhitespace)) {
            err.put("password", "Password cannot contain whitespace.");
        } else if (!pw.matches(".*[A-Z].*") || !pw.matches(".*[a-z].*")
                || !pw.matches(".*\\d.*") || !pw.matches(".*[^A-Za-z0-9].*")) {
            err.put("password", "Password must contain uppercase, lowercase, numbers, and special characters.");
        } else if (username != null && !username.isEmpty() && pw.toLowerCase().contains(username)) {
            err.put("password", "Password cannot contain the username.");
        }
        if (confirm == null || !confirm.equals(pw)) {
            err.put("confirmPassword", "Confirmation password does not match.");
        }
    }

    private void validateUsername(UserForm f, Map<String, String> err) {
        String u = f.getUsername();
        if (isBlank(u)) {
            err.put("username", "Username cannot be empty.");
        } else if (!USERNAME.matcher(u).matches()) {
            err.put("username", "Username must be 4-30 characters, containing only a-z, 0-9, dot and underscore (cannot start/end with dot).");
        } else if (accountDAO.existsUsername(u)) {
            err.put("username", "Username already exists.");
        }
    }

    private void validateRoleChange(Account existing, Role newRole, Account currentUser, Map<String, String> err) {
        Role oldRole = existing.getRole();
        if (oldRole == newRole) {
            return;
        }
        if ((oldRole == Role.KIOSK) != (newRole == Role.KIOSK)) {
            err.put("role", "Cannot switch between KIOSK and employee accounts. Please create a new account.");
        } else if (existing.getId() == currentUser.getId()) {
            err.put("role", "You cannot change your own role.");
        } else if (oldRole == Role.ADMIN && existing.isActive() && accountDAO.countActiveAdmins() <= 1) {
            err.put("role", "This is the last active administrator and cannot be demoted.");
        }
    }

    private void validateSalary(UserForm f, Map<String, String> err) {
        if (isBlank(f.getBaseSalary())) {
            err.put("baseSalary", "Salary cannot be empty.");
            return;
        }
        BigDecimal v;
        try {
            v = new BigDecimal(f.getBaseSalary());
        } catch (NumberFormatException e) {
            err.put("baseSalary", "Salary must be a valid number.");
            return;
        }
        if ("HOURLY".equals(f.getSalaryType())) {
            if (v.compareTo(HOURLY_MIN) < 0 || v.compareTo(HOURLY_MAX) > 0) {
                err.put("baseSalary", "Hourly rate must be between 10,000 and 2,000,000 VND.");
            }
        } else if (v.compareTo(MONTHLY_MIN) < 0 || v.compareTo(MONTHLY_MAX) > 0) {
            err.put("baseSalary", "Monthly salary must be between 1,000,000 and 500,000,000 VND.");
        }
    }

    private static boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }
}
