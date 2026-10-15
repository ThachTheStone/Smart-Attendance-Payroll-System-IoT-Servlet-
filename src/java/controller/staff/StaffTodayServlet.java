package controller.staff;

import dal.AttendanceDAO;
import dal.ShiftAssignmentDAO;
import dal.ShiftDAO;
import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import model.Account;
import model.Attendance;
import model.Employee;
import model.Shift;
import model.ShiftAssignment;
import util.Constants;

/**
 * Staff "Today" Portal (FR-STAFF-01..04).
 * Shows today's shift, actual check-in/out, live JavaScript elapsed work counter,
 * shift progress timeline, monthly hours summary, and attendance history.
 */
@WebServlet(name = "StaffTodayServlet", urlPatterns = {"/staff/today"})
public class StaffTodayServlet extends HttpServlet {

    private final AttendanceDAO attendanceDAO = new AttendanceDAO();
    private final ShiftAssignmentDAO shiftAssignmentDAO = new ShiftAssignmentDAO();
    private final ShiftDAO shiftDAO = new ShiftDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        Account acc = session == null ? null : (Account) session.getAttribute(Constants.SESSION_USER);
        if (acc == null || acc.getEmployee() == null) {
            res.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        Employee emp = acc.getEmployee();
        LocalDate today = LocalDate.now();

        // 1. Today's assigned shift (FR-STAFF-01)
        List<ShiftAssignment> assignments = shiftAssignmentDAO.findByEmployeeAndDate(emp.getId(), today);
        Shift todayShift = null;
        if (!assignments.isEmpty()) {
            todayShift = shiftDAO.findById(assignments.get(0).getShiftId());
        }

        // 2. Today's attendance record
        List<Attendance> todayRecords = attendanceDAO.findByEmployeeAndDate(emp.getId(), today);
        Attendance todayAtt = todayRecords.isEmpty() ? null : todayRecords.get(0);

        // 3. Monthly statistics (FR-STAFF-03)
        LocalDate startOfMonth = today.withDayOfMonth(1);
        LocalDate endOfMonth = today.withDayOfMonth(today.lengthOfMonth());
        List<Attendance> monthRecords = attendanceDAO.findByEmployeeAndDateRange(emp.getId(), startOfMonth, endOfMonth);

        long totalWorkedMinutesMonth = 0;
        int lateCountMonth = 0;
        int overtimeCountMonth = 0;
        int onTimeCountMonth = 0;

        for (Attendance a : monthRecords) {
            totalWorkedMinutesMonth += a.getWorkedMinutes();
            if ("LATE".equalsIgnoreCase(a.getStatus())) lateCountMonth++;
            else if ("OVERTIME".equalsIgnoreCase(a.getStatus())) overtimeCountMonth++;
            else if ("ON_TIME".equalsIgnoreCase(a.getStatus())) onTimeCountMonth++;
        }

        double totalHoursMonth = Math.round((totalWorkedMinutesMonth / 60.0) * 10.0) / 10.0;

        // Estimated salary calculation
        double baseSalary = emp.getBaseSalary() != null ? emp.getBaseSalary().doubleValue() : 0.0;
        double estimatedSalary = 0.0;
        if ("HOURLY".equalsIgnoreCase(emp.getSalaryType())) {
            estimatedSalary = totalHoursMonth * baseSalary;
        } else {
            // Standard hours 208
            double hourlyRate = baseSalary / 208.0;
            estimatedSalary = totalHoursMonth * hourlyRate;
        }

        // 4. Attendance history filter (FR-STAFF-04)
        String fromStr = req.getParameter("from");
        String toStr = req.getParameter("to");
        LocalDate fromDate = startOfMonth;
        LocalDate toDate = today;

        if (fromStr != null && !fromStr.trim().isEmpty()) {
            try { fromDate = LocalDate.parse(fromStr.trim()); } catch (DateTimeParseException ignored) {}
        }
        if (toStr != null && !toStr.trim().isEmpty()) {
            try { toDate = LocalDate.parse(toStr.trim()); } catch (DateTimeParseException ignored) {}
        }

        List<Attendance> historyList = attendanceDAO.findByEmployeeAndDateRange(emp.getId(), fromDate, toDate);

        req.setAttribute("emp", emp);
        req.setAttribute("today", today);
        req.setAttribute("todayShift", todayShift);
        req.setAttribute("todayAtt", todayAtt);
        req.setAttribute("totalHoursMonth", totalHoursMonth);
        req.setAttribute("lateCountMonth", lateCountMonth);
        req.setAttribute("overtimeCountMonth", overtimeCountMonth);
        req.setAttribute("onTimeCountMonth", onTimeCountMonth);
        req.setAttribute("estimatedSalary", Math.round(estimatedSalary));
        req.setAttribute("fromDate", fromDate);
        req.setAttribute("toDate", toDate);
        req.setAttribute("historyList", historyList);

        req.getRequestDispatcher("/WEB-INF/views/staff/today.jsp").forward(req, res);
    }
}
