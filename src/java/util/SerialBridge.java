/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package util;

import com.fazecast.jSerialComm.SerialPort;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;

public class SerialBridge {

    // Configure your device and server details
    private static final String PORT_NAME = "COM10"; // Set to your ESP32 COM port
    private static final int BAUD_RATE = 115200;
    private static final String API_KEY = "DEV-ESP32-ATTENDANCE-KEY-001";
    
    // Default Tomcat URL (will auto-detect 8084 or 8080 if running)
    private static String serverUrl = "http://localhost:8084/SmartAttendance";

    public static void main(String[] args) {
        System.out.println("==================================================");
        System.out.println("       SmartAttend - ESP32 USB Serial Bridge      ");
        System.out.println("==================================================");

        // 1. Auto-detect Tomcat Port
        detectTomcatServer();

        // 2. Connect to Serial Port
        SerialPort comPort = SerialPort.getCommPort(PORT_NAME);
        comPort.setBaudRate(BAUD_RATE);
        comPort.setComPortTimeouts(SerialPort.TIMEOUT_READ_SEMI_BLOCKING, 0, 0);

        if (!comPort.openPort()) {
            System.err.println("\n[ERROR] Failed to open serial port " + PORT_NAME);
            System.err.println("--------------------------------------------------");
            System.err.println(" [!] IMPORTANT: Is Arduino Serial Monitor open?");
            System.err.println("     Please CLOSE the Serial Monitor window in Arduino IDE");
            System.err.println("     because only ONE application can access " + PORT_NAME + " at a time.");
            System.err.println("--------------------------------------------------");
            System.out.println("\nAvailable COM ports detected on your PC:");
            for (SerialPort p : SerialPort.getCommPorts()) {
                System.out.println(" -> " + p.getSystemPortName() + " (" + p.getDescriptivePortName() + ")");
            }
            return;
        }

        System.out.println("[Serial] Connected to ESP32 on " + PORT_NAME + " @ " + BAUD_RATE + " baud.");
        System.out.println("[Bridge] Running... Waiting for fingerprint scans.");
        System.out.println("--------------------------------------------------");

        try (BufferedReader reader = new BufferedReader(new InputStreamReader(comPort.getInputStream(), StandardCharsets.UTF_8))) {
            String line;
            while ((line = reader.readLine()) != null) {
                line = line.trim();
                // Filter out non-JSON debug/boot lines from the ESP32
                if (!line.startsWith("{")) {
                    continue;
                }

                System.out.println("\n[ESP32 RAW]: " + line);
                forwardToTomcat(line);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            comPort.closePort();
            System.out.println("\n[Serial] Port " + PORT_NAME + " closed.");
        }
    }

    private static void detectTomcatServer() {
        String[] candidates = {
            "http://localhost:8084/SmartAttendance",
            "http://localhost:8080/SmartAttendance",
            "http://127.0.0.1:8084/SmartAttendance",
            "http://127.0.0.1:8080/SmartAttendance",
            "http://192.168.1.93:8080/SmartAttendance"
        };

        for (String cand : candidates) {
            if (isReachable(cand)) {
                serverUrl = cand;
                System.out.println("[Tomcat] Detected active server at: " + serverUrl);
                return;
            }
        }
        System.out.println("[Tomcat] Warning: Tomcat not responding yet on port 8084 or 8080.");
        System.out.println("         Defaulting target to: " + serverUrl);
        System.out.println("         (Make sure you right-click project in NetBeans -> 'Run' to start Tomcat!)");
    }

    private static boolean isReachable(String targetUrl) {
        try {
            URL url = new URL(targetUrl + "/kiosk");
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("GET");
            conn.setConnectTimeout(600);
            conn.setReadTimeout(600);
            int code = conn.getResponseCode();
            return (code > 0);
        } catch (Exception e) {
            return false;
        }
    }

    private static void forwardToTomcat(String jsonPayload) {
        try {
            // Determine endpoint from JSON payload (e.g., /api/device/scan or /api/device/heartbeat)
            String endpoint = "/api/device/scan";
            int idx = jsonPayload.indexOf("\"endpoint\":\"");
            if (idx != -1) {
                int start = idx + 12;
                int end = jsonPayload.indexOf("\"", start);
                if (end != -1) {
                    endpoint = jsonPayload.substring(start, end);
                }
            }

            URL url = new URL(serverUrl + endpoint);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");
            conn.setRequestProperty("Content-Type", "application/json; charset=UTF-8");
            conn.setRequestProperty("X-API-Key", API_KEY);
            conn.setDoOutput(true);
            conn.setConnectTimeout(3000);
            conn.setReadTimeout(3000);

            try (OutputStream os = conn.getOutputStream()) {
                byte[] input = jsonPayload.getBytes(StandardCharsets.UTF_8);
                os.write(input, 0, input.length);
            }

            int code = conn.getResponseCode();
            if (code == 200) {
                if ("/api/device/heartbeat".equals(endpoint)) {
                    System.out.println("  -> [Heartbeat 200 OK] Device heartbeat synced. Device is ONLINE in Dashboard.");
                } else {
                    System.out.println("  -> [Attendance 200 OK] Scan recorded successfully! Broadcasted to Dashboard & Kiosk.");
                }
            } else if (code == 401) {
                System.err.println("  -> [HTTP 401 Unauthorized] API Key rejected. Check Device table in DB.");
            } else {
                System.out.println("  -> [HTTP POST] " + endpoint + " | Status: " + code);
            }
            conn.disconnect();
        } catch (Exception ex) {
            System.err.println("  [!] Failed to forward to Tomcat (" + serverUrl + "): " + ex.getMessage());
        }
    }
}
