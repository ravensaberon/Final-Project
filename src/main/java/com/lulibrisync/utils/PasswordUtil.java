package com.lulibrisync.utils;

import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.PBEKeySpec;
import java.lang.reflect.Constructor;
import java.lang.reflect.Method;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.security.spec.InvalidKeySpecException;
import java.util.Base64;

public final class PasswordUtil {

    private static final String PBKDF2_ALGORITHM = "PBKDF2WithHmacSHA256";
    private static final int PBKDF2_ITERATIONS = 120000;
    private static final int PBKDF2_SALT_BYTES = 16;
    private static final int PBKDF2_HASH_BITS = 256;
    private static final SecureRandom SECURE_RANDOM = new SecureRandom();

    private PasswordUtil() {
    }

    public static String hashPassword(String plainPassword) {
        byte[] salt = new byte[PBKDF2_SALT_BYTES];
        SECURE_RANDOM.nextBytes(salt);

        try {
            byte[] hash = pbkdf2(plainPassword.toCharArray(), salt, PBKDF2_ITERATIONS, PBKDF2_HASH_BITS);
            return "pbkdf2$" + PBKDF2_ITERATIONS + "$"
                    + Base64.getEncoder().encodeToString(salt) + "$"
                    + Base64.getEncoder().encodeToString(hash);
        } catch (NoSuchAlgorithmException | InvalidKeySpecException e) {
            throw new IllegalStateException("Unable to hash password.", e);
        }
    }

    public static boolean verifyPassword(String plainPassword, String storedPassword) {
        if (storedPassword == null || storedPassword.isBlank()) {
            return false;
        }

        if (isBcryptHash(storedPassword)) {
            return verifyBcryptIfAvailable(plainPassword, storedPassword);
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

    private static boolean verifyBcryptIfAvailable(String plainPassword, String storedPassword) {
        try {
            Class<?> encoderClass = Class.forName("org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder");
            Constructor<?> constructor = encoderClass.getConstructor(int.class);
            Object encoder = constructor.newInstance(12);
            Method matchesMethod = encoderClass.getMethod("matches", CharSequence.class, String.class);
            Object result = matchesMethod.invoke(encoder, plainPassword, storedPassword);
            return result instanceof Boolean && (Boolean) result;
        } catch (Exception ignored) {
            return false;
        }
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
