package util;

import com.fazecast.jSerialComm.SerialPort;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;

/**
 * SmartAttend - ESP32 USB Bidirectional Serial Bridge
 * - Chieu 1 (ESP32 -> Tomcat): Nhan tin hieu quet cham cong, heartbeat, va tien trinh dang ky van tay tu ESP32 de forward len Tomcat.
 * - Chieu 2 (Tomcat -> ESP32): Dinh ky poll lenh tu /api/device/command tren Server. Khi Admin bam Enroll tren Web, ban lenh xuong ESP32 qua Serial.
 */
public class SerialBridge {

    private static final String PORT_NAME = "COM10"; // Cong COM cua ESP32
    private static final int BAUD_RATE = 115200;
    private static final String API_KEY = "DEV-ESP32-ATTENDANCE-KEY-001";
    
    // Default Tomcat URL (se tu dong detect 8084 hoac 8080)
    private static String serverUrl = "http://localhost:8084/SmartAttendance";

    // Trang thai kiem soat tien trinh dang ky
    private static volatile boolean commandInProgress = false;
    private static volatile long commandStartTime = 0;
    
    //Bien ho tro cho viec chay tu dọng
    private static Thread bridgeThread = null;
    private static SerialPort activePort = null;

    public static void main(String[] args) {
        System.out.println("==================================================");
        System.out.println("   SmartAttend - ESP32 Bidirectional USB Bridge   ");
        System.out.println("==================================================");

        // 1. Tu dong tim port Tomcat
        detectTomcatServer();

        // 2. Ket noi cong Serial COM
        SerialPort comPort = findOrFallbackPort(PORT_NAME);
        comPort.setBaudRate(BAUD_RATE);
        comPort.setComPortTimeouts(SerialPort.TIMEOUT_READ_SEMI_BLOCKING, 0, 0);

        if (!comPort.openPort()) {
            System.err.println("\n[ERROR] Khong the mo cong " + comPort.getSystemPortName());
            System.err.println("--------------------------------------------------");
            System.err.println(" [!] LUU Y: Co phai Serial Monitor trong Arduino IDE dang mo?");
            System.err.println("     Vui long DONG cua so Serial Monitor trong Arduino IDE.");
            System.err.println("--------------------------------------------------");
            System.out.println("\nCac cong COM dang co tren may tinh cua ban:");
            for (SerialPort p : SerialPort.getCommPorts()) {
                System.out.println(" -> " + p.getSystemPortName() + " (" + p.getDescriptivePortName() + ")");
            }
            return;
        }

        System.out.println("[Serial] Da ket noi toi ESP32 tren " + comPort.getSystemPortName() + " @ " + BAUD_RATE + " baud.");
        System.out.println("[Bridge] Running... Ho tro ca Cham Cong va Dang Ky Van Tay tu Web!");
        System.out.println("--------------------------------------------------");

        // 3. Khoi chay Thread chay ngam lang nghe lenh tu Web Server (Chieu: Web -> ESP32)
        Thread pollerThread = new Thread(() -> pollCommandsLoop(comPort), "CommandPollerThread");
        pollerThread.setDaemon(true);
        pollerThread.start();

        // 4. Luong chinh: Doc du lieu tu ESP32 va forward len Server (Chieu: ESP32 -> Web)
        try (BufferedReader reader = new BufferedReader(new InputStreamReader(comPort.getInputStream(), StandardCharsets.UTF_8))) {
            String line;
            while ((line = reader.readLine()) != null) {
                line = line.trim();
                // Chi xu ly cac dong JSON hop le
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
            System.out.println("\n[Serial] Cong " + comPort.getSystemPortName() + " da dong.");
        }
    }
    
    public static synchronized void startAsync() {
    if (bridgeThread != null && bridgeThread.isAlive()) return;
    
    bridgeThread = new Thread(() -> {
        try {
            // Chờ 3 giây để Tomcat khởi động hoàn tất
            Thread.sleep(3000);
            detectTomcatServer();
            activePort = findOrFallbackPort(PORT_NAME);
            if (activePort == null || !activePort.openPort()) {
                System.out.println("[SerialBridge] Khong tim thay ESP32 qua cong USB COM (che do ranh tay).");
                return;
            }
            activePort.setBaudRate(BAUD_RATE);
            activePort.setComPortTimeouts(SerialPort.TIMEOUT_READ_SEMI_BLOCKING, 0, 0);
            System.out.println("[SerialBridge] Da tu dong ket noi ESP32 tren " + activePort.getSystemPortName());
            
            Thread poller = new Thread(() -> pollCommandsLoop(activePort), "AutoCommandPoller");
            poller.setDaemon(true);
            poller.start();
            try (BufferedReader reader = new BufferedReader(new InputStreamReader(activePort.getInputStream(), StandardCharsets.UTF_8))) {
                String line;
                while ((line = reader.readLine()) != null) {
                    line = line.trim();
                    if (line.startsWith("{")) forwardToTomcat(line);
                }
            }
        } catch (Exception e) {
            System.out.println("[SerialBridge] Luong USB ket thuc: " + e.getMessage());
        }
    }, "AutoSerialBridgeThread");
    
    bridgeThread.setDaemon(true);
    bridgeThread.start();
}
public static synchronized void stopBridge() {
    if (activePort != null && activePort.isOpen()) {
        activePort.closePort();
        System.out.println("[SerialBridge] Da dong cong COM an toan.");
    }
}

    private static SerialPort findOrFallbackPort(String preferredPort) {
        SerialPort port = SerialPort.getCommPort(preferredPort);
        if (port != null && isPortPresent(preferredPort)) {
            return port;
        }
        // Neu preferredPort chua cam, thu tim cong dau tien co chu USB hoac CP210 / CH340
        for (SerialPort p : SerialPort.getCommPorts()) {
            String desc = p.getDescriptivePortName().toLowerCase();
            if (desc.contains("usb") || desc.contains("cp210") || desc.contains("ch340") || desc.contains("uart")) {
                System.out.println("[Serial] Tu dong chon cong: " + p.getSystemPortName() + " (" + p.getDescriptivePortName() + ")");
                return p;
            }
        }
        return port;
    }

    private static boolean isPortPresent(String portName) {
        for (SerialPort p : SerialPort.getCommPorts()) {
            if (p.getSystemPortName().equalsIgnoreCase(portName)) return true;
        }
        return false;
    }

    /**
     * Dinh ky moi 2 giay hoi Server xem Admin co bam ENROLL hoac DELETE khong.
     */
    private static void pollCommandsLoop(SerialPort port) {
        while (port.isOpen()) {
            try {
                Thread.sleep(2000);

                // Neu mot lenh Enroll dang thuc hien, kiem tra timeout 35s de phong treo
                if (commandInProgress) {
                    if (System.currentTimeMillis() - commandStartTime > 35000) {
                        System.out.println("[Bridge] Lenh truoc do da het han cho (35s timeout). Tiep tuc poll lenh moi.");
                        commandInProgress = false;
                    }
                    continue;
                }

                String resp = fetchPendingCommand();
                if (resp != null && resp.contains("\"type\"") && (resp.contains("\"ENROLL\"") || resp.contains("\"DELETE\""))) {
                    int id = extractInt(resp, "id");
                    String type = extractString(resp, "type");
                    int templateId = extractInt(resp, "templateId");

                    if (id > 0 && type != null) {
                        String cmdToSend = "{\"cmd\":\"" + type + "\",\"id\":" + id + ",\"templateId\":" + templateId + "}\n";
                        OutputStream os = port.getOutputStream();
                        os.write(cmdToSend.getBytes(StandardCharsets.UTF_8));
                        os.flush();

                        commandInProgress = true;
                        commandStartTime = System.currentTimeMillis();
                        System.out.println("\n>>> [Bridge -> ESP32] Da gui lenh: " + type + " #" + id + " vao Slot #" + templateId);
                        System.out.println("    Vui long huong dan nhan vien dat ngon tay len cam bien AS608!");
                    }
                }
            } catch (InterruptedException e) {
                break;
            } catch (Exception ex) {
                // Bo qua cac loi mang tam thoi
            }
        }
    }

    private static String fetchPendingCommand() {
        try {
            URL url = new URL(serverUrl + "/api/device/command");
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("GET");
            conn.setRequestProperty("X-API-Key", API_KEY);
            conn.setConnectTimeout(2000);
            conn.setReadTimeout(2000);

            if (conn.getResponseCode() == 200) {
                try (BufferedReader r = new BufferedReader(new InputStreamReader(conn.getInputStream(), StandardCharsets.UTF_8))) {
                    StringBuilder sb = new StringBuilder();
                    String l;
                    while ((l = r.readLine()) != null) sb.append(l);
                    return sb.toString().trim();
                }
            }
        } catch (Exception ignored) {
        }
        return null;
    }

    private static void forwardToTomcat(String jsonPayload) {
        try {
            String endpoint = "/api/device/scan";
            int idx = jsonPayload.indexOf("\"endpoint\":\"");
            if (idx != -1) {
                int start = idx + 12;
                int end = jsonPayload.indexOf("\"", start);
                if (end != -1) {
                    endpoint = jsonPayload.substring(start, end);
                }
            }

            if ("/api/device/scan".equals(endpoint) && commandInProgress) {
                System.out.println("  -> [BLOCKED] Dang trong che do Dang ky van tay. Bo qua tin hieu cham cong de tranh nham lan!");
                return;
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
                    System.out.println("  -> [Heartbeat 200 OK] Dong bo heartbeat thanh cong. Thiet bi ONLINE.");
                } else if ("/api/device/command/result".equals(endpoint)) {
                    System.out.println("  -> [Command 200 OK] Tien trinh Dang ky/Xoa da duoc cap nhat len Web!");
                    if (jsonPayload.contains("\"DONE\"") || jsonPayload.contains("\"FAILED\"")) {
                        new Thread(() -> {
                            try {
                                Thread.sleep(3000); // Dem 3 giay de ngon tay roi khoi mat kinh truoc khi mo lai cham cong
                            } catch (Exception ignored) {}
                            commandInProgress = false;
                            System.out.println("  -> [Bridge] Hoan tat lenh. Da quay tro lai che do Cham Cong binh thuong.");
                        }).start();
                    }
                } else {
                    System.out.println("  -> [Attendance 200 OK] Ghi nhan quet van tay thanh cong! Da phat realtime toi Kiosk & Dashboard.");
                }
            } else if (code == 401) {
                System.err.println("  -> [HTTP 401 Unauthorized] API Key bi tu choi. Kiem tra bang Device trong DB.");
            } else {
                System.out.println("  -> [HTTP POST] " + endpoint + " | Status: " + code);
            }
            conn.disconnect();
        } catch (Exception ex) {
            System.err.println("  [!] Loi gui toi Tomcat (" + serverUrl + "): " + ex.getMessage());
        }
    }

