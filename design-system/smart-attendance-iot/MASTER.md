# Smart Attendance & Payroll System (IoT + Servlet)
## Master Design System (UI/UX Pro Max Edition)

> **Design Tokens, Layout Patterns, Component Architecture, and Interaction Rules**  
> *Generated with UI/UX Pro Max Design Intelligence Framework*  
> Target Platform: Web / Desktop Kiosk (Full-HD Laptop / Wall Tablet) · NetBeans Ant Java Servlet/JSP + Apache Tomcat 9

---

## 1. Product Context & Design Persona

| Attribute | Specification |
|---|---|
| **Product Type** | Hybrid: **IoT Biometric Terminal** + **Real-Time Operations Dashboard** + **Automated Payroll Engine** |
| **Industry Category** | Enterprise Workforce Management / IoT Automation / Fintech-Payroll |
| **Target Users** | **Admin (HR / Operations Manager)**, **Staff (Field / Office Employees)**, **Kiosk Display (Public Terminal)** |
| **Aesthetic Direction** | **Modern Swiss Minimalism** for Administrative Portals + **Glassmorphic OLED Dark Mode** for Kiosk Terminal |
| **Design Dials** | **Variance: 7/10** (Bento Grid cards, floating biometric rings) · **Motion: 6/10** (Smooth feedback, laser sweep) · **Density: 8/10** (Data-dense tabular layouts, 8-32px spacing) |

---

## 2. Core Color Architecture (WCAG 2.1 AA/AAA Compliant)

All color tokens are engineered with measured contrast ratios (> 4.5:1 for body copy, > 3:1 for graphical controls).

```css
:root {
    /* --- Light Mode Core (Admin & Staff Portal) --- */
    --bg-app: #f8fafc;              /* Slate 50 canvas */
    --surface: #ffffff;             /* Pure white card surface */
    --surface-hover: #f1f5f9;       /* Slate 100 on hover */
    --surface-glass: rgba(255, 255, 255, 0.92);
    --border-light: #e2e8f0;        /* Slate 200 border */
    --border-subtle: #f1f5f9;       /* Slate 100 divider */
    
    /* Typography Contrasts */
    --text-primary: #0f172a;        /* Slate 900 (15.8:1 contrast on white) */
    --text-secondary: #475569;      /* Slate 600 (5.4:1 contrast on white) */
    --text-muted: #64748b;          /* Slate 500 (4.6:1 contrast on white) */
    --text-inverse: #ffffff;        /* Pure white on dark accents */

    /* Brand Accent: Royal Sapphire */
    --primary: #2563eb;             /* Blue 600 */
    --primary-hover: #1d4ed8;       /* Blue 700 */
    --primary-light: #eff6ff;       /* Blue 50 tint */
    --primary-border: #bfdbfe;      /* Blue 200 */
    --primary-glow: rgba(37, 99, 235, 0.22);

    /* Status Indicators */
    --success: #059669;             /* Emerald 600 */
    --success-bg: #ecfdf5;          /* Emerald 50 */
    --success-border: #a7f3d0;      /* Emerald 200 */
    --success-glow: rgba(5, 150, 105, 0.25);

    --warning: #d97706;             /* Amber 600 */
    --warning-bg: #fffbeb;          /* Amber 50 */
    --warning-border: #fde68a;      /* Amber 200 */
    --warning-glow: rgba(217, 119, 6, 0.25);

    --danger: #dc2626;              /* Red 600 */
    --danger-bg: #fef2f2;           /* Red 50 */
    --danger-border: #fecaca;       /* Red 200 */
    --danger-glow: rgba(220, 38, 38, 0.25);

    --info: #0284c7;                /* Sky 600 */
    --info-bg: #f0f9ff;             /* Sky 50 */
    --info-border: #bae6fd;         /* Sky 200 */
    --info-glow: rgba(2, 132, 199, 0.25);

    /* --- Kiosk & Terminal OLED Dark Mode --- */
    --kiosk-bg: #090d16;            /* Deep Midnight Blue-Black */
    --kiosk-surface: #111827;        /* Slate 900 card surface */
    --kiosk-surface-glass: rgba(17, 24, 39, 0.85);
    --kiosk-border: rgba(255, 255, 255, 0.10);
    --kiosk-text-main: #f8fafc;
    --kiosk-text-muted: #94a3b8;
    --kiosk-biometric-idle: #38bdf8;
    --kiosk-biometric-ok: #10b981;
    --kiosk-biometric-err: #ef4444;
}
```

---

## 3. Typography Hierarchy

| Style Token | Font Family | Size | Weight | Line Height | Tracking | Usage |
|---|---|---|---|---|---|---|
| `display-kiosk` | Plus Jakarta Sans | 48px | 800 | 1.1 | -0.03em | Kiosk Digital Clock & Scan Status |
| `h1` | Plus Jakarta Sans | 24px | 700 | 1.25 | -0.02em | Page Headings, Hero titles |
| `h2` | Plus Jakarta Sans | 18px | 700 | 1.3 | -0.01em | Card & Section Headings |
| `h3` | Plus Jakarta Sans | 15px | 600 | 1.4 | 0 | Subsection headers |
| `body` | Plus Jakarta Sans | 14px | 400/500 | 1.5 | 0 | Primary narrative & descriptions |
| `label` | Plus Jakarta Sans | 12px | 600 | 1.4 | +0.03em | Field labels, Uppercase subtext |
| `tabular-num` | JetBrains Mono | 13px / 14px | 600/700 | 1.3 | -0.01em | Timestamps (`08:00:23`), Currency (`14,500,000 ₫`), Template IDs (`#042`) |

