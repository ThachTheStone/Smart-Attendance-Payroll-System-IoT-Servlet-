package controller.api;

import dal.DeviceDAO;
import java.io.IOException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import model.Device;
import service.AttendanceService;
import service.ScanResult;
import util.JsonUtil;

@WebServlet(name = "DeviceScanServlet", urlPatterns = {"/api/device/scan"})
public class DeviceScanServlet extends HttpServlet {

    private final DeviceDAO deviceDAO = new DeviceDAO();
    private final AttendanceService attendanceService = new AttendanceService();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Device device = (Device) request.getAttribute("device");
        deviceDAO.updateHeartbeat(device.getId());

        String body = JsonUtil.readyBody(request);
        Integer templateId = JsonUtil.getInteger(body, "templateId");
        Integer confidence = JsonUtil.getInteger(body, "confidence");

        LocalDateTime now = LocalDateTime.now();
        ScanResult res = attendanceService.processScan(device.getId(), templateId, confidence, now);

        String timeStr = now.format(DateTimeFormatter.ofPattern("HH:mm:ss"));

        // Broadcast to Kiosk & Dashboard via SseHub
        broadcastScanEvents(device, templateId, confidence, res, timeStr);

        StringBuilder json = new StringBuilder("{");
        json.append("\"result\":\"").append(res.getResult()).append("\"");
        json.append(",\"message\":\"").append(JsonUtil.escape(res.getMessage())).append("\"");

        if (res.getEmployee() != null) {
            json.append(",\"employee\":\"").append(JsonUtil.escape(res.getEmployee().getFullName())).append("\"");
            json.append(",\"employeeCode\":\"").append(JsonUtil.escape(res.getEmployee().getCode())).append("\"");
        }
        if (res.getStatus() != null) {
            json.append(",\"status\":\"").append(res.getStatus()).append("\"");
        }
        json.append(",\"time\":\"").append(timeStr).append("\"");
        json.append("}");

        JsonUtil.sendJson(response, HttpServletResponse.SC_OK, json.toString());
    }

    private void broadcastScanEvents(Device device, Integer templateId, Integer confidence, ScanResult res, String timeStr) {
        realtime.SseHub hub = realtime.SseHub.getInstance();

        if (res.isSuccess() && res.getEmployee() != null) {
            model.Employee emp = res.getEmployee();
            int workedMins = (res.getAttendance() != null) ? res.getAttendance().getWorkedMinutes() : 0;
            String statusLabel = (res.getAttendance() != null) ? res.getAttendance().getStatusLabel() : res.getStatus();

            // Kiosk Event (FR-KIOSK-03)
            String kioskPayload = String.format(
                    "{\"type\":\"SCAN_SUCCESS\",\"result\":\"%s\",\"employee\":{\"id\":%d,\"name\":\"%s\",\"code\":\"%s\",\"department\":\"%s\",\"position\":\"%s\",\"photo\":\"%s\"},\"time\":\"%s\",\"status\":\"%s\",\"statusLabel\":\"%s\",\"workedMinutes\":%d,\"message\":\"%s\"}",
                    res.getResult(),
                    emp.getId(),
                    JsonUtil.escape(emp.getFullName()),
                    JsonUtil.escape(emp.getCode()),
                    JsonUtil.escape(emp.getDepartment() != null ? emp.getDepartment() : ""),
                    JsonUtil.escape(emp.getPosition() != null ? emp.getPosition() : ""),
                    JsonUtil.escape(emp.getPhoto() != null ? emp.getPhoto() : ""),
                    timeStr,
                    res.getStatus(),
                    JsonUtil.escape(statusLabel != null ? statusLabel : ""),
                    workedMins,
                    JsonUtil.escape(res.getMessage())
            );
            hub.broadcast("kiosk", "scan", kioskPayload);

            // Dashboard Event (FR-DASH-03)
            String dashPayload = String.format(
                    "{\"type\":\"SCAN_EVENT\",\"result\":\"%s\",\"employeeName\":\"%s\",\"employeeCode\":\"%s\",\"department\":\"%s\",\"time\":\"%s\",\"status\":\"%s\",\"statusLabel\":\"%s\",\"deviceName\":\"%s\",\"confidence\":%d,\"message\":\"%s\"}",
                    res.getResult(),
                    JsonUtil.escape(emp.getFullName()),
                    JsonUtil.escape(emp.getCode()),
                    JsonUtil.escape(emp.getDepartment() != null ? emp.getDepartment() : ""),
                    timeStr,
                    res.getStatus(),
                    JsonUtil.escape(statusLabel != null ? statusLabel : ""),
                    JsonUtil.escape(device.getName()),
                    confidence != null ? confidence : 0,
                    JsonUtil.escape(res.getMessage())
            );
            hub.broadcast("dashboard", "scan_event", dashPayload);

        } else if ("NOT_RECOGNIZED".equals(res.getResult())) {
            // Kiosk Event (FR-KIOSK-04)
            String kioskPayload = String.format(
                    "{\"type\":\"SCAN_FAIL\",\"result\":\"NOT_RECOGNIZED\",\"message\":\"%s\",\"time\":\"%s\"}",
                    JsonUtil.escape(res.getMessage()), timeStr
            );
            hub.broadcast("kiosk", "scan", kioskPayload);

            // Security alert tracking on dashboard (FR-DASH-04)
            hub.recordUnrecognizedScan();
            if (confidence != null && confidence < 50) {
                hub.broadcastLowConfidenceAlert(confidence, 50.0);
            }

            // Dashboard live feed
            String dashPayload = String.format(
                    "{\"type\":\"SCAN_EVENT\",\"result\":\"NOT_RECOGNIZED\",\"employeeName\":\"Unrecognized\",\"employeeCode\":\"--\",\"department\":\"--\",\"time\":\"%s\",\"status\":\"NOT_RECOGNIZED\",\"statusLabel\":\"Not Recognized\",\"deviceName\":\"%s\",\"confidence\":%d,\"message\":\"%s\"}",
                    timeStr, JsonUtil.escape(device.getName()), confidence != null ? confidence : 0, JsonUtil.escape(res.getMessage())
            );
            hub.broadcast("dashboard", "scan_event", dashPayload);

        } else {
            // IGNORED or other
            String kioskPayload = String.format(
                    "{\"type\":\"SCAN_IGNORED\",\"result\":\"%s\",\"message\":\"%s\",\"time\":\"%s\"}",
                    res.getResult(), JsonUtil.escape(res.getMessage()), timeStr
            );
            hub.broadcast("kiosk", "scan", kioskPayload);

            String dashPayload = String.format(
                    "{\"type\":\"SCAN_EVENT\",\"result\":\"%s\",\"employeeName\":\"%s\",\"employeeCode\":\"--\",\"department\":\"--\",\"time\":\"%s\",\"status\":\"IGNORED\",\"statusLabel\":\"Ignored\",\"deviceName\":\"%s\",\"confidence\":%d,\"message\":\"%s\"}",
                    res.getResult(),
                    res.getEmployee() != null ? JsonUtil.escape(res.getEmployee().getFullName()) : "Employee",
                    timeStr, JsonUtil.escape(device.getName()), confidence != null ? confidence : 0, JsonUtil.escape(res.getMessage())
            );
            hub.broadcast("dashboard", "scan_event", dashPayload);
        }
    }
}
