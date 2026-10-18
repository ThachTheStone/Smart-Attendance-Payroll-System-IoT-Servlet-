package spotbugs.testcase;

import java.util.List;

/**
 * SB-TC10 (Performance - Noi chuoi trong vong lap) - gom log cham cong thanh 1 chuoi bao cao.
 * Ky vong SpotBugs: SBSC_USE_STRINGBUFFER_CONCATENATION tai bugBuildReport.
 */
public class SBTC10_LoopConcat {

    // BUG: moi vong lap tao String moi, O(n^2) khi gom hang nghin log
    public String bugBuildReport(List<String> attendanceLogs) {
        String report = "";
        for (String log : attendanceLogs) {
            report = report + log + "\n";
        }
        return report;
    }

    // FIX: dung StringBuilder
    public String fixedBuildReport(List<String> attendanceLogs) {
        StringBuilder report = new StringBuilder();
        for (String log : attendanceLogs) {
            report.append(log).append('\n');
        }
        return report.toString();
    }
}
