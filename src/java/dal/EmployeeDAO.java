package dal;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import model.Employee;

/**
 * DAO bang Employee. Tat ca query dung PreparedStatement (NFR-03).
 * Cac ham insert/update nhan Connection tu ben ngoai de chay chung transaction voi Account.
 */
public class EmployeeDAO extends DBContext {

    /** Them nhan vien, tra ve id vua sinh. */
    public int insert(Connection con, Employee e) throws SQLException {
        String sql = "INSERT INTO Employee (code, full_name, email, phone, department, position, "
                + "salary_type, base_salary, status) VALUES (?,?,?,?,?,?,?,?,?)";
        try (PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, e.getCode());
            ps.setString(2, e.getFullName());
            ps.setString(3, e.getEmail());
            ps.setString(4, e.getPhone());
            ps.setString(5, e.getDepartment());
            ps.setString(6, e.getPosition());
            ps.setString(7, e.getSalaryType());
            ps.setBigDecimal(8, e.getBaseSalary());
            ps.setString(9, e.getStatus() == null ? "ACTIVE" : e.getStatus());
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                rs.next();
                return rs.getInt(1);
            }
        }
    }

    /** Cap nhat thong tin (khong doi code, khong doi status o day). */
    public void update(Connection con, Employee e) throws SQLException {
        String sql = "UPDATE Employee SET full_name=?, email=?, phone=?, department=?, position=?, "
                + "salary_type=?, base_salary=? WHERE id=?";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, e.getFullName());
            ps.setString(2, e.getEmail());
            ps.setString(3, e.getPhone());
            ps.setString(4, e.getDepartment());
            ps.setString(5, e.getPosition());
            ps.setString(6, e.getSalaryType());
            ps.setBigDecimal(7, e.getBaseSalary());
            ps.setInt(8, e.getId());
            ps.executeUpdate();
        }
    }

    public void updateStatus(Connection con, int employeeId, String status) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement("UPDATE Employee SET status=? WHERE id=?")) {
            ps.setString(1, status);
            ps.setInt(2, employeeId);
            ps.executeUpdate();
        }
    }

    /* ---------------- Kiem tra trung (dung khi validate) ---------------- */

    public boolean existsCode(String code) {
        return exists("SELECT 1 FROM Employee WHERE code = ?", code, 0);
    }

    /** excludeId = id cua chinh nhan vien dang sua (0 neu la them moi). */
    public boolean existsEmail(String email, int excludeId) {
        return exists("SELECT 1 FROM Employee WHERE LOWER(email) = LOWER(?) AND id <> ?", email, excludeId);
    }

    public boolean existsPhone(String phone, int excludeId) {
        return exists("SELECT 1 FROM Employee WHERE phone = ? AND id <> ?", phone, excludeId);
    }

    /** Sinh ma NV tiep theo, vd NV013 (goi y cho form them moi). */
    public String nextCode() {
        String sql = "SELECT MAX(CAST(SUBSTRING(code, 3, 10) AS INT)) FROM Employee WHERE code LIKE 'NV%'";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            int max = rs.next() ? rs.getInt(1) : 0;
            return String.format("NV%03d", max + 1);
        } catch (SQLException ex) {
            throw new RuntimeException(ex);
        }
    }

    private boolean exists(String sql, String value, int excludeId) {
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, value);
            if (sql.contains("id <> ?")) {
                ps.setInt(2, excludeId);
            }
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException ex) {
            throw new RuntimeException(ex);
        }
    }
}
