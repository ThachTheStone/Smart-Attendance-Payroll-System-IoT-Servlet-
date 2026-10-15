package dal;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import model.Holiday;

public class HolidayDAO extends DBContext {

    public List<Holiday> findAll() {
        List<Holiday> list = new ArrayList<>();
        String sql = "SELECT [date], name FROM Holiday ORDER BY [date] ASC";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Date d = rs.getDate("date");
                String name = rs.getString("name");
                list.add(new Holiday(d.toLocalDate(), name));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Holiday> findByYear(int year) {
        List<Holiday> list = new ArrayList<>();
        String sql = "SELECT [date], name FROM Holiday WHERE YEAR([date]) = ? ORDER BY [date] ASC";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, year);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Date d = rs.getDate("date");
                    String name = rs.getString("name");
                    list.add(new Holiday(d.toLocalDate(), name));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean isHoliday(LocalDate date) {
        if (date == null) return false;
        String sql = "SELECT 1 FROM Holiday WHERE [date] = ?";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setDate(1, Date.valueOf(date));
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean insert(Holiday h) {
        String sql = "INSERT INTO Holiday ([date], name) VALUES (?, ?)";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setDate(1, Date.valueOf(h.getDate()));
            ps.setString(2, h.getName());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean delete(LocalDate date) {
        String sql = "DELETE FROM Holiday WHERE [date] = ?";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setDate(1, Date.valueOf(date));
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
}
