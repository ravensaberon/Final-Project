package com.lulibrisync.utils;

import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.PBEKeySpec;
import java.security.NoSuchAlgorithmException;
import java.security.spec.InvalidKeySpecException;
import java.util.Base64;

public final class PasswordUtil {

    private static final BCryptPasswordEncoder BCRYPT = new BCryptPasswordEncoder(12);

    // Legacy PBKDF2 support (kept for backward compatibility/migration).
    private static final String PBKDF2_ALGORITHM = "PBKDF2WithHmacSHA256";

    private PasswordUtil() {
    }

    public static String hashPassword(String plainPassword) {
        return BCRYPT.encode(plainPassword);
    }

    public static boolean verifyPassword(String plainPassword, String storedPassword) {
        if (storedPassword == null || storedPassword.isBlank()) {
            return false;
        }

        if (isBcryptHash(storedPassword)) {
            return BCRYPT.matches(plainPassword, storedPassword);
        }

        if (storedPassword.startsWith("pbkdf2$")) {
            return verifyLegacyPbkdf2(plainPassword, storedPassword);
        }

        // Legacy plain-text fallback for very old records.
        return storedPassword.equals(plainPassword);
    }

    public static boolean isBcryptHash(String hash) {
        if (hash == null) {
            return false;
        }
        return hash.startsWith("$2a$") || hash.startsWith("$2b$") || hash.startsWith("$2y$");
    }

    private static boolean verifyLegacyPbkdf2(String plainPassword, String storedPassword) {
        try {
            String[] parts = storedPassword.split("\\$");
            if (parts.length != 4) {
                return false;
            }

            int iterations = Integer.parseInt(parts[1]);
            byte[] salt = Base64.getDecoder().decode(parts[2]);
            byte[] expectedHash = Base64.getDecoder().decode(parts[3]);
            byte[] actualHash = pbkdf2(plainPassword.toCharArray(), salt, iterations, expectedHash.length * 8);

            if (expectedHash.length != actualHash.length) {
                return false;
            }

            int diff = 0;
            for (int i = 0; i < expectedHash.length; i++) {
                diff |= expectedHash[i] ^ actualHash[i];
            }
            return diff == 0;
        } catch (Exception e) {
            return false;
        }
    }

    private static byte[] pbkdf2(char[] password, byte[] salt, int iterations, int keyLength)
            throws NoSuchAlgorithmException, InvalidKeySpecException {
        PBEKeySpec spec = new PBEKeySpec(password, salt, iterations, keyLength);
        SecretKeyFactory skf = SecretKeyFactory.getInstance(PBKDF2_ALGORITHM);
        return skf.generateSecret(spec).getEncoded();
    }
}
