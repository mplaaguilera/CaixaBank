/*****************************************************************
 * Name: SAC_ComportamientoSLAs
 * Copyright © 2019  CaixaBank
 * ============================================================
 * Proposito: Clase para insertar los errores en el objeto correspondiente de errores del proyecto SAC
 * ============================================================
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0            US219261         Nicolás García 15/06/21      Creación
*****************************************************************/
public class SAC_errorHandler {
    public static void insertError(DateTime errorDateTime, String userName, String className, String methodName, String errorMessage, String stackTrace){
        //if(Schema.sObjectType.SAC_Error__c.isCreateable()){
            //insert new SAC_Error__c(SAC_ClassName__c = className, SAC_ErrorDateTime__c = errorDateTime, SAC_ErrorMessage__c = errorMessage, SAC_MethodName__c = methodName, SAC_StackTrace__c = stackTrace, SAC_UserName__c = userName);
        //}
    }
}