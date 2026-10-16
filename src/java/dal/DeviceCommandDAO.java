package dal;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import model.DeviceCommand;

public class DeviceCommandDAO extends DBContext {

    public boolean insert(DeviceCommand cmd) {
        String sql = "INSERT INTO DeviceCommand (device_id, type, template_id, employee_id, finger_name, status, created_at) "
                   + "VALUES (?, ?, ?, ?, ?, 'PENDING', SYSDATETIME())";

        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, cmd.getDeviceId());
            ps.setString(2, cmd.getType());
            ps.setInt(3, cmd.getTemplateId());
            if (cmd.getEmployeeId() == null) {
                ps.setNull(4, java.sql.Types.INTEGER);
            } else {
                ps.setInt(4, cmd.getEmployeeId());
            }
            ps.setString(5, cmd.getFingerName());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public DeviceCommand findPendingByDeviceId(int deviceId) {
        String sql = "SELECT TOP 1 id, device_id, type, template_id, employee_id, finger_name, status, created_at "
                   + "FROM DeviceCommand "
                   + "WHERE device_id = ? AND status = 'PENDING' "
                   + "ORDER BY created_at ASC";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, deviceId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToCommand(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public DeviceCommand findPendingByEmployeeId(int employeeId) {
        String sql = "SELECT TOP 1 id, device_id, type, template_id, employee_id, finger_name, status, created_at "
                   + "FROM DeviceCommand "
                   + "WHERE employee_id = ? AND status = 'PENDING' "
                   + "ORDER BY created_at DESC";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, employeeId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToCommand(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public DeviceCommand findAnyPending() {
        String sql = "SELECT TOP 1 id, device_id, type, template_id, employee_id, finger_name, status, created_at "
                   + "FROM DeviceCommand "
                   + "WHERE status = 'PENDING' "
                   + "ORDER BY created_at ASC";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return mapResultSetToCommand(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean updateStatus(int commandId, String status) {
        String sql = "UPDATE DeviceCommand SET status = ? WHERE id = ?";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, status); // 'DONE' or 'FAILED'
            ps.setInt(2, commandId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public DeviceCommand findById(int id) {
        String sql = "SELECT id, device_id, type, template_id, employee_id, finger_name, status, created_at "
                   + "FROM DeviceCommand WHERE id = ?";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToCommand(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    private DeviceCommand mapResultSetToCommand(ResultSet rs) throws SQLException {
        DeviceCommand cmd = new DeviceCommand();
        cmd.setId(rs.getInt("id"));
        cmd.setDeviceId(rs.getInt("device_id"));
        cmd.setType(rs.getString("type"));
        cmd.setTemplateId(rs.getInt("template_id"));
        int empId = rs.getInt("employee_id");
        cmd.setEmployeeId(rs.wasNull() ? null : empId);
        cmd.setFingerName(rs.getString("finger_name"));
        cmd.setStatus(rs.getString("status"));
        Timestamp ts = rs.getTimestamp("created_at");
        if (ts != null) {
            cmd.setCreateAt(ts.toLocalDateTime());
        }
        return cmd;
    }
}
