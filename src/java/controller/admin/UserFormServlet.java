package controller.admin;

import dal.AccountDAO;
import dal.EmployeeDAO;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.Collections;
import java.util.Map;
import model.Account;
import model.Employee;
import model.Role;
import model.UserForm;
import util.Constants;
import util.Flash;
import util.PasswordUtil;
import util.UserValidator;

/**
 * Them moi (/admin/users/create) va cap nhat (/admin/users/edit?id=) user.
 * GET hien form, POST validate -> luu -> redirect ve danh sach.
 */
@WebServlet(name = "UserFormServlet", urlPatterns = {"/admin/users/create", "/admin/users/edit"})
public class UserFormServlet extends HttpServlet {

    private final AccountDAO accountDAO = new AccountDAO();
    private final EmployeeDAO employeeDAO = new EmployeeDAO();
    private final UserValidator validator = new UserValidator();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        UserForm form;
        if (isCreate(req)) {
            form = new UserForm();
            form.setRole("STAFF");
            form.setSalaryType("MONTHLY");
            form.setCode(employeeDAO.nextCode());
        } else {
            Account existing = loadExisting(req);
            if (existing == null) {
                Flash.error(req, "Không tìm thấy người dùng.");
                res.sendRedirect(req.getContextPath() + "/admin/users");
                return;
            }
            form = UserForm.fromAccount(existing);
        }
        show(req, res, form, Collections.emptyMap());
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        Account currentUser = (Account) req.getSession().getAttribute(Constants.SESSION_USER);
        boolean create = isCreate(req);
        Account existing = null;
        if (!create) {
            existing = loadExisting(req);
            if (existing == null) {
                Flash.error(req, "Không tìm thấy người dùng.");
                res.sendRedirect(req.getContextPath() + "/admin/users");
                return;
            }
        }

        UserForm form;
        try {
            form = UserForm.fromRequest(req);
        } catch (NumberFormatException e) {
            res.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }
        if (!create) {   // cac field khong duoc sua lay tu DB, khong tin du lieu gui len
            form.setAccountId(existing.getId());
            form.setUsername(existing.getUsername());
            if (existing.getEmployee() != null) {
                form.setCode(existing.getEmployee().getCode());
            }
        }

        Map<String, String> errors = validator.validate(form, existing, currentUser);
        if (!errors.isEmpty()) {
            show(req, res, form, errors);
            return;
        }

        Role role = Role.parse(form.getRole());
        Employee emp = null;
        if (role != Role.KIOSK) {
            emp = new Employee();
            emp.setCode(form.getCode());
            emp.setFullName(form.getFullName());
            emp.setEmail(form.getEmail());
            emp.setPhone(form.getPhone());
            emp.setDepartment(form.getDepartment());
            emp.setPosition(form.getPosition());
            emp.setSalaryType(form.getSalaryType());
            emp.setBaseSalary(new BigDecimal(form.getBaseSalary()));
        }

        if (create) {
            Account acc = new Account();
            acc.setUsername(form.getUsername());
            acc.setPasswordHash(PasswordUtil.hash(form.getPassword()));
            acc.setRole(role);
            accountDAO.create(acc, emp);
            Flash.success(req, "Đã thêm người dùng \"" + form.getUsername() + "\".");
        } else {
            existing.setRole(role);
            if (emp != null) {
                emp.setId(existing.getEmployeeId());
            }
            accountDAO.update(existing, emp);
            Flash.success(req, "Đã cập nhật người dùng \"" + existing.getUsername() + "\".");
        }
        res.sendRedirect(req.getContextPath() + "/admin/users");
    }

    private boolean isCreate(HttpServletRequest req) {
        return req.getServletPath().endsWith("/create");
    }

    private Account loadExisting(HttpServletRequest req) {
        try {
            return accountDAO.findById(Integer.parseInt(req.getParameter("id")));
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private void show(HttpServletRequest req, HttpServletResponse res, UserForm form, Map<String, String> errors)
            throws ServletException, IOException {
        req.setAttribute("form", form);
        req.setAttribute("errors", errors);
        req.setAttribute("roles", Role.values());
        req.setAttribute("departments", Constants.DEPARTMENTS);
        req.getRequestDispatcher("/WEB-INF/views/admin/user-form.jsp").forward(req, res);
    }
}
