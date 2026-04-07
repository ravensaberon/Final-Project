package com.lulibrisync.api.dto;

import com.lulibrisync.api.model.ApiUserSummary;

public class AuthResponse {
    private final String token;
    private final String tokenType;
    private final long expiresInMs;
    private final ApiUserSummary user;

    public AuthResponse(String token, String tokenType, long expiresInMs, ApiUserSummary user) {
        this.token = token;
        this.tokenType = tokenType;
        this.expiresInMs = expiresInMs;
        this.user = user;
    }

    public String getToken() {
        return token;
    }

    public String getTokenType() {
        return tokenType;
    }

    public long getExpiresInMs() {
        return expiresInMs;
    }

    public ApiUserSummary getUser() {
        return user;
    }
}
