package controller.admin;

import dal.AttendanceDAO;
import dal.EmployeeDAO;
import dal.HolidayDAO;
import dal.PayrollDAO;
import dal.SalaryRuleDAO;
import java.io.IOException;
import java.time.LocalDate;
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
import model.Attendance;
import model.Employee;
import model.Holiday;
import model.Payroll;
import model.PayrollDetail;
import model.SalaryRule;
import service.PayrollCalculator;
import util.Flash;

/**
 * Monthly Payroll Management (FR-PAY-01..04).
 * Handles monthly batch generation, missing checkout validation, DRAFT review, and LOCK protection.
 */
@WebServlet(name = "PayrollServlet", urlPatterns = {"/admin/payroll"})
public class PayrollServlet extends HttpServlet {

    private final PayrollDAO payrollDAO = new PayrollDAO();
    private final EmployeeDAO employeeDAO = new EmployeeDAO();
    private final AttendanceDAO attendanceDAO = new AttendanceDAO();
    private final SalaryRuleDAO salaryRuleDAO = new SalaryRuleDAO();
    private final HolidayDAO holidayDAO = new HolidayDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        LocalDate now = LocalDate.now();
        int month = now.getMonthValue();
        int year = now.getYear();

        String mStr = req.getParameter("month");
        String yStr = req.getParameter("year");
        if (mStr != null && !mStr.trim().isEmpty()) {
            try { month = Integer.parseInt(mStr.trim()); } catch (NumberFormatException ignored) {}
        }
        if (yStr != null && !yStr.trim().isEmpty()) {
            try { year = Integer.parseInt(yStr.trim()); } catch (NumberFormatException ignored) {}
        }

        // 1. Check if Payroll batch exists
        Payroll payroll = payrollDAO.findByMonthAndYear(month, year);
        List<PayrollDetail> details = null;
        if (payroll != null) {
            details = payrollDAO.findDetailsByPayrollId(payroll.getId());
        }

        // 2. Check for unresolved missing checkouts in this month (FR-PAY-03)
        List<Attendance> missingCheckouts = payrollDAO.findMissingCheckoutsForMonth(month, year);

        // 3. Payroll history list for side navigation
        List<Payroll> history = payrollDAO.findAll();

        req.setAttribute("month", month);
        req.setAttribute("year", year);
        req.setAttribute("payroll", payroll);
        req.setAttribute("details", details);
        req.setAttribute("missingCheckouts", missingCheckouts);
        req.setAttribute("history", history);

        req.getRequestDispatcher("/WEB-INF/views/admin/payroll/index.jsp").forward(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");

        int month = LocalDate.now().getMonthValue();
        int year = LocalDate.now().getYear();
        try {
            month = Integer.parseInt(req.getParameter("month"));
            year = Integer.parseInt(req.getParameter("year"));
        } catch (NumberFormatException ignored) {
        }

        if ("lock".equalsIgnoreCase(action)) {
            // Lock payroll (FR-PAY-04)
            int payrollId = Integer.parseInt(req.getParameter("payrollId"));
            boolean locked = payrollDAO.lockPayroll(payrollId);
            if (locked) {
                Flash.success(req, "Payroll for Month " + month + "/" + year + " locked successfully. Data is now final.");
            } else {
                Flash.error(req, "Failed to lock payroll.");
            }
            res.sendRedirect(req.getContextPath() + "/admin/payroll?month=" + month + "&year=" + year);
            return;
        }

        if ("generate".equalsIgnoreCase(action)) {
            // Check for missing checkouts (FR-PAY-03)
            List<Attendance> missingCheckouts = payrollDAO.findMissingCheckoutsForMonth(month, year);
            if (!missingCheckouts.isEmpty()) {
                Flash.error(req, "Cannot generate payroll: Month " + month + "/" + year + " has " 
                        + missingCheckouts.size() + " unresolved missing checkouts (FR-PAY-03).");
                res.sendRedirect(req.getContextPath() + "/admin/payroll?month=" + month + "&year=" + year);
                return;
            }

            // Check if existing payroll is locked
            Payroll existing = payrollDAO.findByMonthAndYear(month, year);
            if (existing != null && existing.isLocked()) {
                Flash.error(req, "Payroll for Month " + month + "/" + year + " is LOCKED and cannot be recalculated.");
                res.sendRedirect(req.getContextPath() + "/admin/payroll?month=" + month + "&year=" + year);
                return;
            }

            int payrollId;
            if (existing == null) {
                payrollId = payrollDAO.createDraft(month, year);
                if (payrollId <= 0) {
                    Flash.error(req, "Could not initialize new payroll record.");
                    res.sendRedirect(req.getContextPath() + "/admin/payroll?month=" + month + "&year=" + year);
                    return;
                }
            } else {
                payrollId = existing.getId();
            }

            // Load rules, holidays, and employees
            Map<String, SalaryRule> rulesRaw = salaryRuleDAO.findAll();
            Map<String, Double> rules = new HashMap<>();
            for (Map.Entry<String, SalaryRule> entry : rulesRaw.entrySet()) {
                rules.put(entry.getKey(), entry.getValue().getDoubleValue());
            }

            List<Holiday> holidayList = holidayDAO.findByYear(year);
            Set<LocalDate> holidays = new HashSet<>();
            for (Holiday h : holidayList) {
                holidays.add(h.getDate());
            }

            LocalDate from = LocalDate.of(year, month, 1);
            LocalDate to = from.withDayOfMonth(from.lengthOfMonth());

            List<Employee> employees = employeeDAO.findAllActive();
            List<PayrollDetail> details = new ArrayList<>();

            for (Employee emp : employees) {
                List<Attendance> atts = attendanceDAO.findByEmployeeAndDateRange(emp.getId(), from, to);
                PayrollDetail d = PayrollCalculator.calculateFromAttendance(emp, atts, rules, holidays);
                details.add(d);
            }

            boolean saved = payrollDAO.savePayrollDetails(payrollId, details);
            if (saved) {
                Flash.success(req, "Calculated payroll for Month " + month + "/" + year 
                        + " across " + details.size() + " employees (DRAFT).");
            } else {
                Flash.error(req, "Could not save payroll details.");
            }

            res.sendRedirect(req.getContextPath() + "/admin/payroll?month=" + month + "&year=" + year);
            return;
        }

        res.sendRedirect(req.getContextPath() + "/admin/payroll");
    }
}
