package controller.admin;

import dal.AttendanceDAO;
import dal.AttendanceLogDAO;
import dal.DeviceDAO;
import dal.EmployeeDAO;
import java.io.IOException;
import java.time.LocalDate;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import model.Attendance;
import model.AttendanceLog;
import model.Device;
import util.JsonUtil;

/**
 * Admin Live Dashboard (FR-DASH-01..06).
 * Displays real-time KPIs, currently checked-in employees, live event feed,
 * device statuses, and security alerts.
 */
@WebServlet(name = "DashboardServlet", urlPatterns = {"/admin/dashboard"})
public class DashboardServlet extends HttpServlet {

    private final AttendanceDAO attendanceDAO = new AttendanceDAO();
    private final AttendanceLogDAO attendanceLogDAO = new AttendanceLogDAO();
    private final EmployeeDAO employeeDAO = new EmployeeDAO();
    private final DeviceDAO deviceDAO = new DeviceDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        LocalDate today = LocalDate.now();

        // 1. Check if request is AJAX polling fallback (FR-DASH-06)
        String action = req.getParameter("action");
        if ("poll".equalsIgnoreCase(action) || "application/json".equals(req.getHeader("Accept"))) {
            sendPollingJson(res, today);
            return;
        }

        // 2. Fetch Dashboard metrics
        int totalEmployees = employeeDAO.countActive();
        int presentCount = attendanceDAO.countPresentToday(today);
        int lateCount = attendanceDAO.countLateToday(today);
        int absentCount = attendanceDAO.countAbsentToday(today);
        int overtimeCount = attendanceDAO.countOvertimeToday(today);

        List<Attendance> currentlyWorking = attendanceDAO.findCurrentlyCheckedIn(today);
        List<AttendanceLog> recentLogs = attendanceLogDAO.findRecentWithDetails(15);
        List<Device> devices = deviceDAO.findAll();

        req.setAttribute("today", today);
        req.setAttribute("totalEmployees", totalEmployees);
        req.setAttribute("presentCount", presentCount);
        req.setAttribute("lateCount", lateCount);
        req.setAttribute("absentCount", absentCount);
        req.setAttribute("overtimeCount", overtimeCount);
        req.setAttribute("currentlyWorking", currentlyWorking);
        req.setAttribute("recentLogs", recentLogs);
        req.setAttribute("devices", devices);

        req.getRequestDispatcher("/WEB-INF/views/admin/dashboard.jsp").forward(req, res);
    }

    /**
     * Responds with full JSON snapshot for polling fallback.
     */
    private void sendPollingJson(HttpServletResponse res, LocalDate today) throws IOException {
        int totalEmployees = employeeDAO.countActive();
        int presentCount = attendanceDAO.countPresentToday(today);
        int lateCount = attendanceDAO.countLateToday(today);
        int absentCount = attendanceDAO.countAbsentToday(today);
        int overtimeCount = attendanceDAO.countOvertimeToday(today);

        List<Attendance> working = attendanceDAO.findCurrentlyCheckedIn(today);
        List<AttendanceLog> logs = attendanceLogDAO.findRecentWithDetails(10);
        List<Device> devices = deviceDAO.findAll();

        StringBuilder sb = new StringBuilder("{");
        sb.append("\"stats\":{")
          .append("\"totalEmployees\":").append(totalEmployees)
          .append(",\"present\":").append(presentCount)
          .append(",\"late\":").append(lateCount)
          .append(",\"absent\":").append(absentCount)
          .append(",\"overtime\":").append(overtimeCount)
          .append("},");

        // Currently working array
        sb.append("\"working\":[");
        for (int i = 0; i < working.size(); i++) {
            Attendance a = working.get(i);
            if (i > 0) sb.append(",");
            sb.append("{")
              .append("\"id\":").append(a.getId())
              .append(",\"name\":\"").append(JsonUtil.escape(a.getEmployeeName())).append("\"")
              .append(",\"code\":\"").append(JsonUtil.escape(a.getEmployeeCode())).append("\"")
              .append(",\"department\":\"").append(JsonUtil.escape(a.getDepartment())).append("\"")
              .append(",\"checkIn\":\"").append(a.getFormattedCheckIn()).append("\"")
              .append(",\"shift\":\"").append(JsonUtil.escape(a.getShiftName())).append("\"")
              .append(",\"status\":\"").append(a.getStatus()).append("\"")
              .append(",\"statusLabel\":\"").append(JsonUtil.escape(a.getStatusLabel())).append("\"")
              .append("}");
        }
        sb.append("],");

        // Devices array
        sb.append("\"devices\":[");
        for (int i = 0; i < devices.size(); i++) {
            Device d = devices.get(i);
            if (i > 0) sb.append(",");
            sb.append("{")
              .append("\"id\":").append(d.getId())
              .append(",\"name\":\"").append(JsonUtil.escape(d.getName())).append("\"")
              .append(",\"online\":").append(d.isOnline())
              .append("}");
        }
        sb.append("]");

        sb.append("}");
        JsonUtil.sendJson(res, HttpServletResponse.SC_OK, sb.toString());
    }
}
