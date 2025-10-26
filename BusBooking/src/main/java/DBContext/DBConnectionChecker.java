package DBContext;

import java.sql.Connection;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Simple entry-point to verify database connectivity via DBContext.
 */
public class DBConnectionChecker {

    private static final Logger LOGGER = LoggerFactory.getLogger(DBConnectionChecker.class);

    public static void main(String[] args) {
        try (DBContext dbContext = new DBContext()) {
            Connection connection = dbContext.getConnection();
            if (connection != null && !connection.isClosed()) {
                LOGGER.info("Database connection established successfully.");
            } else {
                LOGGER.warn("Database connection is null or closed.");
            }
        } catch (Exception e) {
            LOGGER.error("Database connectivity test failed.", e);
        }
    }
}
