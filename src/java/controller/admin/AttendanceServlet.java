package controller.admin;

import dal.AttendanceDAO;
import dal.AuditLogDAO;
import dal.EmployeeDAO;
import dal.ShiftDAO;
import java.io.IOException;
import java.time.Duration;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import model.Account;
import model.Attendance;
import model.AuditLog;
import model.Employee;
import model.Shift;
import util.Flash;
import util.JsonUtil;

@WebServlet(name = "AttendanceServlet", urlPatterns = {"/admin/attendance"})
public class AttendanceServlet extends HttpServlet {

    private final AttendanceDAO attendanceDAO = new AttendanceDAO();
    private final AuditLogDAO auditLogDAO = new AuditLogDAO();
    private final EmployeeDAO employeeDAO = new EmployeeDAO();
    private final ShiftDAO shiftDAO = new ShiftDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        // AJAX endpoint to fetch audit history for a record (FR-ATT-05)
        if ("audit".equalsIgnoreCase(action)) {
            String recordIdStr = request.getParameter("recordId");
            if (recordIdStr != null) {
                try {
                    int recordId = Integer.parseInt(recordIdStr);
                    List<AuditLog> logs = auditLogDAO.findByRecord("Attendance", recordId);
                    StringBuilder sb = new StringBuilder("[");
                    for (int i = 0; i < logs.size(); i++) {
                        AuditLog l = logs.get(i);
                        if (i > 0) sb.append(",");
                        sb.append("{")
                          .append("\"id\":").append(l.getId())
                          .append(",\"admin\":\"").append(JsonUtil.escape(l.getAdminUsername())).append("\"")
                          .append(",\"time\":\"").append(l.getFormattedTime()).append("\"")
                          .append(",\"oldValue\":\"").append(JsonUtil.escape(l.getOldValue())).append("\"")
                          .append(",\"newValue\":\"").append(JsonUtil.escape(l.getNewValue())).append("\"")
                          .append(",\"reason\":\"").append(JsonUtil.escape(l.getReason())).append("\"")
                          .append("}");
                    }
                    sb.append("]");
                    JsonUtil.sendJson(response, HttpServletResponse.SC_OK, sb.toString());
                    return;
                } catch (NumberFormatException ignored) {
                }
            }
            JsonUtil.sendJson(response, HttpServletResponse.SC_BAD_REQUEST, "[]");
            return;
        }

        // Filters: Date range, employee, status
        LocalDate today = LocalDate.now();
        String fromStr = request.getParameter("from");
        String toStr = request.getParameter("to");
        String empIdStr = request.getParameter("employeeId");
        String status = request.getParameter("status");

        LocalDate from = (fromStr != null && !fromStr.trim().isEmpty())
                ? LocalDate.parse(fromStr.trim())
                : today.withDayOfMonth(1); // Default to 1st of current month

        LocalDate to = (toStr != null && !toStr.trim().isEmpty())
                ? LocalDate.parse(toStr.trim())
                : today;

        Integer employeeId = null;
        if (empIdStr != null && !empIdStr.trim().isEmpty()) {
            try {
                employeeId = Integer.parseInt(empIdStr.trim());
                if (employeeId <= 0) employeeId = null;
            } catch (NumberFormatException ignored) {
            }
        }

        if (status != null && (status.trim().isEmpty() || "ALL".equalsIgnoreCase(status.trim()))) {
            status = null;
        }

        List<Attendance> attendances = attendanceDAO.search(from, to, employeeId, status);
        List<Employee> employees = employeeDAO.findAllActive();
        List<Shift> shifts = shiftDAO.findAll();

        // Calculate statistics for the filtered dataset
        int totalRecords = attendances.size();
        long onTimeCount = 0;
        long lateCount = 0;
        long earlyLeaveCount = 0;
        long missingCheckoutCount = 0;
        long absentCount = 0;
        long overtimeCount = 0;

        for (Attendance a : attendances) {
            String s = a.getStatus();
            if ("ON_TIME".equals(s)) onTimeCount++;
            else if ("LATE".equals(s)) lateCount++;
            else if ("EARLY_LEAVE".equals(s)) earlyLeaveCount++;
            else if ("MISSING_CHECKOUT".equals(s)) missingCheckoutCount++;
            else if ("ABSENT".equals(s)) absentCount++;
            else if ("OVERTIME".equals(s)) overtimeCount++;
        }

        request.setAttribute("attendances", attendances);
        request.setAttribute("employees", employees);
        request.setAttribute("shifts", shifts);
        request.setAttribute("from", from);
        request.setAttribute("to", to);
        request.setAttribute("selectedEmployeeId", employeeId);
        request.setAttribute("selectedStatus", status);

