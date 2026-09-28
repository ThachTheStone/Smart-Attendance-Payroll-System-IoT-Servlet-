package controller.auth;

import dal.AccountDAO;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import model.Account;
import util.Constants;
import util.PasswordUtil;

/** Dang nhap cho ca 3 vai tro (FR-AUTH-01). Dang nhap xong chuyen ve trang chu cua vai tro. */
@WebServlet(name = "LoginServlet", urlPatterns = {"/login"})
public class LoginServlet extends HttpServlet {

    private static final int MAX_FAILS = 5;
    private static final long LOCK_MILLIS = 60_000;   // khoa 60 giay sau 5 lan sai

    private final AccountDAO accountDAO = new AccountDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        HttpSession s = req.getSession(false);
        Account acc = s == null ? null : (Account) s.getAttribute(Constants.SESSION_USER);
        if (acc != null) {   // da dang nhap roi thi ve thang trang chu
            res.sendRedirect(req.getContextPath() + acc.getRole().getHomePath());
            return;
        }
        req.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        String username = req.getParameter("username") == null ? "" : req.getParameter("username").trim().toLowerCase();
        String password = req.getParameter("password") == null ? "" : req.getParameter("password");
        req.setAttribute("username", username);

        HttpSession session = req.getSession();
        Long lockedUntil = (Long) session.getAttribute("loginLockedUntil");
        if (lockedUntil != null && lockedUntil > System.currentTimeMillis()) {
            long sec = (lockedUntil - System.currentTimeMillis()) / 1000 + 1;
            fail(req, res, "Bạn nhập sai quá " + MAX_FAILS + " lần. Vui lòng thử lại sau " + sec + " giây.");
            return;
        }

        if (username.isEmpty() || password.isEmpty()) {
            fail(req, res, "Vui lòng nhập tên đăng nhập và mật khẩu.");
            return;
        }

        Account acc = accountDAO.findByUsername(username);
        if (acc == null || !PasswordUtil.verify(password, acc.getPasswordHash())) {
            int fails = session.getAttribute("loginFails") == null ? 1 : (Integer) session.getAttribute("loginFails") + 1;
            session.setAttribute("loginFails", fails);
            if (fails >= MAX_FAILS) {
                session.setAttribute("loginLockedUntil", System.currentTimeMillis() + LOCK_MILLIS);
                session.setAttribute("loginFails", 0);
            }
            fail(req, res, "Tên đăng nhập hoặc mật khẩu không đúng.");
            return;
        }
        if (!acc.isActive()) {
            fail(req, res, "Tài khoản đã bị vô hiệu hóa. Vui lòng liên hệ quản trị viên.");
            return;
        }

        // Tao session moi de chong session fixation
        session.invalidate();
        HttpSession newSession = req.getSession(true);
        newSession.setAttribute(Constants.SESSION_USER, acc);
        accountDAO.updateLastLogin(acc.getId());

        res.sendRedirect(req.getContextPath() + acc.getRole().getHomePath());
    }

    private void fail(HttpServletRequest req, HttpServletResponse res, String msg) throws ServletException, IOException {
        req.setAttribute("error", msg);
        req.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(req, res);
    }
}
