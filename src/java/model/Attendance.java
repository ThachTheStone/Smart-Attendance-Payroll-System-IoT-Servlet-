package model;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;

public class Attendance {
    private int id;
    private int employeeId;
    private LocalDate workDate;
    private int shiftId;
    private LocalDateTime checkIn;
    private LocalDateTime checkOut;
    private int workedMinutes;
    private String status; // ON_TIME, LATE, EARLY_LEAVE, MISSING_CHECKOUT, ABSENT, OVERTIME

    // Joined fields for display
    private String employeeCode;
    private String employeeName;
    private String department;
    private String shiftName;
    private LocalTime shiftStartTime;
    private LocalTime shiftEndTime;

    public Attendance() {
    }

    public Attendance(int employeeId, LocalDate workDate, int shiftId, LocalDateTime checkIn, String status) {
        this.employeeId = employeeId;
        this.workDate = workDate;
        this.shiftId = shiftId;
        this.checkIn = checkIn;
        this.status = status;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getEmployeeId() {
        return employeeId;
    }

    public void setEmployeeId(int employeeId) {
        this.employeeId = employeeId;
    }

    public LocalDate getWorkDate() {
        return workDate;
    }

    public void setWorkDate(LocalDate workDate) {
        this.workDate = workDate;
    }

    public int getShiftId() {
        return shiftId;
    }

    public void setShiftId(int shiftId) {
        this.shiftId = shiftId;
    }

    public LocalDateTime getCheckIn() {
        return checkIn;
    }

    public void setCheckIn(LocalDateTime checkIn) {
        this.checkIn = checkIn;
    }

    public LocalDateTime getCheckOut() {
        return checkOut;
    }

    public void setCheckOut(LocalDateTime checkOut) {
        this.checkOut = checkOut;
    }

    public int getWorkedMinutes() {
        return workedMinutes;
    }

    public void setWorkedMinutes(int workedMinutes) {
        this.workedMinutes = workedMinutes;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
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

    public String getShiftName() {
        return shiftName;
    }

    public void setShiftName(String shiftName) {
        this.shiftName = shiftName;
    }

    public LocalTime getShiftStartTime() {
        return shiftStartTime;
    }

    public void setShiftStartTime(LocalTime shiftStartTime) {
        this.shiftStartTime = shiftStartTime;
    }

    public LocalTime getShiftEndTime() {
        return shiftEndTime;
    }

    public void setShiftEndTime(LocalTime shiftEndTime) {
        this.shiftEndTime = shiftEndTime;
    }

    public String getStatusLabel() {
        if (status == null) return "Chưa rõ";
        switch (status) {
            case "ON_TIME": return "Đúng giờ";
            case "LATE": return "Đi muộn";
            case "EARLY_LEAVE": return "Về sớm";
            case "MISSING_CHECKOUT": return "Quên checkout";
            case "ABSENT": return "Vắng mặt";
            case "OVERTIME": return "Tăng ca";
            default: return status;
        }
    }

    public String getStatusBadgeClass() {
        if (status == null) return "secondary";
        switch (status) {
            case "ON_TIME": return "success";
            case "LATE": return "warning";
            case "EARLY_LEAVE": return "warning";
            case "MISSING_CHECKOUT": return "danger";
            case "ABSENT": return "secondary";
            case "OVERTIME": return "primary";
            default: return "secondary";
        }
    }

    public String getFormattedCheckInTime() {
        if (checkIn == null) return "--:--";
        return checkIn.format(java.time.format.DateTimeFormatter.ofPattern("HH:mm:ss"));
    }

    public String getFormattedCheckIn() {
        return getFormattedCheckInTime();
    }

    public String getFormattedCheckOutTime() {
        if (checkOut == null) return "--:--";
        return checkOut.format(java.time.format.DateTimeFormatter.ofPattern("HH:mm:ss"));
    }

    public String getFormattedCheckOut() {
        return getFormattedCheckOutTime();
    }

    public String getFormattedCheckInDateTime() {
        if (checkIn == null) return "";
        return checkIn.format(java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm"));
    }

    public String getFormattedCheckOutDateTime() {
        if (checkOut == null) return "";
        return checkOut.format(java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm"));
    }

    public String getFormattedWorkedHours() {
        int hours = workedMinutes / 60;
        int mins = workedMinutes % 60;
        if (hours == 0 && mins == 0) return "0h";
        return hours + "h " + (mins > 0 ? mins + "m" : "");
    }
}
