package com.lulibrisync.config;

public final class EmailConfig {

    private EmailConfig() {
    }

    public static String getSmtpHost() {
        return getEnv("LU_LIBRISYNC_SMTP_HOST", "smtp.example.com");
    }

    public static int getSmtpPort() {
        return Integer.parseInt(getEnv("LU_LIBRISYNC_SMTP_PORT", "587"));
    }

    public static String getUsername() {
        return getEnv("LU_LIBRISYNC_SMTP_USERNAME", "");
    }

    public static String getPassword() {
        return getEnv("LU_LIBRISYNC_SMTP_PASSWORD", "");
    }

    public static String getSenderEmail() {
        return getEnv("LU_LIBRISYNC_SENDER_EMAIL", "noreply@lulibrisync.local");
    }

    private static String getEnv(String key, String fallback) {
        String value = System.getenv(key);
        return value == null || value.isBlank() ? fallback : value.trim();
    }
}
