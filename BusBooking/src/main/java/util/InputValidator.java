package util;

import java.util.regex.Pattern;

/**
 * Utility helpers for validating common text inputs.
 */
public final class InputValidator {

    private static final Pattern DIGITS_PATTERN = Pattern.compile("^\\d{1,20}$");
    private static final Pattern NAME_PATTERN = Pattern.compile("^[\\p{L}][\\p{L}\\s'.-]*$");
    private static final Pattern AMOUNT_PATTERN = Pattern.compile("^\\d+(\\.\\d{1,2})?$");
    private static final Pattern CITY_PATTERN = Pattern.compile("^[\\p{L}][\\p{L}\\s,.'-]*$");
    private static final Pattern DISTANCE_PATTERN = Pattern.compile("^[1-9]\\d*(\\.\\d+)?$");

    private InputValidator() {
        // prevent instantiation
    }

    public static boolean isValidCity(String value) {
        if (value == null) {
            return false;
        }
        String trimmed = value.trim();
        return !trimmed.isEmpty() && CITY_PATTERN.matcher(trimmed).matches();
    }

    public static boolean isValidDistance(String value) {
        if (value == null) {
            return false;
        }
        String trimmed = value.trim();
        return !trimmed.isEmpty() && DISTANCE_PATTERN.matcher(trimmed).matches();
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
