package com.lulibrisync.api.controller;

import com.lulibrisync.api.dto.AuthLoginRequest;
import com.lulibrisync.api.dto.AuthRegisterRequest;
import com.lulibrisync.api.dto.AuthResponse;
import com.lulibrisync.api.dto.RegisterResponse;
import com.lulibrisync.api.service.AuthApiService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import javax.validation.Valid;

@RestController
@RequestMapping("/api/auth")
@Validated
public class AuthApiController {

    private final AuthApiService authApiService;

    public AuthApiController(AuthApiService authApiService) {
        this.authApiService = authApiService;
    }

    @PostMapping("/login")
    public ResponseEntity<AuthResponse> login(@Valid @RequestBody AuthLoginRequest request) {
        AuthResponse response = authApiService.login(request);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/register")
    public ResponseEntity<RegisterResponse> register(@Valid @RequestBody AuthRegisterRequest request) {
        RegisterResponse response = authApiService.register(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }
}
