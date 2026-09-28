package util;

import javax.servlet.http.HttpServletRequest;
import java.util.HashMap;
import java.util.Map;

/** Thong bao hien 1 lan sau khi redirect (Post/Redirect/Get). header.jsp se hien va xoa. */
public final class Flash {

    private Flash() {
    }

    public static void success(HttpServletRequest req, String msg) {
        set(req, "success", msg);
    }

    public static void error(HttpServletRequest req, String msg) {
        set(req, "error", msg);
    }

    private static void set(HttpServletRequest req, String type, String msg) {
        Map<String, String> flash = new HashMap<>();
        flash.put("type", type);
        flash.put("message", msg);
        req.getSession().setAttribute(Constants.SESSION_FLASH, flash);
    }
}
