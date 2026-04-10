package com.lulibrisync.model;

public class Category {

    private final long id;
    private final String name;
    private final String description;
    private final int bookCount;

    public Category(long id, String name, String description, int bookCount) {
        this.id = id;
        this.name = name;
        this.description = description;
        this.bookCount = bookCount;
    }

    public long getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    public String getDescription() {
        return description;
    }

    public int getBookCount() {
        return bookCount;
    }
}
