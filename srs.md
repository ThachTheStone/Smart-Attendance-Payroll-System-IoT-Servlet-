# **SRS – Smart Attendance & Payroll System (IoT \+ Servlet)**

Sep 23, 2026 · @Someonesd1. Overview

The system records employee attendance with a fingerprint-based IoT device and automatically calculates monthly salary using configurable Vietnamese labor rules. A web portal gives staff and admins real-time visibility.

**Purpose:** prevent attendance fraud ("buddy punching"), calculate pay fairly and transparently, and let everyone see attendance live.

**In scope:**

* An IoT device (ESP32-WROOM-32 \+ AS608 fingerprint sensor) that identifies employees by fingerprint  
* A kiosk page running full-screen in a browser on a laptop, acting as the device's display  
* A Java Servlet/JSP web application with a database, used by Staff and Admin  
* Shift scheduling, an overtime and penalty rules engine, monthly PDF payslips sent by email

**Out of scope:** personal income tax, social insurance deductions, bank transfers, and a mobile app.

## **2\. Actors**

| Actor | Description |
| :---- | :---- |
| Staff | Checks in and out with a fingerprint; views own attendance, hours worked and payslips |
| Admin (HR/Manager) | Manages employees, fingerprints, shifts, rules and payroll; monitors the live dashboard |
| IoT Device | Scans fingerprints and sends events to the server |
| Kiosk (laptop screen) | Shows scan results and enrollment instructions to the person at the device |
| System (scheduler) | Runs automatic jobs such as flagging missing check-outs and checking device heartbeats |

## **3\. Hardware and System Architecture**

The device uses only an ESP32-WROOM-32 and an AS608 fingerprint sensor; all messages appear on a laptop screen.

| Component | Purpose |
| :---- | :---- |
| ESP32-WROOM-32 | Main controller with WiFi; reads the sensor and talks to the server |
| AS608 fingerprint sensor | Identifies the employee (1:N search against stored templates) |
| Laptop screen | Shows all messages through the kiosk web page |
| ESP32 onboard LED (GPIO2) | Optional basic status, e.g. blinking when there is no WiFi |

**Wiring:** AS608 TX → GPIO16 (RX2), AS608 RX → GPIO17 (TX2), plus power and GND. Check the module label for its supply voltage (most AS608 boards use 3.3V).

flowchart LR  
  A\[Finger\] \--\> B\[AS608 sensor\]  
  B \--\>|UART| C\[ESP32-WROOM-32\]  
  C \--\>|WiFi HTTP POST| D\[Servlet server\<br/\>Tomcat\]  
  D \--\> E\[(Database)\]  
  D \--\>|SSE| F\[Kiosk page\<br/\>laptop screen\]  
  D \--\>|SSE| G\[Admin dashboard\]  
  D \--\> H\[Staff portal\]  
The ESP32 and the laptop must be on the same WiFi network. The server needs a fixed IP address (or one set in a config line in the firmware) so the ESP32 always knows where to send data.

## **4\. Functional Requirements**

### **4.1 IoT Device (FR-IOT)**

| ID | Requirement |
| :---- | :---- |
| FR-IOT-01 | The device continuously waits for a finger and, when one is detected, searches the AS608's stored templates. |
| FR-IOT-02 | On a match, the device sends the template ID, match confidence score and device ID to the server as JSON over HTTP POST, with an API key in the header. |
| FR-IOT-03 | On no match, the device sends a "not recognized" event so the kiosk can show it. |
| FR-IOT-04 | The server rejects matches below a configurable confidence threshold (default 50\) and treats them as "not recognized". |
| FR-IOT-05 | The server, not the device, decides whether an event is a check-in or a check-out. |
| FR-IOT-06 | The device sends a heartbeat every 60 seconds. |
| FR-IOT-07 | The device polls the server every 2 seconds for commands (fingerprint enrollment and deletion). |
| FR-IOT-08 | Only template IDs leave the device; fingerprint images and templates stay inside the AS608. |

### **4.2 Kiosk Screen (FR-KIOSK)**

