package com.lulibrisync.model;

public class Student {

    private final long id;
    private final long userId;
    private final String studentId;
    private final String name;
    private final String email;
    private final String course;
    private final String yearLevel;
    private final String phone;
    private final String address;
    private final String status;
    private final int issuedCount;
    private final int reservationCount;
    private final int overdueCount;

    public Student(long id, long userId, String studentId, String name, String email, String course, String yearLevel,
                   String phone, String address, String status, int issuedCount, int reservationCount, int overdueCount) {
        this.id = id;
        this.userId = userId;
        this.studentId = studentId;
        this.name = name;
        this.email = email;
        this.course = course;
        this.yearLevel = yearLevel;
        this.phone = phone;
        this.address = address;
        this.status = status;
        this.issuedCount = issuedCount;
        this.reservationCount = reservationCount;
        this.overdueCount = overdueCount;
    }

    public long getId() {
        return id;
    }

    public long getUserId() {
        return userId;
    }

    public String getStudentId() {
        return studentId;
    }

    public String getName() {
        return name;
    }

    public String getEmail() {
        return email;
    }

    public String getCourse() {
        return course;
    }

    public String getYearLevel() {
        return yearLevel;
    }

    public String getPhone() {
        return phone;
    }

    public String getAddress() {
        return address;
    }

    public String getStatus() {
        return status;
    }

    public int getIssuedCount() {
        return issuedCount;
    }

    public int getReservationCount() {
        return reservationCount;
    }

    public int getOverdueCount() {
        return overdueCount;
    }
}
