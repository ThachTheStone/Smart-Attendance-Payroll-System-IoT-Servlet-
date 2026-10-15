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
            Flash.error(req, "ID nhân viên không hợp lệ.");
            res.sendRedirect(req.getContextPath() + "/admin/users");
            return;
        }

        Employee emp = employeeDAO.findById(employeeId);
        if (emp == null) {
            Flash.error(req, "Không tìm thấy nhân viên.");
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
            Flash.error(req, "ID nhân viên không hợp lệ.");
            res.sendRedirect(req.getContextPath() + "/admin/users");
            return;
        }

        Employee emp = employeeDAO.findById(employeeId);
        if (emp == null) {
            Flash.error(req, "Không tìm thấy nhân viên.");
            res.sendRedirect(req.getContextPath() + "/admin/users");
            return;
        }

        if ("enroll".equals(action)) {
            List<Fingerprint> existing = fingerprintDAO.findByEmployeeId(employeeId);
            if (existing.size() >= 2) {
                Flash.error(req, "Mỗi nhân viên chỉ được đăng ký tối đa 2 vân tay (FR-ENROLL-03).");
                res.sendRedirect(req.getContextPath() + "/admin/employees/enroll?id=" + employeeId);
                return;
            }

            DeviceCommand pending = commandDAO.findPendingByEmployeeId(employeeId);
            if (pending != null) {
                Flash.error(req, "Nhân viên này đang có một lệnh đăng ký đang chờ xử lý (Lệnh #" + pending.getId() + ").");
                res.sendRedirect(req.getContextPath() + "/admin/employees/enroll?id=" + employeeId);
                return;
            }

            int freeTemplateId = fingerprintDAO.findFreeTemplateId();
            if (freeTemplateId <= 0) {
                Flash.error(req, "Bộ nhớ cảm biến vân tay đã đầy (162/162). Không thể đăng ký thêm.");
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
                fingerName = "Vân tay " + (existing.size() + 1);
            } else {
                fingerName = fingerName.trim();
            }

            DeviceCommand cmd = new DeviceCommand(deviceId, "ENROLL", freeTemplateId, employeeId, fingerName);
            boolean created = commandDAO.insert(cmd);

            if (created) {
                realtime.SseHub.getInstance().broadcastEnrollStep(cmd.getId(), emp.getFullName(), 
                        "PLACE_FINGER", "Bắt đầu đăng ký cho " + emp.getFullName() + ": Vui lòng đặt ngón tay lên cảm biến (lần 1)");
                Flash.success(req, "Đã gửi lệnh đăng ký vân tay (Slot #" + freeTemplateId 
                        + "). Vui lòng cho nhân viên quét ngón tay tại máy chấm công hoặc Simulator.");
            } else {
                Flash.error(req, "Không thể tạo lệnh đăng ký vân tay.");
            }

            res.sendRedirect(req.getContextPath() + "/admin/employees/enroll?id=" + employeeId);
            return;
        }

        if ("delete".equals(action)) {
            int templateId;
            try {
                templateId = Integer.parseInt(req.getParameter("templateId"));
            } catch (NumberFormatException e) {
                Flash.error(req, "ID vân tay không hợp lệ.");
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

            Flash.success(req, "Đã xóa vân tay và gửi lệnh xóa tới thiết bị (Slot #" + templateId + ").");
            res.sendRedirect(req.getContextPath() + "/admin/employees/enroll?id=" + employeeId);
        }
    }
}
