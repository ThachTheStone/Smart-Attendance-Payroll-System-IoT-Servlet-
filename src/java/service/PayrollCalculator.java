package service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.DayOfWeek;
import java.time.Duration;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;
import java.util.Map;
import java.util.Set;
import model.Attendance;
import model.Employee;
import model.PayrollDetail;

/**
 * Pure function salary calculation engine according to Vietnamese Labor Code & SRS Section 5.
 * Reproduces the SRS worked example:
 * Base: 8,320,000 VND, 200h reg, 10h weekday OT (150%), 8h night (30%), 20m late (-20k) => 8,676,000 VND.
 */
public class PayrollCalculator {

    public static final double DEFAULT_STANDARD_HOURS = 208.0;
    public static final double DEFAULT_OT_WEEKDAY = 1.5;
    public static final double DEFAULT_OT_WEEKEND = 2.0;
    public static final double DEFAULT_OT_HOLIDAY = 3.0;
    public static final double DEFAULT_NIGHT_ALLOWANCE = 0.3;
    public static final double DEFAULT_NIGHT_OT = 0.2;
    public static final double DEFAULT_GRACE_MINUTES = 5.0;
    public static final double DEFAULT_PENALTY_RATE = 1000.0;

    /**
     * Pure function that calculates payroll details directly from aggregated hours and rates.
     */
    public static PayrollDetail calculate(
            Employee emp,
            double regularHours,
            double otWeekdayHours,
            double otWeekendHours,
            double otHolidayHours,
            double nightHours,
            double nightOtHours,
            int penalizedLateMinutes,
            Map<String, Double> rules) {

        double standardHours = getRule(rules, "standard_hours_per_month", DEFAULT_STANDARD_HOURS);
        double otWeekdayMult = getRule(rules, "ot_weekday_multiplier", DEFAULT_OT_WEEKDAY);
        double otWeekendMult = getRule(rules, "ot_weekend_multiplier", DEFAULT_OT_WEEKEND);
        double otHolidayMult = getRule(rules, "ot_holiday_multiplier", DEFAULT_OT_HOLIDAY);
        double nightMult = getRule(rules, "night_allowance_multiplier", DEFAULT_NIGHT_ALLOWANCE);
        double nightOtMult = getRule(rules, "night_ot_multiplier", DEFAULT_NIGHT_OT);
        double penaltyRate = getRule(rules, "penalty_rate_per_minute", DEFAULT_PENALTY_RATE);

        double baseSalary = emp.getBaseSalary() != null ? emp.getBaseSalary().doubleValue() : 0.0;

        // 1. Hourly rate (SRS Section 5)
        double hourlyRate;
        if ("HOURLY".equalsIgnoreCase(emp.getSalaryType())) {
            hourlyRate = baseSalary;
        } else {
            hourlyRate = standardHours > 0 ? (baseSalary / standardHours) : 0.0;
        }

        // 2. Earnings components
        double regularPay = regularHours * hourlyRate;
        double otWeekdayPay = otWeekdayHours * hourlyRate * otWeekdayMult;
        double otWeekendPay = otWeekendHours * hourlyRate * otWeekendMult;
        double otHolidayPay = otHolidayHours * hourlyRate * otHolidayMult;
        double nightAllowance = nightHours * hourlyRate * nightMult;
        double nightOtBonus = nightOtHours * hourlyRate * nightOtMult;

        // 3. Penalty
        double penalty = penalizedLateMinutes * penaltyRate;

        // 4. Net salary = Regular + Overtime + Night Allowance + Night OT Bonus - Penalty
        double netSalary = regularPay + otWeekdayPay + otWeekendPay + otHolidayPay + nightAllowance + nightOtBonus - penalty;
        if (netSalary < 0) netSalary = 0.0;

        PayrollDetail d = new PayrollDetail();
        d.setEmployeeId(emp.getId());
        d.setEmployeeCode(emp.getCode());
        d.setEmployeeName(emp.getFullName());
        d.setDepartment(emp.getDepartment());
        d.setPosition(emp.getPosition());
        d.setSalaryType(emp.getSalaryType());
        d.setBaseSalary(toMoney(baseSalary));

        d.setHourlyRate(toMoney(hourlyRate));
        d.setRegularHours(toHours(regularHours));
        d.setOtWeekdayHours(toHours(otWeekdayHours));
        d.setOtWeekendHours(toHours(otWeekendHours));
        d.setOtHolidayHours(toHours(otHolidayHours));
        d.setNightHours(toHours(nightHours));
        d.setNightOtHours(toHours(nightOtHours));
        d.setLateMinutes(penalizedLateMinutes);

        d.setRegularPay(toMoney(regularPay));
        d.setOtWeekdayPay(toMoney(otWeekdayPay));
        d.setOtWeekendPay(toMoney(otWeekendPay));
        d.setOtHolidayPay(toMoney(otHolidayPay));
        d.setNightAllowance(toMoney(nightAllowance));
        d.setNightOtBonus(toMoney(nightOtBonus));
        d.setPenalty(toMoney(penalty));
        d.setNetSalary(toMoney(netSalary));

        return d;
    }

