# Page Override Specification: Authentication & Access Control (`/login`)
*Parent Design System: `../MASTER.md`*

## 1. Role & Intent
Secure, role-based entry point for all three actors: `ADMIN`, `STAFF`, and `KIOSK`.

## 2. Visual Style & Enhancements
1. **Modern Dual-Pane / Glassmorphic Card**:
   - Left side: Brand identity with biometric pulse visual, IoT device connectivity badge, and value proposition.
   - Right side: High-contrast login form with floating focus indicators, password toggle, and clear validation.
2. **Reviewer & Demo Quick-Login Helper**:
   - Three quick-fill pills for demonstration and testing:
     - 👑 **Admin**: `admin` / `Admin@123`
     - 👤 **Staff**: `tuan.le` / `Staff@123`
     - 💻 **Kiosk Terminal**: `kiosk01` / `Kiosk@123`
   - Clicking fills username and password with a single tap, providing an effortless evaluation experience.
3. **WCAG Compliance**:
   - `autocomplete="username"` and `autocomplete="current-password"`.
   - Focus outline: 3px solid `--primary` with 2px offset.
   - Inline alert banner for invalid credentials or session timeouts.
