/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller.api;

import dal.DeviceCommandDAO;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import model.Device;
import model.DeviceCommand;
import util.JsonUtil;

@WebServlet(name = "DeviceCommandServlet", urlPatterns = {"/api/device/command"})
public class DeviceCommandServlet extends HttpServlet {

    private final DeviceCommandDAO commandDAO = new DeviceCommandDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        Device device = (Device) request.getAttribute("device");

        // Find the oldest PENDING command for this device
        DeviceCommand cmd = commandDAO.findPendingByDeviceId(device.getId());

        if (cmd == null) {
            // No command pending
            JsonUtil.sendJson(response, HttpServletResponse.SC_OK, "{}");
            return;
        }

        // Return command details: {"id":5, "type":"ENROLL", "templateId":13}
        String json = String.format("{\"id\":%d,\"type\":\"%s\",\"templateId\":%d}",
                cmd.getId(), cmd.getType(), cmd.getTemplateId());

        JsonUtil.sendJson(response, HttpServletResponse.SC_OK, json);
    }
}

