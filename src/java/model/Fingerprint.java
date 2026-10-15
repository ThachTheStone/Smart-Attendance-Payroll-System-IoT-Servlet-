/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

import java.time.LocalDateTime;

/**
 *
 * @author ngocthach
 */
public class Fingerprint {
    private int id;
    private int employeeId;
    private int templateId;
    private String fingerName;
    private LocalDateTime errollAt;

    public Fingerprint() {
    }

    public Fingerprint(int id, int employeeId, int templateId, String fingerName, LocalDateTime errollAt) {
        this.id = id;
        this.employeeId = employeeId;
        this.templateId = templateId;
        this.fingerName = fingerName;
        this.errollAt = errollAt;
    }

    public Fingerprint(int employeeId, int templateId, String fingerName) {
        this.employeeId = employeeId;
        this.templateId = templateId;
        this.fingerName = fingerName;
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

    public int getTemplateId() {
        return templateId;
    }

    public void setTemplateId(int templateId) {
        this.templateId = templateId;
    }

    public String getFingerName() {
        return fingerName;
    }

    public void setFingerName(String fingerName) {
        this.fingerName = fingerName;
    }

    public LocalDateTime getErrollAt() {
        return errollAt;
    }

    public void setErrollAt(LocalDateTime errollAt) {
        this.errollAt = errollAt;
    }
    
    
    
}
