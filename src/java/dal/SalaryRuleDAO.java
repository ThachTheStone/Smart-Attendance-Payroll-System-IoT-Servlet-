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
                insertDefaultRule(con, "standard_hours_per_month", 208.0, "Standard working hours per month (26 days x 8h)");
                insertDefaultRule(con, "ot_weekday_multiplier", 1.5, "Weekday overtime multiplier (150%)");
                insertDefaultRule(con, "ot_weekend_multiplier", 2.0, "Weekend overtime multiplier (200%)");
                insertDefaultRule(con, "ot_holiday_multiplier", 3.0, "Public holiday overtime multiplier (300%)");
                insertDefaultRule(con, "night_allowance_multiplier", 0.3, "Night shift allowance 22:00 - 06:00 (+30%)");
                insertDefaultRule(con, "night_ot_multiplier", 0.2, "Night overtime bonus multiplier (+20%)");
                insertDefaultRule(con, "grace_period_minutes", 5.0, "Grace period for late arrival without penalty (minutes)");
                insertDefaultRule(con, "penalty_rate_per_minute", 1000.0, "Penalty rate per minute after grace period (VND/min)");
                insertDefaultRule(con, "min_confidence", 50.0, "Minimum fingerprint recognition confidence threshold (%)");
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
