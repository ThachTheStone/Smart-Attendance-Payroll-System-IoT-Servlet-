package dal;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import model.Account;
import model.Employee;
import model.Role;

/** DAO bang Account (+ JOIN Employee). Tat ca query dung PreparedStatement (NFR-03). */
public class AccountDAO extends DBContext {

    private final EmployeeDAO employeeDAO = new EmployeeDAO();

    private static final String SELECT_JOIN =
            "SELECT a.id, a.employee_id, a.username, a.password_hash, a.role, a.status, a.last_login, a.created_at, "
            + "e.code, e.full_name, e.email, e.phone, e.department, e.position, e.photo, "
            + "e.salary_type, e.base_salary, e.status AS emp_status "
            + "FROM Account a LEFT JOIN Employee e ON a.employee_id = e.id ";

    /* ============================ READ ============================ */

    public Account findByUsername(String username) {
        return findOne(SELECT_JOIN + "WHERE a.username = ?", ps -> ps.setString(1, username));
    }

    public Account findById(int id) {
        return findOne(SELECT_JOIN + "WHERE a.id = ?", ps -> ps.setInt(1, id));
    }

    /**
     * Tim kiem cho trang quan ly user.
     * keyword: tim theo username, ho ten, ma NV, email; role/status: null = tat ca.
     */
    public List<Account> search(String keyword, Role role, String status) {
        StringBuilder sql = new StringBuilder(SELECT_JOIN).append("WHERE 1=1 ");
        List<Object> params = new ArrayList<>();
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (a.username LIKE ? OR e.full_name LIKE ? OR e.code LIKE ? OR e.email LIKE ?) ");
            String k = "%" + keyword.trim() + "%";
            for (int i = 0; i < 4; i++) {
                params.add(k);
            }
        }
        if (role != null) {
            sql.append("AND a.role = ? ");
            params.add(role.name());
        }
        if (status != null && !status.trim().isEmpty()) {
            sql.append("AND a.status = ? ");
            params.add(status);
        }
        sql.append("ORDER BY CASE a.role WHEN 'ADMIN' THEN 0 WHEN 'STAFF' THEN 1 ELSE 2 END, e.code, a.username");

