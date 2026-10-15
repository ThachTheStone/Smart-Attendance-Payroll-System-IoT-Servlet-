/**
 * ============================================================================
 * SmartAttend - ESP32 + AS608 IoT Biometric Attendance Firmware
 * ============================================================================
 * Hardware:
 *   - ESP32 NodeMCU / Dev Module (ESP-WROOM-32)
 *   - AS608 Optical Fingerprint Sensor (UART TTL)
 *   - Optional: Active Buzzer & Status LED
 *
 * Implements SRS Requirements:
 *   - FR-IOT-01: Continuous finger detection and template search
 *   - FR-IOT-02: HTTP POST scan event with templateId, confidence, X-API-Key
 *   - FR-IOT-03: HTTP POST unrecognized scan event
 *   - FR-IOT-06: Periodic 60-second heartbeat to server
 *   - FR-IOT-07: Periodic 2-second command polling (enroll/delete)
 *   - FR-IOT-08: Local template storage on AS608 (no raw images transmitted)
 * ============================================================================
 */

#include <WiFi.h>
#include <HTTPClient.h>
#include <Adafruit_Fingerprint.h>
#include "config.h"

// Hardware Serial 2 for AS608
HardwareSerial as608Serial(2);
Adafruit_Fingerprint finger = Adafruit_Fingerprint(&as608Serial);

// Non-blocking timers
unsigned long lastHeartbeatTime = 0;
unsigned long lastCommandPollTime = 0;
unsigned long lastScanTime = 0;
bool isEnrolling = false;

// Function prototypes
void connectWiFi();
void checkWiFiConnection();
bool sendHeartbeat();
void pollPendingCommand();
void handleEnrollCommand(int cmdId, int templateId);
void handleDeleteCommand(int cmdId, int templateId);
void checkFingerprintScan();
bool sendCommandResult(int cmdId, const char* status, const char* step = NULL);
bool sendScanEvent(int templateId, int confidence);
void feedbackSuccess();
void feedbackFailed();
void beep(int times, int durationMs);

void setup() {
    Serial.begin(115200);
    delay(500);
    Serial.println("\n==============================================");
    Serial.println("  SmartAttend IoT Biometric Terminal (ESP32) ");
    Serial.println("==============================================");

    // Initialize feedback pins
    pinMode(LED_STATUS_PIN, OUTPUT);
    digitalWrite(LED_STATUS_PIN, LOW);
#ifdef BUZZER_PIN
    pinMode(BUZZER_PIN, OUTPUT);
    digitalWrite(BUZZER_PIN, LOW);
#endif

    // 1. Initialize AS608 Fingerprint Sensor UART
    Serial.printf("[AS608] Initializing UART on RX=%d, TX=%d, Baud=%d...\n", 
                  AS608_RX_PIN, AS608_TX_PIN, AS608_BAUD_RATE);
    as608Serial.begin(AS608_BAUD_RATE, SERIAL_8N1, AS608_RX_PIN, AS608_TX_PIN);

    finger.begin(AS608_BAUD_RATE);
    delay(100);

    if (finger.verifyPassword()) {
        Serial.println("[AS608] SUCCESS: Sensor handshake verified!");
        finger.getParameters();
        Serial.printf("[AS608] Capacity: %d templates | Security Level: %d | Device Address: 0x%X\n",
                      finger.capacity, finger.security_level, finger.device_addr);
        finger.getTemplateCount();
        Serial.printf("[AS608] Currently stored templates: %d\n", finger.templateCount);
    } else {
        Serial.println("[AS608] ERROR: Could not find AS608 fingerprint sensor!");
        Serial.println("[AS608] Check wiring: TX(AS608)->GPIO16, RX(AS608)->GPIO17, VCC->3.3V/5V, GND->GND.");
        while (1) {
            digitalWrite(LED_STATUS_PIN, HIGH);
            delay(200);
            digitalWrite(LED_STATUS_PIN, LOW);
            delay(200);
        }
    }

    // 2. Connect to Wi-Fi
    connectWiFi();

    // 3. Send initial heartbeat to register online state immediately
    sendHeartbeat();
    lastHeartbeatTime = millis();
    lastCommandPollTime = millis();

    beep(2, 80); // Two short beeps to signal ready
    Serial.println("[SYSTEM] Device ready. Listening for fingerprint scans...");
}

