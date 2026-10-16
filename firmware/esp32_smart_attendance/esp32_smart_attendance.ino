#include <Adafruit_Fingerprint.h>
#include <ArduinoJson.h>

// Hardware Serial 2 for AS608
HardwareSerial mySerial(2);
Adafruit_Fingerprint finger = Adafruit_Fingerprint(&mySerial);

#define FINGERPRINT_RX_PIN 16
#define FINGERPRINT_TX_PIN 17
#define BUZZER_PIN         4
#define STATUS_LED_PIN     2

// ========================================================
// PHÂN ĐỊNH RÕ RÀNG 2 CHẾ ĐỘ HOẠT ĐỘNG
// ========================================================
enum DeviceMode {
  MODE_ATTENDANCE,  // Chế độ Chấm công bình thường
  MODE_ENROLLING    // Chế độ Thêm vân tay (Khóa toàn bộ chấm công)
};

DeviceMode currentMode = MODE_ATTENDANCE;

unsigned long lastHeartbeat = 0;
const unsigned long HEARTBEAT_INTERVAL = 30000; // 30s heartbeat
unsigned long lastScanDebounce = 0;

void beep(int ms) {
  #ifdef BUZZER_PIN
  digitalWrite(BUZZER_PIN, HIGH);
  delay(ms);
  digitalWrite(BUZZER_PIN, LOW);
  #endif
}

void beepPattern(int count, int ms, int pauseMs) {
  for (int i = 0; i < count; i++) {
    beep(ms);
    if (i < count - 1) delay(pauseMs);
  }
}

// Template helper tương thích cả ArduinoJson v6 và v7
template <typename T>
void sendJson(const char* type, T& doc) {
  doc["type"] = type;
  serializeJson(doc, Serial);
  Serial.println(); // Xuống dòng
}

void sendEnrollStep(int cmdId, const char* step) {
  StaticJsonDocument<128> doc;
  doc["endpoint"] = "/api/device/command/result";
  doc["id"] = cmdId;
  doc["status"] = "RUNNING";
  doc["step"] = step;
  sendJson("ENROLL_STEP", doc);
}

void sendCommandResult(int cmdId, const char* status) {
  StaticJsonDocument<128> doc;
  doc["endpoint"] = "/api/device/command/result";
  doc["id"] = cmdId;
  doc["status"] = status;
  sendJson("COMMAND_RESULT", doc);
}

// Đợi người dùng nhấc ngón tay ra khỏi cảm biến và tạo khoảng đệm an toàn trước khi chuyển sang chấm công
void finishEnrollment() {
  unsigned long liftStart = millis();
  // Đợi cho đến khi ngón tay rời hẳn khỏi mặt kính cảm biến (tối đa 5s)
  while (finger.getImage() != FINGERPRINT_NOFINGER && (millis() - liftStart < 5000)) {
    delay(60);
  }
  delay(2500); // Khoảng đệm an toàn 2.5s để ngón tay không vô tình chạm lại gây chấm công
  lastScanDebounce = millis();
  currentMode = MODE_ATTENDANCE; // Trả lại chế độ Chấm công
}

// ========================================================
// 1. ENROLL COMMAND HANDLING (2 bước đặt ngón tay)
// ========================================================
void handleEnrollCommand(int cmdId, int targetId) {
  currentMode = MODE_ENROLLING; // KHÓA chế độ chấm công ngay lập tức!
  int p = -1;
  unsigned long startTime;

  // --- BƯỚC 1: Đặt ngón tay lần 1 ---
  sendEnrollStep(cmdId, "PLACE_FINGER");
  beep(120);

  startTime = millis();
  while (p != FINGERPRINT_OK) {
    if (millis() - startTime > 15000) {
      beepPattern(2, 100, 100);
      sendCommandResult(cmdId, "FAILED");
      finishEnrollment();
      return;
    }
    p = finger.getImage();
    if (p == FINGERPRINT_NOFINGER) {
      delay(50);
    }
  }

  p = finger.image2Tz(1);
  if (p != FINGERPRINT_OK) {
    beepPattern(2, 100, 100);
    sendCommandResult(cmdId, "FAILED");
    finishEnrollment();
    return;
  }

  // --- BƯỚC 2: Nhấc ngón tay ra ---
  sendEnrollStep(cmdId, "REMOVE_FINGER");
  beepPattern(2, 60, 60);
  delay(500);
  while (finger.getImage() != FINGERPRINT_NOFINGER) {
    delay(50);
  }

  // --- BƯỚC 3: Đặt lại cùng ngón tay lần 2 ---
  sendEnrollStep(cmdId, "PLACE_AGAIN");
  beep(120);

  p = -1;
  startTime = millis();
  while (p != FINGERPRINT_OK) {
    if (millis() - startTime > 15000) {
      beepPattern(2, 100, 100);
      sendCommandResult(cmdId, "FAILED");
      finishEnrollment();
      return;
    }
    p = finger.getImage();
    if (p == FINGERPRINT_NOFINGER) {
      delay(50);
    }
  }

  p = finger.image2Tz(2);
  if (p != FINGERPRINT_OK) {
    beepPattern(2, 100, 100);
    sendCommandResult(cmdId, "FAILED");
    finishEnrollment();
    return;
  }

  // --- BƯỚC 4: Đối chiếu & Lưu vào AS608 Flash ---
  p = finger.createModel();
  if (p != FINGERPRINT_OK) {
    beepPattern(3, 80, 80);
    sendCommandResult(cmdId, "FAILED");
    finishEnrollment();
    return;
  }

  p = finger.storeModel(targetId);
  if (p == FINGERPRINT_OK) {
    beep(350); // Bíp dài báo thành công
    sendCommandResult(cmdId, "DONE");
  } else {
    beepPattern(3, 80, 80);
    sendCommandResult(cmdId, "FAILED");
  }

  // Bắt buộc nhấc tay và có thời gian đệm trước khi mở lại chấm công
  finishEnrollment();
}

