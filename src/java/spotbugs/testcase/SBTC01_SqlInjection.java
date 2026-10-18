package spotbugs.testcase;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

/**
 * SB-TC01 (Security - SQL Injection) - mo phong dal/AccountDAO.java, vi pham NFR-03.
 * Ky vong SpotBugs: SQL_PREPARED_STATEMENT_GENERATED_FROM_NONCONSTANT_STRING tai bugFindByUsername.
 * Ham fixedFindByUsername khong duoc bao loi.
 */
public class SBTC01_SqlInjection {

    // BUG: cong chuoi username truc tiep vao cau SQL roi moi prepare
    public boolean bugFindByUsername(Connection conn, String username) throws SQLException {
        String sql = "SELECT id FROM Account WHERE username = '" + username + "'";
        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            return rs.next();
        }
    }

    // FIX: cau SQL hang so, tham so truyen qua dau ?
    public boolean fixedFindByUsername(Connection conn, String username) throws SQLException {
        String sql = "SELECT id FROM Account WHERE username = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }
}
