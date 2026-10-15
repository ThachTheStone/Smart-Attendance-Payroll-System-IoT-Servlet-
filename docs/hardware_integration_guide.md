# SmartAttend Hardware Integration Guide (Phase 8)

This guide provides complete instructions for wiring, configuring, and flashing the **ESP32 + AS608 Biometric Terminal** to interface with the SmartAttend Tomcat 9 server.

---

## 1. Bill of Materials (BOM)

| Component | Quantity | Specification / Description |
| :--- | :---: | :--- |
| **ESP32 Dev Module** | 1 | NodeMCU ESP-WROOM-32 (30-pin or 38-pin) |
| **AS608 Fingerprint Sensor** | 1 | Optical fingerprint reader module (UART TTL interface) |
| **Active Buzzer** | 1 | 3.3V / 5V active buzzer (Optional, for tactile feedback) |
| **Connecting Wires** | 6–8 | Dupont female-to-female or breadboard jumper wires |
| **Micro-USB Cable** | 1 | High-quality data cable for programming and power |

---

## 2. Wiring & Schematic Diagram

The AS608 optical sensor communicates with the ESP32 via TTL Serial UART. The ESP32's **HardwareSerial 2 (UART2)** on **GPIO 16 (RX2)** and **GPIO 17 (TX2)** is used, leaving the primary Serial (GPIO 1 & 3) free for USB debugging.

```
+-----------------------------------------------------------+
|                      WIRING SCHEMATIC                     |
+-----------------------------------------------------------+
|                                                           |
|       AS608 Sensor                      ESP32 Dev Module  |
|     +---------------+                  +----------------+ |
|     |  VCC (Red)    |----------------->| 3.3V (or VIN)* | |
|     |  GND (Black)  |----------------->| GND            | |
|     |  TXD (White)  |----------------->| GPIO 16 (RX2)  | |
|     |  RXD (Green)  |----------------->| GPIO 17 (TX2)  | |
|     |  TOUCH (Blue) | (NC)             |                | |
|     +---------------+                  +----------------+ |
|                                                           |
|       Active Buzzer                                       |
|     +---------------+                                     |
|     |  (+) Positive |----------------->| GPIO 4         | |
|     |  (-) Negative |----------------->| GND            | |
|     +---------------+                  +----------------+ |
+-----------------------------------------------------------+
```

### Pin Connection Table

| AS608 Wire Color | AS608 Pin Function | ESP32 Target Pin | Note |
| :--- | :--- | :--- | :--- |
| **Red** | VCC (Power) | **3.3V** (or **VIN**) | *See power note below |
| **Black** | GND (Ground) | **GND** | Common ground |
| **White / Yellow** | TXD (Sensor Data Out) | **GPIO 16 (RX2)** | AS608 TX connects to ESP32 RX |
| **Green** | RXD (Sensor Data In) | **GPIO 17 (TX2)** | AS608 RX connects to ESP32 TX |
| **Blue / Gray** | Touch / Wakeup | *Not connected* | Optional wake-up trigger |

> [!IMPORTANT]
> **Power Supply Note**:
> Most AS608 modules work reliably when powered directly from the ESP32 **3.3V** pin. However, during the blue optical flash scan, the sensor consumes approximately **100mA–120mA**.
> If your ESP32 brownouts or resets when scanning, power the AS608 module from the ESP32 **VIN** pin (5V from USB), provided your AS608 module has an integrated 3.3V onboard LDO regulator.

---

## 3. Arduino IDE Environment Setup

