package com.lulibrisync.service;

import com.lulibrisync.config.EmailConfig;

import jakarta.mail.Authenticator;
import jakarta.mail.Message;
import jakarta.mail.PasswordAuthentication;
import jakarta.mail.Session;
import jakarta.mail.Transport;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;

import java.util.Properties;

public class EmailService {

    public void sendProfileOtp(String recipientEmail, String recipientName, String otpCode) {
        sendOtpEmail(
                recipientEmail,
                recipientName,
                "LU Librisync Profile Update OTP",
                buildOtpBody(recipientName, otpCode, "updating your LU Librisync profile")
        );
    }

    public void sendPasswordChangeOtp(String recipientEmail, String recipientName, String otpCode) {
        sendOtpEmail(
                recipientEmail,
                recipientName,
                "LU Librisync Change Password OTP",
                buildOtpBody(recipientName, otpCode, "changing your LU Librisync password")
        );
    }

    private void sendOtpEmail(String recipientEmail, String recipientName, String subject, String body) {
        String smtpHost = EmailConfig.getSmtpHost();
        String smtpUsername = EmailConfig.getUsername();
        String smtpPassword = EmailConfig.getPassword();
        String senderEmail = EmailConfig.getSenderEmail();

        if (smtpHost == null || smtpHost.isBlank()
                || smtpUsername == null || smtpUsername.isBlank()
                || smtpPassword == null || smtpPassword.isBlank()
                || senderEmail == null || senderEmail.isBlank()
                || "smtp.example.com".equalsIgnoreCase(smtpHost)) {
            throw new IllegalStateException("mail_not_configured");
        }

        try {
            Properties properties = new Properties();
            properties.put("mail.smtp.auth", "true");
            properties.put("mail.smtp.starttls.enable", "true");
            properties.put("mail.smtp.host", smtpHost);
            properties.put("mail.smtp.port", String.valueOf(EmailConfig.getSmtpPort()));

            Session session = Session.getInstance(properties, new Authenticator() {
                @Override
                protected PasswordAuthentication getPasswordAuthentication() {
                    return new PasswordAuthentication(smtpUsername, smtpPassword);
                }
            });

            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(senderEmail, "LU Librisync"));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(recipientEmail));
            message.setSubject(subject);
            message.setText(body);

            Transport.send(message);
        } catch (IllegalStateException e) {
            throw e;
        } catch (Exception e) {
            throw new IllegalStateException("mail_send_failed", e);
        }
    }

    private String buildOtpBody(String recipientName, String otpCode, String purpose) {
        String name = recipientName == null || recipientName.isBlank() ? "Student" : recipientName.trim();
        return "Hello " + name + ",\n\n"
                + "Your one-time password for " + purpose + " is: " + otpCode + "\n\n"
                + "This code expires in 10 minutes. If you did not request this action, you can ignore this email.\n\n"
                + "LU Librisync";
    }
}
