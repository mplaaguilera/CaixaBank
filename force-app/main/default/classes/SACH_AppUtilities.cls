public with sharing class SACH_AppUtilities {

    private static final String BRACKET_LEFT        = '(';
    private static final String BRACKET_RIGHT       = ') ';
    private static final String BRACKET_RIGHT_ERROR = ') Error: ';
    
    /**
     * Display the errors from database Result: operation save
     */
    public static void displayErrors(String methodName, List<Database.SaveResult> listUpdateResult){
        if (listUpdateResult!=null && !listUpdateResult.isEmpty()){
            
            for (Database.SaveResult sr : listUpdateResult) {
                if (!sr.isSuccess()) {
                    // Operation failed, so get all errors
                    for(Database.Error err : sr.getErrors()) {
                        print(LoggingLevel.ERROR, methodName, '----ERR status: ' + err.getStatusCode() + ': ' + err.getMessage(), true);
                        print(LoggingLevel.ERROR, methodName, '----ERR fields: ' + err.getFields(), true);
                    }
                }
            }
            print(LoggingLevel.ERROR, methodName, '***************************', true);
        }
    }

        /**
     * Display the errors from database Result: operation save
     */
    public static void displayErrorsDelete(String methodName, List<Database.DeleteResult> listDeleteResult){
        if (listDeleteResult!=null && !listDeleteResult.isEmpty()){
            
            for (Database.DeleteResult sr : listDeleteResult) {
                if (!sr.isSuccess()) {
                    // Operation failed, so get all errors
                    for(Database.Error err : sr.getErrors()) {
                        print(LoggingLevel.ERROR, methodName, '----ERR status: ' + err.getStatusCode() + ': ' + err.getMessage(), true);
                        print(LoggingLevel.ERROR, methodName, '----ERR fields: ' + err.getFields(), true);
                    }
                }
            }
            print(LoggingLevel.ERROR, methodName, '***************************', true);
        }
    }

    private static void print(LoggingLevel level, String methodName, String msg, boolean isError){
        if (msg!=null && msg.length()<6000000) {
            String msgError = BRACKET_LEFT + methodName + (isError ? BRACKET_RIGHT_ERROR : BRACKET_RIGHT) + msg;
            CBK_Log.error(msgError);
        }
    }
	
}