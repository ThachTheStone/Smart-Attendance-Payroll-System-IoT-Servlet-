package util;

import java.util.Arrays;
import java.util.Collections;
import java.util.List;

/** Hang so dung chung. */
public final class Constants {

    private Constants() {
    }

    /** Ten attribute luu tai khoan dang dang nhap trong session. */
    public static final String SESSION_USER = "account";

    /** Ten attribute thong bao 1 lan (flash message) trong session. */
    public static final String SESSION_FLASH = "flash";

    public static final List<String> DEPARTMENTS = Collections.unmodifiableList(Arrays.asList(
            "Executive Board", "Human Resources", "Accounting", "Production", "Warehouse", "Security"));

    public static final List<String> SALARY_TYPES = Collections.unmodifiableList(Arrays.asList("MONTHLY", "HOURLY"));
}
