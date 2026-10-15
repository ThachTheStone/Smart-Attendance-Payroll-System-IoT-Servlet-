package model;

import java.time.LocalDateTime;

public class DeviceCommand {
    private int id;
    private int deviceId;
    private String type;         // 'ENROLL' or 'DELETE'
    private int templateId;
    private Integer employeeId;
    private String fingerName;
    private String status;       // 'PENDING', 'DONE', 'FAILED'
    private LocalDateTime createAt;

    public DeviceCommand() {
    }

    public DeviceCommand(int deviceId, String type, int templateId) {
        this.deviceId = deviceId;
        this.type = type;
        this.templateId = templateId;
    }

    public DeviceCommand(int deviceId, String type, int templateId, Integer employeeId, String fingerName) {
        this.deviceId = deviceId;
        this.type = type;
        this.templateId = templateId;
        this.employeeId = employeeId;
        this.fingerName = fingerName;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getDeviceId() {
        return deviceId;
    }

    public void setDeviceId(int deviceId) {
        this.deviceId = deviceId;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public int getTemplateId() {
        return templateId;
    }

    public void setTemplateId(int templateId) {
        this.templateId = templateId;
    }

    public Integer getEmployeeId() {
        return employeeId;
    }

    public void setEmployeeId(Integer employeeId) {
        this.employeeId = employeeId;
    }

    public String getFingerName() {
        return fingerName;
    }

    public void setFingerName(String fingerName) {
        this.fingerName = fingerName;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public LocalDateTime getCreateAt() {
        return createAt;
    }

    public void setCreateAt(LocalDateTime createAt) {
        this.createAt = createAt;
    }
}
