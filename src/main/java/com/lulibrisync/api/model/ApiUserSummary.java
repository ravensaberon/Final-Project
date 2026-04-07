package com.lulibrisync.api.model;

public class ApiUserSummary {
    private final long id;
    private final String name;
    private final String email;
    private final String role;
    private final String status;
    private final String studentId;

    public ApiUserSummary(long id, String name, String email, String role, String status, String studentId) {
        this.id = id;
        this.name = name;
        this.email = email;
        this.role = role;
        this.status = status;
        this.studentId = studentId;
    }

    public long getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    public String getEmail() {
        return email;
    }

    public String getRole() {
        return role;
    }

    public String getStatus() {
        return status;
    }

    public String getStudentId() {
        return studentId;
    }
}
