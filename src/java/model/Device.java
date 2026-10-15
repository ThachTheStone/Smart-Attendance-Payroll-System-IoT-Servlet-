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
public class Device {
    private int id;
    private String name;
    private String location;
    private String apiKey;
    private LocalDateTime lastHeartbeat;

    public Device() {
    }

    public Device(int id, String name, String location, String apiKey, LocalDateTime lastHeartbeat) {
        this.id = id;
        this.name = name;
        this.location = location;
        this.apiKey = apiKey;
        this.lastHeartbeat = lastHeartbeat;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getLocation() {
        return location;
    }

    public void setLocation(String location) {
        this.location = location;
    }

    public String getApiKey() {
        return apiKey;
    }

    public void setApiKey(String apiKey) {
        this.apiKey = apiKey;
    }

    public LocalDateTime getLastHeartbeat() {
        return lastHeartbeat;
    }

    public void setLastHeartbeat(LocalDateTime lastHeartbeat) {
        this.lastHeartbeat = lastHeartbeat;
    }

    public boolean isOnline() {
        if (lastHeartbeat == null)
            return false;
        return java.time.Duration.between(lastHeartbeat, LocalDateTime.now()).getSeconds() <= 120;
    }

    public String getFormattedHeartbeat() {
        if (lastHeartbeat == null) {
            return "Chưa có tín hiệu";
        }
        return lastHeartbeat.format(java.time.format.DateTimeFormatter.ofPattern("HH:mm:ss dd/MM/yyyy"));
    }
}
