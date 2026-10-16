/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package filter;

/**
 *
 * @author ngocthach
 */

import dal.DeviceDAO;
import java.io.IOException;
import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import model.Device;
import util.JsonUtil;

@WebFilter(filterName = "DeviceApiFilter", urlPatterns = {"/api/device/*"}, asyncSupported = true)
public class DeviceApiFilter implements Filter {

    private final DeviceDAO deviceDAO = new DeviceDAO();

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;

        // 1. Read the X-API-Key header
        String apiKey = req.getHeader("X-API-Key");

        if (apiKey == null || apiKey.trim().isEmpty()) {
            JsonUtil.sendJson(res, HttpServletResponse.SC_UNAUTHORIZED, 
                    JsonUtil.error("Missing X-API-Key header"));
            return;
        }

        // 2. Look up the device in database
        Device device = deviceDAO.findByApiKey(apiKey.trim());

        if (device == null) {
            JsonUtil.sendJson(res, HttpServletResponse.SC_UNAUTHORIZED, 
                    JsonUtil.error("Invalid API key"));
            return;
        }

        // 3. Attach the authenticated device to the request so Servlets can use it
        req.setAttribute("device", device);

        // 4. Continue to the target Servlet (Scan, Heartbeat, or Command)
        chain.doFilter(request, response);
    }
}

