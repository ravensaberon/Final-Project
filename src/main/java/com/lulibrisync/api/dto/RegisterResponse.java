package com.lulibrisync.api.dto;

public class RegisterResponse {
    private final String message;
    private final String studentId;

    public RegisterResponse(String message, String studentId) {
        this.message = message;
        this.studentId = studentId;
    }

    public String getMessage() {
        return message;
    }

    public String getStudentId() {
        return studentId;
    }
}
