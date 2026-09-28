package filter;

import dal.AccountDAO;
import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import model.Account;
import model.Role;
import util.Constants;

/**
 * Phan quyen theo vai tro (FR-AUTH-03). Khai bao trong web.xml cho:
 *   /admin/*   -> chi ADMIN
 *   /staff/*   -> chi STAFF
 *   /kiosk/*   -> chi KIOSK
 *   /account/* -> moi vai tro da dang nhap (doi mat khau)
 * Chua dang nhap -> ve /login. Sai vai tro -> trang 403.
 */
public class AuthFilter implements Filter {

    private final AccountDAO accountDAO = new AccountDAO();

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;

        // Khong cho trinh duyet cache trang can dang nhap -> logout xong bam Back khong xem lai duoc
        res.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        res.setHeader("Pragma", "no-cache");
        res.setDateHeader("Expires", 0);

        HttpSession session = req.getSession(false);
        Account acc = session == null ? null : (Account) session.getAttribute(Constants.SESSION_USER);
        if (acc == null) {
            res.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        // Doc lai tu DB: neu admin vua khoa tai khoan / doi vai tro thi co hieu luc ngay
        Account fresh = accountDAO.findById(acc.getId());
        if (fresh == null || !fresh.isActive()) {
            session.invalidate();
            res.sendRedirect(req.getContextPath() + "/login?disabled=1");
            return;
        }
        session.setAttribute(Constants.SESSION_USER, fresh);
        acc = fresh;

        String path = req.getRequestURI().substring(req.getContextPath().length());
        Role required = requiredRole(path);
        if (required != null && acc.getRole() != required) {
            res.setStatus(HttpServletResponse.SC_FORBIDDEN);
            req.getRequestDispatcher("/WEB-INF/views/common/403.jsp").forward(req, res);
            return;
        }
        chain.doFilter(request, response);
    }

    private Role requiredRole(String path) {
        if (path.equals("/admin") || path.startsWith("/admin/")) return Role.ADMIN;
        if (path.equals("/staff") || path.startsWith("/staff/")) return Role.STAFF;
        if (path.equals("/kiosk") || path.startsWith("/kiosk/")) return Role.KIOSK;
        return null; // /account/* : ai dang nhap cung vao duoc
    }
}
