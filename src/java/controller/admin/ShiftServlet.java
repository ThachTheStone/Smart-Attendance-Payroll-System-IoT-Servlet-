package controller.admin;

import dal.ShiftDAO;
import java.io.IOException;
import java.time.LocalTime;
import java.time.format.DateTimeParseException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import model.Shift;
import util.Flash;

@WebServlet(name = "ShiftServlet", urlPatterns = {"/admin/shifts"})
public class ShiftServlet extends HttpServlet {

    private final ShiftDAO shiftDAO = new ShiftDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        String action = req.getParameter("action");
        if ("edit".equals(action)) {
            try {
                int id = Integer.parseInt(req.getParameter("id"));
                Shift shift = shiftDAO.findById(id);
                if (shift != null) {
                    req.setAttribute("shift", shift);
                }
            } catch (NumberFormatException ignored) {
            }
        }

        List<Shift> shifts = shiftDAO.findAll();
        req.setAttribute("shifts", shifts);
        req.getRequestDispatcher("/WEB-INF/views/admin/shifts/list.jsp").forward(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");

        if ("delete".equals(action)) {
            try {
                int id = Integer.parseInt(req.getParameter("id"));
                boolean deleted = shiftDAO.delete(id);
                if (deleted) {
                    Flash.success(req, "Shift deleted successfully.");
                } else {
                    Flash.error(req, "Cannot delete shift (currently assigned to employees or has attendance records).");
                }
            } catch (NumberFormatException e) {
                Flash.error(req, "Invalid shift ID.");
            }
            res.sendRedirect(req.getContextPath() + "/admin/shifts");
            return;
        }

        // Save (Create or Update)
        String idStr = req.getParameter("id");
        String name = req.getParameter("name");
        String startStr = req.getParameter("startTime");
        String endStr = req.getParameter("endTime");
        String breakStr = req.getParameter("breakMinutes");

        int id = 0;
        if (idStr != null && !idStr.trim().isEmpty()) {
            try {
                id = Integer.parseInt(idStr.trim());
            } catch (NumberFormatException ignored) {
            }
        }

        if (name == null || name.trim().isEmpty()) {
            Flash.error(req, "Please enter shift name.");
            res.sendRedirect(req.getContextPath() + "/admin/shifts");
            return;
        }

        name = name.trim();
        if (shiftDAO.existsName(name, id)) {
            Flash.error(req, "Shift name '" + name + "' already exists.");
            res.sendRedirect(req.getContextPath() + "/admin/shifts");
            return;
        }

        LocalTime startTime;
        LocalTime endTime;
        try {
            startTime = LocalTime.parse(startStr.trim());
            endTime = LocalTime.parse(endStr.trim());
        } catch (DateTimeParseException | NullPointerException e) {
            Flash.error(req, "Invalid time format (HH:mm).");
            res.sendRedirect(req.getContextPath() + "/admin/shifts");
            return;
        }

        int breakMinutes = 0;
        try {
            if (breakStr != null && !breakStr.trim().isEmpty()) {
                breakMinutes = Integer.parseInt(breakStr.trim());
                if (breakMinutes < 0) breakMinutes = 0;
            }
        } catch (NumberFormatException ignored) {
        }

        Shift shift = new Shift(id, name, startTime, endTime, breakMinutes);
        boolean ok;
        if (id > 0) {
            ok = shiftDAO.update(shift);
            if (ok) Flash.success(req, "Shift updated successfully.");
            else Flash.error(req, "Failed to update shift.");
        } else {
            ok = shiftDAO.insert(shift);
            if (ok) Flash.success(req, "New shift created successfully.");
            else Flash.error(req, "Failed to create new shift.");
        }

        res.sendRedirect(req.getContextPath() + "/admin/shifts");
    }
}
