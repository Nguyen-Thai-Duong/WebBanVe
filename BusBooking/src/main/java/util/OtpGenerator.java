package util;

import java.security.SecureRandom;

/**
 * Generates numeric one-time passcodes.
 */
public final class OtpGenerator {

    private static final SecureRandom RANDOM = new SecureRandom();

    private OtpGenerator() {
    }

    public static String generateNumericCode(int length) {
        if (length <= 0) {
            throw new IllegalArgumentException("OTP length must be positive");
        }
        StringBuilder builder = new StringBuilder(length);
        for (int i = 0; i < length; i++) {
            builder.append(RANDOM.nextInt(10));
        }
        return builder.toString();
    }
}
