package spotbugs.testcase;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * SB-TC02 (Bad Practice - Ro ri ket noi DB) - mo phong dal/EmployeeDAO.java, vi pham NFR-05 (50+ nhan vien).
 * Ky vong SpotBugs: OBL_UNSATISFIED_OBLIGATION (PreparedStatement, ResultSet khong duoc dong) tai bugGetAllNames.
 */
public class SBTC02_ResourceLeak {

    // BUG: mo PreparedStatement / ResultSet nhung khong close()
    public List<String> bugGetAllNames(Connection conn) throws SQLException {
        List<String> names = new ArrayList<>();
        PreparedStatement ps = conn.prepareStatement("SELECT full_name FROM Employee");
        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            names.add(rs.getString("full_name"));
        }
        return names;
    }

    // FIX: try-with-resources tu dong dong ps va rs ke ca khi co exception
    public List<String> fixedGetAllNames(Connection conn) throws SQLException {
        List<String> names = new ArrayList<>();
        try (PreparedStatement ps = conn.prepareStatement("SELECT full_name FROM Employee");
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                names.add(rs.getString("full_name"));
            }
        }
        return names;
    }
}
