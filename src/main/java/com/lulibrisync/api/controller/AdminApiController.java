package com.lulibrisync.api.controller;

import com.lulibrisync.api.model.ApiUserSummary;
import com.lulibrisync.api.repository.ApiUserRepository;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/admin")
public class AdminApiController {

    private final ApiUserRepository apiUserRepository;

    public AdminApiController(ApiUserRepository apiUserRepository) {
        this.apiUserRepository = apiUserRepository;
    }

    @GetMapping("/users")
    public List<ApiUserSummary> listUsers() {
        return apiUserRepository.findAllUsers();
    }
}
