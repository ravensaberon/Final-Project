package com.lulibrisync.model;

import java.time.LocalDateTime;

public class Fine {

    private final long id;
    private final long issueRecordId;
    private final long studentDbId;
    private final double amount;
    private final String status;
    private final LocalDateTime calculatedAt;
    private final LocalDateTime paidAt;

    public Fine(long id, long issueRecordId, long studentDbId, double amount, String status,
                LocalDateTime calculatedAt, LocalDateTime paidAt) {
        this.id = id;
        this.issueRecordId = issueRecordId;
        this.studentDbId = studentDbId;
        this.amount = amount;
        this.status = status;
        this.calculatedAt = calculatedAt;
        this.paidAt = paidAt;
    }

    public long getId() {
        return id;
    }

    public long getIssueRecordId() {
        return issueRecordId;
    }

    public long getStudentDbId() {
        return studentDbId;
    }

    public double getAmount() {
        return amount;
    }

    public String getStatus() {
        return status;
    }

    public LocalDateTime getCalculatedAt() {
        return calculatedAt;
    }

    public LocalDateTime getPaidAt() {
        return paidAt;
    }
}