// ========================================================
// 2. DELETE COMMAND HANDLING
// ========================================================
void handleDeleteCommand(int cmdId, int targetId) {
  uint8_t p = finger.deleteModel(targetId);
  if (p == FINGERPRINT_OK) {
    beep(100);
    sendCommandResult(cmdId, "DONE");
  } else {
    sendCommandResult(cmdId, "FAILED");
  }
}

// ========================================================
// 3. ĐỌC LỆNH TỪ SERIAL (Do SerialBridge gửi xuống)
// ========================================================
void checkSerialCommands() {
  if (Serial.available() > 0) {
    String line = Serial.readStringUntil('\n');
    line.trim();
    if (line.startsWith("{")) {
      StaticJsonDocument<256> doc;
      DeserializationError err = deserializeJson(doc, line);
      if (!err) {
        const char* cmd = doc["cmd"];
        int cmdId = doc["id"];
        int templateId = doc["templateId"];
        if (cmd != NULL && strcmp(cmd, "ENROLL") == 0) {
          handleEnrollCommand(cmdId, templateId);
        } else if (cmd != NULL && strcmp(cmd, "DELETE") == 0) {
          handleDeleteCommand(cmdId, templateId);
        }
      }
    }
  }
}

// ========================================================
// 4. CHẤM CÔNG THƯỜNG NHẬT
// ========================================================
void handleFingerprintScanning() {
  // Chỉ chấm công khi ở MODE_ATTENDANCE
  if (currentMode != MODE_ATTENDANCE) return;

  // Debounce an toàn 2.0s
  if (millis() - lastScanDebounce < 2000) return;

  uint8_t p = finger.getImage();
  if (p != FINGERPRINT_OK) return;

  p = finger.image2Tz();
  if (p != FINGERPRINT_OK) return;

  p = finger.fingerSearch();
  StaticJsonDocument<128> doc;

  if (p == FINGERPRINT_OK) {
    beep(100);
    doc["endpoint"] = "/api/device/scan";
    doc["templateId"] = finger.fingerID;
    doc["confidence"] = finger.confidence;
    sendJson("SCAN_MATCH", doc);
  } else {
    beep(50); delay(80); beep(50);
    doc["endpoint"] = "/api/device/scan";
    doc["templateId"] = (char*)NULL;
    doc["confidence"] = 0;
    sendJson("SCAN_NOT_RECOGNIZED", doc);
  }
  lastScanDebounce = millis();
}

void setup() {
  Serial.begin(115200);
  delay(500);

  #ifdef STATUS_LED_PIN
  pinMode(STATUS_LED_PIN, OUTPUT);
  #endif
  #ifdef BUZZER_PIN
  pinMode(BUZZER_PIN, OUTPUT);
  digitalWrite(BUZZER_PIN, LOW);
  #endif

  // AS608 UART
  mySerial.begin(57600, SERIAL_8N1, FINGERPRINT_RX_PIN, FINGERPRINT_TX_PIN);
  finger.begin(57600);

  StaticJsonDocument<128> doc;
  if (finger.verifyPassword()) {
    doc["status"] = "OK";
    doc["capacity"] = finger.capacity;
    sendJson("INIT", doc);
  } else {
    doc["status"] = "ERROR";
    doc["error"] = "SENSOR_NOT_FOUND";
    sendJson("INIT", doc);
  }
}

void loop() {
  // 1. Kiểm tra xem Web có gửi lệnh ENROLL / DELETE xuống không
  checkSerialCommands();

  // 2. Nếu đang bận thêm vân tay, TUYỆT ĐỐI không chạy chấm công
  if (currentMode != MODE_ATTENDANCE) {
    return;
  }

  // 3. Gửi Heartbeat định kỳ 30s
  unsigned long now = millis();
  if (now - lastHeartbeat >= HEARTBEAT_INTERVAL) {
    lastHeartbeat = now;
    StaticJsonDocument<64> doc;
    doc["endpoint"] = "/api/device/heartbeat";
    sendJson("HEARTBEAT", doc);
  }

  // 4. Quét vân tay chấm công bình thường
  handleFingerprintScanning();
}
