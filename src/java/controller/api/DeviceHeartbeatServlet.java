/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
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
import util.JsonUtil;

@WebServlet(name = "DeviceHeartbeatServlet", urlPatterns = {"/api/device/heartbeat"})
public class DeviceHeartbeatServlet extends HttpServlet {

    private final DeviceDAO deviceDAO = new DeviceDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // 1. Get authenticated device attached by DeviceApiFilter
        Device device = (Device) request.getAttribute("device");

        // 2. Update last_heartbeat timestamp in database
        deviceDAO.updateHeartbeat(device.getId());

        // Broadcast device online status via SseHub (FR-KIOSK-06, FR-DASH-05)
        realtime.SseHub.getInstance().broadcastDeviceStatus(device.getId(), device.getName(), true);

        // 3. Return current server time
        String serverTime = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
        String json = String.format("{\"ok\":true,\"serverTime\":\"%s\"}", serverTime);

        JsonUtil.sendJson(response, HttpServletResponse.SC_OK, json);
    }
}

