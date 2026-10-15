package test;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import model.PayrollDetail;
import service.MailService;
import service.PayslipPdfService;

/**
 * Verification test for PayslipPdfService and MailService (Phase 7: FR-PAY-05, FR-PAY-06).
 */
public class PayslipPdfAndMailTest {

    public static void main(String[] args) {
        System.out.println("=== TESTING PAYSLIP PDF & EMAIL SERVICE ===");

        // 1. Build sample PayrollDetail
        PayrollDetail d1 = new PayrollDetail();
        d1.setEmployeeId(1);
        d1.setEmployeeCode("NV003");
        d1.setEmployeeName("Lê Minh Tuấn");
        d1.setEmployeeEmail("minhtuan.le@smartattend.vn");
        d1.setDepartment("Kỹ thuật");
        d1.setPosition("Kỹ sư phần mềm");
        d1.setSalaryType("MONTHLY");
        d1.setBaseSalary(BigDecimal.valueOf(8320000));
        d1.setHourlyRate(BigDecimal.valueOf(40000));
        d1.setRegularHours(BigDecimal.valueOf(200));
        d1.setRegularPay(BigDecimal.valueOf(8000000));
        d1.setOtWeekdayHours(BigDecimal.valueOf(10));
        d1.setOtWeekdayPay(BigDecimal.valueOf(600000));
        d1.setOtWeekendHours(BigDecimal.ZERO);
        d1.setOtWeekendPay(BigDecimal.ZERO);
        d1.setOtHolidayHours(BigDecimal.ZERO);
        d1.setOtHolidayPay(BigDecimal.ZERO);
        d1.setNightHours(BigDecimal.valueOf(8));
        d1.setNightAllowance(BigDecimal.valueOf(96000));
        d1.setNightOtHours(BigDecimal.ZERO);
        d1.setNightOtBonus(BigDecimal.ZERO);
        d1.setLateMinutes(20);
        d1.setPenalty(BigDecimal.valueOf(20000));
        d1.setNetSalary(BigDecimal.valueOf(8676000));

        PayrollDetail d2 = new PayrollDetail();
        d2.setEmployeeId(2);
        d2.setEmployeeCode("NV001");
        d2.setEmployeeName("Nguyễn Văn An");
        d2.setEmployeeEmail("vanan.nguyen@smartattend.vn");
        d2.setDepartment("Ban Giám Đốc");
        d2.setPosition("Quản lý vận hành");
        d2.setSalaryType("MONTHLY");
        d2.setBaseSalary(BigDecimal.valueOf(15000000));
        d2.setHourlyRate(BigDecimal.valueOf(72115.38));
        d2.setRegularHours(BigDecimal.valueOf(208));
        d2.setRegularPay(BigDecimal.valueOf(15000000));
        d2.setOtWeekdayHours(BigDecimal.ZERO);
        d2.setOtWeekdayPay(BigDecimal.ZERO);
        d2.setOtWeekendHours(BigDecimal.ZERO);
        d2.setOtWeekendPay(BigDecimal.ZERO);
        d2.setOtHolidayHours(BigDecimal.ZERO);
        d2.setOtHolidayPay(BigDecimal.ZERO);
        d2.setNightHours(BigDecimal.ZERO);
        d2.setNightAllowance(BigDecimal.ZERO);
        d2.setNightOtHours(BigDecimal.ZERO);
        d2.setNightOtBonus(BigDecimal.ZERO);
        d2.setLateMinutes(0);
        d2.setPenalty(BigDecimal.ZERO);
        d2.setNetSalary(BigDecimal.valueOf(15000000));

        List<PayrollDetail> batchList = new ArrayList<>();
        batchList.add(d1);
        batchList.add(d2);

        // 2. Test PDF Generation
        PayslipPdfService pdfService = new PayslipPdfService();
        try {
            byte[] singlePdf = pdfService.generatePayslipPdf(d1, 10, 2026);
            System.out.println("[TEST 1] Single PDF Generated: " + singlePdf.length + " bytes.");
            if (singlePdf.length < 1000) {
                throw new RuntimeException("Generated PDF is too small (<1KB)");
            }

            byte[] batchPdf = pdfService.generateBatchPayslipsPdf(batchList, 10, 2026);
            System.out.println("[TEST 2] Batch PDF Generated: " + batchPdf.length + " bytes.");
            if (batchPdf.length <= singlePdf.length) {
                throw new RuntimeException("Batch PDF should be larger than single PDF");
            }
            System.out.println(">>> PDF GENERATION TESTS PASSED! <<<");

            // 3. Test Mail Service
            MailService mailService = new MailService();
            System.out.println("[TEST 3] Mail Service Configured: " + mailService.isConfigured());

            MailService.MailResult mailRes = mailService.sendPayslipEmail(
                    d1.getEmployeeEmail(),
                    d1.getEmployeeName(),
                    10,
                    2026,
                    singlePdf,
                    "Payslip_NV003_10_2026.pdf"
            );

            System.out.println("[TEST 4] Mail Result: success=" + mailRes.isSuccess()
                    + ", simulated=" + mailRes.isSimulated()
                    + ", msg=" + mailRes.getMessage());

            if (!mailRes.isSuccess()) {
                throw new RuntimeException("Mail send failed: " + mailRes.getMessage());
            }
            System.out.println(">>> MAIL SERVICE TESTS PASSED! <<<");

            System.out.println("\nALL PHASE 7 TESTS PASSED SUCCESSFULLY! :)");

        } catch (Exception e) {
            e.printStackTrace();
            System.exit(1);
        }
    }
}
