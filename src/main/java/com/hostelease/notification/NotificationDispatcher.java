package com.hostelease.notification;

import com.hostelease.dao.NotificationDAO;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.List;
import java.util.Map;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

public class NotificationDispatcher {

    private static final Logger logger = LoggerFactory.getLogger(NotificationDispatcher.class);
    private static final NotificationDispatcher INSTANCE = new NotificationDispatcher();

    private final NotificationDAO notificationDAO = new NotificationDAO();
    private final EmailService emailService = new EmailService();
    private final SmsProvider smsProvider;
    private ScheduledExecutorService scheduler;

    private NotificationDispatcher() {
        String provider = System.getenv().getOrDefault("SMS_PROVIDER", "MOCK");
        if ("TWILIO".equalsIgnoreCase(provider)) {
            this.smsProvider = new TwilioSmsProvider();
        } else {
            this.smsProvider = new MockSmsProvider();
        }
    }

    public static NotificationDispatcher getInstance() {
        return INSTANCE;
    }

    public synchronized void start() {
        if (scheduler == null || scheduler.isShutdown()) {
            scheduler = Executors.newSingleThreadScheduledExecutor(r -> {
                Thread t = new Thread(r, "HostelEase-NotificationWorker");
                t.setDaemon(true);
                return t;
            });
            scheduler.scheduleWithFixedDelay(this::processQueue, 5, 15, TimeUnit.SECONDS);
            logger.info("Notification Dispatcher background worker started");
        }
    }

    public synchronized void stop() {
        if (scheduler != null && !scheduler.isShutdown()) {
            scheduler.shutdown();
            logger.info("Notification Dispatcher stopped");
        }
    }

    public void processQueue() {
        try {
            List<Map<String, Object>> items = notificationDAO.pollPending(10);
            for (Map<String, Object> item : items) {
                Long id = (Long) item.get("id");
                String channel = (String) item.get("channel");
                String email = (String) item.get("email");
                String phone = (String) item.get("phone");
                String type = (String) item.get("type");
                String subject = (String) item.get("subject");
                String message = (String) item.get("message");
                int retryCount = (Integer) item.get("retryCount");
                int maxRetries = (Integer) item.get("maxRetries");

                boolean success = false;
                String providerResponse = "";

                if ("EMAIL".equalsIgnoreCase(channel)) {
                    String targetEmail = (email != null && !email.isEmpty()) ? email : "student@hostelease.com";
                    success = emailService.sendHtmlEmail(targetEmail, subject, "<p>" + message + "</p>");
                    providerResponse = success ? "DISPATCHED_SMTP" : "SMTP_FAILURE";
                } else if ("SMS".equalsIgnoreCase(channel)) {
                    String targetPhone = (phone != null && !phone.isEmpty()) ? phone : "+919876543210";
                    SmsProvider.SmsResult res = smsProvider.sendSms(targetPhone, message);
                    success = res.isSuccess();
                    providerResponse = success ? res.getMessageId() : res.getErrorMessage();
                }

                if (success) {
                    notificationDAO.updateStatus(id, "SENT", retryCount);
                    notificationDAO.logDelivery(id, "EMAIL".equalsIgnoreCase(channel) ? email : phone, channel, type, "SENT", providerResponse);
                } else {
                    if (retryCount + 1 >= maxRetries) {
                        notificationDAO.updateStatus(id, "FAILED", retryCount + 1);
                        notificationDAO.logDelivery(id, "EMAIL".equalsIgnoreCase(channel) ? email : phone, channel, type, "FAILED", providerResponse);
                    } else {
                        notificationDAO.updateStatus(id, "RETRY_SCHEDULED", retryCount + 1);
                    }
                }
            }
        } catch (Exception e) {
            logger.error("Error processing notification queue: {}", e.getMessage());
        }
    }
}
