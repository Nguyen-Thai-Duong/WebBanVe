package DAO;

/**
 * DAO specialization for managing bus operator accounts from the admin portal.
 */
public class BusOperatorDAO extends RoleBasedUserDAO {

    public BusOperatorDAO() {
        super("BusOperator");
    }
}
