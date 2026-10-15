package controller.admin;

import dal.HolidayDAO;
import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import model.Holiday;
import util.Flash;

@WebServlet(name = "HolidayServlet", urlPatterns = {"/admin/holidays"})
public class HolidayServlet extends HttpServlet {

    private final HolidayDAO holidayDAO = new HolidayDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        List<Holiday> holidays = holidayDAO.findAll();
        req.setAttribute("holidays", holidays);
        req.getRequestDispatcher("/WEB-INF/views/admin/holidays/list.jsp").forward(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");

        if ("delete".equals(action)) {
            String dateStr = req.getParameter("date");
            try {
                LocalDate date = LocalDate.parse(dateStr.trim());
                boolean ok = holidayDAO.delete(date);
                if (ok) Flash.success(req, "Xóa ngày lễ thành công.");
                else Flash.error(req, "Không thể xóa ngày lễ.");
            } catch (DateTimeParseException | NullPointerException e) {
                Flash.error(req, "Ngày không hợp lệ.");
            }
            res.sendRedirect(req.getContextPath() + "/admin/holidays");
            return;
        }

        if ("add".equals(action)) {
            String dateStr = req.getParameter("date");
            String name = req.getParameter("name");

            if (dateStr == null || name == null || dateStr.trim().isEmpty() || name.trim().isEmpty()) {
                Flash.error(req, "Vui lòng nhập ngày và tên ngày lễ.");
                res.sendRedirect(req.getContextPath() + "/admin/holidays");
                return;
            }

            LocalDate date;
            try {
                date = LocalDate.parse(dateStr.trim());
            } catch (DateTimeParseException e) {
                Flash.error(req, "Định dạng ngày không hợp lệ.");
                res.sendRedirect(req.getContextPath() + "/admin/holidays");
                return;
            }

            if (holidayDAO.isHoliday(date)) {
                Flash.error(req, "Ngày " + date + " đã tồn tại trong danh sách ngày lễ.");
                res.sendRedirect(req.getContextPath() + "/admin/holidays");
                return;
            }

            boolean ok = holidayDAO.insert(new Holiday(date, name.trim()));
            if (ok) Flash.success(req, "Thêm ngày lễ thành công.");
            else Flash.error(req, "Thêm ngày lễ thất bại.");

            res.sendRedirect(req.getContextPath() + "/admin/holidays");
        }
    }
}
