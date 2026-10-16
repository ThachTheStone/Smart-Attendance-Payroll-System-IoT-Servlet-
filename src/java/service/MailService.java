package service;

import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.util.Properties;
import javax.activation.DataHandler;
import javax.mail.Authenticator;
import javax.mail.Message;
import javax.mail.PasswordAuthentication;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeBodyPart;
import javax.mail.internet.MimeMessage;
import javax.mail.internet.MimeMultipart;
import javax.mail.util.ByteArrayDataSource;

/**
 * Service for sending payslip emails with PDF attachment (FR-PAY-06).
 * Supports Gmail SMTP with graceful mock/simulation fallback when unconfigured.
 */
public class MailService {

    private String smtpHost;
    private String smtpPort;
    private boolean smtpAuth;
    private boolean startTls;
    private String username;
    private String password;
    private String fromAddress;
    private boolean configured = false;

    public static class MailResult {
        private final boolean success;
        private final String message;
        private final boolean simulated;

        public MailResult(boolean success, String message, boolean simulated) {
            this.success = success;
            this.message = message;
            this.simulated = simulated;
        }

        public boolean isSuccess() {
            return success;
        }

        public String getMessage() {
            return message;
        }

        public boolean isSimulated() {
            return simulated;
        }
    }

    public MailService() {
        loadConfig();
    }