| ID | Requirement |
| :---- | :---- |
| FR-KIOSK-01 | The kiosk page (/kiosk) runs full-screen on the laptop and receives device events in real time via Server-Sent Events. |
| FR-KIOSK-02 | The idle state shows the current time and "Place your finger on the sensor". |
| FR-KIOSK-03 | A successful scan shows the employee's name and photo, check-in or check-out, the time, status (e.g. "Late 6 minutes") and hours worked today, then returns to idle after 5 seconds. |
| FR-KIOSK-04 | A failed scan shows "Fingerprint not recognized, please try again" in red. |
| FR-KIOSK-05 | During enrollment it guides the person: "Place your finger", "Remove your finger", "Place the same finger again", "Enrolled successfully". |
| FR-KIOSK-06 | A "Device offline" banner appears when the device heartbeat stops. |
| FR-KIOSK-07 | The kiosk page requires a kiosk account login. |

### **4.3 Fingerprint Enrollment (FR-ENROLL), Admin only**

| ID | Requirement |
| :---- | :---- |
| FR-ENROLL-01 | The admin clicks "Enroll fingerprint" on an employee's profile; the server creates an enrollment command with a free template ID. |
| FR-ENROLL-02 | The ESP32 picks up the command, captures the finger twice, stores the template in the AS608 and reports success or failure. |
| FR-ENROLL-03 | On success, the server links the template ID to the employee. Each employee can enroll up to 2 fingers. |
| FR-ENROLL-04 | Deactivating an employee sends a delete command that removes their templates from the sensor. |
| FR-ENROLL-05 | The system warns the admin when the sensor nears its storage limit (about 162 templates on most AS608 modules). |

### **4.4 Authentication and Accounts (FR-AUTH)**

| ID | Requirement |
| :---- | :---- |
| FR-AUTH-01 | Staff, Admin and Kiosk accounts log in with a username and password. |
| FR-AUTH-02 | Passwords are stored hashed with BCrypt. |
| FR-AUTH-03 | A Servlet Filter enforces role-based access; staff cannot open admin pages. |
| FR-AUTH-04 | Users can change their password; admins can reset a staff member's password. |

### **4.5 Employee Management (FR-EMP), Admin only**

| ID | Requirement |
| :---- | :---- |
| FR-EMP-01 | CRUD for employees: code, name, email, phone, department, position, photo, status (active/inactive). |
| FR-EMP-02 | Each employee has a salary type (monthly or hourly) and a base salary amount. |
| FR-EMP-03 | Each employee is linked to 1–2 fingerprint template IDs through enrollment. |

### **4.6 Shift Scheduling (FR-SHIFT)**

| ID | Requirement |
| :---- | :---- |
| FR-SHIFT-01 | Admins define shifts with name, start time, end time and break minutes. Defaults: Morning 06:00–14:00, Afternoon 14:00–22:00, Night 22:00–06:00. |
| FR-SHIFT-02 | Admins assign shifts to employees by date or by weekly pattern. |
| FR-SHIFT-03 | A night shift that crosses midnight belongs to the date it starts. |
| FR-SHIFT-04 | Staff can view their schedule for the current and next week. |

### **4.7 Attendance (FR-ATT)**

| ID | Requirement |
| :---- | :---- |
| FR-ATT-01 | Every device event is saved as a raw log, whether it succeeded or failed. |
| FR-ATT-02 | The system builds one daily record per employee per shift: check-in, check-out and worked minutes. |
| FR-ATT-03 | Each record gets a status: On time, Late, Early leave, Missing check-out, Absent or Overtime. |
| FR-ATT-04 | With no check-out 2 hours after shift end, the record is marked "Missing check-out" and shown on the admin dashboard. |
| FR-ATT-05 | Admins can correct a record but must enter a reason; every correction goes to an audit log. |
| FR-ATT-06 | A second scan from the same employee within 60 seconds is ignored. |

### **4.8 Salary Rules Engine (FR-RULE)**

| ID | Requirement |
| :---- | :---- |
| FR-RULE-01 | All rules are stored in a database table and editable by the admin; nothing is hardcoded. |
| FR-RULE-02 | Default overtime multipliers: 150% on normal working days, 200% on weekly days off, 300% on public holidays. |
| FR-RULE-03 | Night work (22:00–06:00) earns at least 30% extra; overtime at night earns an additional 20%. |
| FR-RULE-04 | Lateness within a configurable grace period (default 5 minutes) is not penalized. |
| FR-RULE-05 | The late/early-leave penalty is either an amount per minute or a deduction of unworked minutes. |
| FR-RULE-06 | Admins manage a public holiday calendar (date and name). |
| FR-RULE-07 | Rule changes apply only to payroll periods that are not locked. |

