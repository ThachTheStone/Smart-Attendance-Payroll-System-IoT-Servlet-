package model;

import java.math.BigDecimal;
import java.math.RoundingMode;

/**
 * Individual employee payslip details (FR-PAY-02, Section 5).
 */
public class PayrollDetail {

    private int payrollId;
    private int employeeId;
    private BigDecimal regularHours;
    private BigDecimal otWeekdayHours;
    private BigDecimal otWeekendHours;
    private BigDecimal otHolidayHours;
    private BigDecimal nightHours;
    private BigDecimal nightOtHours;
    private int lateMinutes;
    private BigDecimal penalty;
    private BigDecimal netSalary;
    private String emailStatus; // SENT, FAILED, null

    // Joined Employee fields
    private String employeeCode;
    private String employeeName;
    private String employeeEmail;
    private String department;
    private String position;
    private String salaryType;
    private BigDecimal baseSalary;

    // Joined Payroll fields (for display & export)
    private int month;
    private int year;

    // Computed breakdown fields (for payslip view & PDF)
    private BigDecimal hourlyRate;
    private BigDecimal regularPay;
    private BigDecimal otWeekdayPay;
    private BigDecimal otWeekendPay;
    private BigDecimal otHolidayPay;
    private BigDecimal nightAllowance;
    private BigDecimal nightOtBonus;

    public PayrollDetail() {
        this.regularHours = BigDecimal.ZERO;
        this.otWeekdayHours = BigDecimal.ZERO;
        this.otWeekendHours = BigDecimal.ZERO;
        this.otHolidayHours = BigDecimal.ZERO;
        this.nightHours = BigDecimal.ZERO;
        this.nightOtHours = BigDecimal.ZERO;
        this.penalty = BigDecimal.ZERO;
        this.netSalary = BigDecimal.ZERO;
    }

    public int getPayrollId() {
        return payrollId;
    }

    public void setPayrollId(int payrollId) {
        this.payrollId = payrollId;
    }

    public int getEmployeeId() {
        return employeeId;
    }

    public void setEmployeeId(int employeeId) {
        this.employeeId = employeeId;
    }

    public BigDecimal getRegularHours() {
        return regularHours;
    }

    public void setRegularHours(BigDecimal regularHours) {
        this.regularHours = regularHours;
    }

    public BigDecimal getOtWeekdayHours() {
        return otWeekdayHours;
    }

    public void setOtWeekdayHours(BigDecimal otWeekdayHours) {
        this.otWeekdayHours = otWeekdayHours;
    }

    public BigDecimal getOtWeekendHours() {
        return otWeekendHours;
    }

    public void setOtWeekendHours(BigDecimal otWeekendHours) {
        this.otWeekendHours = otWeekendHours;
    }

    public BigDecimal getOtHolidayHours() {
        return otHolidayHours;
    }

    public void setOtHolidayHours(BigDecimal otHolidayHours) {
        this.otHolidayHours = otHolidayHours;
    }

    public BigDecimal getNightHours() {
        return nightHours;
    }

    public void setNightHours(BigDecimal nightHours) {
        this.nightHours = nightHours;
    }

    public BigDecimal getNightOtHours() {
        return nightOtHours;
    }

    public void setNightOtHours(BigDecimal nightOtHours) {
        this.nightOtHours = nightOtHours;
    }

    public int getLateMinutes() {
        return lateMinutes;
    }

    public void setLateMinutes(int lateMinutes) {
        this.lateMinutes = lateMinutes;
    }

    public BigDecimal getPenalty() {
        return penalty;
    }

    public void setPenalty(BigDecimal penalty) {
        this.penalty = penalty;
    }

    public BigDecimal getNetSalary() {
        return netSalary;
    }

    public void setNetSalary(BigDecimal netSalary) {
        this.netSalary = netSalary;
    }

    public String getEmailStatus() {
        return emailStatus;
    }

    public void setEmailStatus(String emailStatus) {
        this.emailStatus = emailStatus;
    }

    public String getEmployeeCode() {
        return employeeCode;
    }

    public void setEmployeeCode(String employeeCode) {
        this.employeeCode = employeeCode;
    }

    public String getEmployeeName() {
        return employeeName;
    }

    public void setEmployeeName(String employeeName) {
        this.employeeName = employeeName;
    }

    public String getDepartment() {
        return department;
    }

    public void setDepartment(String department) {
        this.department = department;
    }

    public String getPosition() {
        return position;
    }

    public void setPosition(String position) {
        this.position = position;
    }

    public String getSalaryType() {
        return salaryType;
    }

    public void setSalaryType(String salaryType) {
        this.salaryType = salaryType;
    }

    public BigDecimal getBaseSalary() {
        return baseSalary;
    }

    public void setBaseSalary(BigDecimal baseSalary) {
        this.baseSalary = baseSalary;
    }

    public BigDecimal getHourlyRate() {
        return hourlyRate;
    }

    public void setHourlyRate(BigDecimal hourlyRate) {
        this.hourlyRate = hourlyRate;
    }

    public BigDecimal getRegularPay() {
        return regularPay;
    }

    public void setRegularPay(BigDecimal regularPay) {
        this.regularPay = regularPay;
    }

    public BigDecimal getOtWeekdayPay() {
        return otWeekdayPay;
    }

    public void setOtWeekdayPay(BigDecimal otWeekdayPay) {
        this.otWeekdayPay = otWeekdayPay;
    }

    public BigDecimal getOtWeekendPay() {
        return otWeekendPay;
    }

    public void setOtWeekendPay(BigDecimal otWeekendPay) {
        this.otWeekendPay = otWeekendPay;
    }

    public BigDecimal getOtHolidayPay() {
        return otHolidayPay;
    }

    public void setOtHolidayPay(BigDecimal otHolidayPay) {
        this.otHolidayPay = otHolidayPay;
    }

    public BigDecimal getNightAllowance() {
        return nightAllowance;
    }

    public void setNightAllowance(BigDecimal nightAllowance) {
        this.nightAllowance = nightAllowance;
    }

    public BigDecimal getNightOtBonus() {
        return nightOtBonus;
    }

    public void setNightOtBonus(BigDecimal nightOtBonus) {
        this.nightOtBonus = nightOtBonus;
    }

    public BigDecimal getTotalOvertimeHours() {
        BigDecimal sum = BigDecimal.ZERO;
        if (otWeekdayHours != null) sum = sum.add(otWeekdayHours);
        if (otWeekendHours != null) sum = sum.add(otWeekendHours);
        if (otHolidayHours != null) sum = sum.add(otHolidayHours);
        return sum;
    }

    public BigDecimal getTotalOvertimePay() {
        BigDecimal sum = BigDecimal.ZERO;
        if (otWeekdayPay != null) sum = sum.add(otWeekdayPay);
        if (otWeekendPay != null) sum = sum.add(otWeekendPay);
        if (otHolidayPay != null) sum = sum.add(otHolidayPay);
        return sum;
    }

    public String getEmployeeEmail() {
        return employeeEmail;
    }

    public void setEmployeeEmail(String employeeEmail) {
        this.employeeEmail = employeeEmail;
    }

    public int getMonth() {
        return month;
    }

    public void setMonth(int month) {
        this.month = month;
    }

    public int getYear() {
        return year;
    }

    public void setYear(int year) {
        this.year = year;
    }
}
