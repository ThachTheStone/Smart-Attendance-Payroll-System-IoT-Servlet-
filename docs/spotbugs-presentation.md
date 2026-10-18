# Static Code Analysis with SpotBugs
### Smart Attendance & Payroll System (IoT + Servlet)

---

## 1. What is SpotBugs?

**SpotBugs is a free, open-source static analysis tool for Java.** It reads compiled `.class` files (bytecode), not source code, and looks for patterns that are likely to be bugs, without ever running the program.

- It ships with **400+ bug patterns**, grouped into categories: Correctness, Bad practice, Security, Performance, Multithreaded correctness, Internationalization, Malicious code vulnerability, Dodgy code.
- Every warning has a **priority** (High / Medium / Low) and a short code, for example `NP_NULL_ON_SOME_PATH` or `SQL_PREPARED_STATEMENT_GENERATED_FROM_NONCONSTANT_STRING`.
- It runs from the command line, Ant, Maven, Gradle, and IDE plugins, so it fits easily into a build or a CI pipeline.

### Who created it, and a short history

| Year | Event |
|---|---|
| 2006 | **FindBugs** is released (first release: 10 June 2006) by **Bill Pugh and David Hovemeyer**. It started as a research project at the University of Maryland. |
| ~2015 | The last FindBugs release. The project then becomes inactive. |
| 2016 | Volunteers (notably **Andrey Loskutov**) start a community fork, because FindBugs no longer supported new Java versions. |
| 2017 | The fork is renamed **SpotBugs**; release 3.1.0 adds Java 9/10/11 support. SpotBugs calls itself the "spiritual successor of FindBugs". |
| Today | SpotBugs 4.x is actively released (4.8 and 4.9 are current). This project uses **3.1.12**. |

