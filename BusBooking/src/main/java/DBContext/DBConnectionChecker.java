package DBContext;

/**
 * Simple entry-point to verify database connectivity via DBContext.
 */
public class DBConnectionChecker {

    public static void main(String[] args) {
        try (DBContext dbContext = new DBContext()) {
            if (dbContext.getConnection() != null && !dbContext.getConnection().isClosed()) {
                System.out.println("Database connection established successfully.");
            } else {
                System.err.println("Database connection is null or closed.");
            }
        } catch (Exception e) {
            System.err.println("Database connectivity test failed: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
