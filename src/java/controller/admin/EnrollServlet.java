package controller.admin;

import dal.DeviceCommandDAO;
import dal.DeviceDAO;
import dal.EmployeeDAO;
import dal.FingerprintDAO;
import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import model.Device;
import model.DeviceCommand;
import model.Employee;
import model.Fingerprint;
import util.Flash;

@WebServlet(name = "EnrollServlet", urlPatterns = {"/admin/employees/enroll"})
public class EnrollServlet extends HttpServlet {

    private final EmployeeDAO employeeDAO = new EmployeeDAO();
    private final FingerprintDAO fingerprintDAO = new FingerprintDAO();
    private final DeviceDAO deviceDAO = new DeviceDAO();
    private final DeviceCommandDAO commandDAO = new DeviceCommandDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        int employeeId;
        try {
            employeeId = Integer.parseInt(req.getParameter("id"));
        } catch (NumberFormatException e) {
            Flash.error(req, "Invalid employee ID.");
            res.sendRedirect(req.getContextPath() + "/admin/users");
            return;
        }

        Employee emp = employeeDAO.findById(employeeId);
        if (emp == null) {
            Flash.error(req, "Employee not found.");
            res.sendRedirect(req.getContextPath() + "/admin/users");
            return;
        }

        List<Fingerprint> fingerprints = fingerprintDAO.findByEmployeeId(employeeId);
        DeviceCommand pendingCmd = commandDAO.findPendingByEmployeeId(employeeId);
        int totalEnrolled = fingerprintDAO.countTotalEnrolled();
        List<Device> devices = deviceDAO.findAll();

        req.setAttribute("emp", emp);
        req.setAttribute("fingerprints", fingerprints);
        req.setAttribute("pendingCmd", pendingCmd);
        req.setAttribute("totalEnrolled", totalEnrolled);
        req.setAttribute("devices", devices);

        req.getRequestDispatcher("/WEB-INF/views/admin/enroll.jsp").forward(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");
        int employeeId;
        try {
            employeeId = Integer.parseInt(req.getParameter("employeeId"));
        } catch (NumberFormatException e) {
            Flash.error(req, "Invalid employee ID.");
            res.sendRedirect(req.getContextPath() + "/admin/users");
            return;
        }

        Employee emp = employeeDAO.findById(employeeId);
        if (emp == null) {
            Flash.error(req, "Employee not found.");
            res.sendRedirect(req.getContextPath() + "/admin/users");
            return;
        }

        if ("enroll".equals(action)) {
            List<Fingerprint> existing = fingerprintDAO.findByEmployeeId(employeeId);
            if (existing.size() >= 2) {
                Flash.error(req, "Each employee can only register up to 2 fingerprints (FR-ENROLL-03).");
                res.sendRedirect(req.getContextPath() + "/admin/employees/enroll?id=" + employeeId);
                return;
            }

            DeviceCommand pending = commandDAO.findPendingByEmployeeId(employeeId);
            if (pending != null) {
                Flash.error(req, "This employee has a pending enrollment command (Command #" + pending.getId() + ").");
                res.sendRedirect(req.getContextPath() + "/admin/employees/enroll?id=" + employeeId);
                return;
            }

            int freeTemplateId = fingerprintDAO.findFreeTemplateId();
            if (freeTemplateId <= 0) {
                Flash.error(req, "Fingerprint sensor memory is full (162/162). Cannot enroll more.");
                res.sendRedirect(req.getContextPath() + "/admin/employees/enroll?id=" + employeeId);
                return;
            }

            int deviceId = 1;
            try {
                deviceId = Integer.parseInt(req.getParameter("deviceId"));
            } catch (NumberFormatException ignored) {
            }

            String fingerName = req.getParameter("fingerName");
            if (fingerName == null || fingerName.trim().isEmpty()) {
                fingerName = "Fingerprint " + (existing.size() + 1);
            } else {
                fingerName = fingerName.trim();
            }

            DeviceCommand cmd = new DeviceCommand(deviceId, "ENROLL", freeTemplateId, employeeId, fingerName);
            boolean created = commandDAO.insert(cmd);

            if (created) {
                realtime.SseHub.getInstance().broadcastEnrollStep(cmd.getId(), emp.getFullName(), 
                        "PLACE_FINGER", "Starting enrollment for " + emp.getFullName() + ": Please place finger on sensor (step 1)");
                Flash.success(req, "Fingerprint enrollment command sent (Slot #" + freeTemplateId 
                        + "). Please place finger on the scanner or simulator.");
            } else {
                Flash.error(req, "Could not create fingerprint enrollment command.");
            }

            res.sendRedirect(req.getContextPath() + "/admin/employees/enroll?id=" + employeeId);
            return;
        }

        if ("delete".equals(action)) {
            int templateId;
            try {
                templateId = Integer.parseInt(req.getParameter("templateId"));
            } catch (NumberFormatException e) {
                Flash.error(req, "Invalid fingerprint ID.");
                res.sendRedirect(req.getContextPath() + "/admin/employees/enroll?id=" + employeeId);
                return;
            }

            // 1. Delete from database
            fingerprintDAO.deleteByTemplateId(templateId);

            // 2. Queue DELETE command to all devices
            List<Device> devices = deviceDAO.findAll();
            for (Device d : devices) {
                commandDAO.insert(new DeviceCommand(d.getId(), "DELETE", templateId, employeeId, null));
            }

            Flash.success(req, "Fingerprint deleted and removal command sent to devices (Slot #" + templateId + ").");
            res.sendRedirect(req.getContextPath() + "/admin/employees/enroll?id=" + employeeId);
        }
    }
}
