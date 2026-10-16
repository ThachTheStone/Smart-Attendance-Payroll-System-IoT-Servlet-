package service;

import dal.AttendanceDAO;
import dal.AttendanceLogDAO;
import dal.DeviceCommandDAO;
import dal.EmployeeDAO;
import dal.FingerprintDAO;
import dal.SalaryRuleDAO;
import dal.ShiftAssignmentDAO;
import dal.ShiftDAO;
import java.time.Duration;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;
import model.Attendance;
import model.AttendanceLog;
import model.DeviceCommand;
import model.Employee;
import model.Fingerprint;
import model.Shift;
import model.ShiftAssignment;

public class AttendanceService {

    private final FingerprintDAO fingerprintDAO;
    private final EmployeeDAO employeeDAO;
    private final AttendanceLogDAO attendanceLogDAO;
    private final AttendanceDAO attendanceDAO;
    private final ShiftAssignmentDAO shiftAssignmentDAO;
    private final ShiftDAO shiftDAO;
    private final SalaryRuleDAO salaryRuleDAO;
    private final DeviceCommandDAO deviceCommandDAO;

    public AttendanceService() {
        this.fingerprintDAO = new FingerprintDAO();
        this.employeeDAO = new EmployeeDAO();
        this.attendanceLogDAO = new AttendanceLogDAO();
        this.attendanceDAO = new AttendanceDAO();
        this.shiftAssignmentDAO = new ShiftAssignmentDAO();
        this.shiftDAO = new ShiftDAO();
        this.salaryRuleDAO = new SalaryRuleDAO();
        this.deviceCommandDAO = new DeviceCommandDAO();
    }

    // Constructor for testing with mock/custom DAOs
    public AttendanceService(FingerprintDAO fingerprintDAO, EmployeeDAO employeeDAO,
                             AttendanceLogDAO attendanceLogDAO, AttendanceDAO attendanceDAO,
                             ShiftAssignmentDAO shiftAssignmentDAO, ShiftDAO shiftDAO,
                             SalaryRuleDAO salaryRuleDAO) {
        this.fingerprintDAO = fingerprintDAO;
        this.employeeDAO = employeeDAO;
        this.attendanceLogDAO = attendanceLogDAO;
        this.attendanceDAO = attendanceDAO;
        this.shiftAssignmentDAO = shiftAssignmentDAO;
        this.shiftDAO = shiftDAO;
        this.salaryRuleDAO = salaryRuleDAO;
        this.deviceCommandDAO = new DeviceCommandDAO();
    }

