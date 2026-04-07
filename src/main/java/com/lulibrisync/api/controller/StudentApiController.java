package com.lulibrisync.api.controller;

import com.lulibrisync.api.model.ApiUserSummary;
import com.lulibrisync.api.repository.ApiUserRepository;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

import static org.springframework.http.HttpStatus.UNAUTHORIZED;

@RestController
@RequestMapping("/api/student")
public class StudentApiController {

    private final ApiUserRepository apiUserRepository;

    public StudentApiController(ApiUserRepository apiUserRepository) {
        this.apiUserRepository = apiUserRepository;
    }

    @GetMapping("/profile")
    public ApiUserSummary profile(Authentication authentication) {
        if (authentication == null || authentication.getName() == null) {
            throw new ResponseStatusException(UNAUTHORIZED, "Unauthenticated request.");
        }

        ApiUserSummary user = apiUserRepository.findUserSummaryByEmail(authentication.getName());
        if (user == null) {
            throw new ResponseStatusException(UNAUTHORIZED, "User not found.");
        }
        return user;
    }
}
