package spotbugs.testcase;

import java.util.Date;

/**
 * SB-TC08 (Malicious Code - Lo tham chieu noi bo) - mo phong model/Employee.java.
 * Ky vong SpotBugs: EI_EXPOSE_REP tai getHireDate, EI_EXPOSE_REP2 tai setHireDate.
 * Lop FixedEmployee ben duoi khong duoc bao loi.
 */
public class SBTC08_ExposeDate {

    // BUG: tra ve / nhan vao truc tiep doi tuong Date (mutable)
    // -> ben ngoai goi emp.getHireDate().setTime(0) la sua duoc ngay vao lam cua nhan vien
    private Date hireDate;

    public Date getHireDate() {
        return hireDate;
    }

    public void setHireDate(Date hireDate) {
        this.hireDate = hireDate;
    }

    // FIX: sao chep phong thu (defensive copy) khi doc va ghi
    public static class FixedEmployee {

        private Date hireDate;

        public Date getHireDate() {
            return hireDate == null ? null : new Date(hireDate.getTime());
        }

        public void setHireDate(Date hireDate) {
            this.hireDate = hireDate == null ? null : new Date(hireDate.getTime());
        }
    }
}