        List<Account> list = new ArrayList<>();
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(map(rs));
                }
            }
        } catch (SQLException ex) {
            throw new RuntimeException(ex);
        }
        return list;
    }

    public boolean existsUsername(String username) {
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement("SELECT 1 FROM Account WHERE LOWER(username) = LOWER(?)")) {
            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException ex) {
            throw new RuntimeException(ex);
        }
    }

    /** So admin dang hoat dong - dung de chan viec khoa/ha quyen admin cuoi cung. */
    public int countActiveAdmins() {
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(
                     "SELECT COUNT(*) FROM Account WHERE role = 'ADMIN' AND status = 'ACTIVE'");
             ResultSet rs = ps.executeQuery()) {
            rs.next();
            return rs.getInt(1);
        } catch (SQLException ex) {
            throw new RuntimeException(ex);
        }
    }

    /* ============================ WRITE ============================ */

    /**
     * Tao user moi trong 1 transaction: insert Employee (neu co) roi insert Account.
     * Loi o buoc nao thi rollback ca hai.
     */
    public int create(Account acc, Employee emp) {
        try (Connection con = getConnection()) {
            con.setAutoCommit(false);
            try {
                Integer empId = null;
                if (emp != null) {
                    empId = employeeDAO.insert(con, emp);
                }
                String sql = "INSERT INTO Account (employee_id, username, password_hash, role, status) VALUES (?,?,?,?,?)";
                int newId;
                try (PreparedStatement ps = con.prepareStatement(sql, java.sql.Statement.RETURN_GENERATED_KEYS)) {
                    ps.setObject(1, empId);
                    ps.setString(2, acc.getUsername());
                    ps.setString(3, acc.getPasswordHash());
                    ps.setString(4, acc.getRole().name());
                    ps.setString(5, "ACTIVE");
                    ps.executeUpdate();
                    try (ResultSet rs = ps.getGeneratedKeys()) {
                        rs.next();
                        newId = rs.getInt(1);
                    }
                }
                con.commit();
                return newId;
            } catch (SQLException ex) {
                con.rollback();
                throw ex;
            }
        } catch (SQLException ex) {
            throw new RuntimeException(ex);
        }
    }

    /** Cap nhat vai tro + thong tin nhan vien (neu co) trong 1 transaction. */
    public void update(Account acc, Employee emp) {
        try (Connection con = getConnection()) {
            con.setAutoCommit(false);
            try {
                try (PreparedStatement ps = con.prepareStatement("UPDATE Account SET role = ? WHERE id = ?")) {
                    ps.setString(1, acc.getRole().name());
                    ps.setInt(2, acc.getId());
                    ps.executeUpdate();
                }
                if (emp != null) {
                    employeeDAO.update(con, emp);
                }
                con.commit();
            } catch (SQLException ex) {
                con.rollback();
                throw ex;
            }
        } catch (SQLException ex) {
            throw new RuntimeException(ex);
        }
    }

    /**
     * Kich hoat / vo hieu hoa tai khoan (va nhan vien di kem).
     * TODO sprint sau (FR-ENROLL-04): khi INACTIVE -> tao DeviceCommand DELETE van tay.
     */
    public void updateStatus(int accountId, String status) {
        Account acc = findById(accountId);
        if (acc == null) {
            return;
        }
        try (Connection con = getConnection()) {
            con.setAutoCommit(false);
            try {
                try (PreparedStatement ps = con.prepareStatement("UPDATE Account SET status = ? WHERE id = ?")) {
                    ps.setString(1, status);
                    ps.setInt(2, accountId);
                    ps.executeUpdate();
                }
                if (acc.getEmployeeId() != null) {
                    employeeDAO.updateStatus(con, acc.getEmployeeId(), status);
                }
                con.commit();
            } catch (SQLException ex) {
                con.rollback();
                throw ex;
            }
        } catch (SQLException ex) {
            throw new RuntimeException(ex);
        }
    }

    public void updatePassword(int accountId, String passwordHash) {
        executeUpdate("UPDATE Account SET password_hash = ? WHERE id = ?", ps -> {
            ps.setString(1, passwordHash);
            ps.setInt(2, accountId);
        });
    }

    public void updateLastLogin(int accountId) {
        executeUpdate("UPDATE Account SET last_login = SYSDATETIME() WHERE id = ?", ps -> ps.setInt(1, accountId));
    }

    /* ============================ HELPER ============================ */

    @FunctionalInterface
    private interface Binder {
        void bind(PreparedStatement ps) throws SQLException;
    }

    private Account findOne(String sql, Binder binder) {
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            binder.bind(ps);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? map(rs) : null;
            }
        } catch (SQLException ex) {
            throw new RuntimeException(ex);
        }
    }

    private void executeUpdate(String sql, Binder binder) {
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            binder.bind(ps);
            ps.executeUpdate();
        } catch (SQLException ex) {
            throw new RuntimeException(ex);
        }
    }

    private Account map(ResultSet rs) throws SQLException {
        Account a = new Account();
        a.setId(rs.getInt("id"));
        int empId = rs.getInt("employee_id");
        a.setEmployeeId(rs.wasNull() ? null : empId);
        a.setUsername(rs.getString("username"));
        a.setPasswordHash(rs.getString("password_hash"));
        a.setRole(Role.parse(rs.getString("role")));
        a.setStatus(rs.getString("status"));
        Timestamp last = rs.getTimestamp("last_login");
        a.setLastLogin(last == null ? null : last.toLocalDateTime());
        Timestamp created = rs.getTimestamp("created_at");
        a.setCreatedAt(created == null ? null : created.toLocalDateTime());

        if (a.getEmployeeId() != null) {
            Employee e = new Employee();
            e.setId(a.getEmployeeId());
            e.setCode(rs.getString("code"));
            e.setFullName(rs.getString("full_name"));
            e.setEmail(rs.getString("email"));
            e.setPhone(rs.getString("phone"));
            e.setDepartment(rs.getString("department"));
            e.setPosition(rs.getString("position"));
            e.setPhoto(rs.getString("photo"));
            e.setSalaryType(rs.getString("salary_type"));
            e.setBaseSalary(rs.getBigDecimal("base_salary"));
            e.setStatus(rs.getString("emp_status"));
            a.setEmployee(e);
        }
        return a;
    }
}
