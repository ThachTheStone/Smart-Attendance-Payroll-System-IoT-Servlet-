package dal;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import model.AuditLog;

public class AuditLogDAO extends DBContext {

    public boolean insert(AuditLog log) {
        String sql = "INSERT INTO AuditLog (admin_id, table_name, record_id, old_value, new_value, reason, time) "
                   + "VALUES (?, ?, ?, ?, ?, ?, SYSDATETIME())";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, log.getAdminId());
            ps.setString(2, log.getTableName());
            ps.setInt(3, log.getRecordId());
            ps.setString(4, log.getOldValue());
            ps.setString(5, log.getNewValue());
            ps.setString(6, log.getReason());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<AuditLog> findByRecord(String tableName, int recordId) {
        List<AuditLog> list = new ArrayList<>();
        String sql = "SELECT al.id, al.admin_id, al.table_name, al.record_id, al.old_value, al.new_value, al.reason, al.time, "
                   + "a.username AS admin_username "
                   + "FROM AuditLog al "
                   + "JOIN Account a ON al.admin_id = a.id "
                   + "WHERE al.table_name = ? AND al.record_id = ? "
                   + "ORDER BY al.time DESC";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, tableName);
            ps.setInt(2, recordId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    AuditLog al = new AuditLog();
                    al.setId(rs.getLong("id"));
                    al.setAdminId(rs.getInt("admin_id"));
                    al.setTableName(rs.getString("table_name"));
                    al.setRecordId(rs.getInt("record_id"));
                    al.setOldValue(rs.getString("old_value"));
                    al.setNewValue(rs.getString("new_value"));
                    al.setReason(rs.getString("reason"));
                    Timestamp ts = rs.getTimestamp("time");
                    if (ts != null) al.setTime(ts.toLocalDateTime());
                    al.setAdminUsername(rs.getString("admin_username"));
                    list.add(al);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
}
