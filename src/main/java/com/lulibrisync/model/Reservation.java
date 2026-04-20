package com.lulibrisync.model;

import java.time.LocalDateTime;

public class Reservation {

    private final long id;
    private final long bookId;
    private final long studentDbId;
    private final String title;
    private final String isbn;
    private final int queuePosition;
    private final String status;
    private final LocalDateTime reservedAt;
    private final LocalDateTime expiresAt;
    private final boolean digital;

    public Reservation(long id, long bookId, long studentDbId, String title, String isbn, int queuePosition,
                       String status, LocalDateTime reservedAt, LocalDateTime expiresAt, boolean digital) {
        this.id = id;
        this.bookId = bookId;
        this.studentDbId = studentDbId;
        this.title = title;
        this.isbn = isbn;
        this.queuePosition = queuePosition;
        this.status = status;
        this.reservedAt = reservedAt;
        this.expiresAt = expiresAt;
        this.digital = digital;
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

    public String getTitle() {
        return title;
    }

    public String getIsbn() {
        return isbn;
    }

    public int getQueuePosition() {
        return queuePosition;
    }

    public String getStatus() {
        return status;
    }

    public LocalDateTime getReservedAt() {
        return reservedAt;
    }

    public LocalDateTime getExpiresAt() {
        return expiresAt;
    }

    public boolean isDigital() {
        return digital;
    }
}
