package com.hostelease.notification;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.net.URI;
import java.net.URLEncoder;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.util.Base64;
import java.util.HashMap;
import java.util.Map;
import java.util.stream.Collectors;

public class TwilioSmsProvider implements SmsProvider {

    private static final Logger logger = LoggerFactory.getLogger(TwilioSmsProvider.class);

    private final String accountSid;
    private final String authToken;
    private final String senderId;
    private final String apiBaseUrl;
    private final HttpClient httpClient;

    public TwilioSmsProvider() {
        this.accountSid = System.getenv("SMS_ACCOUNT_ID");
        this.authToken = System.getenv("SMS_AUTH_TOKEN");
        this.senderId = System.getenv("SMS_SENDER_ID");
        String baseUrl = System.getenv("SMS_API_BASE_URL");
        this.apiBaseUrl = (baseUrl != null && !baseUrl.isEmpty()) ? baseUrl : "https://api.twilio.com/2010-04-01";

        this.httpClient = HttpClient.newBuilder()
                .connectTimeout(Duration.ofSeconds(10))
                .build();
    }

    @Override
    public SmsResult sendSms(String recipient, String message) {
        if (accountSid == null || authToken == null || senderId == null ||
            accountSid.trim().isEmpty() || authToken.trim().isEmpty() || senderId.trim().isEmpty() ||
            accountSid.startsWith("AC_mock")) {
            logger.warn("Twilio SMS credentials are not configured or are set to mock. SMS dispatch skipped safely.");
            return SmsResult.failure("NOT_CONFIGURED: Twilio Account SID or Auth Token missing in environment");
        }

        try {
            String url = String.format("%s/Accounts/%s/Messages.json", apiBaseUrl, accountSid);

            Map<String, String> formData = new HashMap<>();
            formData.put("To", recipient);
            formData.put("From", senderId);
            formData.put("Body", message);

            String formBody = formData.entrySet().stream()
                    .map(e -> URLEncoder.encode(e.getKey(), StandardCharsets.UTF_8) + "=" + URLEncoder.encode(e.getValue(), StandardCharsets.UTF_8))
                    .collect(Collectors.joining("&"));

            String authHeader = "Basic " + Base64.getEncoder().encodeToString((accountSid + ":" + authToken).getBytes(StandardCharsets.UTF_8));

            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(url))
                    .timeout(Duration.ofSeconds(15))
                    .header("Authorization", authHeader)
                    .header("Content-Type", "application/x-www-form-urlencoded")
                    .POST(HttpRequest.BodyPublishers.ofString(formBody))
                    .build();

            HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());

            if (response.statusCode() >= 200 && response.statusCode() < 300) {
                logger.info("Twilio SMS sent successfully to {}. Status: {}", recipient, response.statusCode());
                return SmsResult.success("TWILIO-MSG-" + response.statusCode());
            } else {
                logger.error("Twilio SMS error (HTTP {}): {}", response.statusCode(), response.body());
                return SmsResult.failure("HTTP " + response.statusCode() + ": " + response.body());
            }
        } catch (Exception e) {
            logger.error("Exception during Twilio SMS dispatch: {}", e.getMessage(), e);
            return SmsResult.failure("Exception: " + e.getMessage());
        }
    }

    @Override
    public String getProviderName() {
        return "TWILIO";
    }
}