---

## 4. Spacing & Spatial Rhythm (8dp Grid System)

```css
:root {
    --space-1: 4px;     /* Micro badge padding, dot spacing */
    --space-2: 8px;     /* Tight gaps between icon and text */
    --space-3: 12px;    /* Button horizontal padding, table cell gaps */
    --space-4: 16px;    /* Standard card inner padding (compact) */
    --space-5: 20px;    /* Standard modal padding */
    --space-6: 24px;    /* Section gaps, grid layout gap */
    --space-8: 32px;    /* Page header margin, hero section padding */
    --space-10: 40px;   /* Major section separator */
    --space-12: 48px;   /* Bottom page clearance */
}
```

---

## 5. Micro-Interactions & Animation Rules

1. **Tap / Click Feedback (80ms - 150ms)**:
   - Buttons scale to `transform: scale(0.98)` on active press.
   - Elevation drops slightly to simulate physical depth.
2. **Biometric Pulse Animation**:
   - Idle Kiosk Sensor: 2.4s infinite gentle breathing ring (`scale(1)` to `scale(1.08)`).
   - Active Scanning: Laser line sweeps vertically across fingerprint icon with dynamic blue glow.
   - Success Match: Flash green ring expansion with haptic visual tick icon.
3. **Hardware Heartbeat Indicator**:
   - Online dot emits subtle emerald radial ping (`0 0 10px rgba(16, 185, 129, 0.6)`).
   - Offline dot displays static red with emergency banner.
4. **Reduced Motion**:
   - Strictly honor `@media (prefers-reduced-motion: reduce)`: disable continuous pulsing, replace sliding sweeps with instantaneous opacity switches.

---

## 6. Key Screen Specifications

### 6.1 Kiosk Biometric Terminal (`/kiosk`)
- **Full Screen Layout**: 100vh dark OLED backdrop.
- **Top HUD**: Live device connection status (SSE indicator), terminal name, full-screen toggle.
- **Centerpiece Biometric Target**: 180px animated circle target with vector fingerprint graphic.
- **Result Overlay**: High-speed modal pop-in (150ms) displaying:
  - Employee photo avatar with verified green ring.
  - Full name + Employee ID in tabular mono font.
  - Event type badge: **CHECK IN** (Green) vs **CHECK OUT** (Blue).
  - Punctuality indicator (e.g. `On Time · 07:54 AM` or `Late 6 mins · 08:06 AM`).
  - Total worked hours accumulated today.
  - Automatic 5-second countdown progress bar returning to idle.

### 6.2 Admin Live Dashboard (`/admin/dashboard`)
- **5 Critical KPI Cards**:
  1. `Checked In Today` (with punctuality percentage).
  2. `Late Arrivals` (amber flag with grace period analysis).
  3. `Missing Check-outs` (critical red alert counter).
  4. `Active Devices` (IoT ESP32 heartbeat state).
  5. `Biometric Sensor Capacity` (X / 162 slots utilized progress meter).
- **Security Alert Panel**: Immediate warning when an employee fails biometric scan 3 consecutive times.
- **Live Event Feed**: Real-time SSE incoming check-in logs with instant slide-down animation.

### 6.3 Automated Payroll & Payslips (`/admin/payroll`, `/staff/payslips`)
- **Vietnamese Labor Code Overtime Matrix**:
  - Normal Day OT: `150%`
  - Weekly Day Off OT: `200%`
  - Public Holiday OT: `300%`
  - Night Work Bonus: `+30%` (or `+50%` for Night OT)
- **Monospace Tabular Grid**: Clean currency figures formatted as Vietnamese Đồng (e.g., `12,500,000 ₫`) with right-alignment.
- **Period State Pill**: `DRAFT` (Amber editable) vs `LOCKED` (Emerald finalized with PDF export enabled).

### 6.4 Staff Today Portal (`/staff/today`)
- **Hero Card**: Greeting with real-time digital timer counting current shift duration.
- **Timeline Stepper**: 4 visual stages (Shift Start -> Check In -> Check Out -> Shift End).
- **Shift Schedule Card**: Displays assigned shift time, break duration, and overtime balance.

---

## 7. Anti-Patterns to Avoid

- ❌ **No Emoji Icons**: Always use crisp SVGs or Phosphor icons for system controls and navigation.
- ❌ **No Arbitrary Hex Colors**: Use defined CSS variables (`--primary`, `--surface`, `--text-primary`).
- ❌ **No Low-Contrast Gray Text**: Ensure normal text maintains at least 4.5:1 against light and dark surfaces.
- ❌ **No Layout Shifting on Hover**: Avoid changing borders or paddings on hover; use box-shadow, transform, or background color transitions.
- ❌ **No Hardcoded Dates/Currencies**: Format dates consistently (`YYYY-MM-DD HH:mm`) and currency numbers with `JetBrains Mono` tabular alignment.
