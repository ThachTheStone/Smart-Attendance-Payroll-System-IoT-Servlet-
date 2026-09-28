package model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/** Bang Employee (FR-EMP-01, FR-EMP-02). */
public class Employee implements Serializable {

    private static final long serialVersionUID = 1L;

    private int id;
    private String code;
    private String fullName;
    private String email;
    private String phone;
    private String department;
    private String position;
    private String photo;
    private String salaryType;   // MONTHLY | HOURLY
    private BigDecimal baseSalary;
    private String status;       // ACTIVE | INACTIVE
    private LocalDateTime createdAt;

    public Employee() {
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public String getDepartment() { return department; }
    public void setDepartment(String department) { this.department = department; }

    public String getPosition() { return position; }
    public void setPosition(String position) { this.position = position; }

    public String getPhoto() { return photo; }
    public void setPhoto(String photo) { this.photo = photo; }

    public String getSalaryType() { return salaryType; }
    public void setSalaryType(String salaryType) { this.salaryType = salaryType; }

    public BigDecimal getBaseSalary() { return baseSalary; }
    public void setBaseSalary(BigDecimal baseSalary) { this.baseSalary = baseSalary; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
