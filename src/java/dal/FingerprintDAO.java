/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dal;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import model.Fingerprint;
import java.sql.Timestamp;

/**
 *
 * @author ngocthach
 */

public class FingerprintDAO extends DBContext {
    /*
        Choose the list of fingerprinted of 1 employee (each employee have maximum 2 fingerprinted)
    */
    
    public List<Fingerprint> findByEmployeeId(int employeeId){
        List<Fingerprint> list = new ArrayList<>();
        
        String sql = "SELECT id, employee_id, template_id, finger_name, enrolled_at "
                + "FROM Fingerprint WHERE employee_id = ?";
        
        try (Connection con = getConnection();
               PreparedStatement ps = con.prepareStatement(sql)){
                ps.setInt(1, employeeId);
                try(ResultSet rs = ps.executeQuery()){
                     while(rs.next()){
                         Fingerprint fp = new Fingerprint();
                         fp.setId(rs.getInt("Id"));
                         fp.setEmployeeId(rs.getInt("employee_id"));
                         fp.setTemplateId(rs.getInt("template_id"));
                         fp.setFingerName(rs.getString("finger_name"));
                         Timestamp ts = rs.getTimestamp("enrolled_at");
                         if (ts != null){
                             fp.setErrollAt(ts.toLocalDateTime());
                         }
                         list.add(fp);      
                    }
                }
        
        }
        catch (SQLException e){
            e.printStackTrace();
        }
        return list;
    }
    
    // Crucial for /api/device/scan: Find employee by scanned template ID (1..162)
    public Fingerprint findByTemplateId(int templateId) {
        String sql = "SELECT id, employee_id, template_id, finger_name, enrolled_at "
                   + "FROM Fingerprint WHERE template_id = ?";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, templateId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToFingerprint(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
    
    public int findFreeTemplateId(){
        //Take all the list of template_id that is being used 
        String sql = "SELECT template_id FROM Fingerprint "
                + "UNION "
                + "SELECT template_id FROM DeviceCommand WHERE status = 'PENDING' ";
        
        //Use boolean array to mark up  slots is in used 
        boolean[] used = new boolean[163];
        
        try(Connection con = getConnection();
                PreparedStatement ps = con.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()){
                    while (rs.next()){
                        int id = rs.getInt("template_id");
                        if(id >= 1 && id <= 162){
                            used[id] = true;
                        }
                    }
            //find the smallest slot that have not been used
            for (int i = 1; i <= 162; i++){
                if(!used[i]){
                    return i; // Find the first slot
                }
            }
        } catch(SQLException e){
            e.printStackTrace();
        }
        return -1;  
    }
    
        public List<Fingerprint> findAll() {
        List<Fingerprint> list = new ArrayList<>();
        String sql = "SELECT id, employee_id, template_id, finger_name, enrolled_at FROM Fingerprint ORDER BY template_id ASC";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapResultSetToFingerprint(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    
    
    //SAVE THE NEW FINGER PRINT AFTER THE ESP32 SUCCESSFULLY SCAN
    public boolean insert(Fingerprint fp){
        String sql = "INSERT INTO Fingerprint (employee_id, template_id, finger_name) VALUES (?,?,?)";
        try(Connection con = getConnection();
            PreparedStatement ps = con.prepareStatement(sql)) {
               ps.setInt(1, fp.getEmployeeId());
               ps.setInt(2, fp.getTemplateId());
               ps.setString(3, fp.getFingerName());
               return ps.executeUpdate() > 0;
        } catch(SQLException e){
                e.printStackTrace();
                return false;
        }
    }
    
    //DELETE ALL THE FINGER PRINT OF 1 EMPLOYEE (WHY THE ACCOUNT IS DELETE OR UNUSABLE)
    public boolean deleteByEmployeeId(int employeeId){
        String sql = "DELETE FROM Fingerprint WHERE employee_id = ?";
        try(Connection con = getConnection();
                PreparedStatement ps = con.prepareStatement(sql)){
                ps.setInt(1, employeeId);
                return ps.executeUpdate() > 0;
        } catch(SQLException e){
            e.printStackTrace();
            return false;
        }
    }

    public boolean deleteByTemplateId(int templateId) {
        String sql = "DELETE FROM Fingerprint WHERE template_id = ?";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, templateId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    //COUNT THE SUM OF FINGERPRINT THAT HAVE BEEN SUBCRIBED TO ANOUCEMENT
    public int countTotalEnrolled(){
        String sql = "SELECT COUNT(*) FROM Fingerprint";
        try (Connection con =getConnection();
                PreparedStatement ps=con.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()){
                if (rs.next()) {
                    return rs.getInt(1);
            }
        } catch(SQLException e){
            e.printStackTrace();
            return -1;
        }
        return 0;
    }

    private Fingerprint mapResultSetToFingerprint(ResultSet rs) throws SQLException{
        Fingerprint fp = new Fingerprint();
        fp.setId(rs.getInt("id"));
        fp.setEmployeeId(rs.getInt("employee_id")); 
        fp.setTemplateId(rs.getInt("template_id"));
        fp.setFingerName(rs.getString("finger_name"));
        Timestamp ts = rs.getTimestamp("enrolled_at");
        if (ts != null) {
            fp.setErrollAt(ts.toLocalDateTime());
        }
        return fp;
    }
}
