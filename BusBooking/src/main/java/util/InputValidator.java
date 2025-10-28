package util;

import java.util.regex.Pattern;

/**
 * Utility helpers for validating common text inputs.
 */
public final class InputValidator {

    private static final Pattern DIGITS_PATTERN = Pattern.compile("^\\d{1,20}$");
    private static final Pattern NAME_PATTERN = Pattern.compile("^[\\p{L}][\\p{L}\\s'.-]*$");
    private static final Pattern AMOUNT_PATTERN = Pattern.compile("^\\d+(\\.\\d{1,2})?$");

    private InputValidator() {
        // prevent instantiation
    }

    public static boolean isDigitsOnly(String value) {
        if (value == null) {
            return false;
        }
        String trimmed = value.trim();
        return !trimmed.isEmpty() && DIGITS_PATTERN.matcher(trimmed).matches();
    }

    public static boolean isAlphabeticName(String value) {
        if (value == null) {
            return false;
        }
        String trimmed = value.trim();
        return !trimmed.isEmpty() && NAME_PATTERN.matcher(trimmed).matches();
    }

    public static boolean isValidMonetaryAmount(String value) {
        if (value == null) {
            return false;
        }
        String trimmed = value.trim();
        return !trimmed.isEmpty() && AMOUNT_PATTERN.matcher(trimmed).matches();
    }
}
