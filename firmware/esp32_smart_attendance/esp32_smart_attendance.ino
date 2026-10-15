#include <Adafruit_Fingerprint.h>
#include <ArduinoJson.h>

// Hardware Serial 2 for AS608
HardwareSerial mySerial(2);
Adafruit_Fingerprint finger = Adafruit_Fingerprint(&mySerial);

#define FINGERPRINT_RX_PIN 16
#define FINGERPRINT_TX_PIN 17
#define BUZZER_PIN         4
#define STATUS_LED_PIN     2

unsigned long lastHeartbeat = 0;
const unsigned long HEARTBEAT_INTERVAL = 30000; // 30s heartbeat

void beep(int ms) {
  #ifdef BUZZER_PIN
  digitalWrite(BUZZER_PIN, HIGH);
  delay(ms);
  digitalWrite(BUZZER_PIN, LOW);
  #endif
}

// Template helper tương thích cả ArduinoJson v6 và v7
template <typename T>
void sendJson(const char* type, T& doc) {
  doc["type"] = type;
  serializeJson(doc, Serial);
  Serial.println(); // Xuống dòng
}

void handleFingerprintScanning() {
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
  delay(1200); // Debounce
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
  // 1. Heartbeat
  unsigned long now = millis();
  if (now - lastHeartbeat >= HEARTBEAT_INTERVAL) {
    lastHeartbeat = now;
    StaticJsonDocument<64> doc;
    doc["endpoint"] = "/api/device/heartbeat";
    sendJson("HEARTBEAT", doc);
  }

  // 2. Scan Finger
  handleFingerprintScanning();
}
