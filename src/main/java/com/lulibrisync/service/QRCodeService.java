package com.lulibrisync.service;

import com.lulibrisync.utils.QRCodeGenerator;

public class QRCodeService {

    public String generateIssueQrDataUri(String issueReference) {
        String normalized = issueReference == null ? "" : issueReference.trim();
        if (normalized.isEmpty()) {
            return "";
        }
        return QRCodeGenerator.toDataUri(normalized, 240);
    }
}
