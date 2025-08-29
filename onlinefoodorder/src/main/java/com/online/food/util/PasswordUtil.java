package com.online.food.util;

import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.PBEKeySpec;
import java.security.SecureRandom;
import java.util.Base64;

public final class PasswordUtil {

    // ——— Tunable parameters ———
    private static final int ITERATIONS = 65_536;      // ≥ 60k today
    private static final int KEY_LENGTH = 256;         // bits
    private static final String ALGORITHM = "PBKDF2WithHmacSHA256";

    private static final SecureRandom RNG = new SecureRandom();

    private PasswordUtil() {} // utility

    /**
     * @return a string in the form  iterations:salt:hash  (all Base64‑encoded)
     */
    public static String hash(String plain) {
        byte[] salt = new byte[16];
        RNG.nextBytes(salt);

        byte[] hash = pbkdf2(plain.toCharArray(), salt);
        return ITERATIONS + ":" +
                Base64.getEncoder().encodeToString(salt) + ":" +
                Base64.getEncoder().encodeToString(hash);
    }

    /** Verifies a plain text password against the stored  iterations:salt:hash  value */
    public static boolean verify(String plain, String stored) {
        String[] parts = stored.split(":");
        int iterations = Integer.parseInt(parts[0]);
        byte[] salt = Base64.getDecoder().decode(parts[1]);
        byte[] expected = Base64.getDecoder().decode(parts[2]);

        byte[] testHash = pbkdf2(plain.toCharArray(), salt, iterations);
        return slowEquals(expected, testHash);
    }

    // ——— helpers ———
    private static byte[] pbkdf2(char[] pwd, byte[] salt) {
        return pbkdf2(pwd, salt, ITERATIONS);
    }

    private static byte[] pbkdf2(char[] pwd, byte[] salt, int iterations) {
        try {
            PBEKeySpec spec = new PBEKeySpec(pwd, salt, iterations, KEY_LENGTH);
            SecretKeyFactory skf = SecretKeyFactory.getInstance(ALGORITHM);
            return skf.generateSecret(spec).getEncoded();
        } catch (Exception e) {
            throw new IllegalStateException("PBKDF2 error", e);
        }
    }

    /** Constant‑time comparison to prevent timing attacks */
    private static boolean slowEquals(byte[] a, byte[] b) {
        int diff = a.length ^ b.length;
        for (int i = 0; i < a.length && i < b.length; i++) {
            diff |= a[i] ^ b[i];
        }
        return diff == 0;
    }
}
