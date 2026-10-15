package model;

import java.math.BigDecimal;

public class SalaryRule {
    private String ruleKey;
    private BigDecimal value;
    private String description;

    public SalaryRule() {
    }

    public SalaryRule(String ruleKey, BigDecimal value, String description) {
        this.ruleKey = ruleKey;
        this.value = value;
        this.description = description;
    }

    public String getRuleKey() {
        return ruleKey;
    }

    public void setRuleKey(String ruleKey) {
        this.ruleKey = ruleKey;
    }

    public BigDecimal getValue() {
        return value;
    }

    public void setValue(BigDecimal value) {
        this.value = value;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public double getDoubleValue() {
        return value != null ? value.doubleValue() : 0.0;
    }

    public int getIntValue() {
        return value != null ? value.intValue() : 0;
    }
}
