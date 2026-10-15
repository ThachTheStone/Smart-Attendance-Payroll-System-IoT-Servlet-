package controller.admin;

import dal.SalaryRuleDAO;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import model.SalaryRule;
import util.Flash;

/**
 * Salary Rules Configuration Servlet (FR-RULE-01..07).
 * Allows Admin to configure overtime multipliers, night allowances, grace periods, and penalties.
 */
@WebServlet(name = "SalaryRuleServlet", urlPatterns = {"/admin/rules"})
public class SalaryRuleServlet extends HttpServlet {

    private final SalaryRuleDAO salaryRuleDAO = new SalaryRuleDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        List<SalaryRule> rules = salaryRuleDAO.findAllList();
        req.setAttribute("rules", rules);
        req.getRequestDispatcher("/WEB-INF/views/admin/rules/index.jsp").forward(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        List<SalaryRule> rules = salaryRuleDAO.findAllList();
        int updatedCount = 0;

        for (SalaryRule r : rules) {
            String valStr = req.getParameter("rule_" + r.getRuleKey());
            if (valStr != null && !valStr.trim().isEmpty()) {
                try {
                    BigDecimal newVal = new BigDecimal(valStr.trim());
                    if (r.getValue() == null || newVal.compareTo(r.getValue()) != 0) {
                        salaryRuleDAO.update(r.getRuleKey(), newVal);
                        updatedCount++;
                    }
                } catch (NumberFormatException ignored) {
                }
            }
        }

        if (updatedCount > 0) {
            Flash.success(req, "Đã cập nhật thành công " + updatedCount + " quy tắc tính lương.");
        } else {
            Flash.info(req, "Không có thay đổi nào được lưu.");
        }

        res.sendRedirect(req.getContextPath() + "/admin/rules");
    }
}