    /**
     * Calculates PayrollDetail by processing a full month's raw attendance records for an employee.
     */
    public static PayrollDetail calculateFromAttendance(
            Employee emp,
            List<Attendance> attendances,
            Map<String, Double> rules,
            Set<LocalDate> holidays) {

        double regularHours = 0.0;
        double otWeekdayHours = 0.0;
        double otWeekendHours = 0.0;
        double otHolidayHours = 0.0;
        double nightHours = 0.0;
        double nightOtHours = 0.0;
        int totalPenalizedLateMinutes = 0;

        double graceMinutes = getRule(rules, "grace_period_minutes", DEFAULT_GRACE_MINUTES);

        if (attendances != null) {
            for (Attendance a : attendances) {
                if (a.getCheckIn() == null || "ABSENT".equalsIgnoreCase(a.getStatus())) {
                    continue;
                }

                int workedMins = a.getWorkedMinutes();
                LocalDate date = a.getWorkDate();
                boolean isHoliday = holidays != null && holidays.contains(date);
                boolean isWeekend = (date.getDayOfWeek() == DayOfWeek.SATURDAY || date.getDayOfWeek() == DayOfWeek.SUNDAY);

                // Standard shift duration is 8 hours (480 minutes)
                int standardMins = 480;
                int regMins = Math.min(workedMins, standardMins);
                int otMins = Math.max(0, workedMins - standardMins);

                regularHours += (regMins / 60.0);

                if (otMins > 0) {
                    double otH = otMins / 60.0;
                    if (isHoliday) {
                        otHolidayHours += otH;
                    } else if (isWeekend) {
                        otWeekendHours += otH;
                    } else {
                        otWeekdayHours += otH;
                    }
                }

                // Night work calculation (22:00 to 06:00 next day)
                if (a.getCheckOut() != null) {
                    long nightMins = calculateNightMinutes(a.getCheckIn(), a.getCheckOut());
                    if (nightMins > 0) {
                        double nH = nightMins / 60.0;
                        if (otMins > 0) {
                            nightOtHours += Math.min(nH, otMins / 60.0);
                            nightHours += Math.max(0, nH - (otMins / 60.0));
                        } else {
                            nightHours += nH;
                        }
                    }
                }

                // Late arrival penalty calculation
                if (a.getShiftStartTime() != null) {
                    LocalTime checkInTime = a.getCheckIn().toLocalTime();
                    if (checkInTime.isAfter(a.getShiftStartTime())) {
                        long lateMins = Duration.between(a.getShiftStartTime(), checkInTime).toMinutes();
                        if (lateMins > graceMinutes) {
                            totalPenalizedLateMinutes += (int) (lateMins - graceMinutes);
                        }
                    }
                }
            }
        }

        return calculate(emp, regularHours, otWeekdayHours, otWeekendHours, otHolidayHours,
                nightHours, nightOtHours, totalPenalizedLateMinutes, rules);
    }

    /**
     * Calculates the number of minutes elapsed between check-in and check-out that fall within 22:00 to 06:00.
     */
    public static long calculateNightMinutes(LocalDateTime in, LocalDateTime out) {
        if (in == null || out == null || in.isAfter(out)) return 0;

        long nightMins = 0;
        LocalDateTime cur = in;

        // Iterate in small steps or hour intervals
        while (cur.isBefore(out)) {
            int h = cur.getHour();
            boolean isNight = (h >= 22 || h < 6);
            if (isNight) {
                nightMins++;
            }
            cur = cur.plusMinutes(1);
        }

        return nightMins;
    }

    private static double getRule(Map<String, Double> rules, String key, double def) {
        if (rules == null || !rules.containsKey(key)) return def;
        Double v = rules.get(key);
        return v != null ? v : def;
    }

    private static BigDecimal toMoney(double v) {
        return BigDecimal.valueOf(Math.round(v)).setScale(2, RoundingMode.HALF_UP);
    }

    private static BigDecimal toHours(double v) {
        return BigDecimal.valueOf(Math.round(v * 100.0) / 100.0).setScale(2, RoundingMode.HALF_UP);
    }
}
