package com.lulibrisync.model;

public class Book {

    private final long id;
    private final String title;
    private final String isbn;
    private final String barcode;
    private final Long categoryId;
    private final String categoryName;
    private final Long authorId;
    private final String authorName;
    private final Integer publicationYear;
    private final int quantity;
    private final int availableQuantity;
    private final String shelfLocation;
    private final String description;
    private final boolean digital;

    public Book(long id, String title, String isbn, String barcode, Long categoryId, String categoryName,
                Long authorId, String authorName, Integer publicationYear, int quantity, int availableQuantity,
                String shelfLocation, String description, boolean digital) {
        this.id = id;
        this.title = title;
        this.isbn = isbn;
        this.barcode = barcode;
        this.categoryId = categoryId;
        this.categoryName = categoryName;
        this.authorId = authorId;
        this.authorName = authorName;
        this.publicationYear = publicationYear;
        this.quantity = quantity;
        this.availableQuantity = availableQuantity;
        this.shelfLocation = shelfLocation;
        this.description = description;
        this.digital = digital;
    }

    public long getId() {
        return id;
    }

    public String getTitle() {
        return title;
    }

    public String getIsbn() {
        return isbn;
    }

    public String getBarcode() {
        return barcode;
    }

    public Long getCategoryId() {
        return categoryId;
    }

    public String getCategoryName() {
        return categoryName;
    }

    public Long getAuthorId() {
        return authorId;
    }

    public String getAuthorName() {
        return authorName;
    }

    public Integer getPublicationYear() {
        return publicationYear;
    }

    public int getQuantity() {
        return quantity;
    }

    public int getAvailableQuantity() {
        return availableQuantity;
    }

    public String getShelfLocation() {
        return shelfLocation;
    }

    public String getDescription() {
        return description;
    }

    public boolean isDigital() {
        return digital;
    }
}
