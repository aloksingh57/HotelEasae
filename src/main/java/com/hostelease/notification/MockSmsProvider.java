package com.hostelease.notification;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.UUID;

public class MockSmsProvider implements SmsProvider {

    private static final Logger logger = LoggerFactory.getLogger(MockSmsProvider.class);

    @Override
    public SmsResult sendSms(String recipient, String message) {
        String mockId = "MOCK-SMS-" + UUID.randomUUID().toString().substring(0, 8);
        logger.info("[MOCK SMS GATEWAY] To: {} | Msg: {} | MsgId: {}", recipient, message, mockId);
        return SmsResult.success(mockId);
    }

    @Override
    public String getProviderName() {
        return "MOCK";
    }
}
