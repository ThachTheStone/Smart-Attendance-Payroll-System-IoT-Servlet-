package util;

import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Date;
import java.util.List;

/**
 * Class dùng để Demo trực tiếp các Test Cases của SpotBugs cho dự án SmartAttendance
 */
public class SpotBugsDemoShowcase {

    private static String sharedTemplateId; // Dùng cho SB-TC05
    private Date enrolledDate;              // Dùng cho SB-TC08

    // SB-TC01 (SQL Injection) & SB-TC02 (Resource Leak - Không đóng kết nối DB)
    public void demoTC01_TC02_SqlAndResourceLeak(Connection conn, String username) throws SQLException {
        String sql = "SELECT * FROM Account WHERE username = '" + username + "'";
        PreparedStatement ps = conn.prepareStatement(sql); // Lỗi TC01 & TC02
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            System.out.println(rs.getString(1));
        }
        // Quên gọi rs.close() và ps.close() -> Bắt lỗi SB-TC02
    }

    // SB-TC03: NullPointerException tiềm ẩn
    public String demoTC03_NullPointer(String inputRole) {
        String role = null;
        if ("ADMIN".equals(inputRole)) {
            role = "Administrator";
        }
        // Nếu inputRole khác ADMIN, role vẫn bằng null -> Gọi .toLowerCase() sẽ sập
        return role.toLowerCase();
    }

    // SB-TC04: So sánh chuỗi Role bằng dấu ==
    public boolean demoTC04_CompareStringWithEq(String userRole) {
        return userRole == new String("ADMIN");
    }

    // SB-TC05 (Ghi vào biến static từ instance method) & SB-TC06 (Biến cục bộ dư thừa)
    public void demoTC05_TC06_ThreadAndDeadStore(String scannedId) {
        sharedTemplateId = scannedId; // Lỗi SB-TC05: Nguy cơ xung đột đa luồng khi nhiều người quét vân tay
        String unusedValidatorMessage = "Lỗi định dạng mã nhân viên"; // Lỗi SB-TC06: Dead local store
    }

    // SB-TC07 (Mất bảng mã UTF-8) & SB-TC08 (Lộ đối tượng Date nội bộ)
    public byte[] demoTC07_DefaultEncoding(String vietnameseName) {
        return vietnameseName.getBytes(); // Lỗi SB-TC07: Không chỉ định StandardCharsets.UTF_8
    }

    public Date getEnrolledDate_TC08() {
        return enrolledDate; // Lỗi SB-TC08: EI_EXPOSE_REP
    }

    // SB-TC09 (Bỏ qua Exception) & SB-TC10 (Cộng chuỗi trong vòng lặp)
    public String demoTC09_TC10_ExceptionAndLoopConcat(Connection conn, List<String> attendanceLogs) {
        try {
            conn.close();
        } catch (Exception e) {
            // Lỗi SB-TC09: Khối catch rỗng, nuốt mất lỗi
        }

        String report = "";
        for (String log : attendanceLogs) {
            report = report + log + "\n"; // Lỗi SB-TC10: Tạo rác bộ nhớ trong vòng lặp
        }
        return report;
    }
}