        request.setAttribute("totalRecords", totalRecords);
        request.setAttribute("onTimeCount", onTimeCount);
        request.setAttribute("lateCount", lateCount);
        request.setAttribute("earlyLeaveCount", earlyLeaveCount);
        request.setAttribute("missingCheckoutCount", missingCheckoutCount);
        request.setAttribute("absentCount", absentCount);
        request.setAttribute("overtimeCount", overtimeCount);

        request.getRequestDispatcher("/WEB-INF/views/admin/attendance/list.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        Account current = (session != null) ? (Account) session.getAttribute("account") : null;
        if (current == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String from = request.getParameter("from");
        String to = request.getParameter("to");
        String redirectUrl = request.getContextPath() + "/admin/attendance";
        if (from != null && to != null) {
            redirectUrl += "?from=" + from + "&to=" + to;
        }

        String idStr = request.getParameter("id");
        String reason = request.getParameter("reason");

        // Mandatory reason enforcement (FR-ATT-05)
        if (reason == null || reason.trim().isEmpty()) {
            Flash.error(request, "Lý do điều chỉnh bảng công là bắt buộc (FR-ATT-05).");
            response.sendRedirect(redirectUrl);
            return;
        }

        int id;
        try {
            id = Integer.parseInt(idStr);
        } catch (NumberFormatException e) {
            Flash.error(request, "Mã bảng công không hợp lệ.");
            response.sendRedirect(redirectUrl);
            return;
        }

        Attendance old = attendanceDAO.findById(id);
        if (old == null) {
            Flash.error(request, "Không tìm thấy bản ghi chấm công cần điều chỉnh.");
            response.sendRedirect(redirectUrl);
            return;
        }

        String checkInStr = request.getParameter("checkIn");
        String checkOutStr = request.getParameter("checkOut");
        String newStatus = request.getParameter("status");
        String workedMinutesStr = request.getParameter("workedMinutes");

        LocalDateTime newCheckIn = (checkInStr != null && !checkInStr.trim().isEmpty())
                ? LocalDateTime.parse(checkInStr.trim(), DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm"))
                : null;

        LocalDateTime newCheckOut = (checkOutStr != null && !checkOutStr.trim().isEmpty())
                ? LocalDateTime.parse(checkOutStr.trim(), DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm"))
                : null;

        int newWorkedMinutes = 0;
        if (workedMinutesStr != null && !workedMinutesStr.trim().isEmpty()) {
            try {
                newWorkedMinutes = Integer.parseInt(workedMinutesStr.trim());
            } catch (NumberFormatException ignored) {
            }
        }

        // Auto calculate worked minutes if not supplied but checkIn & checkOut are provided
        if (newWorkedMinutes <= 0 && newCheckIn != null && newCheckOut != null) {
            Shift s = shiftDAO.findById(old.getShiftId());
            int breakMins = (s != null) ? s.getBreakMinutes() : 0;
            newWorkedMinutes = (int) Math.max(0, Duration.between(newCheckIn, newCheckOut).toMinutes() - breakMins);
        }

        // Format old & new values for AuditLog
        String oldValueStr = String.format("checkIn=%s, checkOut=%s, status=%s, workedMinutes=%d",
                old.getFormattedCheckInDateTime(),
                old.getFormattedCheckOutDateTime(),
                old.getStatus(),
                old.getWorkedMinutes());

        String newValueStr = String.format("checkIn=%s, checkOut=%s, status=%s, workedMinutes=%d",
                (newCheckIn != null ? newCheckIn.format(DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm")) : ""),
                (newCheckOut != null ? newCheckOut.format(DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm")) : ""),
                newStatus,
                newWorkedMinutes);

        // Update attendance record
        old.setCheckIn(newCheckIn);
        old.setCheckOut(newCheckOut);
        old.setStatus(newStatus != null ? newStatus.trim() : old.getStatus());
        old.setWorkedMinutes(newWorkedMinutes);

        boolean updated = attendanceDAO.update(old);
        if (updated) {
            // Record audit log (FR-ATT-05)
            AuditLog audit = new AuditLog(current.getId(), "Attendance", old.getId(), oldValueStr, newValueStr, reason.trim());
            auditLogDAO.insert(audit);

            Flash.success(request, "Đã cập nhật bảng công #" + old.getId() + " và lưu lịch sử kiểm toán thành công.");
        } else {
            Flash.error(request, "Không thể cập nhật bảng công vào cơ sở dữ liệu.");
        }

        response.sendRedirect(redirectUrl);
    }
}