    private static void detectTomcatServer() {
        String[] candidates = {
            "http://localhost:8084/SmartAttendance",
            "http://localhost:8080/SmartAttendance",
            "http://127.0.0.1:8084/SmartAttendance",
            "http://127.0.0.1:8080/SmartAttendance"
        };

        for (String cand : candidates) {
            if (isReachable(cand)) {
                serverUrl = cand;
                System.out.println("[Tomcat] Phat hien server dang chay tai: " + serverUrl);
                return;
            }
        }
        System.out.println("[Tomcat] Mac dinh target tai: " + serverUrl);
    }

    private static boolean isReachable(String targetUrl) {
        try {
            URL url = new URL(targetUrl + "/kiosk");
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("GET");
            conn.setConnectTimeout(600);
            conn.setReadTimeout(600);
            return (conn.getResponseCode() > 0);
        } catch (Exception e) {
            return false;
        }
    }

    private static int extractInt(String json, String key) {
        String search = "\"" + key + "\":";
        int idx = json.indexOf(search);
        if (idx == -1) return 0;
        int start = idx + search.length();
        int end = start;
        while (end < json.length() && (Character.isDigit(json.charAt(end)) || json.charAt(end) == '-')) {
            end++;
        }
        try {
            return Integer.parseInt(json.substring(start, end).trim());
        } catch (Exception e) {
            return 0;
        }
    }

    private static String extractString(String json, String key) {
        String search = "\"" + key + "\":\"";
        int idx = json.indexOf(search);
        if (idx == -1) return null;
        int start = idx + search.length();
        int end = json.indexOf("\"", start);
        if (end == -1) return null;
        return json.substring(start, end);
    }
}
