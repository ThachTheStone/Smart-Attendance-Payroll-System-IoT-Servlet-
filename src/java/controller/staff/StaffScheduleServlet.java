package controller.staff;

import dal.HolidayDAO;
import dal.ShiftAssignmentDAO;
import java.io.IOException;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.temporal.TemporalAdjusters;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import model.Account;
import model.ShiftAssignment;
import util.Constants;

@WebServlet(name = "StaffScheduleServlet", urlPatterns = {"/staff/schedule"})
public class StaffScheduleServlet extends HttpServlet {

    private final ShiftAssignmentDAO assignmentDAO = new ShiftAssignmentDAO();
    private final HolidayDAO holidayDAO = new HolidayDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        Account user = session == null ? null : (Account) session.getAttribute(Constants.SESSION_USER);

        if (user == null || user.getEmployeeId() == null) {
            req.setAttribute("errorMessage", "Tài khoản của bạn chưa được liên kết với hồ sơ nhân viên.");
            req.getRequestDispatcher("/WEB-INF/views/staff/schedule.jsp").forward(req, res);
            return;
        }

        LocalDate today = LocalDate.now();
        LocalDate monThisWeek = today.with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY));
        LocalDate sunNextWeek = monThisWeek.plusDays(13);

        List<ShiftAssignment> list = assignmentDAO.findByEmployeeAndDateRange(
                user.getEmployeeId(), monThisWeek, sunNextWeek);

        Map<String, ShiftAssignment> scheduleMap = new HashMap<>();
        for (ShiftAssignment sa : list) {
            scheduleMap.put(sa.getWorkDate().toString(), sa);
        }

        List<LocalDate> thisWeek = new ArrayList<>();
        for (int i = 0; i < 7; i++) {
            thisWeek.add(monThisWeek.plusDays(i));
        }

        List<LocalDate> nextWeek = new ArrayList<>();
        LocalDate monNextWeek = monThisWeek.plusDays(7);
        for (int i = 0; i < 7; i++) {
            nextWeek.add(monNextWeek.plusDays(i));
        }

        req.setAttribute("today", today);
        req.setAttribute("thisWeek", thisWeek);
        req.setAttribute("nextWeek", nextWeek);
        req.setAttribute("scheduleMap", scheduleMap);

        req.getRequestDispatcher("/WEB-INF/views/staff/schedule.jsp").forward(req, res);
    }
}
