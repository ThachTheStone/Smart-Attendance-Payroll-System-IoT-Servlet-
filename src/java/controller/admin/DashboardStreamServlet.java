package controller.admin;

import java.io.IOException;
import javax.servlet.AsyncContext;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import realtime.SseHub;

/**
 * Server-Sent Events stream for Admin Dashboard (FR-DASH-03, 04, 05, 06).
 * Pushes live scan logs, security alerts, and device status updates.
 */
@WebServlet(name = "DashboardStreamServlet", urlPatterns = {"/admin/dashboard/stream"}, asyncSupported = true)
public class DashboardStreamServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        res.setContentType("text/event-stream");
        res.setCharacterEncoding("UTF-8");
        res.setHeader("Cache-Control", "no-cache, no-transform");
        res.setHeader("Connection", "keep-alive");
        res.setHeader("X-Accel-Buffering", "no");

        AsyncContext asyncContext = req.startAsync();
        asyncContext.setTimeout(0); // Persistent stream

        SseHub.getInstance().register("dashboard", asyncContext);
    }
}
