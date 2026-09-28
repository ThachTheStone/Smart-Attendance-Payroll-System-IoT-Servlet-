package util;

import org.mindrot.jbcrypt.BCrypt;

/** Hash va kiem tra mat khau bang BCrypt (FR-AUTH-02). Khong bao gio luu mat khau thuong. */
public final class PasswordUtil {

    private static final int COST = 10;

    private PasswordUtil() {
    }

    public static String hash(String plain) {
        return BCrypt.hashpw(plain, BCrypt.gensalt(COST));
    }

    public static boolean verify(String plain, String hash) {
        if (plain == null || hash == null || !hash.startsWith("$2")) {
            return false;
        }
        try {
            return BCrypt.checkpw(plain, hash);
        } catch (IllegalArgumentException e) {
            return false;
        }
    }
}
