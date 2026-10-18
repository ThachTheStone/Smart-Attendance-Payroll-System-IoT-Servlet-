package spotbugs.testcase;

import dal.AccountDAO;
import model.Account;

/**
 * SB-TC03 (Correctness - NullPointerException) - mo phong controller/auth/LoginServlet.java.
 * Ky vong SpotBugs: NP_NULL_ON_SOME_PATH tai bugResolveHomePath (acc co the null khi username rong).
 */
public class SBTC03_NullPointer {

    // BUG: khong kiem tra acc != null truoc khi goi acc.getRole()
    public String bugResolveHomePath(AccountDAO dao, String username) {
        Account acc = null;
        if (username != null && !username.isEmpty()) {
            acc = dao.findByUsername(username);
        }
        return acc.getRole().getHomePath();
    }

    // FIX: kiem tra null, sai thong tin thi quay ve trang login
    public String fixedResolveHomePath(AccountDAO dao, String username) {
        Account acc = null;
        if (username != null && !username.isEmpty()) {
            acc = dao.findByUsername(username);
        }
        if (acc == null || acc.getRole() == null) {
            return "/login";
        }
        return acc.getRole().getHomePath();
    }
}