### **4.9 Payroll and Payslip (FR-PAY)**

| ID | Requirement |
| :---- | :---- |
| FR-PAY-01 | Admins generate payroll for a selected month for all or selected employees. |
| FR-PAY-02 | Each payslip shows regular hours, overtime hours by type, night hours, late/early minutes and every amount (see section 5). |
| FR-PAY-03 | Payroll cannot be generated while the month has unresolved "Missing check-out" records; the system lists them. |
| FR-PAY-04 | Admins review, then lock the payroll; locked payroll cannot be recalculated. |
| FR-PAY-05 | The system exports each payslip as a PDF. |
| FR-PAY-06 | Admins email payslips individually or in bulk; the send status (sent/failed) is recorded. |
| FR-PAY-07 | Staff can view and download their payslips from locked months. |

### **4.10 Staff Portal (FR-STAFF)**

| ID | Requirement |
| :---- | :---- |
| FR-STAFF-01 | A "Today" panel shows today's shift, check-in time, hours worked so far (live counter), time left until shift end and current status (e.g. "Working – 5h 12m"). |
| FR-STAFF-02 | A timeline shows today's check-in, check-out and overtime periods. |
| FR-STAFF-03 | A monthly summary shows total hours, overtime hours, number of late arrivals and estimated salary so far. |
| FR-STAFF-04 | Attendance history can be filtered by date range, with each day's status. |

### **4.11 Admin Live Dashboard (FR-DASH)**

| ID | Requirement |
| :---- | :---- |
| FR-DASH-01 | Shows who is currently checked in, with check-in times. |
| FR-DASH-02 | Shows today's counters: present, late, absent, on overtime. |
| FR-DASH-03 | A live feed shows the latest check-in/out events as they happen. |
| FR-DASH-04 | Security alerts appear for 5 or more unrecognized scans within 1 minute, and for low-confidence matches. |
| FR-DASH-05 | Device status shows online or offline based on the heartbeat. |
| FR-DASH-06 | The dashboard updates without a page reload, via Server-Sent Events (or AJAX polling every 5 seconds as a fallback). |

## **5\. Salary Calculation**

Net salary is regular pay plus overtime and night allowances, minus penalties. Standard hours per month default to 208 (26 days × 8 hours) and are editable.

Hourly rate     \= Base monthly salary / Standard hours per month  
Regular pay     \= Regular hours × Hourly rate  
Overtime pay    \= Σ (OT hours of each type × Hourly rate × multiplier)  
Night allowance \= Night hours × Hourly rate × 30%  
Night OT bonus  \= Night OT hours × Hourly rate × 20%  
Penalty         \= Late/early minutes beyond grace × penalty rate  
Net salary      \= Regular pay \+ Overtime pay \+ Night allowance \+ Night OT bonus − Penalty  
**Worked example:** base salary 8,320,000 VND (hourly rate 40,000 VND); 200 regular hours, 10 weekday overtime hours, 8 night hours, and 20 minutes late beyond the grace period at 1,000 VND per minute.

| Item | Calculation | Amount (VND) |
| :---- | :---- | :---- |
| Regular pay | 200 × 40,000 | 8,000,000 |
| Overtime pay | 10 × 40,000 × 1.5 | 600,000 |
| Night allowance | 8 × 40,000 × 0.3 | 96,000 |
| Penalty | 20 × 1,000 | −20,000 |
| **Net salary** |  | **8,676,000** |

## **6\. Non-Functional Requirements**

| ID | Requirement |
| :---- | :---- |
| NFR-01 | The kiosk shows the scan result within 2 seconds of the finger being placed, on a normal network. |
| NFR-02 | Every device request carries a valid API key; invalid requests are rejected and logged. |
| NFR-03 | All SQL queries use PreparedStatement to prevent SQL injection. |
| NFR-04 | The staff and admin pages work on desktop and mobile browsers. |
| NFR-05 | The system supports at least 50 employees without slowdown. |
| NFR-06 | The server clock is the official time for all records; the ESP32 syncs via NTP. |
| NFR-07 | The code follows MVC: Servlets as controllers, JSP as views, a DAO layer for database access. |

