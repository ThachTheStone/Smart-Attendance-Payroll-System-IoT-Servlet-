package spotbugs.testcase;

/**
 * SB-TC06 (Dodgy Code - Bien chet) - mo phong util/UserValidator.java.
 * Ky vong SpotBugs: DLS_DEAD_LOCAL_STORE tai bugValidateEmployeeCode (errorMessage gan gia tri nhung khong dung).
 * Luu y: gia tri gan phai la bieu thuc (khong phai hang so) thi SpotBugs moi bao loi.
 */
public class SBTC06_DeadStore {

    // BUG: tao thong bao loi roi bo quen, nguoi dung khong biet sai o dau
    public boolean bugValidateEmployeeCode(String code) {
        if (code == null || !code.matches("NV\\d{4}")) {
            String errorMessage = "Ma nhan vien khong hop le: " + code;
            return false;
        }
        return true;
    }

    // FIX: tra thong bao loi ra ngoai (null = hop le)
    public String fixedValidateEmployeeCode(String code) {
        if (code == null || !code.matches("NV\\d{4}")) {
            return "Ma nhan vien khong hop le: " + code;
        }
        return null;
    }
}
