package dal;

import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;

/**
 * Tao ket noi JDBC toi SQL Server.
 * Cau hinh doc tu src/java/db.properties (moi nguoi tu tao tu db.properties.example cung thu muc).
 */
public class DBContext {

    private static final Properties PROPS = new Properties();

    static {
        try (InputStream in = DBContext.class.getClassLoader().getResourceAsStream("db.properties")) {
            if (in == null) {
                throw new IllegalStateException(
                        "Khong tim thay db.properties! Hay copy src/java/db.properties.example "
                        + "thanh db.properties va sua user/password SQL Server.");
            }
            PROPS.load(in);
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
        } catch (IOException | ClassNotFoundException e) {
            throw new ExceptionInInitializerError(e);
        }
    }

    protected Connection getConnection() throws SQLException {
        return DriverManager.getConnection(
                PROPS.getProperty("db.url"),
                PROPS.getProperty("db.user"),
                PROPS.getProperty("db.password"));
    }
}
