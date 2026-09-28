package controller.staff;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * Trang chu STAFF. Sprint nay chi hien thong tin ca nhan.
 * TODO sprint sau (FR-STAFF-01..04): ca hom nay, gio vao, dong ho dem gio lam, lich su cham cong.
 */
@WebServlet(name = "StaffTodayServlet", urlPatterns = {"/staff/today"})
public class StaffTodayServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        req.getRequestDispatcher("/WEB-INF/views/staff/today.jsp").forward(req, res);
    }
}
