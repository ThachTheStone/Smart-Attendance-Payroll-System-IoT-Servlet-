package test;

import dal.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import util.PasswordUtil;

public class TestLogin extends DBContext {
    public static void main(String[] args) {
        new TestLogin().run();
    }

    public void run() {
        try {
            String adminHash = PasswordUtil.hash("Admin@123");
            String staffHash = PasswordUtil.hash("Staff@123");
            String kioskHash = PasswordUtil.hash("Kiosk@123");

            System.out.println("Admin Hash: " + adminHash);

            try (Connection con = getConnection()) {
                try (PreparedStatement ps = con.prepareStatement("UPDATE Account SET password_hash = ? WHERE role = 'ADMIN'")) {
                    ps.setString(1, adminHash);
                    int n = ps.executeUpdate();
                    System.out.println("Updated " + n + " admin accounts.");
                }
                try (PreparedStatement ps = con.prepareStatement("UPDATE Account SET password_hash = ? WHERE role = 'STAFF'")) {
                    ps.setString(1, staffHash);
                    int n = ps.executeUpdate();
                    System.out.println("Updated " + n + " staff accounts.");
                }
                try (PreparedStatement ps = con.prepareStatement("UPDATE Account SET password_hash = ? WHERE role = 'KIOSK'")) {
                    ps.setString(1, kioskHash);
                    int n = ps.executeUpdate();
                    System.out.println("Updated " + n + " kiosk accounts.");
                }
            }

            System.out.println("Verification test:");
            System.out.println("Admin@123 matches adminHash: " + PasswordUtil.verify("Admin@123", adminHash));
        } catch (Throwable t) {
            t.printStackTrace();
        }
    }
}