void loop() {
    checkWiFiConnection();

    // 1. Periodic Heartbeat (every 60s - FR-IOT-06)
    if (millis() - lastHeartbeatTime >= HEARTBEAT_INTERVAL_MS) {
        lastHeartbeatTime = millis();
        sendHeartbeat();
    }

    // 2. Periodic Command Poll (every 2s - FR-IOT-07)
    if (!isEnrolling && (millis() - lastCommandPollTime >= COMMAND_POLL_INTERVAL_MS)) {
        lastCommandPollTime = millis();
        pollPendingCommand();
    }

    // 3. Continuous Fingerprint Scan (FR-IOT-01)
    if (!isEnrolling) {
        checkFingerprintScan();
    }

    delay(20); // Small cooperative yield for ESP32 background tasks
}

/**
 * Connect to Wi-Fi network.
 */
void connectWiFi() {
    Serial.printf("[WiFi] Connecting to SSID: %s ", WIFI_SSID);
    WiFi.mode(WIFI_STA);
    WiFi.begin(WIFI_SSID, WIFI_PASSWORD);

    int attempts = 0;
    while (WiFi.status() != WL_CONNECTED && attempts < 25) {
        delay(500);
        Serial.print(".");
        digitalWrite(LED_STATUS_PIN, !digitalRead(LED_STATUS_PIN));
        attempts++;
    }

    if (WiFi.status() == WL_CONNECTED) {
        digitalWrite(LED_STATUS_PIN, HIGH);
        Serial.println("\n[WiFi] Connected successfully!");
        Serial.printf("[WiFi] IP Address: %s | RSSI: %d dBm\n", 
                      WiFi.localIP().toString().c_str(), WiFi.RSSI());
    } else {
        Serial.println("\n[WiFi] Connection failed! Will retry in background.");
        digitalWrite(LED_STATUS_PIN, LOW);
    }
}

void checkWiFiConnection() {
    if (WiFi.status() != WL_CONNECTED) {
        static unsigned long lastReconnectAttempt = 0;
        if (millis() - lastReconnectAttempt >= 10000) {
            lastReconnectAttempt = millis();
            Serial.println("[WiFi] Lost connection. Reconnecting...");
            WiFi.disconnect();
            WiFi.reconnect();
        }
    }
}

/**
 * Sends heartbeat ping to server (FR-IOT-06).
 */
bool sendHeartbeat() {
    if (WiFi.status() != WL_CONNECTED) return false;

    HTTPClient http;
    String url = String(SERVER_BASE_URL) + "/heartbeat";
    http.begin(url);
    http.setTimeout(HTTP_TIMEOUT_MS);
    http.addHeader("Content-Type", "application/json");
    http.addHeader("X-API-Key", DEVICE_API_KEY);

    int httpCode = http.POST("{}");
    bool ok = (httpCode == 200);

    if (ok) {
        Serial.printf("[HEARTBEAT] Ping sent successfully (HTTP %d)\n", httpCode);
    } else {
        Serial.printf("[HEARTBEAT] Ping failed! HTTP code: %d | Error: %s\n", 
                      httpCode, http.errorToString(httpCode).c_str());
    }

    http.end();
    return ok;
}

/**
 * Polls server for pending commands (FR-IOT-07).
 */
void pollPendingCommand() {
    if (WiFi.status() != WL_CONNECTED) return false;

    HTTPClient http;
    String url = String(SERVER_BASE_URL) + "/command";
    http.begin(url);
    http.setTimeout(HTTP_TIMEOUT_MS);
    http.addHeader("X-API-Key", DEVICE_API_KEY);

    int httpCode = http.GET();
    if (httpCode == 200) {
        String payload = http.getString();
        payload.trim();

        if (payload.length() > 2 && payload != "{}") {
            Serial.printf("[COMMAND] Received payload: %s\n", payload.c_str());

            // Simple robust JSON field extraction without heavy library requirement
            int idIdx = payload.indexOf("\"id\":");
            int typeIdx = payload.indexOf("\"type\":");
            int templateIdx = payload.indexOf("\"templateId\":");

            if (idIdx != -1 && typeIdx != -1 && templateIdx != -1) {
                int cmdId = payload.substring(idIdx + 5).toInt();
                int templateId = payload.substring(templateIdx + 13).toInt();

                int q1 = payload.indexOf("\"", typeIdx + 7);
                int q2 = payload.indexOf("\"", q1 + 1);
                String cmdType = payload.substring(q1 + 1, q2);

                Serial.printf("[COMMAND] Parsed Command #%d: Type=%s, TemplateId=%d\n", 
                              cmdId, cmdType.c_str(), templateId);

                if (cmdType.equalsIgnoreCase("ENROLL")) {
                    handleEnrollCommand(cmdId, templateId);
                } else if (cmdType.equalsIgnoreCase("DELETE")) {
                    handleDeleteCommand(cmdId, templateId);
                }
            }
        }
    }

    http.end();
}

