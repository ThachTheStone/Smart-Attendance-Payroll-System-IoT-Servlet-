package dal;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Time;
import java.util.ArrayList;
import java.util.List;
import model.Shift;

public class ShiftDAO extends DBContext {

    public List<Shift> findAll() {
        List<Shift> list = new ArrayList<>();
        String sql = "SELECT id, name, start_time, end_time, break_minutes FROM Shift ORDER BY start_time ASC";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapResultSetToShift(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public Shift findById(int id) {
        String sql = "SELECT id, name, start_time, end_time, break_minutes FROM Shift WHERE id = ?";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToShift(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean insert(Shift s) {
        String sql = "INSERT INTO Shift (name, start_time, end_time, break_minutes) VALUES (?, ?, ?, ?)";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, s.getName());
            ps.setTime(2, Time.valueOf(s.getStartTime()));
            ps.setTime(3, Time.valueOf(s.getEndTime()));
            ps.setInt(4, s.getBreakMinutes());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean update(Shift s) {
        String sql = "UPDATE Shift SET name = ?, start_time = ?, end_time = ?, break_minutes = ? WHERE id = ?";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, s.getName());
            ps.setTime(2, Time.valueOf(s.getStartTime()));
            ps.setTime(3, Time.valueOf(s.getEndTime()));
            ps.setInt(4, s.getBreakMinutes());
            ps.setInt(5, s.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean delete(int id) {
        String sql = "DELETE FROM Shift WHERE id = ?";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            // Cannot delete if referenced by ShiftAssignment or Attendance
            e.printStackTrace();
            return false;
        }
    }

    public boolean existsName(String name, int excludeId) {
        String sql = "SELECT 1 FROM Shift WHERE name = ? AND id <> ?";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, name);
            ps.setInt(2, excludeId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    private Shift mapResultSetToShift(ResultSet rs) throws SQLException {
        Shift s = new Shift();
        s.setId(rs.getInt("id"));
        s.setName(rs.getString("name"));
        Time start = rs.getTime("start_time");
        if (start != null) {
            s.setStartTime(start.toLocalTime());
        }
        Time end = rs.getTime("end_time");
        if (end != null) {
            s.setEndTime(end.toLocalTime());
        }
        s.setBreakMinutes(rs.getInt("break_minutes"));
        return s;
    }
}