    /**
     * Core attendance engine processing a single fingerprint scan event (FR-ATT-01..06, FR-IOT-04/05).
     */
    public ScanResult processScan(int deviceId, Integer templateId, Integer confidence, LocalDateTime now) {
        if (now == null) {
            now = LocalDateTime.now();
        }

        // 0. Enrollment mode guard: If device is currently executing ENROLL, ignore attendance scans
        DeviceCommand pendingCmd = deviceCommandDAO.findPendingByDeviceId(deviceId);
        if (pendingCmd != null && "ENROLL".equalsIgnoreCase(pendingCmd.getType())) {
            return ScanResult.ignored("Device is currently in fingerprint enrollment mode");
        }

        // 1. Raw check: invalid or missing template ID (FR-IOT-03, FR-ATT-01)
        if (templateId == null || templateId <= 0) {
            AttendanceLog log = new AttendanceLog(null, deviceId, now, confidence,
                    "NOT_RECOGNIZED", "Unrecognized fingerprint (empty or invalid templateId)");
            attendanceLogDAO.insert(log);
            return ScanResult.notRecognized("Unrecognized fingerprint");
        }

        // 2. Confidence threshold check (FR-IOT-04)
        double minConfidence = salaryRuleDAO.getRuleValue("min_confidence", 50.0);
        if (confidence != null && confidence < minConfidence) {
            AttendanceLog log = new AttendanceLog(null, deviceId, now, confidence,
                    "NOT_RECOGNIZED", "Low recognition confidence: " + confidence + " < " + minConfidence);
            attendanceLogDAO.insert(log);
            return ScanResult.notRecognized("Recognition confidence too low (" + confidence + "%)");
        }

        // 3. Template existence in DB
        Fingerprint fp = fingerprintDAO.findByTemplateId(templateId);
        if (fp == null) {
            AttendanceLog log = new AttendanceLog(null, deviceId, now, confidence,
                    "NOT_RECOGNIZED", "Template ID " + templateId + " not registered in database");
            attendanceLogDAO.insert(log);
            return ScanResult.notRecognized("Fingerprint not registered in the system");
        }

        // 4. Employee active status check
        Employee emp = employeeDAO.findById(fp.getEmployeeId());
        if (emp == null || !"ACTIVE".equalsIgnoreCase(emp.getStatus())) {
            AttendanceLog log = new AttendanceLog(fp.getEmployeeId(), deviceId, now, confidence,
                    "IGNORED", "Employee is inactive or has left company");
            attendanceLogDAO.insert(log);
            return ScanResult.ignored("Employee is inactive or has left company");
        }

        // 5. Cooldown check: ignore scans within 60 seconds (FR-ATT-06)
        AttendanceLog lastLog = attendanceLogDAO.findLastLogByEmployeeId(emp.getId());
        if (lastLog != null && lastLog.getEventTime() != null) {
            long seconds = Duration.between(lastLog.getEventTime(), now).getSeconds();
            if (seconds >= 0 && seconds < 60) {
                AttendanceLog log = new AttendanceLog(emp.getId(), deviceId, now, confidence,
                        "IGNORED", "Consecutive scans within " + seconds + "s (< 60s)");
                attendanceLogDAO.insert(log);
                return ScanResult.ignored("Please wait 1 minute between scans (" + seconds + "s elapsed)");
            }
        }

        // 6. Check-in vs Check-out determination (FR-IOT-05)
        // Find if there is an active/open attendance record (checked in, not checked out)
        Attendance openAttendance = findOpenAttendance(emp.getId(), now.toLocalDate());

        if (openAttendance != null) {
            // === CHECK_OUT ===
            return processCheckOut(emp, openAttendance, deviceId, confidence, now);
        } else {
            // === CHECK_IN ===
            return processCheckIn(emp, deviceId, confidence, now);
        }
    }

    /**
     * Checks if the employee has an open attendance session (checked in, no check out yet).
     * First checks today; if not found, checks yesterday for overnight shifts (FR-SHIFT-03).
     */
    private Attendance findOpenAttendance(int employeeId, LocalDate today) {
        // 1. Check today's records
        List<Attendance> todayRecords = attendanceDAO.findByEmployeeAndDate(employeeId, today);
        for (Attendance a : todayRecords) {
            if (a.getCheckIn() != null && a.getCheckOut() == null) {
                return a;
            }
        }

        // 2. Check yesterday's records (for overnight shift checkout)
        List<Attendance> yesterdayRecords = attendanceDAO.findByEmployeeAndDate(employeeId, today.minusDays(1));
        for (Attendance a : yesterdayRecords) {
            if (a.getCheckIn() != null && a.getCheckOut() == null) {
                return a;
            }
        }

        return null;
    }

    /**
     * Processes Check-out for an existing open attendance record.
     */
    private ScanResult processCheckOut(Employee emp, Attendance att, int deviceId, Integer confidence, LocalDateTime now) {
        att.setCheckOut(now);

        Shift shift = shiftDAO.findById(att.getShiftId());
        int breakMinutes = (shift != null) ? shift.getBreakMinutes() : 0;

        long rawMinutes = Duration.between(att.getCheckIn(), now).toMinutes();
        int workedMinutes = (int) Math.max(0, rawMinutes - breakMinutes);
        att.setWorkedMinutes(workedMinutes);

        // Determine checkout status
        LocalDateTime shiftEndDateTime;
        if (shift != null) {
            if (shift.isOvernight()) {
                shiftEndDateTime = LocalDateTime.of(att.getWorkDate().plusDays(1), shift.getEndTime());
            } else {
                shiftEndDateTime = LocalDateTime.of(att.getWorkDate(), shift.getEndTime());
            }
        } else {
            shiftEndDateTime = att.getCheckIn().plusHours(8);
        }

        // If employee left before scheduled shift end time
        if (now.isBefore(shiftEndDateTime)) {
            att.setStatus("EARLY_LEAVE");
        } else if (now.isAfter(shiftEndDateTime.plusMinutes(30))
                || (shift != null && workedMinutes > (shift.getDurationMinutes() + 30))) {
            att.setStatus("OVERTIME");
        } else {
            if ("LATE".equals(att.getStatus())) {
                // If they checked in late, maintain LATE status
            } else {
                att.setStatus("ON_TIME");
            }
        }

        attendanceDAO.update(att);

        // Raw log
        String reason = "Check-out successful (" + att.getStatusLabel() + ", " + (workedMinutes / 60) + "h" + (workedMinutes % 60) + "m)";
        AttendanceLog log = new AttendanceLog(emp.getId(), deviceId, now, confidence, "CHECK_OUT", reason);
        attendanceLogDAO.insert(log);

        return ScanResult.checkOut(emp, now, att, reason);
    }