*Sources: [FindBugs on Wikipedia](https://en.wikipedia.org/wiki/FindBugs), [SpotBugs project](https://github.com/spotbugs/spotbugs). The University of Maryland detail is from general knowledge, not from those pages.*

---

## 2. Who uses SpotBugs? How big is the usage?

SpotBugs (and FindBugs before it) is one of the most widely used static analyzers in the Java world. It is used by open-source projects, companies and students through build plugins (Maven/Gradle), IDE plugins, and as a rule source inside code-quality platforms. Google engineers even published a paper on running FindBugs at scale: *["Experiences Using Static Analysis to Find Bugs"](https://research.google/pubs/experiences-using-static-analysis-to-find-bugs/)*.

### Estimating the share of Java developers who use it

There is no official "SpotBugs user count", so this is an **estimate built from public numbers**:

| Step | Number | Source |
|---|---|---|
| Java developers worldwide | **about 23 million** | SlashData estimate, 2025 |
| All developers worldwide | about 47.2 million | SlashData, early 2025 |
| Share of developers who use Java | 29.6% (2025), 27.6% (2026) | Stack Overflow Developer Survey ([2026](https://survey.stackoverflow.co/2026/technology)) |
| Java developers who use **no** static analysis tool | 36% | [Snyk JVM Ecosystem Report 2018](https://snyk.io/blog/jvm-ecosystem-report-2018-tools/) |
| Java developers who use **FindBugs** | **27%** | same report (SonarQube 39%, Checkstyle 23%, PMD 15%) |

**Calculation**

- Developers using FindBugs/SpotBugs = 23,000,000 × 27% ≈ **6.2 million**
- Share of *all* developers = 6.2 M / 47.2 M ≈ **13%**
- Share among Java developers who use *any* tool = 27% / (100% − 36%) = 27 / 64 ≈ **42%**

> **Caveats (say these out loud):** the 27% figure is from **2018** and measures **FindBugs**, the predecessor; the survey was multiple choice and self-selected (10,200 responses). So treat the result as an order of magnitude: **"roughly one in four Java developers, a few million people"**, not an exact number.

---

## 3. The system we tested

**Smart Attendance & Payroll System**: employees clock in by fingerprint, and the system calculates salary automatically.

- **Hardware:** an ESP32 board with an AS608 fingerprint sensor sends scans over WiFi (HTTP POST) to the server. A laptop shows the kiosk screen.
- **Software:** Java Servlet/JSP on Apache Tomcat 9, SQL Server, built as a NetBeans Ant web application.
- **Three roles:** ADMIN (users, shifts, payroll, dashboard), STAFF (own schedule and payslips), KIOSK (scan screen).
- **Size:** 88 Java files, 22 JSP pages, 14 database tables.

### Architecture (MVC with a DAO layer, NFR-07)

```
   Finger ──► AS608 ──UART──► ESP32 ──WiFi HTTP POST──► ┌─────────────────────────┐
                                                        │  Tomcat 9               │
   Browser (Admin / Staff / Kiosk)  ◄── JSP views ──────│                         │
            ▲                                           │  Filters                │
            │ Server-Sent Events                        │   EncodingFilter (UTF-8)│
            └───────── SseHub ◄─────────────────────────│   AuthFilter (roles)    │
                                                        │   DeviceApiFilter (key) │
                                                        │  Controllers (Servlets) │
                                                        │   auth / admin / staff  │
                                                        │   kiosk / api / account │
                                                        │  Services               │
                                                        │   Attendance, Payroll,  │
                                                        │   PayslipPdf, Mail      │
                                                        │  DAO layer ─► DBContext │
                                                        └───────────┬─────────────┘
                                                                    │ JDBC
                                                              SQL Server
```

| Layer | Packages |
|---|---|
| Model | `model` (Account, Employee, Role, Payroll, Shift...) |
| View | `web/WEB-INF/views/*` (JSP per role) |
| Controller | `controller.auth`, `.admin`, `.staff`, `.kiosk`, `.api`, `.account` |
| Service | `service` (AttendanceService, PayrollCalculator, PayslipPdfService, MailService) |
| Data access | `dal` (DBContext + 13 DAOs, all `PreparedStatement`) |
| Cross-cutting | `filter`, `listener` (scheduler, serial bridge), `realtime` (SSE), `util` |

Libraries: jBCrypt (password hashing), OpenPDF (payslips), JavaMail (email), jSerialComm (serial bridge), SQL Server JDBC driver.

---

## 4. What do we test, and why?

SpotBugs is a **static** tool, so we only test the *quality and safety of the code itself*. We chose the checks that map directly to the requirements in our SRS:

| Requirement (SRS) | Risk if ignored | SpotBugs check |
|---|---|---|
| **NFR-03**: all SQL uses `PreparedStatement` | SQL injection leaks or destroys payroll data | `SQL_PREPARED_STATEMENT_GENERATED_FROM_NONCONSTANT_STRING` |
| **NFR-05**: at least 50 employees without slowdown | Unclosed connections exhaust the pool, system freezes | `OBL_UNSATISFIED_OBLIGATION`, `SBSC_USE_STRINGBUFFER_CONCATENATION` |
| **FR-AUTH-01 / 03**: login and role-based access | NullPointerException on login, broken role checks | `NP_*`, `ES_COMPARING_STRINGS_WITH_EQ` |
| Many kiosks and employees scan at the same time | Scan data overwritten between threads | `ST_WRITE_TO_STATIC_FROM_INSTANCE_METHOD` |
| Vietnamese employee names | Garbled names in database, PDF and email | `DM_DEFAULT_ENCODING` |
| Employee and payroll data integrity | Callers modify internal dates | `EI_EXPOSE_REP` |
| Reliability | Errors silently swallowed, bugs impossible to trace | `DE_MIGHT_IGNORE`, `DLS_DEAD_LOCAL_STORE` |

### Our 10 SpotBugs test cases

Each test case is one class in `src/java/spotbugs/testcase/` with a `bug...()` method (the defect) and a `fixed...()` method (the correction).

| ID | Category | Defect | Bug pattern | Detected? |
|---|---|---|---|---|
| SB-TC01 | Security | SQL built by string concatenation | `SQL_PREPARED_STATEMENT_...` | Yes (High) |
| SB-TC02 | Bad practice | `PreparedStatement`/`ResultSet` never closed | `OBL_UNSATISFIED_OBLIGATION` | Yes |
| SB-TC03 | Correctness | `acc` used without `null` check | `NP_NULL_ON_SOME_PATH` | Yes |
| SB-TC04 | Bad practice | `role == "ADMIN"` | `ES_COMPARING_STRINGS_WITH_EQ` | Yes |
| SB-TC05 | Multithreading | Static field written in a servlet | `ST_WRITE_TO_STATIC_...` | Yes |
| SB-TC06 | Dodgy code | Error message assigned but never used | `DLS_DEAD_LOCAL_STORE` | Yes |
| SB-TC07 | Internationalization | `getBytes()` without UTF-8 | `DM_DEFAULT_ENCODING` | Yes (High) |
| SB-TC08 | Malicious code | Getter/setter exposes `java.util.Date` | `EI_EXPOSE_REP` / `EI_EXPOSE_REP2` | Yes |
| SB-TC09 | Bad practice | Empty `catch (Exception e) {}` | `DE_MIGHT_IGNORE` | Yes |
| SB-TC10 | Performance | `String +` inside a loop | `SBSC_USE_STRINGBUFFER_...` | Yes |

**How we ran it:** SpotBugs 3.1.12, `effort=max`, `reportLevel=low`, through the Ant target `spotbugs` in `build.xml`, producing `spotbugs-report.html`. It must run on **JDK 8** (see section 5).

---

## 5. What succeeded and what failed (and why)

### Succeeded

1. **All 10 test cases were detected**, and none of the `fixed...()` methods produced a warning. This proves the tool is configured correctly and that each fix is valid.
2. **The real code is better than we feared on the key requirement.** NFR-03 holds: the full scan produced only **one** SQL-injection warning in production code (`AccountDAO.search`), and it is a **false positive**, because the dynamic part of the query only appends fixed text with `?` placeholders and all values go through `setObject`.
3. **SpotBugs found a few real problems in our production code**, which we can now fix:

| Where | Problem |
|---|---|
| `SseHub` (3 places), `SerialBridge` | Empty `catch` blocks: errors are silently ignored (`DE_MIGHT_IGNORE`) |
| `AttendanceServlet`, `ShiftScheduleServlet` | A request parameter is put into a redirect/HTTP header (`HRS_REQUEST_PARAMETER_TO_HTTP_HEADER`): possible header injection |
| `DeviceDAO.findAll` | `ResultSet` opened without try-with-resources (`OBL_UNSATISFIED_OBLIGATION`) |
| `PayslipPdfService` | Hard-coded absolute file path (`DMI_HARDCODED_ABSOLUTE_FILENAME`) |
| `DashboardServlet` | Dead local store |
| `AuthFilter`, `DeviceApiFilter` | Unchecked cast of `ServletResponse` |

### Failed or did not work as planned

| Problem | Why it happened | What we learned |
|---|---|---|
| **The original test plan pointed at the wrong places.** It described bugs in `AccountDAO` (SQL injection), `EmployeeDAO` (leak), `LoginServlet` (NPE), `AuthFilter` (`==`), `UserValidator`, `Employee.java`, `DBContext`. | Our real code does **not** contain those bugs: the team already used `PreparedStatement`, try-with-resources and `.equals()`. | Good for quality, but it means we cannot demo those cases on the real files. So we **seeded the bugs on purpose** in a separate package, `spotbugs.testcase`. |
| **360 warnings, but most are noise.** 223 (62%) are `RCN_REDUNDANT_NULLCHECK_*` and 84 (23%) are serialization warnings (`SE_BAD_FIELD`, `SE_NO_SERIALVERSIONID`). | The redundant-null-check warnings are a well-known false-positive pattern on try-with-resources bytecode produced by newer compilers. Servlets are `Serializable` by inheritance, so serialization warnings are irrelevant for us. | Only about a dozen of the 360 warnings need action. A real project should add them to `spotbugs-exclude.xml` (today it only excludes BCrypt). |
| **The first demo class missed SB-TC06.** | `SpotBugsDemoShowcase` assigned a *constant* string to the unused variable, and SpotBugs ignores that on purpose. | The new `SBTC06_DeadStore` assigns an expression, and is detected. |
| **SpotBugs 3.1.12 crashes on JDK 17** ("Error scanning java/lang/Object"). | The old version cannot read the JDK 17 class library. | Run it on JDK 8, or upgrade to SpotBugs 4.x. |
| **`build.xml` has machine-specific paths** (`D:\SEMEMESTER V\SWT301\...`, a Tomcat path). | Written for one laptop. | Not portable for teammates or CI; move to properties or Maven/Gradle. |
| **Deliberate bugs live in production code.** `AccountDAO.testSpotBugsScanner()` contains a real `NullPointerException` and `==` string comparison. | Left over from an earlier demo. | Never call it, and remove it before release. |
| **SpotBugs cannot test behavior.** | It is static: it never runs the program. | It says nothing about the 2-second kiosk response (NFR-01), payroll math, the 10 SRS test scenarios, or the ESP32 hardware. Those need unit tests (JUnit), integration tests and manual tests. |

---

## 6. Summary

- **SpotBugs** is the free successor of FindBugs (2006), which was created by Bill Pugh and David Hovemeyer and continued by the community since 2017. Roughly one in four Java developers used FindBugs/SpotBugs in 2018, which is a few million people.
- Our system is a **Servlet/JSP MVC application with a DAO layer, an IoT fingerprint device and real-time updates**. The risks that matter most are SQL injection, resource leaks, null handling, thread safety and Vietnamese text encoding.
- We built **10 test cases**, one per bug category, and **SpotBugs detected all 10** while staying silent on the fixed code.
- On the real code it confirmed that **NFR-03 (PreparedStatement) is respected**, and it found a short list of genuine fixes (empty catch blocks, header injection, one unclosed `ResultSet`, a hard-coded path).
- Its weaknesses are **noise** (62% of warnings are false positives), an **old version** that needs JDK 8, and the fact that it **cannot verify behavior**.
- **Recommendation:** keep SpotBugs in the build, upgrade to 4.x, filter the noisy patterns, fix the real findings above, and combine it with JUnit tests and the SRS test scenarios.

**Key sentence for the closing slide:** *Static analysis finds a certain kind of bug early and cheaply, but it does not replace testing.*
