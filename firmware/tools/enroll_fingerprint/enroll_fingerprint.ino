#include <Adafruit_Fingerprint.h>

// Hardware Serial 2 for ESP32 & AS608
HardwareSerial mySerial(2);
Adafruit_Fingerprint finger = Adafruit_Fingerprint(&mySerial);

#define FINGERPRINT_RX_PIN 16
#define FINGERPRINT_TX_PIN 17
#define BUZZER_PIN         4
#define STATUS_LED_PIN     2

void beep(int ms) {
  #ifdef BUZZER_PIN
  digitalWrite(BUZZER_PIN, HIGH);
  delay(ms);
  digitalWrite(BUZZER_PIN, LOW);
  #endif
}

void flushSerial() {
  while (Serial.available() > 0) {
    Serial.read();
    delay(5);
  }
}

void setup() {
  Serial.begin(115200);
  while (!Serial);
  delay(500);

  #ifdef STATUS_LED_PIN
  pinMode(STATUS_LED_PIN, OUTPUT);
  #endif
  #ifdef BUZZER_PIN
  pinMode(BUZZER_PIN, OUTPUT);
  digitalWrite(BUZZER_PIN, LOW);
  #endif

  Serial.println("\n\n========================================================");
  Serial.println("  SmartAttend - AS608 Quick Fingerprint Enrollment Tool  ");
  Serial.println("========================================================");

  // AS608 default baud rate is 57600
  mySerial.begin(57600, SERIAL_8N1, FINGERPRINT_RX_PIN, FINGERPRINT_TX_PIN);
  finger.begin(57600);

  if (finger.verifyPassword()) {
    Serial.println("[OK] Da ket noi cam bien van tay AS608 thanh cong!");
    Serial.printf("[Info] Bo nho cam bien chua toi da: %d van tay.\n", finger.capacity);
  } else {
    Serial.println("[ERROR] Khong tim thay cam bien AS608!");
    Serial.println("  -> Kiem tra: VCC -> VIN(5V), GND -> GND, TX -> Pin 16, RX -> Pin 17.");
    while (1) { delay(100); }
  }
}

void printMappingGuide() {
  Serial.println("\n--------------------------------------------------------");
  Serial.println("Danh sach nhan vien da khoi tao trong Co So Du Lieu:");
  Serial.println("  ID 1 -> NV001 : Nguyen Van An");
  Serial.println("  ID 2 -> NV002 : Tran Thi Lan");
  Serial.println("  ID 3 -> NV003 : Le Minh Tuan");
  Serial.println("  ID 4 -> NV004 : Pham Thi Hoa");
  Serial.println("  ID 5 -> NV005 : Hoang Duc Minh");
  Serial.println("--------------------------------------------------------");
}

uint8_t readNumber(void) {
  flushSerial();
  while (!Serial.available()) {
    delay(50);
  }
  String input = Serial.readStringUntil('\n');
  input.trim();
  flushSerial();
  return (uint8_t)input.toInt();
}

bool getFingerprintEnroll(uint8_t targetId);

void loop() {
  printMappingGuide();
  Serial.print(">> Nhap so ID muon dang ky (vi du go 1) roi bam ENTER: ");
  
  uint8_t targetId = readNumber();
  if (targetId == 0 || targetId > 127) {
    Serial.println("\n[!] ID khong hop le! Vui long nhap mot so tu 1 den 127.");
    delay(1000);
    return;
  }

  Serial.printf("\n[BAT DAU] Dang dang ky cho ID #%d...\n", targetId);
  bool success = getFingerprintEnroll(targetId);

  if (success) {
    Serial.println("\n========================================================");
    Serial.printf("  [THANH CONG] Da luu van tay vao o nho ID #%d cua AS608!\n", targetId);
    Serial.println("  Mau van tay nay da duoc ghi nho VINH VIEN tren cam bien.");
    Serial.println("========================================================");
    Serial.println("\n>>> BIEU HIEN: BAN KHONG CAN QUET THEM NUA!");
    Serial.println("Cac buoc tiep theo de cham cong:");
    Serial.println("  1. DONG cua so Serial Monitor nay lai.");
    Serial.println("  2. Nap lai file sketch esp32_smart_attendance.ino vao ESP32.");
    Serial.println("  3. Mo NetBeans -> Run SerialBridge.java de bat dau cham cong!");
    Serial.println("--------------------------------------------------------");
    Serial.println(">> Neu ban van muon dang ky them mot ngon tay nua, hay go ID moi:");
  } else {
    Serial.println("\n[THAT BAI] Qua trinh lay mau chua thanh cong.");
    Serial.println("Ban co the nhap lai so ID de thu lai!");
  }
  
  delay(1500);
}

bool getFingerprintEnroll(uint8_t targetId) {
  int p = -1;
  Serial.println("\n[Buoc 1/2] Dat ngon tay len mat kinh cam bien...");
  beep(100);

  unsigned long startTime = millis();
  while (p != FINGERPRINT_OK) {
    if (millis() - startTime > 20000) {
      Serial.println("  [!] Qua thoi gian cho dat tay (Timeout).");
      return false;
    }
    p = finger.getImage();
    if (p == FINGERPRINT_OK) {
      Serial.println("  -> [OK] Da chup anh van tay lan 1 thanh cong!");
    } else if (p == FINGERPRINT_NOFINGER) {
      delay(50);
    } else {
      Serial.println("  [!] Loi doc anh, vui long giu tay thang va thu lai.");
    }
  }

  // Convert image 1 to template
  p = finger.image2Tz(1);
  if (p != FINGERPRINT_OK) {
    Serial.println("  [!] Khong the tao template tu anh lan 1. Vui long thu lai.");
    return false;
  }

  Serial.println("\n[Hanh dong] Nhac ngon tay ra khoi cam bien...");
  beep(50); delay(50); beep(50);
  delay(800);

  // Wait until finger is removed
  while (finger.getImage() != FINGERPRINT_NOFINGER) {
    delay(50);
  }

  Serial.println("\n[Buoc 2/2] Dat lai DUNG ngon tay do len cam bien mot lan nua...");
  p = -1;
  startTime = millis();
  while (p != FINGERPRINT_OK) {
    if (millis() - startTime > 20000) {
      Serial.println("  [!] Qua thoi gian cho dat tay lan 2 (Timeout).");
      return false;
    }
    p = finger.getImage();
    if (p == FINGERPRINT_OK) {
      Serial.println("  -> [OK] Da chup anh van tay lan 2 thanh cong!");
    } else if (p == FINGERPRINT_NOFINGER) {
      delay(50);
    }
  }

  // Convert image 2 to template
  p = finger.image2Tz(2);
  if (p != FINGERPRINT_OK) {
    Serial.println("  [!] Khong the tao template tu anh lan 2.");
    return false;
  }

  // Create model
  Serial.println("\nDang doi chieu 2 lan quet de tao khuon mau...");
  p = finger.createModel();
  if (p == FINGERPRINT_OK) {
    Serial.println("  -> 2 lan quet trung khop!");
  } else if (p == FINGERPRINT_ENROLLMISMATCH) {
    Serial.println("  [!] 2 lan quet khong giong nhau. Vui long thu lai.");
    return false;
  } else {
    Serial.println("  [!] Loi tao khuon mau.");
    return false;
  }

  // Store in sensor flash memory
  p = finger.storeModel(targetId);
  if (p == FINGERPRINT_OK) {
    beep(200);
    return true;
  } else {
    Serial.printf("  [!] Loi luu vao bo nho cam bien o slot #%d.\n", targetId);
    return false;
  }
}
