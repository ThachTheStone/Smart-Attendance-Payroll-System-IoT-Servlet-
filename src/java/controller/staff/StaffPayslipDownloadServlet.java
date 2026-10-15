package controller.staff;

import dal.PayrollDAO;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import model.Account;
import model.Employee;
import model.Payroll;
import model.PayrollDetail;
import service.PayslipPdfService;
import util.Constants;
import util.Flash;

/**
 * Servlet for Staff to download their own official PDF payslip (FR-PAY-05, FR-PAY-07).
 * Strictly restricted to LOCKED payrolls and the logged-in employee's own record.
 */
@WebServlet(name = "StaffPayslipDownloadServlet", urlPatterns = {"/staff/payslips/download"})
public class StaffPayslipDownloadServlet extends HttpServlet {

    private final PayrollDAO payrollDAO = new PayrollDAO();
    private final PayslipPdfService pdfService = new PayslipPdfService();

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
        String pIdStr = req.getParameter("payrollId");

        if (pIdStr == null || pIdStr.trim().isEmpty()) {
            Flash.error(req, "Thiếu tham số mã kỳ lương.");
            res.sendRedirect(req.getContextPath() + "/staff/payslips");
            return;
        }

        int payrollId;
        try {
            payrollId = Integer.parseInt(pIdStr.trim());
        } catch (NumberFormatException e) {
            Flash.error(req, "Mã kỳ lương không hợp lệ.");
            res.sendRedirect(req.getContextPath() + "/staff/payslips");
            return;
        }

        Payroll payroll = payrollDAO.findById(payrollId);
        if (payroll == null || !payroll.isLocked()) {
            Flash.error(req, "Phiếu lương này chưa được phòng Nhân sự khóa sổ chính thức.");
            res.sendRedirect(req.getContextPath() + "/staff/payslips");
            return;
        }

        PayrollDetail detail = payrollDAO.findDetailByPayrollAndEmployee(payrollId, emp.getId());
        if (detail == null) {
            Flash.error(req, "Không tìm thấy dữ liệu phiếu lương của bạn cho kỳ lương này.");
            res.sendRedirect(req.getContextPath() + "/staff/payslips");
            return;
        }

        try {
            String filename = "Payslip_" + (emp.getCode() != null ? emp.getCode() : "NV" + emp.getId())
                    + "_" + String.format("%02d", payroll.getMonth()) + "_" + payroll.getYear() + ".pdf";

            res.setContentType("application/pdf");
            res.setHeader("Content-Disposition", "attachment; filename=\"" + filename + "\"");
            pdfService.generatePayslipPdf(detail, payroll.getMonth(), payroll.getYear(), res.getOutputStream());
        } catch (Exception e) {
            e.printStackTrace();
            Flash.error(req, "Lỗi trong quá trình tạo phiếu lương PDF: " + e.getMessage());
            res.sendRedirect(req.getContextPath() + "/staff/payslips");
        }
    }
}
