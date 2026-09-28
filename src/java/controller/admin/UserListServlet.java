package controller.admin;

import dal.AccountDAO;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;
import model.Account;
import model.Role;

/** Danh sach user + tim kiem / loc theo vai tro, trang thai. */
@WebServlet(name = "UserListServlet", urlPatterns = {"/admin/users"})
public class UserListServlet extends HttpServlet {

    private final AccountDAO accountDAO = new AccountDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        String q = req.getParameter("q");
        Role role = Role.parse(req.getParameter("role"));
        String status = req.getParameter("status");
        if (status != null && !status.equals("ACTIVE") && !status.equals("INACTIVE")) {
            status = null;
        }

        List<Account> users = accountDAO.search(q, role, status);
        List<Account> all = accountDAO.search(null, null, null);

        req.setAttribute("users", users);
        req.setAttribute("q", q);
        req.setAttribute("roleFilter", role == null ? "" : role.name());
        req.setAttribute("statusFilter", status == null ? "" : status);
        req.setAttribute("roles", Role.values());
        req.setAttribute("totalCount", all.size());
        req.setAttribute("adminCount", all.stream().filter(a -> a.getRole() == Role.ADMIN).count());
        req.setAttribute("staffCount", all.stream().filter(a -> a.getRole() == Role.STAFF).count());
        req.setAttribute("inactiveCount", all.stream().filter(a -> !a.isActive()).count());
        req.getRequestDispatcher("/WEB-INF/views/admin/users.jsp").forward(req, res);
    }
}
