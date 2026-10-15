package service;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import model.Attendance;
import model.Employee;

public class ScanResult {

    private boolean success;
    private String result;     // CHECK_IN, CHECK_OUT, NOT_RECOGNIZED, IGNORED
    private String status;     // ON_TIME, LATE, EARLY_LEAVE, OVERTIME, etc.
    private String message;
    private Employee employee;
    private LocalDateTime time;
    private Attendance attendance;

    public ScanResult() {
    }

    public static ScanResult notRecognized(String message) {
        ScanResult r = new ScanResult();
        r.success = false;
        r.result = "NOT_RECOGNIZED";
        r.message = message;
        r.time = LocalDateTime.now();
        return r;
    }

    public static ScanResult ignored(String message) {
        ScanResult r = new ScanResult();
        r.success = false;
        r.result = "IGNORED";
        r.message = message;
        r.time = LocalDateTime.now();
        return r;
    }

    public static ScanResult checkIn(Employee emp, LocalDateTime time, Attendance att, String message) {
        ScanResult r = new ScanResult();
        r.success = true;
        r.result = "CHECK_IN";
        r.status = att != null ? att.getStatus() : "ON_TIME";
        r.employee = emp;
        r.time = time != null ? time : LocalDateTime.now();
        r.attendance = att;
        r.message = message;
        return r;
    }

    public static ScanResult checkOut(Employee emp, LocalDateTime time, Attendance att, String message) {
        ScanResult r = new ScanResult();
        r.success = true;
        r.result = "CHECK_OUT";
        r.status = att != null ? att.getStatus() : "ON_TIME";
        r.employee = emp;
        r.time = time != null ? time : LocalDateTime.now();
        r.attendance = att;
        r.message = message;
        return r;
    }

    public boolean isSuccess() {
        return success;
    }

    public void setSuccess(boolean success) {
        this.success = success;
    }

    public String getResult() {
        return result;
    }

    public void setResult(String result) {
        this.result = result;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public Employee getEmployee() {
        return employee;
    }

    public void setEmployee(Employee employee) {
        this.employee = employee;
    }

    public LocalDateTime getTime() {
        return time;
    }

    public void setTime(LocalDateTime time) {
        this.time = time;
    }

    public Attendance getAttendance() {
        return attendance;
    }

    public void setAttendance(Attendance attendance) {
        this.attendance = attendance;
    }

    public String getFormattedTime() {
        if (time == null) return "";
        return time.format(DateTimeFormatter.ofPattern("HH:mm:ss"));
    }
}
