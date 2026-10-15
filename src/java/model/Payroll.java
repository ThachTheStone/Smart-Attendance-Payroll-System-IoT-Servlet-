package model;

import java.math.BigDecimal;

/**
 * Monthly Payroll batch model (FR-PAY-01, 04).
 */
public class Payroll {

    private int id;
    private int month;
    private int year;
    private String status; // 'DRAFT', 'LOCKED'

    // Presentation helpers
    private int totalEmployees;
    private BigDecimal totalNetSalary;

    public Payroll() {
        this.status = "DRAFT";
    }

    public Payroll(int month, int year, String status) {
        this.month = month;
        this.year = year;
        this.status = status != null ? status : "DRAFT";
    }

    public Payroll(int id, int month, int year, String status) {
        this.id = id;
        this.month = month;
        this.year = year;
        this.status = status != null ? status : "DRAFT";
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
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

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public boolean isLocked() {
        return "LOCKED".equalsIgnoreCase(status);
    }

    public int getTotalEmployees() {
        return totalEmployees;
    }

    public void setTotalEmployees(int totalEmployees) {
        this.totalEmployees = totalEmployees;
    }

    public BigDecimal getTotalNetSalary() {
        return totalNetSalary;
    }

    public void setTotalNetSalary(BigDecimal totalNetSalary) {
        this.totalNetSalary = totalNetSalary;
    }

    public String getPeriodLabel() {
        return String.format("Tháng %02d/%d", month, year);
    }
}
