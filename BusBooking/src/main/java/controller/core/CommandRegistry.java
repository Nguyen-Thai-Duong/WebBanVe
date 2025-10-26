package controller.core;

import java.util.Map;
import java.util.Objects;
import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Simple in-memory registry mapping HTTP method and path to a {@link Command} implementation.
 */
public class CommandRegistry {

    private final Map<String, Command> commands = new ConcurrentHashMap<>();

    public void register(String httpMethod, String path, Command command) {
        Objects.requireNonNull(httpMethod, "HTTP method must not be null");
        Objects.requireNonNull(path, "Path must not be null");
        Objects.requireNonNull(command, "Command must not be null");
        commands.put(buildKey(httpMethod, path), command);
    }

    public Optional<Command> lookup(String httpMethod, String path) {
        if (httpMethod == null || path == null) {
            return Optional.empty();
        }
        return Optional.ofNullable(commands.get(buildKey(httpMethod, path)));
    }

    private String buildKey(String method, String path) {
        String normalizedMethod = method.trim().toUpperCase();
        String normalizedPath = normalizePath(path);
        return normalizedMethod + "::" + normalizedPath;
    }

    private String normalizePath(String path) {
        if (path == null || path.isBlank()) {
            return "/";
        }
        String normalized = path.trim();
        if (!normalized.startsWith("/")) {
            normalized = "/" + normalized;
        }
        if (normalized.length() > 1 && normalized.endsWith("/")) {
            normalized = normalized.substring(0, normalized.length() - 1);
        }
        return normalized;
    }
}
