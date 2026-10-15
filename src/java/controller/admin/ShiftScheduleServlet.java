package controller.admin;

import dal.EmployeeDAO;
import dal.ShiftAssignmentDAO;
import dal.ShiftDAO;
import java.io.IOException;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.time.temporal.TemporalAdjusters;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import model.Employee;
import model.Shift;
import model.ShiftAssignment;
import util.Flash;

@WebServlet(name = "ShiftScheduleServlet", urlPatterns = {"/admin/shifts/schedule"})
public class ShiftScheduleServlet extends HttpServlet {

    private final ShiftAssignmentDAO assignmentDAO = new ShiftAssignmentDAO();
    private final ShiftDAO shiftDAO = new ShiftDAO();
    private final EmployeeDAO employeeDAO = new EmployeeDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        int offset = 0;
        try {
            String offStr = req.getParameter("offset");
            if (offStr != null) {
                offset = Integer.parseInt(offStr);
            }
        } catch (NumberFormatException ignored) {
        }

        LocalDate today = LocalDate.now();
        LocalDate monday = today.with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY)).plusWeeks(offset);
        LocalDate sunday = monday.plusDays(6);

        List<LocalDate> weekDays = new ArrayList<>();
        for (int i = 0; i < 7; i++) {
            weekDays.add(monday.plusDays(i));
        }

        List<Employee> employees = employeeDAO.findAllActive();
        List<Shift> shifts = shiftDAO.findAll();
        List<ShiftAssignment> assignments = assignmentDAO.findByDateRange(monday, sunday);

        // Group assignments by "empId_yyyy-MM-dd" for easy JSP table lookup
        Map<String, List<ShiftAssignment>> grid = new HashMap<>();
        for (ShiftAssignment sa : assignments) {
            String key = sa.getEmployeeId() + "_" + sa.getWorkDate().toString();
            grid.computeIfAbsent(key, k -> new ArrayList<>()).add(sa);
        }

        req.setAttribute("offset", offset);
        req.setAttribute("monday", monday);
        req.setAttribute("sunday", sunday);
        req.setAttribute("weekDays", weekDays);
        req.setAttribute("employees", employees);
        req.setAttribute("shifts", shifts);
        req.setAttribute("grid", grid);

        req.getRequestDispatcher("/WEB-INF/views/admin/shifts/schedule.jsp").forward(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");
        String offsetParam = req.getParameter("offset");
        String redirectUrl = req.getContextPath() + "/admin/shifts/schedule" 
                + (offsetParam != null && !offsetParam.isEmpty() ? "?offset=" + offsetParam : "");

        if ("delete".equals(action)) {
            try {
                int id = Integer.parseInt(req.getParameter("id"));
                boolean ok = assignmentDAO.delete(id);
                if (ok) Flash.success(req, "Shift assignment deleted.");
                else Flash.error(req, "Cannot delete shift assignment.");
            } catch (NumberFormatException e) {
                Flash.error(req, "Invalid ID.");
            }
            res.sendRedirect(redirectUrl);
            return;
        }

        if ("assign".equals(action)) {
            String[] empIdStrs = req.getParameterValues("employeeIds");
            String shiftIdStr = req.getParameter("shiftId");
            String startStr = req.getParameter("startDate");
            String endStr = req.getParameter("endDate");
            String[] dowStrs = req.getParameterValues("daysOfWeek");

            if (empIdStrs == null || empIdStrs.length == 0 || shiftIdStr == null || startStr == null || endStr == null) {
                Flash.error(req, "Please select employees, shift, and date range.");
                res.sendRedirect(redirectUrl);
                return;
            }

            int shiftId;
            LocalDate from;
            LocalDate to;
            try {
                shiftId = Integer.parseInt(shiftIdStr);
                from = LocalDate.parse(startStr.trim());
                to = LocalDate.parse(endStr.trim());
                if (to.isBefore(from)) {
                    Flash.error(req, "End date must be greater than or equal to start date.");
                    res.sendRedirect(redirectUrl);
                    return;
                }
            } catch (DateTimeParseException | NumberFormatException e) {
                Flash.error(req, "Invalid date or shift.");
                res.sendRedirect(redirectUrl);
                return;
            }

            List<Integer> empIds = new ArrayList<>();
            for (String s : empIdStrs) {
                try {
                    empIds.add(Integer.parseInt(s));
                } catch (NumberFormatException ignored) {
                }
            }

            Set<Integer> daysOfWeek = new HashSet<>();
            if (dowStrs != null) {
                for (String d : dowStrs) {
                    try {
                        daysOfWeek.add(Integer.parseInt(d));
                    } catch (NumberFormatException ignored) {
                    }
                }
            }

            int count = assignmentDAO.assignBatch(empIds, shiftId, from, to, daysOfWeek);
            Flash.success(req, "Successfully scheduled " + count + " shift assignments.");
            res.sendRedirect(redirectUrl);
        }
    }
}
