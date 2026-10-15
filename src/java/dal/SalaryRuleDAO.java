package dal;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import model.SalaryRule;

public class SalaryRuleDAO extends DBContext {

    public Map<String, SalaryRule> findAll() {
        Map<String, SalaryRule> map = new HashMap<>();
        for (SalaryRule r : findAllList()) {
            map.put(r.getRuleKey(), r);
        }
        return map;
    }

    public List<SalaryRule> findAllList() {
        ensureDefaultRules();
        List<SalaryRule> list = new ArrayList<>();
        String sql = "SELECT rule_key, value, description FROM SalaryRule ORDER BY rule_key ASC";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                SalaryRule r = new SalaryRule(
                        rs.getString("rule_key"),
                        rs.getBigDecimal("value"),
                        rs.getString("description"));
                list.add(r);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public void ensureDefaultRules() {
        String countSql = "SELECT COUNT(*) FROM SalaryRule";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(countSql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next() && rs.getInt(1) == 0) {
                insertDefaultRule(con, "standard_hours_per_month", 208.0, "Số giờ làm việc chuẩn mỗi tháng (26 ngày x 8h)");
                insertDefaultRule(con, "ot_weekday_multiplier", 1.5, "Hệ số làm thêm giờ ngày thường (150%)");
                insertDefaultRule(con, "ot_weekend_multiplier", 2.0, "Hệ số làm thêm giờ ngày nghỉ cuối tuần (200%)");
                insertDefaultRule(con, "ot_holiday_multiplier", 3.0, "Hệ số làm thêm giờ ngày nghỉ lễ/Tết (300%)");
                insertDefaultRule(con, "night_allowance_multiplier", 0.3, "Phụ cấp làm việc ban đêm 22h-06h (+30%)");
                insertDefaultRule(con, "night_ot_multiplier", 0.2, "Thưởng thêm làm thêm giờ vào ban đêm (+20%)");
                insertDefaultRule(con, "grace_period_minutes", 5.0, "Thời gian ân hạn đi muộn không bị phạt (phút)");
                insertDefaultRule(con, "penalty_rate_per_minute", 1000.0, "Mức phạt đi muộn mỗi phút sau ân hạn (VNĐ/phút)");
                insertDefaultRule(con, "min_confidence", 50.0, "Ngưỡng độ tin cậy nhận diện vân tay tối thiểu (%)");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    private void insertDefaultRule(Connection con, String key, double val, String desc) throws SQLException {
        String sql = "INSERT INTO SalaryRule (rule_key, value, description) VALUES (?, ?, ?)";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, key);
            ps.setBigDecimal(2, BigDecimal.valueOf(val));
            ps.setString(3, desc);
            ps.executeUpdate();
        }
    }

    public double getRuleValue(String key, double defaultValue) {
        String sql = "SELECT value FROM SalaryRule WHERE rule_key = ?";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, key);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    BigDecimal val = rs.getBigDecimal("value");
                    if (val != null) return val.doubleValue();
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return defaultValue;
    }

    public boolean update(String key, BigDecimal value) {
        String sql = "UPDATE SalaryRule SET value = ? WHERE rule_key = ?";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setBigDecimal(1, value);
            ps.setString(2, key);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
}
