package com.lulibrisync.config;

import java.util.Properties;

public final class EmailConfig {

    private static final Properties APPLICATION_PROPERTIES = loadApplicationProperties();

    private EmailConfig() {
    }

    public static String getSmtpHost() {
        return resolveConfig("LU_LIBRISYNC_SMTP_HOST", "app.mail.smtp.host", "smtp.example.com");
    }

    public static int getSmtpPort() {
        String configuredPort = resolveConfig("LU_LIBRISYNC_SMTP_PORT", "app.mail.smtp.port", "587");
        try {
            return Integer.parseInt(configuredPort);
        } catch (Exception e) {
            return 587;
        }
    }

    public static String getUsername() {
        return resolveConfig("LU_LIBRISYNC_SMTP_USERNAME", "app.mail.smtp.username", "");
    }

    public static String getPassword() {
        return resolveConfig("LU_LIBRISYNC_SMTP_PASSWORD", "app.mail.smtp.password", "");
    }

    public static String getSenderEmail() {
        return resolveConfig("LU_LIBRISYNC_SENDER_EMAIL", "app.mail.sender.email", "noreply@lulibrisync.local");
    }

    private static String resolveConfig(String envKey, String propertyKey, String fallback) {
        String propertyValue = APPLICATION_PROPERTIES.getProperty(propertyKey);
        String resolvedPropertyValue = resolvePlaceholderValue(propertyValue);
        if (resolvedPropertyValue != null) {
            return resolvedPropertyValue;
        }

        String envValue = System.getenv(envKey);
        if (envValue != null && !envValue.isBlank()) {
            return envValue.trim();
        }

        String systemValue = System.getProperty(envKey);
        if (systemValue != null && !systemValue.isBlank()) {
            return systemValue.trim();
        }

        return fallback;
    }

    private static String resolvePlaceholderValue(String rawValue) {
        if (rawValue == null || rawValue.isBlank()) {
            return null;
        }

        String trimmed = rawValue.trim();
        if (!trimmed.startsWith("${") || !trimmed.endsWith("}")) {
            return trimmed;
        }

        String placeholderBody = trimmed.substring(2, trimmed.length() - 1);
        int separatorIndex = placeholderBody.indexOf(':');
        String referencedKey = separatorIndex >= 0
                ? placeholderBody.substring(0, separatorIndex)
                : placeholderBody;
        String fallback = separatorIndex >= 0
                ? placeholderBody.substring(separatorIndex + 1)
                : null;

        String envValue = System.getenv(referencedKey);
        if (envValue != null && !envValue.isBlank()) {
            return envValue.trim();
        }

        String systemValue = System.getProperty(referencedKey);
        if (systemValue != null && !systemValue.isBlank()) {
            return systemValue.trim();
        }

        return fallback == null ? null : fallback.trim();
    }

    private static Properties loadApplicationProperties() {
        Properties properties = new Properties();
        try (var inputStream = EmailConfig.class.getClassLoader().getResourceAsStream("application.properties")) {
            if (inputStream != null) {
                properties.load(inputStream);
            }
        } catch (Exception e) {
            System.err.println("[LU_LIBRISYNC][MAIL] Unable to load application.properties.");
            e.printStackTrace();
        }
        return properties;
    }
}
