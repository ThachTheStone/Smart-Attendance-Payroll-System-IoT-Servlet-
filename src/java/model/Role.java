package model;

/** Vai tro tai khoan (FR-AUTH-01). */
public enum Role {
    ADMIN("Quản trị"),
    STAFF("Nhân viên"),
    KIOSK("Máy kiosk");

    private final String label;

    Role(String label) {
        this.label = label;
    }

    public String getLabel() {
        return label;
    }

    /** Trang chu sau khi dang nhap cua tung vai tro. */
    public String getHomePath() {
        switch (this) {
            case ADMIN: return "/admin/users";
            case STAFF: return "/staff/today";
            default:    return "/kiosk";
        }
    }

    /** Tra ve null neu chuoi khong hop le (dung khi validate form). */
    public static Role parse(String s) {
        if (s == null) return null;
        try {
            return Role.valueOf(s.trim().toUpperCase());
        } catch (IllegalArgumentException e) {
            return null;
        }
    }
}