    private void loadConfig() {
        Properties props = new Properties();
        try (InputStream in = Thread.currentThread().getContextClassLoader().getResourceAsStream("mail.properties")) {
            if (in != null) {
                props.load(in);
            } else {
                try (InputStream fallback = MailService.class.getClassLoader().getResourceAsStream("mail.properties")) {
                    if (fallback != null) {
                        props.load(fallback);
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("[MailService] Failed to load mail.properties: " + e.getMessage());
        }

        this.smtpHost = props.getProperty("mail.smtp.host", "smtp.gmail.com");
        this.smtpPort = props.getProperty("mail.smtp.port", "587");
        this.smtpAuth = Boolean.parseBoolean(props.getProperty("mail.smtp.auth", "true"));
        this.startTls = Boolean.parseBoolean(props.getProperty("mail.smtp.starttls.enable", "true"));
        this.username = props.getProperty("mail.user", "").trim();
        this.password = props.getProperty("mail.password", "").trim();
        this.fromAddress = props.getProperty("mail.from", "SmartAttend Payroll <no-reply@smartattend.vn>").trim();

        // Check if real credentials are provided
        if (!username.isEmpty() && !username.contains("your_email@gmail.com")
                && !password.isEmpty() && !password.contains("your_16_character_app_password")) {
            this.configured = true;
            System.out.println("[MailService] SMTP configured for user: " + username);
        } else {
            this.configured = false;
            System.out.println("[MailService] SMTP not fully configured in mail.properties -> Running in SIMULATION mode.");
        }
    }

    public boolean isConfigured() {
        return configured;
    }

    /**
     * Sends payslip email to an employee with their PDF payslip attached.
     */
    public MailResult sendPayslipEmail(String recipientEmail, String recipientName, int month, int year, byte[] pdfBytes, String pdfFilename) {
        if (recipientEmail == null || recipientEmail.trim().isEmpty()) {
            return new MailResult(false, "Employee has no email address configured in profile", false);
        }

        String safeEmail = recipientEmail.trim();
        String safeName = recipientName != null ? recipientName.trim() : safeEmail;
        String subject = "Payslip for Month " + String.format("%02d", month) + "/" + year + " - SmartAttend";

        // Simulation mode
        if (!configured) {
            System.out.println("[SIMULATED EMAIL] To: " + safeEmail + " (" + safeName + ")");
            System.out.println("[SIMULATED EMAIL] Subject: " + subject);
            System.out.println("[SIMULATED EMAIL] Attachment: " + pdfFilename + " (" + (pdfBytes != null ? pdfBytes.length : 0) + " bytes)");
            return new MailResult(true, "Simulated send successful (Demo Mock Mode). To send real emails, create mail.properties from mail.properties.example.", true);
        }

        // Live SMTP delivery
        try {
            Properties mailProps = new Properties();
            mailProps.put("mail.smtp.host", smtpHost);
            mailProps.put("mail.smtp.port", smtpPort);
            mailProps.put("mail.smtp.auth", String.valueOf(smtpAuth));
            mailProps.put("mail.smtp.starttls.enable", String.valueOf(startTls));
            mailProps.put("mail.smtp.ssl.protocols", "TLSv1.2");
            mailProps.put("mail.smtp.connectiontimeout", "10000");
            mailProps.put("mail.smtp.timeout", "15000");

            Session session = Session.getInstance(mailProps, new Authenticator() {
                @Override
                protected PasswordAuthentication getPasswordAuthentication() {
                    return new PasswordAuthentication(username, password);
                }
            });

            MimeMessage message = new MimeMessage(session);

            // Clean sender address to prevent AddressException: Missing '<'
            String cleanFrom = extractEmail(fromAddress);
            if (cleanFrom.isEmpty()) {
                cleanFrom = username;
            }
            String fromPersonal = extractDisplayName(fromAddress, "SmartAttend Payroll System");
            message.setFrom(new InternetAddress(cleanFrom, fromPersonal, StandardCharsets.UTF_8.name()));

            // Clean recipient address
            String cleanTo = extractEmail(safeEmail);
            String toPersonal = extractDisplayName(safeName, safeName);
            message.setRecipient(Message.RecipientType.TO, new InternetAddress(cleanTo, toPersonal, StandardCharsets.UTF_8.name()));
            message.setSubject(subject, StandardCharsets.UTF_8.name());

            // HTML Body part
            MimeBodyPart textPart = new MimeBodyPart();
            String html = buildEmailHtml(toPersonal, month, year);
            textPart.setContent(html, "text/html; charset=UTF-8");

            // PDF Attachment part
            MimeBodyPart attachmentPart = new MimeBodyPart();
            ByteArrayDataSource ds = new ByteArrayDataSource(pdfBytes, "application/pdf");
            attachmentPart.setDataHandler(new DataHandler(ds));
            attachmentPart.setFileName(pdfFilename);

            MimeMultipart multipart = new MimeMultipart();
            multipart.addBodyPart(textPart);
            multipart.addBodyPart(attachmentPart);

            message.setContent(multipart);
            Transport.send(message);

            return new MailResult(true, "Email successfully sent to " + cleanTo, false);

        } catch (Exception e) {
            e.printStackTrace();
            return new MailResult(false, "SMTP server connection error: " + e.getMessage(), false);
        }
    }

    /**
     * Extracts pure email address from potential compound strings like "Name <user@domain.com>".
     */
    private String extractEmail(String input) {
        if (input == null) return "";
        String s = input.trim();
        if (s.contains("<") && s.contains(">")) {
            int start = s.indexOf("<");
            int end = s.indexOf(">", start);
            if (end > start) {
                return s.substring(start + 1, end).trim();
            }
        }
        return s;
    }

    /**
     * Extracts personal display name if provided in format "Display Name <user@domain.com>".
     */
    private String extractDisplayName(String input, String defaultName) {
        if (input == null) return defaultName;
        String s = input.trim();
        if (s.contains("<") && s.contains(">")) {
            int start = s.indexOf("<");
            String prefix = s.substring(0, start).trim();
            if (!prefix.isEmpty()) {
                if (prefix.startsWith("\"") && prefix.endsWith("\"") && prefix.length() >= 2) {
                    prefix = prefix.substring(1, prefix.length() - 1).trim();
                }
                return prefix;
            }
        }
        return defaultName;
    }

    private String buildEmailHtml(String name, int month, int year) {
        String periodStr = String.format("%02d", month) + "/" + year;
        return "<!DOCTYPE html>"
                + "<html><head><meta charset='UTF-8'></head>"
                + "<body style='font-family:-apple-system,BlinkMacSystemFont,\"Segoe UI\",Roboto,Helvetica,Arial,sans-serif; line-height:1.6; color:#1e293b; background:#f1f5f9; margin:0; padding:30px 10px;'>"
                + "<table align='center' width='100%' style='max-width:580px; background:#ffffff; border-radius:12px; overflow:hidden; border:1px solid #e2e8f0; box-shadow:0 4px 6px rgba(0,0,0,0.05);'>"
                + "<tr><td style='background:linear-gradient(135deg, #1e3a8a, #2563eb); padding:28px 24px; text-align:center; color:#ffffff;'>"
                + "<div style='font-size:20px; font-weight:800; letter-spacing:0.5px;'>SMARTATTEND SYSTEM</div>"
                + "<div style='font-size:13px; opacity:0.9; margin-top:4px;'>Automated Attendance & Payroll Management</div>"
                + "</td></tr>"
                + "<tr><td style='padding:28px 24px;'>"
                + "<h2 style='font-size:18px; margin-top:0; color:#0f172a;'>Dear " + escapeHtml(name) + ",</h2>"
                + "<p style='color:#334155;'>The Human Resources & Accounting Department hereby provides your detailed payslip for <strong>Month " + periodStr + "</strong> which has been officially approved.</p>"
                + "<div style='background:#f8fafc; border-left:4px solid #2563eb; border-radius:6px; padding:14px 16px; margin:20px 0;'>"
                + "<div style='font-weight:700; color:#1e3a8a; margin-bottom:4px;'>Attached File: Payslip PDF</div>"
                + "<div style='font-size:13px; color:#64748b;'>Detailed salary calculations, regular hours, overtime (OT 150%, 200%, 300%), night shift allowance, and deductions are included in the attached document.</div>"
                + "</div>"
                + "<p style='font-size:13px; color:#64748b;'>If you have any questions or discrepancies regarding your attendance data or compensation, please contact Human Resources within 3 working days of receiving this email.</p>"
                + "<hr style='border:none; border-top:1px solid #e2e8f0; margin:24px 0;'>"
                + "<div style='font-size:12px; color:#94a3b8; text-align:center;'>"
                + "This is an automated email sent from the SmartAttend system. Please do not reply directly to this email.<br>"
                + "(c) 2026 SmartAttend Inc. All rights reserved."
                + "</div>"
                + "</td></tr></table>"
                + "</body></html>";
    }

    private String escapeHtml(String str) {
        if (str == null) return "";
        return str.replace("&", "&amp;")
                  .replace("<", "&lt;")
                  .replace(">", "&gt;")
                  .replace("\"", "&quot;");
    }
}
