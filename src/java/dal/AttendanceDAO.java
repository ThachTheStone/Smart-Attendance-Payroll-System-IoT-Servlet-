package dal;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Time;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import model.Attendance;

public class AttendanceDAO extends DBContext {

    private static final String SELECT_JOIN = 
            "SELECT att.id, att.employee_id, att.work_date, att.shift_id, att.check_in, att.check_out, "
            + "att.worked_minutes, att.status, "
            + "e.code AS employee_code, e.full_name AS employee_name, e.department, "
            + "s.name AS shift_name, s.start_time AS shift_start_time, s.end_time AS shift_end_time "
            + "FROM Attendance att "
            + "JOIN Employee e ON att.employee_id = e.id "
            + "JOIN Shift s ON att.shift_id = s.id ";

    public Attendance findByEmployeeDateShift(int employeeId, LocalDate date, int shiftId) {
        String sql = SELECT_JOIN + "WHERE att.employee_id = ? AND att.work_date = ? AND att.shift_id = ?";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, employeeId);
            ps.setDate(2, Date.valueOf(date));
            ps.setInt(3, shiftId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToAttendance(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<Attendance> findByEmployeeAndDate(int employeeId, LocalDate date) {
        List<Attendance> list = new ArrayList<>();
        String sql = SELECT_JOIN + "WHERE att.employee_id = ? AND att.work_date = ? ORDER BY s.start_time ASC";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, employeeId);
            ps.setDate(2, Date.valueOf(date));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToAttendance(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Attendance> findByEmployeeAndDateRange(int employeeId, LocalDate from, LocalDate to) {
        List<Attendance> list = new ArrayList<>();
        String sql = SELECT_JOIN + "WHERE att.employee_id = ? AND att.work_date BETWEEN ? AND ? "
                   + "ORDER BY att.work_date DESC, s.start_time ASC";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, employeeId);
            ps.setDate(2, Date.valueOf(from));
            ps.setDate(3, Date.valueOf(to));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToAttendance(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public Attendance findById(int id) {
        String sql = SELECT_JOIN + "WHERE att.id = ?";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToAttendance(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<Attendance> search(LocalDate from, LocalDate to, Integer employeeId, String status) {
        StringBuilder sql = new StringBuilder(SELECT_JOIN).append("WHERE 1=1 ");
        List<Object> params = new ArrayList<>();

        if (from != null) {
            sql.append("AND att.work_date >= ? ");
            params.add(Date.valueOf(from));
        }
        if (to != null) {
            sql.append("AND att.work_date <= ? ");
            params.add(Date.valueOf(to));
        }
        if (employeeId != null && employeeId > 0) {
            sql.append("AND att.employee_id = ? ");
            params.add(employeeId);
        }
        if (status != null && !status.trim().isEmpty()) {
            sql.append("AND att.status = ? ");
            params.add(status.trim());
        }

        sql.append("ORDER BY att.work_date DESC, e.code ASC, s.start_time ASC");

        List<Attendance> list = new ArrayList<>();
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToAttendance(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public int insert(Attendance a) {
        String sql = "INSERT INTO Attendance (employee_id, work_date, shift_id, check_in, check_out, worked_minutes, status) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, a.getEmployeeId());
            ps.setDate(2, Date.valueOf(a.getWorkDate()));
            ps.setInt(3, a.getShiftId());
            if (a.getCheckIn() != null) ps.setTimestamp(4, Timestamp.valueOf(a.getCheckIn()));
            else ps.setNull(4, java.sql.Types.TIMESTAMP);

            if (a.getCheckOut() != null) ps.setTimestamp(5, Timestamp.valueOf(a.getCheckOut()));
            else ps.setNull(5, java.sql.Types.TIMESTAMP);

            ps.setInt(6, a.getWorkedMinutes());
            ps.setString(7, a.getStatus());

            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return -1;
    }

    public boolean update(Attendance a) {
        String sql = "UPDATE Attendance SET check_in = ?, check_out = ?, worked_minutes = ?, status = ? WHERE id = ?";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            if (a.getCheckIn() != null) ps.setTimestamp(1, Timestamp.valueOf(a.getCheckIn()));
            else ps.setNull(1, java.sql.Types.TIMESTAMP);

            if (a.getCheckOut() != null) ps.setTimestamp(2, Timestamp.valueOf(a.getCheckOut()));
            else ps.setNull(2, java.sql.Types.TIMESTAMP);

            ps.setInt(3, a.getWorkedMinutes());
            ps.setString(4, a.getStatus());
            ps.setInt(5, a.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * FR-ATT-04: Mark records with no check-out 2 hours after shift end as MISSING_CHECKOUT.
     */
    public int markMissingCheckouts() {
        String sql = "UPDATE att "
                   + "SET att.status = 'MISSING_CHECKOUT' "
                   + "FROM Attendance att "
                   + "JOIN Shift s ON att.shift_id = s.id "
                   + "WHERE att.check_in IS NOT NULL "
                   + "  AND att.check_out IS NULL "
                   + "  AND att.status NOT IN ('MISSING_CHECKOUT') "
                   + "  AND ( "
                   + "      (s.start_time <= s.end_time AND DATEADD(hour, 2, CAST(att.work_date AS DATETIME) + CAST(s.end_time AS DATETIME)) < GETDATE()) "
                   + "      OR "
                   + "      (s.start_time > s.end_time AND DATEADD(hour, 2, DATEADD(day, 1, CAST(att.work_date AS DATETIME)) + CAST(s.end_time AS DATETIME)) < GETDATE()) "
                   + "  )";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            return ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
            return 0;
        }
    }

    /**
     * Creates ABSENT records for assigned shifts that had no check-in at all by end of day.
     */
    public int markAbsentForUnattendedShifts(LocalDate date) {
        String sql = "INSERT INTO Attendance (employee_id, work_date, shift_id, check_in, check_out, worked_minutes, status) "
                   + "SELECT sa.employee_id, sa.work_date, sa.shift_id, NULL, NULL, 0, 'ABSENT' "
                   + "FROM ShiftAssignment sa "
                   + "LEFT JOIN Attendance att ON sa.employee_id = att.employee_id "
                   + "                        AND sa.work_date = att.work_date "
                   + "                        AND sa.shift_id = att.shift_id "
                   + "WHERE sa.work_date = ? AND att.id IS NULL";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setDate(1, Date.valueOf(date));
            return ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
            return 0;
        }
    }

    /**
     * Finds employees currently checked in today who have not checked out yet (FR-DASH-01).
     */
    public List<Attendance> findCurrentlyCheckedIn(LocalDate date) {
        List<Attendance> list = new ArrayList<>();
        String sql = SELECT_JOIN + "WHERE att.work_date = ? AND att.check_in IS NOT NULL AND att.check_out IS NULL ORDER BY att.check_in DESC";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setDate(1, Date.valueOf(date));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToAttendance(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Today counters for Dashboard KPI cards (FR-DASH-02).
     */
    public int countPresentToday(LocalDate date) {
        String sql = "SELECT COUNT(DISTINCT employee_id) FROM Attendance WHERE work_date = ? AND check_in IS NOT NULL";
        return executeCount(sql, date);
    }

    public int countLateToday(LocalDate date) {
        String sql = "SELECT COUNT(*) FROM Attendance WHERE work_date = ? AND status = 'LATE'";
        return executeCount(sql, date);
    }

    public int countAbsentToday(LocalDate date) {
        String sql = "SELECT COUNT(*) FROM Attendance WHERE work_date = ? AND status = 'ABSENT'";
        return executeCount(sql, date);
    }

    public int countOvertimeToday(LocalDate date) {
        String sql = "SELECT COUNT(*) FROM Attendance WHERE work_date = ? AND status = 'OVERTIME'";
        return executeCount(sql, date);
    }

    private int executeCount(String sql, LocalDate date) {
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setDate(1, Date.valueOf(date));
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    private Attendance mapResultSetToAttendance(ResultSet rs) throws SQLException {
        Attendance a = new Attendance();
        a.setId(rs.getInt("id"));
        a.setEmployeeId(rs.getInt("employee_id"));
        Date d = rs.getDate("work_date");
        if (d != null) a.setWorkDate(d.toLocalDate());
        a.setShiftId(rs.getInt("shift_id"));

        Timestamp in = rs.getTimestamp("check_in");
        if (in != null) a.setCheckIn(in.toLocalDateTime());

        Timestamp out = rs.getTimestamp("check_out");
        if (out != null) a.setCheckOut(out.toLocalDateTime());

        a.setWorkedMinutes(rs.getInt("worked_minutes"));
        a.setStatus(rs.getString("status"));

        a.setEmployeeCode(rs.getString("employee_code"));
        a.setEmployeeName(rs.getString("employee_name"));
        a.setDepartment(rs.getString("department"));
        a.setShiftName(rs.getString("shift_name"));

        Time start = rs.getTime("shift_start_time");
        if (start != null) a.setShiftStartTime(start.toLocalTime());

        Time end = rs.getTime("shift_end_time");
        if (end != null) a.setShiftEndTime(end.toLocalTime());

        return a;
    }
}
