package spotbugs.testcase;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * SB-TC09 (Bad Practice - Nuot ngoai le) - mo phong dal/DBContext.java.
 * Ky vong SpotBugs: DE_MIGHT_IGNORE tai bugGetConnection (khoi catch (Exception e) {} rong).
 */
public class SBTC09_EmptyCatch {

    private static final Logger LOG = Logger.getLogger(SBTC09_EmptyCatch.class.getName());

    // BUG: loi ket noi DB bi nuot mat, ham tra ve null va NPE xuat hien o cho khac rat kho tim
    public Connection bugGetConnection(String url, String user, String pass) {
        Connection conn = null;
        try {
            conn = DriverManager.getConnection(url, user, pass);
        } catch (Exception e) {
        }
        return conn;
    }

    // FIX: ghi log va nem lai de tang tren biet ket noi that bai
    public Connection fixedGetConnection(String url, String user, String pass) throws SQLException {
        try {
            return DriverManager.getConnection(url, user, pass);
        } catch (SQLException e) {
            LOG.log(Level.SEVERE, "Khong ket noi duoc SQL Server", e);
            throw e;
        }
    }
}
