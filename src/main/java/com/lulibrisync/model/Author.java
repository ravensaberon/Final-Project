package com.lulibrisync.model;

public class Author {

    private final long id;
    private final String name;
    private final String bio;
    private final int bookCount;

    public Author(long id, String name, String bio, int bookCount) {
        this.id = id;
        this.name = name;
        this.bio = bio;
        this.bookCount = bookCount;
    }

    public long getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    public String getBio() {
        return bio;
    }

    public int getBookCount() {
        return bookCount;
    }
}