1. **Install Arduino IDE**: Download and install [Arduino IDE (v2.x or v1.8.x)](https://www.arduino.cc/en/software).
2. **Add ESP32 Board Package**:
   - Go to `File` $\rightarrow$ `Preferences`.
   - In "Additional Boards Manager URLs", add:
     ```text
     https://raw.githubusercontent.com/espressif/arduino-esp32/gh-pages/package_esp32_index.json
     ```
   - Open `Tools` $\rightarrow$ `Board` $\rightarrow$ `Boards Manager...`, search for **esp32** by *Espressif Systems*, and click **Install**.
3. **Install Required Libraries**:
   - Open `Tools` $\rightarrow$ `Manage Libraries...` (Ctrl+Shift+I).
   - Search for **Adafruit Fingerprint Sensor Library** by *Adafruit* and click **Install**.

---

## 4. Firmware Configuration (`config.h`)

Open [`firmware/esp32_smart_attendance/config.h`](file:///d:/SEMEMESTER%20V/PRJ301/Project_Team/SmartAttendance-sprint1-ant/firmware/esp32_smart_attendance/config.h) and customize the following settings:

```cpp
// 1. Set Wi-Fi Credentials
#define WIFI_SSID       "Your_WiFi_Network"
#define WIFI_PASSWORD   "Your_WiFi_Password"

// 2. Set Host Server IP (Your PC/Laptop running Tomcat)
// Run 'ipconfig' in Windows Command Prompt to find your IPv4 address (e.g. 192.168.1.15)
#define SERVER_HOST     "192.168.1.15"
#define SERVER_PORT     8080
#define SERVER_BASE_URL "http://" SERVER_HOST ":8080/SmartAttendance/api/device"

// 3. API Key (Matches SQL Server Device table)
#define DEVICE_API_KEY  "DEVICE_SECRET_KEY_2026"
```

---

## 5. Host Laptop Network & Firewall Configuration

Because the ESP32 connects to Tomcat over the local Wi-Fi network, Windows Firewall must permit inbound HTTP traffic on port **8080**:

### Quick Firewall Setup (Run in Administrator PowerShell):
```powershell
New-NetFirewallRule -DisplayName "Tomcat 8080 LAN Access" -Direction Inbound -LocalPort 8080 -Protocol TCP -Action Allow
```

> [!TIP]
> **Demo Hotspot Recommendation**:
> University and public Wi-Fi networks frequently enable **AP Client Isolation**, which prevents the ESP32 and laptop from communicating directly.
> For guaranteed connectivity during project presentations and demos, turn on your **Smartphone Personal Hotspot** and connect both your laptop and ESP32 to it.

---

## 6. Flashing the Firmware

1. Connect the ESP32 to your PC using a USB cable.
2. In Arduino IDE:
   - Select Board: `Tools` $\rightarrow$ `Board` $\rightarrow$ `ESP32 Arduino` $\rightarrow$ `DOIT ESP32 DEVKIT V1` (or `ESP32 Dev Module`).
   - Select Port: `Tools` $\rightarrow$ `Port` $\rightarrow$ `COMx` (Check Windows Device Manager if unsure).
   - Set Upload Speed: `921600`.
3. Open `firmware/esp32_smart_attendance/esp32_smart_attendance.ino`.
4. Click **Upload** (Ctrl+U).
   *(If the IDE displays `Connecting........_____.....`, press and hold the **BOOT** button on the ESP32 for 2 seconds until uploading begins).*

---

## 7. Operational Testing & Verification

Open the Arduino IDE **Serial Monitor** at **115200 baud**:

1. **Sensor Verification**:
   ```text
   [AS608] Initializing UART on RX=16, TX=17, Baud=57600...
   [AS608] SUCCESS: Sensor handshake verified!
   [AS608] Capacity: 162 templates | Currently stored templates: 0
   ```
2. **Wi-Fi Connection & Heartbeat**:
   ```text
   [WiFi] Connected successfully! IP Address: 192.168.1.45
   [HEARTBEAT] Ping sent successfully (HTTP 200)
   [SYSTEM] Device ready. Listening for fingerprint scans...
   ```
3. **Kiosk Live Monitor**:
   - Open `http://localhost:8080/SmartAttendance/kiosk` in your browser.
   - The device status will switch to **ONLINE**.
4. **Live Scan Event**:
   - Touch an enrolled finger to the AS608 optical prism.
   - Serial Monitor prints:
     ```text
     [SCAN MATCH] Found Template ID #1 with confidence score 92
     [SCAN] Sending HTTP POST to http://192.168.1.15:8080/SmartAttendance/api/device/scan
     [SCAN] Server Response: {"result":"CHECK_IN","employee":"Lê Minh Tuấn","status":"ON_TIME"}
     ```
   - The Kiosk screen instantly transitions to show the employee's name, photo, and check-in confirmation!
5. **Live Enrollment via Admin Portal**:
   - Open `http://localhost:8080/SmartAttendance/admin/enroll`.
   - Select an employee and click **"Bắt đầu đăng ký vân tay"**.
   - The ESP32 picks up the command on its next 2-second poll, guide prompts appear on the screen, and the sensor captures the finger twice to store the template.

---

## 8. Common Troubleshooting

| Symptom | Cause | Solution |
| :--- | :--- | :--- |
| `[AS608] ERROR: Could not find AS608 fingerprint sensor!` | Swapped TX/RX pins or loose wire | Swap GPIO 16 & GPIO 17. Verify red wire is on 3.3V/VIN and black wire is on GND. |
| ESP32 continuously boots / browns out | Current surge during optical scan | Connect AS608 VCC to `VIN` (5V) pin or use a powered USB hub. |
| `[WiFi] Connection failed!` | 5GHz Wi-Fi band or wrong password | The ESP32 only supports **2.4GHz Wi-Fi**. Connect to a 2.4GHz network. |
| `[HEARTBEAT] Ping failed! Error: connection refused` | Tomcat not running or wrong IP | Verify Tomcat is started on port 8080. Verify IP in `config.h` via `ipconfig`. |
| `HTTP Code: 401` | Mismatched API key | Ensure `DEVICE_API_KEY` in `config.h` matches the `api_key` in the `Device` table (`DEVICE_SECRET_KEY_2026`). |
