package controller.admin;

import dal.PayrollDAO;
import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import model.Payroll;
import model.PayrollDetail;
import service.MailService;
import service.PayslipPdfService;
import util.Flash;

/**
 * Servlet for triggering payslip email delivery (FR-PAY-06).
 * Supports sending to single employee or batch sending to all employees.
 */
@WebServlet(name = "SendPayslipEmailServlet", urlPatterns = {"/admin/payroll/send-email"})
public class SendPayslipEmailServlet extends HttpServlet {

    private final PayrollDAO payrollDAO = new PayrollDAO();
    private final PayslipPdfService pdfService = new PayslipPdfService();
    private final MailService mailService = new MailService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        doPost(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        String pIdStr = req.getParameter("payrollId");
        String empIdStr = req.getParameter("employeeId");
        String sendAllStr = req.getParameter("sendAll");

        if (pIdStr == null || pIdStr.trim().isEmpty()) {
            Flash.error(req, "Missing payroll period ID parameter.");
            res.sendRedirect(req.getContextPath() + "/admin/payroll");
            return;
        }

        int payrollId;
        try {
            payrollId = Integer.parseInt(pIdStr.trim());
        } catch (NumberFormatException e) {
            Flash.error(req, "Invalid payroll period ID.");
            res.sendRedirect(req.getContextPath() + "/admin/payroll");
            return;
        }

        Payroll payroll = payrollDAO.findById(payrollId);
        if (payroll == null) {
            Flash.error(req, "Payroll period not found.");
            res.sendRedirect(req.getContextPath() + "/admin/payroll");
            return;
        }

        String redirectUrl = req.getContextPath() + "/admin/payroll?month=" + payroll.getMonth() + "&year=" + payroll.getYear();

        try {
            boolean isSendAll = "true".equalsIgnoreCase(sendAllStr) || (empIdStr == null || empIdStr.trim().isEmpty() || empIdStr.equalsIgnoreCase("all"));

            if (!isSendAll) {
                // Send to single employee
                int employeeId = Integer.parseInt(empIdStr.trim());
                PayrollDetail d = payrollDAO.findDetailByPayrollAndEmployee(payrollId, employeeId);
                if (d == null) {
                    Flash.error(req, "No payslip data found for this employee.");
                    res.sendRedirect(redirectUrl);
                    return;
                }

                if (d.getEmployeeEmail() == null || d.getEmployeeEmail().trim().isEmpty()) {
                    payrollDAO.updateEmailStatus(payrollId, employeeId, "FAILED");
                    Flash.error(req, "Employee " + d.getEmployeeName() + " has no email address configured.");
                    res.sendRedirect(redirectUrl);
                    return;
                }

                byte[] pdfBytes = pdfService.generatePayslipPdf(d, payroll.getMonth(), payroll.getYear());
                String filename = "Payslip_" + (d.getEmployeeCode() != null ? d.getEmployeeCode() : "NV" + employeeId)
                        + "_" + String.format("%02d", payroll.getMonth()) + "_" + payroll.getYear() + ".pdf";

                MailService.MailResult result = mailService.sendPayslipEmail(
                        d.getEmployeeEmail(),
                        d.getEmployeeName(),
                        payroll.getMonth(),
                        payroll.getYear(),
                        pdfBytes,
                        filename
                );

                payrollDAO.updateEmailStatus(payrollId, employeeId, result.isSuccess() ? "SENT" : "FAILED");

                if (result.isSuccess()) {
                    String prefix = result.isSimulated() ? "[Demo Simulation] " : "";
                    Flash.success(req, prefix + "Payslip email sent successfully to " + d.getEmployeeName() + " (" + d.getEmployeeEmail() + ").");
                } else {
                    Flash.error(req, "Failed to send email: " + result.getMessage());
                }

            } else {
                // Send batch to all employees in this payroll
                List<PayrollDetail> details = payrollDAO.findDetailsByPayrollId(payrollId);
                if (details.isEmpty()) {
                    Flash.error(req, "Payroll has no employee data.");
                    res.sendRedirect(redirectUrl);
                    return;
                }

                int successCount = 0;
                int failCount = 0;
                boolean anySimulated = false;

                for (PayrollDetail d : details) {
                    if (d.getEmployeeEmail() == null || d.getEmployeeEmail().trim().isEmpty()) {
                        payrollDAO.updateEmailStatus(payrollId, d.getEmployeeId(), "FAILED");
                        failCount++;
                        continue;
                    }

                    try {
                        byte[] pdfBytes = pdfService.generatePayslipPdf(d, payroll.getMonth(), payroll.getYear());
                        String filename = "Payslip_" + (d.getEmployeeCode() != null ? d.getEmployeeCode() : "NV" + d.getEmployeeId())
                                + "_" + String.format("%02d", payroll.getMonth()) + "_" + payroll.getYear() + ".pdf";

                        MailService.MailResult result = mailService.sendPayslipEmail(
                                d.getEmployeeEmail(),
                                d.getEmployeeName(),
                                payroll.getMonth(),
                                payroll.getYear(),
                                pdfBytes,
                                filename
                        );

                        if (result.isSuccess()) {
                            payrollDAO.updateEmailStatus(payrollId, d.getEmployeeId(), "SENT");
                            successCount++;
                            if (result.isSimulated()) anySimulated = true;
                        } else {
                            payrollDAO.updateEmailStatus(payrollId, d.getEmployeeId(), "FAILED");
                            failCount++;
                        }
                    } catch (Exception ex) {
                        payrollDAO.updateEmailStatus(payrollId, d.getEmployeeId(), "FAILED");
                        failCount++;
                    }
                }

                String prefix = anySimulated ? "[Demo Simulation] " : "";
                Flash.success(req, prefix + "Email delivery finished: " + successCount + " successful, " + failCount + " failed.");
            }

        } catch (Exception e) {
            e.printStackTrace();
            Flash.error(req, "Error during email delivery: " + e.getMessage());
        }

        res.sendRedirect(redirectUrl);
    }
}
