package com.lulibrisync.api.model;

public class ApiUser {
    private final long id;
    private final String name;
    private final String email;
    private final String password;
    private final String role;
    private final String studentId;
    private final String status;

    public ApiUser(long id, String name, String email, String password, String role, String studentId, String status) {
        this.id = id;
        this.name = name;
        this.email = email;
        this.password = password;
        this.role = role;
        this.studentId = studentId;
        this.status = status;
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

    public String getPassword() {
        return password;
    }

    public String getRole() {
        return role;
    }

    public String getStudentId() {
        return studentId;
    }

    public String getStatus() {
        return status;
    }
}
