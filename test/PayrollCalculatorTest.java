package test;

import java.math.BigDecimal;
import java.util.HashMap;
import java.util.Map;
import model.Employee;
import model.PayrollDetail;
import service.PayrollCalculator;

/**
 * Verification test for PayrollCalculator based on SRS Section 5 worked example:
 * Base: 8,320,000 VND, 200h regular, 10h weekday OT, 8h night, 20m late (-20,000)
 * Expected Net Salary: 8,676,000 VND
 */
public class PayrollCalculatorTest {

    public static void main(String[] args) {
        Employee emp = new Employee();
        emp.setId(1);
        emp.setCode("NV003");
        emp.setFullName("Lê Minh Tuấn");
        emp.setSalaryType("MONTHLY");
        emp.setBaseSalary(BigDecimal.valueOf(8320000));

        Map<String, Double> rules = new HashMap<>();
        rules.put("standard_hours_per_month", 208.0);
        rules.put("ot_weekday_multiplier", 1.5);
        rules.put("ot_weekend_multiplier", 2.0);
        rules.put("ot_holiday_multiplier", 3.0);
        rules.put("night_allowance_multiplier", 0.3);
        rules.put("night_ot_multiplier", 0.2);
        rules.put("grace_period_minutes", 5.0);
        rules.put("penalty_rate_per_minute", 1000.0);

        PayrollDetail d = PayrollCalculator.calculate(
                emp,
                200.0, // 200 regular hours
                10.0,  // 10 weekday overtime hours
                0.0,   // 0 weekend hours
                0.0,   // 0 holiday hours
                8.0,   // 8 night hours
                0.0,   // 0 night OT hours
                20,    // 20 minutes late beyond grace
                rules
        );

        System.out.println("=== SRS WORKED EXAMPLE VERIFICATION ===");
        System.out.println("Hourly Rate:      " + d.getHourlyRate() + " (Expected: 40000.00)");
        System.out.println("Regular Pay:      " + d.getRegularPay() + " (Expected: 8000000.00)");
        System.out.println("Overtime Pay:     " + d.getOtWeekdayPay() + " (Expected: 600000.00)");
        System.out.println("Night Allowance:  " + d.getNightAllowance() + " (Expected: 96000.00)");
        System.out.println("Late Penalty:     " + d.getPenalty() + " (Expected: 20000.00)");
        System.out.println("Net Salary:       " + d.getNetSalary() + " (Expected: 8676000.00)");

        boolean passed = d.getNetSalary().compareTo(BigDecimal.valueOf(8676000)) == 0;
        if (passed) {
            System.out.println(">>> TEST PASSED: Net salary matches 8,676,000 VND perfectly! <<<");
        } else {
            System.err.println(">>> TEST FAILED: Expected 8676000 but got " + d.getNetSalary() + " <<<");
            System.exit(1);
        }
    }
}
