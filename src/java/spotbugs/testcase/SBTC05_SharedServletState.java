package spotbugs.testcase;

import java.io.IOException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * SB-TC05 (Multithreading - Loi da luong trong Servlet) - mo phong servlet nhan du lieu quet van tay.
 * Servlet chi co 1 instance dung chung cho moi request: nhieu nhan vien quet cung luc se ghi de lastScannedId.
 * Ky vong SpotBugs: ST_WRITE_TO_STATIC_FROM_INSTANCE_METHOD tai doPost.
 * (Khong gan @WebServlet de lop nay khong duoc deploy thanh URL that.)
 */
public class SBTC05_SharedServletState extends HttpServlet {

    private static final long serialVersionUID = 1L;

    // BUG: trang thai cua 1 lan quet luu o bien static dung chung
    private static String lastScannedId;

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws IOException {
        lastScannedId = req.getParameter("fingerprintId");
        // ... xu ly cham cong mat vai ms, request khac co the ghi de lastScannedId o day ...
        log("Cham cong cho van tay: " + lastScannedId);
        res.setStatus(HttpServletResponse.SC_OK);
    }

    // FIX: dung bien cuc bo - moi request (moi thread) co ban sao rieng
    protected void fixedDoPost(HttpServletRequest req, HttpServletResponse res) throws IOException {
        String scannedId = req.getParameter("fingerprintId");
        log("Cham cong cho van tay: " + scannedId);
        res.setStatus(HttpServletResponse.SC_OK);
    }
}
