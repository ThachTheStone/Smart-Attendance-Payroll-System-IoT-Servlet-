package controller.staff;

import dal.PayrollDAO;
import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import model.Account;
import model.Employee;
import model.PayrollDetail;
import util.Constants;

/**
 * Staff Payslip Portal (FR-PAY-07).
 * Allows staff members to view their payslips from LOCKED payroll months.
 */
@WebServlet(name = "StaffPayslipServlet", urlPatterns = {"/staff/payslips"})
public class StaffPayslipServlet extends HttpServlet {

    private final PayrollDAO payrollDAO = new PayrollDAO();

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
        List<PayrollDetail> lockedPayslips = payrollDAO.findLockedPayslipsByEmployee(emp.getId());

        req.setAttribute("emp", emp);
        req.setAttribute("payslips", lockedPayslips);

        req.getRequestDispatcher("/WEB-INF/views/staff/payslips.jsp").forward(req, res);
    }
}
