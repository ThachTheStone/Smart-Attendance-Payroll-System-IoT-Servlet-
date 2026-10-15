package controller.api;

import dal.DeviceCommandDAO;
import dal.FingerprintDAO;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import model.DeviceCommand;
import model.Fingerprint;
import util.JsonUtil;

@WebServlet(name = "DeviceCommandResultServlet", urlPatterns = {"/api/device/command/result"})
public class DeviceCommandResultServlet extends HttpServlet {

    private final DeviceCommandDAO commandDAO = new DeviceCommandDAO();
    private final FingerprintDAO fingerprintDAO = new FingerprintDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String body = JsonUtil.readyBody(request);
        Integer id = JsonUtil.getInteger(body, "id");
        String status = JsonUtil.getString(body, "status");
        String step = JsonUtil.getString(body, "step");

        if (id == null || status == null) {
            JsonUtil.sendJson(response, HttpServletResponse.SC_BAD_REQUEST, 
                    JsonUtil.error("Valid 'id' and 'status' are required"));
            return;
        }

        DeviceCommand cmd = commandDAO.findById(id);
        if (cmd == null) {
            JsonUtil.sendJson(response, HttpServletResponse.SC_NOT_FOUND, 
                    JsonUtil.error("Command not found with id " + id));
            return;
        }

        boolean updated = commandDAO.updateStatus(id, status);

        if (updated) {
            // When command finishes successfully (DONE):
            if ("DONE".equals(status)) {
                if ("ENROLL".equalsIgnoreCase(cmd.getType()) && cmd.getEmployeeId() != null) {
                    Fingerprint fp = new Fingerprint(cmd.getEmployeeId(), cmd.getTemplateId(), 
                            cmd.getFingerName() != null ? cmd.getFingerName() : "New Fingerprint");
                    fingerprintDAO.insert(fp);
                    realtime.SseHub.getInstance().broadcastEnrollStep(cmd.getId(), "", "SUCCESS", "Fingerprint enrolled successfully!");
                } else if ("DELETE".equalsIgnoreCase(cmd.getType())) {
                    fingerprintDAO.deleteByTemplateId(cmd.getTemplateId());
                }
            } else if ("FAILED".equals(status)) {
                realtime.SseHub.getInstance().broadcastEnrollStep(cmd.getId(), "", "FAILED", "Fingerprint enrollment failed, please try again!");
            } else if (step != null && !step.isEmpty()) {
                String msg = getStepMessage(step);
                realtime.SseHub.getInstance().broadcastEnrollStep(cmd.getId(), "", step, msg);
            }

            JsonUtil.sendJson(response, HttpServletResponse.SC_OK, JsonUtil.success());
        } else {
            JsonUtil.sendJson(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, 
                    JsonUtil.error("Failed to update command status"));
        }
    }

    private String getStepMessage(String step) {
        switch (step.toUpperCase()) {
            case "PLACE_FINGER": return "Place finger on the sensor (step 1)";
            case "REMOVE_FINGER": return "Lift finger off the sensor";
            case "PLACE_AGAIN": return "Place the same finger again";
            default: return "Processing fingerprint enrollment...";
        }
    }
}
