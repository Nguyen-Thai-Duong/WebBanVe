package DBContext;

public class TestConnection {
    public static void main(String[] args) {
        System.out.println("Testing database connection...");
        try (DBContext db = new DBContext()) {
            if (db.getConnection() != null && !db.getConnection().isClosed()) {
                System.out.println("✅ Connection successful!");
                System.out.println("Server: LAPTOP-ULLKF8SD\\SQLEXPRESS");
                System.out.println("Database: BusBookingSystem");
            } else {
                System.out.println("❌ Connection failed - connection is null or closed");
            }
        } catch (Exception e) {
            System.out.println("❌ Connection failed with error:");
            System.out.println(e.getMessage());
            e.printStackTrace();
        }
    }
}