package com.lulibrisync.config;

public final class AppConfig {

    public static final String APP_NAME = "LU Librisync";
    public static final String DEFAULT_TIMEZONE = "Asia/Manila";
    public static final int BORROW_DURATION_DAYS = 14;
    public static final double DAILY_FINE_AMOUNT = 10.00;
    public static final int RESET_TOKEN_EXPIRY_MINUTES = 30;

    private AppConfig() {
    }
}
