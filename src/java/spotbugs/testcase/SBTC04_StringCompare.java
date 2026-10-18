package spotbugs.testcase;

import javax.servlet.http.HttpSession;

/**
 * SB-TC04 (Bad Practice - So sanh chuoi bang ==) - mo phong filter/AuthFilter.java.
 * Ky vong SpotBugs: ES_COMPARING_STRINGS_WITH_EQ tai bugIsAdmin.
 */
public class SBTC04_StringCompare {

    // BUG: so sanh tham chieu, role lay tu session la object khac nen co the luon false
    public boolean bugIsAdmin(HttpSession session) {
        String role = (String) session.getAttribute("role");
        return role == "ADMIN";
    }

    // FIX: so sanh noi dung, dat hang so ben trai de an toan khi role null
    public boolean fixedIsAdmin(HttpSession session) {
        String role = (String) session.getAttribute("role");
        return "ADMIN".equals(role);
    }
}
