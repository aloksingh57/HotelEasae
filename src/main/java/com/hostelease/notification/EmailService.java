package com.hostelease.notification;

import jakarta.mail.*;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.Properties;

public class EmailService {

    private static final Logger logger = LoggerFactory.getLogger(EmailService.class);

    private final boolean enabled;
    private final String host;
    private final int port;
    private final String username;
    private final String password;
    private final String fromAddress;
    private final boolean auth;
    private final boolean starttls;

    public EmailService() {
        this.enabled = Boolean.parseBoolean(System.getenv().getOrDefault("MAIL_ENABLED", "false"));
        this.host = System.getenv().getOrDefault("MAIL_HOST", "smtp.gmail.com");
        this.port = Integer.parseInt(System.getenv().getOrDefault("MAIL_PORT", "587"));
        this.username = System.getenv().getOrDefault("MAIL_USERNAME", "");
        this.password = System.getenv().getOrDefault("MAIL_PASSWORD", "");
        this.fromAddress = System.getenv().getOrDefault("MAIL_FROM", "notifications@hostelease.com");
        this.auth = Boolean.parseBoolean(System.getenv().getOrDefault("MAIL_SMTP_AUTH", "true"));
        this.starttls = Boolean.parseBoolean(System.getenv().getOrDefault("MAIL_STARTTLS_ENABLE", "true"));
    }

    public boolean sendHtmlEmail(String to, String subject, String htmlBody) {
        if (!enabled || username.isEmpty() || password.isEmpty() || password.contains("your_app_password")) {
            logger.info("[EMAIL SERVICE SIMULATION - NOT_CONFIGURED] To: {} | Subject: {}", to, subject);
            logger.debug("Body: {}", htmlBody);
            return true;
        }

        try {
            Properties props = new Properties();
            props.put("mail.smtp.host", host);
            props.put("mail.smtp.port", String.valueOf(port));
            props.put("mail.smtp.auth", String.valueOf(auth));
            props.put("mail.smtp.starttls.enable", String.valueOf(starttls));
            props.put("mail.smtp.connectiontimeout", "10000");
            props.put("mail.smtp.timeout", "10000");

            Session session = Session.getInstance(props, new Authenticator() {
                @Override
                protected PasswordAuthentication getPasswordAuthentication() {
                    return new PasswordAuthentication(username, password);
                }
            });

            MimeMessage message = new MimeMessage(session);
            message.setFrom(new InternetAddress(fromAddress, "HostelEase Notifications"));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(to));
            message.setSubject(subject, "UTF-8");

            String fullHtml = wrapInTemplate(subject, htmlBody);
            message.setContent(fullHtml, "text/html; charset=UTF-8");

            Transport.send(message);
            logger.info("Email dispatched successfully to {}", to);
            return true;

        } catch (Exception e) {
            logger.error("Failed to send email to {}: {}", to, e.getMessage(), e);
            return false;
        }
    }

    private String wrapInTemplate(String heading, String body) {
        return """
            <!DOCTYPE html>
            <html>
            <head>
                <meta charset="utf-8">
                <style>
                    body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; background-color: #f1f5f9; margin: 0; padding: 20px; color: #1e293b; }
                    .card { max-width: 600px; margin: 0 auto; background: #ffffff; border-radius: 12px; overflow: hidden; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.1); border: 1px solid #e2e8f0; }
                    .header { background: linear-gradient(135deg, #0f172a 0%%, #1e3a8a 100%%); padding: 24px 32px; color: #ffffff; }
                    .header h1 { margin: 0; font-size: 22px; font-weight: 700; letter-spacing: -0.5px; }
                    .header p { margin: 4px 0 0; font-size: 13px; color: #94a3b8; }
                    .content { padding: 32px; font-size: 15px; line-height: 1.6; }
                    .footer { background: #f8fafc; padding: 16px 32px; text-align: center; font-size: 12px; color: #64748b; border-top: 1px solid #e2e8f0; }
                </style>
            </head>
            <body>
                <div class="card">
                    <div class="header">
                        <h1>HostelEase</h1>
                        <p>Smart Hostel Management System</p>
                    </div>
                    <div class="content">
                        <h2 style="margin-top: 0; font-size: 18px; color: #0f172a;">%s</h2>
                        %s
                    </div>
                    <div class="footer">
                        &copy; 2026 HostelEase Systems. All rights reserved. Automated security notification.
                    </div>
                </div>
            </body>
            </html>
        """.formatted(heading, body);
    }
}