## **7\. Database Entities**

| Table | Key fields |
| :---- | :---- |
| Employee | id, code, name, email, phone, department, position, photo, salary\_type, base\_salary, status |
| Account | id, employee\_id, username, password\_hash, role (STAFF/ADMIN/KIOSK) |
| Fingerprint | id, employee\_id, template\_id, finger\_name, enrolled\_at |
| Device | id, name, location, api\_key, last\_heartbeat |
| DeviceCommand | id, device\_id, type (ENROLL/DELETE), template\_id, status (PENDING/DONE/FAILED), created\_at |
| Shift | id, name, start\_time, end\_time, break\_minutes |
| ShiftAssignment | id, employee\_id, shift\_id, work\_date |
| AttendanceLog | id, employee\_id, device\_id, event\_time, confidence\_score, result, reason |
| Attendance | id, employee\_id, work\_date, shift\_id, check\_in, check\_out, worked\_minutes, status |
| SalaryRule | rule\_key, value, description |
| Holiday | date, name |
| Payroll | id, month, year, status (DRAFT/LOCKED) |
| PayrollDetail | payroll\_id, employee\_id, regular\_hours, ot\_hours per type, night\_hours, penalty, net\_salary, email\_status |
| AuditLog | id, admin\_id, table\_name, record\_id, old\_value, new\_value, reason, time |

## **8\. Servlet Endpoints**

| Endpoint | Method | Used by |
| :---- | :---- | :---- |
| /api/device/scan | POST | Device: template ID \+ confidence score |
| /api/device/heartbeat | POST | Device |
| /api/device/command | GET | Device polls for enroll/delete commands |
| /api/device/command/result | POST | Device reports the command result |
| /kiosk | GET | Laptop kiosk page |
| /kiosk/stream | GET | Kiosk live feed (SSE) |
| /login, /logout | GET/POST | All users |
| /staff/today, /staff/history, /staff/schedule, /staff/payslips | GET | Staff |
| /admin/employees, /admin/employees/enroll | GET/POST | Admin |
| /admin/shifts, /admin/rules, /admin/holidays | GET/POST | Admin |
| /admin/attendance | GET/POST | Admin: view and correct |
| /admin/payroll | GET/POST | Admin: generate, lock, export PDF, email |
| /admin/dashboard, /admin/dashboard/stream | GET | Admin: live dashboard (SSE) |

## **9\. Technology Stack**

| Layer | Technology |
| :---- | :---- |
| Backend | Java Servlet/JSP on Apache Tomcat, JDBC with a DAO layer |
| Database | SQL Server or MySQL |
| Real-time | Server-Sent Events from a Servlet |
| PDF | OpenPDF |
| Email | Jakarta Mail via Gmail SMTP (App Password) |
| Password hashing | jBCrypt |
| Device firmware | Arduino IDE for ESP32; libraries: Adafruit Fingerprint Sensor, ArduinoJson, HTTPClient, WiFi |

## **10\. Key Test Scenarios**

| \# | Scenario | Expected result |
| :---- | :---- | :---- |
| 1 | Enrolled finger scanned at shift start | Check-in recorded; kiosk shows name and time within 2 seconds |
| 2 | Unknown finger scanned 5 times in 1 minute | Red message on kiosk; security alert on admin dashboard |
| 3 | Admin enrolls a new employee | Kiosk guides both captures; employee can check in immediately |
| 4 | Deactivated employee scans | Finger not recognized |
| 5 | Check-in 4 minutes late (within grace) | Status "On time", no penalty |
| 6 | Hours worked on a public holiday | Paid at 300% |
| 7 | Night shift 22:00–06:00 | Recorded on the start date, night allowance applied |
| 8 | Month has a missing check-out | Payroll generation blocked until admin resolves it |
| 9 | Payroll locked and emailed | PDF payslip generated; email status "sent" |
| 10 | ESP32 unplugged | "Device offline" banner on kiosk within about 2 minutes |

