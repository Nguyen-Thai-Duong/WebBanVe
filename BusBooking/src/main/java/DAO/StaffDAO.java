package DAO;

/**
 * DAO specialization for managing Staff accounts in the admin console.
 */
public class StaffDAO extends RoleBasedUserDAO {

    public StaffDAO() {
        super("Staff");
    }
}
