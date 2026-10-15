/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dal;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import model.AttendanceLog;

/**
 *
 * @author ngocthach
 */
public class AttendanceLogDAO extends DBContext {
    
    
    public boolean insert(AttendanceLog log) {
        String sql = "INSERT INTO AttendanceLog (employee_id, device_id, event_time, confidence_score, result, reason) "
                   + "VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            if (log.getEmployeeId() == null) {
                ps.setNull(1, java.sql.Types.INTEGER);
            } else {
                ps.setInt(1, log.getEmployeeId());
            }
            
            ps.setInt(2, log.getDeviceId());
            
            if (log.getEventTime() != null) {
                ps.setTimestamp(3, Timestamp.valueOf(log.getEventTime()));
            } else {
                ps.setTimestamp(3, Timestamp.valueOf(java.time.LocalDateTime.now()));
            }
            
            if (log.getConfidenceScore() == null) {
                ps.setNull(4, java.sql.Types.INTEGER);
            } else {
                ps.setInt(4, log.getConfidenceScore());
            }
            
            ps.setString(5, log.getResult());
            ps.setString(6, log.getReason());
            
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<AttendanceLog> findRecent(int limit) {
        return findRecentWithDetails(limit);
    }

    public List<AttendanceLog> findRecentWithDetails(int limit) {
        List<AttendanceLog> list = new ArrayList<>();
        String sql = "SELECT TOP (" + limit + ") l.id, l.employee_id, l.device_id, l.event_time, l.confidence_score, l.result, l.reason, "
                   + "e.full_name AS employee_name, e.code AS employee_code, e.department, d.name AS device_name "
                   + "FROM AttendanceLog l "
                   + "LEFT JOIN Employee e ON l.employee_id = e.id "
                   + "LEFT JOIN Device d ON l.device_id = d.id "
                   + "ORDER BY l.event_time DESC";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                AttendanceLog log = mapResultSetToLog(rs);
                log.setEmployeeName(rs.getString("employee_name"));
                log.setEmployeeCode(rs.getString("employee_code"));
                log.setDepartment(rs.getString("department"));
                log.setDeviceName(rs.getString("device_name"));
                list.add(log);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public int countUnknownScansInLastMinutes(int minutes) {
        String sql = "SELECT COUNT(*) FROM AttendanceLog "
                   + "WHERE result = 'NOT_RECOGNIZED' "
                   + "  AND event_time >= DATEADD(minute, -?, SYSDATETIME())";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, minutes);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }
    
    public AttendanceLog findLastLogByEmployeeId(int employeeId) {
    String sql = "SELECT TOP 1 id, employee_id, device_id, event_time, confidence_score, result, reason "
               + "FROM AttendanceLog "
               + "WHERE employee_id = ? "
               + "ORDER BY event_time DESC";
    try (Connection con = getConnection();
         PreparedStatement ps = con.prepareStatement(sql)) {
        ps.setInt(1, employeeId);
        try (ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return mapResultSetToLog(rs);
            }
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
    return null;
}

    private AttendanceLog mapResultSetToLog(ResultSet rs) throws SQLException{
        AttendanceLog log = new AttendanceLog();
        log.setId(rs.getLong("id"));
        
        int empId = rs.getInt("employee_id");
        log.setEmployeeId(rs.wasNull() ? null : empId);
        
        log.setDeviceId(rs.getInt("device_id"));
        
        Timestamp ts = rs.getTimestamp("event_time");
        if (ts != null) {
            log.setEventTime(ts.toLocalDateTime());
        }
        
        int conf = rs.getInt("confidence_score");
        log.setConfidenceScore(rs.wasNull() ? null : conf);
        
        log.setResult(rs.getString("result"));
        log.setReason(rs.getString("reason"));
        return log;
    }


}
