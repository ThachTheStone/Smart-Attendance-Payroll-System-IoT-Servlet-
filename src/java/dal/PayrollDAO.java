package dal;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import model.Attendance;
import model.Payroll;
import model.PayrollDetail;

/**
 * DAO for Payroll and PayrollDetail tables (FR-PAY-01..04, FR-PAY-07).
 */
public class PayrollDAO extends DBContext {

    /**
     * Finds Payroll header by month and year.
     */
    public Payroll findByMonthAndYear(int month, int year) {
        String sql = "SELECT p.id, p.month, p.year, p.status, "
                   + "       COUNT(pd.employee_id) AS total_employees, "
                   + "       ISNULL(SUM(pd.net_salary), 0) AS total_net_salary "
                   + "FROM Payroll p "
                   + "LEFT JOIN PayrollDetail pd ON p.id = pd.payroll_id "
                   + "WHERE p.month = ? AND p.year = ? "
                   + "GROUP BY p.id, p.month, p.year, p.status";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, month);
            ps.setInt(2, year);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Payroll p = new Payroll(rs.getInt("id"), rs.getInt("month"), rs.getInt("year"), rs.getString("status"));
                    p.setTotalEmployees(rs.getInt("total_employees"));
                    p.setTotalNetSalary(rs.getBigDecimal("total_net_salary"));
                    return p;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public Payroll findById(int id) {
        String sql = "SELECT p.id, p.month, p.year, p.status, "
                   + "       COUNT(pd.employee_id) AS total_employees, "
                   + "       ISNULL(SUM(pd.net_salary), 0) AS total_net_salary "
                   + "FROM Payroll p "
                   + "LEFT JOIN PayrollDetail pd ON p.id = pd.payroll_id "
                   + "WHERE p.id = ? "
                   + "GROUP BY p.id, p.month, p.year, p.status";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Payroll p = new Payroll(rs.getInt("id"), rs.getInt("month"), rs.getInt("year"), rs.getString("status"));
                    p.setTotalEmployees(rs.getInt("total_employees"));
                    p.setTotalNetSalary(rs.getBigDecimal("total_net_salary"));
                    return p;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<Payroll> findAll() {
        List<Payroll> list = new ArrayList<>();
        String sql = "SELECT p.id, p.month, p.year, p.status, "
                   + "       COUNT(pd.employee_id) AS total_employees, "
                   + "       ISNULL(SUM(pd.net_salary), 0) AS total_net_salary "
                   + "FROM Payroll p "
                   + "LEFT JOIN PayrollDetail pd ON p.id = pd.payroll_id "
                   + "GROUP BY p.id, p.month, p.year, p.status "
                   + "ORDER BY p.year DESC, p.month DESC";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Payroll p = new Payroll(rs.getInt("id"), rs.getInt("month"), rs.getInt("year"), rs.getString("status"));
                p.setTotalEmployees(rs.getInt("total_employees"));
                p.setTotalNetSalary(rs.getBigDecimal("total_net_salary"));
                list.add(p);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Checks if unresolved MISSING_CHECKOUT records exist for this month (FR-PAY-03).
     */
    public List<Attendance> findMissingCheckoutsForMonth(int month, int year) {
        List<Attendance> list = new ArrayList<>();
        String sql = "SELECT att.id, att.employee_id, att.work_date, att.shift_id, att.check_in, att.check_out, "
                   + "       att.worked_minutes, att.status, e.code AS employee_code, e.full_name AS employee_name, "
                   + "       e.department, s.name AS shift_name, s.start_time AS shift_start_time, s.end_time AS shift_end_time "
                   + "FROM Attendance att "
                   + "JOIN Employee e ON att.employee_id = e.id "
                   + "JOIN Shift s ON att.shift_id = s.id "
                   + "WHERE MONTH(att.work_date) = ? AND YEAR(att.work_date) = ? "
                   + "  AND (att.status = 'MISSING_CHECKOUT' OR (att.check_in IS NOT NULL AND att.check_out IS NULL)) "
                   + "ORDER BY att.work_date ASC, e.code ASC";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, month);
            ps.setInt(2, year);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Attendance a = new Attendance();
                    a.setId(rs.getInt("id"));
                    a.setEmployeeId(rs.getInt("employee_id"));
                    Date d = rs.getDate("work_date");
                    if (d != null) a.setWorkDate(d.toLocalDate());
                    a.setCheckIn(rs.getTimestamp("check_in") != null ? rs.getTimestamp("check_in").toLocalDateTime() : null);
                    a.setStatus(rs.getString("status"));
                    a.setEmployeeCode(rs.getString("employee_code"));
                    a.setEmployeeName(rs.getString("employee_name"));
                    a.setDepartment(rs.getString("department"));
                    a.setShiftName(rs.getString("shift_name"));
                    list.add(a);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public int createDraft(int month, int year) {
        String sql = "INSERT INTO Payroll (month, year, status) VALUES (?, ?, 'DRAFT')";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, month);
            ps.setInt(2, year);
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return -1;
    }

    public boolean lockPayroll(int id) {
        String sql = "UPDATE Payroll SET status = 'LOCKED' WHERE id = ?";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Saves calculated details for a payroll batch. Overwrites existing draft details.
     */
    public boolean savePayrollDetails(int payrollId, List<PayrollDetail> details) {
        String deleteSql = "DELETE FROM PayrollDetail WHERE payroll_id = ?";
        String insertSql = "INSERT INTO PayrollDetail ("
                         + "payroll_id, employee_id, regular_hours, ot_weekday_hours, ot_weekend_hours, "
                         + "ot_holiday_hours, night_hours, night_ot_hours, late_minutes, penalty, net_salary, email_status"
                         + ") VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection con = getConnection()) {
            con.setAutoCommit(false);
            try (PreparedStatement delPs = con.prepareStatement(deleteSql)) {
                delPs.setInt(1, payrollId);
                delPs.executeUpdate();
            }

            try (PreparedStatement insPs = con.prepareStatement(insertSql)) {
                for (PayrollDetail d : details) {
                    insPs.setInt(1, payrollId);
                    insPs.setInt(2, d.getEmployeeId());
                    insPs.setBigDecimal(3, d.getRegularHours());
                    insPs.setBigDecimal(4, d.getOtWeekdayHours());
                    insPs.setBigDecimal(5, d.getOtWeekendHours());
                    insPs.setBigDecimal(6, d.getOtHolidayHours());
                    insPs.setBigDecimal(7, d.getNightHours());
                    insPs.setBigDecimal(8, d.getNightOtHours());
                    insPs.setInt(9, d.getLateMinutes());
                    insPs.setBigDecimal(10, d.getPenalty());
                    insPs.setBigDecimal(11, d.getNetSalary());
                    insPs.setString(12, d.getEmailStatus());
                    insPs.addBatch();
                }
                insPs.executeBatch();
            }
            con.commit();
            return true;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<PayrollDetail> findDetailsByPayrollId(int payrollId) {
        List<PayrollDetail> list = new ArrayList<>();
        String sql = "SELECT pd.*, e.code AS employee_code, e.full_name AS employee_name, e.email AS employee_email, "
                   + "       e.department, e.position, e.salary_type, e.base_salary, "
                   + "       p.month, p.year "
                   + "FROM PayrollDetail pd "
                   + "JOIN Payroll p ON pd.payroll_id = p.id "
                   + "JOIN Employee e ON pd.employee_id = e.id "
                   + "WHERE pd.payroll_id = ? "
                   + "ORDER BY e.code ASC";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, payrollId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToDetail(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public PayrollDetail findDetailByPayrollAndEmployee(int payrollId, int employeeId) {
        String sql = "SELECT pd.*, e.code AS employee_code, e.full_name AS employee_name, e.email AS employee_email, "
                   + "       e.department, e.position, e.salary_type, e.base_salary, "
                   + "       p.month, p.year "
                   + "FROM PayrollDetail pd "
                   + "JOIN Payroll p ON pd.payroll_id = p.id "
                   + "JOIN Employee e ON pd.employee_id = e.id "
                   + "WHERE pd.payroll_id = ? AND pd.employee_id = ?";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, payrollId);
            ps.setInt(2, employeeId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToDetail(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Finds all payslips from LOCKED payroll periods for an employee (FR-PAY-07).
     */
    public List<PayrollDetail> findLockedPayslipsByEmployee(int employeeId) {
        List<PayrollDetail> list = new ArrayList<>();
        String sql = "SELECT pd.*, e.code AS employee_code, e.full_name AS employee_name, e.email AS employee_email, "
                   + "       e.department, e.position, e.salary_type, e.base_salary, "
                   + "       p.month, p.year "
                   + "FROM PayrollDetail pd "
                   + "JOIN Payroll p ON pd.payroll_id = p.id "
                   + "JOIN Employee e ON pd.employee_id = e.id "
                   + "WHERE pd.employee_id = ? AND p.status = 'LOCKED' "
                   + "ORDER BY p.year DESC, p.month DESC";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, employeeId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    PayrollDetail d = mapResultSetToDetail(rs);
                    list.add(d);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Updates email delivery status for an employee payslip (FR-PAY-06).
     */
    public boolean updateEmailStatus(int payrollId, int employeeId, String status) {
        String sql = "UPDATE PayrollDetail SET email_status = ? WHERE payroll_id = ? AND employee_id = ?";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, payrollId);
            ps.setInt(3, employeeId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    private PayrollDetail mapResultSetToDetail(ResultSet rs) throws SQLException {
        PayrollDetail d = new PayrollDetail();
        d.setPayrollId(rs.getInt("payroll_id"));
        d.setEmployeeId(rs.getInt("employee_id"));
        d.setRegularHours(rs.getBigDecimal("regular_hours"));
        d.setOtWeekdayHours(rs.getBigDecimal("ot_weekday_hours"));
        d.setOtWeekendHours(rs.getBigDecimal("ot_weekend_hours"));
        d.setOtHolidayHours(rs.getBigDecimal("ot_holiday_hours"));
        d.setNightHours(rs.getBigDecimal("night_hours"));
        d.setNightOtHours(rs.getBigDecimal("night_ot_hours"));
        d.setLateMinutes(rs.getInt("late_minutes"));
        d.setPenalty(rs.getBigDecimal("penalty"));
        d.setNetSalary(rs.getBigDecimal("net_salary"));
        d.setEmailStatus(rs.getString("email_status"));

        d.setEmployeeCode(rs.getString("employee_code"));
        d.setEmployeeName(rs.getString("employee_name"));
        d.setEmployeeEmail(rs.getString("employee_email"));
        d.setDepartment(rs.getString("department"));
        d.setPosition(rs.getString("position"));
        d.setSalaryType(rs.getString("salary_type"));
        d.setBaseSalary(rs.getBigDecimal("base_salary"));

        d.setMonth(rs.getInt("month"));
        d.setYear(rs.getInt("year"));

        // Hourly rate
        double base = d.getBaseSalary() != null ? d.getBaseSalary().doubleValue() : 0.0;
        double hr = "HOURLY".equalsIgnoreCase(d.getSalaryType()) ? base : (base / 208.0);
        d.setHourlyRate(BigDecimal.valueOf(hr));

        d.setRegularPay(BigDecimal.valueOf(d.getRegularHours().doubleValue() * hr));
        d.setOtWeekdayPay(BigDecimal.valueOf(d.getOtWeekdayHours().doubleValue() * hr * 1.5));
        d.setOtWeekendPay(BigDecimal.valueOf(d.getOtWeekendHours().doubleValue() * hr * 2.0));
        d.setOtHolidayPay(BigDecimal.valueOf(d.getOtHolidayHours().doubleValue() * hr * 3.0));
        d.setNightAllowance(BigDecimal.valueOf(d.getNightHours().doubleValue() * hr * 0.3));
        d.setNightOtBonus(BigDecimal.valueOf(d.getNightOtHours().doubleValue() * hr * 0.2));

        return d;
    }
}
