package controller.account;

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
import util.Constants;
import util.Flash;
import util.PasswordUtil;
import util.UserValidator;

/** Nguoi dung tu doi mat khau (FR-AUTH-04). Moi vai tro deu dung duoc. */
@WebServlet(name = "ChangePasswordServlet", urlPatterns = {"/account/password"})
public class ChangePasswordServlet extends HttpServlet {

    private final AccountDAO accountDAO = new AccountDAO();
    private final UserValidator validator = new UserValidator();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        req.setAttribute("errors", Collections.emptyMap());
        req.getRequestDispatcher("/WEB-INF/views/account/change-password.jsp").forward(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        Account me = (Account) req.getSession().getAttribute(Constants.SESSION_USER);
        String current = req.getParameter("currentPassword");
        String pw = req.getParameter("password");

        Map<String, String> errors = new LinkedHashMap<>();
        if (!PasswordUtil.verify(current, me.getPasswordHash())) {
            errors.put("currentPassword", "Mật khẩu hiện tại không đúng.");
        }
        validator.validatePassword(pw, req.getParameter("confirmPassword"), me.getUsername(), errors);
        if (!errors.containsKey("password") && pw != null && pw.equals(current)) {
            errors.put("password", "Mật khẩu mới phải khác mật khẩu hiện tại.");
        }
        if (!errors.isEmpty()) {
            req.setAttribute("errors", errors);
            req.getRequestDispatcher("/WEB-INF/views/account/change-password.jsp").forward(req, res);
            return;
        }
        accountDAO.updatePassword(me.getId(), PasswordUtil.hash(pw));
        Flash.success(req, "Đổi mật khẩu thành công.");
        res.sendRedirect(req.getContextPath() + me.getRole().getHomePath());
    }
}
