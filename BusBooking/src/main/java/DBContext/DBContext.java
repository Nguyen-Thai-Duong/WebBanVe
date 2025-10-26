package DBContext;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Helper for managing JDBC interactions with the BusBooking SQL Server database.
 */
public class DBContext implements AutoCloseable {

    private static final String DEFAULT_URL = "jdbc:sqlserver://localhost:1433;databaseName=BusBookingSystem1;encrypt=false";
    private static final String DEFAULT_USER = "sa";
    private static final String DEFAULT_PASSWORD = "123";

    private static final Logger LOGGER = LoggerFactory.getLogger(DBContext.class);

    private Connection connection;

    public DBContext() {
        this(DEFAULT_URL, DEFAULT_USER, DEFAULT_PASSWORD);
    }

    public DBContext(String url, String user, String password) {
        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            connection = DriverManager.getConnection(url, user, password);
        } catch (ClassNotFoundException e) {
            LOGGER.error("SQL Server JDBC driver not found.", e);
        } catch (SQLException e) {
            LOGGER.error("Failed to establish database connection.", e);
        }
    }

    public Connection getConnection() {
        return connection;
    }

    public void closeConnection() {
        if (connection != null) {
            try {
                connection.close();
            } catch (SQLException e) {
                LOGGER.warn("Error closing database connection.", e);
            }
        }
    }

    @Override
    public void close() {
        closeConnection();
    }

    public ResultSet executeSelect(String query, Object[] params) throws SQLException {
        ensureConnected();
        PreparedStatement statement = prepareStatement(query, params);
        return statement.executeQuery();
    }

    public ResultSet executeSelect(String query) throws SQLException {
        return executeSelect(query, null);
    }

    public int executeUpdate(String query, Object[] params) throws SQLException {
        ensureConnected();
        try (PreparedStatement statement = prepareStatement(query, params)) {
            return statement.executeUpdate();
        }
    }

    private PreparedStatement prepareStatement(String query, Object[] params) throws SQLException {
        PreparedStatement statement = connection.prepareStatement(query);
        if (params != null) {
            for (int i = 0; i < params.length; i++) {
                statement.setObject(i + 1, params[i]);
            }
        }
        return statement;
    }

    private void ensureConnected() throws SQLException {
        if (connection == null || connection.isClosed()) {
            throw new SQLException("Database connection is not available.");
        }
    }
}