/**
 * Handles Fingerprint Enrollment flow (FR-ENROLL-02, FR-KIOSK-05).
 */
void handleEnrollCommand(int cmdId, int templateId) {
    isEnrolling = true;
    Serial.printf("\n>>> STARTING ENROLLMENT for Template ID: %d (Command #%d) <<<\n", templateId, cmdId);

    // Step 1: Request user to place finger
    sendCommandResult(cmdId, "RUNNING", "PLACE_FINGER");
    beep(1, 150);

    unsigned long startWait = millis();
    int p = -1;
    while (p != FINGERPRINT_OK) {
        if (millis() - startWait > ENROLL_STEP_TIMEOUT_MS) {
            Serial.println("[ENROLL] Timeout waiting for first touch!");
            sendCommandResult(cmdId, "FAILED");
            feedbackFailed();
            isEnrolling = false;
            return;
        }
        p = finger.getImage();
        delay(50);
    }

    // Convert image 1 to buffer 1
    p = finger.image2Tz(1);
    if (p != FINGERPRINT_OK) {
        Serial.println("[ENROLL] Error converting image 1 to template!");
        sendCommandResult(cmdId, "FAILED");
        feedbackFailed();
        isEnrolling = false;
        return;
    }

    beep(1, 100);
    Serial.println("[ENROLL] First capture successful. Remove finger.");

    // Step 2: Request user to remove finger
    sendCommandResult(cmdId, "RUNNING", "REMOVE_FINGER");
    delay(500);

    p = 0;
    while (p != FINGERPRINT_NOFINGER) {
        p = finger.getImage();
        delay(50);
    }

    // Step 3: Request user to place same finger again
    sendCommandResult(cmdId, "RUNNING", "PLACE_AGAIN");
    beep(1, 150);

    startWait = millis();
    p = -1;
    while (p != FINGERPRINT_OK) {
        if (millis() - startWait > ENROLL_STEP_TIMEOUT_MS) {
            Serial.println("[ENROLL] Timeout waiting for second touch!");
            sendCommandResult(cmdId, "FAILED");
            feedbackFailed();
            isEnrolling = false;
            return;
        }
        p = finger.getImage();
        delay(50);
    }

    // Convert image 2 to buffer 2
    p = finger.image2Tz(2);
    if (p != FINGERPRINT_OK) {
        Serial.println("[ENROLL] Error converting image 2 to template!");
        sendCommandResult(cmdId, "FAILED");
        feedbackFailed();
        isEnrolling = false;
        return;
    }

    // Step 4: Create model from both buffers
    p = finger.createModel();
    if (p != FINGERPRINT_OK) {
        Serial.println("[ENROLL] Error: Prints did not match! (createModel failed)");
        sendCommandResult(cmdId, "FAILED");
        feedbackFailed();
        isEnrolling = false;
        return;
    }

    // Step 5: Store model at templateId in AS608 flash memory
    p = finger.storeModel(templateId);
    if (p == FINGERPRINT_OK) {
        Serial.printf("[ENROLL] SUCCESS: Stored template #%d into AS608!\n", templateId);
        sendCommandResult(cmdId, "DONE");
        feedbackSuccess();
    } else {
        Serial.printf("[ENROLL] ERROR: Failed to store template #%d (error %d)\n", templateId, p);
        sendCommandResult(cmdId, "FAILED");
        feedbackFailed();
    }

    isEnrolling = false;
}

/**
 * Handles Fingerprint Deletion command (FR-ENROLL-04).
 */
void handleDeleteCommand(int cmdId, int templateId) {
    Serial.printf("[DELETE] Deleting template ID: %d...\n", templateId);
    int p = finger.deleteModel(templateId);

    if (p == FINGERPRINT_OK) {
        Serial.printf("[DELETE] SUCCESS: Deleted template #%d from sensor flash.\n", templateId);
        sendCommandResult(cmdId, "DONE");
        beep(1, 80);
    } else {
        Serial.printf("[DELETE] WARNING: Sensor reported code %d for template #%d (may not have existed).\n", p, templateId);
        sendCommandResult(cmdId, "DONE"); // Still mark done so queue doesn't hang
    }
}

/**
 * Sends command execution status back to server.
 */
