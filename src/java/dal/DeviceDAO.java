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
import model.Device;

/**
 *
 * @author ngocthach
 */
public class DeviceDAO extends DBContext{
     // 1. Used by DeviceApiFilter to authenticate incoming requests from ESP32
    public Device findByApiKey(String apiKey){
        String sql = "SELECT id, name, location, api_key, last_heartbeat FROM Device WHERE api_key = ?";
        try(Connection con = getConnection();
               PreparedStatement ps = con.prepareCall(sql) ){
                ps.setString(1, apiKey);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        return mapResultSetToDevice(rs);
                    }
                }
                
        } catch(SQLException e){
            e.printStackTrace();
        }
        return null;
    }
    // 2. Used when ESP32 sends heartbeat or scan to update its online status
    public boolean updateHeartbeat(int deviceId){
        String sql = "UPDATE Device SET last_heartbeat = SYSDATETIME() WHERE id = ?";
        try (Connection con = getConnection();
                PreparedStatement ps = con.prepareStatement(sql)){
                    ps.setInt(1, deviceId);
                    return ps.executeUpdate() > 0; //MEAN ???
        } catch(SQLException e){
            e.printStackTrace(); //MEAN ???
            return false;
        }
    }
    
    public Device findById(int id){
        String sql = "SELECT id, name, location, api_key, last_heartbeat FROM Device WHERE id = ?";
        try(Connection con  = getConnection();
                PreparedStatement ps = con.prepareStatement(sql)){
                    ps.setInt(1, id);
                    try(ResultSet rs = ps.executeQuery()){
                        if(rs.next()){
                            return mapResultSetToDevice(rs);
                        }
                    }
                
        } catch (SQLException e){
            e.printStackTrace();
            
        }
        return null; // WHEN CATCH OUTSIDE CATCH INSIDE??
    }
    
    //HELPER METHOD OF THE findById method
    private Device mapResultSetToDevice(ResultSet rs) throws SQLException  { // what is throws SQLException mean????
        Device d = new Device();
        d.setId(rs.getInt("id"));
        d.setName(rs.getString("name"));
        d.setLocation(rs.getString("location"));
        d.setApiKey(rs.getString("api_key"));
        
        Timestamp ts = rs.getTimestamp("last_heartbeat");
        if(ts != null){
            d.setLastHeartbeat(ts.toLocalDateTime());
        }
        return d;
    }
    
    public List<Device> findAll(){
        List<Device> list = new ArrayList<>();
        String sql = "SELECT id, name, location, api_key, last_heartbeat FROM Device ORDER BY id ASC"; // ASC wtf??
        try (Connection con = getConnection();
                PreparedStatement ps = con.prepareStatement(sql)){
                    ResultSet rs = ps.executeQuery();
                    while(rs.next()){
                        list.add(mapResultSetToDevice(rs));
                    }
            
        } catch(SQLException e){
            e.printStackTrace();
        }
        return list;
    }
}
