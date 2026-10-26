# Notification & Messaging Integration Guide: Jakarta Mail & SMS Adapters

## 1. Architecture Overview
HostelEase implements an asynchronous multi-channel notification engine powered by **Jakarta Mail 2.0** and a pluggable **SMS Provider Adapter Pattern** (`SmsProvider`).

```
[ Application Event ]
   (Leave Approved, Gate Out, Overdue Alert, Fee Receipt)
           │
           ▼
[ NotificationDispatcher ] ──> Queued in `notification_queue` table
           │
     ┌─────┴──────────────────┐
     ▼                        ▼
[ Jakarta Mail ]        [ SmsProvider ]
 (HTML Email Engine)          │
                        ┌─────┴──────────────┐
                        ▼                    ▼
               [ TwilioSmsProvider ]  [ MockSmsProvider ]
               (Production Gateway)   (Local Dev / Offline)
```

---

## 2. Jakarta Mail (Email Service Configuration)

HostelEase sends rich HTML emails using standard Jakarta Mail (`jakarta.mail.*`).

### SMTP Settings Configuration
Configure the following keys in `src/main/resources/application.properties` or as OS environment variables:

| Key | Environment Variable | Default Value | Description |
|---|---|---|---|
| `mail.smtp.host` | `MAIL_HOST` | `smtp.gmail.com` | SMTP Server Hostname |
| `mail.smtp.port` | `MAIL_PORT` | `587` | SMTP Port (587 for TLS, 465 for SSL) |
| `mail.smtp.auth` | `MAIL_AUTH` | `true` | SMTP Authentication flag |
| `mail.smtp.starttls.enable` | `MAIL_STARTTLS` | `true` | Enable STARTTLS encryption |
| `mail.smtp.username` | `MAIL_USERNAME` | `notifications@hostelease.com` | SMTP Sender Username |
| `mail.smtp.password` | `MAIL_PASSWORD` | `your-app-password` | App-specific password or SMTP credential |
| `mail.from` | `MAIL_FROM` | `HostelEase Alerts <no-reply@hostelease.com>` | Display Name & From Address |

---

## 3. SMS Gateway Adapter (Twilio & Mock Provider)

HostelEase uses the `SmsProvider` interface:
```java
public interface SmsProvider {
    boolean sendSms(String recipientPhone, String messageBody);
}
```

### 1. Production Mode: Twilio Gateway
Set in environment variables:
```bat
set SMS_PROVIDER=TWILIO
set TWILIO_ACCOUNT_SID=ACXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
set TWILIO_AUTH_TOKEN=your_auth_token_here
set TWILIO_FROM_NUMBER=+1234567890
```

### 2. Development & Offline Mode: Mock Provider
When `SMS_PROVIDER=MOCK` (default):
- Outgoing SMS messages are safely intercepted, logged to `hostelease.log`, and marked as dispatched without incurring API charges or requiring internet access.
- Ideal for development, evaluation, and offline campus testing.

---

## 4. Key Event Triggers & Notification Templates

| System Event | Recipient | Channels | Content / Purpose |
|---|---|---|---|
| **Leave Application Submitted** | Parent / Guardian | SMS + Email | Informs guardian that student applied for leave with dates & destination. |
| **Leave Approved** | Student & Guardian | Email + SMS | Confirms departure authorization and gate pass readiness. |
| **Physical Gate Departure** | Parent / Guardian | SMS | Real-time alert confirming student has departed campus premises. |
| **Physical Gate Return** | Parent / Guardian | SMS | Confirms student has safely returned to hostel premises. |
| **Overdue Return Alert** | Guardian & Warden | Priority SMS + Email | Immediate alert that student failed to return by scheduled curfew. |
| **Payment Receipt** | Student | Email | Official digital receipt with invoice reference and transaction UTR. |
