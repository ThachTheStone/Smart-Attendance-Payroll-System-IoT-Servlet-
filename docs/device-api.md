# SmartAttend Device API Contract (FR-IOT-01..08)

The SmartAttend server exposes a RESTful JSON API for the IoT biometric devices (ESP32 + AS608 fingerprint module).

## Base Configuration

- **Protocol**: HTTP/1.1
- **Default Base URL**: `http://<server-ip>:8080/SmartAttendance/api/device`
- **Authentication**: Custom HTTP header `X-API-Key: <Device.api_key>`
- **Content-Type**: `application/json; charset=UTF-8`

---

## Security & Authentication

Every request to `/api/device/*` is inspected by [`DeviceApiFilter.java`](file:///d:/SEMEMESTER%20V/PRJ301/Project_Team/SmartAttendance-sprint1-ant/src/java/filter/DeviceApiFilter.java).
- If the `X-API-Key` header is missing or does not match any active device in the `Device` table, the server returns **`401 Unauthorized`**:
  ```json
  {
    "error": "Invalid or missing X-API-Key"
  }
  ```
- If valid, the authenticated `Device` instance is attached to the request attributes and passed to the servlet.

---

## 1. Fingerprint Scan Event

Processes a fingerprint scan event detected by the AS608 optical sensor.

- **Endpoint**: `POST /api/device/scan`
- **Frequency**: Triggered upon physical finger detection.

### Request Body

#### Case A: Fingerprint Matched on Sensor (FR-IOT-02)
```json
{
  "templateId": 12,
  "confidence": 87
}
```

#### Case B: Fingerprint Not Recognized on Sensor (FR-IOT-03)
```json
{
  "templateId": null,
  "confidence": 0
}
```

### Server Logic
1. Updates `last_heartbeat` for the device.
2. Checks confidence threshold ($\ge 50$ by default, configurable in `SalaryRule`). Matches below threshold are treated as invalid.
3. Checks if `templateId` is mapped to an active employee in `Fingerprint` and `Employee` tables.
4. Checks active shift assignment for today.
5. Evaluates 60-second debounce window to prevent accidental double-scans.
6. Server determines `CHECK_IN` vs `CHECK_OUT` automatically (FR-IOT-05).
7. Broadcasts real-time SSE event to `/kiosk/stream` and `/admin/dashboard/stream`.

### Response Body (`200 OK`)

```json
{
  "result": "CHECK_IN",
  "message": "Check-in thành công: 07:58 (Đúng giờ)",
  "employee": "Lê Minh Tuấn",
  "employeeCode": "NV003",
  "status": "ON_TIME",
  "time": "07:58:12"
}
```

Or on failure / unrecognized:
```json
{
  "result": "INVALID",
  "message": "Không nhận diện được vân tay",
  "time": "08:05:30"
}
```

---

## 2. Device Heartbeat

Keeps the device online status active in the system.

- **Endpoint**: `POST /api/device/heartbeat`
- **Frequency**: Every 60 seconds (FR-IOT-06).

### Request Body
```json
{}
```

### Response Body (`200 OK`)
```json
{
  "ok": true,
  "serverTime": "2026-10-15 13:30:00"
}
```

If the server does not receive a heartbeat for $> 120$ seconds, the device is marked **OFFLINE** and a warning banner appears on the Kiosk screen (FR-KIOSK-06) and Admin Dashboard (FR-DASH-05).

---

## 3. Command Polling

Polls for pending administrative commands (such as fingerprint enrollment or deletion).

- **Endpoint**: `GET /api/device/command`
- **Frequency**: Every 2 seconds (FR-IOT-07).

### Response Body (`200 OK`)

#### When no command is pending:
```json
{}
```

#### When an ENROLL command is pending:
```json
{
  "id": 5,
  "type": "ENROLL",
  "templateId": 13
}
```

#### When a DELETE command is pending:
```json
{
  "id": 6,
  "type": "DELETE",
  "templateId": 13
}
```

---

## 4. Command Result & Progress Reporting

Reports the execution progress or final result of a command.

- **Endpoint**: `POST /api/device/command/result`
- **Frequency**: Called during enrollment steps and upon command completion.

### Request Body

#### Intermediate Enrollment Steps (FR-KIOSK-05)
```json
{
  "id": 5,
  "status": "RUNNING",
  "step": "PLACE_FINGER"
}
```
Available step values:
- `PLACE_FINGER`: "Đặt ngón tay lên cảm biến (lần 1)"
- `REMOVE_FINGER`: "Nhấc ngón tay ra khỏi cảm biến"
- `PLACE_AGAIN`: "Đặt lại cùng ngón tay lần nữa"

#### Final Command Status (`DONE` or `FAILED`)
```json
{
  "id": 5,
  "status": "DONE"
}
```

### Response Body (`200 OK`)
```json
{
  "ok": true
}
```
On `DONE`:
- For `ENROLL`: Links `templateId` to `employee_id` in `Fingerprint` table and broadcasts `SUCCESS` to Admin UI and Kiosk.
- For `DELETE`: Removes template mapping from `Fingerprint` table.
