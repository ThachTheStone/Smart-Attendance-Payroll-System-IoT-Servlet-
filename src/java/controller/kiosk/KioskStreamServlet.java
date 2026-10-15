package controller.kiosk;

import java.io.IOException;
import javax.servlet.AsyncContext;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import realtime.SseHub;

/**
 * Server-Sent Events stream for Kiosk display (FR-KIOSK-01..06).
 * Pushes live scan events, enrollment steps, and device offline banners in real time.
 */
@WebServlet(name = "KioskStreamServlet", urlPatterns = {"/kiosk/stream"}, asyncSupported = true)
public class KioskStreamServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        // Setup SSE response headers
        res.setContentType("text/event-stream");
        res.setCharacterEncoding("UTF-8");
        res.setHeader("Cache-Control", "no-cache, no-transform");
        res.setHeader("Connection", "keep-alive");
        res.setHeader("X-Accel-Buffering", "no");

        // Start async processing
        AsyncContext asyncContext = req.startAsync();
        asyncContext.setTimeout(0); // No timeout (persistent stream)

        SseHub.getInstance().register("kiosk", asyncContext);
    }
}
