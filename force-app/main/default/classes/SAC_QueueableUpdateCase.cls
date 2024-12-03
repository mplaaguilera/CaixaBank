/*****************************************************************
 * Name: SAC_QueueableUpdateCase
 * Copyright © 2023  CaixaBank
 * 
 * Proposito: Actualizar los casos en asincrono
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR           DATE         Description
 * 1.0                             Esperanza Conde  01/08/2023      Creación
*****************************************************************/

public without sharing class SAC_QueueableUpdateCase implements Queueable  {

    private static final String BRACKET_LEFT        = '(';
    private static final String BRACKET_RIGHT       = ') ';
    private static final String BRACKET_RIGHT_ERROR = ') Error: ';

    List<Case> lstReclamacion;

    public SAC_QueueableUpdateCase(List<Case> lstReclamacionC) {
        lstReclamacion = lstReclamacionC;
    }

    public void execute(QueueableContext context) {
        String methodName = 'execute';

        Database.SaveResult[] srList = Database.update(lstReclamacion, false);
        // Iterate through each returned result
        for (Database.SaveResult sr : srList) {
            if (!sr.isSuccess()) {
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) {
                    print(LoggingLevel.ERROR, methodName, '----ERR status: ' + err.getStatusCode() + ': ' + err.getMessage(), true);
                    print(LoggingLevel.ERROR, methodName, '----ERR fields: ' + err.getFields(), true);
                }
            }
        }
    }

    @TestVisible
    private static void print(LoggingLevel level, String methodName, String msg, boolean isError){
        if (msg!=null && msg.length()<6000000) {
            String msgError = BRACKET_LEFT + methodName + (isError ? BRACKET_RIGHT_ERROR : BRACKET_RIGHT) + msg;
            CBK_Log.error(msgError);
        }
    }
}