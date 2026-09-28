package model;

import javax.servlet.http.HttpServletRequest;

/**
 * Du lieu tho nguoi dung nhap tren form them/sua user.
 * Giu nguyen chuoi de khi loi validate thi do lai vao form (khong bat nhap lai).
 */
public class UserForm {

    private int accountId;       // 0 = them moi
    private String role;
    private String username;
    private String password;
    private String confirmPassword;

    private String code;
    private String fullName;
    private String email;
    private String phone;
    private String department;
    private String position;
    private String salaryType;
    private String baseSalary;

    public static UserForm fromRequest(HttpServletRequest req) {
        UserForm f = new UserForm();
        String id = req.getParameter("id");
        f.accountId = (id == null || id.trim().isEmpty()) ? 0 : Integer.parseInt(id);
        f.role = trim(req.getParameter("role"));
        f.username = lower(req.getParameter("username"));
        f.password = req.getParameter("password");            // khong trim mat khau
        f.confirmPassword = req.getParameter("confirmPassword");
        f.code = upper(req.getParameter("code"));
        f.fullName = collapseSpaces(req.getParameter("fullName"));
        f.email = lower(req.getParameter("email"));
        f.phone = trim(req.getParameter("phone"));
        f.department = trim(req.getParameter("department"));
        f.position = collapseSpaces(req.getParameter("position"));
        f.salaryType = trim(req.getParameter("salaryType"));
        f.baseSalary = trim(req.getParameter("baseSalary"));
        if (f.baseSalary != null) {
            f.baseSalary = f.baseSalary.replace(",", "").replace(".", "").replace(" ", "");
        }
        return f;
    }

    /** Tao form tu du lieu DB (dung cho man hinh sua). */
    public static UserForm fromAccount(Account a) {
        UserForm f = new UserForm();
        f.accountId = a.getId();
        f.role = a.getRole().name();
        f.username = a.getUsername();
        Employee e = a.getEmployee();
        if (e != null) {
            f.code = e.getCode();
            f.fullName = e.getFullName();
            f.email = e.getEmail();
            f.phone = e.getPhone();
            f.department = e.getDepartment();
            f.position = e.getPosition();
            f.salaryType = e.getSalaryType();
            f.baseSalary = e.getBaseSalary() == null ? "" : e.getBaseSalary().toBigInteger().toString();
        }
        return f;
    }

    public boolean isCreate() {
        return accountId == 0;
    }

    public boolean isKiosk() {
        return "KIOSK".equals(role);
    }

    private static String trim(String s) {
        return s == null ? null : s.trim();
    }

    private static String lower(String s) {
        return s == null ? null : s.trim().toLowerCase();
    }

    private static String upper(String s) {
        return s == null ? null : s.trim().toUpperCase();
    }

    private static String collapseSpaces(String s) {
        return s == null ? null : s.trim().replaceAll("\\s+", " ");
    }

    public int getAccountId() { return accountId; }
    public void setAccountId(int accountId) { this.accountId = accountId; }
    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }
    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }
    public String getPassword() { return password; }
    public String getConfirmPassword() { return confirmPassword; }
    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }
    public String getFullName() { return fullName; }
    public String getEmail() { return email; }
    public String getPhone() { return phone; }
    public String getDepartment() { return department; }
    public String getPosition() { return position; }
    public String getSalaryType() { return salaryType; }
    public void setSalaryType(String salaryType) { this.salaryType = salaryType; }
    public String getBaseSalary() { return baseSalary; }
}
