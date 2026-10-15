/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

import java.time.LocalDateTime;

public class AttendanceLog {
    private long id;
    private Integer employeeId;     // Integer (can be null for unrecognized fingers)
    private int deviceId;
    private LocalDateTime eventTime;
    private Integer confidenceScore; // Integer (can be null)
    private String result;          // 'CHECK_IN', 'CHECK_OUT', 'NOT_RECOGNIZED', 'IGNORED'
    private String reason;          // e.g. "Duplicate scan within 60s" or "Confidence too low"

    public AttendanceLog() {
    }

    public AttendanceLog(Integer employeeId, int deviceId, Integer confidenceScore, String result, String reason) {
        this.employeeId = employeeId;
        this.deviceId = deviceId;
        this.confidenceScore = confidenceScore;
        this.result = result;
        this.reason = reason;
        this.eventTime = LocalDateTime.now();
    }

    public AttendanceLog(Integer employeeId, int deviceId, LocalDateTime eventTime, Integer confidenceScore, String result, String reason) {
        this.employeeId = employeeId;
        this.deviceId = deviceId;
        this.eventTime = eventTime;
        this.confidenceScore = confidenceScore;
        this.result = result;
        this.reason = reason;
    }

    // Joined / presentation fields
    private String employeeName;
    private String employeeCode;
    private String department;
    private String deviceName;

    // Getters and Setters for all fields...
    public long getId() { return id; }
    public void setId(long id) { this.id = id; }

    public Integer getEmployeeId() { return employeeId; }
    public void setEmployeeId(Integer employeeId) { this.employeeId = employeeId; }

    public int getDeviceId() { return deviceId; }
    public void setDeviceId(int deviceId) { this.deviceId = deviceId; }

    public LocalDateTime getEventTime() { return eventTime; }
    public void setEventTime(LocalDateTime eventTime) { this.eventTime = eventTime; }

    public Integer getConfidenceScore() { return confidenceScore; }
    public void setConfidenceScore(Integer confidenceScore) { this.confidenceScore = confidenceScore; }

    public String getResult() { return result; }
    public void setResult(String result) { this.result = result; }

    public String getReason() { return reason; }
    public void setReason(String reason) { this.reason = reason; }

    public String getEmployeeName() { return employeeName; }
    public void setEmployeeName(String employeeName) { this.employeeName = employeeName; }

    public String getEmployeeCode() { return employeeCode; }
    public void setEmployeeCode(String employeeCode) { this.employeeCode = employeeCode; }

    public String getDepartment() { return department; }
    public void setDepartment(String department) { this.department = department; }

    public String getDeviceName() { return deviceName; }
    public void setDeviceName(String deviceName) { this.deviceName = deviceName; }

    public String getFormattedTime() {
        if (eventTime == null) return "";
        return eventTime.format(java.time.format.DateTimeFormatter.ofPattern("HH:mm:ss"));
    }
}