bool sendCommandResult(int cmdId, const char* status, const char* step) {
    if (WiFi.status() != WL_CONNECTED) return false;

    HTTPClient http;
    String url = String(SERVER_BASE_URL) + "/command/result";
    http.begin(url);
    http.setTimeout(HTTP_TIMEOUT_MS);
    http.addHeader("Content-Type", "application/json");
    http.addHeader("X-API-Key", DEVICE_API_KEY);

    String body = "{\"id\":" + String(cmdId) + ",\"status\":\"" + String(status) + "\"";
    if (step != NULL) {
        body += ",\"step\":\"" + String(step) + "\"";
    }
    body += "}";

    int httpCode = http.POST(body);
    bool ok = (httpCode == 200);
    http.end();
    return ok;
}

/**
 * Continuously polls AS608 sensor for finger placement and performs search (FR-IOT-01..03).
 */
void checkFingerprintScan() {
    // Cooldown check to prevent accidental repeated scans
    if (millis() - lastScanTime < SCAN_COOLDOWN_MS) {
        return;
    }

    // 1. Capture image from optical sensor
    int p = finger.getImage();
    if (p == FINGERPRINT_NOFINGER) {
        return; // No finger placed
    }
    if (p != FINGERPRINT_OK) {
        return; // Poor image or error reading
    }

    // 2. Convert raw image to template slot 1
    p = finger.image2Tz();
    if (p != FINGERPRINT_OK) {
        Serial.println("[SCAN] Image too messy to convert.");
        return;
    }

    // 3. Fast search AS608 database for match
    p = finger.fingerFastSearch();

    if (p == FINGERPRINT_OK) {
        // MATCH FOUND (FR-IOT-02)
        int templateId = finger.fingerID;
        int confidence = finger.confidence;
        Serial.printf("\n[SCAN MATCH] Found Template ID #%d with confidence score %d\n", templateId, confidence);
        feedbackSuccess();
        sendScanEvent(templateId, confidence);
        lastScanTime = millis();

    } else if (p == FINGERPRINT_NOTFOUND) {
        // NOT RECOGNIZED (FR-IOT-03)
        Serial.println("\n[SCAN UNKNOWN] Finger detected but NOT recognized in sensor database.");
        feedbackFailed();
        sendScanEvent(-1, 0); // -1 triggers {"templateId": null}
        lastScanTime = millis();

    } else {
        Serial.printf("[SCAN] Search error code: %d\n", p);
    }
}

/**
 * Sends scan event to server (FR-IOT-02, FR-IOT-03).
 */
bool sendScanEvent(int templateId, int confidence) {
    if (WiFi.status() != WL_CONNECTED) {
        Serial.println("[SCAN] Cannot send scan event: Wi-Fi not connected!");
        return false;
    }

    HTTPClient http;
    String url = String(SERVER_BASE_URL) + "/scan";
    http.begin(url);
    http.setTimeout(HTTP_TIMEOUT_MS);
    http.addHeader("Content-Type", "application/json");
    http.addHeader("X-API-Key", DEVICE_API_KEY);

    String body;
    if (templateId >= 0) {
        body = "{\"templateId\":" + String(templateId) + ",\"confidence\":" + String(confidence) + "}";
    } else {
        body = "{\"templateId\":null,\"confidence\":0}";
    }

    Serial.printf("[SCAN] Sending HTTP POST to %s with payload: %s\n", url.c_str(), body.c_str());

    int httpCode = http.POST(body);
    if (httpCode == 200) {
        String resp = http.getString();
        Serial.printf("[SCAN] Server Response: %s\n", resp.c_str());
    } else {
        Serial.printf("[SCAN] Server Error! HTTP Code: %d | %s\n", 
                      httpCode, http.errorToString(httpCode).c_str());
    }

    http.end();
    return (httpCode == 200);
}

// ============================================================================
// Tactile Feedback Helpers (LED & Buzzer)
// ============================================================================

void feedbackSuccess() {
    digitalWrite(LED_STATUS_PIN, HIGH);
    beep(1, 100);
    digitalWrite(LED_STATUS_PIN, LOW);
}

void feedbackFailed() {
    digitalWrite(LED_STATUS_PIN, HIGH);
    beep(2, 250);
    digitalWrite(LED_STATUS_PIN, LOW);
}

void beep(int times, int durationMs) {
#ifdef BUZZER_PIN
    for (int i = 0; i < times; i++) {
        digitalWrite(BUZZER_PIN, HIGH);
        delay(durationMs);
        digitalWrite(BUZZER_PIN, LOW);
        if (i < times - 1) delay(80);
    }
#else
    // If buzzer is not connected, flash the LED instead
    for (int i = 0; i < times; i++) {
        digitalWrite(LED_STATUS_PIN, HIGH);
        delay(durationMs);
        digitalWrite(LED_STATUS_PIN, LOW);
        if (i < times - 1) delay(80);
    }
#endif
}
