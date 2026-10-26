package com.hostelease.notification;

public interface SmsProvider {
    /**
     * Sends an SMS message to a recipient.
     * @param recipient Target mobile phone number with country code
     * @param message Message body
     * @return SmsResult containing status and provider response/error details
     */
    SmsResult sendSms(String recipient, String message);

    String getProviderName();

    class SmsResult {
        private final boolean success;
        private final String messageId;
        private final String errorMessage;

        public SmsResult(boolean success, String messageId, String errorMessage) {
            this.success = success;
            this.messageId = messageId;
            this.errorMessage = errorMessage;
        }

        public static SmsResult success(String messageId) {
            return new SmsResult(true, messageId, null);
        }

        public static SmsResult failure(String errorMessage) {
            return new SmsResult(false, null, errorMessage);
        }

        public boolean isSuccess() { return success; }
        public String getMessageId() { return messageId; }
        public String getErrorMessage() { return errorMessage; }
    }
}
