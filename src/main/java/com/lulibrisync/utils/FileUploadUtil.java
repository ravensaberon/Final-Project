package com.lulibrisync.utils;

import javax.servlet.http.Part;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.text.Normalizer;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

public final class FileUploadUtil {

    private static final DateTimeFormatter FILE_SUFFIX = DateTimeFormatter.ofPattern("yyyyMMddHHmmss");

    private FileUploadUtil() {
    }

    public static String savePdf(Part part, Path directory, String baseName) throws IOException {
        if (part == null || part.getSize() <= 0) {
            throw new IOException("Missing upload content.");
        }

        Files.createDirectories(directory);

        String submittedName = part.getSubmittedFileName() == null ? "ebook.pdf" : part.getSubmittedFileName().trim();
        String extension = submittedName.toLowerCase().endsWith(".pdf") ? ".pdf" : "";
        if (!".pdf".equals(extension)) {
            throw new IOException("Only PDF uploads are supported.");
        }

        String safeBaseName = sanitizeBaseName(baseName);
        String fileName = safeBaseName + "-" + LocalDateTime.now().format(FILE_SUFFIX) + extension;
        Path target = directory.resolve(fileName);

        try (InputStream inputStream = part.getInputStream()) {
            Files.copy(inputStream, target, StandardCopyOption.REPLACE_EXISTING);
        }

        return target.toAbsolutePath().toString();
    }

    private static String sanitizeBaseName(String value) {
        String normalized = value == null ? "ebook" : value.trim();
        if (normalized.isEmpty()) {
            normalized = "ebook";
        }

        String ascii = Normalizer.normalize(normalized, Normalizer.Form.NFD)
                .replaceAll("\\p{M}", "");
        String safe = ascii.replaceAll("[^A-Za-z0-9]+", "-")
                .replaceAll("^-+", "")
                .replaceAll("-+$", "")
                .toLowerCase();
        return safe.isEmpty() ? "ebook" : safe;
    }
}
