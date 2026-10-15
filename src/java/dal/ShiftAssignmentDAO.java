package dal;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Time;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;
import model.ShiftAssignment;

public class ShiftAssignmentDAO extends DBContext {

    private static final String SELECT_JOIN = 
            "SELECT sa.id, sa.employee_id, sa.shift_id, sa.work_date, "
            + "e.code AS employee_code, e.full_name AS employee_name, e.department, "
            + "s.name AS shift_name, s.start_time, s.end_time, s.break_minutes "
            + "FROM ShiftAssignment sa "
            + "JOIN Employee e ON sa.employee_id = e.id "
            + "JOIN Shift s ON sa.shift_id = s.id ";

    public List<ShiftAssignment> findByDateRange(LocalDate from, LocalDate to) {
        List<ShiftAssignment> list = new ArrayList<>();
        String sql = SELECT_JOIN + "WHERE sa.work_date BETWEEN ? AND ? "
                   + "ORDER BY sa.work_date ASC, e.code ASC, s.start_time ASC";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setDate(1, Date.valueOf(from));
            ps.setDate(2, Date.valueOf(to));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToAssignment(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<ShiftAssignment> findByEmployeeAndDateRange(int employeeId, LocalDate from, LocalDate to) {
        List<ShiftAssignment> list = new ArrayList<>();
        String sql = SELECT_JOIN + "WHERE sa.employee_id = ? AND sa.work_date BETWEEN ? AND ? "
                   + "ORDER BY sa.work_date ASC, s.start_time ASC";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, employeeId);
            ps.setDate(2, Date.valueOf(from));
            ps.setDate(3, Date.valueOf(to));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToAssignment(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<ShiftAssignment> findByEmployeeAndDate(int employeeId, LocalDate date) {
        return findByEmployeeAndDateRange(employeeId, date, date);
    }

    public boolean assign(int employeeId, int shiftId, LocalDate date) {
        String sql = "IF NOT EXISTS (SELECT 1 FROM ShiftAssignment WHERE employee_id = ? AND shift_id = ? AND work_date = ?) "
                   + "INSERT INTO ShiftAssignment (employee_id, shift_id, work_date) VALUES (?, ?, ?)";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, employeeId);
            ps.setInt(2, shiftId);
            ps.setDate(3, Date.valueOf(date));
            ps.setInt(4, employeeId);
            ps.setInt(5, shiftId);
            ps.setDate(6, Date.valueOf(date));
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Batch assigns shifts for multiple employees across a date range, optionally filtering by days of week (1=Mon..7=Sun).
     */
    public int assignBatch(List<Integer> employeeIds, int shiftId, LocalDate from, LocalDate to, Set<Integer> daysOfWeek) {
        int count = 0;
        String sql = "IF NOT EXISTS (SELECT 1 FROM ShiftAssignment WHERE employee_id = ? AND shift_id = ? AND work_date = ?) "
                   + "INSERT INTO ShiftAssignment (employee_id, shift_id, work_date) VALUES (?, ?, ?)";
        try (Connection con = getConnection()) {
            con.setAutoCommit(false);
            try (PreparedStatement ps = con.prepareStatement(sql)) {
                LocalDate curr = from;
                while (!curr.isAfter(to)) {
                    int dow = curr.getDayOfWeek().getValue();
                    if (daysOfWeek == null || daysOfWeek.isEmpty() || daysOfWeek.contains(dow)) {
                        for (int empId : employeeIds) {
                            ps.setInt(1, empId);
                            ps.setInt(2, shiftId);
                            ps.setDate(3, Date.valueOf(curr));
                            ps.setInt(4, empId);
                            ps.setInt(5, shiftId);
                            ps.setDate(6, Date.valueOf(curr));
                            ps.addBatch();
                        }
                    }
                    curr = curr.plusDays(1);
                }
                int[] results = ps.executeBatch();
                con.commit();
                for (int r : results) {
                    if (r > 0) count += r;
                }
            } catch (SQLException ex) {
                con.rollback();
                throw ex;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return count;
    }

    public boolean delete(int id) {
        String sql = "DELETE FROM ShiftAssignment WHERE id = ?";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean deleteByEmployeeAndDate(int employeeId, LocalDate date) {
        String sql = "DELETE FROM ShiftAssignment WHERE employee_id = ? AND work_date = ?";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, employeeId);
            ps.setDate(2, Date.valueOf(date));
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    private ShiftAssignment mapResultSetToAssignment(ResultSet rs) throws SQLException {
        ShiftAssignment sa = new ShiftAssignment();
        sa.setId(rs.getInt("id"));
        sa.setEmployeeId(rs.getInt("employee_id"));
        sa.setShiftId(rs.getInt("shift_id"));
        Date d = rs.getDate("work_date");
        if (d != null) {
            sa.setWorkDate(d.toLocalDate());
        }
        sa.setEmployeeCode(rs.getString("employee_code"));
        sa.setEmployeeName(rs.getString("employee_name"));
        sa.setDepartment(rs.getString("department"));
        sa.setShiftName(rs.getString("shift_name"));
        Time start = rs.getTime("start_time");
        if (start != null) {
            sa.setStartTime(start.toLocalTime());
        }
        Time end = rs.getTime("end_time");
        if (end != null) {
            sa.setEndTime(end.toLocalTime());
        }
        sa.setBreakMinutes(rs.getInt("break_minutes"));
        return sa;
    }
}