    /**
     * Processes Check-in for an employee starting a shift.
     */
    private ScanResult processCheckIn(Employee emp, int deviceId, Integer confidence, LocalDateTime now) {
        LocalDate workDate = now.toLocalDate();

        // Find shift assignment for today
        List<ShiftAssignment> assignments = shiftAssignmentDAO.findByEmployeeAndDate(emp.getId(), workDate);
        Shift targetShift = null;

        for (ShiftAssignment sa : assignments) {
            Attendance existing = attendanceDAO.findByEmployeeDateShift(emp.getId(), workDate, sa.getShiftId());
            if (existing == null || (existing.getCheckIn() == null && !"MISSING_CHECKOUT".equals(existing.getStatus()))) {
                targetShift = shiftDAO.findById(sa.getShiftId());
                break;
            }
        }

        // If no assignment or all assigned shifts already attended, find closest active shift
        if (targetShift == null) {
            List<Shift> allShifts = shiftDAO.findAll();
            if (allShifts.isEmpty()) {
                AttendanceLog log = new AttendanceLog(emp.getId(), deviceId, now, confidence,
                        "IGNORED", "No shifts have been configured in the system");
                attendanceLogDAO.insert(log);
                return ScanResult.ignored("No shifts have been configured in the system");
            }

            targetShift = findClosestShift(allShifts, now.toLocalTime());
            // Auto-assign this shift so data integrity is maintained
            shiftAssignmentDAO.assign(emp.getId(), targetShift.getId(), workDate);
        }

        // Calculate ON_TIME vs LATE using grace period
        LocalDateTime shiftStartDateTime = LocalDateTime.of(workDate, targetShift.getStartTime());
        double graceMinutes = salaryRuleDAO.getRuleValue("grace_period_minutes", 5.0);
        LocalDateTime graceDeadline = shiftStartDateTime.plusMinutes((long) graceMinutes);

        String status = now.isAfter(graceDeadline) ? "LATE" : "ON_TIME";

        // Check if an Attendance record row already exists (e.g. pre-seeded or ABSENT)
        Attendance att = attendanceDAO.findByEmployeeDateShift(emp.getId(), workDate, targetShift.getId());
        if (att != null) {
            att.setCheckIn(now);
            att.setCheckOut(null);
            att.setWorkedMinutes(0);
            att.setStatus(status);
            attendanceDAO.update(att);
        } else {
            att = new Attendance(emp.getId(), workDate, targetShift.getId(), now, status);
            att.setShiftName(targetShift.getName());
            att.setShiftStartTime(targetShift.getStartTime());
            att.setShiftEndTime(targetShift.getEndTime());
            int newId = attendanceDAO.insert(att);
            att.setId(newId);
        }

        // Raw log
        String reason = "Check-in successful: " + att.getStatusLabel() + " (" + targetShift.getName() + ")";
        AttendanceLog log = new AttendanceLog(emp.getId(), deviceId, now, confidence, "CHECK_IN", reason);
        attendanceLogDAO.insert(log);

        return ScanResult.checkIn(emp, now, att, reason);
    }

    /**
     * Finds the shift whose start time is closest to the given time.
     */
    private Shift findClosestShift(List<Shift> shifts, LocalTime time) {
        Shift closest = shifts.get(0);
        long minDiff = Long.MAX_VALUE;

        for (Shift s : shifts) {
            long diff = Math.abs(Duration.between(s.getStartTime(), time).toMinutes());
            if (diff > 12 * 60) {
                // Adjust for 24-hour wrap-around
                diff = 24 * 60 - diff;
            }
            if (diff < minDiff) {
                minDiff = diff;
                closest = s;
            }
        }
        return closest;
    }
}
