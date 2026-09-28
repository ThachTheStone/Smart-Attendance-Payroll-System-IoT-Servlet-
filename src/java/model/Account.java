package model;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * Bang Account. Mot Account co the gan voi 1 Employee (ADMIN/STAFF)
 * hoac khong gan ai (KIOSK) -> employee == null.
 */
public class Account implements Serializable {

    private static final long serialVersionUID = 1L;

    private int id;
    private Integer employeeId;
    private String username;
    private String passwordHash;
    private Role role;
    private String status;       // ACTIVE | INACTIVE
    private LocalDateTime lastLogin;
    private LocalDateTime createdAt;

    /** Thong tin nhan vien (JOIN), null voi KIOSK. */
    private Employee employee;

    public Account() {
    }

    public boolean isActive() {
        return "ACTIVE".equals(status);
    }

    /** Ten hien thi tren header: ho ten neu co, khong thi username. */
    public String getDisplayName() {
        return employee != null ? employee.getFullName() : username;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public Integer getEmployeeId() { return employeeId; }
    public void setEmployeeId(Integer employeeId) { this.employeeId = employeeId; }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public String getPasswordHash() { return passwordHash; }
    public void setPasswordHash(String passwordHash) { this.passwordHash = passwordHash; }

    public Role getRole() { return role; }
    public void setRole(Role role) { this.role = role; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public LocalDateTime getLastLogin() { return lastLogin; }
    public void setLastLogin(LocalDateTime lastLogin) { this.lastLogin = lastLogin; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public Employee getEmployee() { return employee; }
    public void setEmployee(Employee employee) { this.employee = employee; }
}
