package consign.entity;

/**
 * @author fdse
 */
public class InsertConsignRecordResult {
    private boolean status;

    private String message;

    public InsertConsignRecordResult(){
        //Default Constructor
    }

    public boolean isStatus() {
        return status;
    }

    public void setStatus(boolean status) {
        this.status = status;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }
}
