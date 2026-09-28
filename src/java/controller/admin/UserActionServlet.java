package controller.admin;

import dal.AccountDAO;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.LinkedHashMap;
import java.util.Collections;
import java.util.Map;
import model.Account;
import model.Role;
import util.Constants;
import util.Flash;
import util.PasswordUtil;
import util.UserValidator;

/**
 * Cac thao tac tren 1 user:
 *   POST /admin/users/status          id, status=ACTIVE|INACTIVE  -> khoa / mo khoa
 *   GET  /admin/users/reset-password  id                          -> form dat lai mat khau
 *   POST /admin/users/reset-password  id, password, confirmPassword (FR-AUTH-04)
 */
@WebServlet(name = "UserActionServlet", urlPatterns = {"/admin/users/status", "/admin/users/reset-password"})
public class UserActionServlet extends HttpServlet {

    private final AccountDAO accountDAO = new AccountDAO();
    private final UserValidator validator = new UserValidator();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        if (!req.getServletPath().endsWith("/reset-password")) {
            res.sendRedirect(req.getContextPath() + "/admin/users");
            return;
        }
        Account target = load(req);
        if (target == null) {
            notFound(req, res);
            return;
        }
        req.setAttribute("target", target);
        req.setAttribute("errors", Collections.emptyMap());
        req.getRequestDispatcher("/WEB-INF/views/admin/reset-password.jsp").forward(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        Account target = load(req);
        if (target == null) {
            notFound(req, res);
            return;
        }
        if (req.getServletPath().endsWith("/status")) {
            changeStatus(req, res, target);
        } else {
            resetPassword(req, res, target);
        }
    }

    private void changeStatus(HttpServletRequest req, HttpServletResponse res, Account target) throws IOException {
        Account me = (Account) req.getSession().getAttribute(Constants.SESSION_USER);
        String status = req.getParameter("status");
        if (!"ACTIVE".equals(status) && !"INACTIVE".equals(status)) {
            Flash.error(req, "Trạng thái không hợp lệ.");
        } else if ("INACTIVE".equals(status) && target.getId() == me.getId()) {
            Flash.error(req, "Bạn không thể tự vô hiệu hóa tài khoản của mình.");
        } else if ("INACTIVE".equals(status) && target.getRole() == Role.ADMIN && accountDAO.countActiveAdmins() <= 1) {
            Flash.error(req, "Không thể vô hiệu hóa admin cuối cùng đang hoạt động.");
        } else {
            accountDAO.updateStatus(target.getId(), status);
            Flash.success(req, ("ACTIVE".equals(status) ? "Đã kích hoạt" : "Đã vô hiệu hóa")
                    + " tài khoản \"" + target.getUsername() + "\".");
        }
        res.sendRedirect(req.getContextPath() + "/admin/users");
    }

    private void resetPassword(HttpServletRequest req, HttpServletResponse res, Account target)
            throws ServletException, IOException {
        Map<String, String> errors = new LinkedHashMap<>();
        String pw = req.getParameter("password");
        validator.validatePassword(pw, req.getParameter("confirmPassword"), target.getUsername(), errors);
        if (!errors.isEmpty()) {
            req.setAttribute("target", target);
            req.setAttribute("errors", errors);
            req.getRequestDispatcher("/WEB-INF/views/admin/reset-password.jsp").forward(req, res);
            return;
        }
        accountDAO.updatePassword(target.getId(), PasswordUtil.hash(pw));
        Flash.success(req, "Đã đặt lại mật khẩu cho \"" + target.getUsername() + "\".");
        res.sendRedirect(req.getContextPath() + "/admin/users");
    }

    private Account load(HttpServletRequest req) {
        try {
            return accountDAO.findById(Integer.parseInt(req.getParameter("id")));
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private void notFound(HttpServletRequest req, HttpServletResponse res) throws IOException {
        Flash.error(req, "Không tìm thấy người dùng.");
        res.sendRedirect(req.getContextPath() + "/admin/users");
    }
}
