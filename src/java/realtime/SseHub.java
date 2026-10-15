package realtime;

import java.io.IOException;
import java.io.PrintWriter;
import java.nio.charset.StandardCharsets;
import java.util.Collections;
import java.util.Deque;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentLinkedDeque;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.servlet.AsyncContext;
import javax.servlet.AsyncEvent;
import javax.servlet.AsyncListener;
import javax.servlet.ServletResponse;

/**
 * Central broker for Server-Sent Events (SSE) (FR-KIOSK-01, FR-DASH-06).
 * Maintains active HTTP connections and broadcasts real-time events to connected clients.
 */
public class SseHub {

    private static final Logger LOGGER = Logger.getLogger(SseHub.class.getName());
    private static final SseHub INSTANCE = new SseHub();

    // Map channel name ("kiosk", "dashboard") to active AsyncContexts
    private final Map<String, Set<AsyncContext>> channels = new ConcurrentHashMap<>();

    // Sliding window of timestamps for unrecognized fingerprint scans within last 60 seconds (FR-DASH-04)
    private final Deque<Long> unrecognizedScanTimestamps = new ConcurrentLinkedDeque<>();

    private SseHub() {
        channels.put("kiosk", Collections.newSetFromMap(new ConcurrentHashMap<>()));
        channels.put("dashboard", Collections.newSetFromMap(new ConcurrentHashMap<>()));
    }

    public static SseHub getInstance() {
        return INSTANCE;
    }

    /**
     * Registers a client's AsyncContext to a channel.
     */
    public void register(String channel, AsyncContext ctx) {
        Set<AsyncContext> subscribers = channels.computeIfAbsent(channel,
                k -> Collections.newSetFromMap(new ConcurrentHashMap<>()));

        subscribers.add(ctx);

        ctx.addListener(new AsyncListener() {
            @Override
            public void onComplete(AsyncEvent event) {
                subscribers.remove(ctx);
            }

            @Override
            public void onTimeout(AsyncEvent event) {
                subscribers.remove(ctx);
                try {
                    ctx.complete();
                } catch (Exception ignored) {
                }
            }

            @Override
            public void onError(AsyncEvent event) {
                subscribers.remove(ctx);
                try {
                    ctx.complete();
                } catch (Exception ignored) {
                }
            }

            @Override
            public void onStartAsync(AsyncEvent event) {
            }
        });

        // Send welcome / handshake message
        sendDirect(ctx, "connected", "{\"channel\":\"" + channel + "\",\"time\":" + System.currentTimeMillis() + "}");
    }

    /**
     * Broadcasts an SSE event to all subscribers of a channel.
     */
    public void broadcast(String channel, String eventName, String jsonData) {
        Set<AsyncContext> subscribers = channels.get(channel);
        if (subscribers == null || subscribers.isEmpty()) {
            return;
        }

        Iterator<AsyncContext> it = subscribers.iterator();
        while (it.hasNext()) {
            AsyncContext ctx = it.next();
            boolean success = sendDirect(ctx, eventName, jsonData);
            if (!success) {
                it.remove();
                try {
                    ctx.complete();
                } catch (Exception ignored) {
                }
            }
        }
    }

    /**
     * Broadcasts an event to all channels.
     */
    public void broadcastAll(String eventName, String jsonData) {
        for (String channel : channels.keySet()) {
            broadcast(channel, eventName, jsonData);
        }
    }

    /**
     * Sends a raw SSE event payload to a single AsyncContext connection.
     */
    private boolean sendDirect(AsyncContext ctx, String eventName, String jsonData) {
        try {
            ServletResponse resp = ctx.getResponse();
            if (resp == null) {
                return false;
            }

            PrintWriter out = resp.getWriter();
            out.write("event: " + eventName + "\n");
            out.write("data: " + jsonData + "\n\n");
            out.flush();
            return !out.checkError();
        } catch (IOException e) {
            return false;
        } catch (IllegalStateException e) {
            // Already completed or closed
            return false;
        }
    }

    /**
     * Records an unrecognized fingerprint scan and checks for brute-force / security threshold (FR-DASH-04).
     * If 5 or more unrecognized scans occur within 60 seconds, a SECURITY_ALERT is broadcasted to the dashboard.
     */
    public synchronized int recordUnrecognizedScan() {
        long now = System.currentTimeMillis();
        unrecognizedScanTimestamps.addLast(now);

        // Evict older than 60 seconds
        long windowStart = now - 60_000L;
        while (!unrecognizedScanTimestamps.isEmpty() && unrecognizedScanTimestamps.peekFirst() < windowStart) {
            unrecognizedScanTimestamps.pollFirst();
        }

        int count = unrecognizedScanTimestamps.size();
        if (count >= 5) {
            String alertJson = String.format(
                    "{\"type\":\"SECURITY_ALERT\",\"severity\":\"HIGH\",\"message\":\"Cảnh báo an ninh: Phát hiện %d lần quét vân tay không xác định trong 1 phút!\",\"count\":%d,\"time\":%d}",
                    count, count, now
            );
            broadcast("dashboard", "security_alert", alertJson);
            LOGGER.warning("[SseHub] Security alert triggered: " + count + " unrecognized scans in 60s");
        }

        return count;
    }

    /**
     * Helper to broadcast a low-confidence scan alert (FR-DASH-04).
     */
    public void broadcastLowConfidenceAlert(int confidence, double minConfidence) {
        String alertJson = String.format(
                "{\"type\":\"SECURITY_ALERT\",\"severity\":\"MEDIUM\",\"message\":\"Cảnh báo: Lần quét với độ tin cậy thấp (%d%% < %.0f%%)\",\"confidence\":%d,\"time\":%d}",
                confidence, minConfidence, confidence, System.currentTimeMillis()
        );
        broadcast("dashboard", "security_alert", alertJson);
    }

    /**
     * Helper to broadcast enrollment guidance steps to the Kiosk (FR-KIOSK-05).
     */
    public void broadcastEnrollStep(int commandId, String employeeName, String step, String message) {
        String json = String.format(
                "{\"type\":\"ENROLL_STEP\",\"commandId\":%d,\"employeeName\":\"%s\",\"step\":\"%s\",\"message\":\"%s\",\"time\":%d}",
                commandId, escapeJson(employeeName), step, escapeJson(message), System.currentTimeMillis()
        );
        broadcast("kiosk", "enroll_step", json);
    }

    /**
     * Helper to broadcast device online/offline status (FR-KIOSK-06, FR-DASH-05).
     */
    public void broadcastDeviceStatus(int deviceId, String deviceName, boolean online) {
        String json = String.format(
                "{\"type\":\"DEVICE_STATUS\",\"deviceId\":%d,\"deviceName\":\"%s\",\"online\":%b,\"time\":%d}",
                deviceId, escapeJson(deviceName), online, System.currentTimeMillis()
        );
        broadcastAll("device_status", json);
    }

    private static String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r");
    }
}
