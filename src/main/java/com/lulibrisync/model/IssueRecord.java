package com.lulibrisync.model;

import java.time.LocalDateTime;

public class IssueRecord {

    private final long id;
    private final long bookId;
    private final long studentDbId;
    private final String studentId;
    private final String studentName;
    private final String bookTitle;
    private final String issueReference;
    private final LocalDateTime issueDate;
    private final LocalDateTime dueDate;
    private final LocalDateTime returnDate;
    private final String status;
    private final double fineAmount;
    private final String remarks;

    public IssueRecord(long id, long bookId, long studentDbId, String studentId, String studentName, String bookTitle,
                       String issueReference, LocalDateTime issueDate, LocalDateTime dueDate, LocalDateTime returnDate,
                       String status, double fineAmount, String remarks) {
        this.id = id;
        this.bookId = bookId;
        this.studentDbId = studentDbId;
        this.studentId = studentId;
        this.studentName = studentName;
        this.bookTitle = bookTitle;
        this.issueReference = issueReference;
        this.issueDate = issueDate;
        this.dueDate = dueDate;
        this.returnDate = returnDate;
        this.status = status;
        this.fineAmount = fineAmount;
        this.remarks = remarks;
    }

    public long getId() {
        return id;
    }

    public long getBookId() {
        return bookId;
    }

    public long getStudentDbId() {
        return studentDbId;
    }

    public String getStudentId() {
        return studentId;
    }

    public String getStudentName() {
        return studentName;
    }

    public String getBookTitle() {
        return bookTitle;
    }

    public String getIssueReference() {
        return issueReference;
    }

    public LocalDateTime getIssueDate() {
        return issueDate;
    }

    public LocalDateTime getDueDate() {
        return dueDate;
    }

    public LocalDateTime getReturnDate() {
        return returnDate;
    }

    public String getStatus() {
        return status;
    }

    public double getFineAmount() {
        return fineAmount;
    }

    public String getRemarks() {
        return remarks;
    }
}
