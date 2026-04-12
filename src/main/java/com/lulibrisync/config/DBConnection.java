package com.lulibrisync.config;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Properties;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Locale;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public final class DBConnection {

    private static final String DEFAULT_URL = "jdbc:mysql://localhost:3306/lu_librisync?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=Asia/Manila";
    private static final String DEFAULT_USER = "root";
    private static final String DEFAULT_PASSWORD = "";
    private static final Pattern URL_WITH_PORT_PATTERN =
            Pattern.compile("^(jdbc:mysql://[^/:?#]+:)(\\d+)(/[^?]+)(\\?.*)?$", Pattern.CASE_INSENSITIVE);
    private static final Properties APPLICATION_PROPERTIES = loadApplicationProperties();

    private DBConnection() {
    }

    public static Connection getConnection() {
        String configuredUrl = withDefaultJdbcParams(resolveConfig("LU_LIBRISYNC_DB_URL", DEFAULT_URL));
        String configuredUser = resolveConfig("LU_LIBRISYNC_DB_USER", DEFAULT_USER);
        String configuredPassword = resolveConfig("LU_LIBRISYNC_DB_PASSWORD", DEFAULT_PASSWORD);

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (Exception e) {
            System.err.println("[LU_LIBRISYNC][DB] MySQL JDBC driver load failed.");
            e.printStackTrace();
            return null;
        }

        SQLException lastSqlException = null;
        for (String candidateUrl : buildCandidateUrls(configuredUrl)) {
            try {
                return DriverManager.getConnection(candidateUrl, configuredUser, configuredPassword);
            } catch (SQLException e) {
                lastSqlException = e;
                System.err.println("[LU_LIBRISYNC][DB] Connection failed for URL: " + candidateUrl
                        + " | user: " + configuredUser
                        + " | reason: " + e.getMessage());

                // Stop retries for non-network failures (ex: bad password, missing database, SQL auth issues).
                if (!isRetryableConnectionFailure(e)) {
                    e.printStackTrace();
                    return null;
                }
            }
        }

        if (lastSqlException != null) {
            lastSqlException.printStackTrace();
        }

        return null;
    }

    private static String resolveConfig(String key, String fallback) {
        String applicationPropertyValue = getApplicationPropertyFor(key);
        if (applicationPropertyValue != null) {
            return applicationPropertyValue;
        }

        String envValue = System.getenv(key);
        if (envValue != null) {
            return envValue.trim();
        }

        String propertyValue = System.getProperty(key);
        if (propertyValue != null) {
            return propertyValue.trim();
        }

        return fallback;
    }

    private static Properties loadApplicationProperties() {
        Properties properties = new Properties();
        try (var inputStream = DBConnection.class.getClassLoader().getResourceAsStream("application.properties")) {
            if (inputStream != null) {
                properties.load(inputStream);
            }
        } catch (Exception e) {
            System.err.println("[LU_LIBRISYNC][DB] Unable to load application.properties.");
            e.printStackTrace();
        }
        return properties;
    }

    private static String getApplicationPropertyFor(String key) {
        String propertyKey;
        switch (key) {
            case "LU_LIBRISYNC_DB_URL":
                propertyKey = "spring.datasource.url";
                break;
            case "LU_LIBRISYNC_DB_USER":
                propertyKey = "spring.datasource.username";
                break;
            case "LU_LIBRISYNC_DB_PASSWORD":
                propertyKey = "spring.datasource.password";
                break;
            default:
                propertyKey = null;
        }

        if (propertyKey == null) {
            return null;
        }

        String rawValue = APPLICATION_PROPERTIES.getProperty(propertyKey);
        if (rawValue == null) {
            return null;
        }

        // Supports Spring-style placeholders like ${ENV:fallback} used in this project.
        if (rawValue.startsWith("${") && rawValue.endsWith("}")) {
            String placeholderBody = rawValue.substring(2, rawValue.length() - 1);
            int separatorIndex = placeholderBody.indexOf(':');
            String referencedKey = separatorIndex >= 0
                    ? placeholderBody.substring(0, separatorIndex)
                    : placeholderBody;
            String fallback = separatorIndex >= 0
                    ? placeholderBody.substring(separatorIndex + 1)
                    : null;

            String envValue = System.getenv(referencedKey);
            if (envValue != null) {
                return envValue.trim();
            }

            String systemValue = System.getProperty(referencedKey);
            if (systemValue != null) {
                return systemValue.trim();
            }

            return fallback == null ? null : fallback.trim();
        }

        return rawValue.trim();
    }

    private static String withDefaultJdbcParams(String url) {
        String normalized = (url == null || url.isBlank()) ? DEFAULT_URL : url.trim();
        normalized = appendParamIfMissing(normalized, "useSSL", "false");
        normalized = appendParamIfMissing(normalized, "allowPublicKeyRetrieval", "true");
        normalized = appendParamIfMissing(normalized, "serverTimezone", "Asia/Manila");
        return normalized;
    }

    private static String appendParamIfMissing(String url, String key, String value) {
        if (url.toLowerCase().contains((key + "=").toLowerCase())) {
            return url;
        }
        return url + (url.contains("?") ? "&" : "?") + key + "=" + value;
    }

    private static List<String> buildCandidateUrls(String configuredUrl) {
        Set<String> candidates = new LinkedHashSet<>();
        String normalized = withDefaultJdbcParams(configuredUrl);
        candidates.add(normalized);

        Matcher matcher = URL_WITH_PORT_PATTERN.matcher(normalized);
        if (matcher.matches()) {
            String prefix = matcher.group(1);
            String port = matcher.group(2);
            String path = matcher.group(3);
            String query = matcher.group(4) == null ? "" : matcher.group(4);

            if (!"3306".equals(port)) {
                candidates.add(prefix + "3306" + path + query);
            }
            if (!"3006".equals(port)) {
                candidates.add(prefix + "3006" + path + query);
            }

            if (prefix.toLowerCase().contains("localhost")) {
                String ipPrefix = prefix.replaceAll("(?i)localhost", "127.0.0.1");
                candidates.add(ipPrefix + port + path + query);
                if (!"3306".equals(port)) {
                    candidates.add(ipPrefix + "3306" + path + query);
                }
                if (!"3006".equals(port)) {
                    candidates.add(ipPrefix + "3006" + path + query);
                }
            }
        }

        return new ArrayList<>(candidates);
    }

    private static boolean isRetryableConnectionFailure(SQLException exception) {
        String sqlState = exception.getSQLState();
        if (sqlState != null && sqlState.startsWith("08")) {
            return true; // connection exceptions
        }

        String message = exception.getMessage();
        if (message == null) {
            return false;
        }

        String lowerMessage = message.toLowerCase(Locale.ROOT);
        return lowerMessage.contains("connection refused")
                || lowerMessage.contains("communications link failure")
                || lowerMessage.contains("connect timed out")
                || lowerMessage.contains("connection timed out")
                || lowerMessage.contains("no route to host");
    }
}
