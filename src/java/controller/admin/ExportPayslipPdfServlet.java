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
import service.PayslipPdfService;
import util.Flash;

/**
 * Servlet for exporting PDF payslips for Admin (FR-PAY-05).
 * Supports downloading single employee payslip or entire company batch.
 */
@WebServlet(name = "ExportPayslipPdfServlet", urlPatterns = {"/admin/payroll/export-pdf"})
public class ExportPayslipPdfServlet extends HttpServlet {

    private final PayrollDAO payrollDAO = new PayrollDAO();
    private final PayslipPdfService pdfService = new PayslipPdfService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        String pIdStr = req.getParameter("payrollId");
        String empIdStr = req.getParameter("employeeId");

        if (pIdStr == null || pIdStr.trim().isEmpty()) {
            Flash.error(req, "Thiếu tham số mã bảng lương (payrollId).");
            res.sendRedirect(req.getContextPath() + "/admin/payroll");
            return;
        }

        int payrollId;
        try {
            payrollId = Integer.parseInt(pIdStr.trim());
        } catch (NumberFormatException e) {
            Flash.error(req, "Mã bảng lương không hợp lệ.");
            res.sendRedirect(req.getContextPath() + "/admin/payroll");
            return;
        }

        Payroll payroll = payrollDAO.findById(payrollId);
        if (payroll == null) {
            Flash.error(req, "Không tìm thấy bảng lương tương ứng.");
            res.sendRedirect(req.getContextPath() + "/admin/payroll");
            return;
        }

        try {
            // Case 1: Single employee payslip export
            if (empIdStr != null && !empIdStr.trim().isEmpty() && !empIdStr.equalsIgnoreCase("all")) {
                int employeeId = Integer.parseInt(empIdStr.trim());
                PayrollDetail detail = payrollDAO.findDetailByPayrollAndEmployee(payrollId, employeeId);
                if (detail == null) {
                    Flash.error(req, "Không tìm thấy dữ liệu phiếu lương của nhân viên này.");
                    res.sendRedirect(req.getContextPath() + "/admin/payroll?month=" + payroll.getMonth() + "&year=" + payroll.getYear());
                    return;
                }

                String filename = "Payslip_" + (detail.getEmployeeCode() != null ? detail.getEmployeeCode() : "NV" + employeeId)
                        + "_" + String.format("%02d", payroll.getMonth()) + "_" + payroll.getYear() + ".pdf";

                res.setContentType("application/pdf");
                res.setHeader("Content-Disposition", "attachment; filename=\"" + filename + "\"");
                pdfService.generatePayslipPdf(detail, payroll.getMonth(), payroll.getYear(), res.getOutputStream());
                return;
            }

            // Case 2: Batch company-wide PDF export
            List<PayrollDetail> details = payrollDAO.findDetailsByPayrollId(payrollId);
            if (details.isEmpty()) {
                Flash.error(req, "Bảng lương chưa có dữ liệu nhân sự để xuất PDF.");
                res.sendRedirect(req.getContextPath() + "/admin/payroll?month=" + payroll.getMonth() + "&year=" + payroll.getYear());
                return;
            }

            String filename = "Payroll_Batch_" + String.format("%02d", payroll.getMonth()) + "_" + payroll.getYear() + ".pdf";
            res.setContentType("application/pdf");
            res.setHeader("Content-Disposition", "attachment; filename=\"" + filename + "\"");
            pdfService.generateBatchPayslipsPdf(details, payroll.getMonth(), payroll.getYear(), res.getOutputStream());

        } catch (Exception e) {
            e.printStackTrace();
            Flash.error(req, "Lỗi trong quá trình tạo tệp PDF: " + e.getMessage());
            res.sendRedirect(req.getContextPath() + "/admin/payroll?month=" + payroll.getMonth() + "&year=" + payroll.getYear());
        }
    }
}
